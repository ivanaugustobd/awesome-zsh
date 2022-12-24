#!/bin/zsh -e

ZSHRC=~/.zshrc
OMZ_CUSTOM_FOLDER="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
BOLD=$(tput bold)
UNFORMAT=$(tput sgr0)

echo '' > install.log

sudo --prompt "${BOLD}Insert your sudo password${UNFORMAT} (to automatically set the zsh as default shell later on): " echo -n ''

# Oh My Zsh setup
echo -n 'Installing Oh My Zsh.. '
[ -e "$ZSHRC" ] && mv "$ZSHRC"{,.bkp}
OMZ_DIR=~/.oh-my-zsh
if [ -d "$OMZ_DIR" ]; then
  echo -n "backuping old $OMZ_DIR dir.. "
  rm -rf "$OMZ_DIR".bkp
  mv "$OMZ_DIR"{,.bkp}
fi
curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh > omz_install.sh
chmod +x omz_install.sh
./omz_install.sh --unattended &>> install.log
rm ./omz_install.sh
echo 'done.'

# Plugins
_csv_get_column() {
  cut -d ',' -f $2 <<< $1
}
IS_HEADER=0
while read LINE; do
  [ "$IS_HEADER" -eq 0 ] && IS_HEADER=1 && continue

  ID="$(_csv_get_column $LINE 1)"
  URL="$(_csv_get_column $LINE 2)"
  NAME="$(_csv_get_column $LINE 3)"

  echo -n "Installing $NAME.. "
  git clone $URL "$OMZ_CUSTOM_FOLDER/plugins/$ID" &>> install.log
  echo -n 'enabling it.. '
  sed -i "s/\(plugins=(git\)*)/\1 $ID)/" "$ZSHRC"
  echo 'done.'
done < plugins.csv

# Theme
echo -n 'Installing p10k theme.. '
URL=https://github.com/romkatv/powerlevel10k
DEST_DIR="$OMZ_CUSTOM_FOLDER/themes/powerlevel10k"
git clone --depth=1 $URL "$DEST_DIR" &>> install.log
echo -n 'enabling it.. '
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
echo 'done.'

# Shell
echo -n 'Setting zsh as the default shell.. '
sudo usermod --shell "$(which zsh)" "$USER" &>> install.log
echo 'done.'

# Done
echo 'Enjoy! 😎'
exec zsh

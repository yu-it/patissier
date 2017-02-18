#!bin/sh
pgpath=/home/pi/bin/programs/stage
cd $pgpath
sudo bash ${0%/*}/inputrunner.sh $pgpath/recipe.txt >> $pgpath/std 2>&1

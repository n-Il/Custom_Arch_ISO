#!/usr/bin/bash
echo "Do you want to update?(y/n)"
read -n 1 -p "(y/n): " yesorno
echo ""
if [ $yesorno == "y" ]; then
    sudo pacman -Syu 
else
    exit
fi
read -n 1 -p "Press Any Key to Close" 

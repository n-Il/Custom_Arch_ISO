#!/usr/bin/bash
echo "Do you want to reboot?(y/n)"
read -n 1 -p "(y/n): " yesorno
echo ""
if [ $yesorno == "y" ]; then
    shutdown -r now
else
    exit
fi

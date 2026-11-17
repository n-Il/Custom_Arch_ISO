#!/usr/bin/bash
echo "Do you want to shut down?(y/n)"
read -n 1 -p "(y/n): " yesorno
echo ""
if [ $yesorno == "y" ]; then
    shutdown now
else
    exit
fi

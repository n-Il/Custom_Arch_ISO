#!/bin/bash

#TODO: cleanup note
##!/bin/bash -x (for logging)

if [[ ! -f "install-files/install-files-1.0.0-1-any.pkg.tar.zst" ]]; then
    echo "Run Buildscript in install-files first"
    exit
fi

###Copy releng
cp -r /usr/share/archiso/configs/releng ./build_folder

echo "whois" >> ./build_folder/packages.x86_64
echo "jq" >> ./build_folder/packages.x86_64
echo "networkmanager" >> ./build_folder/packages.x86_64

#TODO: REMOVE THIS FOR FINAL: edit the profiledef.sh in build_folder to replace the top line with the bottom, for build speed
##airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86,arm64' '-b' '1M' '-Xdict-size' '1M')
##airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '3')
#sed -i "s/^airootfs_image_tool_options=.*/airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '3')/" ./build_folder/profiledef.sh

###Custom package 
mkdir ./build_folder/airootfs/etc/customrepo
cp install-files/install-files-1.0.0-1-any.pkg.tar.zst ./build_folder/airootfs/etc/customrepo/install-files-1.0.0-1-any.pkg.tar.zst
repo-add ./build_folder/airootfs/etc/customrepo/customrepo.db.tar.zst ./build_folder/airootfs/etc/customrepo/install-files-1.0.0-1-any.pkg.tar.zst
cp -r /etc/pacman.conf ./build_folder/airootfs/etc/pacman.conf
echo -e "\n[customrepo]\nSigLevel = Optional TrustAll\nServer = file:///etc/customrepo" >> ./build_folder/airootfs/etc/pacman.conf
sed -i 's/^ParallelDownloads.*/ParallelDownloads = 1/' ./build_folder/airootfs/etc/pacman.conf

###Archinstall Configuration
cp archinstall-config.json ./build_folder/airootfs/root/config.json
cp archinstall-config-user.json ./build_folder/airootfs/root/user.json
cp pre-archinstall.sh ./build_folder/airootfs/root/pre-archinstall.sh

#Setup .zlogin to run archinstall with config
echo -e  "if [[ \"\$(tty)\" == \"/dev/tty1\" ]]; then\n    bash pre-archinstall.sh\nfi" >> ./build_folder/airootfs/root/.zlogin
echo -e "#!/bin/bash\narchinstall --config config.json --creds user.json | tee output.log" >> ./build_folder/airootfs/root/install_command.sh

#Build iso
mkarchiso -v -r -w ./tmp_archiso -o output ./build_folder
mv output/* output.iso
#TODO: temporary copy to libvirt location
#sudo mv output.iso /var/lib/libvirt/images/

rmdir output

#TODO: temporary Cleanup
#rm -r ./build_folder

#TODO: cleanup note
#sudo dd if=/var/lib/libvirt/images/output.iso of=/dev/sda bs=4M status=progress oflag=sync

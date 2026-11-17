#!/bin/bash

confirm_input() {
  local _prompt_msg="$1"
  local -n _target_var="$2"
  local _mode="$3"
  local _val1 _val2
  local _read_opts=(-rp)

  if [[ "$_mode" == "hidden" ]]; then
    _read_opts=(-rsp)
  fi
  while true; do
    read "${_read_opts[@]}" "Enter $_prompt_msg:" _val1
    [[ "$_mode" == "hidden" ]] && echo

    read "${_read_opts[@]}" "Confirm $_prompt_msg:" _val2
    [[ "$_mode" == "hidden" ]] && echo

    if [[ -z "$_val1" ]]; then
      echo "Value cannot be empty. Please try again."
      echo
    elif [[ "$_val1" == "$_val2" ]]; then
      echo "Confirmed successfully."
      _target_var="$_val1"
      break
    else
      echo "Entries do not match. Please try again."
      echo
    fi
  done
}
#confirm_input "test1" test_var "visible"
#confirm_input "test2" test_var "hidden"
#echo $test_var

chmod +x install_command.sh
systemctl start NetworkManager

#this is to wait for drives to get ready as archinstall will commonly crash due to it
echo "Preinstall Loading..."
sleep 30

confirm_input "desired hostname" input_hostname "visible"
jq --arg host "$input_hostname" '.hostname = $host' "config.json" > "config.json.tmp" && mv "config.json.tmp" "config.json"

confirm_input "root password" root_pass "hidden"
hashed_pass=$(printf '%s' "$root_pass" | tr -d '\r\n' | mkpasswd -m yescrypt --stdin)
jq --arg pass "$hashed_pass" '.root_enc_password = $pass' "user.json" > "user.json.tmp" && mv "user.json.tmp" "user.json"
unset root_pass hashed_pass

confirm_input "desired username" input_username "visible"
jq --arg user "$input_username" '.users[0].username = $user' "user.json" > "user.json.tmp" && mv "user.json.tmp" "user.json"
jq --arg user "$input_username" \
   '.custom_commands |= map(sub("usermod -aG libvirt user"; "usermod -aG libvirt " + $user))' \
   "config.json" > "config.json.tmp" && mv "config.json.tmp" "config.json"
jq --arg user "$input_username" \
   '.custom_commands |= map(gsub("USERNAME"; $user))' \
   "config.json" > "config.json.tmp" && mv "config.json.tmp" "config.json"

confirm_input "user password" user_pass "hidden"
hashed_pass=$(printf '%s' "$user_pass" | tr -d '\r\n' | mkpasswd -m yescrypt --stdin)
jq --arg pass "$hashed_pass" '.users[0].enc_password = $pass' "user.json" > "user.json.tmp" && mv "user.json.tmp" "user.json"
unset user_pass hashed_pass

if curl -Is --connect-timeout 5 https://google.com >/dev/null 2>&1; then
    echo "Computer Online"
else
    read -p "Launching nmtui to configure network(Press any key to continue)"
    nmtui
fi


read -r -p "Skip GUI and attempt to autoformat entire disk(y/n): " yesorno
if [[ "$yesorno" != "y" ]]; then
    jq 'del(.disk_config)' "config.json" > "config.json.tmp" && mv "config.json.tmp" "config.json"
    #read -n 1 -p "If you get a wipeFS error, run ./install_command.sh to retry, it's just buggy(press any key)"
    archinstall --config config.json --creds user.json
else
    echo
    echo
    echo "Scanning for available physical drives..."
    echo
    mapfile -t disk_list < <(lsblk -d -n -o NAME,TYPE | awk '$2=="disk"{print $1}')
    if [ ${#disk_list[@]} -eq 0 ]; then
        echo "Error: No physical disks found on this system."
        exit 1
    elif [ ${#disk_list[@]} -eq 1 ]; then
        selected_disk="/dev/${disk_list[0]}"
        echo "✔ Only one drive found ($selected_disk). Automatically selecting it."
    else
        echo "Available Drives:"
        echo "--------------------------------------------------"
        for i in "${!disk_list[@]}"; do
            dev_name="/dev/${disk_list[$i]}"
            echo "[$((i+1))] Drive: $dev_name"
            lsblk -o NAME,SIZE,MODEL "$dev_name"
            echo "--------------------------------------------------"
        done
        while true; do
            read -p "Select a drive number (1-${#disk_list[@]}): " choice
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#disk_list[@]} )); then
                selected_index=$((choice - 1))
                selected_disk="/dev/${disk_list[$selected_index]}"
                break
            else
                echo "Invalid choice. Please enter a valid number from the list."
            fi
        done
    fi
    echo
    echo "✔ Target device set to: $selected_disk"
    total_sectors=$(cat /sys/class/block/$(basename "$selected_disk")/size)
    total_mib=$((total_sectors / 2048))
    boot_start_mib=1
    boot_size_mib=1024
    root_start_mib=$((boot_start_mib + boot_size_mib))
    root_size_mib=$((total_mib - root_start_mib - 2))
    echo "Configuring partitions for $selected_disk:"
    echo " - Boot Start: $boot_start_mib MiB | Size: $boot_size_mib MiB"
    echo " - Root Start: $root_start_mib MiB | Size: $root_size_mib MiB"
    jq --arg dev "$selected_disk" \
       --argjson b_start "$boot_start_mib" \
       --argjson b_size "$boot_size_mib" \
       --argjson r_start "$root_start_mib" \
       --argjson r_size "$root_size_mib" \
       '.disk_config.device_modifications[0].device = $dev |
        .disk_config.device_modifications[0].partitions[0].start.value = $b_start |
        .disk_config.device_modifications[0].partitions[0].size.value = $b_size |
        .disk_config.device_modifications[0].partitions[1].start.value = $r_start |
        .disk_config.device_modifications[0].partitions[1].size.value = $r_size' \
       "config.json" > "config.json.tmp" && mv "config.json.tmp" "config.json"
       
    echo "config.json updated successfully with aligned disk layout"
    #read -n 1 -p "If you get a wipeFS error, run ./install_command.sh to retry, it's just buggy(press any key)"
    archinstall --config config.json --creds user.json --silent
    echo "Do you want to reboot?(y/n)"
    read -n 1 -p "(y/n): " yesorno
    echo ""
    if [ $yesorno == "y" ]; then
        shutdown -r now
    else
        exit
    fi
fi

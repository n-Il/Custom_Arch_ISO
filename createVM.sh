#!/bin/bash

VM_NAME="arch-test-vm"
URI="qemu:///system"

if virsh -c "$URI" dominfo "$VM_NAME" &>/dev/null; then
    echo "[+] Destroying and undefining existing VM on system instance..."
    virsh -c "$URI" destroy "$VM_NAME" &>/dev/null
    virsh -c "$URI" undefine "$VM_NAME" --remove-all-storage
fi

echo "[+] Creating new test VM on system instance..."
virt-install \
  --connect "$URI" \
  --name "$VM_NAME" \
  --memory 13000 \
  --vcpus 15 \
  --disk size=80,format=qcow2 \
  --cdrom /var/lib/libvirt/images/output.iso \
  --os-variant archlinux \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole

echo "[+] VM '$VM_NAME' has been successfully created and started on qemu:///system."
virt-manager --connect qemu:///system --show-domain-console "$VM_NAME" &>/dev/null &

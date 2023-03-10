#!/usr/bin/env -S bash -e

# Cleaning the TTY.
clear

arch-chroot /mnt /bin/bash -e <<EOF
    # Setting up timezone.
    ln -sf /usr/share/zoneinfo/$(curl -s http://ip-api.com/line?fields=timezone) /etc/localtime 
    # Setting up clock.
    hwclock --systohc
    # Generating locales.my keys aren't even on
    echo "Generating locales."
    locale-gen 
    # Generating a new initramfs.
    echo "Creating a new initramfs."
    chmod 600 /boot/initramfs-linux* 
    mkinitcpio -P 
    # Snapper configuration
   
    # Installing GRUB.
    echo "Installing GRUB on /boot."
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile gzio part_gpt tpm btrfs" --disable-shim-lock 
    # Creating grub config file.
    echo "Creating GRUB config file."
    grub-mkconfig -o /boot/grub/grub.cfg 
    # Adding user with sudo privilege
EOF


# Enabling audit service.
systemctl enable auditd --root=/mnt 

# Enabling auto-trimming service.
systemctl enable fstrim.timer --root=/mnt 

# Enabling NetworkManager.
systemctl enable NetworkManager --root=/mnt 

# Enabling GDM.
systemctl enable gdm --root=/mnt 

# Enabling AppArmor.
echo "Enabling AppArmor."
systemctl enable apparmor --root=/mnt 

# Enabling Firewalld.
echo "Enabling Firewalld."
systemctl enable firewalld --root=/mnt 

# Enabling Bluetooth Service (This is only to fix the visual glitch with gnome where it gets stuck in the menu at the top right).
# IF YOU WANT TO USE BLUETOOTH, YOU MUST REMOVE IT FROM THE LIST OF BLACKLISTED KERNEL MODULES IN /mnt/etc/modprobe.d/30_security-misc.conf
systemctl enable bluetooth --root=/mnt 

# Enabling Reflector timer.
echo "Enabling Reflector."
systemctl enable reflector.timer --root=/mnt 

# Enabling systemd-oomd.
echo "Enabling systemd-oomd."
systemctl enable systemd-oomd --root=/mnt 

# Disabling systemd-timesyncd
systemctl disable systemd-timesyncd --root=/mnt 

# Enabling chronyd
systemctl enable chronyd --root=/mnt 

# Enabling Snapper automatic snapshots.
echo "Enabling Snapper and automatic snapshots entries."
systemctl enable snapper-timeline.timer --root=/mnt 
systemctl enable snapper-cleanup.timer --root=/mnt 
systemctl enable grub-btrfs.path --root=/mnt 



# Finishing up
echo "Done, you may now wish to reboot (further changes can be done by chrooting into /mnt)."
exit

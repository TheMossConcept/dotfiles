#!/bin/bash
# =============================================================================
# Arch Linux Initial Installation Script
# =============================================================================
# Hardware:
#   - Motherboard: ASUS TUF GAMING B760M-PLUS WIFI II (Intel AX211 WiFi 6E + BT)
#   - GPU: AMD Radeon Pro WX 3200 (amdgpu driver)
#   - Boot: UEFI + GPT
#   - Bootloader: GRUB
#
# Partition layout:
#   1. EFI System Partition — 1 GiB (FAT32)
#   2. Swap — 64 GiB
#   3. Root — remainder of disk (ext4)
#
# This script is meant to be followed interactively in the live USB environment.
# It is NOT meant to be run unattended — read each section before executing.
# =============================================================================

set -e

# =====================
# PLACEHOLDER — SET THIS
# =====================
# Run "fdisk -l" to identify your target disk, then set it here.
# Example: /dev/nvme0n1 for NVMe, /dev/sda for SATA
DISK="<YOUR_DISK>"  # e.g. /dev/nvme0n1

# For NVMe drives, partitions are suffixed with "p1", "p2", etc.
# For SATA drives, partitions are suffixed with "1", "2", etc.
# Adjust these if your disk naming differs.
#   NVMe example: PART_PREFIX="${DISK}p"
#   SATA example: PART_PREFIX="${DISK}"
PART_PREFIX="${DISK}p"  # Change to "${DISK}" for SATA drives

EFI_PART="${PART_PREFIX}1"
SWAP_PART="${PART_PREFIX}2"
ROOT_PART="${PART_PREFIX}3"

# =============================================================================
# Step 0: Verify UEFI boot mode
# =============================================================================
echo ">>> Verifying UEFI boot mode..."
if [ -d /sys/firmware/efi/efivars ]; then
    echo "UEFI mode confirmed."
else
    echo "ERROR: System is NOT booted in UEFI mode. Reboot in UEFI mode first."
    exit 1
fi

# =============================================================================
# Step 1: Connect to the internet
# =============================================================================
# If you're on ethernet, it should work automatically.
# If you need WiFi, run: iwctl
#   > station wlan0 scan
#   > station wlan0 get-networks
#   > station wlan0 connect <SSID>
#   > exit

echo ">>> Testing internet connectivity..."
ping -c 3 archlinux.org || {
    echo "ERROR: No internet. Connect via ethernet or use iwctl for WiFi."
    exit 1
}

# =============================================================================
# Step 2: Update system clock
# =============================================================================
echo ">>> Syncing system clock..."
timedatectl set-ntp true
timedatectl

# =============================================================================
# Step 3: Partition the disk
# =============================================================================
echo ""
echo ">>> About to partition ${DISK} with the following layout:"
echo "    1. EFI  — 1 GiB   (FAT32)"
echo "    2. Swap — 64 GiB"
echo "    3. Root — remainder (ext4)"
echo ""
echo "WARNING: This will DESTROY all data on ${DISK}."
read -rp "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Wipe existing partition table and create new GPT layout
sgdisk --zap-all "${DISK}"

# Partition 1: EFI System Partition (1 GiB)
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" "${DISK}"

# Partition 2: Swap (64 GiB)
sgdisk -n 2:0:+64G -t 2:8200 -c 2:"Swap" "${DISK}"

# Partition 3: Root (rest of disk)
sgdisk -n 3:0:0 -t 3:8300 -c 3:"Root" "${DISK}"

# Inform kernel of partition table changes
partprobe "${DISK}"

echo ">>> Partition table:"
fdisk -l "${DISK}"

# =============================================================================
# Step 4: Format partitions
# =============================================================================
echo ">>> Formatting partitions..."

mkfs.fat -F 32 "${EFI_PART}"
mkswap "${SWAP_PART}"
mkfs.ext4 "${ROOT_PART}"

# =============================================================================
# Step 5: Mount filesystems
# =============================================================================
echo ">>> Mounting filesystems..."

mount "${ROOT_PART}" /mnt
mount --mkdir "${EFI_PART}" /mnt/boot
swapon "${SWAP_PART}"

# =============================================================================
# Step 6: Install base system
# =============================================================================
# Packages:
#   base, linux, linux-firmware  — core system
#   intel-ucode                  — Intel CPU microcode (LGA1700 = Intel)
#   linux-firmware-iwlwifi       — firmware for Intel AX211 WiFi 6E
#   mesa, xf86-video-amdgpu,
#   vulkan-radeon, libva-mesa-driver,
#   mesa-vdpau                   — AMD GPU drivers (amdgpu) + Vulkan + VA-API
#   bluez, bluez-utils           — Bluetooth stack (Intel AX211 has integrated BT)
#   pipewire, pipewire-pulse,
#   wireplumber                  — Audio (PipeWire with PulseAudio compat)
#   grub, efibootmgr             — GRUB bootloader for UEFI
#   nano                         — text editor for in-chroot editing
#   man-db, man-pages            — manual pages
echo ">>> Installing base system and drivers..."

pacstrap -K /mnt \
    base linux linux-firmware \
    intel-ucode \
    linux-firmware-iwlwifi \
    mesa xf86-video-amdgpu vulkan-radeon libva-mesa-driver mesa-vdpau \
    bluez bluez-utils \
    pipewire pipewire-pulse wireplumber \
    grub efibootmgr \
    nano \
    man-db man-pages

# =============================================================================
# Step 7: Generate fstab
# =============================================================================
echo ">>> Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo ">>> Review fstab:"
cat /mnt/etc/fstab

# =============================================================================
# Step 8: Chroot configuration
# =============================================================================
# Everything below runs inside the chroot.
echo ">>> Entering chroot to configure the system..."

arch-chroot /mnt /bin/bash <<'CHROOT_EOF'
set -e

# -- Timezone --
echo ">>> Setting timezone to Europe/London..."
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc

# -- Locale --
echo ">>> Configuring locale (en_US.UTF-8)..."
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# -- Hostname --
# PLACEHOLDER — set your hostname here
echo "<YOUR_HOSTNAME>" > /etc/hostname

# -- Initramfs --
# The default mkinitcpio.conf is fine for our setup (no LUKS, no LVM, no RAID).
# Regenerate just in case:
mkinitcpio -P

# -- Root password --
echo ">>> Set the root password:"
passwd

# -- GRUB bootloader --
echo ">>> Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Enable AMD GPU early KMS for better boot experience
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 amdgpu"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# -- Enable services --
echo ">>> Enabling services..."

# Bluetooth
systemctl enable bluetooth.service

# PipeWire is started per-user via systemd user units (auto-enabled, no system enable needed)

CHROOT_EOF

# =============================================================================
# Step 9: Unmount and reboot
# =============================================================================
echo ""
echo "============================================="
echo " Installation complete!"
echo "============================================="
echo ""
echo "Next steps:"
echo "  1. Review the output above for any errors."
echo "  2. Run: umount -R /mnt"
echo "  3. Run: reboot"
echo "  4. Remove the USB drive when prompted."
echo "  5. After booting, log in as root and run arch-install.sh for post-install setup."
echo ""

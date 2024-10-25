#!/bin/bash

# Mettre à jour le système et installer les paquets de base
pacman -Syu --noconfirm
pacman -S --noconfirm xorg xorg-server xorg-xinit plasma kde-applications sddm arc-gtk-theme papirus-icon-theme conky neofetch

# Activer NTP pour la synchronisation de l'horloge
timedatectl set-ntp true

# Partitioner et formater le disque (supposons /dev/sda, ajuster selon vos besoins)
parted /dev/sda mklabel gpt
parted /dev/sda mkpart primary ext4 1MiB 100%
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# Installer le système de base
pacstrap /mnt base linux linux-firmware

# Générer fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot dans le nouveau système
arch-chroot /mnt

# Configurer le fuseau horaire
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

# Configurer la locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configurer le réseau
echo "myhostname" > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\tmyhostname.localdomain\tmyhostname" > /etc/hosts

# Installer et configurer GRUB
pacman -S --noconfirm grub os-prober
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Activer les services essentiels
systemctl enable sddm
systemctl enable NetworkManager

# Configurer KDE Plasma avec thème sombre et diaporama
cat << 'EOF' > /etc/sddm.conf
[Theme]
Current=breeze
EOF

mkdir -p ~/.config/plasma-workspace/env
echo "export KDE_FULL_SESSION=true" > ~/.config/plasma-workspace/env/startup
echo "export XDG_CURRENT_DESKTOP=KDE" >> ~/.config/plasma-workspace/env/startup

mkdir -p ~/.config/plasma-org.kde.plasma.desktop-appletsrc
cat << 'EOF' > ~/.config/plasma-org.kde.plasma.desktop-appletsrc
[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/backgrounds/slideshow
SlidePaths=/usr/share/backgrounds/slideshow
SlideTimer=300
EOF

mkdir -p /usr/share/backgrounds/slideshow
wget -O /usr/share/backgrounds/slideshow/nature1.jpg URL_IMAGE_1
wget -O /usr/share/backgrounds/slideshow/nature2.jpg URL_IMAGE_2
wget -O /usr/share/backgrounds/slideshow/nature3.jpg URL_IMAGE_3
# Ajoutez plus d'URL d'images de haute qualité ici

# Installer Microsoft Edge
yay -S microsoft-edge-stable

# Configurer les widgets et le thème sombre
lookandfeeltool -a org.kde.breezedark.desktop

# Message de fin
echo "Installation terminée ! Redémarrez pour profiter de votre nouvelle configuration KDE Plasma avec un diaporama d'images spectaculaires et Microsoft Edge."

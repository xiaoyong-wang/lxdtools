#!/bin/bash

# Update package list and upgrade all packages
apt-get update
apt-get upgrade -y

# Install ufw if not already installed
apt install ufw -y

# Allow SSH connections
sudo ufw allow ssh

# Set default policies to deny incoming and allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow traffic on the lxdbr0 bridge interface
sudo ufw allow in on lxdbr0
sudo ufw allow out on lxdbr0

# Enable ufw to apply the rules
sudo ufw enable

# Reload ufw to apply new rules
sudo ufw reload

# Print the current status and rules
sudo ufw status verbose

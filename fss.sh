#!/bin/bash

# Function to prompt user for input
prompt() {
    read -p "$1: " input
    echo "$input"
}

# Function to create new user
create_user() {
    username=$(prompt "请输入要创建的用户名")
    sudo adduser "$username"
}

# Function to add user to sudo group
add_to_sudo_group() {
    username=$1
    sudo usermod -aG sudo "$username"
}

# Function to configure sudo no password
configure_sudo_nopass() {
    username=$1
    sudo bash -c "echo '$username ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$username"
}

# Function to setup SSH public key authentication
setup_ssh_key_auth() {
    username=$1
    home_dir=$(eval echo "~$username")
    ssh_dir="$home_dir/.ssh"
    auth_keys_file="$ssh_dir/authorized_keys"

    sudo mkdir -p "$ssh_dir"
    sudo chmod 700 "$ssh_dir"
    sudo touch "$auth_keys_file"
    sudo chmod 600 "$auth_keys_file"

    public_key=$(prompt "请输入公钥")
    echo "$public_key" | sudo tee -a "$auth_keys_file"

    sudo chown -R "$username:$username" "$ssh_dir"
}

# Main script execution
echo "用户创建和配置脚本"

# Step 1: Create a new user
create_user

# Step 2: Add the new user to sudo group
add_to_sudo_group "$username"

# Step 3: Configure sudo to not require a password
configure_sudo_nopass "$username"

# Step 4: Setup SSH public key authentication
setup_ssh_key_auth "$username"

echo "用户 $username 创建成功并已配置 sudo 权限和公钥登录"

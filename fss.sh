#!/bin/bash

# Function to prompt user for input
prompt() {
    read -p "$1: " input
    echo "$input"
}

# Function to determine the Linux distribution
get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    else
        echo "unknown"
    fi
}

# Function to perform system update
perform_system_update() {
    distro=$1
    if [ "$distro" == "ubuntu" ] || [ "$distro" == "debian" ]; then
        sudo apt update && sudo apt upgrade -y
    elif [ "$distro" == "centos" ] || [ "$distro" == "fedora" ]; then
        sudo yum update -y
    else
        echo "Unsupported distribution for automatic updates"
    fi
}

# Function to create new user using useradd
create_user() {
    username=$(prompt "请输入要创建的用户名")
    sudo useradd -m -s /bin/bash "$username"
    sudo passwd "$username"
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
echo "-----脚本开始-----"

# Determine the distribution
distro=$(get_distro)
echo "检测到的系统发行版: $distro"

# Ask user if they want to perform a system update
update_choice=$(prompt "是否执行系统更新？(Y/n)")
if [ "$update_choice" == "Y" ] || [ "$update_choice" == "y" ] || [ -z "$update_choice" ]; then
    perform_system_update "$distro"
fi

echo "-----用户创建和配置脚本-----"

# Step 1: Create a new user
echo "-----创建新用户阶段-----"
create_user

# Step 2: Add the new user to sudo group
echo "-----添加用户到sudo组阶段-----"
add_to_sudo_group "$username"

# Step 3: Configure sudo to not require a password
echo "-----配置sudo免密码阶段-----"
configure_sudo_nopass "$username"

# Step 4: Setup SSH public key authentication
echo "-----设置SSH公钥认证阶段-----"
setup_ssh_key_auth "$username"

echo "-----用户 $username 创建成功并已配置 sudo 权限和公钥登录-----"

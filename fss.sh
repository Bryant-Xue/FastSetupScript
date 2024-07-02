#!/bin/bash

# Function to prompt user for input
prompt() {
    read -p "$1: " input
    echo "$input"
}

# Function to print messages in color
print_msg() {
    color=$1
    msg=$2
    case $color in
        "red") echo -e "\e[31m$msg\e[0m" ;;
        "green") echo -e "\e[32m$msg\e[0m" ;;
        "yellow") echo -e "\e[33m$msg\e[0m" ;;
        "blue") echo -e "\e[34m$msg\e[0m" ;;
        *) echo "$msg" ;;
    esac
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
        print_msg "yellow" "正在更新系统..."
        sudo apt update && sudo apt upgrade -y
    elif [ "$distro" == "centos" ] || [ "$distro" == "fedora" ]; then
        print_msg "yellow" "正在更新系统..."
        sudo yum update -y
    else
        print_msg "red" "不支持自动更新的发行版"
    fi
}

# Function to create new user using useradd
create_user() {
    username=$(prompt "请输入要创建的用户名")
    sudo useradd -m -s /bin/bash "$username"
    sudo passwd "$username"
    print_msg "green" "用户 $username 已创建"
}

# Function to add user to sudo group
add_to_sudo_group() {
    username=$1
    sudo usermod -aG sudo "$username"
    print_msg "green" "用户 $username 已添加到 sudo 组"
}

# Function to configure sudo no password
configure_sudo_nopass() {
    username=$1
    sudo bash -c "echo '$username ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$username"
    print_msg "green" "用户 $username 的 sudo 权限已配置为免密码"
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
    print_msg "green" "用户 $username 的 SSH 公钥认证已配置"
}

# Main script execution
print_msg "blue" "-----脚本开始-----"

# Determine the distribution
distro=$(get_distro)
print_msg "blue" "检测到的系统发行版: $distro"

# Ask user if they want to perform a system update
update_choice=$(prompt "是否执行系统更新？(Y/n)")
if [ "$update_choice" == "Y" ] || [ "$update_choice" == "y" ] || [ -z "$update_choice" ]; then
    perform_system_update "$distro"
fi

print_msg "blue" "-----用户创建和配置脚本-----"

# Step 1: Create a new user
print_msg "blue" "-----创建新用户阶段-----"
create_user

# Step 2: Add the new user to sudo group
print_msg "blue" "-----添加用户到sudo组阶段-----"
add_to_sudo_group "$username"

# Step 3: Configure sudo to not require a password
print_msg "blue" "-----配置sudo免密码阶段-----"
configure_sudo_nopass "$username"

# Step 4: Setup SSH public key authentication
print_msg "blue" "-----设置SSH公钥认证阶段-----"
setup_ssh_key_auth "$username"

print_msg "blue" "-----用户 $username 创建成功并已配置 sudo 权限和公钥登录-----"

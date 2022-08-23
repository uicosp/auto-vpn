echo "🚧 检测安装环境"
DUMMY=$(oathtool)
if [[ $DUMMY == '' ]]
then
    # notice: 这里是编辑器展示问题
    echo '⚠️  请先安装 oath-toolkit'
    exit
fi
echo "🔧 开始安装 auto-vpn 到 ～/autoVpn"
# read username & password & secret
read -p "请输入 VPN 服务器地址: " host
read -p "请输入用户名: " username
read -p "请输入密码: " passwd
read -p "请输入动态口令: " secret
# get home dir
home_dir=`eval echo "~$USER"`
# create install dir
install_dir="$home_dir/autoVpn"
[ -d install_dir ] || mkdir $install_dir
# download vpn_auto_login.exp
curl --url "https://raw.githubusercontent.com/uicosp/auto-vpn/main/vpn_auto_login.exp" \
    --output "$install_dir/vpn_auto_login.exp"

chmox +x $install_dir/vpn_auto_login.exp

# detect default shell to determine the profile name, current supported: zsh/bash
shell_profile=''
if [[ $SHELL =~ "zsh" ]]
then
    shell_profile='.zprofile'
elif [[ $SHELL =~ "bash" ]]
then
    shell_profile='.bash_profile'
fi
profile_path="$home_dir/$shell_profile"
# export alias to shell profile and source it
echo "alias vpn='~/autoVpn/vpn_auto_login.exp $host $username \"$passwd\" \$(oathtool --totp -b $secret)'" >> "$profile_path"
echo "alias disconnect='/opt/cisco/anyconnect/bin/vpn disconnect'" >> "$profile_path"

source $profile_path
echo "🍻 安装成功"
echo "请打开新的窗口输入 vpn 自动连接，断开连接使用 disconnect 命令"
echo "如果要在当前窗口使用请先手动执行 source 命令:"
echo "  source $profile_path"
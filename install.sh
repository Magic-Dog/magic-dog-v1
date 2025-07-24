#!/bin/bash

# MagicDog Linux 一键安装脚本
# 适用于 Ubuntu/Debian/CentOS/RHEL 等主流Linux发行版

set -e

# 配置变量
GITHUB_REPO="https://github.com/Magic-Dog/magic-dog-v1.git"
GITHUB_RAW_URL="https://raw.githubusercontent.com/Magic-Dog/magic-dog-v1/main"
INSTALL_DIR="/opt/magicdog"
SERVICE_NAME="magicdog"
SERVICE_PORT="8080"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "请使用root用户运行此脚本，或使用 sudo ./install.sh"
    fi
}

# 检测系统类型
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        DISTRO=$NAME
        VERSION=$VERSION_ID
    else
        error "无法检测操作系统类型"
    fi
    log "检测到系统: $DISTRO $VERSION"
}

# 预安装基础工具
pre_install_basics() {
    log "预安装基础工具..."
    
    case $OS in
        ubuntu|debian)
            export DEBIAN_FRONTEND=noninteractive
            
            # 首先尝试安装时间同步工具，忽略时间验证错误
            apt update -o Acquire::Check-Valid-Until=false -o Acquire::Max-FutureTime=86400 2>/dev/null || true
            apt install -y ntpdate systemd-timesyncd 2>/dev/null || true
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y ntpdate systemd 2>/dev/null || true
            else
                yum install -y ntpdate systemd 2>/dev/null || true
            fi
            ;;
        *)
            log "跳过预安装步骤"
            ;;
    esac
}

# 检查系统兼容性
check_system_compatibility() {
    log "检查系统兼容性..."
    
    # 检查架构
    arch=$(uname -m)
    if [ "$arch" != "x86_64" ]; then
        error "❌ 不支持的系统架构: $arch，目前仅支持 x86_64"
    fi
    
    # 检查GLIBC版本
    log "检查GLIBC版本..."
    if command -v ldd >/dev/null 2>&1; then
        glibc_version=$(ldd --version | head -1 | awk '{print $NF}')
        log "当前GLIBC版本: $glibc_version"
        
        # 检查是否满足最低要求 (2.38)
        required_version="2.38"
        if ! awk -v ver="$glibc_version" -v req="$required_version" 'BEGIN{if(ver<req) exit 1}' 2>/dev/null; then
            warn "⚠️  GLIBC版本可能不兼容"
            warn "当前版本: $glibc_version"
            warn "所需版本: >= $required_version"
            echo ""
            log "尝试升级系统库..."
            upgrade_system_libraries
        else
            log "✅ GLIBC版本兼容"
        fi
    else
        warn "⚠️  无法检测GLIBC版本"
    fi
}

# 升级系统库
upgrade_system_libraries() {
    log "升级系统库和运行时环境..."
    
    case $OS in
        ubuntu|debian)
            # 对于Ubuntu/Debian，尝试升级libc6和相关库
            export DEBIAN_FRONTEND=noninteractive
            
            log "更新包列表并升级系统库..."
            apt update -o Acquire::Check-Valid-Until=false >/dev/null 2>&1 || true
            
            # 升级核心库
            apt install -y libc6 libc6-dev build-essential >/dev/null 2>&1 || {
                warn "系统库升级失败，尝试替代方案..."
            }
            
            # 如果是较老的Ubuntu版本，尝试启用更新的源
            ubuntu_version=$(lsb_release -rs 2>/dev/null || echo "unknown")
            if [ "$ubuntu_version" != "unknown" ]; then
                major_version=$(echo "$ubuntu_version" | cut -d. -f1)
                if [ "$major_version" -lt 22 ]; then
                    warn "检测到较老的Ubuntu版本($ubuntu_version)，可能需要手动升级系统"
                    warn "建议运行: sudo apt update && sudo apt upgrade"
                fi
            fi
            ;;
        centos|rhel|fedora)
            log "升级glibc和相关库..."
            if command -v dnf &> /dev/null; then
                dnf update -y glibc glibc-devel >/dev/null 2>&1 || true
            else
                yum update -y glibc glibc-devel >/dev/null 2>&1 || true
            fi
            ;;
        *)
            warn "未知系统类型，请手动升级系统库"
            ;;
    esac
}

# 测试二进制文件兼容性
test_binary_compatibility() {
    log "测试MagicDog二进制文件兼容性..."
    
    local binary_path="${INSTALL_DIR}/magicdog_linux_deploy/magicDog"
    
    if [ ! -f "$binary_path" ]; then
        error "二进制文件不存在: $binary_path"
    fi
    
    # 设置执行权限
    chmod +x "$binary_path"
    
    # 测试运行（快速退出测试）
    if timeout 5 "$binary_path" --help >/dev/null 2>&1 || \
       timeout 5 "$binary_path" --version >/dev/null 2>&1 || \
       timeout 5 "$binary_path" -h >/dev/null 2>&1; then
        log "✅ 二进制文件兼容性测试通过"
        return 0
    fi
    
    # 如果测试失败，检查具体错误
    log "检查二进制文件依赖..."
    if command -v ldd >/dev/null 2>&1; then
        missing_libs=$(ldd "$binary_path" 2>&1 | grep "not found" || true)
        if [ -n "$missing_libs" ]; then
            warn "❌ 发现缺失的库依赖:"
            echo "$missing_libs"
            echo ""
            
            # 检查是否是GLIBC版本问题
            if echo "$missing_libs" | grep -q "GLIBC"; then
                error "❌ GLIBC版本不兼容。请升级系统或联系管理员获取兼容版本的二进制文件。

建议解决方案:
1. 升级系统到更新版本
2. 运行: sudo apt update && sudo apt upgrade (Ubuntu/Debian)
3. 运行: sudo yum update (CentOS/RHEL)
4. 或联系开发者获取针对您系统的兼容版本"
            else
                warn "尝试安装缺失的库依赖..."
                install_missing_libraries "$missing_libs"
            fi
        fi
    fi
    
    # 再次测试
    if timeout 5 "$binary_path" --help >/dev/null 2>&1 || \
       timeout 5 "$binary_path" --version >/dev/null 2>&1 || \
       timeout 5 "$binary_path" -h >/dev/null 2>&1; then
        log "✅ 二进制文件修复成功"
        return 0
    else
        error "❌ 二进制文件仍然不兼容，请检查系统环境"
    fi
}

# 安装缺失的库
install_missing_libraries() {
    local missing_output="$1"
    log "尝试安装缺失的库依赖..."
    
    case $OS in
        ubuntu|debian)
            # 常见的库依赖
            apt install -y libc6 libssl3 libssl-dev libffi8 libffi-dev \
                          zlib1g zlib1g-dev libgcc-s1 libstdc++6 >/dev/null 2>&1 || true
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y glibc openssl-libs libffi zlib gcc-c++ >/dev/null 2>&1 || true
            else
                yum install -y glibc openssl-libs libffi zlib gcc-c++ >/dev/null 2>&1 || true
            fi
            ;;
    esac
}

# 检查并修复系统时间
check_and_fix_time() {
    log "检查系统时间..."
    
    current_date=$(date)
    log "当前系统时间: $current_date"
    
    # 检查时间是否明显不对（比如年份小于2020）
    current_year=$(date +%Y)
    if [ "$current_year" -lt 2020 ]; then
        warn "检测到系统时间异常，尝试修复..."
    fi
    
    # 尝试各种时间同步方法
    log "尝试同步系统时间..."
    
    # 方法1: 使用timedatectl
    if command -v timedatectl &> /dev/null; then
        log "使用timedatectl同步时间..."
        timedatectl set-ntp true 2>/dev/null || true
        sleep 3
        
        # 如果还不行，手动设置一个合理的时间
        if [ "$(date +%Y)" -lt 2020 ]; then
            timedatectl set-time "2025-07-23 12:00:00" 2>/dev/null || true
        fi
    fi
    
    # 方法2: 使用ntpdate
    if command -v ntpdate &> /dev/null; then
        log "使用ntpdate同步时间..."
        ntpdate -s time.nist.gov 2>/dev/null || \
        ntpdate -s pool.ntp.org 2>/dev/null || \
        ntpdate -s 0.pool.ntp.org 2>/dev/null || \
        ntpdate -s 1.pool.ntp.org 2>/dev/null || true
    fi
    
    # 方法3: 使用curl获取网络时间（最后的备用方案）
    if [ "$(date +%Y)" -lt 2020 ] && command -v curl &> /dev/null; then
        log "尝试从网络获取时间..."
        network_time=$(curl -s -I "http://www.google.com" 2>/dev/null | grep -i "^date:" | cut -d' ' -f2- | tr -d '\r' 2>/dev/null || echo "")
        if [ -n "$network_time" ]; then
            date -s "$network_time" 2>/dev/null || true
        fi
    fi
    
    # 最终显示时间
    final_date=$(date)
    log "修复后系统时间: $final_date"
    
    # 如果时间仍然有问题，给出警告但不停止安装
    if [ "$(date +%Y)" -lt 2020 ]; then
        warn "系统时间修复失败，但安装将继续。请在安装完成后手动修复系统时间。"
    fi
}

# 安装依赖包
install_dependencies() {
    log "安装系统依赖..."
    
    case $OS in
        ubuntu|debian)
            # 现在时间应该已经修复，可以正常更新包列表
            export DEBIAN_FRONTEND=noninteractive
            
            # 更新包列表
            apt update -o Acquire::Check-Valid-Until=false || {
                warn "apt update遇到问题，尝试使用备用方案..."
                apt update --allow-unauthenticated 2>/dev/null || true
            }
            
            # 安装剩余的必要包
            apt install -y curl wget git redis-server systemd 2>/dev/null || {
                warn "部分包安装失败，尝试单独安装..."
                apt install -y curl wget git || error "无法安装基础工具"
                apt install -y redis-server || warn "Redis安装失败，请手动安装"
                apt install -y systemd || true
            }
            
            systemctl enable redis-server 2>/dev/null || true
            systemctl start redis-server 2>/dev/null || true
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y curl wget git redis systemd 2>/dev/null || {
                    dnf install -y curl wget git || error "无法安装基础工具"
                    dnf install -y redis || warn "Redis安装失败，请手动安装"
                }
            else
                yum install -y curl wget git redis systemd 2>/dev/null || {
                    yum install -y curl wget git || error "无法安装基础工具"
                    yum install -y redis || warn "Redis安装失败，请手动安装"
                }
            fi
            systemctl enable redis 2>/dev/null || true
            systemctl start redis 2>/dev/null || true
            ;;
        *)
            warn "未知的系统类型，请手动安装以下依赖: git, redis, curl, wget"
            ;;
    esac
}

# 检查Redis是否运行
check_redis() {
    log "检查Redis状态..."
    if ! systemctl is-active --quiet redis-server &> /dev/null && ! systemctl is-active --quiet redis &> /dev/null; then
        warn "Redis未运行，尝试启动..."
        systemctl start redis-server 2>/dev/null || systemctl start redis 2>/dev/null || {
            error "Redis启动失败，请手动安装和启动Redis服务"
        }
    fi
    log "✅ Redis运行正常"
}

# 清理旧数据库文件（确保全新初始化）
cleanup_old_database() {
    log "清理可能存在的旧数据库文件..."
    
    local data_dir="${INSTALL_DIR}/magicdog_linux_deploy/data"
    
    if [ -d "$data_dir" ]; then
        # 删除数据库文件但保留GeoIP数据
        rm -f "$data_dir"/app_system* 2>/dev/null || true
        rm -rf "$data_dir"/card_cache 2>/dev/null || true
        
        # 创建空的缓存目录
        mkdir -p "$data_dir/card_cache" 2>/dev/null || true
        
        log "✅ 旧数据库清理完成，确保全新初始化"
    fi
}

# 下载项目
download_project() {
    log "下载MagicDog项目..."
    
    # 如果安装目录存在，需要安全地处理删除
    if [ -d "$INSTALL_DIR" ]; then
        warn "检测到现有安装目录: $INSTALL_DIR"
        
        # 检查当前目录是否在安装目录内
        current_dir=$(pwd)
        if [[ "$current_dir" == "$INSTALL_DIR"* ]]; then
            log "当前目录在安装目录内，切换到根目录"
            cd /
        fi
        
        # 停止可能运行的服务
        systemctl stop magicdog 2>/dev/null || true
        
        # 备份数据目录（如果存在）
        if [ -d "$INSTALL_DIR/magicdog_linux_deploy/data" ]; then
            backup_dir="/tmp/magicdog_data_backup_$(date +%Y%m%d_%H%M%S)"
            log "备份数据目录到: $backup_dir"
            cp -r "$INSTALL_DIR/magicdog_linux_deploy/data" "$backup_dir" 2>/dev/null || true
        fi
        
        # 删除旧的安装目录
        log "删除旧的安装目录..."
        rm -rf "$INSTALL_DIR" 2>/dev/null || {
            # 如果删除失败，尝试强制删除
            warn "正常删除失败，尝试强制删除..."
            rm -rf "$INSTALL_DIR" 2>/dev/null || {
                error "无法删除安装目录 $INSTALL_DIR，请手动删除后重新运行"
            }
        }
    fi
    
    # 创建安装目录的父目录
    mkdir -p "$(dirname "$INSTALL_DIR")" 2>/dev/null || true
    
    # 克隆项目并切换到main分支
    log "克隆项目到: $INSTALL_DIR"
    if ! git clone -b main "$GITHUB_REPO" "$INSTALL_DIR"; then
        error "项目下载失败，请检查网络连接和仓库地址"
    fi
    
    # 检查关键文件是否存在
    if [ ! -f "$INSTALL_DIR/magicdog_linux_deploy/magicDog" ]; then
        error "关键文件不存在: magicDog 可执行文件"
    fi
    
    # 恢复数据目录（如果有备份）
    if [ -n "${backup_dir:-}" ] && [ -d "$backup_dir" ]; then
        log "恢复数据目录..."
        cp -r "$backup_dir"/* "$INSTALL_DIR/magicdog_linux_deploy/data/" 2>/dev/null || true
        rm -rf "$backup_dir" 2>/dev/null || true
    fi
    
    # 设置执行权限
    chmod +x "$INSTALL_DIR/magicdog_linux_deploy/magicDog"
    chmod +x "$INSTALL_DIR/magicdog_linux_deploy/start.sh" 2>/dev/null || true
    
    log "✅ 项目下载完成"
}

# 配置systemd服务
setup_service() {
    log "配置systemd服务..."
    
    # 创建服务文件
    cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=MagicDog Service
After=network.target redis.service
Wants=redis.service

[Service]
Type=simple
User=root
WorkingDirectory=${INSTALL_DIR}/magicdog_linux_deploy
ExecStart=${INSTALL_DIR}/magicdog_linux_deploy/magicDog
Restart=always
RestartSec=10
Environment=PORT=${SERVICE_PORT}

# 日志配置
StandardOutput=journal
StandardError=journal
SyslogIdentifier=magicdog

# 安全配置
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=${INSTALL_DIR}
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载systemd配置
    systemctl daemon-reload
    systemctl enable ${SERVICE_NAME}
    
    log "✅ 服务配置完成"
}

# 配置防火墙
setup_firewall() {
    log "配置防火墙规则..."
    
    # UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        ufw allow ${SERVICE_PORT}/tcp
        log "UFW规则已添加: 端口 ${SERVICE_PORT}"
    fi
    
    # firewalld (CentOS/RHEL/Fedora)
    if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
        firewall-cmd --permanent --add-port=${SERVICE_PORT}/tcp
        firewall-cmd --reload
        log "firewalld规则已添加: 端口 ${SERVICE_PORT}"
    fi
    
    # iptables (备用方案)
    if command -v iptables &> /dev/null; then
        iptables -I INPUT -p tcp --dport ${SERVICE_PORT} -j ACCEPT
        # 尝试保存iptables规则
        if command -v iptables-save &> /dev/null; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
    fi
}

# 启动服务
start_service() {
    log "启动MagicDog服务..."
    
    systemctl start ${SERVICE_NAME}
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        log "✅ MagicDog服务启动成功"
    else
        error "❌ MagicDog服务启动失败，请检查日志: journalctl -u ${SERVICE_NAME}"
    fi
}

# 等待服务完全启动
wait_for_service() {
    log "等待MagicDog服务完全启动..."
    
    local max_wait=300  # 最大等待时间5分钟
    local wait_time=0
    local check_interval=5
    
    # 显示启动提示
    echo ""
    echo -e "${YELLOW}⏳ 正在启动MagicDog服务，首次启动可能需要较长时间...${NC}"
    echo ""
    
    while [ $wait_time -lt $max_wait ]; do
        # 检查端口是否监听
        if command -v netstat &> /dev/null; then
            if netstat -tlnp 2>/dev/null | grep ":${SERVICE_PORT}" > /dev/null; then
                log "✅ 检测到端口 ${SERVICE_PORT} 已开始监听"
                break
            fi
        elif command -v ss &> /dev/null; then
            if ss -tlnp 2>/dev/null | grep ":${SERVICE_PORT}" > /dev/null; then
                log "✅ 检测到端口 ${SERVICE_PORT} 已开始监听"
                break
            fi
        elif command -v lsof &> /dev/null; then
            if lsof -i :${SERVICE_PORT} 2>/dev/null | grep LISTEN > /dev/null; then
                log "✅ 检测到端口 ${SERVICE_PORT} 已开始监听"
                break
            fi
        else
            # 使用curl测试连接
            if curl -s --connect-timeout 1 http://localhost:${SERVICE_PORT} >/dev/null 2>&1; then
                log "✅ 服务已可访问"
                break
            fi
        fi
        
        # 显示等待进度
        dots=""
        for ((i=0; i<(wait_time/check_interval)%4; i++)); do
            dots="${dots}."
        done
        printf "\r${BLUE}[INFO]${NC} 等待服务启动${dots}    (${wait_time}s/${max_wait}s)"
        
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    done
    
    echo ""  # 换行
    
    if [ $wait_time -ge $max_wait ]; then
        warn "⚠️  服务启动超时，但安装可能已完成"
        warn "请手动检查服务状态: systemctl status magicdog"
        return 1
    fi
    
    # 额外等待几秒确保服务完全就绪
    log "服务检测成功，等待完全就绪..."
    sleep 5
    
    return 0
}

# 输出初始化数据
show_initialization_data() {
    log "获取系统初始化数据..."
    
    local magic_file="${INSTALL_DIR}/magicdog_linux_deploy/static/MagicDog.txt"
    local public_file="${INSTALL_DIR}/magicdog_linux_deploy/public/MagicDog.txt"
    
    # 尝试查找MagicDog.txt文件的位置
    local found_file=""
    if [ -f "$public_file" ]; then
        found_file="$public_file"
    elif [ -f "$magic_file" ]; then
        found_file="$magic_file"
    else
        # 搜索所有可能的位置
        found_file=$(find "${INSTALL_DIR}" -name "MagicDog.txt" 2>/dev/null | head -1)
    fi
    
    if [ -n "$found_file" ] && [ -f "$found_file" ]; then
        echo ""
        echo -e "${GREEN}🔑 系统初始化数据:${NC}"
        echo "=========================================="
        cat "$found_file"
        echo "=========================================="
        echo ""
        log "✅ 初始化数据已显示，请记录上述信息"
    else
        warn "⚠️  未找到MagicDog.txt文件，可能需要等待服务完全初始化"
        warn "文件位置: ${INSTALL_DIR}/magicdog_linux_deploy/public/MagicDog.txt"
        warn "请稍后手动查看该文件获取初始化数据"
    fi
}

# 检查服务是否正常运行
check_service() {
    log "检查服务运行状态..."
    
    # 检查端口是否监听
    if command -v netstat &> /dev/null; then
        if netstat -tlnp | grep ":${SERVICE_PORT}" > /dev/null; then
            log "✅ 服务正在监听端口 ${SERVICE_PORT}"
        else
            warn "⚠️  端口 ${SERVICE_PORT} 未在监听，请检查服务状态"
        fi
    elif command -v ss &> /dev/null; then
        if ss -tlnp | grep ":${SERVICE_PORT}" > /dev/null; then
            log "✅ 服务正在监听端口 ${SERVICE_PORT}"
        else
            warn "⚠️  端口 ${SERVICE_PORT} 未在监听，请检查服务状态"
        fi
    fi
}

# 显示安装完成信息
show_completion_info() {
    echo ""
    echo -e "${BLUE}🎉 MagicDog 安装完成！${NC}"
    echo "=================================="
    echo ""
    echo -e "${GREEN}📋 服务信息:${NC}"
    echo "服务名称: ${SERVICE_NAME}"
    echo "安装目录: ${INSTALL_DIR}"
    echo "服务端口: ${SERVICE_PORT}"
    echo "配置文件: ${INSTALL_DIR}/magicdog_linux_deploy/"
    echo ""
    echo -e "${GREEN}🔧 管理命令:${NC}"
    echo "启动服务: systemctl start ${SERVICE_NAME}"
    echo "停止服务: systemctl stop ${SERVICE_NAME}"
    echo "重启服务: systemctl restart ${SERVICE_NAME}"
    echo "查看状态: systemctl status ${SERVICE_NAME}"
    echo "查看日志: journalctl -u ${SERVICE_NAME} -f"
    echo ""
    echo -e "${GREEN}🌐 访问地址:${NC}"
    echo "http://服务器IP:${SERVICE_PORT}"
    echo "http://localhost:${SERVICE_PORT}"
    echo ""
    echo -e "${YELLOW}⚠️  安全提醒:${NC}"
    echo "1. 请及时修改默认密码"
    echo "2. 建议配置SSL证书"
    echo "3. 定期更新程序版本"
    echo "4. 监控服务运行状态"
    echo ""
    echo -e "${BLUE}📝 配置文件位置:${NC}"
    echo "${INSTALL_DIR}/magicdog_linux_deploy/data/"
    echo ""
    
    # 显示初始化数据位置提示
    echo -e "${GREEN}📄 获取初始化数据:${NC}"
    echo "初始化数据文件: ${INSTALL_DIR}/magicdog_linux_deploy/public/MagicDog.txt"
    echo "或运行: cat ${INSTALL_DIR}/magicdog_linux_deploy/public/MagicDog.txt"
    echo ""
}

# 主安装流程
main() {
    echo -e "${BLUE}🐕 MagicDog Linux 一键安装脚本${NC}"
    echo "======================================"
    echo ""
    
    check_root
    detect_os
    check_system_compatibility
    pre_install_basics
    check_and_fix_time
    install_dependencies
    check_redis
    download_project
    cleanup_old_database
    # test_binary_compatibility
    setup_service
    setup_firewall
    start_service
    
    # 等待服务完全启动并显示初始化数据
    if wait_for_service; then
        show_initialization_data
    fi
    
    check_service
    show_completion_info
    
    log "安装脚本执行完成！"
}

# 运行主函数
main "$@"
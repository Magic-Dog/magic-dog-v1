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

# 检查并修复系统时间
check_and_fix_time() {
    log "检查系统时间..."
    
    # 检查是否有ntpdate或timedatectl
    if command -v timedatectl &> /dev/null; then
        log "使用timedatectl同步时间..."
        timedatectl set-ntp true 2>/dev/null || true
        sleep 2
    elif command -v ntpdate &> /dev/null; then
        log "使用ntpdate同步时间..."
        ntpdate -s time.nist.gov 2>/dev/null || ntpdate -s pool.ntp.org 2>/dev/null || true
    fi
    
    # 显示当前时间
    log "当前系统时间: $(date)"
}

# 安装依赖包
install_dependencies() {
    log "安装系统依赖..."
    
    case $OS in
        ubuntu|debian)
            # 尝试修复apt源问题
            export DEBIAN_FRONTEND=noninteractive
            
            # 更新包列表，忽略时间相关错误
            apt update -o Acquire::Check-Valid-Until=false || {
                warn "apt update遇到问题，尝试使用备用方案..."
                apt update --allow-unauthenticated 2>/dev/null || true
            }
            
            # 安装必要包
            apt install -y curl wget git redis-server systemd ntpdate 2>/dev/null || {
                warn "部分包安装失败，尝试单独安装..."
                apt install -y curl wget git || error "无法安装基础工具"
                apt install -y redis-server || warn "Redis安装失败，请手动安装"
                apt install -y systemd || true
                apt install -y ntpdate || true
            }
            
            systemctl enable redis-server 2>/dev/null || true
            systemctl start redis-server 2>/dev/null || true
            ;;
        centos|rhel|fedora)
            if command -v dnf &> /dev/null; then
                dnf install -y curl wget git redis systemd ntpdate 2>/dev/null || {
                    dnf install -y curl wget git || error "无法安装基础工具"
                    dnf install -y redis || warn "Redis安装失败，请手动安装"
                }
            else
                yum install -y curl wget git redis systemd ntpdate 2>/dev/null || {
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

# 下载项目
download_project() {
    log "下载MagicDog项目..."
    
    # 删除旧的安装目录
    if [ -d "$INSTALL_DIR" ]; then
        warn "删除旧的安装目录: $INSTALL_DIR"
        rm -rf "$INSTALL_DIR"
    fi
    
    # 克隆项目并切换到main分支
    git clone -b main "$GITHUB_REPO" "$INSTALL_DIR"
    
    # 检查关键文件是否存在
    if [ ! -f "$INSTALL_DIR/magicdog_linux_deploy/magicDog" ]; then
        error "关键文件不存在: magicDog 可执行文件"
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
}

# 主安装流程
main() {
    echo -e "${BLUE}🐕 MagicDog Linux 一键安装脚本${NC}"
    echo "======================================"
    echo ""
    
    check_root
    detect_os
    check_and_fix_time
    install_dependencies
    check_redis
    download_project
    setup_service
    setup_firewall
    start_service
    check_service
    show_completion_info
    
    log "安装脚本执行完成！"
}

# 运行主函数
main "$@"
#!/bin/bash

# MagicDog 一键安装运行脚本 (Linux)
# 自动检测系统、安装环境、下载模板文件并运行容器

set -e

# 配置变量
MAGICDOG_DIR="magicdog-deploy"
APP_PORT="8080"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
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

info() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

success() {
    echo -e "${PURPLE}[SUCCESS]${NC} $1"
}

# 显示欢迎信息
show_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════╗
    ║                                                      ║
    ║               🐕 MagicDog 一键部署脚本                ║
    ║                                                      ║
    ║        自动安装 Docker 环境并运行 MagicDog            ║
    ║                                                      ║
    ╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

# 检测Linux发行版
detect_os() {
    info "检测操作系统..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
        echo "检测到系统: $OS $VER"
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/redhat-release ]; then
        OS="CentOS"
        VER=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
    else
        error "无法检测Linux发行版"
    fi
    
    log "操作系统: $OS"
    log "版本: $VER"
}

# 检查是否为root用户或具有sudo权限
check_privileges() {
    info "检查用户权限..."
    
    if [ "$EUID" -eq 0 ]; then
        log "检测到root用户"
        SUDO=""
    elif sudo -n true 2>/dev/null; then
        log "检测到sudo权限"
        SUDO="sudo"
    else
        error "需要root权限或sudo权限来安装软件包"
    fi
}

# 更新系统包管理器
update_system() {
    info "更新系统包管理器..."
    
    case $OS in
        "Ubuntu"*|"Debian"*)
            $SUDO apt-get update -y
            $SUDO apt-get install -y curl wget gnupg lsb-release ca-certificates
            ;;
        "CentOS"*|"Red Hat"*|"Rocky"*|"AlmaLinux"*)
            $SUDO yum update -y
            $SUDO yum install -y curl wget yum-utils
            ;;
        "Fedora"*)
            $SUDO dnf update -y
            $SUDO dnf install -y curl wget dnf-plugins-core
            ;;
        *)
            warn "未识别的Linux发行版，尝试通用安装方法"
            ;;
    esac
    
    success "系统更新完成"
}

# 检查Docker是否已安装
check_docker() {
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log "Docker已安装，版本: $DOCKER_VERSION"
        return 0
    else
        return 1
    fi
}

# 安装Docker
install_docker() {
    info "安装Docker..."
    
    case $OS in
        "Ubuntu"*|"Debian"*)
            # 添加Docker官方GPG密钥
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            
            # 添加Docker仓库
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            # 安装Docker
            $SUDO apt-get update -y
            $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
            
        "CentOS"*|"Red Hat"*|"Rocky"*|"AlmaLinux"*)
            # 添加Docker仓库
            $SUDO yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            # 安装Docker
            $SUDO yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
            
        "Fedora"*)
            # 添加Docker仓库
            $SUDO dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
            
            # 安装Docker
            $SUDO dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
            
        *)
            error "不支持的Linux发行版: $OS"
            ;;
    esac
    
    # 启动Docker服务
    $SUDO systemctl start docker
    $SUDO systemctl enable docker
    
    # 将当前用户添加到docker组(如果不是root用户)
    if [ "$EUID" -ne 0 ]; then
        $SUDO usermod -aG docker $USER
        log "已将用户 $USER 添加到docker组"
        log "注意: 需要重新登录或运行 'newgrp docker' 以使组权限生效"
    fi
    
    success "Docker安装完成"
}

# 检查Docker Compose是否已安装
check_docker_compose() {
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        if command -v docker-compose &> /dev/null; then
            COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | cut -d',' -f1)
            log "Docker Compose已安装，版本: $COMPOSE_VERSION"
        else
            COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
            log "Docker Compose Plugin已安装，版本: $COMPOSE_VERSION"
        fi
        return 0
    else
        return 1
    fi
}

# 安装Docker Compose
install_docker_compose() {
    info "安装Docker Compose..."
    
    # 首先检查是否已有Docker Compose Plugin
    if docker compose version &> /dev/null; then
        log "Docker Compose Plugin已可用"
        return 0
    fi
    
    # 安装独立的docker-compose
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    $SUDO curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    $SUDO chmod +x /usr/local/bin/docker-compose
    
    success "Docker Compose安装完成，版本: $COMPOSE_VERSION"
}

# 创建部署目录
create_deploy_directory() {
    info "创建部署目录..."
    
    if [ -d "$MAGICDOG_DIR" ]; then
        warn "目录 $MAGICDOG_DIR 已存在"
        read -p "是否删除现有目录并重新创建? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$MAGICDOG_DIR"
        else
            error "部署已取消"
        fi
    fi
    
    mkdir -p "$MAGICDOG_DIR"
    cd "$MAGICDOG_DIR"
    
    # 创建必要的目录结构
    mkdir -p {public,AdminIndex,static,data,updates,logs}
    mkdir -p data/{card_cache,geoip}
    
    success "部署目录创建完成: $(pwd)"
}

# 创建配置文件
create_config_files() {
    info "创建配置文件..."
    
    # 创建docker-compose.yml
    log "创建 docker-compose.yml..."
    create_docker_compose_file
    
    success "配置文件创建完成"
}

# 创建docker-compose.yml文件(备用)
create_docker_compose_file() {
    cat > docker-compose.yml << 'EOF'
services:
  magicdog:
    image: ghcr.io/magic-dog/magic-dog-v1
    
    restart: unless-stopped
    ports:
      - "${APP_PORT:-8080}:8080"
    volumes:
      - ./public:/app/public
      - ./AdminIndex:/app/AdminIndex
      - ./static:/app/static
      - ./data:/app/data
      - ./updates:/app/updates
      - ./logs:/app/logs
      - redis_data:/var/lib/redis
    networks:
      - magicdog_network

volumes:
  redis_data:
    driver: local
  app_data:
    driver: local
  app_logs:
    driver: local

networks:
  magicdog_network:
    driver: bridge 
EOF
}

# 下载并运行容器
deploy_magicdog() {
    info "部署MagicDog..."
    
    # 检查使用哪个compose命令
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        error "Docker Compose未正确安装"
    fi
    
    log "拉取最新镜像..."
    $COMPOSE_CMD pull
    
    log "启动容器..."
    $COMPOSE_CMD up -d
    
    # 等待容器启动和初始化
    log "等待服务启动和初始化..."
    sleep 10
    
    # 检查容器状态
    if $COMPOSE_CMD ps | grep -q "Up"; then
        success "MagicDog启动成功！"
        
        # 显示系统用户信息
        if [ -f "public/MagicDog.txt" ]; then
            log "系统用户信息已生成："
            echo ""
            echo -e "${GREEN}=================================================="
            cat public/MagicDog.txt
            echo -e "==================================================${NC}"
            echo ""
        else
            warn "系统用户信息文件尚未生成，请稍等片刻后查看: cat public/MagicDog.txt"
        fi
    else
        error "MagicDog启动失败，请检查日志: $COMPOSE_CMD logs"
    fi
}

# 显示部署信息
show_deployment_info() {
    echo ""
    echo -e "${GREEN}🎉 MagicDog部署完成！${NC}"
    echo "======================================="
    echo ""
    echo -e "${BLUE}📁 部署目录:${NC}"
    echo "  📂 $(pwd)"
    echo ""
    echo -e "${YELLOW}⚠️  注意事项:${NC}"
    echo "  1. 首次启动可能需要几分钟时间来初始化"
    echo "  2. 确保防火墙允许端口 8080 的访问"
    echo "  3. 数据将保存在 ./data 目录中"
    echo "  4. 日志文件位于 ./logs 目录中"
    echo "  5. 系统用户信息保存在 ./public/MagicDog.txt 文件中"
    echo ""
}

# 主函数
main() {
    show_banner
    
    # 检查系统
    detect_os
    check_privileges
    
    # 更新系统
    update_system
    
    # 安装Docker
    if ! check_docker; then
        install_docker
    fi
    
    # 安装Docker Compose
    if ! check_docker_compose; then
        install_docker_compose
    fi
    
    # 创建部署环境
    create_deploy_directory
    create_config_files
    
    # 部署应用
    deploy_magicdog
    
    # 显示部署信息
    show_deployment_info
    
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 

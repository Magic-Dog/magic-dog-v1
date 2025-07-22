# MagicDog Linux Deploy

MagicDog的Linux一键部署包，支持主流Linux发行版的快速安装和部署。

## 特性

- 🚀 一键安装部署
- 🔧 自动安装Redis依赖
- 📦 包含完整的编译二进制文件
- 🛡️ 自动配置防火墙规则
- ⚙️ 系统服务自动启动
- 🐧 支持Ubuntu/Debian/CentOS/RHEL
- 🔒 安全的systemd服务配置
- 📊 完整的管理界面

## 快速安装

### 方式一：一键安装脚本（推荐）
```bash
curl -fsSL https://raw.githubusercontent.com/Magic-Dog/magic-dog-v1/main/install.sh | sudo bash
```

### 方式二：手动安装
```bash
# 克隆仓库
git clone https://github.com/Magic-Dog/magic-dog-v1.git
cd magic-dog-v1

# 运行安装脚本
sudo chmod +x install.sh
sudo ./install.sh
```

## 系统要求

- **操作系统**: Ubuntu 18.04+, Debian 9+, CentOS 7+, RHEL 7+
- **权限**: root权限或sudo权限
- **网络**: 互联网连接（用于下载依赖）
- **内存**: 至少512MB可用内存
- **硬盘**: 至少1GB可用空间

## 服务管理

安装完成后，MagicDog将作为系统服务运行在8080端口：

### 基本命令
```bash
# 查看服务状态
sudo systemctl status magicdog

# 启动服务
sudo systemctl start magicdog

# 停止服务
sudo systemctl stop magicdog

# 重启服务
sudo systemctl restart magicdog

# 启用开机自启动
sudo systemctl enable magicdog

# 禁用开机自启动
sudo systemctl disable magicdog
```

### 日志查看
```bash
# 查看实时日志
sudo journalctl -u magicdog -f

# 查看最近50条日志
sudo journalctl -u magicdog -n 50

# 查看今天的日志
sudo journalctl -u magicdog --since today
```

## 访问应用

安装完成后，可以通过以下方式访问：

- **本地访问**: http://localhost:8080
- **远程访问**: http://服务器IP:8080
- **管理界面**: 同上地址，使用默认管理员账号登录

> ⚠️ **安全提醒**: 首次登录后请立即修改默认密码！

## 目录结构

```
/opt/magicdog/magicdog_linux_deploy/
├── magicDog          # 主程序二进制文件
├── AdminIndex/       # 管理界面静态文件
│   ├── assets/       # 前端资源文件
│   ├── index.html    # 主页面
│   └── favicon.svg   # 图标
├── data/             # 数据目录
│   ├── card_cache/   # 卡片缓存
│   └── geoip/        # 地理位置数据
├── static/           # 静态资源
│   ├── backdata/     # 备份数据
│   └── style.css     # 样式文件
├── start.sh          # 启动脚本
└── README.md         # 说明文档
```

## 配置文件

- **系统服务配置**: `/etc/systemd/system/magicdog.service`
- **应用数据目录**: `/opt/magicdog/magicdog_linux_deploy/data/`
- **日志文件**: 通过systemd管理，使用 `journalctl` 查看

## 故障排除

### 服务无法启动
```bash
# 检查服务状态和错误信息
sudo systemctl status magicdog -l

# 查看详细启动日志
sudo journalctl -u magicdog -n 50

# 检查端口占用情况
sudo netstat -tlnp | grep 8080
sudo ss -tlnp | grep 8080

# 检查文件权限
ls -la /opt/magicdog/magicdog_linux_deploy/magicDog
```

### Redis连接问题
```bash
# 检查Redis服务状态
sudo systemctl status redis-server || sudo systemctl status redis

# 启动Redis服务
sudo systemctl start redis-server || sudo systemctl start redis

# 测试Redis连接
redis-cli ping

# 检查Redis配置
sudo netstat -tlnp | grep 6379
```

### 网络连接问题
```bash
# 检查防火墙状态
sudo ufw status || sudo firewall-cmd --list-all

# 临时开放端口（测试用）
sudo ufw allow 8080 || sudo firewall-cmd --add-port=8080/tcp

# 检查程序是否正在监听端口
sudo netstat -tlnp | grep magicDog
```

### 权限问题
```bash
# 检查安装目录权限
ls -la /opt/magicdog/

# 修复权限（如果需要）
sudo chown -R root:root /opt/magicdog/
sudo chmod +x /opt/magicdog/magicdog_linux_deploy/magicDog
```

## 更新升级

### 自动更新（推荐）
重新运行安装脚本即可更新到最新版本：
```bash
curl -fsSL https://raw.githubusercontent.com/Magic-Dog/magic-dog-v1/main/install.sh | sudo bash
```

### 手动更新
```bash
# 停止服务
sudo systemctl stop magicdog

# 备份当前版本（可选）
sudo cp -r /opt/magicdog /opt/magicdog.backup.20250723

# 下载新版本
cd /tmp
git clone https://github.com/Magic-Dog/magic-dog-v1.git
cd magic-dog-v1

# 运行安装脚本
sudo ./install.sh
```

## 备份与恢复

### 数据备份
```bash
# 创建完整备份
sudo tar -czf magicdog-backup-20250723.tar.gz -C /opt magicdog/

# 仅备份数据文件
sudo tar -czf magicdog-data-20250723.tar.gz -C /opt/magicdog/magicdog_linux_deploy data/
```

### 数据恢复
```bash
# 停止服务
sudo systemctl stop magicdog

# 恢复完整备份
sudo tar -xzf magicdog-backup-YYYYMMDD.tar.gz -C /opt/

# 启动服务
sudo systemctl start magicdog
```

## 完全卸载

```bash
# 停止并删除服务
sudo systemctl stop magicdog
sudo systemctl disable magicdog
sudo rm -f /etc/systemd/system/magicdog.service
sudo systemctl daemon-reload

# 删除安装目录
sudo rm -rf /opt/magicdog

# 可选：删除Redis（如果仅为MagicDog安装）
# sudo systemctl stop redis-server
# sudo apt remove redis-server -y  # Ubuntu/Debian
# sudo yum remove redis -y         # CentOS/RHEL

# 删除防火墙规则（如果需要）
sudo ufw delete allow 8080 || sudo firewall-cmd --remove-port=8080/tcp --permanent
```

## 性能优化

### 系统资源监控
```bash
# 查看MagicDog进程资源使用情况
ps aux | grep magicDog

# 查看系统资源使用
htop
free -h
df -h
```

### 配置优化建议
- 确保服务器有足够的内存（推荐1GB+）
- 定期清理日志文件
- 监控磁盘空间使用情况
- 配置日志轮转

## 安全建议

1. **修改默认密码**: 首次登录后立即修改默认管理员密码
2. **配置SSL证书**: 在生产环境中配置HTTPS
3. **配置防火墙**: 仅开放必要的端口
4. **定期更新**: 保持系统和应用程序为最新版本
5. **监控日志**: 定期检查应用日志，发现异常及时处理
6. **数据备份**: 定期备份重要数据

## 技术支持

如果您在使用过程中遇到问题：

1. 查看本文档的故障排除部分
2. 检查系统日志：`sudo journalctl -u magicdog -f`
3. 在GitHub仓库提交Issue：https://github.com/Magic-Dog/magic-dog-v1/issues

## 更新日志

### 最新版本特性
- 支持多种Linux发行版
- 自动化安装和配置
- 系统服务集成
- 完善的错误处理和日志记录

## 许可证

本项目遵循相应的开源许可证。详情请查看LICENSE文件。

---

**MagicDog Linux Deploy** - 让Linux部署变得简单！

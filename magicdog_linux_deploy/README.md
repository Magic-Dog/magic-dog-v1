# MagicDog Linux 部署说明

## 要求
- Linux系统 (Ubuntu 20.04+, CentOS 7+, Debian 10+)
- 系统已安装 glibc 2.31+
- 端口 8080 未被占用

## 快速启动
1. 解压文件到目标目录
2. 运行: ./start.sh

## 作为系统服务运行
1. 复制文件到 /opt/magicdog/
2. 复制 magicdog.service 到 /etc/systemd/system/
3. 运行:
   sudo systemctl daemon-reload
   sudo systemctl enable magicdog
   sudo systemctl start magicdog

## 检查状态
sudo systemctl status magicdog

## 查看日志
sudo journalctl -u magicdog -f

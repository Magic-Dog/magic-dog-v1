#!/bin/bash
# MagicDog Server 启动脚本

# 设置工作目录
cd "$(dirname "$0")"

# 检查端口是否被占用
PORT=8080
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ 端口 $PORT 已被占用"
    exit 1
fi

# 启动服务器
echo "🚀 启动 MagicDog Server..."
./magicDog

#!/bin/bash
# 这个批处理会自动将 IPv6 配置脚本 operation.sh 发送到路由器上运行
# 使用前请先将下方的IP地址修改为你路由器的网关地址
# This batch file will automatically send operation.sh to your route, then run.
# Change the following IP address to your actual gateway address.

scp operation.sh root@192.168.1.1:/tmp/
ssh root@192.168.1.1 "chmod +x /tmp/install.sh; sh /tmp/operation.sh"

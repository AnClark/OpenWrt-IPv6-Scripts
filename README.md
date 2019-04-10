# OpenWrt-IPv6-Scripts

根据网络教程，为OpenWrt设计的IPv6脚本

## 概述

一般情况下，IPv6 并不支持 NAT，所以默认地，路由器并不能像 IPv4 那样，给客户端共享 IPv6 互联网连接。因此我们有一些替代方案，其中经我实测可用的，是 kmod 配合 ip6tables 的方案。

点击“Use ip6tables”文件夹，以查看教程、阅读源码。

## Abstract

This is a set of IPv6 configuration scripts for OpenWrt referred to existing guides.

By default, IPv6 doesn't support NAT, so you cannot share IPv6 connections with your router. So there's some substitudes available. What works well is that using kmod with ip6tables.

Please click "Use ip6table" to view the guide and read source code.

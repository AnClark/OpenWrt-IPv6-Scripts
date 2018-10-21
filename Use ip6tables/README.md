# ipv6tables 共享 IPv6 教程

## 原理
通过给路由器安装上 kmod-ipt-nat6 模块，配合 ip6tables 的使用，为路由器开启 IPv6 网络的 NAT 功能。

期间，为保证功能的开启，需要给路由器设置一系列的参数。具体设置参数可在脚本 operation.sh 中阅读。

## 需求
* SCP工具（scp）。
* SSH工具（scp）。

以上工具在Linux发行版中均有自带。

如果您使用Windows，建议您安装 Git Bash （Git-scp）或者是 Cygwin，它们都自带了该工具。

本工具中的批处理脚本 execute.cmd 要求您事先把Git Bash 和 Cygwin 的 /bin 目录加入PATH环境变量中，它们通常在这些工具的安装目录下。当然，您也可以直接在这两款工具的命令解释器中运行 execute.sh。

当然，您也可以使用 WinSCP 配合 PuTTY 来完成上述两款工具的工作。

## 自动操作方法
* 1. 在Windows中，确保scp和ssh这两款工具在您的PATH中，随后运行execute.cmd。如果是Linux或Git Bash、Cygwin，请运行execute.sh。

在当前目录下运行脚本的方法是 ```./<脚本文件名>```。

* 2. 这时您可能需要输入两次路由器密码，按提示操作即可。
* 3. 脚本执行完毕后，重启路由器。

## 手动操作方法
### Windows 下
* 1. 使用 WinSCP，将 operation.sh 上传到路由器的 /tmp 目录中。
* 2. 使用 PuTTY 登录路由器，cd到tmp目录，随后运行：
```
chmod +x operation.sh
./operation.sh
```
* 3. 操作完成后，重启路由器。


## 参考资料
* [【转发】 通过openwrt的NAT6转发，使后端设备获得ipv6网络](https://blog.csdn.net/guituo9698/article/details/70285755)
* zqp19950813 整理的教程

## 致谢
* 教程整理：zqp19950813

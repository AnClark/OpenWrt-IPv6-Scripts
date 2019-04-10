# ipv6tables 共享 IPv6 教程

**How To Share IPv6 with `ipv6tables`**

<span style="font-size: 1.5em;">**[=== Click Here to Read in English ===](#english)**</span>

## 原理

通过给路由器安装上 `kmod-ipt-nat6` 模块，配合 `ip6tables` 的使用，为路由器开启 IPv6 网络的 NAT 功能。

期间，为保证功能的开启，需要给路由器设置一系列的参数。具体设置参数可在脚本 `operation.sh` 中阅读。

## 需求

* SCP工具（scp）。
* SSH工具（scp）。

以上工具在Linux发行版中均有自带。

如果您使用Windows，建议您安装 Git Bash （Git-scp）或者是 Cygwin，它们都自带了该工具。

本工具中的批处理脚本 execute.cmd 要求您事先把Git Bash 和 Cygwin 的 /bin 目录加入PATH环境变量中，它们通常在这些工具的安装目录下。当然，您也可以直接在这两款工具的命令解释器中运行 execute.sh。

当然，您也可以使用 WinSCP 配合 PuTTY 来完成上述两款工具的工作。

## 自动操作方法

1. 在Windows中，确保scp和ssh这两款工具在您的PATH中，随后运行execute.cmd。如果是Linux或Git Bash、Cygwin，请运行execute.sh。在当前目录下运行脚本的方法是 ```./<脚本文件名>```。
2. 这时您可能需要输入两次路由器密码，按提示操作即可。
3. 脚本执行完毕后，重启路由器。

## 手动操作方法

### Windows 下

1. 使用 WinSCP，将 operation.sh 上传到路由器的 /tmp 目录中。
2. 使用 PuTTY 登录路由器，cd到tmp目录，随后运行：

    ```shell
    chmod +x operation.sh
    ./operation.sh
    ```

3. 操作完成后，重启路由器。

## 注意

内核模块需要从OpenWrt的软件仓库中获取，因此安装模块时需要路由器已经连接网络。

## 参考资料

* [TS - 在OpenWrt上配置原生IPv6 NAT](https://tang.su/2017/03/openwrt-ipv6-nat/)
* [【转发】 通过openwrt的NAT6转发，使后端设备获得ipv6网络](https://blog.csdn.net/guituo9698/article/details/70285755)
* zqp19950813 整理的教程

## 致谢

* 教程整理：zqp19950813

---

<!-- English translation start -->
<span id="english"></span>

## Principle

This script will make your router support IPv6's NAT by installing `kmod-ipt-nat6` kernel module, with configurating `ip6tables`.

During this, to ensure these features take effect, you need to set a series of parameters. Read `operation.sh` to find out how to do.

## Requirements

* SCP utility (`scp`)
* SSH client (`ssh`)。

They are all contained in any Linux distributions, as they are core components.

If you're using Windows, it's highly recommended that you install Git Bash (Git-SCP) or Cygwin, as the two kits also contained them.

The batch file `execute.cmd` requires you to add Git Bash or Cygwin's `/bin` directory to `%PATH%` - usually their `/bin` directories are in where you installed them. Of cource, you can directory run `execute.sh` with their shells (usually bash).

By the way, you can also try WinSCP with PuTTY. WinSCP serves as `scp`, and `PuTTY` serves as `ssh`.

## How to apply automatically

1. On Windows, ensure that the commands above are in your `%PATH%`, then run `execute.cmd`. If you're using Linux or Git Bash or Cygwin, run `execute.sh`. To run scripts in the current directory, please use ```./<script filename>```.

2. At this time, you may need to type router's admin password twice. Just follow the instructions.

3. Reboot your router after script finishes.

## Manually apply

### On Windows

1. Use WinSCP to upload `operation.sh` to the router's `/tmp` directory.
2. Use PuTTY's SSH to log in your router, `cd` to `/tmp`, then run:

    ```bash
    chmod +x operation.sh
    ./operation.sh
    ```

3. Reboot your router when operation finishes.

### On Linux

Follow the following shell commands:

1. Upload `operation.sh` to your router.

    ```bash
    scp operation.sh /tmp
    ```

2. Log in your router, then execute the script.

    ```bash
    # ================= LOCAL SESSION =================
    ssh root@<ROUTER ADDRESS>

    # ================= ROUTER SESSION =================
    cd /tmp
    ./operation.sh
    ```

3. Once finishes, reboot your router.

## Notice

Installing kernel modules requires your router to have Internet access, as the package manager will fetch modules from OpenWrt's repository.

#!/bin/sh
# -------------------------------------------------------------------
#	OpenWrt IPv6 自动配置脚本
#
#	可在LEDE等基于OpenWrt的环境下配置IPv6支持。
#
#	制作：AnClark
#	致谢：zqp19950813
# -------------------------------------------------------------------


# 1. Install the package kmod-ipt-nat6    # 安装kmod-ipt-nat6
opkg update
opkg install kmod-ipt-nat6


# 2. Change the first letter of the "IPv6 ULA Prefix" from f to d
uci set network.globals.ula_prefix="$(uci get network.globals.ula_prefix | sed 's/^./d/')"
uci commit network


# 3. Set the DHCP server to "Always announce default router"
uci set dhcp.lan.ra_default='1'
uci commit dhcp


# 4. Add an init script for NAT6 by creating a new file /etc/init.d/nat6 and paste the code from the section Init Script into it    #生成nat6脚本
touch /etc/init.d/nat6
cat > /etc/init.d/nat6 << EOF
#!/bin/sh /etc/rc.common
# NAT6 init script for OpenWrt // Depends on package: kmod-ipt-nat6

START=55

# Options
# -------

# Use temporary addresses (IPv6 privacy extensions) for outgoing connections? Yes: 1 / No: 0
PRIVACY=1

# Maximum number of attempts before this script will stop in case no IPv6 route is available
# This limits the execution time of the IPv6 route lookup to (MAX_TRIES+1)*(MAX_TRIES/2) seconds. The default (15) equals 120 seconds.
MAX_TRIES=15

# An initial delay (in seconds) helps to avoid looking for the IPv6 network too early. Ideally, the first probe is successful.
# This would be the case if the time passed between the system log messages "Probing IPv6 route" and "Setting up NAT6" is 1 second.
DELAY=5

# Logical interface name of outbound IPv6 connection
# There should be no need to modify this, unless you changed the default network interface names
# Edit by Vincent: I never changed my default network interface names, but still I have to change the WAN6_NAME to "wan" instead of "wan6"
WAN6_NAME="wan6"

# ---------------------------------------------------
# Options end here - no need to change anything below

boot() {
        [ $DELAY -gt 0 ] && sleep $DELAY
        logger -t NAT6 "Probing IPv6 route"
        PROBE=0
        COUNT=1
        while [ $PROBE -eq 0 ]
        do
                if [ $COUNT -gt $MAX_TRIES ]
                then
                        logger -t NAT6 "Fatal error: No IPv6 route found (reached retry limit)" && exit 1
                fi
                sleep $COUNT
                COUNT=$((COUNT+1))
                PROBE=$(route -A inet6 | grep -c '::/0')
        done
 
        logger -t NAT6 "Setting up NAT6"
 
        WAN6_INTERFACE=$(uci get "network.$WAN6_NAME.ifname")
        if [ -z "$WAN6_INTERFACE" ] || [ ! -e "/sys/class/net/$WAN6_INTERFACE/" ] ; then
                logger -t NAT6 "Fatal error: Lookup of $WAN6_NAME interface failed. Were the default interface names changed?" && exit 1
        fi
        WAN6_GATEWAY=$(route -A inet6 -e | grep "$WAN6_INTERFACE" | awk '/::\/0/{print $2; exit}')
        if [ -z "$WAN6_GATEWAY" ] ; then
                logger -t NAT6 "Fatal error: No IPv6 gateway for $WAN6_INTERFACE found" && exit 1
        fi
        LAN_ULA_PREFIX=$(uci get network.globals.ula_prefix)
        if [ $(echo "$LAN_ULA_PREFIX" | grep -c -E "^([0-9a-fA-F]{4}):([0-9a-fA-F]{0,4}):") -ne 1 ] ; then
                logger -t NAT6 "Fatal error: IPv6 ULA prefix $LAN_ULA_PREFIX seems invalid. Please verify that a prefix is set and valid." && exit 1
        fi
 
        ip6tables -t nat -I POSTROUTING -s "$LAN_ULA_PREFIX" -o "$WAN6_INTERFACE" -j MASQUERADE
        if [ $? -eq 0 ] ; then
                logger -t NAT6 "Added IPv6 masquerading rule to the firewall (Src: $LAN_ULA_PREFIX - Dst: $WAN6_INTERFACE)"
        else
                logger -t NAT6 "Fatal error: Failed to add IPv6 masquerading rule to the firewall (Src: $LAN_ULA_PREFIX - Dst: $WAN6_INTERFACE)" && exit 1
        fi
 
        route -A inet6 add 2000::/3 gw "$WAN6_GATEWAY" dev "$WAN6_INTERFACE"
        if [ $? -eq 0 ] ; then
                logger -t NAT6 "Added $WAN6_GATEWAY to routing table as gateway on $WAN6_INTERFACE for outgoing connections"
        else
                logger -t NAT6 "Error: Failed to add $WAN6_GATEWAY to routing table as gateway on $WAN6_INTERFACE for outgoing connections"
        fi
 
        if [ $PRIVACY -eq 1 ] ; then
                echo 2 > "/proc/sys/net/ipv6/conf/$WAN6_INTERFACE/accept_ra"
                if [ $? -eq 0 ] ; then
                        logger -t NAT6 "Accepting router advertisements on $WAN6_INTERFACE even if forwarding is enabled (required for temporary addresses)"
                else
                        logger -t NAT6 "Error: Failed to change router advertisements accept policy on $WAN6_INTERFACE (required for temporary addresses)"
                fi
                echo 2 > "/proc/sys/net/ipv6/conf/$WAN6_INTERFACE/use_tempaddr"
                if [ $? -eq 0 ] ; then
                        logger -t NAT6 "Using temporary addresses for outgoing connections on interface $WAN6_INTERFACE"
                else
                        logger -t NAT6 "Error: Failed to enable temporary addresses for outgoing connections on interface $WAN6_INTERFACE"
                fi
        fi
 
        exit 0
}
EOF


# 5. Make the script executable and enable it    #修改权限，并生效
chmod +x /etc/init.d/nat6
/etc/init.d/nat6 enable


# 6. In addition, you may now disable the default firewall rule "Allow-ICMPv6-Forward" since it's not needed when masquerading is enabled
uci set firewall.@rule["$(uci show firewall | grep 'Allow-ICMPv6-Forward' | cut -d'[' -f2 | cut -d']' -f1)"].enabled='0'
uci commit firewall


# 7. Modify /etc/sysctl.conf. If entries not exist, add them. 
# It's about to receive broadcasts and enable IPv6 transfer.
# NOTICE: The newest 18.06.1 doesn't have net.ipv6.conf.default.forwarding and net.ipv6.conf.all.forwarding,
#         so I have to attach them.
#
# 7.修改/etc/sysctl.conf，把文件中相关内容改为以下内容，没有的话就添加，大概说接收广播并开启ipv6转发
# 注意：最新的18.06.1中没有net.ipv6.conf.default.forwarding和net.ipv6.conf.all.forwarding，需在文件末尾额外添加之
touch /etc/sysctl.conf

a=$(sed -n '/net.ipv6.conf.default.forwarding/=' /etc/sysctl.conf)
if [ ! "$a" ]; then
	echo "net.ipv6.conf.default.forwarding=2" >> /etc/sysctl.conf
else
	sed -i "${a}d; $((a-1))a net.ipv6.conf.default.forwarding=2" /etc/sysctl.conf
fi

a=$(sed -n '/net.ipv6.conf.all.forwarding/=' /etc/sysctl.conf)
if [ ! "$a" ]; then
	echo "net.ipv6.conf.all.forwarding=2" >> /etc/sysctl.conf
else
	sed -i "${a}d; $((a-1))a net.ipv6.conf.all.forwarding=2" /etc/sysctl.conf
fi

a=$(sed -n '/net.ipv6.conf.default.accept_ra/=' /etc/sysctl.conf)
if [ ! "$a" ]; then
	a=$(sed -n '/net.ipv6.conf.all.forwarding/=' /etc/sysctl.conf)
	sed -i "${a}a net.ipv6.conf.default.accept_ra=2" /etc/sysctl.conf
else
	sed -i "${a}d; $((a-1))a net.ipv6.conf.default.accept_ra=2" /etc/sysctl.conf
fi

a=$(sed -n '/net.ipv6.conf.all.accept_ra/=' /etc/sysctl.conf)
if [ ! "$a" ]; then
	a=$(sed -n '/net.ipv6.conf.default.accept_ra/=' /etc/sysctl.conf)
	sed -i "${a}a net.ipv6.conf.all.accept_ra=2" /etc/sysctl.conf
else
	sed -i "${a}d; $((a-1))a net.ipv6.conf.all.accept_ra=2" /etc/sysctl.conf
fi


# 8. Add transfer rules to firewall.
# 8. 加入转发规则，编辑/etc/firewall.user，或路由器界面防火墙规则里加上
echo "ip6tables -t nat -I POSTROUTING -s $(uci get network.globals.ula_prefix) -j MASQUERADE" >> /etc/firewall.user
/etc/init.d/firewall restart



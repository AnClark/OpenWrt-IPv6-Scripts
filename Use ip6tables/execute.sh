#!/bin/bash
# �����������Զ��� IPv6 ���ýű� operation.sh ���͵�·����������
# ʹ��ǰ���Ƚ��·���IP��ַ�޸�Ϊ��·���������ص�ַ
# This batch file will automatically send operation.sh to your route, then run.
# Change the following IP address to your actual gateway address.

scp operation.sh root@192.168.1.1:/tmp/
ssh root@192.168.1.1 "chmod +x /tmp/install.sh; sh /tmp/operation.sh"

#!/bin/bash
# �����������Զ��� IPv6 ���ýű�operation.sh
# ʹ��ǰ���Ƚ��·���IP��ַ�޸�Ϊ��·���������ص�ַ
scp operation.sh root@192.168.1.1:/tmp/
ssh root@192.168.1.1 "chmod +x /tmp/install.sh; sh /tmp/operation.sh"

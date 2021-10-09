#!/usr/bin/env python3
import socket
import time

test_services = {'drive.google.com':'','mail.google.com':'','google.com':''}
while 1==1:
    for srv, old_ip in test_services.items():
        current_ip = socket.gethostbyname(srv)
        if old_ip == '':
            test_services[srv] = current_ip
        elif old_ip != current_ip:
            print (' '.join(['[ERROR]',srv,'IP mismatch:',old_ip,current_ip]))
            test_services[srv] = current_ip
        print (' - '.join([srv, current_ip]))
        time.sleep(1)
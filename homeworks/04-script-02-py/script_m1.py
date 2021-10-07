#!/usr/bin/env python3

import os

bash_command = ["cd ~/devops-netology", "git status"]
fullPath = os.popen(bash_command[0]+' && pwd').read()    # определим полный путь к директории
result_os = os.popen(' && '.join(bash_command)).read()
#is_change = False  # это нам тоже не понадобится
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = '/'.join([fullPath.replace('\n',''), result.replace('\tmodified:   ', '')])
        print(prepare_result)
#        break    # убираем чтобы скрипт показывал все найденные modified
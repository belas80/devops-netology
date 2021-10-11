# 4.3. Языки разметки JSON и YAML  
1. Исправление ошибок JSON
    ```json
    {
        "info" : "Sample JSON output from our service",
        "elements" : [
            {
              "name" : "first",
              "type" : "server",
              "ip" : "71.75.22.43"
            },
            {
              "name" : "second",
              "type" : "proxy",
              "ip" : "71.78.22.43"
            }
        ]
    }
    ```
2. Добавление возможности записи JSON и YAML файлов, описывающих наши сервисы, в скрипт из предыдущего задания. Для этого буду использовать библиотеки `json` и `yaml`.  
   ```python
   #!/usr/bin/env python3
   import socket
   import time
   import json
   import yaml
   
   test_services = {'drive.google.com': '', 'mail.google.com': '', 'google.com': ''}
   while True:
       for srv, old_ip in test_services.items():
           current_ip = socket.gethostbyname(srv)
           if old_ip == '':
               test_services[srv] = current_ip
           elif old_ip != current_ip:
               print(' '.join(['[ERROR]', srv, 'IP mismatch:', old_ip, current_ip]))
               test_services[srv] = current_ip
           print(' - '.join([srv, current_ip]))
           time.sleep(1)
       with open('file.json', 'w') as jf, open('file.yaml', 'w') as yf:           # Открываем файл JSON и YAML на запись
           json.dump(test_services, jf, indent=4)   # Записываем в него dict в формате JSON
           yaml.dump(test_services, yf, explicit_start=True, explicit_end=True)     # Пишем тот же dict в YAML
   ```
   file.json
   ```json
   {
       "drive.google.com": "74.125.205.194",
       "mail.google.com": "64.233.164.19",
       "google.com": "74.125.205.113"
   }
   ```
   file.yaml
   ```yaml
   ---
   drive.google.com: 74.125.205.194
   google.com: 74.125.205.113
   mail.google.com: 64.233.164.19
   ...
   ```

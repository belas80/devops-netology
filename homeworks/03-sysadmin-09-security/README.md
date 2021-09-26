# 3.9. Элементы безопасности информационных систем  
1. Установка Apache2
   ```bash
   vagrant@vagrant:~$ sudo apt install apache2
   vagrant@vagrant:~$ systemctl status apache2
    ● apache2.service - The Apache HTTP Server
         Loaded: loaded (/lib/systemd/system/apache2.service; enabled; vendor preset: enabled)
         Active: active (running) since Sun 2021-09-26 17:04:06 UTC; 1min 1s ago
           Docs: https://httpd.apache.org/docs/2.4/
       Main PID: 3001 (apache2)
          Tasks: 55 (limit: 1112)
         Memory: 5.6M
         CGroup: /system.slice/apache2.service
                 ├─3001 /usr/sbin/apache2 -k start
                 ├─3002 /usr/sbin/apache2 -k start
                 └─3003 /usr/sbin/apache2 -k start
    
    Sep 26 17:04:06 vagrant systemd[1]: Starting The Apache HTTP Server...
    Sep 26 17:04:06 vagrant systemd[1]: Started The Apache HTTP Server.
   ```
   Включим модуль SSL
   ```bash
   vagrant@vagrant:~$ a2query -m | grep ssl
   vagrant@vagrant:~$ 
   vagrant@vagrant:~$ sudo a2enmod ssl 
   Considering dependency setenvif for ssl:
   Module setenvif already enabled
   Considering dependency mime for ssl:
   Module mime already enabled
   Considering dependency socache_shmcb for ssl:
   Enabling module socache_shmcb.
   Enabling module ssl.
   See /usr/share/doc/apache2/README.Debian.gz on how to configure SSL and create self-signed certificates.
   To activate the new configuration, you need to run:
     systemctl restart apache2
   
   vagrant@vagrant:~$ sudo systemctl restart apache2
   vagrant@vagrant:~$ a2query -m | grep ssl
   ssl (enabled by site administrator)
   ```
   Сгенерируем самоподписанный сертификат состоящий из закрытого ключа `my-selfsigned.key` и сертификата `my-selfsigned.crt`
   ```bash
   vagrant@vagrant:~$ sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/my-selfsigned.key -out /etc/ssl/certs/my-selfsigned.crt
   Generating a RSA private key
   .+++++
   ........+++++
   writing new private key to '/etc/ssl/private/my-selfsigned.key'
   -----
   You are about to be asked to enter information that will be incorporated
   into your certificate request.
   What you are about to enter is what is called a Distinguished Name or a DN.
   There are quite a few fields but you can leave some blank
   For some fields there will be a default value,
   If you enter '.', the field will be left blank.
   -----
   Country Name (2 letter code) [AU]:RU
   State or Province Name (full name) [Some-State]:Sverdlovskaya
   Locality Name (eg, city) []:Yekaterinburg
   Organization Name (eg, company) [Internet Widgits Pty Ltd]:MyCompany
   Organizational Unit Name (eg, section) []:IT
   Common Name (e.g. server FQDN or YOUR name) []:localhost
   Email Address []:belas80@gmail.com
   vagrant@vagrant:~$ 
   ```
   Создадим файл конфигурации нашего тестового сайта в папке `sites-available` следующего содержания
   ```bash
   vagrant@vagrant:~$ cat /etc/apache2/sites-available/my-site.conf 
   <VirtualHost *:443>
      ServerName localhost
      DocumentRoot /var/www/my-site
      SSLEngine on
      SSLCertificateFile /etc/ssl/certs/my-selfsigned.crt
      SSLCertificateKeyFile /etc/ssl/private/my-selfsigned.key
   </VirtualHost>
   ```
   Создадим директорию нашего тестового сайта и его страницу
   ```bash
   vagrant@vagrant:~$ sudo mkdir /var/www/my-site
   vagrant@vagrant:~$ sudo tee /var/www/my-site/index.html
   <h1>It worked!</h1>
   <h1>It worked!</h1>
   vagrant@vagrant:~$ cat /var/www/my-site/index.html 
   <h1>It worked!</h1>
   ```
   Включим наш новый сайт, протестируем и перезагрузим конфиг
   ```bash
   vagrant@vagrant:~$ sudo a2ensite my-site.conf 
   Enabling site my-site.
   To activate the new configuration, you need to run:
     systemctl reload apache2
   vagrant@vagrant:~$ sudo apache2ctl configtest 
   Syntax OK
   vagrant@vagrant:~$ sudo systemctl reload apache2.service 
   vagrant@vagrant:~$ 
   ```
   Наш сайт готов, осталось протестировать с клиента. Для этого пробросим порт в vagrant и зайдем на него через браузер
   ```bash
   config.vm.network "forwarded_port", guest: 443, host: 8443
   ```
   ![](img/https.png)
   Дополнительно сделаем редирект с 80 порта на 443, добавив в конфиг сайта `/etc/apache2/sites-available/my-site.conf` следующие строчки
   ```bash
   <VirtualHost *:80>
     ServerName localhost
     Redirect / https://localhost:8443/
   </VirtualHost>
   ```
   ![](img/redirect.png)
2. Проверим на TLS уязвимости произвольный сайт в интернете с помощью `testssl.sh`
   ```bash
      vagrant@vagrant:~/testssl.sh$ ./testssl.sh -U --sneaky https://ya.ru      
   ```
   ![](img/testssl.png)
   Утилита показала 4 уязвимости.
3. 
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
      
       Testing vulnerabilities 

       Heartbleed (CVE-2014-0160)                not vulnerable (OK), no heartbeat extension
       CCS (CVE-2014-0224)                       not vulnerable (OK)
       Ticketbleed (CVE-2016-9244), experiment.  not vulnerable (OK)
       ROBOT                                     not vulnerable (OK)
       Secure Renegotiation (RFC 5746)           supported (OK)
       Secure Client-Initiated Renegotiation     not vulnerable (OK)
       CRIME, TLS (CVE-2012-4929)                not vulnerable (OK)
       BREACH (CVE-2013-3587)                    potentially NOT ok, "gzip" HTTP compression detected. - only supplied "/" tested
                                                 Can be ignored for static pages or if no secrets in the page
       POODLE, SSL (CVE-2014-3566)               not vulnerable (OK)
       TLS_FALLBACK_SCSV (RFC 7507)              Downgrade attack prevention supported (OK)
       SWEET32 (CVE-2016-2183, CVE-2016-6329)    VULNERABLE, uses 64 bit block ciphers
       FREAK (CVE-2015-0204)                     not vulnerable (OK)
       DROWN (CVE-2016-0800, CVE-2016-0703)      not vulnerable on this host and port (OK)
                                                 make sure you don't use this certificate elsewhere with SSLv2 enabled services
                                                 https://censys.io/ipv4?q=26EB381642B07A05F7CA935101FC6492F91F7F0721995A8E577EDFB6723EBD1F could help you to find out
       LOGJAM (CVE-2015-4000), experimental      not vulnerable (OK): no DH EXPORT ciphers, no DH key detected with <= TLS 1.2
       BEAST (CVE-2011-3389)                     TLS1: ECDHE-RSA-AES128-SHA AES128-SHA DES-CBC3-SHA 
                                                 VULNERABLE -- but also supports higher protocols  TLSv1.1 TLSv1.2 (likely mitigated)
       LUCKY13 (CVE-2013-0169), experimental     potentially VULNERABLE, uses cipher block chaining (CBC) ciphers with TLS. Check patches
       Winshock (CVE-2014-6321), experimental    not vulnerable (OK)
       RC4 (CVE-2013-2566, CVE-2015-2808)        no RC4 ciphers detected (OK)
   ```
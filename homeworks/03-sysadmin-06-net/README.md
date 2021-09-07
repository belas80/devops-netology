# 3.6. Компьютерные сети, лекция 1
1. Запрос через телнет к сайту `stackoverflow.com` выдал HTTP код 301
    ```bash
   vagrant@vagrant:~$ telnet stackoverflow.com 80
   Trying 151.101.193.69...
   Connected to stackoverflow.com.
   Escape character is '^]'.
   GET /questions HTTP/1.0
   HOST: stackoverflow.com
   
   HTTP/1.1 301 Moved Permanently 
   cache-control: no-cache, no-store, must-revalidate
   location: https://stackoverflow.com/questions
   ...
   ```
   Этот код указывает на то, что запрошенный ресурс был окончательно (на постоянной основе) перемещен в URL указанный в поле `locaton`, т.е. в данном случае, было перенаправление на протокол HTTPS.
   
1. Тоже задание в браузере в консоли разработчика. И видим тот же ответ сервера `Status Code: 301 Moved Permanently`.
   ![](img/screen-net-1.png)
   Самый долгий запрос был `https://stackoverflow.com/`, обрабатывался `647 ms`
   ![](img/screen-net-2.png)
   
1. Узнаем свой адрес в интернете через терминал
   ![](img/screen-ip.png)
   
1. Мой IP принадлежит `LLC KOMTEHCENTR`. Автономная система `AS12668`.
   ![](img/screen-whois.png)
   
1. Мой пакет прошел через сеть `VirtualBox` 10.0.2.2, домашняя локальная сеть 192.168.1.1, сети моего провайдера `AS12668`, сети ПАО МТС (MTS PJSC) `AS8359` и далее пошли сети google `AS15169`.
   ![](img/screen-trace.png)
   
1. 
# 5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера  

## Задача 1

   Для реализации этой задачи заранее подготовил html файл с содержимым из задания и скопировал его в свой новый образ
   при билде. За основу взял официальный nginx образ. Докерфайл получился следующего содержания  
   ```bash
   vagrant@server2:~/nginx$ cat Dockerfile 
   FROM nginx
   
   COPY index.html /usr/share/nginx/html/
   vagrant@server2:~/nginx$ 
   ```
   Далее забилдил его  
   ```bash
   vagrant@server2:~/nginx$ docker build -t belas80/nginx .
   Sending build context to Docker daemon  3.072kB
   Step 1/2 : FROM nginx
    ---> 87a94228f133
   Step 2/2 : COPY index.html /usr/share/nginx/html/
    ---> d0e3cbddaff0
   Successfully built d0e3cbddaff0
   Successfully tagged belas80/nginx:latest
   
   vagrant@server2:~/nginx$ docker images
   REPOSITORY      TAG       IMAGE ID       CREATED             SIZE
   belas80/nginx   latest    d0e3cbddaff0   About an hour ago   133MB
   nginx           latest    87a94228f133   3 weeks ago         133MB
   vagrant@server2:~/nginx$ 
   ```
   Проверил что все работает запустив его командой `docker run -dp 8080:80 belas80/nginx`  
   ![](img/docker1.png)
   И запушил образ в hub.docker.com командой `docker push belas80/nginx`  
   Мой ответ в виде ссылки [https://hub.docker.com/r/belas80/nginx](https://hub.docker.com/r/belas80/nginx)  
   
## Задача 2  

   В подобном сценарии думаю возможны разные варианты. Все зависит от нагрузки. Для высоконагруженного монолитного java 
   веб-приложения, мне кажется больше подойдет физическая машина. Все остальное в принципе хорошо запустится в Docker 
   контейнерах.  
   
## Задача 3  

   ```bash
   # проверяем на хосте что папка пуста
   vagrant@server2:~$ ls data/
   
   # запускаем centos подключая папку data
   vagrant@server2:~$ docker run -di -v $(pwd)/data:/data centos
   f37db5623e26686119a305af4cbb404f9dd9189c295c9e37df44360632a08cbb
   
   # тоже самое для debian
   vagrant@server2:~$ docker run -di -v $(pwd)/data:/data debian
   408ebf944bd61259c7c2101dd26867709609ffcfd7323f29d507c9242992ecf5
   
   # смотрим что оба контейнера запущены
   vagrant@server2:~$ docker ps
   CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS              PORTS     NAMES
   408ebf944bd6   debian    "bash"        56 seconds ago       Up 55 seconds                 dreamy_haibt
   f37db5623e26   centos    "/bin/bash"   About a minute ago   Up About a minute             stoic_nash
   
   # подключаемся к первому, т.е. к centos и создаем пустой файл в папке /data
   vagrant@server2:~$ docker exec -it f37db5623e26 bash
   [root@f37db5623e26 /]# touch /data/centos_file
   [root@f37db5623e26 /]# ls /data/
   centos_file
   [root@f37db5623e26 /]# exit
   exit
   
   # cоздаем файл на хостовой машине
   vagrant@server2:~$ touch data/server2_file
   vagrant@server2:~$ ls data/
   centos_file  server2_file
   
   # проверяем что находится в папке /data второго контейнера debian
   vagrant@server2:~$ docker exec 408ebf944bd6 ls /data
   centos_file
   server2_file
   vagrant@server2:~$
   ```

## Задача 4

   
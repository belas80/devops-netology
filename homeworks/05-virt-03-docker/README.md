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

   В подобном сценарии думаю возможны разные варианты. Все зависит от нагрузки. Для Высоконагруженного монолитного java 
   веб-приложения, мне кажется больше подойдет физическая машина. Все остальное в принципе хорошо запустится в Docker 
   контейнерах.  
   
## Задача 3  

   
# 6.3. MySQL  

## Задача 1  

   Поднимаем инстанс MySQL (версию 8) и восстанавливаем бэкап. Так как в предоставленном бэкапе содержится БД `test_db`, 
   добавим ее заранее в `docker-compose.yml`, который получился следующего содержания:  
   ```yaml
   version: '3.1'
   
   services:
   
     db:
       image: mysql:8
       command: --default-authentication-plugin=mysql_native_password
       restart: always
       environment:
         MYSQL_ROOT_PASSWORD: example
         MYSQL_DATABASE: test_db
       volumes:
         - mysqldata:/var/lib/mysql
         - $PWD/backup:/backup
   volumes:
     mysqldata:
   ```
   Заходим в инстанс и восстанавливаем бэкап  
   ```bash
   belyaev@MacBook-Air-Aleksandr src % docker exec -it src_db_1 bash
   root@df67e2393748:/# mysql -p -D test_db < /backup/test_dump.sql 
   Enter password: 
   root@df67e2393748:/#    
   ```
   
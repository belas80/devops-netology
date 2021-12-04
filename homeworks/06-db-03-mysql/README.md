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
   Заходим в управляющую консоль `mysql`, цепляя нужную нам БД `mysql -p -D test_db` и смотрим статус  
   ```bash
   mysql> \s
   --------------
   mysql  Ver 8.0.27 for Linux on x86_64 (MySQL Community Server - GPL)
   
   Connection id:		16
   Current database:	test_db
   Current user:		root@localhost
   SSL:			Not in use
   Current pager:		stdout
   Using outfile:		''
   Using delimiter:	;
   Server version:		8.0.27 MySQL Community Server - GPL
   Protocol version:	10
   Connection:		Localhost via UNIX socket
   Server characterset:	utf8mb4
   Db     characterset:	utf8mb4
   Client characterset:	latin1
   Conn.  characterset:	latin1
   UNIX socket:		/var/run/mysqld/mysqld.sock
   Binary data as:		Hexadecimal
   Uptime:			10 min 15 sec
   
   Threads: 2  Questions: 38  Slow queries: 0  Opens: 144  Flush tables: 3  Open tables: 62  Queries per second avg: 0.061
   --------------
   ```
   Список таблиц нашей БД  
   ```bash
   mysql> show tables;
   +-------------------+
   | Tables_in_test_db |
   +-------------------+
   | orders            |
   +-------------------+
   1 row in set (0.08 sec)
   ```
   Количество записей с price > 300  
   ```bash
   mysql> select count(*) from orders where price>300;
   +----------+
   | count(*) |
   +----------+
   |        1 |
   +----------+
   1 row in set (0.00 sec)
   ```

## Задача 2  

   Создание пользователя `test` в БД c паролем `test-pass`  
   ```bash
   mysql> CREATE USER test IDENTIFIED WITH mysql_native_password BY 'test-pass'
       -> WITH MAX_QUERIES_PER_HOUR 100
       -> PASSWORD EXPIRE INTERVAL 180 DAY FAILED_LOGIN_ATTEMPTS 3
       -> ATTRIBUTE '{"lname": "Pretty", "fname": "James"}';
   Query OK, 0 rows affected (0.04 sec)   
   ```
   Предоставление привилегии пользователю `test` на операции SELECT базы `test_db`  
   ```bash
   mysql> GRANT SELECT ON test_db.* TO test;
   Query OK, 0 rows affected (0.03 sec)
   ```
   Результаты:  
   ```bash
   mysql> show grants for test;
   +-------------------------------------------+
   | Grants for test@%                         |
   +-------------------------------------------+
   | GRANT USAGE ON *.* TO `test`@`%`          |
   | GRANT SELECT ON `test_db`.* TO `test`@`%` |
   +-------------------------------------------+
   2 rows in set (0.00 sec)
   
   mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user = 'test'\G
   *************************** 1. row ***************************
        USER: test
        HOST: %
   ATTRIBUTE: {"fname": "James", "lname": "Pretty"}
   1 row in set (0.00 sec)
   ```

## Задача 3  

   `Engine` в таблице `orders` используется `InnoDB`. Это можно увидеть выполнив `show create table`  
   ```bash
   mysql> show create table orders\G
   *************************** 1. row ***************************
          Table: orders
   Create Table: CREATE TABLE `orders` (
     `id` int unsigned NOT NULL AUTO_INCREMENT,
     `title` varchar(80) NOT NULL,
     `price` int DEFAULT NULL,
     PRIMARY KEY (`id`)
   ) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
   1 row in set (0.00 sec)
    
   ```
   Поменяем `engine` на `MyISAM` и обратно, с помощью `alter table`. Результат времени выполнения и запросы в таблице 
   ниже  
   ```bash
   mysql> show profiles;
   +----------+------------+------------------------------------+
   | Query_ID | Duration   | Query                              |
   +----------+------------+------------------------------------+
   |        1 | 0.00199700 | show create table orders           |
   |        2 | 0.00154050 | show create table orders           |
   |        3 | 0.00705425 | show tables                        |
   |        4 | 0.40668725 | alter table orders engine = MyISAM |
   |        5 | 0.00094675 | show create table orders           |
   |        6 | 0.00089975 | select * from orders               |
   |        7 | 0.36670600 | alter table orders engine = InnoDB |
   |        8 | 0.00142050 | select * from orders               |
   +----------+------------+------------------------------------+
   8 rows in set, 1 warning (0.00 sec)   
   ```
   
## Задача 4  

   Файл `my.cnf` в соответсвии с  
   * Скорость IO важнее сохранности данных
   * Нужна компрессия таблиц для экономии места на диске
   * Размер буффера с незакомиченными транзакциями 1 Мб
   * Буффер кеширования 30% от ОЗУ
   * Размер файла логов операций 100  
   ```
   
   ```
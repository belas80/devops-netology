# 6.4. PostgreSQL  

## Задача 1  

   Подключение к БД PostgreSQL используя psql.  
   Управляющие команды:  
   * вывода списка БД - `\l`
     ```bash
     postgres=# \l
                                      List of databases
        Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
     -----------+----------+----------+------------+------------+-----------------------
      postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
      template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                |          |          |            |            | postgres=CTc/postgres
      template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
                |          |          |            |            | postgres=CTc/postgres
     (3 rows)          
     ```
   * подключения к БД - `\c`
     ```bash
     postgres=# \c postgres
     Password: 
     You are now connected to database "postgres" as user "postgres".
     postgres=#      
     ```
   * вывода списка таблиц - `\dt`
     ```bash
     postgres=# \dt
           List of relations
      Schema |    Name    | Type  |  Owner   
     --------+------------+-------+----------
      public | test_table | table | postgres
     (1 row)      
     ```
   * вывода описания содержимого таблиц `\d`
     ```bash
     postgres=# \d test_table
                Table "public.test_table"
      Column |     Type      | Collation | Nullable | Default 
     --------+---------------+-----------+----------+---------
      id     | integer       |           |          | 
      name   | character(20) |           |          |      
     ```
   * выхода из psql - `\q`  

## Задача 2  

   Создание БД `test_database`  
   ```bash
   root@27e0d303cdc5:/# psql -U postgres -c 'create database test_database;'
   CREATE DATABASE
   root@27e0d303cdc5:/# 
   ```
   Восстановление бэкапа БД в `test_database`  
   ```bash
   root@27e0d303cdc5:/# psql -U postgres -d test_database < /backups/test_dump.sql 
   SET
   SET
   
   ...
   
   COPY 8
    setval 
   --------
         8
   (1 row)
   
   ALTER TABLE
   root@27e0d303cdc5:/# 
   ```
   Проведение ANALYZE для сбора статистики по таблице  
   ```bash
   test_database=# analyze verbose orders;
   INFO:  analyzing "public.orders"
   INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
   ANALYZE
   test_database=#      
   ```
   Столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах - `title` со значением 16  
   ```bash
   test_database=# select attname, avg_width from pg_catalog.pg_stats where tablename = 'orders' order by avg_width desc;
    attname | avg_width 
   ---------+-----------
    title   |        16
    id      |         4
    price   |         4
   (3 rows)      
   ```
   
## Задача 3  

   Разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499)  
   SQL-транзакция для проведения данной операции:  
   ```bash
   begin;
   
   CREATE TABLE orders_1 (
       CHECK ( price > 499 )
   ) INHERITS (orders);
   
   CREATE TABLE orders_2 (
       CHECK ( price <= 499 )
   ) INHERITS (orders);
   
   CREATE INDEX orders_1_price ON orders_1 (price);
   CREATE INDEX orders_2_price ON orders_2 (price);
   
   CREATE OR REPLACE FUNCTION orders_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
       IF ( NEW.price > 499 ) THEN
           INSERT INTO orders_1 VALUES (NEW.*);
       ELSIF ( NEW.price <= 499 ) THEN
           INSERT INTO orders_2 VALUES (NEW.*);
       END IF;
       RETURN NULL;
   END;
   $$
   LANGUAGE plpgsql;
   
   CREATE TRIGGER insert_orders_trigger
       BEFORE INSERT ON orders
       FOR EACH ROW EXECUTE FUNCTION orders_insert_trigger();
   
   copy orders to '/backups/orders_data';
   delete from orders ;
   copy orders from '/backups/orders_data';
      
   commit;
   ```
   В транзакции мы создаем две новых таблицы с проверкой по прайсу и наследованием от родительской таблицы, добавляем 
   индексы по прайсу, создаем функцию, которая будет раскладывать данные по нужным таблицам и вызываем ее триггером, а 
   так же выгрузим данные, очистим таблицу и загрузим данные обратно, чтобы триггер сработал.  
   Изначальные данные  
   ```bash
   test_database=# select * from only orders;
    id |        title         | price 
   ----+----------------------+-------
     1 | War and peace        |   100
     2 | My little database   |   500
     3 | Adventure psql time  |   300
     4 | Server gravity falls |   300
     5 | Log gossips          |   123
     6 | WAL never lies       |   900
     7 | Me and my bash-pet   |   499
     8 | Dbiezdmin            |   501
   (8 rows)
   
   ```
   Результат  
   ```bash
   test_database=# select * from only orders;
    id | title | price 
   ----+-------+-------
   (0 rows)
   
   test_database=#    
   ```
   Таблица `orders` пустая, посмотрим на другие  
   ```bash
   test_database=# select * from only orders_1;
    id |       title        | price 
   ----+--------------------+-------
     2 | My little database |   500
     6 | WAL never lies     |   900
     8 | Dbiezdmin          |   501
   (3 rows)
   
   test_database=# select * from only orders_2;
    id |        title         | price 
   ----+----------------------+-------
     1 | War and peace        |   100
     3 | Adventure psql time  |   300
     4 | Server gravity falls |   300
     5 | Log gossips          |   123
     7 | Me and my bash-pet   |   499
   (5 rows)
   
   ```
   Триггер отработал и расставил данные по местам.  
   Изначально не всегда можно предугадать размеры таблиц, но в принципе, если бы было понимание что будет ОЧЕНЬ много 
   заказов :)  

## Задача 4  

   Бекап БД `test_database`  
   ```bash
   root@27e0d303cdc5:/# pg_dump -U postgres -d test_database > /backups/test_dump_shard.sql 
   root@27e0d303cdc5:/# 
   ```
   В бэкап-файл, чтобы добавить уникальность значения столбца `title`, добавил бы  
   ```
   ALTER TABLE ONLY public.orders_1
    ADD CONSTRAINT orders_1_title_key UNIQUE (title);
    
   ALTER TABLE ONLY public.orders_2
    ADD CONSTRAINT orders_2_title_key UNIQUE (title);
   ```
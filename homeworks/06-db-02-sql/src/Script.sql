create user test_admin_user password 'example';
grant all on table clients, orders to test_admin_user;
create user test_simple_user password 'example';
grant select, insert, update, delete on table clients, orders to test_simple_user;
revoke all on table clients from test_simple_user;
select grantee, table_name, privilege_type from information_schema.table_privileges where table_schema = 'public';

select * from pg_user;
SELECT rolname FROM pg_roles;

create database "test_db";
select datname from pg_database;

create table orders (
  id serial primary key, 
  order_name CHAR(20), 
  order_price int
 );

create table clients (
  id serial primary key, 
  FIO CHAR(20), 
  country CHAR(10), 
  order_id int references orders (id)
 );
create index coutry_index on clients (Country);
drop index client_id_index;
select * from clients;
drop table orders;
drop table clients;

select * from pg_catalog.pg_tables where schemaname = 'public';
select table_name, column_name, data_type from information_schema."columns" c where table_schema = 'public' order by table_name ;
select table_name from information_schema."tables" t where table_schema = 'public';
select * from pg_catalog.pg_indexes where schemaname = 'public';

insert into orders (order_name, order_price) values ('Шоколад', 10);
insert into orders (order_name, order_price) values ('Принтер', 3000);
insert into orders (order_name, order_price) values ('Книга', 500);
insert into orders (order_name, order_price) values ('Монитор', 7000);
insert into orders (order_name, order_price) values ('Гитара', 4000);

insert into clients (FIO, country) values ('Иванов Иван Иванович', 'USA');
insert into clients (FIO, country) values ('Петров Петр Петрович', 'Canada');
insert into clients (FIO, country) values ('Иоганн Себастьян Бах', 'Japan');
insert into clients (FIO, country) values ('Ронни Джеймс Дио', 'Russia');
insert into clients (FIO, country) values ('Ritchie Blackmore', 'Russia');

select * from orders;
select * from clients;
delete from orders;
delete from clients;

select count(*) from orders o;
select count(*) from clients c;

update clients set order_id = null where order_id notnull;

update clients set order_id = (SELECT id FROM orders WHERE order_name='Книга') where fio = 'Иванов Иван Иванович';
update clients set order_id = (SELECT id FROM orders WHERE order_name='Монитор') where fio = 'Петров Петр Петрович';
update clients set order_id = (SELECT id FROM orders WHERE order_name='Гитара') where fio = 'Иоганн Себастьян Бах';

SELECT * FROM clients WHERE order_id IN (SELECT id FROM orders WHERE order_name='Книга');

SELECT c.id, c.fio "ФИО", o.id "order_id", o.order_name "Заказ" FROM clients c INNER JOIN orders o ON o.id = c.order_id ;

VACUUM

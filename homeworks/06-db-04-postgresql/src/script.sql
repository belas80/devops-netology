explain analyze select * from orders o where price > 499 order by id asc;
select * from only orders o;
select * from orders_1 o ;
select * from orders_2 o ;
select table_name from information_schema."tables" t where table_schema = 'public';
alter table orders add constraint cname unique (title);
alter table orders_1 add unique (title);
alter table orders_2 add unique (title);
vacuum verbose

analyze verbose orders;

select attname, avg_width from pg_catalog.pg_stats where tablename = 'orders' order by avg_width desc;

CREATE UNIQUE INDEX orders_1_title ON orders_1 (price);
CREATE UNIQUE INDEX orders_2_title ON orders_2 (title);

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

CREATE RULE orders_insert_1 AS
ON INSERT TO orders WHERE
    ( price > 499 )
DO INSTEAD
    INSERT INTO orders_1 VALUES (NEW.*);
 
CREATE RULE orders_insert_2 AS
ON INSERT TO orders WHERE
    ( price <= 499 )
DO INSTEAD
    INSERT INTO orders_2 VALUES (NEW.*);
   
insert into orders values (1, 'War and peace', 100), (2, 'My little database', 500);
update orders set price = 600 where id = 1;

copy orders to '/backups/orders_data.csv' with csv;

INSERT INTO orders (title,price) VALUES
	 ('War and peace',100),
	 ('My little database',500),
	 ('Adventure psql time',300),
	 ('Server gravity falls',300),
	 ('Log gossips',123),
	 ('WAL never lies',900),
	 ('Me and my bash-pet',499),
	 ('Dbiezdmin',501);
	 
INSERT INTO orders (title,price) VALUES ('War and peace 3',200);
INSERT INTO orders (title,price) VALUES  ('WAL never lies 3',900);
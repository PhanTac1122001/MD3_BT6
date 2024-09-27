create database md3ss6b2;
use md3ss6b2;

create table users (
	id int auto_increment primary key,
    name varchar(100) not null,
    address varchar(255) not null,
    phone varchar(11) unique not null,
    dateOfBirth date not null,
    status bit(1)
);

create table products (
	id int auto_increment primary key,
    name varchar(100) not null,
    price double check (price > 0) not null,
    stock int check (stock >= 0) not null,
    status bit(1)
);

create table shopping_cart (
	id int auto_increment primary key,
    user_id int not null,
    foreign key (user_id) references users(id),
    product_id int not null,
    foreign key (product_id) references products(id),
    quantity int check (quantity >= 0) not null,
    amount double not null
);

insert into products(name, price, stock, status) value ('Dép tông', 1400, 15, 1);
insert into users (name, address, phone, dateOfBirth, status) value ('Nguyễn Trường Sơn','Hưng Yên','0987654321','2001-4-18',1);
insert into shopping_cart(user_id, product_id, quantity, amount) value (1, 1, 3, 2400);
-- drop procedure delete_shopping;
delimiter //
create procedure insert_shopping (IN user_id_in int, IN product_id_in int,IN quantity_in int,IN amount_in int)
begin 
	#declare exit handler for sqlexception rollback;
    declare newQuantity INT;
    start transaction;
    select stock into newQuantity from products where id = product_id_IN;
    IF(newQuantity < quantity_IN) then 
    rollback;
    signal sqlstate '45000' set message_text = 'Không đủ tiền';
	else
    insert shopping_cart(user_id, product_id, quantity, amount) values(user_id_in, product_id_in, quantity_in ,amount_in);
    commit;
     end if;
end//
delimiter ;
 call insert_shopping(1,1,15,4600);
 
 delimiter //
 create procedure delete_shopping(IN cart_id int)
 begin
	declare quantity_delete int;
	declare product_delete int;
    select quantity into quantity_delete from shopping_cart where id = cart_id;
    select product_id into product_delete from shopping_cart where id = cart_id;
	start transaction;
		delete from shopping_cart where id = cart_id;
		update products set stock = stock + quantity_delete where id = product_delete;
    commit;
end//
 select * from shopping_cart;
 select * from products;
 call delete_shopping(2);
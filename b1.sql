create database md3ss6b1;
use md3ss6b1;

create table users(
id int primary key auto_increment,
name varchar(100),
address varchar(255),
phone varchar(11),
dateOfBirth date,
status bit
);

create table products(
id int primary key auto_increment,
name varchar(100),
price double,
stock int,
status bit
);

create table shopping_cart(
id int primary key auto_increment,
user_id int not null,
product_id int not null,
quantity int,
amount double,
foreign key (user_id) references users(id),
foreign key (product_id) references products(id)
);

-- Tạo Trigger khi thay đổi giá của sản phẩm thì amount (tổng giá) cũng sẽ phải cập nhật lại
delimiter //
create trigger update_amount 
	after update 
    on products
    for each row
    begin
		update shopping_cart as sc join products as p on sc.product_id = old.id set sc.amount = new.price * sc.quantity;
    end//
insert into products(name, price, stock, status) value ('Dép tông', 1400, 15, 1);
insert into users (name, address, phone, dateOfBirth, status) value ('Phan Đình Tạc','Thái bình','0987654321','2001-12-1',1);
insert into shopping_cart(user_id, product_id, quantity, amount) value (1, 1, 3, 2400);
update products set price = 1300 where id = 1;
select * from shopping_cart;

-- Tạo trigger khi xóa product thì những dữ liệu ở bảng shopping_cart có chứa product bị xóa thì cũng phải xóa theo
DROP TRIGGER IF EXISTS delete_product;
delimiter //
create trigger delete_product
after delete
on products
for each row
begin
	delete from shopping_cart where product_id=old.id;
end //

delete from products where id=1;

-- Khi thêm một sản phẩm vào shopping_cart với số lượng n thì bên product cũng sẽ phải trừ đi số lượng n
delimiter //
create trigger update_product_and_add_cart
before update
on shopping_cart
for each row
begin
	declare current_stock int;
	select stock into current_stock from products
    where id = old.product_id;
	if (new.quantity > old.quantity) and (current_stock - (new.quantity - old.quantity) < 0) then
        signal sqlstate '45000' set message_text = 'Vượt quá số lượng trong kho';
    end if;
end //

delimiter //

create trigger after_update
after update on shopping_cart
for each row
begin
  if(new.quantity < old.quantity)
  then update products set stock = stock + (old.quantity - new.quantity);
  elseif (new.quantity > old.quantity)
  then update products set stock = stock - (new.quantity-old.quantity);
  end if;
end//
delimiter ;
update shopping_cart set quantity = 4 where id = 2;


select user();

show grants for root@localhost;

create user 'linhdev'@'localhost' identified by "linhdev";

create database personal_manager;

use personal_manager;

create table employees(
	id int not null auto_increment,
	name varchar(20) not null,
	age int not null,
	cccd char(30) not null,
	primary key(id)
);

grant create, insert, select on personal_manager.employees to 'linhdev'@'localhost';

switch to 'linhdev':

insert into employees (name, age, cccd) values 
("linh", 18, "273498273"),
("tuan", 19, "732948723");

update employees set
age = 22 
where name like "linh";

=> permisson denied!

switch to 'root' => success

revoke select on personal_manager.employees from 'linhdev'@'localhost';

switch to 'linhdev':

select * from employees;

=> permisson denied!

Trường hợp chồng lấn quyền:
1. grant create, insert, select on personal_manager.employees to 'linhdev'@'localhost';
2. grant all privileges on personal.* to 'linhdev'@'localhost';
3. revoke INSERT on personal_manager.employees from 'linhdev'@'localhost';
-> Sau khi chạy lần lượt 3 câu query như trên: 'linhdev' vẫn có quyền truy cập tất cả đối với db personal_manager.
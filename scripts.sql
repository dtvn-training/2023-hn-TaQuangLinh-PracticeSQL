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


View:
create view employees_view as
	select name, age from employees 
	where age >= 18;

Update view:
create or replace view employees_view as 
	select name, age from employees
	where age >= 20;

show view:
show full tables where table_type = 'view';

Drop view:
drop view employees_view;

Index:
- Các lệnh insert và update sẽ mất thời gian hơn trên các bảng được đánh index, trong khi các lệnh select sẽ nhanh hơn. Lý do là vì trong khi insert và update db cũng phải thay đổi cập nhật các giá trị index.
- Simple Index:
	+ Tồn tại bản sao các giá trị trong một bảng.
	+ create index index_name
	  on table_name (column1 <DESC>, column2,...)
- Unique Index:
	+ Hai hàng không thể có cùng giá trị chỉ mục. 
	+ create unique index index_name
	  on table_name (column1 <DESC>, column2,...)
- DESC: lập chỉ mục các giá trị trong cột theo thứ tự giảm dần.

create unique index cccd_employees
on employees (cccd DESC);

show indexes from employees;

ALTER:
- alter database:
	+ alter database personal_manager character set = ascii;
	+ select @@character_set_database;
- alter table:
	+ add column: 
		alter table employees 
		add (
			email varchar(100),
			code char(11) not null
		);
	+ modify:
		alter table employees
		modify email varchar(50) not null;
	+ add index:
		alter table employees
		add index code_employees (code);
	+ add foreign key:
		alter table timekeeping
		add constraint fk_employee_timekeeping
		foreign key (employee_id) references employees(id);
	+ add drop column:
		alter table employees
		drop column code;
	+ rename of table: 
		alter table employees
		rename to nhan_vien;
	+ rename of column:
		alter table employees
		rename column name to ho_ten;
create table timekeeping (
	id int auto_increment,
	time datetime not null,
	employee_id int not null,
	primary key (id)
);

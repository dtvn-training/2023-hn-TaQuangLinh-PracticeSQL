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
	+ drop column:
		alter table employees
		drop column email;
create table timekeeping (
	id int auto_increment,
	time datetime not null,
	employee_id int not null,
	primary key (id)
);

TRUNCATE:
- delete all data.
- truncate table employees;

Phân biệt truncate và delete:
- Truncate: Xóa tất cả dữ liệu của bảng chứ không thể dùng cho từng record. Khi chạy lệnh, SQL sẽ xóa hết dữ liệu của bảng và reset transaction log.
- Delete: xóa dữ liệu trong bảng và giữ lại data trong transaction log.

7 stages of sql order of execution:
1. From/Join
2. Where
3. Group by
4. Having
5. Select
6. Order by
7. Limit/Offset


TCL:
start transaction;
delete from employees;
rollback;

start transaction;
delete from employees where id = 3;
savepoint sp1;
delete from employees where id = 4;
rollback to savepoint sp1;
commit;

Tính cô lập:
Read Uncommitted: TA đọc được kết quả của TB khi mà chưa commit.

set transaction isolation level read uncommitted
start transaction;
...
commit;

=> problem: read dirty
=> Buggy

Read Committed: Chỉ đọc dữ liệu đã được commit.

set transaction isolation level read committed
start transaction;
...
commit;

Example:

set transaction isolation level read committed

select * from account_balance where account_number = 2;
-- do something (before T1 commit, balance[2] = 150)
select * from account_balance where account_number = 2;
-- Sometimes, it does wrong here (after T1 commit, balance[2] = 160)

commit;

Repeatable Read: Trả về cùng một kết quả sau các lần đọc.

set transaction isolation level repeatable read; (default isolation)

Trước khi T2 commit thì các lần đọc là như nhau kể cả khi T1 trước và sau khi commit.
=> phantom read: Khi thực hiện query dạng range (between), có thể sẽ xuất hiện thêm/mất row do một transaction khác thêm/bớt row trong cái range đó và commit.

Serializable:
- solves the phantom read.
- Thực hiện cơ chế lock để đảm bảo thứ tự.
set transaction isolation level serializable;

Locking:

Shared: Allow to read but lock to write
Exclusive: Lock to read and write.

S * S = success
S * X = reject
X * S = reject
X * X = reject

select * from account_balance where account_number = 4 for share;


display info:   select thread_id, index_name, lock_type, lock_mode, lock_status, lock_data
		from performance_schema.data_locks
		where object_name = 'account_balance';

Global Lock:
Table Lock:
Row Level:

SQL Execution:

1. send SQL statement: 
*Relational Engine
2. Command Parser: Build ra cây truy vấn ->
3. Query Optimizer: Đưa ra các chiến lược thực thi, tính toán và đưa ra chiến lược có cost thấp nhất và xóa các plan còn lại.
4. Query Executor: Thao tác với storage engine
*Storage Engine: Thực hiện query
5. Access Methods: Nhận được query và phân biệt read query và write query
- Read query: Forward sang Buffer Manager, nếu không có thì sẽ lấy data dưới disk
- Write query: Forward sang Transaction Manager, quản lý các tính chất của ACID, nếu có yêu cầu Lock thì sẽ gọi xuống Lock Manager.

SQL execution order:
1. From
2. Join
3. On
4. Where
5. Group by
6. Having
7. Select
8. Order by
9. Limit

Execution Plan:
- Là một mô tả từng bước một mà DB thực hiện query -> đánh giá DB thực hiện nhanh chậm ở đâu.
EXPLAIN: Lấy các thông tin cơ bản, dừng lại ở bước chọn ra plan có cost nhỏ nhất (Query Optimizer)
ANALYZE: Lấy các thông tin tiết, thực hiện đầy đủ các bước.
BUFFERS: Thông tin của cache hit or miss. (display)
FORMAT JSON: reformat output
Example: EXPAIN (ANALYZE, BUFFERS, FORMAT JSON) <Query>

Những kiểu access vào dữ liệu:
- Sequetial Scan: Quét toàn bộ bảng dữ liệu gốc và ko dùng index.
- Index scan: Sử dụng index để scan.
- Index only scan: Chỉ lấy dữ liệu ở trong index.
- Bitmap Index Scan + Bitmap Heap Scan: (postgres) Do cách tổ chức dữ liệu của postgre và mysql khác nhau, Sử dụng index -> gen ra cấu trúc dữ liệu là bitmap -> kết hợp được nhiều index với nhau.

Index name: 
Index Cond: điều kiện trên index
Estimate fields: Ước tính
startup cost: Mất bao nhiêu chi phí để lấy được record đầu tiên.
total cost: Chi phí của cả quá trình để lấy tất cả record.
Plan row: Dự kiến có bao nhiều record được trả ra trong operation
Plan width: 
Actual value Fields: thông số thực
Actual Startup Time: Thời gian để lấy được record đầu tiên.
Actual Total Time: Tổng thời gian để lấy tất cả record.
Actual Rows: Số rows được trả về
Actual Loops: Số lần thực hiện operation.

Buffer fields:
Shared Hit Blocks: số blocks được đọc trong buffer.





















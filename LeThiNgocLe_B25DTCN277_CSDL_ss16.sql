create database CarRentalManagement;
use CarRentalManagement;

create table Vehicles (
	vehicle_id varchar(5) primary key,
    vehicle_name varchar(50) not null,
    vehicle_type varchar(50) not null,
    daily_rate decimal(10, 2) check(daily_rate > 0),
    status varchar(50) default 'Available'
);  

create table Clients (
	 client_id varchar(5) primary key,
     full_name varchar(50) not null,
     citizen_id varchar(20) unique not null,
     phone_number int not null,
     register_date datetime default current_timestamp
);

create table Rentals (
	rental_id varchar(5) primary key,
    client_id varchar(5) not null,
    vehicle_id varchar(5) not null,
    start_date date not null,
    expected_return_date date not null,
    total_amount decimal(18, 2) check(total_amount > 0),
    status varchar(50) default 'Active',
    foreign key (client_id) references Clients(client_id),
	foreign key (vehicle_id) references Vehicles(vehicle_id)
);

create table Payments (
	payment_id varchar(5) primary key,
    rental_id varchar(5) not null,
    payment_date date not null,
    amount decimal(18, 2) check(amount > 0),
    method varchar(50),
    foreign key (rental_id) references Rentals(rental_id)
);

create table Maintenance_Logs (
	log_id int primary key auto_increment,
    vehicle_id varchar(5) not null,
    description varchar(50) not null,
    maintenance_date date not null,
    cost decimal(10, 2) check(cost > 0),
    foreign key (vehicle_id) references Vehicles(vehicle_id)
);

insert into Vehicles(vehicle_id, vehicle_name, vehicle_type, daily_rate, status)
values ('V001', 'Toyota Vios', 'Sedan', 700000, 'Available'),
('V002', 'Hyundai Tucson', 'SUV', 1200000, 'Rented'),
('V003', 'Ford Transit', 'Van', 1800000, 'Available'),
('V004', 'Mazda CX5', 'SUV', 1300000, 'Maintenance'),
('V005', 'Kia Morning', 'Hatchback', 500000, 'Available');

insert into Clients (client_id, full_name, citizen_id, phone_number, register_date)
values ('C001', 'Nguyen Van An', '001199900001', '0901112223', '2024-01-15'),
('C002', 'Tran Thi Bich', '001198800002', '0988877766', '2024-06-20'),
('C003', 'Le Hoang Nam', '001200000003', '0903334445', '2025-03-10'),
('C004', 'Nguyen Minh Duc', '001199500004', '0355556667', '2023-12-05'),
('C005', 'Pham Thu Ha', '001200100005', '0779998881', '2026-01-01');

insert into Rentals (rental_id, client_id, vehicle_id, start_date, expected_return_date, total_amount, status)
values ('R001', 'C001', 'V002', '2025-01-10', '2025-01-15', 6000000, 'Active'),
('R002', 'C002', 'V001', '2025-02-05', '2025-02-08', 2100000, 'Completed'),
('R003', 'C003', 'V003', '2025-03-12', '2025-03-15', 5400000, 'Completed'),
('R004', 'C004', 'V005', '2024-12-20', '2024-12-22', 1000000, 'Completed'),
('R005', 'C005', 'V004', '2026-01-05', '2026-01-10', 6500000, 'Cancelled');

insert into Payments (payment_id, rental_id, payment_date, amount, method)
values ('P001', 'R002','2025-02-08', 2100000, 'Cash'),
('P002', 'R003','2025-02-08', 2100000, 'Cash'),
('P003', 'R004','2025-02-08', 2100000, 'Cash'),
('P004', 'R001','2025-02-08', 2100000, 'Cash'),
('P005', 'R005','2025-02-08', 2100000, 'Cash');

insert into Maintenance_Logs (log_id, vehicle_id, description, maintenance_date, cost)
values (1, 'V004', 'Bao duong dong co', '2025-12-01', 1500000),
(2, 'V001', 'Thay dau may', '2023-11-15', 300000),
(3, 'V003', 'Kiem tra phanh', '2024-05-20', 700000),
(4, 'V005', 'Ve sinh noi that', '2023-10-10', 200000),
(5, 'V002', 'Sua dieu hoa', '2025-01-05', 900000);

-- Phan 1:
-- cau update 
update Vehicles
set daily_rate = daily_rate * 1.1
where vehicle_type = 'SUV';

-- cau delete
delete from Maintenance_Logs
where cost < 500000
and maintenance_date < '2024-01-01';

-- Phan 2:
-- cau 1:
-- liet ke danh sach 
select start_date
from Rentals
where start_date between '2025-01-01' and '2025-03-31';

-- cau 2: 
select full_name, phone_number
from Clients
where full_name like 'Nguyen%'
and year(register_date) < 2025;

-- cau3: 
select *
from Payments
order by amount desc
limit 4 offset 2;

-- Phan 3:
-- cau 1: 
select v.vehicle_name, v.vehicle_type, r.start_date, r.total_amount
from Vehicles v
left join Rentals r
on v.vehicle_id = r.vehicle_id;

-- cau 2: 
select c.client_id, c.full_name, sum(p.amount) as total_paid
from Clients c
join Rentals r
on c.client_id = r.client_id
join Payments p
on r.rental_id = p.rental_id
group by c.client_id, c.full_name
having sum(p.amount) > 20000000;

-- cau 3
select v.vehicle_type, count(*) as rental_count
from Rentals r
join Vehicles v
on r.vehicle_id = v.vehicle_id
group by v.vehicle_type
order by rental_count desc
limit 1;

-- Phan 4: 
-- cau 1: 
create index idx_rental_dates
on Rentals(start_date, expected_return_date);

-- cau 2: 

-- Phan 5: vw_vehicle_status_summary
-- cau 1:
delimiter // 
create trigger trg_after_payment_insert
after insert on Payments
for each row
begin
    update Rentals
    set status = 'Completed'
    where rental_id = new.rental_id;

    update Vehicles
    set status = 'Available'
    where vehicle_id = (
        select vehicle_id
        from Rentals
        where rental_id = new.rental_id
    );
end //
delimiter ;

-- cau2 


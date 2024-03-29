create table reference_types (
    reference_type_id integer primary key,
    type_label varchar(50) default null,
    abbreviation varchar(50) default null,
    description varchar(50) default null
);

create table reference_codes (
    reference_type_id int,
    reference_code int not null,
    code_label varchar(50) default null,
    abbreviation varchar(50) default null,
    description varchar(50) default null,
    primary key (reference_type_id, reference_code)
);

create table products (
    id int not null primary key,
    name varchar(50) default null,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

create table tariffs (
    tariff_id int not null,
    start_date date not null,
    amount integer(11) default null,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    primary key (tariff_id, start_date)
);

create table product_tariffs (
    product_id int not null,
    tariff_id int not null,
    tariff_start_date date not null,
    primary key (product_id, tariff_id, tariff_start_date)
);

create table suburbs (
    city_id int identity(1,1) not null,
    suburb_id int identity(1,1) not null,
    name varchar(50) not null,
    primary key (city_id, suburb_id)
);

create table streets (
    id integer not null primary key autoincrement,
    city_id int not null,
    suburb_id int not null,
    name varchar(50) not null
);

create table users (
    id integer not null primary key autoincrement,
    name varchar(50) not null
);

create table moderators (
    id integer not null primary key
);

create table admins (
    id integer not null primary key
);

create table articles (
    id integer not null primary key autoincrement,
    name varchar(50) not null
);

create table readings (
    id integer not null primary key autoincrement,
    user_id int not null,
    article_id int not null,
    rating int not null
);

create table groups (
    id integer not null primary key autoincrement,
    name varchar(50) not null
);

create table memberships (
    user_id int not null,
    group_id int not null,
    primary key (user_id, group_id)
);

create table membership_statuses (
    id integer not null primary key autoincrement,
    user_id int not null,
    group_id int not null,
	status varchar(50) not null
);

create table departments (
    id integer not null,
    location_id integer not null,
    primary key (id, location_id)
);

create table employees (
    id integer not null primary key autoincrement,
    department_id integer null,
    location_id integer null,
    name varchar(50) not null
);

create table comments (
    id integer not null primary key autoincrement,
    article_id int not null,
    person_id int not null,
    person_type varchar(100) not null
);

create table restaurants (
	franchise_id integer not null,
	store_id integer not null,
	name varchar(100),
  lock_version integer default 0,
	primary key (franchise_id, store_id)
);

create table restaurants_suburbs (
	franchise_id integer not null,
	store_id integer not null,
	city_id integer not null,
	suburb_id integer not null
);

create table dorms (
	id integer not null primary key autoincrement
);

create table rooms (
	dorm_id integer not null,
	room_id integer not null,
	primary key (dorm_id, room_id)
);

create table room_attributes (
	id integer not null primary key autoincrement,
	name varchar(50)
);

create table room_attribute_assignments (
	dorm_id integer not null,
	room_id integer not null,
	room_attribute_id integer not null
);

create table staff_rooms (
    dorm_id integer not null,
    room_id integer not null,
    primary key (dorm_id, room_id)
);

create table staff_room_keys (
    dorm_id integer not null,
    room_id integer not null,
    key_no varchar(50) not null,
    primary key (dorm_id, room_id)
);

create table students (
	id integer not null primary key autoincrement
);

create table room_assignments (
	student_id integer not null,
	dorm_id integer not null,
	room_id integer not null	
);

create table capitols (
  country text not null,
  city text not null,
  primary key (country, city)
);

create table products_restaurants (
  product_id integer not null,
	franchise_id integer not null,
	store_id integer not null
);

create table employees_groups (
  employee_id integer not null,
  group_id integer not null
);
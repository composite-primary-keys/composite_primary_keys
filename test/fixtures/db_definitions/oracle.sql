create table reference_types (
  reference_type_id  number(11)    primary key,
  type_label         varchar2(50)  default null,
  abbreviation       varchar2(50)  default null,
  description        varchar2(50)  default null
);

create sequence reference_types_seq
  start with 1000;

create table reference_codes (
  reference_type_id  number(11),
  reference_code     number(11),
  code_label         varchar2(50)  default null,
  abbreviation       varchar2(50)  default null,
  description        varchar2(50)  default null,
  constraint reference_codes_pk primary key(reference_type_id, reference_code)
);

create table products (
  id    number(11)    primary key,
  name  varchar2(50)  default null
);

create sequence products_seq
  start with 1000;

create table tariffs (
  tariff_id   number(11),
  start_date  date,
  amount      number(11)  default null,
  constraint tariffs_pk primary key(tariff_id, start_date)  
);

create table product_tariffs (
  product_id         number(11),
  tariff_id          number(11),
  tariff_start_date  date,
  constraint product_tariffs_pk primary key(product_id, tariff_id, tariff_start_date)
);

create table suburbs (
  city_id    number(11),
  suburb_id  number(11),
  name       varchar2(50)  not null,
  constraint suburbs_pk primary key(city_id, suburb_id)
);

create table streets (
  id         number(11)    primary key,
  city_id    number(11)    not null,
  suburb_id  number(11)    not null,
  name       varchar2(50)  not null
);

create sequence streets_seq
  start with 1000;

create table users (
  id    number(11)    primary key,
  name  varchar2(50)  not null
);

create sequence users_seq
  start with 1000;

create table articles (
  id    number(11)    primary key,
  name  varchar2(50)  not null
);

create sequence articles_seq
  start with 1000;


create table readings (
  id          number(11)  primary key,
  user_id     number(11)  not null,
  article_id  number(11)  not null,
  rating      number(11)  not null
);

create sequence readings_seq
  start with 1000;


create table groups (
  id    number(11)    primary key,
  name  varchar2(50)  not null
);

create sequence groups_seq
  start with 1000;


create table memberships (
  user_id   number(11)  not null,
  group_id  number(11)  not null,
  constraint memberships_pk primary key(user_id, group_id)
);

create table membership_statuses (
  id        number(11)    primary key,
  user_id   number(11)    not null,
  group_id  number(11)    not null,
  status    varchar2(50)  not null
);

create sequence membership_statuses_seq
  start with 1000;

CREATE TABLE departments (
  department_id number(11) NOT NULL,
  location_id number(11) NOT NULL,
  constraint departments_pk primary key(department_id, location_id)
);

CREATE TABLE employees (
 id number(11) NOT NULL primary key,
 department_id number(11) DEFAULT NULL,
 location_id number(11) DEFAULT NULL 
);

create sequence employees_seq
  start with 1000;

CREATE TABLE comments (
	id number(11) NOT NULL PRIMARY KEY,
	person_id varchar(100) DEFAULT NULL,
	person_type varchar(100) DEFAULT NULL
);

create sequence comments_seq
  start with 1000;

CREATE TABLE hacks (
 name varchar(50) NOT NULL PRIMARY KEY
);

create table kitchen_sinks (
	id_1 number(11) not null,
	id_2 number(11) not null,
	a_date date,
	a_string varchar(100),
	constraint kitchen_sinks_pk primary key(id_1, id_2)
);

create table restaurants (
	franchise_id number(11) not null,
	store_id number(11) not null,
	name varchar(100),
	constraint restaurants_pk primary key (franchise_id, store_id)
);

create table restaurants_suburbs (
	franchise_id number(11) not null,
	store_id number(11) not null,
	city_id number(11) not null,
	suburb_id number(11) not null
);
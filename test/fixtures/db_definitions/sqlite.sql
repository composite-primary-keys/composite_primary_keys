CREATE TABLE reference_types (
  reference_type_id INTEGER PRIMARY KEY,
  type_label varchar(50) default NULL,
  abbreviation varchar(50) default NULL,
  description varchar(50) default NULL
);

CREATE TABLE reference_codes (
  reference_type_id int(11) NOT NULL,
  reference_code int(11) NOT NULL,
  code_label varchar(50) default NULL,
  abbreviation varchar(50) default NULL,
  description varchar(50) default NULL,
  PRIMARY KEY  (reference_type_id,reference_code)
);

CREATE TABLE products (
  id int(11) NOT NULL PRIMARY KEY,
  name varchar(50) default NULL
);

CREATE TABLE tariffs (
  tariff_id int(11) NOT NULL,
  start_date date NOT NULL,
  amount integer(11) default NULL,
  PRIMARY KEY  (tariff_id,start_date)
);

CREATE TABLE product_tariffs (
  product_id int(11) NOT NULL,
  tariff_id int(11) NOT NULL,
  tariff_start_date date NOT NULL,
  PRIMARY KEY  (product_id,tariff_id,tariff_start_date)
);

CREATE TABLE suburbs (
  city_id int(11) NOT NULL,
  suburb_id int(11) NOT NULL,
  name varchar(50) NOT NULL,
  PRIMARY KEY  (city_id,suburb_id)
);

CREATE TABLE streets (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  city_id int(11) NOT NULL,
  suburb_id int(11) NOT NULL,
  name varchar(50) NOT NULL
);

CREATE TABLE users (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name varchar(50) NOT NULL
);

CREATE TABLE articles (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name varchar(50) NOT NULL
);

CREATE TABLE readings (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  user_id int(11) NOT NULL,
  article_id int(11) NOT NULL,
  rating int(11) NOT NULL
);

CREATE TABLE groups (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  name varchar(50) NOT NULL
);

CREATE TABLE memberships (
  user_id int NOT NULL,
  group_id int NOT NULL,
  PRIMARY KEY  (user_id,group_id)
);

CREATE TABLE membership_statuses (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  user_id int NOT NULL,
  group_id int NOT NULL,
	status varchar(50) NOT NULL
);

CREATE TABLE departments (
  department_id INTEGER NOT NULL,
  location_id INTEGER NOT NULL,
  PRIMARY KEY (department_id, location_id)
);

CREATE TABLE employees (
 id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
 department_id INTEGER NULL,
 location_id INTEGER NULL
);

CREATE TABLE comments (
	id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	person_id varchar(100) NULL,
	person_type varchar(100) NULL
);

CREATE TABLE hacks (
 name varchar(50) NOT NULL PRIMARY KEY
);

create table kitchen_sinks (
	id_1 integer not null,
	id_2 integer not null,
	a_date date,
	a_string varchar(100),
	primary key (id_1, id_2)
);

create table restaurants (
	franchise_id integer not null,
	store_id integer not null,
	name varchar(100),
	primary key (franchise_id, store_id)
);

create table restaurants_suburbs (
	franchise_id integer not null,
	store_id integer not null,
	city_id integer not null,
	suburb_id integer not null
);
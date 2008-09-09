CREATE SEQUENCE public.reference_types_seq START 100;
CREATE TABLE reference_types (
  reference_type_id int DEFAULT nextval('public.reference_types_seq'),
  type_label varchar(50) default NULL,
  abbreviation varchar(50) default NULL,
  description varchar(50) default NULL,
  PRIMARY KEY  (reference_type_id)
);

CREATE TABLE reference_codes (
  reference_type_id int NOT NULL,
  reference_code int NOT NULL,
  code_label varchar(50) default NULL,
  abbreviation varchar(50) default NULL,
  description varchar(50) default NULL,
  PRIMARY KEY  (reference_type_id,reference_code)
);

CREATE SEQUENCE public.products_seq START 100;
CREATE TABLE products (
  id int NOT NULL DEFAULT nextval('public.products_seq'),
  name varchar(50) default NULL,
  PRIMARY KEY  (id)
);

CREATE TABLE tariffs (
  tariff_id int NOT NULL,
  start_date date NOT NULL,
  amount int default NULL,
  PRIMARY KEY  (tariff_id,start_date)
);

CREATE TABLE product_tariffs (
  product_id int NOT NULL,
  tariff_id int NOT NULL,
  tariff_start_date date NOT NULL,
  PRIMARY KEY  (product_id,tariff_id,tariff_start_date)
);

CREATE TABLE suburbs (
  city_id int NOT NULL,
  suburb_id int NOT NULL,
  name varchar(50) NOT NULL,
  PRIMARY KEY  (city_id,suburb_id)
);

CREATE SEQUENCE public.streets_seq START 100;
CREATE TABLE streets (
  id int NOT NULL DEFAULT nextval('public.streets_seq'),
  city_id int NOT NULL,
  suburb_id int NOT NULL,
  name varchar(50) NOT NULL,
  PRIMARY KEY  (id)
);

CREATE SEQUENCE public.users_seq START 100;
CREATE TABLE users (
  id int NOT NULL DEFAULT nextval('public.users_seq'),
  name varchar(50) NOT NULL,
  PRIMARY KEY  (id)
);

CREATE SEQUENCE public.articles_seq START 100;
CREATE TABLE articles (
  id int NOT NULL DEFAULT nextval('public.articles_seq'),
  name varchar(50) NOT NULL,
  PRIMARY KEY  (id)
);

CREATE SEQUENCE public.readings_seq START 100;
CREATE TABLE readings (
  id int NOT NULL DEFAULT nextval('public.readings_seq'),
  user_id int NOT NULL,
  article_id int NOT NULL,
  rating int NOT NULL,
  PRIMARY KEY  (id)
);

CREATE SEQUENCE public.groups_seq START 100;
CREATE TABLE groups (
  id int NOT NULL DEFAULT nextval('public.groups_seq'),
  name varchar(50) NOT NULL,
  PRIMARY KEY  (id)
);

CREATE TABLE memberships (
  user_id int NOT NULL,
  group_id int NOT NULL,
  PRIMARY KEY  (user_id,group_id)
);

CREATE SEQUENCE public.membership_statuses_seq START 100;
CREATE TABLE membership_statuses (
  id int NOT NULL DEFAULT nextval('public.membership_statuses_seq'),
  user_id int NOT NULL,
  group_id int NOT NULL,
	status varchar(50) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE departments (
  department_id int NOT NULL,
  location_id int NOT NULL,
  PRIMARY KEY (department_id, location_id)
);

CREATE TABLE employees (
 id int NOT NULL,
 department_id int DEFAULT NULL,
 location_id int DEFAULT NULL,
 PRIMARY KEY (id)
);

CREATE TABLE comments (
	id int NOT NULL,
	person_id varchar(100) DEFAULT NULL,
	person_type varchar(100) DEFAULT NULL,
	hack_id varchar(100) DEFAULT NULL,
	PRIMARY KEY (id)
);

CREATE TABLE hacks (
 name varchar(50) NOT NULL,
 PRIMARY KEY (name)
);

CREATE TABLE kitchen_sinks (
	id_1 int not null,
	id_2 int not null,
	a_date date,
	a_string varchar(100),
	primary key (id_1, id_2)
);

CREATE TABLE restaurants (
	franchise_id int not null,
	store_id int not null,
	name varchar(100),
	primary key (franchise_id, store_id)
);

CREATE TABLE restaurants_suburbs (
	franchise_id int not null,
	store_id int not null,
	city_id int not null,
	suburb_id int not null
);

CREATE SEQUENCE public.dorms_seq START 100;
CREATE TABLE dorms (
	id int not null DEFAULT nextval('public.dorms_seq'),
	primary key(id)
);

CREATE TABLE rooms (
	dorm_id int not null,
	room_id int not null,
	primary key (dorm_id, room_id)
);

CREATE SEQUENCE public.room_attributes_seq START 100;
CREATE TABLE room_attributes (
	id int not null DEFAULT nextval('public.room_attributes_seq'),
	name varchar(50),
	primary key(id)
);

CREATE TABLE room_attribute_assignments (
	dorm_id int not null,
	room_id int not null,
	room_attribute_id int not null
);

CREATE SEQUENCE public.students_seq START 100;
CREATE TABLE students (
	id int not null DEFAULT nextval('public.students_seq'),
	primary key(id)
);

CREATE TABLE room_assignments (
	student_id int not null,
	dorm_id int not null,
	room_id int not null
);


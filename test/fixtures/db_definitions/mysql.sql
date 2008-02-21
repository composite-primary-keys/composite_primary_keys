CREATE TABLE `reference_types` (
  `reference_type_id` int(11) NOT NULL auto_increment,
  `type_label` varchar(50) default NULL,
  `abbreviation` varchar(50) default NULL,
  `description` varchar(50) default NULL,
  PRIMARY KEY  (`reference_type_id`)
) TYPE=InnoDB;

CREATE TABLE `reference_codes` (
  `reference_type_id` int(11) NOT NULL,
  `reference_code` int(11) NOT NULL,
  `code_label` varchar(50) default NULL,
  `abbreviation` varchar(50) default NULL,
  `description` varchar(50) default NULL,
  PRIMARY KEY  (`reference_type_id`,`reference_code`)
) TYPE=InnoDB;

CREATE TABLE `products` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `tariffs` (
  `tariff_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `amount` integer(11) default NULL,
  PRIMARY KEY  (`tariff_id`,`start_date`)
) TYPE=InnoDB;

CREATE TABLE `product_tariffs` (
  `product_id` int(11) NOT NULL,
  `tariff_id` int(11) NOT NULL,
  `tariff_start_date` date NOT NULL,
  PRIMARY KEY  (`product_id`,`tariff_id`,`tariff_start_date`)
) TYPE=InnoDB;

CREATE TABLE `suburbs` (
  `city_id` int(11) NOT NULL,
  `suburb_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`city_id`,`suburb_id`)
) TYPE=InnoDB;

CREATE TABLE `streets` (
  `id` int(11) NOT NULL auto_increment,
  `city_id` int(11) NOT NULL,
  `suburb_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `articles` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE `readings` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `article_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

CREATE TABLE groups (
  id int(11) NOT NULL auto_increment,
  name varchar(50) NOT NULL,
  PRIMARY KEY  (id)
) TYPE=InnoDB;

CREATE TABLE memberships (
  user_id int(11) NOT NULL,
  group_id int(11) NOT NULL,
  PRIMARY KEY  (user_id,group_id)
) TYPE=InnoDB;

CREATE TABLE membership_statuses (
  id int(11) NOT NULL auto_increment,
  user_id int(11) NOT NULL,
  group_id int(11) NOT NULL,
  status varchar(50) NOT NULL,
  PRIMARY KEY (id)
) TYPE=InnoDB;

CREATE TABLE departments (
  department_id int(11) NOT NULL,
  location_id int(11) NOT NULL,
  PRIMARY KEY (department_id, location_id)
) TYPE=InnoDB;

CREATE TABLE employees (
 id int(11) NOT NULL auto_increment,
 department_id int(11) DEFAULT NULL,
 location_id int(11) DEFAULT NULL,
 PRIMARY KEY (id)
) TYPE=InnoDB;

CREATE TABLE comments (
	id int(11) NOT NULL auto_increment,
	person_id varchar(100) DEFAULT NULL,
	person_type varchar(100) DEFAULT NULL,
	PRIMARY KEY (id)
) TYPE=InnoDB;

CREATE TABLE hacks (
 name varchar(50) NOT NULL,
 PRIMARY KEY (name)
) TYPE=InnoDB;

create table kitchen_sinks (
	id_1 int(11) not null,
	id_2 int(11) not null,
	a_date date,
	a_string varchar(100),
	primary key (id_1, id_2)
) TYPE=InnoDB;

create table restaurants (
	franchise_id int(11) not null,
	store_id int(11) not null,
	name varchar(100),
	primary key (franchise_id, store_id)
) TYPE=InnoDB;

create table restaurants_suburbs (
	franchise_id int(11) not null,
	store_id int(11) not null,
	city_id int(11) not null,
	suburb_id int(11) not null
) TYPE=InnoDB;
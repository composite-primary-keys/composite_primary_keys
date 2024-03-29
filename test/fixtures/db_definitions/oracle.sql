create sequence reference_types_seq start with 1000;

create table reference_types (
    reference_type_id number(11)   primary key,
    type_label        varchar(50) default null,
    abbreviation      varchar(50) default null,
    description       varchar(50) default null
);

create table reference_codes (
    reference_type_id number(11),
    reference_code    number(11),
    code_label        varchar(50) default null,
    abbreviation      varchar(50) default null,
    description       varchar(50) default null
);

create sequence products_seq start with 1000;

create table products (
    id   number(11)   primary key,
    name varchar(50) default null
);

create table tariffs (
    tariff_id  number(11),
    start_date date,
    amount     number(11) default null,
    created_at timestamp,
    updated_at timestamp,
    constraint tariffs_pk primary key (tariff_id, start_date)
);

create table product_tariffs (
    product_id        number(11),
    tariff_id         number(11),
    tariff_start_date date,
    constraint product_tariffs_pk primary key (product_id, tariff_id, tariff_start_date)
);

create sequence suburbs_city_id_seq start with 1000;

create table suburbs (
    city_id   number(11) default suburbs_city_id_seq.nextval not null,
    suburb_id number(11) not null,
    name      varchar(50) not null,
    constraint suburbs_pk primary key (city_id, suburb_id)
);

create sequence streets_seq start with 1000;

create table streets (
    id        number(11)   primary key,
    city_id   number(11)   not null,
    suburb_id number(11)   not null,
    name      varchar(50) not null
);

create sequence users_seq start with 1000;

create table users (
    id   number(11)   primary key,
    name varchar(50) not null
);

create table moderators (
    id  number(11)   primary key
);

create table admins (
    id  number(11)   primary key
);

create sequence articles_seq start with 1000;

create table articles (
    id   number(11)   primary key,
    name varchar(50) not null
);

create sequence readings_seq start with 1000;

create table readings (
    id         number(11) primary key,
    user_id    number(11) not null,
    article_id number(11) not null,
    rating     number(11) not null
);

create sequence groups_seq start with 1000;

create table groups (
    id   number(11)   primary key,
    name varchar(50) not null
);

create table memberships (
    user_id  number(11) not null,
    group_id number(11) not null,
    constraint memberships_pk primary key (user_id, group_id)
);

create sequence membership_statuses_seq start with 1000;

create table membership_statuses (
    id       number(11)   primary key,
    user_id  number(11)   not null,
    group_id number(11)   not null,
    status   varchar(50) not null
);

create sequence departments_seq start with 1000;

create table departments (
    id number(11) not null,
    location_id   number(11) not null,
    constraint departments_pk primary key (id, location_id)
);

create sequence employees_seq start with 1000;

create table employees (
    id            number(11) not null primary key,
    department_id number(11) default null,
    location_id   number(11) default null,
    name          varchar(50) not null
);

create sequence comments_seq start with 1000;

create table comments (
    id          number(11)   not null primary key,
    article_id  number(11)   not null,
    person_id   number(11)   not null,
    person_type varchar(100) not null
);

create table restaurants (
    franchise_id number(11) not null,
    store_id     number(11) not null,
    name         varchar(100),
    lock_version number(11) default 0,
    constraint restaurants_pk primary key (franchise_id, store_id)
);

create table restaurants_suburbs (
    franchise_id number(11) not null,
    store_id     number(11) not null,
    city_id      number(11) not null,
    suburb_id    number(11) not null
);

create sequence dorms_seq start with 1000;

create table dorms (
    id number(11) not null,
    constraint dorms_pk primary key (id)
);

create table rooms (
    dorm_id number(11) not null,
    room_id number(11) not null,
    constraint rooms_pk primary key (dorm_id, room_id)
);

create sequence room_attributes_seq start with 1000;

create table room_attributes (
    id   number(11) not null,
    name varchar(50),
    constraint room_attributes_pk primary key (id)
);

create table room_attribute_assignments (
    dorm_id           number(11) not null,
    room_id           number(11) not null,
    room_attribute_id number(11) not null
);

create table staff_rooms (
    dorm_id  number(11) not null,
    room_id  number(11) not null,
    constraint staff_rooms_pk primary key (dorm_id, room_id)
);

create table staff_room_keys (
    dorm_id number(11) not null,
    room_id number(11) not null,
    key_no  varchar(50) not null,
    constraint staff_room_keys_pk primary key (dorm_id, room_id)
);

create sequence students_seq start with 1000;

create table students (
    id number(11) not null,
    constraint students_pk primary key (id)
);

create table room_assignments (
    student_id number(11) not null,
    dorm_id    number(11) not null,
    room_id    number(11) not null
);

create table capitols (
    country varchar(100) not null,
    city varchar(100) not null,
    primary key (country, city)
);

create table products_restaurants (
    product_id   number(11) not null,
    franchise_id number(11) not null,
    store_id     number(11) not null
);

create table employees_groups (
  employee_id int not null,
  group_id int not null
);
USE [composite_primary_keys_unittest];
go

CREATE TABLE reference_types (
    reference_type_id [int] IDENTITY(1000,1) NOT NULL,
    type_label        [varchar](50) NULL,
    abbreviation      [varchar](50) NULL,
    description       [varchar](50) NULL
);
go

CREATE TABLE reference_codes (
    reference_type_id [int],
    reference_code    [int],
    code_label        [varchar](50) NULL,
    abbreviation      [varchar](50) NULL,
    description       [varchar](50) NULL
);
go

CREATE TABLE products (
    id   [int] IDENTITY(1000,1) NOT NULL,
    name [varchar](50) NULL
);
go

CREATE TABLE tariffs (
    [tariff_id]  [int],
    [start_date] [date],
    [amount]     [int] NULL
    CONSTRAINT [tariffs_pk] PRIMARY KEY 
        ( [tariff_id], [start_date] )
);
go

CREATE TABLE product_tariffs (
    [product_id]        [int],
    [tariff_id]         [int],
    [tariff_start_date] [date]
    CONSTRAINT [product_tariffs_pk] PRIMARY KEY
        ( [product_id], [tariff_id], [tariff_start_date] )
);
go

CREATE TABLE suburbs (
    city_id   [int],
    suburb_id [int],
    name      varchar(50) not null,
    CONSTRAINT [suburbs_pk] PRIMARY KEY
        ( [city_id], [suburb_id] )
);
go

CREATE TABLE streets (
    id        [int] IDENTITY(1000,1) NOT NULL,
    city_id   [int]   NOT NULL,
    suburb_id [int]   NOT NULL,
    name        [varchar](50)      NOT NULL
);
go

CREATE TABLE users (
    id   [int] IDENTITY(1000,1) NOT NULL,
    name varchar(50) NOT NULL
);
go

CREATE TABLE articles (
    id   [int] IDENTITY(1000,1) NOT NULL,
    name varchar(50) NOT NULL
);
go

CREATE TABLE readings (
    id         [int] PRIMARY KEY,
    user_id    [int] NOT NULL,
    article_id [int] NOT NULL,
    rating     [int] NOT NULL
);
go

CREATE TABLE groups (
    id   [int] IDENTITY(1000,1) NOT NULL,
    name [varchar](50) NOT NULL
);
go

CREATE TABLE memberships (
    user_id  [int] NOT NULL,
    group_id [int] NOT NULL
    CONSTRAINT [memberships_pk] PRIMARY KEY 
        ( [user_id], [group_id] )
);
go

CREATE TABLE membership_statuses (
    id       [int] IDENTITY(1,1) NOT NULL,
    user_id  [int]   not null,
    group_id [int]   not null,
    status   varchar(50) not null
);
go

CREATE TABLE departments (
    department_id [int] NOT NULL,
    location_id   [int] NOT NULL
    CONSTRAINT [departments_pk] PRIMARY KEY
        ( [department_id], [location_id] )
);
go

CREATE TABLE employees (
    id            [int] IDENTITY(1000,1) NOT NULL,
    department_id [int] NULL,
    location_id   [int] NULL
);
go

CREATE TABLE comments (
    id          [int] IDENTITY(1000,1) PRIMARY KEY NOT NULL,
    person_id   [int] NULL,
    person_type varchar(100)      NULL,
    hack_id     [int] NULL
);
go

CREATE TABLE hacks (
    id   [int]  IDENTITY(1000,1) PRIMARY KEY NOT NULL,
    name [varchar](50) NOT NULL
);
go

CREATE TABLE restaurants (
    franchise_id [int] NOT NULL,
    store_id     [int] NOT NULL,
    name         [varchar](100)
    CONSTRAINT [restaurants_pk] PRIMARY KEY CLUSTERED 
        ( [franchise_id], [store_id] )
);
go

CREATE TABLE restaurants_suburbs (
    franchise_id [int] NOT NULL,
    store_id     [int] NOT NULL,
    city_id      [int] NOT NULL,
    suburb_id    [int] NOT NULL
);
go

CREATE TABLE dorms (
    id [int] IDENTITY(1000,1) PRIMARY KEY NOT NULL
);
go

CREATE TABLE rooms (
    dorm_id [int] NOT NULL,
    room_id [int] NOT NULL,
    CONSTRAINT [rooms_pk] PRIMARY KEY CLUSTERED 
        ( [dorm_id], [room_id] )
);
go

CREATE TABLE room_attributes (
    id   [int] IDENTITY(1000,1) PRIMARY KEY NOT NULL,
    name [varchar](50)
);
go

CREATE TABLE room_attribute_assignments (
    dorm_id           [int] NOT NULL,
    room_id           [int] NOT NULL,
    room_attribute_id [int] NOT NULL
);
go

CREATE TABLE students (
    id [int] IDENTITY(1000,1) PRIMARY KEY NOT NULL
);
go

CREATE TABLE room_assignments (
    student_id [int] NOT NULL,
    dorm_id    [int] NOT NULL,
    room_id    [int] NOT NULL
);
go

CREATE TABLE seats (
    flight_number [int] NOT NULL,
    seat          [int] NOT NULL,
    customer      [int]
    CONSTRAINT [seats_pk] PRIMARY KEY
        ( [flight_number], [seat] )
);
go

CREATE TABLE capitols (
    country varchar(450) NOT NULL,
    city varchar(450) NOT NULL
    CONSTRAINT [capitols_pk] PRIMARY KEY 
        ( [country], [city] )
);
go

CREATE TABLE products_restaurants (
    product_id   [int] NOT NULL,
    franchise_id [int] NOT NULL,
    store_id     [int] NOT NULL
);
go
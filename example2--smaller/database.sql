USE master
DROP DATABASE IF EXISTS dziedziczak;

CREATE DATABASE	dziedziczak

GO
USE dziedziczak

GO
DROP SCHEMA IF EXISTS firma

GO
CREATE SCHEMA firma

CREATE TABLE dziedziczak.firma.Products(
	id CHAR(11) PRIMARY KEY NOT NULL,
	fk_productCategories INT NOT NULL,
	fk_productSubCategories INT NOT NULL
);

CREATE TABLE dziedziczak.firma.ProductCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	category VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.ProductSubCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	subcategory VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Geography (
	id INT IDENTITY(1,1) PRIMARY KEY,
	fk_markets INT NOT NULL,
	fk_country INT NOT NULL
);

CREATE TABLE dziedziczak.firma.Countries (
	id INT IDENTITY(1,1) PRIMARY KEY,
	country VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Markets (
	id INT IDENTITY(1,1) PRIMARY KEY,
	market VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Orders (
	id CHAR(24) PRIMARY KEY NOT NULL,
	orderDate DATE NOT NULL UNIQUE,
	shipDate DATE NOT NULL UNIQUE,
	fk_shipMode INT NOT NULL,
	fk_customer CHAR(12) NOT NULL,
	fk_segment INT NOT NULL,
	postalCode VARCHAR(50),
	fk_city INT NOT NULL,
	fk_state INT NOT NULL,
	fk_product CHAR(11) NOT NULL,
	sales MONEY NOT NULL,
	quantity INT NOT NULL,
	discount FLOAT NOT NULL DEFAULT 0.0,
	profit MONEY NOT NULL,
	shippingCost FLOAT NOT NULL,
);

CREATE TABLE dziedziczak.firma.ShipModes (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	shipMode VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Customers (
	id CHAR(12) PRIMARY KEY NOT NULL,
	customerName VARCHAR(50) NOT NULL
);

CREATE TABLE dziedziczak.firma.Segments (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	segment VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Cities (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	fk_country INT NOT NULL,
 	city VARCHAR(50) NOT NULL,
);

CREATE TABLE dziedziczak.firma.States (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	state VARCHAR(50) NOT NULL,
 	fk_country INT NOT NULL
);



ALTER table dziedziczak.firma.Products add constraint fk_products_productCategories foreign key (fk_productCategories) references dziedziczak.firma.ProductCategories(id);
ALTER table dziedziczak.firma.Products add constraint fk_products_productSubCategories foreign key (fk_productSubCategories) references dziedziczak.firma.ProductSubCategories(id);

ALTER table dziedziczak.firma.Geography add constraint fk_geography_markets foreign key (fk_markets) references dziedziczak.firma.Markets(id);
ALTER table dziedziczak.firma.Geography add constraint fk_geography_country foreign key (fk_country) references dziedziczak.firma.Countries(id);

ALTER table dziedziczak.firma.Orders add constraint fk_orders_shipMode foreign key (fk_shipMode) references dziedziczak.firma.ShipModes(id);
ALTER table dziedziczak.firma.Orders add constraint fk_corders_ustomer foreign key (fk_customer) references dziedziczak.firma.Customers(id);
ALTER table dziedziczak.firma.Orders add constraint fk_orders_segment foreign key (fk_segment) references dziedziczak.firma.Segments(id);
ALTER table dziedziczak.firma.Orders add constraint fk_orders_city foreign key (fk_city) references dziedziczak.firma.Cities(id);
ALTER table dziedziczak.firma.Orders add constraint fk_orders_product foreign key (fk_product) references dziedziczak.firma.Products(id);

ALTER table dziedziczak.firma.Cities add constraint fk_cities_country foreign key (fk_country) references dziedziczak.firma.Countries(id);
ALTER table dziedziczak.firma.States add constraint fk_states_country foreign key (fk_country) references dziedziczak.firma.Countries(id);






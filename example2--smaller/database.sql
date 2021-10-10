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
	ProductId CHAR(11) PRIMARY KEY NOT NULL,
	ProductName VARCHAR(200) NOT NULL,
	fk_productCategories INT NOT NULL,
	fk_productSubCategories INT NOT NULL
);

CREATE TABLE dziedziczak.firma.ProductCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.ProductSubCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	SubCategory VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Geography (
	id INT IDENTITY(1,1) PRIMARY KEY,
	fk_markets INT NOT NULL,
	fk_country INT NOT NULL
);

CREATE TABLE dziedziczak.firma.Countries (
	id INT IDENTITY(1,1) PRIMARY KEY,
	Country VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Markets (
	id INT IDENTITY(1,1) PRIMARY KEY,
	Market VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Orders (
	OrderID CHAR(24) PRIMARY KEY NOT NULL,
	OrderDate DATE NOT NULL UNIQUE,
	ShipDate DATE NOT NULL UNIQUE,
	fk_shipMode INT NOT NULL,
	fk_customer CHAR(12) NOT NULL,
	fk_segment INT NOT NULL,
	PostalCode VARCHAR(50),
	fk_city INT NOT NULL,
	fk_state INT NOT NULL,
	fk_product CHAR(11) NOT NULL,
	Sales MONEY NOT NULL,
	Quantity INT NOT NULL,
	Discount FLOAT NOT NULL DEFAULT 0.0,
	Profit MONEY NOT NULL,
	ShippingCost FLOAT NOT NULL,
);

CREATE TABLE dziedziczak.firma.ShipModes (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	ShipMode VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Customers (
	id CHAR(12) PRIMARY KEY NOT NULL,
	CustomerName VARCHAR(50) NOT NULL
);

CREATE TABLE dziedziczak.firma.Segments (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	Segment VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.Cities (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	fk_state INT NOT NULL,
 	City VARCHAR(50) NOT NULL,
);

CREATE TABLE dziedziczak.firma.States (
	id INT IDENTITY(1,1) PRIMARY KEY,
 	State VARCHAR(50) NOT NULL,
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
ALTER table dziedziczak.firma.Orders add constraint fk_orders_product foreign key (fk_product) references dziedziczak.firma.Products(ProductId);

ALTER table dziedziczak.firma.Cities add constraint fk_cities_state foreign key (fk_state) references dziedziczak.firma.States(id);
ALTER table dziedziczak.firma.States add constraint fk_states_country foreign key (fk_country) references dziedziczak.firma.Countries(id);

GO

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela zawiera informacje o produktach.
Każdy produkt reprezentowany jest przez ProductId np. FUR-BO-3175

Każdy produkt, może mieć kategorię i subkategorię.
Oba atrybuty znajduja sie w osobnych tabelach i połączone są 
kluczami obcymi tak aby nie duplikować informacji. 

Wybrałem takie rozwiązanie ponieważ Category oraz Sub-Category
przypomina mi system tagów.', 'schema', N'firma', 'table', N'Products';
EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela zawiera informacje o kategoriach.
Przykładowe dane: Dummy, Furniture, Office supplies.', 'schema', N'firma', 'table', N'ProductCategories';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela przechowuje informację o Sub kategoriach.

Przykładowe dane: Blinders, Bookcases', 'schema', N'firma', 'table', N'ProductSubCategories';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela przechowuje informacje o zakładce Geography.
Jej zadaniem jest połączenie marketów z państwami.

Informacje te przechowywane są w tabelach Countries oraz
Markets.
', 'schema', N'firma', 'table', N'Geography';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela zawiera informację o nazwach państw.
Nazwy te muszą być unikalne.', 'schema', N'firma', 'table', N'Countries';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela zawiera informację o rynkach.

Każda krotka musi mieć unikalny atrybut Market.', 'schema', N'firma', 'table', N'Markets';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Jest to najbardziej rozbudowana tabela projektu.
Przechowuje ona informację o zamówieniach.

Każde zamówienia ma OrderDate oraz ShipingDate,
które to nie mogą być NULL.

Informacje o znaku waluty dla pól Sales i Profit
są zapisywane jako typ MONEY.

Tabela nie zawiera pola Country ponieważ
pola City oraz State jednoznacznie identyfikują
w dla jakiego państwa zostało złożone zamówienie.

PostalCode jest oznaczony jako wartość, która
może przyjmować NULL. Uznałem, że skoro
w danych czasami jest on opcjonalny to dobrze
jest go oznaczyć w ten sposób.
', 'schema', N'firma', 'table', N'Orders';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Zawiera informację o typach transportu.

Przykładowe dane: First class, Second Class', 'schema', N'firma', 'table', N'ShipModes';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela przechowuje dane o klientach.
Każdy klient ma CustomerName, które nie może być NULL.

Tutaj myślałem czy Segment również należy do Customers
ale ostatecznie uznałem, że segment dotyczy zamówienia.', 'schema', N'firma', 'table', N'Customers';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Zawiera informację o segmencie zamówienia.

Każdy segment musi być unikalny i nie może 
być wartością NULL.
', 'schema', N'firma', 'table', N'Segments';

EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Zawiera informację o miastach.

Każde miasto musi być przypisane do jednego ze stanów
państwa tzn. tabeli States.
', 'schema', N'firma', 'table', N'Cities';
EXEC dziedziczak.sys.sp_addextendedproperty 'MS_Description', N'
Tabela zawiera informację o statnach w danym państwie.', 'schema', N'firma', 'table', N'States';


GO




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
	fk_productSubCategories INT NOT NULL
);

CREATE TABLE dziedziczak.firma.ProductCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	Category VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE dziedziczak.firma.ProductSubCategories (
	id INT IDENTITY(1,1) PRIMARY KEY,
	SubCategory VARCHAR(200) NOT NULL UNIQUE,
	fk_productCategories INT NOT NULL
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
	OrderDate DATE NOT NULL,
	ShipDate DATE NOT NULL,
	fk_shipMode INT NOT NULL,
	fk_customer CHAR(12) NOT NULL,
	fk_segment INT NOT NULL,
	PostalCode VARCHAR(50),
	fk_city INT NOT NULL,
	fk_state INT NOT NULL,
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

CREATE TABLE dziedziczak.firma.OrderedProducts (
	id INT IDENTITY(1,1) PRIMARY KEY,
	fk_order CHAR(24) NOT NULL,
	fk_product CHAR(11) NOT NULL,
	Sales MONEY NOT NULL,
	Quantity INT NOT NULL,
	Discount FLOAT NOT NULL DEFAULT 0.0,
	Profit MONEY NOT NULL,
	ShippingCost FLOAT NOT NULL,
)


ALTER table dziedziczak.firma.ProductSubCategories add constraint fk_productSubCategories_productCategories foreign key (fk_productCategories) references dziedziczak.firma.ProductCategories(id);
ALTER table dziedziczak.firma.Products add constraint fk_products_productSubCategories foreign key (fk_productSubCategories) references dziedziczak.firma.ProductSubCategories(id);

ALTER table dziedziczak.firma.Geography add constraint fk_geography_markets foreign key (fk_markets) references dziedziczak.firma.Markets(id);
ALTER table dziedziczak.firma.Geography add constraint fk_geography_country foreign key (fk_country) references dziedziczak.firma.Countries(id);

ALTER table dziedziczak.firma.Orders add constraint fk_orders_shipMode foreign key (fk_shipMode) references dziedziczak.firma.ShipModes(id);
ALTER table dziedziczak.firma.Orders add constraint fk_corders_ustomer foreign key (fk_customer) references dziedziczak.firma.Customers(id);
ALTER table dziedziczak.firma.Orders add constraint fk_orders_segment foreign key (fk_segment) references dziedziczak.firma.Segments(id);
ALTER table dziedziczak.firma.Orders add constraint fk_orders_city foreign key (fk_city) references dziedziczak.firma.Cities(id);

ALTER table dziedziczak.firma.OrderedProducts add constraint fk_orderedProducts_product foreign key (fk_product) references dziedziczak.firma.Products(ProductId);
ALTER table dziedziczak.firma.OrderedProducts add constraint fk_orderedProducts_orders foreign key (fk_order) references dziedziczak.firma.Orders(OrderId);

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

IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures p WHERE Name = 'dodaj_kategorie')
DROP PROCEDURE firma.dodaj_kategorie

GO

CREATE PROCEDURE firma.dodaj_kategorie
	@Category VARCHAR(200),
	@SubCategory VARCHAR(200),
	@ProductName VARCHAR(200),
	@ProductId VARCHAR(200),
	@Country VARCHAR(50),
	@Market VARCHAR(50),
	@State VARCHAR(50),
	@City VARCHAR(50),
	@CustomerName VARCHAR(50),
	@CustomerId CHAR(12),
	@Segment VARCHAR(50),
	@ShipMode VARCHAR(50),
	@OrderID CHAR(24),
	@OrderDate DATE,
	@ShipDate DATE,
	@PostalCode VARCHAR(50),
	@Sales MONEY,
	@Quantity INT,
	@Discount FLOAT,
	@Profit MONEY,
	@ShippingCost FLOAT
	AS
	BEGIN

	declare @fk_productCategories INT = NULL;
	declare @fk_productSubCategories INT = NULL;
	
	SELECT @fk_productCategories = id FROM ProductCategories pc WHERE pc.Category = @Category;

	IF @fk_productCategories IS NULL
	BEGIN
		INSERT INTO ProductCategories(Category) VALUES (@Category);
		SELECT @fk_productCategories = SCOPE_IDENTITY();
	END
	
	SELECT @fk_productSubCategories = id FROM ProductSubCategories psc WHERE psc.SubCategory = @SubCategory
	IF @fk_productSubCategories IS NULL
	BEGIN
		INSERT INTO ProductSubCategories(SubCategory, fk_productCategories) VALUES (@SubCategory, @fk_productCategories)
		SELECT @fk_productSubCategories = SCOPE_IDENTITY();
	END

	declare @fk_product CHAR(11)

	SELECT @fk_product = ProductId FROM Products p WHERE p.ProductName = @ProductName OR p.ProductId = @ProductId
	IF @fk_product IS NULL
	BEGIN
		INSERT INTO Products(ProductId, ProductName, fk_productSubCategories) VALUES (@ProductId, @ProductName, @fk_productSubCategories)
		SELECT @fk_product = SCOPE_IDENTITY()
	END

	declare @fk_markets INT
	declare @fk_country INT

	SELECT @fk_markets = id FROM Markets m WHERE m.Market = @Market
	IF @fk_markets IS NULL
	BEGIN
		INSERT INTO Markets (Market) VALUES (@Market)
		SELECT @fk_markets = SCOPE_IDENTITY()
	END

	SELECT @fk_country = id FROM Countries c WHERE c.Country = @Country
	IF @fk_country IS NULL
	BEGIN
		INSERT INTO Countries (Country) VALUES (@Country)
		SELECT @fk_country = SCOPE_IDENTITY()
	END

	declare @fk_geography INT

	SELECT 1 FROM Geography g WHERE g.fk_markets = @fk_markets AND g.fk_country = @fk_country
	IF @fk_geography IS NULL
	BEGIN
		INSERT INTO Geography (fk_markets, fk_country) VALUES (@fk_markets, @fk_country)
		SELECT @fk_geography = SCOPE_IDENTITY()
	END
	
	declare @fk_state INT = NULL
	SELECT @fk_state = id FROM States s WHERE s.State = @State
	IF @fk_state IS NULL
	BEGIN
		INSERT INTO States(State, fk_country) VALUES (@State, @fk_country)
		SELECT @fk_state = SCOPE_IDENTITY()
	END

	declare @fk_city INT = NULL
	SELECT @fk_city = id FROM Cities c WHERE c.City = @City
	
	IF @fk_city IS NULL
	BEGIN
		INSERT INTO Cities(City, fk_state) VALUES (@City, @fk_state)
		SELECT @fk_city = SCOPE_IDENTITY()
	END

	declare @fk_customer INT = NULL
	SELECT @fk_customer = id FROM Customers c WHERE c.CustomerName = @CustomerName OR c.ID = @CustomerId
	IF @fk_customer IS NULL
	BEGIN
		INSERT INTO Customers(id, CustomerName) VALUES (@CustomerId, @CustomerName)
		SELECT @fk_customer = SCOPE_IDENTITY()
	END

	declare @fk_segment INT = NULL
	SELECT @fk_segment = id FROM Segments s WHERE s.Segment = @Segment
	IF @fk_segment IS NULL
	BEGIN
		INSERT INTO Segments(Segment) VALUES (@Segment)
		SELECT @fk_segment = SCOPE_IDENTITY()
	END

	declare @fk_shipMode INT = NULL
	SELECT @fk_shipMode = id FROM ShipModes sm WHERE sm.ShipMode = @ShipMode
	IF @fk_shipMode IS NULL
	BEGIN
		INSERT INTO ShipModes(ShipMode) VALUES (@ShipMode)
		SELECT @fk_shipMode = SCOPE_IDENTITY()
	END
	
	INSERT INTO Orders(
		OrderID, 
		OrderDate,
		ShipDate,
		fk_customer,
		fk_segment,
		fk_shipMode,
		PostalCode,
		fk_city,
		fk_state
	) VALUES (
		@OrderID,
		@OrderDate,
		@ShipDate,
		@CustomerId,
		@fk_segment,
		@fk_shipMode,
		@PostalCode,
		@fk_city,
		@fk_state
	)

	declare @fk_order INT = NULL
	SELECT @fk_order = SCOPE_IDENTITY()
	
	INSERT INTO OrderedProducts(
		fk_order,
		fk_product,
		Sales,
		Quantity,
		Discount,
		Profit,
		ShippingCost
	) VALUES (
		@OrderID,
		@ProductId,
		@Sales,
		@Quantity,
		@Discount,
		@Profit,
		@ShippingCost
	)
	END
GO

EXEC dziedziczak.firma.dodaj_kategorie 'Technology', 'Phones', 'Samsung Smart Phone, Cordless', 'TEC-PH-5839', 'Brazil', '', 'Rio Grande do Norte', 'Açu', 'Carl Ludwig', 'CL-1189018', 'Consumer', 'Same Day', 'US-2013-CL1189018-41459', '7/4/2013', '7/4/2013', '', '$1,363.20', 0, 0.6, '-$1,806.24', 255.173
EXEC dziedziczak.firma.dodaj_kategorie 'Technology', 'Phones', 'Samsung Smart Phone, Cordless', 'TEC-PH-5839', 'Brazil', '', 'Rio Grande do Norte', 'Açu', 'Carl Ludwig', 'CL-1189018', 'Consumer', 'Same Day', 'US-2013-CL1189018-41459', '7/4/2013', '7/4/2013', '', '$1,363.20', 0, 0.6, '-$1,806.24', 255.173
EXEC dziedziczak.firma.dodaj_kategorie 'Furniture', 'Bookcases', 'Bush Library with Doors, Mobile', 'FUR-BO-3640', 'Iraq', '', 'Al Qadisiyah', 'Ad Diwaniyah', 'Evan Henry', 'EH-418561', 'Consumer', 'First Class', 'IZ-2015-EH418561-42173', '6/18/2015', '6/21/2015', '', '$1,467.36', 0, 0, '$469.44', 243.14



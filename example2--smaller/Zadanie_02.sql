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
	-- Ponieważ OrderID jest PRIMARY KEY nie muszę dawać constraint UNIQUE
	OrderID CHAR(24) PRIMARY KEY NOT NULL,
	OrderDate DATE NOT NULL,
	ShipDate DATE NOT NULL,
	fk_shipMode INT NOT NULL,
	fk_customer CHAR(12) NOT NULL,
	fk_segment INT NOT NULL,
	PostalCode VARCHAR(50),
	fk_city INT NOT NULL,
	fk_state INT NOT NULL,
	CONSTRAINT ck_ShipDate
        CHECK (ShipDate >= OrderDate)
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
	CONSTRAINT ck_Quantity CHECK (Quantity > 0),
	CONSTRAINT ck_ShippingCost CHECK (ShippingCost > 0),
)


ALTER table dziedziczak.firma.ProductSubCategories add constraint fk_productSubCategories_productCategories foreign key (fk_productCategories) references dziedziczak.firma.ProductCategories(id);
ALTER table dziedziczak.firma.Products add constraint fk_products_productSubCategories foreign key (fk_productSubCategories) references dziedziczak.firma.ProductSubCategories(id);

ALTER table dziedziczak.firma.Geography add constraint fk_geography_markets foreign key (fk_markets) references dziedziczak.firma.Markets(id);
ALTER table dziedziczak.firma.Geography add constraint fk_geography_country foreign key (fk_country) references dziedziczak.firma.Countries(id);

ALTER table dziedziczak.firma.Orders add constraint fk_orders_shipMode foreign key (fk_shipMode) references dziedziczak.firma.ShipModes(id);
ALTER table dziedziczak.firma.Orders add constraint fk_corders_customer foreign key (fk_customer) references dziedziczak.firma.Customers(id);
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

/* OPIS PROCEDUR

dodaj_z_xls - tę procedurę napisałem żeby móc wypełnić miasta i inne podstawowe dane w bazie z pliku
			zad1. Najpierw jednak ten plik musiałem doprowadzić do formatu, który pozwala na utworzenie
			poleceń INSERT.
			
			W tym celu napisałem prosty skryp powłoki
			
			#/bin/bash

			join -a 1 -e EMPTY -1 12 -2 1 -t';' <(sort -k 12 -t';' orders.csv) <(sort -k 1 -t';' products.csv) > merger_orders_products.csv
			join --nocheck-order -a 1 -e EMPTY -1 10 -2 2 -t';' <(sort -u -k10 -t';' merger_orders_products.csv) <(sort -k 2 -t';' geography.csv) > merger_orders_products_geography.csv

			while IFS= read -r order; do
			  City=$(echo $order | cut -d ';' -f 1 | sed "s/'//g" ) ;
			  ProductID=$(echo $order | cut -d ';' -f 2 | sed "s/'//g" ) ;
			  OrderID=$(echo $order | cut -d ';' -f 3 | sed "s/'//g" ) ;
			  OrderDate=$(echo $order | cut -d ';' -f 4 | sed "s/'//g" ) ;
			  ShipDate=$(echo $order | cut -d ';' -f 5| sed "s/'//g"  ) ;
			  ShipMode=$(echo $order | cut -d ';' -f 6 | sed "s/'//g" ) ;
			  CustomerID=$(echo $order | cut -d ';' -f 7 | sed "s/'//g" ) ;
			  CustomerName=$(echo $order | cut -d ';' -f 8 | sed "s/'//g" ) ;
			  Segment=$(echo $order | cut -d ';' -f 9 | sed "s/'//g"  ) ;
			  PostalCode=$(echo $order | cut -d ';' -f 10 | sed "s/'//g" ) ;
			  State=$(echo $order | cut -d ';' -f 11 | sed "s/'//g"  ) ;
			  Country=$(echo $order | cut -d ';' -f 12 | sed "s/'//g" ) ;
			  Sales=$(echo $order | cut -d ';' -f 13 | sed "s/'//g"  ) ;
			  Quantity=$(echo $order | cut -d ';' -f 14 | sed "s/'//g" ) ;
			  Discount=$(echo $order | cut -d ';' -f 15 | sed "s/'//g" ) ;
			  Profit=$(echo $order | cut -d ';' -f 16 | sed "s/'//g" ) ;
			  ShippingCost=$(echo $order | cut -d ';' -f 17 | sed "s/'//g" ) ;
			  Category=$(echo $order | cut -d ';' -f 18 | sed "s/'//g" ) ;
			  SubCategory=$(echo $order | cut -d ';' -f 19 | sed "s/'//g" ) ;
			  ProductName=$(echo $order | cut -d ';' -f 20 | sed "s/'//g"  )

			  echo "EXEC dziedziczak.firma.dodaj_z_xls '$Category', '$SubCategory', '$ProductName', '$ProductID', '$Country', '$Market', '$State', '$City', '$CustomerName', '$CustomerID', '$Segment', '$ShipMode', '$OrderID', '$OrderDate', '$ShipDate', '$postalCode', '$Sales', $Quantity, $Discount, '$Profit', $ShippingCost"
			done < merger_orders_products_geography.csv
			
			który można użyć 
			
			bash insert.sh > fill_db.sql
			
			Następnie wybrałem pierwsze kilkadziesiąt poleceń INSERT i umieściłem je w tym skrypcie.
			Nie ładowałem całej bazy danych ponieważ wykonanie tego na bazie zajęłoby zbyt wiele czasu.
			
firma.dodaj_zamowienie - procedura ta pozwala na dodanie zamówienia. Głównym problemem jaki miałem było
			utworzenie jakiejś struktury danych, która pozwoliłaby zdefiniować i przekazać do procedury
			zbiór danych o produktach.
			
			Z tego co czytałem można to wykonać za pomocą tabel tymczasowych albo poleceń  XQuery
			https://docs.microsoft.com/en-us/sql/xquery/xquery-language-reference-sql-server?view=sql-server-ver15v
			które to pozwalają na operacje na XML-u.
			
			Wybrałem tę drugą opcję ponieważ nigdy wczesniej nie używałem tej technologii.

Obie procedury posiadają obsługę tranzakcji, które wykonają ROLLBACK
gdy, jedno z poleceń INSERT nie zostanie wykonane.
			
Przykłady obu procedur znajdują się poniżej.

 */

GO

IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures p WHERE Name = 'dodaj_z_xls')
DROP PROCEDURE firma.dodaj_z_xls

GO

CREATE PROCEDURE firma.dodaj_z_xls
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
	BEGIN TRANSACTION

	declare @fk_productCategories INT = NULL
	declare @fk_productSubCategories INT = NULL
	
	SELECT @fk_productCategories = id FROM ProductCategories pc WHERE pc.Category = @Category

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

	SELECT @fk_product = ProductId FROM Products p WHERE p.ProductId = @ProductId
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
	SELECT @fk_state = s.id FROM States s WHERE s.State = @State
	IF @fk_state IS NULL
	BEGIN
		INSERT INTO States(State, fk_country) VALUES (@State, @fk_country)
		SELECT @fk_state = SCOPE_IDENTITY()
	END

	declare @fk_city INT = NULL
	SELECT @fk_city = c.id FROM Cities c WHERE c.City = @City
	IF @fk_city IS NULL
	BEGIN
		INSERT INTO Cities(City, fk_state) VALUES (@City, @fk_state)
		SELECT @fk_city = SCOPE_IDENTITY()
	END

	declare @fk_customer CHAR(12) = NULL
	SELECT @fk_customer = c.id FROM Customers c WHERE c.id = @CustomerId

	IF @fk_customer IS NULL
	BEGIN
		INSERT INTO Customers(id, CustomerName) VALUES (@CustomerId, @CustomerName)
		SET @fk_customer = @CustomerId
	END
	
	PRINT @fk_customer

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
	declare @fk_order CHAR(24) = NULL
	SELECT @fk_order = o.OrderId FROM Orders o WHERE o.OrderID = @OrderID
	
	IF @fk_order IS NULL
	BEGIN
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
	END

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
	IF @@ERROR = 0  
	BEGIN
	COMMIT
	END
	ELSE
	BEGIN
	ROLLBACK
	END

GO

EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Samsung Smart Phone, Cordless', 'TEC-PH-5839', 'Brazil', '', 'Rio Grande do Norte', 'Açu', 'Carl Ludwig', 'CL-1189018', 'Consumer', 'Same Day', 'US-2013-CL1189018-41459', '7/4/2013', '7/4/2013', '', '$1,363.20', 8, 0.6, '-$1,806.24', 255.173
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Bush Library with Doors, Mobile', 'FUR-BO-3640', 'Iraq', '', 'Al Qadisiyah', 'Ad Diwaniyah', 'Evan Henry', 'EH-418561', 'Consumer', 'First Class', 'IZ-2015-EH418561-42173', '6/18/2015', '6/21/2015', '', '$1,467.36', 4, 0, '$469.44', 243.14
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Bush Library with Doors, Mobile', 'FUR-BO-3640', 'Australia', '', 'South Australia', 'Adelaide', 'Karen Seio', 'KS-163007', 'Corporate', 'First Class', 'IN-2014-KS163007-41912', '9/30/2014', '10/3/2014', '', '$1,320.62', 4, 0.1, '$484.22', 410.88
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Canon Wireless Fax, High-Speed', 'TEC-CO-3709', 'Australia', '', 'South Australia', 'Adelaide', 'Jason Klamczynski', 'JK-153257', 'Corporate', 'Second Class', 'ID-2014-JK153257-41984', '12/11/2014', '12/14/2014', '', '$1,695.87', 5, 0.1, '-$37.83', 498.62
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Brother Wireless Fax, Digital', 'TEC-CO-3609', 'Australia', '', 'South Australia', 'Adelaide', 'Adrian Barton', 'AB-101057', 'Consumer', 'Standard Class', 'IN-2015-AB101057-42153', '5/29/2015', '6/5/2015', '', '$1,703.03', 5, 0.1, '$737.93', 332.14
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Harbour Creations Executive Leather Armchair, Black', 'FUR-CH-4531', 'Australia', '', 'South Australia', 'Adelaide', 'Bart Folk', 'BF-110807', 'Consumer', 'Second Class', 'IN-2014-BF110807-41976', '12/3/2014', '12/6/2014', '', '$1,705.00', 4, 0.1, '$378.88', 403.46
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'HP Wireless Fax, Digital', 'TEC-CO-4790', 'Australia', '', 'South Australia', 'Adelaide', 'Chad McGuire', 'CM-121157', 'Consumer', 'First Class', 'IN-2014-CM121157-41913', '10/1/2014', '10/2/2014', '', '$1,943.19', 6, 0.1, '$258.93', 499.62
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hoover Stove, White', 'OFF-AP-4745', 'Australia', '', 'South Australia', 'Adelaide', 'Claire Gute', 'CG-125207', 'Consumer', 'Standard Class', 'IN-2015-CG125207-42077', '3/14/2015', '3/18/2015', '', '$3,569.64', 7, 0.1, '$674.16', 458.54
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Tenex Trays, Industrial', 'OFF-ST-6282', 'Australia', '', 'South Australia', 'Adelaide', 'Michelle Huthwaite', 'MH-180257', 'Consumer', 'Second Class', 'IN-2013-MH180257-41443', '6/18/2013', '6/20/2013', '', '$689.09', 14, 0.1, '-$53.89', 204.72
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Rogers Lockers, Blue', 'OFF-ST-5700', 'Australia', '', 'South Australia', 'Adelaide', 'Christopher Martinez', 'CM-123857', 'Consumer', 'Second Class', 'ID-2015-CM123857-42208', '7/23/2015', '7/25/2015', '', '$952.29', 5, 0.1, '-$53.01', 223.43
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Hon Executive Leather Armchair, Red', 'FUR-CH-4656', 'India', '', 'Uttar Pradesh', 'Agra', 'Ted Trevino', 'TT-2107058', 'Consumer', 'Standard Class', 'IN-2013-TT2107058-41551', '10/4/2013', '10/9/2013', '', '$2,756.34', 6, 0, '$413.28', 369.4
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'KitchenAid Stove, Silver', 'OFF-AP-4966', 'Iraq', '', 'Maysan', 'Al Amarah', 'Brian Derr', 'BD-163561', 'Consumer', 'Standard Class', 'IZ-2015-BD163561-42045', '2/10/2015', '2/14/2015', '', '$3,425.40', 6, 0, '$1,233.00', 307.83
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Breville Stove, Black', 'OFF-AP-3578', 'Egypt', '', 'Al Iskandariyah', 'Alexandria', 'Alan Hwang', 'AH-21038', 'Consumer', 'Standard Class', 'EG-2013-AH21038-41489', '8/3/2013', '8/7/2013', '', '$2,243.88', 4, 0, '$246.72', 238.95
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Epson Inkjet, Durable', 'TEC-MA-4197', 'Algeria', '', 'Alger', 'Algiers', 'Rose OBrian', 'RO-97803', 'Consumer', 'Same Day', 'AG-2012-RO97803-40964', '2/25/2012', '2/25/2012', '', '$613.26', 2, 0, '$202.32', 241.33
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'KitchenAid Microwave, White', 'OFF-AP-4959', 'Australia', '', 'Northern Territory', 'Alice Springs', 'Dave Poirier', 'DP-131057', 'Corporate', 'Second Class', 'IN-2013-DP131057-41514', '8/28/2013', '9/2/2013', '', '$2,498.53', 9, 0.1, '$499.45', 257.16
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Sharp Fax Machine, Color', 'TEC-CO-5997', 'India', '', 'Uttar Pradesh', 'Aligarh', 'Chuck Sachs', 'CS-1246058', 'Consumer', 'Standard Class', 'IN-2013-CS1246058-41609', '12/1/2013', '12/7/2013', '', '$2,673.81', 9, 0, '$26.73', 237.05
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Samsung Smart Phone, with Caller ID', 'TEC-PH-5842', 'India', '', 'Uttar Pradesh', 'Allahabad', 'Thomas Brumley', 'TB-2119058', 'Home Office', 'Standard Class', 'IN-2013-TB2119058-41552', '10/5/2013', '10/9/2013', '', '$2,544.60', 4, 0, '$865.08', 226.81
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'HP Fax Machine, Laser', 'TEC-CO-4776', 'Brazil', '', 'São Paulo', 'Americana', 'Bill Shonely', 'BS-1136518', 'Corporate', 'First Class', 'MX-2015-BS1136518-42199', '7/14/2015', '7/16/2015', '', '$997.80', 5, 0.002, '$327.90', 213.775
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Nokia Audio Dock, Full Size', 'TEC-PH-5336', 'India', '', 'Maharashtra', 'Amravati', 'Jim Epp', 'JE-1561058', 'Corporate', 'Same Day', 'IN-2014-JE1561058-41895', '9/13/2014', '9/13/2014', '', '$840.15', 5, 0, '$260.40', 286.67
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'HP Wireless Fax, Laser', 'TEC-CO-4792', 'Netherlands', '', 'North Holland', 'Amsterdam', 'Anthony Witt', 'AW-1084091', 'Consumer', 'First Class', 'IT-2012-AW1084091-41242', '11/29/2012', '11/30/2012', '', '$1,440.84', 8, 0.5, '-$1,268.04', 367.35
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hoover Stove, White', 'OFF-AP-4745', 'Netherlands', '', 'North Holland', 'Amsterdam', 'Greg Matthias', 'GM-1468091', 'Consumer', 'First Class', 'IT-2012-GM1468091-41215', '11/2/2012', '11/5/2012', '', '$1,983.14', 7, 0.5, '-$1,784.90', 473.27
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Binders', '"Green Canvas Binder for 8-1/2"" x 14"" Sheets"', 'OFF-BI-4485', 'United States', '', 'California', 'Anaheim', 'Alan Hwang', 'AH-102101404', 'Consumer', 'Standard Class', 'CA-2015-AH10210140-42072', '3/9/2015', '3/16/2015', '', '$171.20', 5, 0.2, '$64.20', 12.9
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Art', 'Newell 323', 'OFF-AR-5301', 'United States', '', 'California', 'Anaheim', 'Alan Hwang', 'AH-102101404', 'Consumer', 'Standard Class', 'CA-2015-AH10210140-42072', '3/9/2015', '3/16/2015', '', '$3.36', 2, 0, '$0.87', 1.27
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'HP Wireless Fax, Laser', 'TEC-CO-4792', 'France', '', 'Pays de la Loire', 'Angers', 'Greg Guthrie', 'GG-1465045', 'Corporate', 'Same Day', 'ES-2013-GG1465045-41615', '12/7/2013', '12/7/2013', '', '$1,224.71', 4, 0.15, '-$129.73', 326.27
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Panasonic Inkjet, Red', 'TEC-MA-5547', 'France', '', 'Auvergne-Rhône-Alpes', 'Annecy-le-Vieux', 'Denny Joy', 'DJ-1342045', 'Corporate', 'Standard Class', 'ES-2015-DJ1342045-42035', '1/31/2015', '2/4/2015', '', '$2,102.83', 8, 0.15, '$321.55', 246.17
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hoover Refrigerator, Silver', 'OFF-AP-4737', 'China', '', 'Anhui', 'Anqing', 'Barry Gonzalez', 'BG-1103527', 'Consumer', 'First Class', 'ID-2014-BG1103527-41781', '5/22/2014', '5/24/2014', '', '$1,581.03', 3, 0, '$790.47', 206.05
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Cisco Signal Booster, VoIP', 'TEC-PH-3802', 'China', '', 'Liaoning', 'Anshan', 'Caroline Jumper', 'CJ-1201027', 'Consumer', 'Second Class', 'IN-2014-CJ1201027-41810', '6/20/2014', '6/22/2014', '', '$1,063.44', 7, 0, '$361.41', 304.95
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Brother Fax Machine, High-Speed', 'TEC-CO-3597', 'China', '', 'Liaoning', 'Anshan', 'Lisa Hazard', 'LH-1702027', 'Consumer', 'First Class', 'IN-2013-LH1702027-41572', '10/25/2013', '10/28/2013', '', '$1,583.70', 5, 0, '$174.15', 479.67
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Dania Library with Doors, Traditional', 'FUR-BO-3904', 'China', '', 'Liaoning', 'Anshan', 'Brian Thompson', 'BT-1168027', 'Consumer', 'First Class', 'IN-2014-BT1168027-41815', '6/25/2014', '6/26/2014', '', '$724.80', 2, 0, '$333.36', 205.55
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'StarTech Printer, Red', 'TEC-MA-6148', 'Madagascar', '', 'Analamanga', 'Antananarivo', 'Duane Huffman', 'DH-367577', 'Home Office', 'First Class', 'MA-2014-DH367577-41926', '10/14/2014', '10/15/2014', '', '$1,519.92', 6, 0, '$653.40', 286.2
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Nokia Smart Phone, Full Size', 'TEC-PH-5355', 'El Salvador', '', 'La Libertad', 'Antiguo Cuscatlán', 'Sarah Foster', 'SF-2020039', 'Consumer', 'First Class', 'MX-2015-SF2020039-42255', '9/8/2015', '9/11/2015', '', '$1,274.70', 3, 0, '$293.16', 290.523
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Novimex Executive Leather Armchair, Red', 'FUR-CH-5380', 'France', '', 'Ile-de-France', 'Antony', 'Stewart Visinsky', 'SV-2078545', 'Consumer', 'First Class', 'ES-2014-SV2078545-41807', '6/17/2014', '6/19/2014', '', '$1,242.54', 3, 0.1, '$345.15', 245.83
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'Logitech Router, Programmable', 'TEC-AC-5136', 'France', '', 'Ile-de-France', 'Antony', 'Stewart Visinsky', 'SV-2078545', 'Consumer', 'First Class', 'ES-2014-SV2078545-41807', '6/17/2014', '6/19/2014', '', '$1,244.10', 5, 0, '$447.75', 309
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'KitchenAid Refrigerator, Red', 'OFF-AP-4961', 'Belgium', '', 'Antwerp', 'Antwerp', 'Rob Dowd', 'RD-1958514', 'Consumer', 'Second Class', 'ES-2013-RD1958514-41639', '12/31/2013', '1/3/2014', '', '$1,583.82', 3, 0, '$126.63', 215.73
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Bush Classic Bookcase, Traditional', 'FUR-BO-3627', 'Brazil', '', 'Tocantins', 'Araguaína', 'Saphhira Shifley', 'SS-2014018', 'Corporate', 'Standard Class', 'MX-2014-SS2014018-41658', '1/19/2014', '1/26/2014', '', '$2,751.20', 10, 0, '$110.00', 203.132
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Tables', 'Chromcraft Round Table, Rectangular', 'FUR-TA-3771', 'Iraq', '', 'Arbil', 'Arbil', 'Denise Leinenbach', 'DL-333061', 'Consumer', 'First Class', 'IZ-2013-DL333061-41514', '8/28/2013', '8/30/2013', '', '$929.34', 2, 0, '$65.04', 212.15
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Motorola Signal Booster, Full Size', 'TEC-PH-5264', 'Iran', '', 'Ardabil', 'Ardabil', 'Andy Gerbode', 'AG-52560', 'Corporate', 'Second Class', 'IR-2014-AG52560-41641', '1/2/2014', '1/4/2014', '', '$2,021.88', 14, 0, '$323.40', 239.62
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Epson Printer, Durable', 'TEC-MA-4205', 'France', '', 'Ile-de-France', 'Argenteuil', 'Monica Federle', 'MF-1825045', 'Corporate', 'Standard Class', 'ES-2015-MF1825045-42330', '11/22/2015', '11/28/2015', '', '$2,456.62', 11, 0.15, '$664.72', 442.49
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Akro Stacking Bins', 'OFF-ST-3078', 'United States', '', 'Texas', 'Arlington', 'Aaron Bergman', 'AB-100151402', 'Consumer', 'Standard Class', 'CA-2012-AB10015140-40958', '2/19/2012', '2/25/2012', '', '$12.62', 2, 0.2, '-$2.52', 1.97
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'WD My Passport Ultra 1TB Portable External Hard Drive', 'TEC-AC-6351', 'United States', '', 'Texas', 'Arlington', 'Adam Hart', 'AH-100751402', 'Corporate', 'Standard Class', 'CA-2014-AH10075140-41991', '12/18/2014', '12/22/2014', '', '$165.60', 3, 0.2, '-$6.21', 11.15
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Paper', 'Xerox 214', 'OFF-PA-6577', 'United States', '', 'Texas', 'Arlington', 'Adam Hart', 'AH-100751402', 'Corporate', 'Standard Class', 'CA-2014-AH10075140-41991', '12/18/2014', '12/22/2014', '', '$51.84', 10, 0.2, '$18.14', 4.93
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Hanging Personal Folder File', 'OFF-ST-4516', 'United States', '', 'Virginia', 'Arlington', 'Aaron Smayling', 'AS-100451408', 'Corporate', 'First Class', 'CA-2014-AS10045140-41727', '3/29/2014', '4/1/2014', '', '$31.40', 2, 0, '$7.85', 3.81
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Sauder Classic Bookcase, Pine', 'FUR-BO-5950', 'Russia', '', 'Astrakhan', 'Astrakhan', 'Corey Roper', 'CR-2625108', 'Home Office', 'Second Class', 'RS-2015-CR2625108-42230', '8/14/2015', '8/16/2015', '', '$3,498.72', 8, 0, '$594.72', 410.05
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Motorola Audio Dock, VoIP', 'TEC-PH-5248', 'Greece', '', 'Attica', 'Athens', 'Denny Joy', 'DJ-88887148', 'Corporate', 'Second Class', 'ES-2012-DJ88887148-41231', '11/18/2012', '11/20/2012', '', '$728.53', 7, 0.4, '-$133.73', 257.16
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Art', 'Newell 347', 'OFF-AR-5327', 'United States', '', 'Georgia', 'Atlanta', 'Adam Hart', 'AH-100751408', 'Corporate', 'Standard Class', 'CA-2015-AH10075140-42335', '11/27/2015', '12/1/2015', '', '$12.84', 3, 0, '$3.72', 1.88
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Furnishings', 'Eldon Image Series Desk Accessories, Burgundy', 'FUR-FU-4070', 'United States', '', 'Washington', 'Auburn', 'Adrian Shami', 'AS-101351404', 'Home Office', 'Standard Class', 'CA-2014-AS10135140-41957', '11/14/2014', '11/20/2014', '', '$4.18', 1, 0, '$1.50', 1.18
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Harbour Creations Executive Leather Armchair, Black', 'FUR-CH-4531', 'New Zealand', '', 'Auckland', 'Auckland', 'Liz Carlisle', 'LC-1705092', 'Consumer', 'Second Class', 'ID-2013-LC1705092-41560', '10/13/2013', '10/16/2013', '', '$1,136.66', 4, 0.4, '-$189.46', 313.52
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Sharp Fax Machine, High-Speed', 'TEC-CO-5999', 'Germany', '', 'Bavaria', 'Augsburg', 'Khloe Miller', 'KM-1666048', 'Consumer', 'First Class', 'ES-2012-KM1666048-41129', '8/8/2012', '8/10/2012', '', '$1,469.25', 5, 0, '$308.40', 527.87
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hamilton Beach Refrigerator, Red', 'OFF-AP-4502', 'India', '', 'Bihar', 'Aurangabad', 'Christine Phan', 'CP-1234058', 'Corporate', 'First Class', 'IN-2015-CP1234058-42202', '7/17/2015', '7/20/2015', '', '$4,001.04', 8, 0, '$1,440.24', 439.65
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'Kingston Digital DataTraveler 16GB USB 2.0', 'TEC-AC-4945', 'United States', '', 'Illinois', 'Aurora', 'Adrian Hane', 'AH-101201402', 'Home Office', 'Second Class', 'CA-2014-AH10120140-41821', '7/1/2014', '7/4/2014', '', '$50.12', 7, 0.2, '-$0.63', 1.34
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Bady BDG101FRU Card Printer', 'TEC-MA-3329', 'United States', '', 'Texas', 'Austin', 'Aaron Smayling', 'AS-100451402', 'Corporate', 'Standard Class', 'CA-2015-AS10045140-42218', '8/2/2015', '8/8/2015', '', '$1,439.98', 3, 0.4, '-$264.00', 103.62
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Paper', 'Xerox 1998', 'OFF-PA-6557', 'United States', '', 'Texas', 'Austin', 'Aaron Smayling', 'AS-100451402', 'Corporate', 'Standard Class', 'CA-2015-AS10045140-42218', '8/2/2015', '8/8/2015', '', '$36.29', 7, 0.2, '$12.70', 1.99
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hamilton Beach Refrigerator, Silver', 'OFF-AP-4503', 'Mexico', '', 'Distrito Federal', 'Azcapotzalco', 'Adam Hart', 'AH-1007582', 'Corporate', 'Standard Class', 'MX-2015-AH1007582-42139', '5/15/2015', '5/19/2015', '', '$2,003.52', 6, 0, '$861.48', 302.477
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Office Star Executive Leather Armchair, Adjustable', 'FUR-CH-5441', 'Philippines', '', 'Western Visayas', 'Bacolod City', 'Keith Herrera', 'KH-16510102', 'Consumer', 'First Class', 'ID-2015-KH16510102-42052', '2/17/2015', '2/18/2015', '', '$1,046.25', 3, 0.25, '-$111.60', 289.32
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Konica Printer, Durable', 'TEC-MA-5014', 'Iraq', '', 'Baghdad', 'Baghdad', 'Tiffany House', 'TH-1123561', 'Corporate', 'Second Class', 'IZ-2014-TH1123561-41738', '4/9/2014', '4/11/2014', '', '$1,071.84', 4, 0, '$310.80', 220.3
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Office Star Swivel Stool, Set of Two', 'FUR-CH-5457', 'Philippines', '', 'Cordillera', 'Baguio City', 'Theresa Coyne', 'TC-21145102', 'Corporate', 'Standard Class', 'ID-2015-TC21145102-42358', '12/20/2015', '12/24/2015', '', '$1,189.28', 9, 0.25, '-$396.43', 225.78
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Tables', 'Barricks Wood Table, Rectangular', 'FUR-TA-3358', 'Azerbaijan', '', 'Baki', 'Baku', 'John Lee', 'JL-58359', 'Consumer', 'Standard Class', 'AJ-2014-JL58359-41662', '1/23/2014', '1/27/2014', '', '$2,058.00', 4, 0, '$946.68', 393.62
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Sauder Stackable Bookrack, Mobile', 'FUR-BO-5971', 'Australia', '', 'Victoria', 'Ballarat', 'Peter McVee', 'PM-191357', 'Home Office', 'Same Day', 'IN-2013-PM191357-41417', '5/23/2013', '5/23/2013', '', '$660.69', 5, 0.1, '$44.04', 296.01
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Harbour Creations Executive Leather Armchair, Black', 'FUR-CH-4531', 'Turkey', '', 'Balikesir', 'Bandirma', 'Eugene Hildebrand', 'EH-4125134', 'Home Office', 'First Class', 'TU-2015-EH4125134-42068', '3/5/2015', '3/7/2015', '', '$1,136.66', 6, 0.6, '-$880.96', 234.15
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Bush Stackable Bookrack, Traditional', 'FUR-BO-3648', 'Indonesia', '', 'Jawa Barat', 'Bandung', 'Pamela Stobb', 'PS-1876059', 'Consumer', 'Second Class', 'IN-2015-PS1876059-42288', '10/11/2015', '10/13/2015', '', '$1,029.26', 9, 0.07, '$10.82', 354.47
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'Memorex Router, Bluetooth', 'TEC-AC-5223', 'Indonesia', '', 'Jawa Barat', 'Bandung', 'Irene Maddox', 'IM-1507059', 'Consumer', 'First Class', 'IN-2015-IM1507059-42157', '6/2/2015', '6/4/2015', '', '$1,043.93', 8, 0.47, '-$295.51', 234.13
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hamilton Beach Refrigerator, Black', 'OFF-AP-4501', 'Indonesia', '', 'Jawa Barat', 'Bandung', 'Anne McFarland', 'AM-1070559', 'Consumer', 'Second Class', 'ID-2013-AM1070559-41535', '9/18/2013', '9/21/2013', '', '$2,487.81', 6, 0.17, '-$269.79', 562.14
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Sharp Wireless Fax, Color', 'TEC-CO-6009', 'Indonesia', '', 'Jawa Barat', 'Bandung', 'Bill Stewart', 'BS-1138059', 'Corporate', 'Standard Class', 'ID-2013-BS1138059-41577', '10/30/2013', '11/3/2013', '', '$2,991.10', 9, 0.07, '-$128.75', 300.6
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Hewlett Fax Machine, Laser', 'TEC-CO-4578', 'India', '', 'Karnataka', 'Bangalore', 'Craig Yedwab', 'CY-1274558', 'Corporate', 'First Class', 'IN-2015-CY1274558-42300', '10/23/2015', '10/25/2015', '', '$959.76', 3, 0, '$460.62', 317.81
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hamilton Beach Stove, Black', 'OFF-AP-4505', 'Thailand', '', 'Bangkok', 'Bangkok', 'Toby Carlisle', 'TC-21295130', 'Consumer', 'Same Day', 'IN-2014-TC21295130-41962', '11/19/2014', '11/19/2014', '', '$1,798.68', 4, 0.17, '$86.64', 300.5
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Tables', 'Barricks Computer Table, Fully Assembled', 'FUR-TA-3341', 'Thailand', '', 'Bangkok', 'Bangkok', 'Tracy Hopkins', 'TH-21550130', 'Home Office', 'Second Class', 'ID-2013-TH21550130-41634', '12/26/2013', '12/28/2013', '', '$1,854.93', 9, 0.57, '-$1,294.35', 225.02
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Samsung Smart Phone, Full Size', 'TEC-PH-5840', 'Thailand', '', 'Bangkok', 'Bangkok', 'Andrew Allen', 'AA-10480130', 'Consumer', 'Standard Class', 'ID-2015-AA10480130-42080', '3/17/2015', '3/21/2015', '', '$2,645.38', 5, 0.17, '-$0.02', 452.6
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Motorola Smart Phone, Cordless', 'TEC-PH-5267', 'Thailand', '', 'Bangkok', 'Bangkok', 'Brad Norvell', 'BN-11470130', 'Corporate', 'Second Class', 'ID-2013-BN11470130-41633', '12/25/2013', '12/28/2013', '', '$2,667.54', 5, 0.17, '-$417.81', 326.27
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Nokia Smart Phone, with Caller ID', 'TEC-PH-5356', 'Thailand', '', 'Bangkok', 'Bangkok', 'Charles Sheldon', 'CS-12175130', 'Corporate', 'Second Class', 'IN-2014-CS12175130-41788', '5/29/2014', '6/1/2014', '', '$3,181.77', 6, 0.17, '$344.97', 359.09
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Samsung Smart Phone, Cordless', 'TEC-PH-5839', 'Thailand', '', 'Bangkok', 'Bangkok', 'Susan Pistek', 'SP-20920130', 'Consumer', 'Standard Class', 'IN-2014-SP20920130-41808', '6/18/2014', '6/24/2014', '', '$3,712.59', 7, 0.17, '$849.87', 302.99
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Motorola Smart Phone, Full Size', 'TEC-PH-5268', 'Thailand', '', 'Bangkok', 'Bangkok', 'Evan Minnotte', 'EM-14200130', 'Home Office', 'Same Day', 'ID-2013-EM14200130-41502', '8/16/2013', '8/16/2013', '', '$3,741.52', 7, 0.17, '$946.63', 491.91
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'Memorex Router, Erganomic', 'TEC-AC-5224', 'Central African Republic', '', 'Bangui', 'Bangui', 'Steven Cartwright', 'SC-1072524', 'Consumer', 'Second Class', 'CT-2013-SC1072524-41301', '1/27/2013', '1/29/2013', '', '$976.08', 4, 0, '$292.80', 217.62
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Dania Library with Doors, Metal', 'FUR-BO-3901', 'China', '', 'Inner Mongolia', 'Baotou', 'Laura Armstrong', 'LA-1678027', 'Corporate', 'Second Class', 'IN-2015-LA1678027-42148', '5/24/2015', '5/29/2015', '', '$1,447.44', 4, 0, '$43.32', 252.36
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Safco Classic Bookcase, Metal', 'FUR-BO-5760', 'Spain', '', 'Basque Country', 'Barakaldo', 'Rob Beeghly', 'RB-19570120', 'Consumer', 'Standard Class', 'ES-2014-RB19570120-41971', '11/28/2014', '12/4/2014', '', '$3,063.27', 7, 0, '$1,470.21', 419.38
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Hoover Stove, Red', 'OFF-AP-4743', 'Spain', '', 'Catalonia', 'Barcelona', 'Randy Ferguson', 'RF-19345120', 'Corporate', 'First Class', 'ES-2015-RF19345120-42043', '2/8/2015', '2/11/2015', '', '$1,136.94', 2, 0, '$568.44', 307.43
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Rogers Lockers, Blue', 'OFF-ST-5700', 'Spain', '', 'Catalonia', 'Barcelona', 'Pauline Chand', 'PC-19000120', 'Home Office', 'First Class', 'IT-2012-PC19000120-41004', '4/5/2012', '4/7/2012', '', '$1,523.66', 8, 0.1, '-$50.98', 345.81
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Hon Executive Leather Armchair, Adjustable', 'FUR-CH-4654', 'Spain', '', 'Catalonia', 'Barcelona', 'Greg Tran', 'GT-14710120', 'Consumer', 'Standard Class', 'ES-2012-GT14710120-41198', '10/16/2012', '10/23/2012', '', '$1,838.52', 5, 0.2, '$160.77', 324.09
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Breville Refrigerator, Silver', 'OFF-AP-3576', 'Spain', '', 'Catalonia', 'Barcelona', 'Benjamin Patterson', 'BP-11230120', 'Consumer', 'Standard Class', 'ES-2013-BP11230120-41411', '5/17/2013', '5/21/2013', '', '$2,080.32', 4, 0, '$561.60', 296.98
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Epson Inkjet, Wireless', 'TEC-MA-4199', 'Spain', '', 'Catalonia', 'Barcelona', 'Aimee Bixby', 'AB-10150120', 'Consumer', 'Standard Class', 'ES-2013-AB10150120-41588', '11/10/2013', '11/17/2013', '', '$2,219.18', 8, 0.1, '$24.62', 215.35
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Hewlett Wireless Fax, High-Speed', 'TEC-CO-4592', 'Italy', '', 'Apulia', 'Barletta', 'Chloris Kastensmidt', 'CK-1220564', 'Consumer', 'First Class', 'ES-2013-CK1220564-41422', '5/28/2013', '5/31/2013', '', '$1,513.56', 4, 0, '$741.60', 325.45
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Canon Fax and Copier, Laser', 'TEC-CO-3685', 'Switzerland', '', 'Basel-Stadt', 'Basel', 'Harry Marie', 'HM-14860125', 'Corporate', 'First Class', 'ES-2015-HM14860125-42368', '12/30/2015', '1/2/2016', '', '$1,913.40', 10, 0, '$899.10', 236.49
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Storage', 'Smead Lockers, Wire Frame', 'OFF-ST-6049', 'France', '', 'Normandy', 'Bayeux', 'Art Foster', 'AF-1088545', 'Consumer', 'First Class', 'ES-2015-AF1088545-42103', '4/9/2015', '4/12/2015', '', '$1,244.19', 7, 0.1, '-$13.92', 338.33
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'KitchenAid Refrigerator, Black', 'OFF-AP-4960', 'Brazil', '', 'Paraíba', 'Bayeux', 'Bruce Geld', 'BG-1174018', 'Consumer', 'First Class', 'MX-2013-BG1174018-41493', '8/7/2013', '8/8/2013', '', '$2,461.06', 7, 0, '$566.02', 343.809
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'StarTech Inkjet, Durable', 'TEC-MA-6140', 'France', '', 'Aquitaine-Limousin-Poitou-Charentes', 'Bayonne', 'Cyma Kinney', 'CK-1276045', 'Corporate', 'First Class', 'ES-2015-CK1276045-42312', '11/4/2015', '11/7/2015', '', '$765.46', 3, 0.15, '-$36.08', 242.18
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Canon Copy Machine, Color', 'TEC-CO-3678', 'Iran', '', 'Mazandaran', 'Behshahr', 'Trudy Glocke', 'TG-1164060', 'Consumer', 'First Class', 'IR-2015-TG1164060-42265', '9/18/2015', '9/21/2015', '', '$2,108.64', 8, 0, '$527.04', 630.97
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Novimex Executive Leather Armchair, Red', 'FUR-CH-5380', 'China', '', 'Beijing', 'Beijing', 'Ruben Ausman', 'RA-1988527', 'Corporate', 'Standard Class', 'IN-2015-RA1988527-42034', '1/30/2015', '2/3/2015', '', '$2,301.00', 5, 0, '$91.95', 313.45
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Bush Classic Bookcase, Mobile', 'FUR-BO-3625', 'China', '', 'Beijing', 'Beijing', 'Tony Sayre', 'TS-2150527', 'Consumer', 'Standard Class', 'IN-2015-TS2150527-42286', '10/9/2015', '10/13/2015', '', '$2,906.40', 7, 0, '$1,220.52', 216.07
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Tables', 'Bevis Conference Table, Fully Assembled', 'FUR-TA-3420', 'China', '', 'Beijing', 'Beijing', 'Bart Watters', 'BW-1111027', 'Corporate', 'First Class', 'IN-2012-BW1111027-41076', '6/16/2012', '6/18/2012', '', '$3,238.31', 5, 0.3, '-$740.30', 449.18
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Apple Smart Phone, Full Size', 'TEC-PH-3148', 'China', '', 'Beijing', 'Beijing', 'Charles McCrossin', 'CM-1216027', 'Consumer', 'Standard Class', 'IN-2013-CM1216027-41506', '8/20/2013', '8/24/2013', '', '$5,737.50', 9, 0, '$630.99', 261.87
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Okidata Printer, White', 'TEC-MA-5512', 'Indonesia', '', 'Jawa Barat', 'Bekasi', 'Karen Daniels', 'KD-1627059', 'Consumer', 'Second Class', 'ID-2015-KD1627059-42306', '10/29/2015', '10/31/2015', '', '$886.14', 4, 0.17, '$106.74', 226.8
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Binders', 'Zipper Ring Binder Pockets', 'OFF-BI-6634', 'United States', '', 'Washington', 'Bellevue', 'Alan Barnes', 'AB-101651404', 'Consumer', 'Standard Class', 'CA-2015-AB10165140-42344', '12/6/2015', '12/10/2015', '', '$14.98', 6, 0.2, '$5.43', 1.15
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Binders', 'GBC Wire Binding Combs', 'OFF-BI-4378', 'United States', '', 'Washington', 'Bellevue', 'Alan Barnes', 'AB-101651404', 'Consumer', 'Standard Class', 'CA-2015-AB10165140-42344', '12/6/2015', '12/10/2015', '', '$24.82', 3, 0.2, '$8.38', 2.02
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Dania Library with Doors, Pine', 'FUR-BO-3903', 'Australia', '', 'Victoria', 'Bendigo', 'Gary Hwang', 'GH-144257', 'Consumer', 'Standard Class', 'IN-2013-GH144257-41489', '8/3/2013', '8/8/2013', '', '$2,619.00', 8, 0.1, '$232.68', 285.65
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Ikea Classic Bookcase, Pine', 'FUR-BO-4850', 'Angola', '', 'Benguela', 'Benguela', 'Henia Zydlo', 'HZ-49504', 'Consumer', 'Standard Class', 'AO-2012-HZ49504-40916', '1/8/2012', '1/13/2012', '', '$2,478.60', 6, 0, '$49.50', 349.87
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Bookcases', 'Dania Library with Doors, Pine', 'FUR-BO-3903', 'Spain', '', 'Valenciana', 'Benidorm', 'Sean Christensen', 'SC-20305120', 'Consumer', 'Same Day', 'ES-2014-SC20305120-41909', '9/27/2014', '9/27/2014', '', '$1,091.25', 3, 0, '$119.97', 411.64
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Accessories', 'Belkin Router, USB', 'TEC-AC-3405', 'Morocco', '', 'Tadla-Azilal', 'Beni Mellal', 'Roy Phan', 'RP-985586', 'Corporate', 'Standard Class', 'MO-2014-RP985586-41907', '9/25/2014', '10/1/2014', '', '$1,553.76', 6, 0, '$730.26', 245.57
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Machines', 'Epson Inkjet, Durable', 'TEC-MA-4197', 'Norway', '', 'Hordaland', 'Bergen', 'Maribeth Yedwab', 'MY-1738096', 'Corporate', 'Standard Class', 'IT-2014-MY1738096-41794', '6/4/2014', '6/8/2014', '', '$1,533.15', 5, 0, '$505.80', 231.35
EXEC dziedziczak.firma.dodaj_z_xls 'Furniture', 'Chairs', 'Office Star Executive Leather Armchair, Black', 'FUR-CH-5442', 'Netherlands', '', 'North Brabant', 'Bergen op Zoom', 'Valerie Mitchum', 'VM-2168591', 'Home Office', 'Same Day', 'IT-2014-VM2168591-41711', '3/13/2014', '3/13/2014', '', '$2,570.87', 11, 0.5, '-$2,211.17', 520.89
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Motorola Smart Phone, Cordless', 'TEC-PH-5267', 'Germany', '', 'Berlin', 'Berlin', 'Katherine Murray', 'KM-1637548', 'Home Office', 'First Class', 'ES-2014-KM1637548-41667', '1/28/2014', '1/30/2014', '', '$2,892.51', 5, 0.1, '-$96.54', 910.16
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Phones', 'Cisco Smart Phone, with Caller ID', 'TEC-PH-3807', 'Germany', '', 'Berlin', 'Berlin', 'Brosina Hoffman', 'BH-1171048', 'Consumer', 'Standard Class', 'ES-2013-BH1171048-41478', '7/23/2013', '7/28/2013', '', '$2,944.08', 5, 0.1, '$1,112.13', 376.58
EXEC dziedziczak.firma.dodaj_z_xls 'Office Supplies', 'Appliances', 'Cuisinart Stove, Silver', 'OFF-AP-3874', 'Germany', '', 'Berlin', 'Berlin', 'Zuschuss Carroll', 'ZC-2191048', 'Consumer', 'First Class', 'IT-2012-ZC2191048-41174', '9/22/2012', '9/24/2012', '', '$3,018.62', 7, 0.2, '$377.24', 655.91
EXEC dziedziczak.firma.dodaj_z_xls 'Technology', 'Copiers', 'Canon Wireless Fax, High-Speed', 'TEC-CO-3709', 'Germany', '', 'Berlin', 'Berlin', 'David Kendrick', 'DK-1315048', 'Corporate', 'Standard Class', 'ES-2013-DK1315048-41386', '4/22/2013', '4/26/2013', '', '$4,748.44', 14, 0.1, '$844.12', 315.29

GO

IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures p WHERE Name = 'dodaj_zamowienie')
DROP PROCEDURE firma.dodaj_zamowienie

GO

CREATE PROCEDURE firma.dodaj_zamowienie
	@Products as XML,
	@OrderDate DATE,
	@ShipDate DATE,
	@OrderID CHAR(24),
	@CustomerName VARCHAR(50),
	@Segment VARCHAR(50),
	@ShipMode VARCHAR(50),
	@PostalCode VARCHAR(50),
	@City VARCHAR(50)
	AS
	
	BEGIN TRANSACTION 

	declare @fk_customer VARCHAR(50) = NULL
	SELECT @fk_customer = id FROM Customers c WHERE c.CustomerName = @CustomerName 
	IF @fk_customer IS NULL
	BEGIN
		ROLLBACK
	END

	declare @fk_segment INT = NULL
	SELECT @fk_segment = id FROM Segments s WHERE s.Segment = @Segment
	IF @fk_segment IS NULL
	BEGIN
		ROLLBACK
	END

	declare @fk_shipMode INT = NULL
	SELECT @fk_shipMode = id FROM ShipModes sm WHERE sm.ShipMode = @ShipMode
	IF @fk_shipMode IS NULL
	BEGIN
		ROLLBACK
	END

	declare @fk_city INT = NULL
	declare @fk_state INT = NULL
	SELECT @fk_city = c.id, @fk_state = c.fk_state FROM Cities c LEFT JOIN States s ON s.id = c.fk_state WHERE c.City = @City
	IF @fk_city IS NULL AND @fk_state IS NOT NULL
	BEGIN
		ROLLBACK
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
		@fk_customer,
		@fk_segment,
		@fk_shipMode,
		@PostalCode,
		@fk_city,
		@fk_state
	)

	declare @numberOfProducts INT = 0
	select 
	  @numberOfProducts = count(N.value('id[1]', 'varchar(200)'))
	from @Products.nodes('/root/product') as T(N)
	declare @tempOrders table (id INT IDENTITY(1, 1) PRIMARY KEY, OrderId CHAR(24))

	WHILE (select count(*) from @tempOrders) != @numberOfProducts
	BEGIN
		insert @tempOrders values (@OrderID)
	END

	INSERT INTO OrderedProducts (
		fk_order,
		fk_product,
		Sales,
		Quantity,
		Discount,
		Profit,
		ShippingCost)
	SELECT tmpOrders.OrderId,
		tmpProducts.fk_product,
		tmpProducts.Sales,
		tmpProducts.Quantity,
		tmpProducts.Discount,
		tmpProducts.Profit,
		tmpProducts.ShippingCost
		FROM (select 
	  ROW_NUMBER() OVER(ORDER BY N.value('id[1]', 'varchar(200)')) AS num_row,
	  N.value('id[1]', 'varchar(200)') as fk_product,
	  N.value('sales[1]', 'varchar(50)') as Sales,
	  N.value('quantity[1]', 'varchar(50)') as Quantity,
	  N.value('discount[1]', 'varchar(50)') as Discount,
	  N.value('profit[1]', 'varchar(50)') as Profit,
	  N.value('shippingCost[1]', 'varchar(50)') as ShippingCost
	from @Products.nodes('/root/product') as T(N)) as tmpProducts
		LEFT JOIN (SELECT * FROM @tempOrders) as tmpOrders ON tmpOrders.id = tmpProducts.num_row
		
	IF @@ERROR = 0  
	BEGIN
	COMMIT
	END
	ELSE
	BEGIN
	ROLLBACK
	END
GO

DECLARE @Products as XML
SET @Products = N'<root>
	<product><id>TEC-PH-5839</id><sales>540</sales><quantity>10</quantity><discount>0</discount><profit>300</profit><shippingCost>30</shippingCost></product>
	<product><id>TEC-PH-5336</id><sales>500</sales><quantity>1000</quantity><discount>0</discount><profit>300</profit><shippingCost>30</shippingCost></product>
	<product><id>TEC-PH-5839</id><sales>340</sales><quantity>10</quantity><discount>0</discount><profit>300</profit><shippingCost>30</shippingCost></product>
</root>'

EXEC dziedziczak.firma.dodaj_zamowienie @Products, '7/4/2013', '7/4/2013', 'IN-2015-AB101057-66655', 'Adrian Barton', 'Consumer', 'First Class', '9939', 'Adelaide'

GO

/* Zad3.1

Indeksy zgrupowane i niezgrupowane

Jeżeli chodzi o indeks zgrupowany to w SQL Server jest on domyślnie dodawany do każdej kolumny zawierające Primary Key.

Indeks niezgrupowany nakładam na tabelę Customers z kolumną CustomerName.
Robię tak dlatego, że zawiera ona bardzo dużo powtarzających się wartości, które 
powiązane są z "id". W ten sposób wyszukiwanie klientów po ich nazwach będzie bardziej wydajne. 
 */

CREATE NONCLUSTERED INDEX IDX_V1 ON dziedziczak.firma.Customers (CustomerName); 

/* Zad 3.2

Zgodnie z dokumentacją SQL Server nie wspiera tworzenia indeksów gęstych i rzadkich, które 
byłyby możliwe do stworzenia przez jakieś słowa kluczowe języka TSQL. 

Poczytałem jednak o tym i znazlazłem materiały stawowiące, że każdy indeks niezgrupowany jest gęsty
oraz, że każdy indeks zgrupowany jest rzadki.  

Głównie swoją wiedzę oparłem na materiałach:
https://youtu.be/tLD5tCP4jqM
https://youtu.be/lg8S2s_yTh4
https://stackoverflow.com/questions/27387603/how-nonclustered-index-works-in-sql-server

Jeden z prowadzących zasugerował również użycie Sparse Columns jako rozwiązania tego zadania
jednak zgodnie z dokumentacją https://docs.microsoft.com/en-us/sql/relational-databases/tables/use-sparse-columns?view=sql-server-ver15
Sparse Column nie służy do optymalizacji zapytań lecz miejsca zajmującego przez kolumny z wartościami NULL.
 */

-- Zad 3.3

-- Zad 3.4

CREATE FUNCTION firma.wybierzZamowienia(@Country VARCHAR(50), @SubCategory VARCHAR(50))
RETURNS TABLE
AS
RETURN (
 SELECT co.Country, psc.SubCategory, o.OrderID, o.OrderDate, o.ShipDate, p.ProductName, op.Sales, op.Quantity, op.Profit from dziedziczak.firma.OrderedProducts op
	LEFT JOIN dziedziczak.firma.Orders o ON o.OrderID = op.fk_order 
	LEFT JOIN dziedziczak.firma.Products p ON p.ProductId = op.fk_product
	LEFT JOIN dziedziczak.firma.ProductSubCategories psc ON psc.id = p.fk_productSubCategories
	LEFT JOIN dziedziczak.firma.Cities c ON o.fk_city = c.id 
	LEFT JOIN dziedziczak.firma.States s ON s.id = c.fk_state 
	LEFT JOIN dziedziczak.firma.Countries co ON co.id = s.fk_country
	WHERE co.Country LIKE @Country AND psc.SubCategory LIKE @SubCategory
)

GO

SELECT * FROM firma.wybierzZamowienia('France', 'Machines');
-- Możliwe jest także przekazanie % by wybrać wszystkie SubCategory
SELECT * FROM firma.wybierzZamowienia('Iraq', '%');

-- Zad 3.4
/* Utworzenie procedury lub funkcji zwracającej dwa najnowsze zamówienia 
 * (wymagane kolumny wynikowe: order id, order date, product name, sales, customer name)
 * dla każdego klienta w segmencie Consumer (segment = Consumer).
 */ 

CREATE FUNCTION firma.wybierzZamowieniaDlaConsumer()
RETURNS TABLE
AS
RETURN (
SELECT TOP 2 s.Segment, o.OrderID, o.OrderDate, p.ProductName, op.Sales, c.CustomerName FROM dziedziczak.firma.OrderedProducts op 
	LEFT JOIN dziedziczak.firma.Orders o ON o.OrderID = op.fk_order 
	LEFT JOIN dziedziczak.firma.Products p ON p.ProductId = op.fk_product 
	LEFT JOIN dziedziczak.firma.Customers c ON c.id = o.fk_customer 
	LEFT JOIN dziedziczak.firma.Segments s ON s.id = o.fk_segment
	WHERE s.Segment LIKE 'Consumer'
	ORDER BY o.OrderDate DESC
)
GO

SELECT * FROM firma.wybierzZamowieniaDlaConsumer();


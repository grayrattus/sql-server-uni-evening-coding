IF EXISTS(select * from master.sys.databases where name='firma')
DROP DATABASE firma

CREATE DATABASE firma;
CREATE TABLE firma.dbo.typ_pracownika
(
	id INT PRIMARY KEY,
	typ NVARCHAR(20) not null unique
);

insert into firma.dbo.typ_pracownika(id, typ) values (1, 'szef'),(2,'kierowca'),(3, 'biuro');

CREATE TABLE firma.dbo.pracownik
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	imie NVARCHAR(40),
	nazwisko NVARCHAR(40),
    id_typ INT not null, 
    id_magazyn INT not null,
);

CREATE TABLE firma.dbo.pracownik_to_rozklad_godzin(
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_pracownik INT not null,
	id_rozklad_godzin INT not null,
)

CREATE TABLE firma.dbo.rozklad_godzin
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	ilosc_godzin INT not null,
	data_wpisu datetime not null
);

CREATE TABLE firma.dbo.magazyn(
	id INT IDENTITY(1,1) PRIMARY KEY,
	nazwa NVARCHAR(40),
	lat FLOAT,
    lon FLOAT, 
);

CREATE TABLE firma.dbo.pojazd(
	id INT IDENTITY(1,1)PRIMARY KEY,
	id_pracownik INT not null,
	marka NVARCHAR(100),
	uszkodzony BIT,
	id_magazyn INT not null,
);

CREATE TABLE firma.dbo.pojazd_w_uzyciu(
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_pojazd INT NOT NULL,
	id_ostatnia_pozycja INT NOT NULL
);

CREATE TABLE firma.dbo.ostatnia_pozycja_pojazdu(
	id INT IDENTITY(1,1) PRIMARY KEY,
	data_aktualizacji datetime not null,
	notatka NVARCHAR(20),
	lat FLOAT,
	lon FLOAT
);

ALTER table firma.dbo.pracownik add constraint fk_typ_pracownika foreign key (id_typ) references firma.dbo.typ_pracownika (id);
ALTER table firma.dbo.pracownik add constraint fk_magazyn foreign key (id_magazyn) references firma.dbo.magazyn(id);

ALTER table firma.dbo.pojazd add constraint fk_pojazd_w_magazynie foreign key (id_magazyn) references firma.dbo.magazyn(id);

ALTER table firma.dbo.pracownik_to_rozklad_godzin add constraint fk_pracownik foreign key (id_pracownik) references firma.dbo.pracownik (id);
ALTER table firma.dbo.pracownik_to_rozklad_godzin add constraint fk_rozklad_godzin foreign key (id_rozklad_godzin) references firma.dbo.rozklad_godzin (id);

ALTER table firma.dbo.pojazd_w_uzyciu add constraint fk_pojazd foreign key (id_pojazd) references firma.dbo.pojazd(id);
ALTER table firma.dbo.pojazd_w_uzyciu add constraint fk_ostatnia_pozycja foreign key (id_ostatnia_pozycja) references firma.dbo.ostatnia_pozycja_pojazdu(id);

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_magazyn')
DROP PROCEDURE dodaj_magazyn

GO
CREATE PROCEDURE dodaj_magazyn @nazwa NVARCHAR(40), @lat FLOAT, @lon FLOAT AS 
	INSERT INTO firma.dbo.magazyn(nazwa, lat, lon)
	VALUES (@nazwa, @lat, @lon);

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_pracownika')
DROP PROCEDURE dodaj_pracownika

GO
CREATE PROCEDURE dodaj_pracownika @imie NVARCHAR(40), @nazwisko NVARCHAR(40), @typ NVARCHAR(40), @id_magazyn INT AS 
	declare @typ_id int

	select @typ_id = id from firma.dbo.typ_pracownika tp where tp.typ LIKE @typ
	PRINT @typ_id

	INSERT INTO firma.dbo.pracownik (imie, nazwisko, id_typ, id_magazyn)
	VALUES (@imie, @nazwisko, @typ_id, @id_magazyn)

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_pojazd')
DROP PROCEDURE dodaj_pojazd

GO
CREATE PROCEDURE dodaj_pojazd @id_pracownik INT, @marka NVARCHAR(40), @id_magazyn INT AS 
	INSERT INTO firma.dbo.pojazd (id_pracownik, marka, id_magazyn)
	VALUES (@id_pracownik, @marka, @id_magazyn)

	declare @lat_magazyn FLOAT
	declare @lon_magazyn FLOAT

	SELECT @lat_magazyn = m.lat, @lon_magazyn = m.lon FROM firma.dbo.magazyn m 
		WHERE m.id = @id_magazyn
	
	declare @id_pojazd INT
	SELECT @id_pojazd = SCOPE_IDENTITY()

	INSERT INTO firma.dbo.ostatnia_pozycja_pojazdu (lat ,lon, data_aktualizacji, notatka) VALUES
		(@lat_magazyn, @lon_magazyn, SYSDATETIME(), 'PIERWSZA_BAZA')

	declare @id_ostatniej_pozycji_pojazdu INT
	SELECT @id_ostatniej_pozycji_pojazdu = SCOPE_IDENTITY()

	INSERT INTO firma.dbo.pojazd_w_uzyciu (id_pojazd, id_ostatnia_pozycja)
		VALUES (@id_pojazd, @id_ostatniej_pozycji_pojazdu)


GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu')
DROP PROCEDURE uaktualnij_pozycje_pojazdu
GO
CREATE PROCEDURE uaktualnij_pozycje_pojazdu @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	INSERT INTO firma.dbo.ostatnia_pozycja_pojazdu(data_aktualizacji, lat, lon, notatka)
		VALUES (SYSDATETIME(), @lat, @lon, 'ZMIANA_POZYCJI')

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu_z_interwalem')
DROP PROCEDURE uaktualnij_pozycje_pojazdu_z_interwalem

GO
-- Jeżeli ostatnia data dla danego pojazdu jest mniejsza niż 15 minut to 
-- dodaj nową pozycję. W ten sposób posiadamy historię tego jak poruszał się
-- pojazd.
CREATE PROCEDURE uaktualnij_pozycje_pojazdu_z_interwalem @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	IF NOT EXISTS(SELECT pwu.id from firma.dbo.pojazd_w_uzyciu pwu LEFT 
		JOIN firma.dbo.ostatnia_pozycja_pojazdu opp ON  pwu.id_ostatnia_pozycja = opp.id 
		WHERE pwu.id_pojazd  = @id_pojazd AND DATEDIFF(MINUTE,opp.data_aktualizacji, SYSDATETIME()) < 15)
	BEGIN
		EXEC uaktualnij_pozycje_pojazdu @id_pojazd, @lat, @lon
	END
	ELSE
	BEGIN
		PRINT 'Ostatnia pozycja jest młodsza niż 15 minut'
	END

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'zakoncz_zmiane')
DROP PROCEDURE zakoncz_zmiane

GO
-- Procedura kończy zmianę pracownika i dodaje go do rozkładu godzin
CREATE PROCEDURE zakoncz_zmiane @id_pracownik INT, @liczba_godzin_w_dniu INT AS 
	INSERT INTO firma.dbo.rozklad_godzin(ilosc_godzin, data_wpisu) VALUES (@liczba_godzin_w_dniu, SYSDATETIME())

	declare @id_rozklad_godzin INT
	SELECT @id_rozklad_godzin = SCOPE_IDENTITY()

	INSERT INTO firma.dbo.pracownik_to_rozklad_godzin (id_pracownik, id_rozklad_godzin) 
		VALUES (@id_pracownik, @id_rozklad_godzin)

GO
EXEC dodaj_magazyn 'Green shop', 59.09, 69.01;
EXEC dodaj_magazyn 'Black shop', 59.09, 69.01;
GO
EXEC dodaj_pracownika 'Artur', 'Dziedziczak', 'szef', 1;
EXEC dodaj_pracownika 'Karol', 'Marcinkiewicz', 'kierowca', 1;
EXEC dodaj_pracownika 'Abram', 'Zagram', 'kierowca', 1;
EXEC dodaj_pracownika 'Marcin', 'Kamrat', 'kierowca', 2;
EXEC dodaj_pracownika 'Jaszczur', 'Jabłonowski', 'szef', 2;
EXEC dodaj_pracownika 'Piotr', 'Uszaty', 'kierowca', 2;

GO
EXEC dodaj_pojazd 2, 'Scania Toscania', 1;
EXEC dodaj_pojazd 3, 'Scania Toscania', 1;
EXEC dodaj_pojazd 4, 'Scania', 1;
EXEC dodaj_pojazd 5, 'Jelcz', 1

GO
-- To zapytanie nie powinno się wykonać ponieważ gdy samochód jest dodawany do bazy dodawana jest
-- też jego lokalizacja.
-- Powinno działać po 15 minutach od dodania do bazy.
EXEC uaktualnij_pozycje_pojazdu_z_interwalem 1, 55.55, 99.0;
-- Muszę też wypełnić trochę więcej danych więc dodaje pomocniczą procedurę, która
-- uaktualnia pozycje pojazdu bez sprawdzenia interwału 15 minut
EXEC uaktualnij_pozycje_pojazdu 1, 55.55, 99.0;
EXEC uaktualnij_pozycje_pojazdu 1, 55.55, 99.0;
EXEC uaktualnij_pozycje_pojazdu 2, 55.55, 99.0;
EXEC uaktualnij_pozycje_pojazdu 3, 55.55, 99.0;

GO
-- Procedury kończące zmiany pracowników
EXEC zakoncz_zmiane 1, 8
EXEC zakoncz_zmiane 2, 8;
EXEC zakoncz_zmiane 3, 8;

GO
IF EXISTS(SELECT 1 FROM sys.views WHERE Name = 'ostatnie_pozycje_pojazdu')
DROP VIEW ostatnie_pozycje_pojazdu

GO
CREATE VIEW ostatnie_pozycje_pojazdu AS
	SELECT pwu.id_pojazd, opp.lat, opp.lon, MAX(opp.data_aktualizacji) as data_aktualizacji
		 FROM firma.dbo.pojazd_w_uzyciu pwu 
		 LEFT JOIN firma.dbo.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
		 GROUP BY pwu.id_pojazd , opp.lat, opp.lon, opp.data_aktualizacji 

GO
IF EXISTS(SELECT 1 FROM sys.views WHERE Name = 'godziny_pracy_pracownikow')
DROP VIEW godziny_pracy_pracownikow
GO
CREATE VIEW godziny_pracy_pracownikow AS
	SELECT p.id, p.imie, p.nazwisko, SUM(rg.ilosc_godzin) as suma_godzin FROM firma.dbo.pracownik_to_rozklad_godzin ptrg 
		LEFT JOIN firma.dbo.pracownik p ON ptrg.id_pracownik = ptrg.id_pracownik 
		LEFT JOIN firma.dbo.rozklad_godzin rg ON rg.id = ptrg.id_rozklad_godzin 
		GROUP BY rg.ilosc_godzin, p.id, p.imie, p.nazwisko 
		
	SELECT pwu.id_pojazd, opp.lat, opp.lon, MAX(opp.data_aktualizacji) as data_aktualizacji
		 FROM firma.dbo.pojazd_w_uzyciu pwu 
		 LEFT JOIN firma.dbo.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
		 GROUP BY pwu.id_pojazd , opp.lat, opp.lon, opp.data_aktualizacji 
	
	
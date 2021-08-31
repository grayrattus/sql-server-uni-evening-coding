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
	id INT PRIMARY KEY,
	id_pracownik INT not null,
	id_rozklad_godzin INT not null,
)

CREATE TABLE firma.dbo.rozklad_godzin
(
	id INT PRIMARY KEY,
	ilosc_godzin INT not null,
	data_wpisu date not null
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
	data_aktualizacji date not null,
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
		(@lat_magazyn, @lon_magazyn, GETDATE(), 'PIERWSZA_BAZA')

	declare @id_ostatniej_pozycji_pojazdu INT
	SELECT @id_ostatniej_pozycji_pojazdu = SCOPE_IDENTITY()

	INSERT INTO firma.dbo.pojazd_w_uzyciu (id_pojazd, id_ostatnia_pozycja)
		VALUES (@id_pojazd, @id_ostatniej_pozycji_pojazdu)

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu')
DROP PROCEDURE uaktualnij_pozycje_pojazdu

GO
CREATE PROCEDURE uaktualnij_pozycje_pojazdu @id_pracownik INT, @marka NVARCHAR(40), @id_magazyn INT AS 
	INSERT INTO firma.dbo.pojazd (id_pracownik, marka, id_magazyn)
	VALUES (@id_pracownik, @marka, @id_magazyn)
	
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
EXEC dodaj_pojazd 5, 'Jelcz', 1;



-- Najpierw przełączam się na master żeby utworzyć bazę danych
USE master
-- Jeżeli istnieje baza to ją usuwam
DROP DATABASE IF EXISTS dziedziczak;

-- Tworzę bazę danych
CREATE DATABASE	dziedziczak

-- Te wyrażenia GO są potrzebne jeżeli nie używa się SQL Managment Studio
-- Ja używałem dBeaver i serwer zwracał mi odpowiedź, że nie mogę używać
-- niektórych komend w jednym bloku instrukcji.
GO
USE dziedziczak

GO
-- Jeżeli schema istnieje to ją usuwam
DROP SCHEMA IF EXISTS firma

GO
CREATE SCHEMA firma

-- Tutaj rozpoczynam tworzenie tabel
-- Nie definiuję tutaj auto increment ponieważ w przyszłości może
-- przyjść wymaganie do zmiany id typów i mogłoby to powodować problemy
CREATE TABLE dziedziczak.firma.typ_pracownika
(
	id INT PRIMARY KEY,
	typ NVARCHAR(20) not null unique
);

-- Od razu dodaje wymagane typy do tabeli
insert into dziedziczak.firma.typ_pracownika(id, typ) values (1, 'szef'),(2,'kierowca'),(3, 'biuro');

-- Typowa tabela dla pracownika
CREATE TABLE dziedziczak.firma.pracownik
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	imie NVARCHAR(40) not null,
	nazwisko NVARCHAR(40) not null,
	id_typ INT not null, 
	id_magazyn INT not null,
);

-- Używam tutaj IDENTITTY(1,1) aby ID było inkrementowane o 1
CREATE TABLE dziedziczak.firma.pracownik_to_rozklad_godzin(
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_pracownik INT not null,
	id_rozklad_godzin INT not null,
)

-- Tutaj ustawiam datetime żeby SQL server przechowywał również czas
-- a nie tylko date
CREATE TABLE dziedziczak.firma.rozklad_godzin
(
	id INT IDENTITY(1,1) PRIMARY KEY,
	ilosc_godzin INT not null,
	data_wpisu datetime not null
);

-- lat, long daje na float gdyż nie interesuje mnie jakaś olbrzymia precyzja
CREATE TABLE dziedziczak.firma.magazyn(
	id INT IDENTITY(1,1) PRIMARY KEY,
	nazwa NVARCHAR(40),
	lat FLOAT not null,
	lon FLOAT not null, 
);

-- jako, że SQL server nie ma boolean to używam do przechowywania
-- binarnego stanu typu BIT.
-- Ta tabela realizuje historyjkę 2.
CREATE TABLE dziedziczak.firma.pojazd(
	id INT IDENTITY(1,1)PRIMARY KEY,
	id_pracownik INT not null,
	marka NVARCHAR(100),
	uszkodzony BIT not null default 0,
	id_magazyn INT not null,
);

CREATE TABLE dziedziczak.firma.pojazd_w_uzyciu(
	id INT IDENTITY(1,1) PRIMARY KEY,
	id_pojazd INT NOT NULL,
	id_ostatnia_pozycja INT NOT NULL,
	id_ostatni_pracownik INT NOT NULL
);

CREATE TABLE dziedziczak.firma.ostatnia_pozycja_pojazdu(
	id INT IDENTITY(1,1) PRIMARY KEY,
	data_aktualizacji datetime not null,
	notatka NVARCHAR(20),
	lat FLOAT not null,
	lon FLOAT not null
);

-- Wszystkie więzy integralności dodaję po stworzeniu tabel tak aby
-- nie musieć przestrzegać kolejności definiowania relacji
ALTER table dziedziczak.firma.pracownik add constraint fk_typ_pracownika foreign key (id_typ) references dziedziczak.firma.typ_pracownika (id);
ALTER table dziedziczak.firma.pracownik add constraint fk_magazyn foreign key (id_magazyn) references dziedziczak.firma.magazyn(id);

ALTER table dziedziczak.firma.pojazd add constraint fk_pojazd_w_magazynie foreign key (id_magazyn) references dziedziczak.firma.magazyn(id);

-- Jest kilka tabeli z więzami wiele do wielu
-- Tutaj jest przykład jednej z nich
ALTER table dziedziczak.firma.pracownik_to_rozklad_godzin add constraint fk_pracownik foreign key (id_pracownik) references dziedziczak.firma.pracownik (id);
ALTER table dziedziczak.firma.pracownik_to_rozklad_godzin add constraint fk_rozklad_godzin foreign key (id_rozklad_godzin) references dziedziczak.firma.rozklad_godzin (id);

ALTER table dziedziczak.firma.pojazd_w_uzyciu add constraint fk_pojazd foreign key (id_pojazd) references dziedziczak.firma.pojazd(id);
ALTER table dziedziczak.firma.pojazd_w_uzyciu add constraint fk_ostatnia_pozycja foreign key (id_ostatnia_pozycja) references dziedziczak.firma.ostatnia_pozycja_pojazdu(id);
ALTER table dziedziczak.firma.pojazd_w_uzyciu add constraint fk_ostatni_pracownik foreign key (id_ostatni_pracownik) references dziedziczak.firma.pracownik(id);
GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'dodaj_magazyn')
DROP PROCEDURE firma.dodaj_magazyn

GO
-- Procedura dodająca magazyn do bazy
CREATE PROCEDURE firma.dodaj_magazyn @nazwa NVARCHAR(40), @lat FLOAT, @lon FLOAT AS 
	INSERT INTO dziedziczak.firma.magazyn(nazwa, lat, lon)
	VALUES (@nazwa, @lat, @lon);

GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'dodaj_pracownika')
DROP PROCEDURE firma.dodaj_pracownika

GO
-- Procedura dodająca pracownika do bazy danych
-- Dla ułatwienia typ przekazywany jest jako NVARCHAR
-- następnie wyszukiwany jest określony typ i "id" tego typu następnie
-- wiąże rekord pracownika z typem
CREATE PROCEDURE firma.dodaj_pracownika @imie NVARCHAR(40), @nazwisko NVARCHAR(40), @typ NVARCHAR(40), @id_magazyn INT AS 
	declare @typ_id int

	select @typ_id = id from dziedziczak.firma.typ_pracownika tp where tp.typ LIKE @typ

	INSERT INTO dziedziczak.firma.pracownik (imie, nazwisko, id_typ, id_magazyn)
	VALUES (@imie, @nazwisko, @typ_id, @id_magazyn)

GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'dodaj_pojazd')
DROP PROCEDURE firma.dodaj_pojazd

GO
-- Procedura dodająca pojazd do bazy danych
-- Procedura ta pobiera dane pojazdu i magazynu, do którego zostanie on
-- dodany. Jest to potrzebne ponieważ domyślna "ostatnia_pozycja_pojazdu"
-- jest ustawiana jako lokalizacja magazynu.
CREATE PROCEDURE firma.dodaj_pojazd @id_pracownik INT, @marka NVARCHAR(40), @id_magazyn INT AS 
	INSERT INTO dziedziczak.firma.pojazd (id_pracownik, marka, id_magazyn)
	VALUES (@id_pracownik, @marka, @id_magazyn)

	declare @lat_magazyn FLOAT
	declare @lon_magazyn FLOAT

	SELECT @lat_magazyn = m.lat, @lon_magazyn = m.lon FROM dziedziczak.firma.magazyn m 
		WHERE m.id = @id_magazyn
	
	declare @id_pojazd INT
	SELECT @id_pojazd = SCOPE_IDENTITY()

	INSERT INTO dziedziczak.firma.ostatnia_pozycja_pojazdu (lat ,lon, data_aktualizacji, notatka) VALUES
		(@lat_magazyn, @lon_magazyn, SYSDATETIME(), 'PIERWSZA_BAZA')

	declare @id_ostatniej_pozycji_pojazdu INT
	SELECT @id_ostatniej_pozycji_pojazdu = SCOPE_IDENTITY()

	INSERT INTO dziedziczak.firma.pojazd_w_uzyciu (id_pojazd, id_ostatnia_pozycja, id_ostatni_pracownik)
		VALUES (@id_pojazd, @id_ostatniej_pozycji_pojazdu, @id_pracownik)


GO
-- Procedura uaktualniająca pozycję pojazdu
-- Uaktualnienie pozycji dodaje nowy rekord do tabeli. Uznałem, że to jest
-- najelepsze rozwiązanie ponieważ od razu zachowywana jest historia
-- tego gdzie pojazd logował swoją pozycje. Również czas dodania rekordu
-- ustawiony jest na SYSDATETIME() a notatka na "ZMIANA_POZYCJI"
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu')
DROP PROCEDURE firma.uaktualnij_pozycje_pojazdu
GO
CREATE PROCEDURE firma.uaktualnij_pozycje_pojazdu @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	INSERT INTO dziedziczak.firma.ostatnia_pozycja_pojazdu(data_aktualizacji, lat, lon, notatka)
		VALUES (SYSDATETIME(), @lat, @lon, 'ZMIANA_POZYCJI')

GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu_z_interwalem')
DROP PROCEDURE firma.uaktualnij_pozycje_pojazdu_z_interwalem

GO
-- Procedura realizuje historyjkę 5
-- Jeżeli ostatnia data dla danego pojazdu jest mniejsza niż 15 minut to 
-- dodaj nową pozycję. W ten sposób posiadamy historię tego jak poruszał się
-- pojazd. Jeżeli czas jest mniejszy to loguję w serwerzę informację o 
-- zapytaniu.
CREATE PROCEDURE firma.uaktualnij_pozycje_pojazdu_z_interwalem @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	IF NOT EXISTS(SELECT pwu.id from dziedziczak.firma.pojazd_w_uzyciu pwu LEFT 
		JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON  pwu.id_ostatnia_pozycja = opp.id 
		WHERE pwu.id_pojazd  = @id_pojazd AND DATEDIFF(MINUTE,opp.data_aktualizacji, SYSDATETIME()) < 15)
	BEGIN
		EXEC firma.uaktualnij_pozycje_pojazdu @id_pojazd, @lat, @lon
	END
	ELSE
	BEGIN
		PRINT 'Ostatnia pozycja jest młodsza niż 15 minut'
	END

GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.procedures WHERE Name = 'zakoncz_zmiane')
DROP PROCEDURE firma.zakoncz_zmiane

GO
-- Procedura realizuje historyjkę 3
-- Procedura kończy zmianę pracownika i dodaje go do rozkładu godzin
-- Używam tutaj SCOPE_IDENTITY() ponieważ interesują mnie tylko rekordy
-- dodane w tej procedurze. Z tego co czytałem można tutaj popełnić błąd
-- i ustawić SCOPE na całą bazę danych.
CREATE PROCEDURE firma.zakoncz_zmiane @id_pracownik INT, @liczba_godzin_w_dniu INT AS 
	INSERT INTO dziedziczak.firma.rozklad_godzin(ilosc_godzin, data_wpisu) VALUES (@liczba_godzin_w_dniu, SYSDATETIME())

	declare @id_rozklad_godzin INT
	SELECT @id_rozklad_godzin = SCOPE_IDENTITY()

	INSERT INTO dziedziczak.firma.pracownik_to_rozklad_godzin (id_pracownik, id_rozklad_godzin) 
		VALUES (@id_pracownik, @id_rozklad_godzin)

GO
EXEC dziedziczak.firma.dodaj_magazyn 'Green shop', 59.09, 69.01;
EXEC dziedziczak.firma.dodaj_magazyn 'Black shop', 59.09, 69.01;
GO
EXEC dziedziczak.firma.dodaj_pracownika 'Artur', 'Dziedziczak', 'szef', 1;
EXEC dziedziczak.firma.dodaj_pracownika 'Karol', 'Marcinkiewicz', 'kierowca', 1;
EXEC dziedziczak.firma.dodaj_pracownika 'Abram', 'Zagram', 'kierowca', 1;
EXEC dziedziczak.firma.dodaj_pracownika 'Marcin', 'Kamrat', 'kierowca', 2;
EXEC dziedziczak.firma.dodaj_pracownika 'Jaszczur', 'Jabłonowski', 'szef', 2;
EXEC dziedziczak.firma.dodaj_pracownika 'Piotr', 'Uszaty', 'kierowca', 2;

GO
EXEC dziedziczak.firma.dodaj_pojazd 2, 'Scania Toscania', 1;
EXEC dziedziczak.firma.dodaj_pojazd 3, 'Scania Toscania', 1;
EXEC dziedziczak.firma.dodaj_pojazd 4, 'Scania', 1;
EXEC dziedziczak.firma.dodaj_pojazd 5, 'Jelcz', 1

GO
-- To zapytanie nie powinno się wykonać ponieważ gdy samochód jest dodawany do bazy to dodawana jest
-- również jego lokalizacja.
-- Powinno działać po 15 minutach od dodania do bazy.
EXEC dziedziczak.firma.uaktualnij_pozycje_pojazdu_z_interwalem 1, 55.55, 99.0;

-- Muszę też wypełnić trochę więcej danych więc dodaje pomocniczą procedurę, która
-- uaktualnia pozycje pojazdu bez sprawdzenia interwału 15 minut
EXEC dziedziczak.firma.uaktualnij_pozycje_pojazdu 1, 55.55, 99.0;
EXEC dziedziczak.firma.uaktualnij_pozycje_pojazdu 1, 55.55, 99.0;
EXEC dziedziczak.firma.uaktualnij_pozycje_pojazdu 2, 55.55, 99.0;
EXEC dziedziczak.firma.uaktualnij_pozycje_pojazdu 3, 55.55, 99.0;

GO
-- Procedury kończące zmiany pracowników
EXEC dziedziczak.firma.zakoncz_zmiane 1, 8
EXEC dziedziczak.firma.zakoncz_zmiane 2, 8;
EXEC dziedziczak.firma.zakoncz_zmiane 3, 8;GO
-- Widok realizuje historyjkę 1
-- Pozwala on na określenie ostatnich lokalizacji pojazów.
-- Logika jest skonstruowana tak, że pobieram potrzebne dane a następnie
-- grupuje je po "data_aktualizacji". To powoduje, że mogę użyć na tym 
-- polu funkcji agregującej MAX. W ten sposób otrzymuje ostatnie daty
-- pozycji danego samochodu.
IF EXISTS(SELECT 1 FROM dziedziczak.sys.views WHERE Name = 'ostatnie_pozycje_pojazdu')
DROP VIEW firma.ostatnie_pozycje_pojazdu
GO
CREATE VIEW firma.ostatnie_pozycje_pojazdu AS
	SELECT pwu.id_pojazd, opp.lat, opp.lon, MAX(opp.data_aktualizacji) as data_aktualizacji
		 FROM dziedziczak.firma.pojazd_w_uzyciu pwu 
		 LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
		 GROUP BY pwu.id_pojazd , opp.lat, opp.lon, opp.data_aktualizacji 

GO
-- Widok realizuje historyjkę 3
-- Widok pozwala na wyświetlenie sum godzin pracy pracowników w ostatnim
-- miesiącu. Najważniejszym elementem jest funkcja agregująca SUM() oraz
-- klauzura WHERE, która to wybiera "data_wpisu" w czasie dłuższym niż
-- ostatni miesiąc.
IF EXISTS(SELECT 1 FROM dziedziczak.sys.views WHERE Name = 'godziny_pracy_pracownikow')
DROP VIEW firma.godziny_pracy_pracownikow
GO
CREATE VIEW firma.godziny_pracy_pracownikow AS
	SELECT p.id, p.imie, p.nazwisko, SUM(rg.ilosc_godzin) as suma_godzin FROM dziedziczak.firma.pracownik_to_rozklad_godzin ptrg 
		LEFT JOIN dziedziczak.firma.pracownik p ON ptrg.id_pracownik = ptrg.id_pracownik 
		LEFT JOIN dziedziczak.firma.rozklad_godzin rg ON rg.id = ptrg.id_rozklad_godzin 
		WHERE rg.data_wpisu >= DATEADD(M,-1, GETDATE())
		GROUP BY rg.ilosc_godzin, p.id, p.imie, p.nazwisko 

GO
IF EXISTS(SELECT 1 FROM dziedziczak.sys.views WHERE Name = 'ostatni_kierowcy_samochodow')
DROP VIEW firma.ostatni_kierowcy_samochodow
GO
-- Widok realizuje historyjkę 4
-- 3 LEFT JOIN-y na tabelach, które pozwalają na wybranie informacji o tym
-- który pracownik ostatni używał pojazdu.
-- Najważniejszym elementem tego widoku jest funkcja grupująca GROUP BY oraz
-- agregująca MAX(opp.data_aktualizacji). Ta kombinacja pozwala na wybranie
-- ostatnich dat dla poszczególnych marek samochodów.
CREATE VIEW firma.ostatni_kierowcy_samochodow AS
	SELECT DISTINCT(p.id), p.imie + ' ' + p.nazwisko as imie_i_nazwisko, po.marka, MAX(opp.data_aktualizacji) as data_aktualizacji FROM dziedziczak.firma.pojazd_w_uzyciu pwu 
	LEFT JOIN dziedziczak.firma.pracownik p ON p.id = pwu.id_ostatni_pracownik
	LEFT JOIN dziedziczak.firma.pojazd po ON po.id = pwu.id_pojazd 
	LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
	GROUP BY p.id, po.marka, p.imie, p.nazwisko, opp.data_aktualizacji 
		
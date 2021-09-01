GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_magazyn')
DROP PROCEDURE dodaj_magazyn

GO
-- Procedura dodająca magazyn do bazy
CREATE PROCEDURE dodaj_magazyn @nazwa NVARCHAR(40), @lat FLOAT, @lon FLOAT AS 
	INSERT INTO dziedziczak.firma.magazyn(nazwa, lat, lon)
	VALUES (@nazwa, @lat, @lon);

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_pracownika')
DROP PROCEDURE dodaj_pracownika

GO
-- Procedura dodająca pracownika do bazy danych
-- Dla ułatwienia typ przekazywany jest jako NVARCHAR
-- następnie wyszukiwany jest określony typ i "id" tego typu następnie
-- wiąże rekord pracownika z typem
CREATE PROCEDURE dodaj_pracownika @imie NVARCHAR(40), @nazwisko NVARCHAR(40), @typ NVARCHAR(40), @id_magazyn INT AS 
	declare @typ_id int

	select @typ_id = id from dziedziczak.firma.typ_pracownika tp where tp.typ LIKE @typ

	INSERT INTO dziedziczak.firma.pracownik (imie, nazwisko, id_typ, id_magazyn)
	VALUES (@imie, @nazwisko, @typ_id, @id_magazyn)

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'dodaj_pojazd')
DROP PROCEDURE dodaj_pojazd

GO
-- Procedura dodająca pojazd do bazy danych
-- Procedura ta pobiera dane pojazdu i magazynu, do którego zostanie on
-- dodany. Jest to potrzebne ponieważ domyślna "ostatnia_pozycja_pojazdu"
-- jest ustawiana jako lokalizacja magazynu.
CREATE PROCEDURE dodaj_pojazd @id_pracownik INT, @marka NVARCHAR(40), @id_magazyn INT AS 
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
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu')
DROP PROCEDURE uaktualnij_pozycje_pojazdu
GO
CREATE PROCEDURE uaktualnij_pozycje_pojazdu @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	INSERT INTO dziedziczak.firma.ostatnia_pozycja_pojazdu(data_aktualizacji, lat, lon, notatka)
		VALUES (SYSDATETIME(), @lat, @lon, 'ZMIANA_POZYCJI')

GO
IF EXISTS(SELECT 1 FROM sys.procedures WHERE Name = 'uaktualnij_pozycje_pojazdu_z_interwalem')
DROP PROCEDURE uaktualnij_pozycje_pojazdu_z_interwalem

GO
-- Procedura realizuje historyjkę 5
-- Jeżeli ostatnia data dla danego pojazdu jest mniejsza niż 15 minut to 
-- dodaj nową pozycję. W ten sposób posiadamy historię tego jak poruszał się
-- pojazd. Jeżeli czas jest mniejszy to loguję w serwerzę informację o 
-- zapytaniu.
CREATE PROCEDURE uaktualnij_pozycje_pojazdu_z_interwalem @id_pojazd INT, @lat FLOAT, @lon FLOAT  AS 
	IF NOT EXISTS(SELECT pwu.id from dziedziczak.firma.pojazd_w_uzyciu pwu LEFT 
		JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON  pwu.id_ostatnia_pozycja = opp.id 
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
-- Procedura realizuje historyjkę 3
-- Procedura kończy zmianę pracownika i dodaje go do rozkładu godzin
-- Używam tutaj SCOPE_IDENTITY() ponieważ interesują mnie tylko rekordy
-- dodane w tej procedurze. Z tego co czytałem można tutaj popełnić błąd
-- i ustawić SCOPE na całą bazę danych.
CREATE PROCEDURE zakoncz_zmiane @id_pracownik INT, @liczba_godzin_w_dniu INT AS 
	INSERT INTO dziedziczak.firma.rozklad_godzin(ilosc_godzin, data_wpisu) VALUES (@liczba_godzin_w_dniu, SYSDATETIME())

	declare @id_rozklad_godzin INT
	SELECT @id_rozklad_godzin = SCOPE_IDENTITY()

	INSERT INTO dziedziczak.firma.pracownik_to_rozklad_godzin (id_pracownik, id_rozklad_godzin) 
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
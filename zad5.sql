GO
-- Widok realizuje historyjkę 1
-- Pozwala on na określenie ostatnich lokalizacji pojazów.
-- Logika jest skonstruowana tak, że pobieram potrzebne dane a następnie
-- grupuje je po "data_aktualizacji". To powoduje, że mogę użyć na tym 
-- polu funkcji agregującej MAX. W ten sposób otrzymuje ostatnie daty
-- pozycji danego samochodu.
IF EXISTS(SELECT 1 FROM sys.views WHERE Name = 'ostatnie_pozycje_pojazdu')
DROP VIEW ostatnie_pozycje_pojazdu
GO
CREATE VIEW ostatnie_pozycje_pojazdu AS
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
IF EXISTS(SELECT 1 FROM sys.views WHERE Name = 'godziny_pracy_pracownikow')
DROP VIEW godziny_pracy_pracownikow
GO
CREATE VIEW godziny_pracy_pracownikow AS
	SELECT p.id, p.imie, p.nazwisko, SUM(rg.ilosc_godzin) as suma_godzin FROM dziedziczak.firma.pracownik_to_rozklad_godzin ptrg 
		LEFT JOIN dziedziczak.firma.pracownik p ON ptrg.id_pracownik = ptrg.id_pracownik 
		LEFT JOIN dziedziczak.firma.rozklad_godzin rg ON rg.id = ptrg.id_rozklad_godzin 
		WHERE rg.data_wpisu >= DATEADD(M,-1, GETDATE())
		GROUP BY rg.ilosc_godzin, p.id, p.imie, p.nazwisko 

GO
IF EXISTS(SELECT 1 FROM sys.views WHERE Name = 'ostatni_kierowcy_samochodow')
DROP VIEW ostatni_kierowcy_samochodow
GO
-- Widok realizuje historyjkę 4
-- 3 LEFT JOIN-y na tabelach, które pozwalają na wybranie informacji o tym
-- który pracownik ostatni używał pojazdu.
-- Najważniejszym elementem tego widoku jest funkcja grupująca GROUP BY oraz
-- agregująca MAX(opp.data_aktualizacji). Ta kombinacja pozwala na wybranie
-- ostatnich dat dla poszczególnych marek samochodów.
CREATE VIEW ostatni_kierowcy_samochodow AS
	SELECT DISTINCT(p.id), p.imie + ' ' + p.nazwisko as imie_i_nazwisko, po.marka, MAX(opp.data_aktualizacji) as data_aktualizacji FROM dziedziczak.firma.pojazd_w_uzyciu pwu 
	LEFT JOIN dziedziczak.firma.pracownik p ON p.id = pwu.id_ostatni_pracownik
	LEFT JOIN dziedziczak.firma.pojazd po ON po.id = pwu.id_pojazd 
	LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
	GROUP BY p.id, po.marka, p.imie, p.nazwisko, opp.data_aktualizacji 
		
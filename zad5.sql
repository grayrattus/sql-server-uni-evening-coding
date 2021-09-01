GO
-- Widok realizuje historyjkę 1
-- Pozwala on na określenie ostatnich lokalizacji pojazów.
-- Logika jest skonstruowana tak, że pobieram potrzebne dane a następnie
-- grupuje je po "data_aktualizacji". To powoduje, że mogę użyć na tym 
-- polu funkcji agregującej MAX. W ten sposób otrzymuje ostatnie daty
-- pozycji danego samochodu. Na koniec jeszcze raz łączę tabele
-- tak aby połączyć daty i id_pojazd.
IF EXISTS(SELECT 1 FROM dziedziczak.sys.views WHERE Name = 'ostatnie_pozycje_pojazdu')
DROP VIEW firma.ostatnie_pozycje_pojazdu
GO
CREATE VIEW firma.ostatnie_pozycje_pojazdu AS
	SELECT maxDates.id_pojazd, p.marka, maxDates.maksymalna_data, opp2.lat, opp2.lon FROM (
		SELECT pwu.id_pojazd as id_pojazd, MAX(opp.data_aktualizacji) as maksymalna_data
			 FROM dziedziczak.firma.pojazd_w_uzyciu pwu 
			 LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON pwu.id_ostatnia_pozycja = opp.id 
			 GROUP BY pwu.id_pojazd
			 ) maxDates
		LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp2 ON opp2.data_aktualizacji = maxDates.maksymalna_data
		LEFT JOIN dziedziczak.firma.pojazd_w_uzyciu pwu2 ON pwu2.id_pojazd = maxDates.id_pojazd and pwu2.id_ostatnia_pozycja = opp2.id 
		LEFT JOIN dziedziczak.firma.pojazd p ON p.id = maxDates.id_pojazd

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
	SELECT p.id, p.imie, p.nazwisko, SUM(rg.ilosc_godzin) as suma_godzin 
		FROM dziedziczak.firma.pracownik_to_rozklad_godzin ptrg 
		LEFT JOIN dziedziczak.firma.pracownik p ON ptrg.id_pracownik = p.id 
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
SELECT ostatniePojazdy.id_pojazd, ostatniePojazdy.data_aktualizacji,  p.imie + ' ' + p.nazwisko as imie_i_nazwisko FROM (
	SELECT pwu.id_pojazd ,MAX(opp.data_aktualizacji) as data_aktualizacji FROM dziedziczak.firma.pojazd_w_uzyciu pwu 
	LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp ON opp.id = pwu.id_ostatnia_pozycja 
	GROUP BY pwu.id_pojazd) ostatniePojazdy
	LEFT JOIN dziedziczak.firma.ostatnia_pozycja_pojazdu opp2 ON opp2.data_aktualizacji = ostatniePojazdy.data_aktualizacji
	LEFT JOIN dziedziczak.firma.pojazd_w_uzyciu pwu2 ON opp2.id = pwu2.id_ostatnia_pozycja and pwu2.id_pojazd = ostatniePojazdy.id_pojazd
	LEFT JOIN dziedziczak.firma.pracownik p ON pwu2.id_ostatni_pracownik = p.id
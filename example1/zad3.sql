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

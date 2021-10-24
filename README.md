# WHY
It's made as my University project. The request was to made own db with bunch of scripts.

If you look for some good examples of TSQL and SQL for Microsoft SQL server you are in the right place.

Using constraints, procedures, views and all of this in one place.

Hope this helps! 

And here is 

# How to build

## example1/*

```
# Build document for university
cd sprawdzenie
pdflatex -shell-escape -synctex=1 -interaction=nonstopmode main; biber main; pdflatex -shell-escape -synctex=1 -interaction=nonstopmode main
cd ..
sh make_sql.sh

# Start server for docker
sudo docker run --rm -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=<YourStrong@Passw0rd>" \
   -p 1433:1433 \
   mcr.microsoft.com/mssql/server:2019-latest
```

After all of this you should be able to run my scrips on server running on `localhost:1433`.

## example2--smaller/database.sql

```
This is a simple database for other classes I had.
```

## ToDo
```
```

## Done
```
08/31/21#18:17:51 😀 - Dodać 5 historyjek użytkonika. Ma być 2 użytkowników.
	Jako ... chcę ...potrzeba użytkownika... żeby ...cel który chcę osiągnąć
08/31/21#18:20:03 😀 - dodać usuwanie bazy danych i jej tworzenie # nie potrzeba, będę leciał na master
08/31/21#18:36:51 😀 - dodać tworzenie jednej tabeli i jej usuwanie
08/31/21#19:08:31 😀 - dodać minimum 5 tabel wraz z ich usuwaniem
08/31/21#22:39:41 😀 - stworzyć procedurę do dodawania elementów do bazy danych
	 wypełnić bazę danych 3 rekordami
09/01/21#14:12:20 😀 - napisanie sprawozdania w jakimś Markdown lub Latex
09/01/21#12:33:43 😐 - sprawdzenie tego markdown marmaid. Jak będzie lipne to PlantUML na pełnej. - update PlantUML jest zdecydowanie lepszy...
09/01/21#11:16:18 😀 - dodać 2 niebanalne widoki (oparte na kilku tabelach i ukrywające część danych dla użytkowników)
09/01/21#10:31:37 😀 	- dodać widok ostatniej pozycji samochodu dla danego kierowcy
09/01/21#11:01:55 😀 	- podający wszystkie godziny pracy w tym miesiącu dla danego pracownika
09/01/21#11:16:15 😀 	- dodać widok poprzedniego kierowcy, który używał danego samochodu
09/01/21#10:00:34 😀 - dodać procedurę dodającą przepracowane godziny dla pracownika
09/01/21#09:52:11 😀 - dodać procedurę do uaktualniania pozycji pojazdu jeżeli poprzednia jest 15 minut mniejsza od ostatniej aktualizacji
```

CREATE TABLE Pacientai(
	Asmens_kodas 		CHAR(11) PRIMARY KEY,
	Vardas CHAR(30) 	NOT NULL,
	Pavarde CHAR(30) 	NOT NULL,
	Gimimo_data 		DATE NOT NULL DEFAULT '2000-01-01',
	Telefono_numeris 	CHAR(11) NOT NULL UNIQUE,
	CONSTRAINT Ilgiai
	CHECK(LENGTH(Asmens_kodas) = 11 AND LENGTH(Telefono_numeris) = 11));

CREATE TABLE Gydytojai(
	Gydytojo_id 	INTEGER PRIMARY KEY,
	Vardas 			CHAR(30),
	Pavarde 		CHAR(30));

CREATE TABLE Priklauso(
	Asmens_kodas 	CHAR(11),
	Gydytojo_id 	INTEGER,
	PRIMARY KEY (Asmens_kodas, Gydytojo_id),
	FOREIGN KEY (Asmens_kodas) REFERENCES Pacientai ON DELETE CASCADE,
	FOREIGN KEY (Gydytojo_id) REFERENCES Gydytojai ON DELETE CASCADE
								ON UPDATE RESTRICT);

CREATE TABLE Rezidentai(
	Gydytojo_id 	INTEGER,
	Universitetas 	CHAR(4) NOT NULL,
	CONSTRAINT Universitetai 
		CHECK(Universitetas IN ('VU', 'LSMU', 'VIKO', 'KK')),
	Specialybe CHAR(30),
	PRIMARY KEY(Gydytojo_id),
	FOREIGN KEY (Gydytojo_id) REFERENCES Gydytojai ON DELETE CASCADE);

CREATE TABLE Patyre_Gydytojai(
	Gydytojo_id 		INTEGER,
	Pareigos 		CHAR(50),
	Metai_patirties 	INTEGER NOT NULL DEFAULT 3,
	PRIMARY KEY (Gydytojo_id),
	FOREIGN KEY (Gydytojo_id) REFERENCES Gydytojai ON DELETE CASCADE);


CREATE TABLE Tyrimai(
	Tyrimo_id 	INTEGER PRIMARY KEY 
	GENERATED ALWAYS AS IDENTITY
	(START WITH 1 INCREMENT BY 1),
	Pacientas	CHAR(11),
	Gydytojas 	INTEGER,
	Data 		DATE NOT NULL DEFAULT CURRENT_DATE,
	Kaina 		SMALLINT NOT NULL,
	CONSTRAINT Kainos CHECK(Kaina BETWEEN 0 AND 100),
	FOREIGN KEY (Pacientas) REFERENCES Pacientai(Asmens_kodas) ON DELETE CASCADE,
	FOREIGN KEY (Gydytojas) REFERENCES Gydytojai(Gydytojo_id) ON DELETE CASCADE);

CREATE TABLE Receptai(
	Recepto_nr 	INTEGER PRIMARY KEY,
	Asmens_kodas 	CHAR(11),
    Gydytojo_id 	INTEGER NOT NULL,
	Israso_data 	DATE NOT NULL DEFAULT CURRENT_DATE,
	FOREIGN KEY (Asmens_kodas) REFERENCES Pacientai ON DELETE CASCADE,
    FOREIGN KEY (Gydytojo_id) REFERENCES Gydytojai ON DELETE CASCADE);

CREATE TABLE Medziagos(
	Recepto_nr INTEGER,
	Pavadinimas CHAR(30),
	Kiekis SMALLINT NOT NULL CHECK(Kiekis > 0 AND Kiekis < 1000), 
    PRIMARY KEY (Recepto_nr, Pavadinimas),
	FOREIGN KEY (Recepto_nr) REFERENCES Receptai ON DELETE CASCADE);

CREATE INDEX idx_pacientai_asmens_kodas ON Pacientai(Asmens_kodas);
CREATE INDEX idx_tyrimai_paciento ON Tyrimai(Pacientas);
CREATE INDEX idx_tyrimai_data ON Tyrimai(Data);
CREATE INDEX idx_receptai_data ON Receptai(Israso_data);
CREATE INDEX idx_recepto_israsymai_gydytojo ON Receptai(Gydytojo_id);
CREATE INDEX idx_recepto_israsymai_paciento ON Receptai(Asmens_kodas);

--- Funkcijos darbui 


--- Pakeisti paciento telefono numerį
UPDATE Pacientai
SET Telefono_numeris = '37065414322'
WHERE Asmens_kodas = '50310230265';

--- Atleisti gydytoją pagal jo ID
DELETE FROM Gydytojai
WHERE Gydytojo_id = 910;

--- Recepto ištrinimas pagal ID
DELETE FROM Receptai
WHERE Recepto_nr = 4;

--- PAšalinti pacientus
DELETE FROM Pacientai
WHERE Asmens_kodas = '60112230001';

--- Tyrimo kainos atnaujinimas
UPDATE Tyrimai
SET Kaina = 20
WHERE Pacientas = '47002220090';

--- Pakeisti medžiagos kiekį recepte
UPDATE Medziagos 
SET Kiekis = 50
WHERE Pavadinimas = 'Tarkofiledas';

--- Rasti labiausiai patyrusį gydytoją
WITH maximumas AS(
	SELECT MAX(Metai_patirties) 
	AS Patirtis FROM Patyre_Gydytojai)
SELECT Gydytojo_id, Pareigos, Metai_patirties
	FROM Patyre_gydytojai, maximumas 	
	WHERE Metai_patirties = Patirtis;

--- Darbas su virtualiom lentelėm
CREATE VIEW Negaliojantis
AS SELECT * FROM Receptai
	WHERE EXTRACT(MONTH FROM Israso_data) < EXTRACT(MONTH FROM CURRENT_DATE);

CREATE VIEW Paciento_amzius AS 
	SELECT Asmens_kodas, Vardas, Pavarde,
	EXTRACT(YEAR FROM AGE (Gimimo_data)) AS amzius
	FROM Pacientai;

--- Lentelių šalinimas
DROP TABLE Priklauso;
DROP TABLE Rezidentai;
DROP TABLE Patyre_Gydytojai;
DROP TABLE Medziagos;
DROP TABLE Receptai;
DROP TABLE Tyrimai;
DROP TABLE Gydytojai;
DROP TABLE Pacientai; 
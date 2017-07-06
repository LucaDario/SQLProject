
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS Genere;
CREATE TABLE Genere(
NomeGenere varchar(20) PRIMARY KEY,
Provenienza varchar(30)
);


DROP TABLE IF EXISTS Ospite;
CREATE TABLE Ospite(
Nome varchar(20) PRIMARY KEY,
Nazione varchar(30) DEFAULT NULL,
AnnoAttivita YEAR(4) DEFAULT NULL,
Genere varchar(20) REFERENCES Genere(NomeGenere)

);


DROP TABLE IF EXISTS PersonaFisica;
CREATE TABLE PersonaFisica(
Id INT NOT NULL AUTO_INCREMENT,
Nome varchar(20) NOT NULL,
Cognome varchar(20) NOT NULL,
DataNascita DATE,
Cantante BOOLEAN NOT NULL,
Nazionalita varchar(30),
Sesso	 ENUM('M','F'),
PRIMARY KEY(Id)
);


DROP TABLE IF EXISTS Composizione;
CREATE TABLE Composizione(
IdPersona INT,
NomeOspite varchar(20),
PRIMARY KEY(NomeOspite,IdPersona),
FOREIGN KEY(NomeOspite) REFERENCES Ospite(Nome),
FOREIGN KEY(IdPersona) REFERENCES PersonaFisica(Id) ON DELETE CASCADE
);


DROP TABLE IF EXISTS StrumentoMusicale;
CREATE TABLE StrumentoMusicale(
Nome varchar(20) PRIMARY KEY,
Tipo varchar(20) NOT NULL
);


DROP TABLE IF EXISTS CapacitaMusicali;
CREATE TABLE CapacitaMusicali(
Persona INT,
Strumento varchar(20),
PRIMARY KEY(Persona,Strumento),
FOREIGN KEY(Persona) REFERENCES PersonaFisica(Id),
FOREIGN KEY(Strumento) REFERENCES StrumentoMusicale(Nome)
);


DROP TABLE IF EXISTS Palco;
CREATE TABLE Palco(
Nome varchar(20) PRIMARY KEY,
Capienza SMALLINT,
Grandezza SMALLINT,
PotenzaSonora SMALLINT,
Indoor BOOLEAN NOT NULL
);


DROP TABLE IF EXISTS Giornata;
CREATE TABLE Giornata(
Giorno DATE PRIMARY KEY,
PrezzoBiglietto SMALLINT NOT NULL
);


DROP TABLE IF EXISTS Esibizione;
CREATE TABLE Esibizione(
Ospite varchar(20),
Palco varchar(20),
Giornata DATE,
OraInizio TIME NOT NULL,
OraFine TIME NOT NULL,
PRIMARY KEY(Palco,Giornata,OraInizio,OraFine),
FOREIGN KEY(Ospite) REFERENCES Ospite(Nome),
FOREIGN KEY(Palco) REFERENCES Palco(Nome),
FOREIGN KEY(Giornata) REFERENCES Giornata(Giorno)
);


DROP TABLE IF EXISTS PuntoRistoro;
CREATE TABLE PuntoRistoro(
Nome varchar(20) PRIMARY KEY,
Capienza SMALLINT NOT NULL,
Cibo BOOLEAN NOT NULL,
PIva varchar(13) NOT NULL,
Indoor BOOLEAN NOT NULL,
Vicinanza varchar(20) REFERENCES Palco(Nome)
);
INSERT INTO PuntoRistoro
VALUES
('RedBull Bar',0,false,'IT74827648987',false,'RedBull Stage'),
('Circus Bar',0,false,'IT83897483987',true,'Circus Stage'),
('Cave Bar',0,false,'IT74837489367',true,'Cave Stage'),
('Main Bar',250,true,'IT64737546957',true,'Main Stage'),
('StreetFood',300,true,'IT64738647893',true,'Second Stage');


INSERT INTO Ospite
VALUES
('Nirvana',	'USA',	1987,'Grunge'),
('Blur',	'Inghilterra',	1989,	NULL),
('Aphex Twin',	'Inghilterra',	1985,	'Elettronica'),
('Sangue Misto',	'Italia',	1993,	'Rap'),
('Neffa',	'Italia',	1996,	NULL),
('The Field',	'Svezia',	2005,	'Elettronica'),
('Nicolas Jaar',	NULL,	2008,	'Elettronica'),
('Vasco Rossi',	'Italia',	1977,	'Rock'),
('Ed Sheeran',	'Inghilterra',	2008,	NULL),
('Jovanotti',	'Italia',	1987,	'Pop'),
('Mumford And Sons',	'Inghilterra',	2007,	'Folk'),
('Pink Floyd',	'Inghilterra',	1965,	'Rock'),
('Subsonica',	'Italia',	1996,	 NULL),
('Gorillaz','Inghlterra',1998,NULL);


INSERT INTO Genere
VALUES
('Rock','Inghilterra'),
('Elettronica','Europa'),
('Pop','USA'),
('Grunge','USA'),
('Rap','USA'),
('Folk','Inghilterra');


INSERT INTO PersonaFisica
VALUES
(NULL,'Kurt','Cobain','1997-02-20',true,'USA','M'),
(NULL,'Dave','Grohl','1969-01-14',true,'USA','M'),
(NULL,'Krist','Novoselic','1965-05-16',false,'USA','M'),
(NULL,'Giovanni','Pellino','1967-10-07',true,'Italia','M'),
(NULL,'Alex','Willner',NULL,false,NULL,'M'),
(NULL,'Richard David','James','1971-08-18',true,'Irlanda','M'),
(NULL,'Edward Christopher','Sheeran','1991-02-17',true,'Inghilterra','M'),
(NULL,'Damon','Albarn','1968-03-23',	true,'Inghilterra','M'),
(NULL,'Graham Leslie','Coxon','1969-03-19',false,'Inghilterra','M'),
(NULL,'Steven Alexander','James','1969-11-21',0,'Inghilterra','M'),
(NULL,'David Alexander', 'Rowntree','1964-05-08',0,'Inghilterra','M'),
(NULL,'Nicolas','Jaar','1990-01-10',0,NULL,'M'),
(NULL,'Andrea','Visani','1971-01-02',1,'Italia','M'),
(NULL,'Sandro','Orru','1968-01-08',0,'Italia','M'),
(NULL,'Vasco','Rossi','1952-02-07',1,'Italia','M'),
(NULL,'Lorenzo','Cherubini','1966-09-27',1,'Italia','M'),
(NULL,'Marcus','Mumford','1987-01-31',1,'Inghilterra','M'),
(NULL,'Winston','Marshall',NULL,0,NULL,'M'),
(NULL,'Ben','Lovett',NULL,0,NULL,'M'),
(NULL,'Ted','Dwane',NULL,0,NULL,'M'), 
(NULL,'Roger','Waters','1943-09-06',1,'Inghilterra','M'),
(NULL,'Richard William','Wright','1943-07-28',1,'Inghilterra','M'),
(NULL,'Nicholas Berkeley','Mason','1944-01-26',0,'Inghilterra','M'),
(NULL,'David Jon','Gilmour','1946-03-06',1,'Inghilterra','M'),
(NULL,'Samuel Umberto','Romano','1972-03-07',1,'Italia','M'),
(NULL,'Massimiliano','Casacci', '1963-10-11',1,'Italia','M'),
(NULL,'Davide','Dileo','1974-09-27',1,'Italia','M'),
(NULL,'Enrico','Matta','1971-09-24',0,'Italia','M'),
(NULL,'Luca','Vicini', '1971-10-05',0,'Italia','M')

;
INSERT INTO Composizione
VALUES
(1,'Nirvana'),
(2,'Nirvana'),
(3,'Nirvana'),
(4,'Sangue Misto'),
(4,'Neffa'),
(5,'The Field'),
(6,'Aphex Twin'),
(7,'Ed Sheeran'),
(8,'Blur'),
(9,'Blur'),
(10,'Blur'),
(11,'Blur'),
(12,'Nicolas Jaar'),
(13,'Sangue Misto'),

(14,'Sangue Misto'),
(15,'Vasco Rossi'),
(16,'Jovanotti'),
(17,'Mumford And Sons'),
(18,'Mumford And Sons'),
(19,'Mumford And Sons'),
(20,'Mumford And Sons'),
(21,'Pink Floyd'),
(22,'Pink Floyd'),
(23,'Pink Floyd'),
(24,'Pink Floyd'),
(25,'Subsonica'),
(26,'Subsonica'),
(27,'Subsonica'),
(28,'Subsonica'),
(29,'Subsonica'),
(8,'Gorillaz');




INSERT INTO StrumentoMusicale
VALUES 
('batteria',NULL),
('tastiera','elettrofoni digitali'),
('basso','elettrofoni semielettronici'),
('chitarra acustica','liuti'),
('chitarra elettrica','semi elettrica'),

('percussioni',NULL),
('pianoforte','cordofoni a tastiera'),
('violino','viole da braccio'),
('contrabbasso','viole da braccio'),
('organo','aerofoni a tastiera'),
('sintetizzatore','elettrofoni semielettronici'),
('banjo','liuti');


INSERT INTO Giornata
VALUES
('2016-08-15',49.99),
('2016-08-16',69.99),
('2016-08-17',39.99),
('2016-08-18',79.99),
('2016-08-19',49.99);

INSERT INTO Palco
VALUES
('Main Stage',5000,100,75,false),
('Second Stage',3000,70,NULL,false),
('RedBull Stage',500,30,60,false),

('Circus Stage',200,50,NULL,true),
('Cave Stage',300,50,50,true)
;



INSERT INTO Esibizione
VALUES
('Mumford and sons','Main Stage','2016-08-15','20:00','23:00'),
('Blur','Second Stage','2016-08-15','20:00','23:00'),
('Aphex Twin','Second Stage','2016-08-16','20:00','23:00'),
('Sangue Misto','RedBull Stage','2016-08-15','00:00','02:00'),
('The Field','Circus Stage','2016-08-15','23:00','01:00'),
('Nicolas Jaar','Cave Stage','2016-08-15', '23:00','01:00'),
('Vasco Rossi','Second Stage','2016-08-15','23:15','02:15'),
('Ed Sheeran','Main Stage','2016-08-15','23:15','02:15'),
('Nirvana','Main Stage','2016-08-16','22:00','00:00'),
('Pink Floyd','Main Stage','2016-08-17','20:00','00:00'),
('Subsonica','RedBull Stage','2016-08-17','23:00','01:00'),
('Jovanotti','Cave Stage','2016-08-16','22:00','01:00'),
('Neffa','Circus Stage','2016-08-16','21:30','00:30'),
('Gorillaz','Circus Stage','2016-08-17','21:30','00:30')
;
INSERT INTO CapacitaMusicali
VALUES
(1,'chitarra acustica'),
(1,'chitarra elettrica'),
(2,'chitarra elettrica'),
(2,'chitarra'),
(3,'basso'),
(5,'sintetizzatore'),
(6,'sintetizzatore'),
(6,'tastiera'),
(9,'chitarra eletrica'),
(10, 'basso'),
(11,'batteria'),
(11,'contrabbasso'),
(12,'sintetizzatore'),
(14,'sintetizzatore'),
(15,'chitarra acustica'),
(15,'chitarra eletrica'),
(17,'chitarra acustica'),
(17,'batteria'),
(18, 'chitarra elettrica'),
(18,'banjo'),
(19,'tastiera'),
(19,'percussioni'),
(20,'basso'),
(20,'chitarra elettrica'),
(21,'basso'),
(22,'tastiera'),
(22,'pianoforte'),
(22,'organo'),
(23,'batteria'),
(23,'tastiera'),
(23,'chitarra'),
(24,'basso'),
(24,'batteria'),
(24,'chitarra'),
(24,'chitarra elettrica'),
(24,'percussioni'),
(25,'chitarra'),
(26,'chitarra'),
(27,'tastiera'),
(28,'batteria'),
(29,'basso');


SET FOREIGN_KEY_CHECKS=1;




#Persone Fisiche nate dal 1 gennaio 1990 con palco data e ora in cui si esibiscono, se piu di un palco ordinati per grandezza


SELECT pf.Id, pf.Nome,pf.cognome as 'Cognome', pa.nome as 'Nome Palco',pa.Capienza as 'Capienza Palco', e.Giornata,e.OraInizio  
FROM PersonaFisica as pf JOIN Composizione as c on pf.Id=c.IdPersona 
JOIN Ospite as o on c.NomeOspite=o.Nome JOIN Esibizione as e ON e.Ospite=o.Nome  JOIN Palco as pa ON e.Palco=pa.Nome  
WHERE pf.DataNascita>'1989-12-31' 
ORDER BY pf.Id,pa.Grandezza;



#punti ristoro che vendono cibo vicino ai palchi con esibizioni tra le 19:00 e le 21:00 per giornata

SELECT e.Giornata,pr.Nome, p.Nome as 'Vicino al palco',e.Ospite as 'durante esibizione di' 
FROM  Esibizione as e JOIN Palco as p ON e.Palco=p.Nome JOIN PuntoRistoro as pr ON pr.Vicinanza=p.Nome
WHERE pr.Cibo=1 && ( (e.OraInizio<'21:00' && e.OraInizio>'19:00') || (e.OraFine<'21:00' && e.OraFine>'19:00'))
ORDER BY e.Giornata, pr.Nome;






#procedura che dato genere musicale torna esibizioni di quel genere per giornata


DROP PROCEDURE IF EXISTS EsibizioniPerGenere;
DELIMITER //
CREATE PROCEDURE EsibizioniPerGenere (genere varchar(20), giornoEs DATE) 
 
BEGIN
IF GiornoEs='NULL' THEN
SELECT e.Giornata,e.OraInizio,e.Ospite,e.Palco,gm.Provenienza
FROM Esibizione as e JOIN Ospite as o ON e.Ospite=o.Nome LEFT JOIN Genere as gm ON o.Genere=gm.NomeGenere

WHERE o.Genere=genere
ORDER BY e.giornata;
ELSE 
SELECT e.Giornata,e.OraInizio,e.Ospite,e.Palco
FROM Esibizione as e JOIN Ospite as o ON e.Ospite=o.Nome LEFT JOIN Genere as gm ON o.Genere=gm.NomeGenere

WHERE o.Genere=genere && Giornata=giornoEs
ORDER BY e.giornata;
	
 END IF;
END //
DELIMITER ;

DROP TRIGGER IF EXISTS InsertPalcoIndoor;
DELIMITER //
CREATE TRIGGER InsertPalcoIndoor
BEFORE INSERT ON Palco
FOR EACH ROW
	BEGIN
	IF new.Indoor=true AND new.Capienza>999 THEN
		SET new.Capienza=999;
	END IF;
	IF new.PotenzaSonora>100 THEN
		SET new.PotenzaSonora=100;
	END IF;
	
END//
DELIMITER ;



DELIMITER &
DROP FUNCTION IF EXISTS ChangeHour&

CREATE FUNCTION ChangeHour(DataEs DATE, TimeEs TIME)
  RETURNS INT
  LANGUAGE SQL
BEGIN
	DECLARE n INT;
	DECLARE timelimit TIME DEFAULT '23:59:59';
	DECLARE timeadd TIME DEFAULT '24:00';
	select COUNT(*) into n FROM Esibizione WHERE Giornata=DataEs;
  UPDATE Esibizione
	SET OraInizio=OraInizio+TimeEs,OraFine=OraFine+TimeEs
	WHERE Giornata=DataEs;
	
	UPDATE Esibizione
	SET OraInizio=OraInizio-timeadd
	WHERE OraInizio>timelimit AND Giornata=DataEs;
	
	UPDATE Esibizione
	SET OraFine=OraFine-timeadd
	WHERE OraFine>timelimit AND Giornata=DataEs;
	
	RETURN n;
END&
DELIMITER ;


DROP FUNCTION IF EXISTS OspiteChiusura;
DELIMITER //
CREATE FUNCTION OspiteChiusura(DataEs DATE)
RETURNS VARCHAR(20)
BEGIN
	DECLARE OraMax TIME DEFAULT '-01:00';
	DECLARE OspiteMax VARCHAR(20) DEFAULT 'NULL';
	DECLARE Finish INT DEFAULT 0;
	DECLARE Verifica INT DEFAULT 0;
	DECLARE n INT DEFAULT 0;
	DECLARE i TIME DEFAULT '24:00';
	DECLARE oFin TIME;
	DECLARE oIn TIME;
	WHILE Finish=0 DO
		SELECT COUNT(*) into Verifica from Esibizione where Giornata=DataEs GROUP BY Ospite LIMIT n,1;
			IF Verifica=0 THEN
				SET Finish=Finish+1;
			ELSE
				SELECT OraFine into oFin from Esibizione where Giornata=DataEs LIMIT n,1;
				SELECT OraInizio into oIn from Esibizione where Giornata=DataEs LIMIT n,1;
				
				IF oFin<='10:00:00' AND oFin>='00:00:00' THEN
					SET oFin=OFin+i;
				END IF;
				IF oFin>OraMax THEN
					SET OraMax=oFin;
					SELECT Ospite into OspiteMax from Esibizione where Giornata=DataEs LIMIT n,1;
					
				END IF;
				
			SET n=n+1;
			END IF;
			
			SET Verifica=0; 
		END WHILE;
RETURN OspiteMax;	
	

END //
DELIMITER ;

#function che torna anno inizio atticita artista dato in input il palco ora e giorno in cui si esibisce
(non sono 100% sicura di aver capito bene ma cercando ho trovato che le function non possono fare update per cui 
quella che avevamo deciso in teoria non va bene e ho pensato questa)

DROP FUNCTION IF EXISTS AnnoInizioAttivita;
DELIMITER //
CREATE FUNCTION AnnoInizioAttivita(NomePalco varchar(20), Ora time, Giorno date)
RETURNS year
BEGIN

DECLARE Anno year;
SELECT Ospite.AnnoAttivita
FROM Ospite JOIN Esibizione ON Esibizione.Ospite=Ospite.Nome
WHERE Esibizione.OraInizio=Ora && Esibizione.Giornata=Giorno && Esibizione.Palco=NomePalco
INTO Anno;
RETURN Anno;

END //
DELIMITER ;




DELIMITER &
DROP TRIGGER IF EXISTS DeleteOspite&
CREATE TRIGGER DeleteOspite
BEFORE DELETE ON Ospite
FOR EACH ROW
	BEGIN
	DECLARE Finish INT default 0;
	DECLARE NPersona INT ;
	DECLARE Verifica INT default 0;
	DECLARE Verifica1 INT;
	
	while Finish=0 do
		select COUNT(*) into Verifica from Composizione where NomeOspite=old.Nome;
		if Verifica=0 then
			SET Finish=Finish+1;
		else
			select IdPersona into NPersona from Composizione where NomeOspite=old.Nome limit 0,1;
			select COUNT(*) into Verifica1 from Composizione where IdPersona=NPersona AND NomeOspite!=old.Nome;
			SET foreign_key_checks = 0;
			
			
			if Verifica1<1 then
				DELETE FROM PersonaFisica where ID=NPersona;
				DELETE FROM Composizione where NomeOspite=old.Nome AND IdPersona=NPersona;
				DELETE FROM Esibizione where Ospite=old.Nome;
			else 
				DELETE FROM Composizione where NomeOspite=old.Nome AND IdPersona=NPersona;
				DELETE FROM Esibizione where Ospite=old.Nome;
			end if;
			SET foreign_key_checks= 1;
		end if;
	end while;
	END&
	DELIMITER ;
	
	
	
	
	
	


	select a.Id,a.Nome,a.Cognome,a.Cantante,c.Nome as 'Strumento',c.Tipo as 'Tipo Strumento'
	from
		(select b. Id, b.Nome,b.Cognome, a.numero,a.NomeOspite,b.Cantante
		from
			(select IdPersona,NomeOspite, COUNT(*) numero from Composizione group by IdPersona) as a 
		join PersonaFisica as b on a.IdPersona=b.Id 
		where a.numero>1) as a left join CapacitaMusicali as b on a.Id=b.Persona left join StrumentoMusicale as c on b.Strumento=c.Nome;



// ritorna strumenti musicali suonati da quelli che partcipano a piu ospiti





// ritorna le esibizione per giorno(1,2,3,4, etc) e con palco scelto, se palco è null seleziona tutte

DELIMITER &
DROP PROCEDURE IF EXISTS GiveFestivalDay&
CREATE PROCEDURE GiveFestivalDay(nDay INT, PalcoEs VARCHAR(20)) 



BEGIN 
	DECLARE DataG DATE;
	SET NDay=nDay-1;
	IF PalcoEs='NULL' THEN
		SELECT Giorno INTO DataG FROM Giornata LIMIT nDay,1;
		IF PalcoEs='NULL' THEN
	
			SELECT* FROM Esibizione WHERE Giornata=DataG ORDER BY Giornata,OraInizio;
		ELSE 
			SELECT* FROM Esibizione WHERE Giornata=DataG ORDER BY Giornata,OraInizio;
		END IF;
	
	ELSE
		SELECT Giorno INTO DataG FROM Giornata LIMIT nDay,1;
		IF PalcoEs='NULL' THEN
	
			SELECT* FROM Esibizione WHERE Giornata=DataG ORDER BY Giornata,OraInizio;
		ELSE 
			SELECT* FROM Esibizione WHERE Giornata=DataG AND Palco=PalcoEs ORDER BY Giornata,OraInizio;
		END IF;
	END IF;	
END&
DELIMITER ;	


//trigger che controlla che non ci siano intersezioni di esibizione NB se un esibizione inizia prima della mezzanotte e trmina dopo o inizia e finisce dopo la mezzanotte l
//la serata è sempre quella di prima di mezzanotte
DELIMITER &
DROP TRIGGER IF EXISTS InsertEsibizione&
CREATE TRIGGER InsertEsibizione
BEFORE INSERT ON Esibizione
FOR EACH ROW
BEGIN

	
	DECLARE Finish INT DEFAULT 0;
	DECLARE Verifica INT;
	DEClARE n INT DEFAULT 0;
	DECLARE oIni TIME;
	DECLARE oFin TIME;
	DECLARE i TIME DEFAULT '24:00';
	DECLARE oFinNew TIME;
	DECLARE oInNew TIME;
	IF new.OraInizio>'24:00'  THEN
		signal sqlstate '45000' set message_text = 'Orario Errato';
		
	END IF;
	IF new.OraFine>'24:00' THEN
		signal sqlstate '45000' set message_text = 'Orario Errato';
		
	END IF;
	
	
	
	IF new.OraFine<='10:00:00' AND new.OraFine>='00:00:00' THEN
		SET oFinNew=new.OraFine+i;
		
	ELSE	
		SET oFinNew=new.OraFine;
	END IF;	
	IF new.OraInizio<='10:00:00' AND new.OraInizio>='00:00:00' THEN
		SET oInNew=new.OraInizio+i;
		
	ELSE	
		SET oInNew=new.OraInizio;
	END IF;	
	
	WHILE Finish=0 DO
	SELECT COUNT(*) into Verifica from Esibizione where Palco=new.Palco AND Giornata=new.Giornata GROUP BY OraInizio,OraFine LIMIT n,1;
		IF Verifica=0 then
			SET Finish=Finish+1;
		ELSE
			SELECT OraInizio into oIni from Esibizione where Palco=new.Palco AND Giornata=new.Giornata LIMIT n,1;
			SELECT OraFine into oFin from Esibizione where Palco=new.Palco AND Giornata=new.Giornata LIMIT n,1;
		
			IF oFin<='10:00:00' AND oFin>='00:00:00' THEN
				SET oFin=OFin+i;
			END IF;
			IF oIni<='10:00:00' AND oIni>='00:00:00' THEN
				SET oIni=OIni+i;
			END IF;	
			
			IF oInNew>=oIni AND oInNew<=oFin THEN
				signal sqlstate '45000' set message_text = 'Intersezione di Esibizioni orario inizio';
			END IF;
		
			IF oFinNew>=oIni AND oFinNew<=oFin THEN
				signal sqlstate '45000' set message_text = 'Intersezione di Esibizioni orario fine';
			END IF;
	
			IF oInNew<=oIni AND oFinNew>=oFin THEN
				signal sqlstate '45000' set message_text = 'Intersezione di Esibizioni Interna';
			END IF;
	
		
			
			
		END IF;
		SET Verifica=0;
		SET n=n+1;
	END WHILE;
END&	
DELIMITER ;







	
// ritorna le le esibiioni delle giornata con piu esibizioni e quelle con meno con relativo punto ristoro vicino e prezzo biglietto
	
		
SELECT b.Ospite, b.Giornata, b.OraInizio, b.OraFine, c.Nome as 'Nome Punto Ristoro', c.Cibo, d.PrezzoBiglietto FROM
				(SELECT a.Giornata FROM (SELECT COUNT(*) NConcerti, Giornata FROM Esibizione GROUP BY Giornata) as a
				
				 WHERE a.NConcerti=(SELECT MAX(a.NConcerti)FROM
									(SELECT COUNT(*) NConcerti, Giornata FROM Esibizione GROUP BY Giornata)as a))
										as a JOIN Esibizione as b ON a.Giornata=b.Giornata LEFT JOIN PuntoRistoro as c ON b.Palco=c.Vicinanza JOIN Giornata as d ON b.Giornata=d.Giorno
										
										
										
UNION		

SELECT b.Ospite, b.Giornata, b.OraInizio, b.OraFine, c.Nome as 'Nome Punto Ristoro', c.Cibo, d.PrezzoBiglietto FROM
				(SELECT a.Giornata FROM (SELECT COUNT(*) NConcerti, Giornata FROM Esibizione GROUP BY Giornata) as a
				
				 WHERE a.NConcerti=(SELECT MIN(a.NConcerti)FROM
									(SELECT COUNT(*) NConcerti, Giornata FROM Esibizione GROUP BY Giornata)as a))
										as a JOIN Esibizione as b ON a.Giornata=b.Giornata LEFT JOIN PuntoRistoro as c ON b.Palco=c.Vicinanza JOIN Giornata as d ON b.Giornata=d.Giorno; 


	//query usa OspiteChiusura e ritorna le credenziali del Ospte Chiusura	


DROP PROCEDURE IF EXISTS DatiOspiteChiusura;
DELIMITER //
CREATE PROCEDURE  DatiOspiteChiusura (GiornoEs DATE)
BEGIN
DECLARE n INT DEFAULT 0;
SELECT COUNT(*) INTO n FROM Esibizione WHERE Giornata=GiornoEs;
IF n>0 THEN
	SELECT a.Nome, a.Cognome, a.Cantante FROM PersonaFisica as a JOIN Composizione as b ON a.Id=b.IdPersona  WHERE b.NomeOspite=OspiteChiusura(GiornoEs) ORDER BY a.Nome,a.Cognome;
ELSE 
	signal sqlstate '45000' set message_text = 'Nessun Ospite in questa Data';
END IF;
END //
DELIMITER ;

									
					
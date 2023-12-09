DROP DATABASE IF EXISTS ara;

CREATE DATABASE ara;

USE ara;

CREATE TABLE CategorieSociale (
	nomCS VARCHAR(20) NOT NULL UNIQUE,
  	reductionCS DECIMAL(2, 2) NOT NULL,
	PRIMARY KEY (nomCS)
) ENGINE InnoDB;

CREATE TABLE Adresse (
	idA INT NOT NULL UNIQUE AUTO_INCREMENT,
	numeroA INT NOT NULL,
	rueA VARCHAR(20) NOT NULL,
	villeA VARCHAR(20) NOT NULL,
	cpA INT NOT NULL,
	PRIMARY KEY (idA)
) ENGINE InnoDB;

CREATE TABLE Association (
	numeroAgrementAS CHAR(14) NOT NULL UNIQUE,
	nomAS VARCHAR(25) NOT NULL,
	dateCreationAS Date NOT NULL,
	emailAS VARCHAR(30) NOT NULL,
	telephoneAS VARCHAR(15) NOT NULL,	
	adresseAS INT NOT NULL,
	PRIMARY KEY (numeroAgrementAS),
	CHECK (numeroAgrementAS LIKE "^\d$")
) ENGINE InnoDB;

CREATE TABLE Personne (
	idPERS INT NOT NULL UNIQUE AUTO_INCREMENT,
	nomPERS VARCHAR(30) NOT NULL,
	prenomPERS VARCHAR(30) NOT NULL,
	emailPERS VARCHAR(40),
	PRIMARY KEY (idPERS)
) ENGINE InnoDB;

CREATE TABLE Adhesion (
	idAD INT NOT NULL UNIQUE AUTO_INCREMENT,
	personneAD INT NOT NULL,
	telephoneAD VARCHAR(15),
	ddnAD INT,
	categorieSocialeAD VARCHAR(20),
	canSuperviseAD BOOLEAN NOT NULL DEFAULT FALSE,
	adresseAD INT,
	associationAD CHAR(14),
	fonctionAD VARCHAR(10),
	PRIMARY KEY (idAD),
	FOREIGN KEY (personneAD) REFERENCES Personne(idPERS),
	FOREIGN KEY (categorieSocialeAD) REFERENCES CategorieSociale(nomCS),
	FOREIGN KEY (adresseAD) REFERENCES Adresse(idA),
	FOREIGN KEY (associationAD) REFERENCES Association(numeroAgrementAS)
) ENGINE InnoDB;

CREATE TABLE Paiement (
	idP INT NOT NULL UNIQUE AUTO_INCREMENT,
	dateRelanceP DATE,
	recuP TEXT NOT NULL,
	datePaiementP DATE NOT NULL,
	dateEcheanceP DATE NOT NULL,
	adhesionP INT NOT NULL,
	PRIMARY KEY (idP),
	FOREIGN KEY (adhesionP) REFERENCES Adhesion(idAD)
) ENGINE InnoDB;

CREATE TABLE CertificatMedical (
	idCM INT NOT NULL UNIQUE AUTO_INCREMENT,
	medecinCM VARCHAR(30) NOT NULL,
	lienCM VARCHAR(150) NOT NULL,
	dateDebutCM DATE NOT NULL DEFAULT NOW(),
	dateFinCM DATE NOT NULL,
	pourAdhesionCM INT NOT NULL,
	PRIMARY KEY (idCM),
	FOREIGN KEY (pourAdhesionCM) REFERENCES Adhesion(idAD)
) ENGINE InnoDB;

CREATE TABLE Formation (
	idF INT NOT NULL UNIQUE AUTO_INCREMENT,
	nomF VARCHAR(30) NOT NULL,
	dateDebutF Date NOT NULL,
	dateFinF Date NOT NULL,
	PRIMARY KEY (idF)
) ENGINE InnoDB;

CREATE TABLE SuitFormation (
	formationSF INT NOT NULL,
	adhesionSF INT NOT NULL,
	PRIMARY KEY (formationSF, adhesionSF),
	FOREIGN KEY (formationSF) REFERENCES Formation(idF),
	FOREIGN KEY (adhesionSF) REFERENCES Adhesion(idAD)
) ENGINE InnoDB;

CREATE TABLE Reunion (
	idREU INT NOT NULL UNIQUE AUTO_INCREMENT,
	dateREU DATETIME NOT NULL,
	crREU TEXT NOT NULL,
	associationREU CHAR(14) NOT NULL,
	PRIMARY KEY (idREU),
	FOREIGN KEY (associationREU) REFERENCES Association(numeroAgrementAS)
) ENGINE InnoDB;

CREATE TABLE Randonnee (
	idR INT NOT NULL UNIQUE AUTO_INCREMENT,
	titreR VARCHAR(20) NOT NULL,
	difficulteR INT NOT NULL,
	nbKilometresR INT,
	dateR DateTime,
	lieuDepartR VARCHAR(40) NOT NULL,
	valideR BOOLEAN NOT NULL DEFAULT FALSE,
	coutR INT,
	organizedByR CHAR(14),
	suggereParR INT NOT NULL,
	PRIMARY KEY (idR),
	FOREIGN KEY (organizedByR) REFERENCES Association(numeroAgrementAS),
	FOREIGN KEY (suggereParR) REFERENCES Adhesion(idAD)
) ENGINE InnoDB;

CREATE TABLE Participation (
	idP INT NOT NULL UNIQUE AUTO_INCREMENT,
	personneP INT NOT NULL,
	randonneeP INT NOT NULL,
	roleP VARCHAR(15) NOT NULL,
	PRIMARY KEY (idP),
	UNIQUE KEY person_hike_role_key (personneP, randonneeP, roleP),
	FOREIGN KEY (personneP) REFERENCES Personne(idPERS),
	FOREIGN KEY (randonneeP) REFERENCES Randonnee(idR)
) ENGINE InnoDB;

CREATE TABLE Photo (
	idPH INT NOT NULL UNIQUE AUTO_INCREMENT,
	photoPH VARCHAR(150) NOT NULL UNIQUE,
	lieuPH VARCHAR(50),
	randonneePH INT NOT NULL,
	personnePH INT NOT NULL,
	PRIMARY KEY (idPH),
	FOREIGN KEY (randonneePH) REFERENCES Randonnee(idR),
	FOREIGN KEY (personnePH) REFERENCES Personne(idPERS)
) ENGINE InnoDB;

-- Fonctionnalité 3

DELIMITER //
CREATE PROCEDURE majAdhesion()
BEGIN
	UPDATE Paiement paiementMaj
	SET paiementMaj.dateRelanceP = NOW()
	WHERE (
		SELECT Adhesion.idAD
		FROM Adhesion
		INNER JOIN Paiement ON Adhesion.idAD = Paiement.adhesionP
		WHERE Adhesion.idAD = paiementMaj.adhesionP
		ORDER BY Paiement.dateEcheanceP
		LIMIT 1
	) = paiementMaj.adhesionP
		AND paiementMaj.dateRelanceP IS NULL
		AND DATEDIFF(paiementMaj.dateEcheanceP, NOW()) < 7;
END//

-- Fonctionnalité 3 version 2

CREATE FUNCTION detecterEcheance() RETURNS INT
BEGIN
	DECLARE $ids INT;

	SELECT Adhesion.idAD INTO $ids
	FROM Adhesion, Paiement
	WHERE Adhesion.idAD = Paiement.adhesionP AND Paiement.dateRelanceP IS NULL
	GROUP BY Adhesion.idAD
	HAVING MAX(DATEDIFF(Paiement.dateEcheanceP, NOW())) < 7;

	RETURN $ids;
END//

-- Fonctionnalité 4

CREATE TABLE _Echeances (
	adhesionId INT,
	PRIMARY KEY (adhesionId)
) ENGINE InnoDB//

CREATE EVENT eventDetecterEcheances
ON SCHEDULE EVERY 1 MONTH
ON COMPLETION PRESERVE
DO
BEGIN
	INSERT INTO _Echeances SELECT detecterEcheance();
END//
DELIMITER ;

-- Fonctionnalité 5

CREATE OR REPLACE VIEW adherentInfos
AS
    SELECT Personne.nomPERS, Personne.prenomPERS, Personne.emailPERS, Adhesion.ddnAD, Adhesion.fonctionAD, Randonnee.titreR, Randonnee.dateR, Participation.roleP, Formation.nomF, Formation.dateFinF, Paiement.dateEcheanceP < NOW()
    FROM Personne, Adhesion, Association, Participation, Randonnee, SuitFormation, Formation, Paiement
    WHERE Adhesion.idAD = Personne.idPERS
        AND Association.numeroAgrementAS = Adhesion.associationAD
        AND Participation.personneP = Personne.idPERS
        AND Randonnee.idR = Participation.randonneeP
        AND SuitFormation.adhesionSF = Personne.idPERS
        AND Formation.idF = SuitFormation.formationSF AND Formation.dateFinF < NOW()
        AND Paiement.adhesionP = Personne.idPERS;
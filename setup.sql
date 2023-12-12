DROP DATABASE IF EXISTS ara;

CREATE DATABASE ara;

USE ara;

-- -- -- STRUCTURE -- -- --

CREATE TABLE CategorieSociale (
    nomCS VARCHAR(20) NOT NULL UNIQUE COMMENT 'Nom unique de la catégorie sociale',
    reductionCS DECIMAL(2, 2) NOT NULL COMMENT 'Réduction (entre 0 et 1, 1 signifiant 100% de réduction, 0 signifiant pas de réduction) du prix de la cotisation à l\'association pour les personnes appartenant à cette catégorie sociale',
    PRIMARY KEY (nomCS)
) ENGINE=InnoDB COMMENT='Table des catégories sociales';

CREATE TABLE Adresse (
    idA INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique de l\'adresse',
    paysA VARCHAR(50) NOT NULL COMMENT 'Nom du pays',
    villeA VARCHAR(20) NOT NULL COMMENT 'Nom de la ville',
    cpA INT NOT NULL COMMENT 'Code postal de la ville',
    rueA VARCHAR(50) NOT NULL COMMENT 'Nom de la rue',
    numeroA INT NOT NULL COMMENT 'Numéro dans la rue',
    PRIMARY KEY (idA)
) ENGINE=InnoDB COMMENT='Table des adresses des adhérents à une association et des associations';

CREATE TABLE Association (
    numeroAgrementAS CHAR(10) NOT NULL UNIQUE COMMENT 'Identifiant unique de l\'association',
    nomAS VARCHAR(50) NOT NULL COMMENT 'Nom de l\'association',
    dateCreationAS Date NOT NULL COMMENT 'Date de déclaration en préfecture de l\'association',
    emailAS VARCHAR(30) NOT NULL COMMENT 'Adresse mail principale pour contacter l\'association',
    telephoneAS VARCHAR(15) NOT NULL COMMENT 'Numéro de téléphone de l\'association',
    adresseAS INT NOT NULL COMMENT 'Référence de l\'adresse du siège social l\'association',
    PRIMARY KEY (numeroAgrementAS),
    FOREIGN KEY (adresseAS) REFERENCES Adresse(idA)
) ENGINE=InnoDB COMMENT='Table des associations';

CREATE TABLE Personne (
    idPERS INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique de la personne',
    nomPERS VARCHAR(30) NOT NULL COMMENT 'Nom de famille de la personne',
    prenomPERS VARCHAR(30) NOT NULL COMMENT 'Prénom de la personne',
    emailPERS VARCHAR(40) COMMENT 'Email de la personne, éventuellement NULL',
    PRIMARY KEY (idPERS)
) ENGINE=InnoDB COMMENT='Table des personnes enregistrées';

CREATE TABLE Adhesion (
    idAD INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'ID de l\'adhérent',
    telephoneAD VARCHAR(15) NOT NULL COMMENT 'Numéro de téléphone de l\'adhérent',
    ddnAD DATE COMMENT 'Date de naissance de l\'adhérent',
    personneAD INT NOT NULL COMMENT 'Référence vers la personne étant adhérente',
    categorieSocialeAD VARCHAR(20) COMMENT 'Référence la catégorie sociale de l\'adhérent',
    adresseAD INT COMMENT 'Référence l\'adresse de l\'adhérent',
    associationAD CHAR(14) COMMENT 'Référence l\'association',
    fonctionAD enum('Responsable', 'Responsable-Adjoint', 'Trésorier', 'Secrétaire', 'Membre') COMMENT 'Fonction de l\'adhérent dans l\'association',
    PRIMARY KEY (idAD),
    FOREIGN KEY (personneAD) REFERENCES Personne(idPERS),
    FOREIGN KEY (categorieSocialeAD) REFERENCES CategorieSociale(nomCS),
    FOREIGN KEY (adresseAD) REFERENCES Adresse(idA),
    FOREIGN KEY (associationAD) REFERENCES Association(numeroAgrementAS)
) ENGINE=InnoDB COMMENT='Table des adhérents à l\'association';

CREATE TABLE Paiement (
    idP INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique du paiement',
    dateRelanceP DATE COMMENT 'Date de la relance pour le paiement de la cotisation suivante, ou NULL si aucune relance n\'a été faite',
    recuP TEXT NOT NULL COMMENT 'Reçu du paiement',
    datePaiementP DATE NOT NULL COMMENT 'Date à laquelle le paiement a été effectué (après confirmation de la banque)',
    dateEcheanceP DATE NOT NULL COMMENT 'Date de l\'échéance de la cotisation pour laquelle ce paiement a été effectué',
    adhesionP INT NOT NULL COMMENT 'Référence vers l\'adhésion pour laquelle ce paiement a été fait',
    PRIMARY KEY (idP),
    FOREIGN KEY (adhesionP) REFERENCES Adhesion(idAD)
) ENGINE=InnoDB COMMENT='Table des paiements des adhérents à une association';

CREATE TABLE CertificatMedical (
    idCM INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique du certificat médical',
    medecinCM VARCHAR(30) NOT NULL COMMENT 'Le nom du médecin ayant délivré le certificat médical',
    lienCM VARCHAR(150) NOT NULL COMMENT 'Le lien vers le certificat médical',
    dateDebutCM DATE NOT NULL DEFAULT NOW() COMMENT 'Date de début de validité',
    dateFinCM DATE NOT NULL COMMENT 'Date de fin de validité',
    pourAdhesionCM INT NOT NULL COMMENT 'Référence vers l\'adhésion pour laquelle ce certificat médical a été délivré',
    PRIMARY KEY (idCM),
    FOREIGN KEY (pourAdhesionCM) REFERENCES Adhesion(idAD)
) ENGINE=InnoDB COMMENT='Table des certificats médicaux des adhérents à une association';

CREATE TABLE Formation (
    idF INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique de la formation',
    nomF VARCHAR(30) NOT NULL COMMENT 'Le nom de la formation tel qu\'il sera affiché',
    dateDebutF Date NOT NULL COMMENT 'La date du premier jour de la formation',
    dateFinF Date NOT NULL COMMENT 'La date du dernier jour de la formation',
    PRIMARY KEY (idF)
) ENGINE=InnoDB COMMENT='Table des différentes formations';

CREATE TABLE SuitFormation (
    formationSF INT NOT NULL COMMENT 'Référence vers la formation suivie',
    adhesionSF INT NOT NULL COMMENT 'Référence vers l\'adhésion de la personne suivant la formation référencée par formationSF',
    reussiSF BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Réussite ou non de la formation. FALSE si la formation n\'est pas finie',
    dateValiditeSF DATE NOT NULL COMMENT 'La date de fin de validité de la formation. Passée cette date, les compétences jusque là acquises par l\' adhérent lors de cette formation ne seront plus considérées comme telles',
    PRIMARY KEY (formationSF, adhesionSF),
    FOREIGN KEY (formationSF) REFERENCES Formation(idF),
    FOREIGN KEY (adhesionSF) REFERENCES Adhesion(idAD)
) ENGINE=InnoDB COMMENT='Table qui fait la relation entre les formations et les adhésions, qui représente l\'inscription à une formation';

CREATE TABLE CompteRendu (
    idCR INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'L\'identifiant unique de la réunion',
    dateCR DATETIME NOT NULL COMMENT 'La date à laquelle s\'est déroulée la réunion',
    contenuCR TEXT NOT NULL COMMENT 'Le compte-rendu de la réunion',
    associationCR CHAR(14) NOT NULL COMMENT 'Référence vers l\'association ayant eu fait réunion',
    PRIMARY KEY (idCR),
    FOREIGN KEY (associationCR) REFERENCES Association(numeroAgrementAS)
) ENGINE=InnoDB COMMENT='Table des comptes rendus de réunion des associations';

CREATE TABLE Randonnee (
    idR INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'L\'identifiant unique de la randonnée',
    titreR VARCHAR(20) NOT NULL COMMENT 'Nom tel qu\'il sera affiché de la randonnée',
    difficulteR INT NOT NULL COMMENT 'Difficulté de la randonnée, 0 = vert, 1 = bleu, 2 = rouge, 3 = noir',
    nbKilometresR INT COMMENT 'Distance de la randonnée',
    dateR DateTime COMMENT 'Date à laquelle se déroulera la randonnée',
    lieuDepartR VARCHAR(40) NOT NULL COMMENT 'Description du lieu de départ de la randonnée',
    valideR BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Définit si la randonnée a été validée par le bureau de l\'association (TRUE) ou pas (encore) (FALSE)',
    coutR INT COMMENT 'Le prix pour s\'inscrire à cette randonnée',
    organiseR CHAR(14) COMMENT 'Référence vers l\'association',
    suggereParR INT NOT NULL COMMENT 'Référence vers l\'adhésion de la personne ayant proposé la randonnée',
    PRIMARY KEY (idR),
    FOREIGN KEY (organiseR) REFERENCES Association(numeroAgrementAS),
    FOREIGN KEY (suggereParR) REFERENCES Adhesion(idAD),
    CHECK (difficulteR >= 0 AND difficulteR < 4)
) ENGINE=InnoDB COMMENT='Table des randonnées';

CREATE TABLE Participe (
    idPART INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique de la participation',
    randonneePART INT NOT NULL COMMENT 'Référence vers la randonnée à laquelle participe la personne référencée par personneP',
    personnePART INT NOT NULL COMMENT 'Référence vers la personne participant à la randonnée référencée par randonneeP',
    rolePART enum('Guide', 'Participant', 'Logistique', 'Balisage', 'Ravitaillement') NOT NULL COMMENT 'Rôle tenu par le participant dans la randonnée',
    PRIMARY KEY (idPART),
    UNIQUE KEY personne_randonnee_role_key (personnePART, randonneePART, rolePART),
    FOREIGN KEY (personnePART) REFERENCES Personne(idPERS),
    FOREIGN KEY (randonneePART) REFERENCES Randonnee(idR)
) ENGINE=InnoDB COMMENT='Table des participants aux randonnées';

CREATE TABLE Photo (
    idPH INT NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'Identifiant unique de la photo',
    photoPH VARCHAR(150) NOT NULL UNIQUE COMMENT 'Lien vers la photo',
    lieuPH VARCHAR(50) COMMENT 'Description du lieu où a été prise la photo',
    randonneePH INT NOT NULL COMMENT 'Référence la randonnée durant laquelle a été prise la photo',
    personnePH INT NOT NULL COMMENT 'Référence la personne ayant pris la photo',
    PRIMARY KEY (idPH),
    FOREIGN KEY (randonneePH) REFERENCES Randonnee(idR),
    FOREIGN KEY (personnePH) REFERENCES Personne(idPERS)
) ENGINE=InnoDB COMMENT='Tables des photos prises pendant les randonnées';

-- -- -- SEEDING -- -- --

INSERT INTO Adresse (idA, numeroA, rueA, villeA, cpA, paysA) VALUES
    (1, 1, 'Rue de la Liberté', 'Paris', 75000, 'France'),
    (2, 2, 'Avenue des Roses', 'Lyon', 69000, 'France'),
    (3, 3, 'Boulevard du Commerce', 'Marseille', 13000, 'France'),
    (4, 4, 'Place de la République', 'Toulouse', 31000, 'France'),
    (5, 5, 'Rue de la Paix', 'Nice', 60000, 'France'),
    (6, 6, 'Avenue Foch', 'Bordeaux', 33000, 'France'),
    (7, 7, 'Rue Saint-Michel', 'Lille', 59000, 'France'),
    (8, 8, 'Boulevard Haussmann', 'Strasbourg', 67000, 'France'),
    (9, 9, 'Avenue Jean Jaurès', 'Rennes', 35000, 'France'),
    (10, 10, 'Place Bellecour', 'Lyon', 69000, 'France'),
    (11, 11, 'Avenue Victor Hugo', 'Toulouse', 31000, 'France'),
    (12, 12, 'Rue du Faubourg Saint-Honoré', 'Paris', 75000, 'France'),
    (13, 13, 'Rue Gambetta', 'Marseille', 13000, 'France'),
    (14, 14, 'Avenue de la Liberté', 'Nice', 60000, 'France'),
    (15, 15, 'Place du Capitole', 'Toulouse', 31000, 'France');

INSERT INTO Association (numeroAgrementAS, nomAS, telephoneAS, emailAS, dateCreationAS, adresseAS) VALUES
    ('W123456789', 'Association des Randonneurs Aubois (A.R.A.)', '0325270000', 'contact@ara.fr', '2023-11-01', 15);

INSERT INTO CategorieSociale (nomCS, reductionCS) VALUES
    ('Catégorie 1', 0.75),
    ('Catégorie 2', 0.50),
    ('Catégorie 3', 0);

INSERT INTO Personne (idPERS, nomPERS, prenomPERS, emailPERS) VALUES
    (1, 'Dupont', 'Jean', 'jean.dupont@example.com'),
    (2, 'Martin', 'Sophie', 'sophie.martin@example.com'),
    (3, 'Lefevre', 'Pierre', 'pierre.lefevre@example.com'),
    (4, 'Dubois', 'Marie', 'marie.dubois@example.com'),
    (5, 'Bernard', 'Julie', 'julie.bernard@example.com'),
    (6, 'Thomas', 'Nicolas', 'nicolas.thomas@example.com'),
    (7, 'Petit', 'Laura', 'laura.petit@example.com'),
    (8, 'Robert', 'Antoine', 'antoine.robert@example.com'),
    (9, 'Richard', 'Emma', 'emma.richard@example.com'),
    (10, 'Moreau', 'Lucas', 'lucas.moreau@example.com'),
    (11, 'Simon', 'Léa', 'lea.simon@example.com'),
    (12, 'Boucher', 'Louis', 'louis.boucher@example.com'),
    (13, 'Garcia', 'Camille', 'camille.garcia@example.com'),
    (14, 'Fournier', 'Hugo', 'hugo.fournier@example.com'),
    (15, 'Leroy', 'Manon', 'manon.leroy@example.com'),
    (16, 'Girard', 'Arthur', 'arthur.girard@example.com'),
    (17, 'Fontaine', 'Chloé', 'chloe.fontaine@example.com'),
    (18, 'Rousseau', 'Lucie', 'lucie.rousseau@example.com'),
    (19, 'Vincent', 'Théo', 'theo.vincent@example.com'),
    (20, 'Masson', 'Mathilde', 'mathilde.masson@example.com');

INSERT INTO Adhesion (idAD, fonctionAD, ddnAD, telephoneAD, associationAD, personneAD, adresseAD, categorieSocialeAD) VALUES
    (1, 'Membre', '2004-12-11', '0601023475', 'W123456789', 1, 1, NULL),
    (2, 'Membre', '1998-05-25', '0605123789', 'W123456789', 2, 1, 'Catégorie 1'),
    (3, 'Secrétaire', '1990-09-12', '0612345678', 'W123456789', 3, 3, 'Catégorie 2'),
    (4, 'Responsable-Adjoint', '1985-07-28', '0623456789', 'W123456789', 4, 4, NULL),
    (5, 'Responsable', '1983-03-15', '0634567890', 'W123456789', 5, 5, 'Catégorie 1'),
    (6, 'Membre', '1976-11-30', '0645678901', 'W123456789', 6, 6, 'Catégorie 3'),
    (7, 'Membre', '1995-02-18', '0656789012', 'W123456789', 7, 7, 'Catégorie 3'),
    (8, 'Secrétaire', '1987-08-05', '0667890123', 'W123456789', 8, 8, 'Catégorie 2'),
    (9, 'Membre', '1992-12-25', '0678901234', 'W123456789', 9, 9, 'Catégorie 1'),
    (10, 'Trésorier', '1989-04-02', '0689012345', 'W123456789', 10, 10, NULL),
    (11, 'Membre', '1978-06-10', '0690123456', 'W123456789', 11, 11, 'Catégorie 2'),
    (12, 'Membre', '1996-10-01', '0601234567', 'W123456789', 12, 12, NULL),
    (13, 'Secrétaire', '1981-11-07', '0612345678', 'W123456789', 13, 13, NULL),
    (14, 'Membre', '1984-03-22', '0623456789', 'W123456789', 14, 14, 'Catégorie 1'),
    (15, 'Membre', '1993-09-08', '0634567890', 'W123456789', 15, 2, NULL);

INSERT INTO CertificatMedical (idCM, medecinCM, lienCM, dateDebutCM, dateFinCM, pourAdhesionCM) VALUES
    (1, 'Docteur Martin', 'Lien_Certificat_1', '2023-11-01', '2023-11-30', 1),
    (2, 'Docteur Dupont', 'Lien_Certificat_2', '2023-11-01', '2023-11-30', 2),
    (3, 'Docteur Lambert', 'Lien_Certificat_3', '2023-11-01', '2023-11-30', 3),
    (4, 'Docteur Laurent', 'Lien_Certificat_4', '2023-11-01', '2023-11-30', 4),
    (5, 'Docteur Lefevre', 'Lien_Certificat_5', '2023-11-01', '2023-11-30', 5),
    (6, 'Docteur Girard', 'Lien_Certificat_6', '2023-11-01', '2023-11-30', 6),
    (7, 'Docteur Moreau', 'Lien_Certificat_7', '2023-11-01', '2023-11-30', 7),
    (8, 'Docteur Fournier', 'Lien_Certificat_8', '2023-11-01', '2023-11-30', 8),
    (9, 'Docteur Bernard', 'Lien_Certificat_9', '2023-11-01', '2023-11-30', 9),
    (10, 'Docteur Petit', 'Lien_Certificat_10', '2023-11-01', '2023-11-30', 10),
    (11, 'Docteur Richard', 'Lien_Certificat_11', '2023-11-01', '2023-11-30', 11),
    (12, 'Docteur Thomas', 'Lien_Certificat_12', '2023-11-01', '2023-11-30', 12),
    (13, 'Docteur Garcia', 'Lien_Certificat_13', '2023-11-01', '2023-11-30', 13),
    (14, 'Docteur Robert', 'Lien_Certificat_14', '2023-11-01', '2023-11-30', 14),
    (15, 'Docteur Simon', 'Lien_Certificat_15', '2023-11-01', '2023-11-30', 15),
    (16, 'Docteur Martin', 'Lien_Certificat_16', '2023-12-01', '2023-12-31', 1),
    (17, 'Docteur Martin', 'Lien_Certificat_17', '2023-12-01', '2023-12-31', 2),
    (18, 'Docteur Richard', 'Lien_Certificat_18', '2023-12-01', '2023-12-31', 3),
    (19, 'Docteur Richard', 'Lien_Certificat_19', '2023-12-01', '2023-12-31', 4),
    (20, 'Docteur Martin', 'Lien_Certificat_20', '2023-12-01', '2023-12-31', 5),
    (21, 'Docteur Robert', 'Lien_Certificat_21', '2023-12-01', '2023-12-31', 6),
    (22, 'Docteur Martin', 'Lien_Certificat_22', '2023-12-01', '2023-12-31', 7),
    (23, 'Docteur Robert', 'Lien_Certificat_23', '2023-12-01', '2023-12-31', 8),
    (24, 'Docteur Martin', 'Lien_Certificat_24', '2023-12-01', '2023-12-31', 9),
    (25, 'Docteur Robert', 'Lien_Certificat_25', '2023-12-01', '2023-12-31', 10);

INSERT INTO CompteRendu (idCR, contenuCR, dateCR, associationCR) VALUES
    (1, 'CR 1', '2023-11-06', 'W123456789'),
    (2, 'CR 2', '2023-11-13', 'W123456789'),
    (3, 'CR 3', '2023-11-20', 'W123456789'),
    (4, 'CR 4', '2023-11-27', 'W123456789'),
    (5, 'CR 5', '2023-12-04', 'W123456789'),
    (6, 'CR 6', '2023-12-11', 'W123456789');

INSERT INTO Formation (idF, nomF, dateDebutF, dateFinF) VALUES
    (1, 'Gestion', '2024-11-01', '2024-11-03'),
    (2, 'Trésorerie', '2024-11-01', '2024-11-03'),
    (3, 'Trésorerie', '2024-11-01', '2024-11-03'),
    (4, 'Secrétaire', '2024-11-01', '2024-11-03'),
    (5, 'Secrétaire', '2024-11-01', '2024-11-03'),
    (6, 'Secrétaire', '2024-11-01', '2024-11-03'),
    (7, 'Guide', '2024-11-01', '2024-11-03'),
    (8, 'Guide', '2024-11-01', '2024-11-03'),
    (9, 'Logistique', '2024-11-01', '2024-11-03'),
    (10, 'Balisage', '2024-11-01', '2024-11-03'),
    (11, 'Ravitaillement', '2024-11-01', '2024-11-03');

INSERT INTO SuitFormation (formationSF, adhesionSF, reussiSF, dateValiditeSF) VALUES
    (1, 4, TRUE, '2023-12-01'),
    (2, 5, TRUE, '2023-12-01'),
    (3, 10, TRUE, '2023-12-01'),
    (4, 3, TRUE, '2023-12-01'),
    (5, 8, TRUE, '2023-12-01'),
    (6, 13, TRUE, '2023-12-01'),
    (7, 4, TRUE, '2023-12-01'),
    (8, 5, TRUE, '2023-12-01');

INSERT INTO Paiement (idP, datePaiementP, dateEcheanceP, recuP, dateRelanceP, adhesionP) VALUES
    (1, '2023-11-01', '2023-11-30', 'Recu_Adherent_1', '2023-12-01', 1),
    (2, '2023-11-01', '2023-11-30', 'Recu_Adherent_2', '2023-12-01', 2),
    (3, '2023-11-01', '2023-11-30', 'Recu_Adherent_3', '2023-12-01', 3),
    (4, '2023-11-01', '2023-11-30', 'Recu_Adherent_4', '2023-12-01', 4),
    (5, '2023-11-01', '2023-11-30', 'Recu_Adherent_5', '2023-12-01', 5),
    (6, '2023-11-15', '2023-12-15', 'Recu_Adherent_6', NULL, 6),
    (7, '2023-11-15', '2023-12-15', 'Recu_Adherent_7', NULL, 7),
    (8, '2023-11-15', '2023-12-15', 'Recu_Adherent_8', NULL, 8),
    (9, '2023-11-15', '2023-12-15', 'Recu_Adherent_9', NULL, 9),
    (10, '2023-11-15', '2023-12-15', 'Recu_Adherent_10', NULL, 10),
    (11, '2023-12-01', '2023-12-31', 'Recu_Adherent_11', NULL, 11),
    (12, '2023-12-01', '2023-12-31', 'Recu_Adherent_12', NULL, 12),
    (13, '2023-12-01', '2023-12-31', 'Recu_Adherent_13', NULL, 13),
    (14, '2023-12-01', '2023-12-31', 'Recu_Adherent_14', NULL, 14),
    (15, '2023-12-01', '2022-12-31', 'Recu_Adherent_15', NULL, 15);

INSERT INTO Randonnee (idR, titreR, dateR, lieuDepartR, nbKilometresR, difficulteR, valideR, coutR, organiseR, suggereParR) VALUES
    (1, 'Randonnée A', '2023-12-01', 'Point de départ A', 10, 0, 1, 10, 'W123456789', 1),
    (2, 'Randonnée B', '2023-12-02', 'Point de départ B', 15, 1, 1, 15, 'W123456789', 1),
    (3, 'Randonnée C', '2023-12-03', 'Point de départ C', 20, 2, 1, 20, 'W123456789', 2),
    (4, 'Randonnée D', '2023-12-04', 'Point de départ D', 12, 0, 1, 12, 'W123456789', 1),
    (5, 'Randonnée E', '2023-12-05', 'Point de départ E', 18, 1, 1, 18, 'W123456789', 3),
    (6, 'Randonnée F', '2023-12-06', 'Point de départ F', 25, 3, 1, 25, 'W123456789', 4),
    (7, 'Randonnée G', '2023-12-20', 'Point de départ G', 30, 2, 1, 30, 'W123456789', 4),
    (8, 'Randonnée H', '2023-12-24', 'Point de départ H', 50, 2, 0, 40, 'W123456789', 4);


INSERT INTO Participe (idPART, personnePART, randonneePART, rolePART) VALUES
    (1, 1, 1, 'Participant'),
    (2, 2, 1, 'Participant'),
    (3, 3, 1, 'Participant'),
    (4, 4, 1, 'Guide'),
    (5, 16, 1, 'Participant'),
    (6, 18, 1, 'Participant'),
    (7, 4, 2, 'Guide'),
    (8, 5, 2, 'Guide'),
    (9, 6, 2, 'Logistique'),
    (10, 17, 2, 'Participant'),
    (11, 18, 2, 'Participant'),
    (12, 4, 1, 'Participant'),
    (13, 7, 3, 'Participant'),
    (14, 8, 3, 'Participant'),
    (15, 9, 3, 'Balisage'),
    (16, 10, 4, 'Guide'),
    (17, 11, 4, 'Ravitaillement'),
    (18, 12, 4, 'Logistique'),
    (19, 3, 5, 'Participant'),
    (20, 4, 5, 'Participant'),
    (21, 13, 5, 'Participant'),
    (22, 14, 5, 'Participant'),
    (23, 15, 5, 'Participant'),
    (24, 19, 5, 'Participant'),
    (25, 20, 5, 'Participant');

INSERT INTO Photo (idPH, photoPH, lieuPH, randonneePH, personnePH) VALUES
    (1, 'Photo_1', 'Randonnée A', 1, 1),
    (2, 'Photo_2', 'Autre lieu de la randonnée A', 1, 1),
    (3, 'Photo_3', 'Encore un autre lieu de la randonnée A', 1, 1),
    (4, 'Photo_4', 'Lieu de la randonnée B', 2, 4),
    (5, 'Photo_5', 'Autre lieu de la randonnée B', 2, 5),
    (6, 'Photo_6', 'Encore un autre lieu de la randonnée B', 2, 6),
    (7, 'Photo_7', 'Lieu de la randonnée C', 3, 7),
    (8, 'Photo_8', 'Autre lieu de la randonnée C', 3, 8),
    (9, 'Photo_9', 'Encore un autre lieu de la randonnée C', 3, 9),
    (10, 'Photo_10', 'Lieu de la randonnée D', 4, 10),
    (11, 'Photo_11', 'Autre lieu de la randonnée D', 4, 11),
    (12, 'Photo_12', 'Encore un autre lieu de la randonnée D', 4, 20),
    (13, 'Photo_13', 'Lieu de la randonnée E', 5, 13),
    (14, 'Photo_14', 'Autre lieu de la randonnée E', 5, 17),
    (15, 'Photo_15', 'Encore un autre lieu de la randonnée E', 5, 16);

-- -- -- FONCTIONNALITÉS -- -- --

-- Fonctionnalité 3 - Détecter qu’un adhérent arrive bientôt à ́échéance de son adhésion ou est déjà à échéance

CREATE VIEW detecterEcheance
AS SELECT Adhesion.idAD
    FROM Adhesion, Paiement
    WHERE Adhesion.idAD = Paiement.adhesionP AND Paiement.dateRelanceP IS NULL
    GROUP BY Adhesion.idAD
    HAVING MAX(DATEDIFF(Paiement.dateEcheanceP, NOW())) < 7;  -- On prend détecte que l'on approche de l'échéance à partir d'une semaine avant celle-ci

-- Fonctionnalité 4 - Tous les mois, détecter les retardataires dans le paiement de la cotisation

DELIMITER //

CREATE TABLE _Echeances (
    adhesionId INT,
    PRIMARY KEY (adhesionId)
) ENGINE=InnoDB//

CREATE EVENT retardataires
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
COMMENT 'Fonctionalité 4 - Tous les mois, détecter les retardataires dans le paiement de la cotisation'
DO BEGIN
    INSERT INTO _Echeances SELECT * FROM detecterEcheance;
END//

DELIMITER ;

-- Fonctionnalité 5 : créer une vue qui retourne les informations détaillées des adhérents

CREATE VIEW infosadherents AS
    SELECT Personne.idPERS AS `ID de la personne`,
           Adhesion.idAD AS `ID de l'adhésion`,
           Personne.nomPERS AS `Nom de la personne`,
           Personne.prenomPERS AS `Prénom de la personne`,
           Adhesion.ddnAD AS `Date de naissance de l'adhérent`,
           Personne.emailPERS AS `Email de la personne`,
           Adhesion.telephoneAD AS `Téléphone de l'adhérent`,
           IF(Adhesion.categorieSocialeAD IS NULL, 'Non spécifiée', Adhesion.categorieSocialeAD) AS `Catégorie sociale de l'adhérent`,
           Association.nomAS AS `Nom de l'association dont il fait partie`,
           MIN(Paiement.datePaiementP) AS `Date d'adhésion de l'adhérent`,
           Adhesion.fonctionAD AS `Fonction de l'adhérent dans son association`,
           IF(COUNT(Formation.idF) = 0, 'Aucune', GROUP_CONCAT(DISTINCT Formation.nomF, ' (Valide jusqu\'au ', SuitFormation.dateValiditeSF, ')' SEPARATOR ',')) AS `Formations de l'adhérent dans son association`,
           MAX(CertificatMedical.dateFinCM) AS `Expiration du certificat médical`,
           MAX(Paiement.dateEcheanceP) AS `Date d'échéance du paiement`,
           IF(Paiement.dateRelanceP, '<Pas de relance actuellement>', Paiement.dateRelanceP) AS `Date de relance du paiement`,
           IF(TO_DAYS(Paiement.dateEcheanceP) - TO_DAYS(NOW()) < 0, 'Non à jour', 'À jour') AS `État de la cotisation`,
           GROUP_CONCAT(DISTINCT Participe.rolePART SEPARATOR ',') AS `Rôles tenus lors des randonnées`,
           COUNT(DISTINCT Participe.randonneePART) AS `Nombre de participations à des randonnées`,
           COUNT(DISTINCT Photo.idPH) AS `Nombre de photos prises en randonnée`
        FROM Adhesion
        INNER JOIN Personne ON Personne.idPERS = Adhesion.idAD
        INNER JOIN Association ON Adhesion.associationAD = Association.numeroAgrementAS
        LEFT JOIN SuitFormation ON SuitFormation.adhesionSF = Adhesion.idAD
        LEFT JOIN Formation ON Formation.idF = SuitFormation.formationSF
        LEFT JOIN CertificatMedical ON Adhesion.idAD = CertificatMedical.pourAdhesionCM
        LEFT JOIN Paiement ON Adhesion.idAD = Paiement.adhesionP
        -- On crée une deuxième jointure avec paiement, pour s'assurer de ne récupérer que le paiement le plus récent
        -- On essaie de trouver un paiementControle payé plus tard que le Paiement joint juste au-dessus
        -- On s'assure ensuite dans un WHERE qu'un tel paiement n'existe pas, et donc que paiementControle.idP IS NULL
        LEFT JOIN Paiement paiementControle ON paiementControle.adhesionP = Adhesion.idAD AND Paiement.datePaiementP < paiementControle.datePaiementP
        LEFT JOIN Participe ON Personne.idPERS = Participe.personnePART
        LEFT JOIN Photo ON Personne.idPERS = Photo.personnePH
        WHERE paiementControle.idP IS NULL
        GROUP BY Adhesion.idAD;

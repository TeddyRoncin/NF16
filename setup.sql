DROP DATABASE IF EXISTS ara;

CREATE DATABASE ara;

USE ara;

CREATE TABLE SocialCategory (
	name VARCHAR(20) NOT NULL UNIQUE,
  	reduction DECIMAL(2, 2) NOT NULL,
	PRIMARY KEY (name)
);

CREATE TABLE Person (
	id INT NOT NULL UNIQUE AUTO_INCREMENT,
	firstname VARCHAR(30) NOT NULL,
	lastname VARCHAR(30) NOT NULL,
	email VARCHAR(40),
	phone VARCHAR(15),
	socialCategory VARCHAR(20),
	lastPayment DATE,
	lastMedicalCertificate DATE,
	remaindedAt DATE,
	canSupervise BOOLEAN NOT NULL DEFAULT FALSE,
	PRIMARY KEY (id),
	FOREIGN KEY (socialCategory) REFERENCES SocialCategory(name)
);

CREATE TABLE Association (
	siret CHAR(14) NOT NULL UNIQUE,
	createdAt Date NOT NULL,
	address VARCHAR(40) NOT NULL,
	phone VARCHAR(15),
	PRIMARY KEY (siret),
	CHECK (siret LIKE "^\d$")
);

CREATE TABLE BureauMember (
        person INT NOT NULL,
        association CHAR(14) NOT NULL,
        PRIMARY KEY (person, association),
        FOREIGN KEY (person) REFERENCES Person(id),
        FOREIGN KEY (association) REFERENCES Association(siret)
);

CREATE TABLE Meeting (
	date DATETIME NOT NULL,
	association CHAR(14) NOT NULL,
	report TEXT,
	PRIMARY KEY (date, association),
	FOREIGN KEY (association) REFERENCES Association(siret)
);

CREATE TABLE Hike (
	id INT NOT NULL UNIQUE AUTO_INCREMENT,
	name VARCHAR(20) NOT NULL,
	place VARCHAR(20) NOT NULL,
	difficulty INT NOT NULL,
	date DateTime,
	validated BOOLEAN NOT NULL DEFAULT FALSE,
	organizedBy CHAR(14),
	PRIMARY KEY (id),
	FOREIGN KEY (organizedBy) REFERENCES Association(siret)
);

CREATE TABLE ParticipationRole (
	name VARCHAR(15) NOT NULL UNIQUE,
	PRIMARY KEY (name)
);

CREATE TABLE Participation (
	id INT NOT NULL UNIQUE AUTO_INCREMENT,
	person INT NOT NULL,
	hike INT NOT NULL,
	role VARCHAR(15) NOT NULL,
	PRIMARY KEY (id),
	UNIQUE KEY person_hike_role_key (person, hike, role),
	FOREIGN KEY (person) REFERENCES Person(id),
	FOREIGN KEY (hike) REFERENCES Hike(id)
);

CREATE TABLE Photo (
	id INT NOT NULL UNIQUE AUTO_INCREMENT,
	link VARCHAR(100) NOT NULL UNIQUE,
	participation INT NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (participation) REFERENCES Participation(id)
);

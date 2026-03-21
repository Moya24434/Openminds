-- On supprime d'abord les tables qui dépendent des autres (les tables "esclaves")
DROP TABLE IF EXISTS Resultats;
DROP TABLE IF EXISTS Inscriptions;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS Sessions;

-- Enfin, on supprime les tables principales (les tables "maîtres")
DROP TABLE IF EXISTS Utilisateurs;
DROP TABLE IF EXISTS Formations;

-- 1. Table Utilisateurs (Inchangée, très bien définie)
-- Version compatible MySQL / MariaDB
CREATE TABLE Utilisateurs (
    id_user INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    ville VARCHAR(100),
    code_postal VARCHAR(10),
    telephone VARCHAR(20),
    role ENUM('Bénévole', 'Administrateur') DEFAULT 'Bénévole'
);
-- 2. Table Formations
CREATE TABLE Formations (
    id_formation INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(255) NOT NULL,
    description TEXT,
    thematique VARCHAR(100)
);
-- 3. Table Quiz (NÉCESSAIRE pour la table Resultats)
CREATE TABLE Quiz (
    id_quiz INT PRIMARY KEY AUTO_INCREMENT,
    id_formation INT,
    titre VARCHAR(255) NOT NULL,
    seuil_reussite INT DEFAULT 10,
    CONSTRAINT fk_quiz_formation FOREIGN KEY (id_formation) 
        REFERENCES Formations(id_formation) ON DELETE CASCADE
);

-- 4. Table Sessions
CREATE TABLE Sessions (
    id_session INT PRIMARY KEY AUTO_INCREMENT,
    id_formation INT,
    date_session DATETIME NOT NULL,
    type_session ENUM('Présentiel', 'En ligne'),
    lieu VARCHAR(255),
    CONSTRAINT fk_session_formation FOREIGN KEY (id_formation) 
        REFERENCES Formations(id_formation) ON DELETE CASCADE
);
-- 5. Table Inscriptions (Lien entre Utilisateurs et Sessions)
-- Essentiel pour savoir qui participe à quoi !
CREATE TABLE Inscriptions (
    id_user INTEGER,
    id_session INTEGER,
    date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_user, id_session),
    FOREIGN KEY (id_user) REFERENCES Utilisateurs(id_user) ON DELETE CASCADE,
    FOREIGN KEY (id_session) REFERENCES Sessions(id_session) ON DELETE CASCADE
);


-- 6. Table Resultats (Version MySQL)
CREATE TABLE Resultats (
    id_res INT PRIMARY KEY AUTO_INCREMENT,
    id_user INT,
    id_quiz INT,
    score INT NOT NULL,
    date_passage DATETIME DEFAULT CURRENT_TIMESTAMP,
    est_valide TINYINT(1) DEFAULT 0, -- 0 pour faux, 1 pour vrai
    CONSTRAINT fk_res_user FOREIGN KEY (id_user) 
        REFERENCES Utilisateurs(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_res_quiz FOREIGN KEY (id_quiz) 
        REFERENCES Quiz(id_quiz) ON DELETE CASCADE
);
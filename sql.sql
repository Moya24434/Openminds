-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : lun. 30 mars 2026 à 23:55
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--

-- 1. Désactiver les contraintes pour pouvoir supprimer sans blocage
SET FOREIGN_KEY_CHECKS = 0;

-- 2. Supprimer les tables si elles existent
DROP TABLE IF EXISTS `resultats`;
DROP TABLE IF EXISTS `inscriptions`;
DROP TABLE IF EXISTS `quiz_options`;
DROP TABLE IF EXISTS `quiz_questions`;
DROP TABLE IF EXISTS `quiz`;
DROP TABLE IF EXISTS `sessions`;
DROP TABLE IF EXISTS `formations`;
DROP TABLE IF EXISTS `utilisateurs`;

-- 3. Réactiver les contraintes
SET FOREIGN_KEY_CHECKS = 1;

--
-- Structure de la table `formations`
--

CREATE TABLE `formations` (
  `id_formation` int(11) NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `thematique` varchar(100) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `formations`
--

INSERT INTO `formations` (`id_formation`, `titre`, `description`, `thematique`, `image_url`) VALUES
(1, 'Formation au PSC1', 'Gestes qui sauvent.', 'Secourisme', 'https://www.crous-bfc.fr/wp-content/uploads/sites/7/2023/09/20231007-PSC1.png'),
(2, 'Initiation au Bénévolat', 'Bases de l\'engagement.', 'Engagement', 'https://via.placeholder.com/400x250');

-- --------------------------------------------------------

--
-- Structure de la table `inscriptions`
--

CREATE TABLE `inscriptions` (
  `id_user` int(11) NOT NULL,
  `id_session` int(11) NOT NULL,
  `date_inscription` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `inscriptions`
--

INSERT INTO `inscriptions` (`id_user`, `id_session`, `date_inscription`) VALUES
(1, 1, '2026-03-30 21:34:29');

-- --------------------------------------------------------

--
-- Structure de la table `quiz_options`
--

CREATE TABLE `quiz_options` (
  `id_option` int(11) NOT NULL,
  `id_question` int(11) DEFAULT NULL,
  `option_text` varchar(255) NOT NULL,
  `is_correct` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `quiz_options`
--

INSERT INTO `quiz_options` (`id_option`, `id_question`, `option_text`, `is_correct`) VALUES
(1, 1, 'Bleu', 1),
(2, 1, 'Rouge', 0),
(3, 1, 'Vert', 0),
(4, 1, 'Jaune', 0),
(5, 2, 'Oui', 0),
(6, 2, 'Non, tout le monde', 1),
(7, 2, 'Seulement les seniors', 0),
(8, 2, 'C\'est facultatif', 0);

-- --------------------------------------------------------

--
-- Structure de la table `quiz_questions`
--

CREATE TABLE `quiz_questions` (
  `id_question` int(11) NOT NULL,
  `id_formation` int(11) DEFAULT NULL,
  `question_text` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `quiz_questions`
--

INSERT INTO `quiz_questions` (`id_question`, `id_formation`, `question_text`) VALUES
(1, 1, 'Quelle est la couleur du logo OpenMinds ?'),
(2, 1, 'L\'inclusion concerne uniquement le handicap ?');

-- --------------------------------------------------------

--
-- Structure de la table `resultats`
--

CREATE TABLE `resultats` (
  `id_res` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_formation` int(11) DEFAULT NULL,
  `score` int(11) NOT NULL,
  `date_passage` datetime DEFAULT current_timestamp(),
  `est_valide` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `resultats`
--

INSERT INTO `resultats` (`id_res`, `id_user`, `id_formation`, `score`, `date_passage`, `est_valide`) VALUES
(3, 1, 1, 50, '2026-03-30 22:32:25', 0),
(4, 1, 1, 100, '2026-03-30 22:32:31', 1);

-- --------------------------------------------------------

--
-- Structure de la table `sessions`
--

CREATE TABLE `sessions` (
  `id_session` int(11) NOT NULL,
  `id_formation` int(11) DEFAULT NULL,
  `date_debut` datetime NOT NULL,
  `date_fin` datetime NOT NULL,
  `type_session` enum('Présentiel','En ligne') DEFAULT NULL,
  `lieu` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `sessions`
--

IINSERT INTO `sessions` (`id_session`, `id_formation`, `date_debut`, `date_fin`, `type_session`, `lieu`, `latitude`, `longitude`) VALUES
 (1, 1, '2026-04-15 09:00:00', '2026-04-15 17:00:00', 'Présentiel', '23 rue de la sablière, 93000 Bobigny', 48.90860000, 2.43970000),
 (2, 2, '2026-04-20 18:30:00', '2026-04-20 20:30:00', 'En ligne', 'Visioconférence Zoom', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `id_user` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password` varchar(255) NOT NULL,
  `ville` varchar(100) DEFAULT NULL,
  `code_postal` varchar(10) DEFAULT NULL,
  `telephone` varchar(20) DEFAULT NULL,
  `role` enum('Bénévole','Administrateur') DEFAULT 'Bénévole'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`id_user`, `nom`, `prenom`, `image_url`, `email`, `password`, `ville`, `code_postal`, `telephone`, `role`) VALUES
(1, 'Test', 'Apputchu', 'http://10.0.2.2/openminds_api/uploads/profile_1_1774903424.jpg', 'b', '$2y$10$uSVoyOAT8eD6WN/BK5m9UO3c3cgxEBViQaLtzpoMpPwZCoCtjlH8q', 'Bobigny', '93000', NULL, 'Bénévole'),
(2, 'a', 'a', 'http://10.0.2.2/openminds_api/uploads/profile_2_1774903449.jpg', 'a', '$2y$10$N4/9pK65mF5F.TO3Qs3eT.pZ9nNzEM1WE.uQpYb6.dVexrwnlyJ3.', 'a', 'a', 'a', 'Bénévole');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `formations`
--
ALTER TABLE `formations`
  ADD PRIMARY KEY (`id_formation`);

--
-- Index pour la table `inscriptions`
--
ALTER TABLE `inscriptions`
  ADD PRIMARY KEY (`id_user`,`id_session`),
  ADD KEY `fk_ins_session` (`id_session`);

--
-- Index pour la table `quiz_options`
--
ALTER TABLE `quiz_options`
  ADD PRIMARY KEY (`id_option`),
  ADD KEY `fk_opt_quest` (`id_question`);

--
-- Index pour la table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  ADD PRIMARY KEY (`id_question`),
  ADD KEY `fk_quest_form` (`id_formation`);

--
-- Index pour la table `resultats`
--
ALTER TABLE `resultats`
  ADD PRIMARY KEY (`id_res`),
  ADD KEY `fk_res_user` (`id_user`),
  ADD KEY `fk_res_form` (`id_formation`);

--
-- Index pour la table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id_session`),
  ADD KEY `fk_session_formation` (`id_formation`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `formations`
--
ALTER TABLE `formations`
  MODIFY `id_formation` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `quiz_options`
--
ALTER TABLE `quiz_options`
  MODIFY `id_option` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  MODIFY `id_question` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `resultats`
--
ALTER TABLE `resultats`
  MODIFY `id_res` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `id_session` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `inscriptions`
--
ALTER TABLE `inscriptions`
  ADD CONSTRAINT `fk_ins_session` FOREIGN KEY (`id_session`) REFERENCES `sessions` (`id_session`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ins_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateurs` (`id_user`) ON DELETE CASCADE;

--
-- Contraintes pour la table `quiz_options`
--
ALTER TABLE `quiz_options`
  ADD CONSTRAINT `fk_opt_quest` FOREIGN KEY (`id_question`) REFERENCES `quiz_questions` (`id_question`) ON DELETE CASCADE;

--
-- Contraintes pour la table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  ADD CONSTRAINT `fk_quest_form` FOREIGN KEY (`id_formation`) REFERENCES `formations` (`id_formation`) ON DELETE CASCADE;

--
-- Contraintes pour la table `resultats`
--
ALTER TABLE `resultats`
  ADD CONSTRAINT `fk_res_form` FOREIGN KEY (`id_formation`) REFERENCES `formations` (`id_formation`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_res_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateurs` (`id_user`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_session_formation` FOREIGN KEY (`id_formation`) REFERENCES `formations` (`id_formation`) ON DELETE CASCADE;


DELIMITER //
CREATE TRIGGER chk_password_before_insert
BEFORE INSERT ON utilisateurs
FOR EACH ROW
BEGIN
  IF CHAR_LENGTH(NEW.password) < 6 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Le mot de passe doit contenir au moins 6 caractères';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER chk_email_before_insert
BEFORE INSERT ON utilisateurs
FOR EACH ROW
BEGIN
  IF NEW.email NOT REGEXP '@(gmail\\.com|gmail\\.fr|yahoo\\.com|yahoo\\.fr|outlook\\.com|hotmail\\.com)$' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Domaine email non autorisé';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER chk_dates_before_insert
BEFORE INSERT ON sessions
FOR EACH ROW
BEGIN
  IF NEW.date_fin <= NEW.date_debut THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La date de fin doit être strictement supérieure à la date de début';
  END IF;
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER chk_dates_before_update
BEFORE UPDATE ON sessions
FOR EACH ROW
BEGIN
  IF NEW.date_fin <= NEW.date_debut THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La date de fin doit être strictement supérieure à la date de début';
  END IF;
END;
//
DELIMITER ;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
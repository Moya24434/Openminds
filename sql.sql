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

-- --------------------------------------------------------
-- STRUCTURE & DONNÉES
-- --------------------------------------------------------

-- Table `utilisateurs`
CREATE TABLE `utilisateurs` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `email` varchar(150) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `role` enum('Bénévole','Administrateur') DEFAULT 'Bénévole',
  PRIMARY KEY (`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `utilisateurs` (`id_user`, `nom`, `prenom`, `email`, `password`) VALUES
(1, 'Test', 'Apputchu', 'b', '$2y$10$uSVoyOAT8eD6WN/BK5m9UO3c3cgxEBViQaLtzpoMpPwZCoCtjlH8q');

-- Table `formations`
CREATE TABLE `formations` (
  `id_formation` int(11) NOT NULL AUTO_INCREMENT,
  `titre` varchar(255) NOT NULL,
  `description` text,
  `thematique` varchar(100),
  `image_url` varchar(255),
  PRIMARY KEY (`id_formation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `formations` (`id_formation`, `titre`, `description`, `thematique`, `image_url`) VALUES
(1, 'Formation au PSC1', 'Gestes qui sauvent.', 'Secourisme', 'https://via.placeholder.com/400x250'),
(2, 'Initiation au Bénévolat', 'Bases de l\'engagement.', 'Engagement', 'https://via.placeholder.com/400x250');

-- Table `sessions`
CREATE TABLE `sessions` (
  `id_session` int(11) NOT NULL AUTO_INCREMENT,
  `id_formation` int(11),
  `date_session` datetime NOT NULL,
  `type_session` enum('Présentiel','En ligne'),
  `lieu` varchar(255),
  PRIMARY KEY (`id_session`),
  CONSTRAINT `fk_session_formation` FOREIGN KEY (`id_formation`) REFERENCES `formations` (`id_formation`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `sessions` (`id_session`, `id_formation`, `date_session`, `type_session`, `lieu`) VALUES
(1, 1, '2026-04-15 09:00:00', 'Présentiel', 'Bobigny'),
(2, 2, '2026-04-20 18:30:00', 'En ligne', 'Zoom');

-- Table `inscriptions`
CREATE TABLE `inscriptions` (
  `id_user` int(11) NOT NULL,
  `id_session` int(11) NOT NULL,
  `date_inscription` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_user`,`id_session`),
  CONSTRAINT `fk_ins_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateurs` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `fk_ins_session` FOREIGN KEY (`id_session`) REFERENCES `sessions` (`id_session`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `inscriptions` (`id_user`, `id_session`) VALUES (1, 1);

-- Table `quiz_questions`
CREATE TABLE `quiz_questions` (
  `id_question` int(11) NOT NULL AUTO_INCREMENT,
  `id_formation` int(11),
  `question_text` text NOT NULL,
  PRIMARY KEY (`id_question`),
  CONSTRAINT `fk_quest_form` FOREIGN KEY (`id_formation`) REFERENCES `formations` (`id_formation`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `quiz_questions` (`id_question`, `id_formation`, `question_text`) VALUES
(1, 1, 'Quelle est la couleur du logo OpenMinds ?'),
(2, 1, 'L\'inclusion concerne uniquement le handicap ?');

-- Table `quiz_options`
CREATE TABLE `quiz_options` (
  `id_option` int(11) NOT NULL AUTO_INCREMENT,
  `id_question` int(11),
  `option_text` varchar(255) NOT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id_option`),
  CONSTRAINT `fk_opt_quest` FOREIGN KEY (`id_question`) REFERENCES `quiz_questions` (`id_question`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `quiz_options` (`id_option`, `id_question`, `option_text`, `is_correct`) VALUES
(1, 1, 'Bleu', 1), (2, 1, 'Rouge', 0), (3, 1, 'Vert', 0), (4, 1, 'Jaune', 0),
(5, 2, 'Oui', 0), (6, 2, 'Non, tout le monde', 1), (7, 2, 'Seulement les seniors', 0), (8, 2, 'C\'est facultatif', 0);

-- Trigger pour limiter à 4 choix
DELIMITER $$
CREATE TRIGGER `limit_options_per_question` BEFORE INSERT ON `quiz_options` FOR EACH ROW BEGIN
    DECLARE option_count INT;
    SELECT COUNT(*) INTO option_count FROM quiz_options WHERE id_question = NEW.id_question;
    IF option_count >= 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erreur : Max 4 choix par question.';
    END IF;
END $$
DELIMITER ;
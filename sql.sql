-- On supprime d'abord les tables qui dépendent des autres (les tables "esclaves")
DROP TABLE IF EXISTS Resultats;
DROP TABLE IF EXISTS Inscriptions;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS Sessions;

-- Enfin, on supprime les tables principales (les tables "maîtres")
DROP TABLE IF EXISTS Utilisateurs;
DROP TABLE IF EXISTS Formations;

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : dim. 29 mars 2026 à 20:05
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
-- Base de données : `open_minds`
--

-- --------------------------------------------------------

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
(1, 'Formation au PSC1', 'Soyez prêt à agir en cas d\'urgence ! Participez à notre formation PSC1 (Prévention et Secours Civiques de niveau 1) et apprenez les gestes essentiels pour sauver des vies.', 'Secourisme', 'https://via.placeholder.com/400x250/FF5733/FFFFFF?text=PSC1'),
(2, 'Initiation au Bénévolat', 'Découvrez les bases de l\'engagement associatif, vos droits, vos devoirs et comment vous rendre utile dans votre communauté locale.', 'Engagement', 'https://via.placeholder.com/400x250/33C1FF/FFFFFF?text=Bénévolat'),
(3, 'Soutien Scolaire', 'Apprenez les bonnes pratiques et la pédagogie pour accompagner les enfants en difficulté scolaire après l\'école.', 'Éducation', 'https://via.placeholder.com/400x250/28B463/FFFFFF?text=Soutien+Scolaire');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `formations`
--
ALTER TABLE `formations`
  ADD PRIMARY KEY (`id_formation`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `formations`
--
ALTER TABLE `formations`
  MODIFY `id_formation` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

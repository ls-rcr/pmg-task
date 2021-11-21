-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Gegenereerd op: 21 nov 2021 om 21:04
-- Serverversie: 10.4.21-MariaDB
-- PHP-versie: 7.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pmgtask`
--

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `pmgdata`
--

CREATE TABLE `pmgdata` (
  `pmgid` int(11) NOT NULL,
  `pmg_name` varchar(25) NOT NULL,
  `pmg_owner_name` varchar(24) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `pmgmembers`
--

CREATE TABLE `pmgmembers` (
  `id` int(11) NOT NULL,
  `username` varchar(24) NOT NULL,
  `pmgid` int(11) NOT NULL,
  `rankid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `pmgranks`
--

CREATE TABLE `pmgranks` (
  `id` int(11) NOT NULL,
  `pmgid` int(11) NOT NULL,
  `rankid` tinyint(4) NOT NULL,
  `rankname` varchar(24) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexen voor geëxporteerde tabellen
--

--
-- Indexen voor tabel `pmgdata`
--
ALTER TABLE `pmgdata`
  ADD PRIMARY KEY (`pmgid`);

--
-- Indexen voor tabel `pmgmembers`
--
ALTER TABLE `pmgmembers`
  ADD PRIMARY KEY (`id`);

--
-- Indexen voor tabel `pmgranks`
--
ALTER TABLE `pmgranks`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT voor geëxporteerde tabellen
--

--
-- AUTO_INCREMENT voor een tabel `pmgdata`
--
ALTER TABLE `pmgdata`
  MODIFY `pmgid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `pmgmembers`
--
ALTER TABLE `pmgmembers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT voor een tabel `pmgranks`
--
ALTER TABLE `pmgranks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

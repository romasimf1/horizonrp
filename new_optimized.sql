-- ==========================================
-- HorizonRP v2.0 - Оптимизированная БД
-- Кодировка: UTF-8
-- ==========================================

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Создание базы данных
CREATE DATABASE IF NOT EXISTS `horizonrp` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `horizonrp`;

-- ==========================================
-- Таблица пользователей
-- ==========================================
CREATE TABLE IF NOT EXISTS `users` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(24) NOT NULL,
  `Pass` varchar(128) NOT NULL COMMENT 'Хеш пароля',
  `Email` varchar(100) NOT NULL,
  `Referal` varchar(24) DEFAULT NULL,
  `DateReg` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LastLogin` timestamp NULL DEFAULT NULL,
  `Nations` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `Age` tinyint(3) unsigned NOT NULL DEFAULT 18,
  `Sex` tinyint(1) unsigned NOT NULL DEFAULT 1 COMMENT '1-мужской, 2-женский',
  `Skin` smallint(5) unsigned NOT NULL DEFAULT 32,
  `Money` int(11) NOT NULL DEFAULT 5000,
  `Level` smallint(5) unsigned NOT NULL DEFAULT 1,
  `Exp` int(11) NOT NULL DEFAULT 0,
  `AdminLevel` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `PlayTime` int(11) NOT NULL DEFAULT 0 COMMENT 'Время игры в секундах',
  `Warns` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `Bans` tinyint(2) unsigned NOT NULL DEFAULT 0,
  `PosX` float NOT NULL DEFAULT 1154.37,
  `PosY` float NOT NULL DEFAULT -1769.26,
  `PosZ` float NOT NULL DEFAULT 16.59,
  `Interior` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Health` float NOT NULL DEFAULT 100.0,
  `Armour` float NOT NULL DEFAULT 0.0,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `idx_email` (`Email`),
  KEY `idx_referal` (`Referal`),
  KEY `idx_level` (`Level`),
  KEY `idx_active` (`IsActive`),
  KEY `idx_admin` (`AdminLevel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица фракций
-- ==========================================
CREATE TABLE IF NOT EXISTS `factions` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(64) NOT NULL,
  `Tag` varchar(8) NOT NULL,
  `Color` int(11) NOT NULL DEFAULT 0xFFFFFFFF,
  `Type` tinyint(2) NOT NULL COMMENT '1-Gang, 2-Mafia, 3-Govt, 4-Other',
  `MaxMembers` smallint(5) unsigned NOT NULL DEFAULT 50,
  `Treasury` int(11) NOT NULL DEFAULT 0,
  `Materials` int(11) NOT NULL DEFAULT 0,
  `Drugs` int(11) NOT NULL DEFAULT 0,
  `SpawnX` float NOT NULL DEFAULT 0.0,
  `SpawnY` float NOT NULL DEFAULT 0.0,
  `SpawnZ` float NOT NULL DEFAULT 0.0,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  UNIQUE KEY `Tag` (`Tag`),
  KEY `idx_type` (`Type`),
  KEY `idx_active` (`IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Добавляем Grove Street
INSERT INTO `factions` (`ID`, `Name`, `Tag`, `Color`, `Type`, `SpawnX`, `SpawnY`, `SpawnZ`) VALUES
(1, 'Grove Street Families', 'GSF', 0x00FF00FF, 1, 2498.22, -1687.15, 13.51);

-- ==========================================
-- Таблица участников фракций
-- ==========================================
CREATE TABLE IF NOT EXISTS `faction_members` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `FactionID` int(11) NOT NULL,
  `Rank` tinyint(2) unsigned NOT NULL DEFAULT 1,
  `Materials` int(11) NOT NULL DEFAULT 0,
  `JoinDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `WarnsInFaction` tinyint(2) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `user_faction` (`UserID`, `FactionID`),
  KEY `idx_faction` (`FactionID`),
  KEY `idx_rank` (`Rank`),
  FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`FactionID`) REFERENCES `factions` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица рангов фракций
-- ==========================================
CREATE TABLE IF NOT EXISTS `faction_ranks` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `FactionID` int(11) NOT NULL,
  `RankLevel` tinyint(2) unsigned NOT NULL,
  `RankName` varchar(32) NOT NULL,
  `Salary` int(11) NOT NULL DEFAULT 0,
  `Permissions` varchar(255) DEFAULT NULL COMMENT 'JSON с правами',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `faction_rank` (`FactionID`, `RankLevel`),
  FOREIGN KEY (`FactionID`) REFERENCES `factions` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Добавляем ранги для Grove Street
INSERT INTO `faction_ranks` (`FactionID`, `RankLevel`, `RankName`, `Salary`) VALUES
(1, 1, 'Печенька', 500),
(1, 2, 'Пончик', 750),
(1, 3, 'Сэндвич', 1000),
(1, 4, 'Круассан', 1250),
(1, 5, 'Пицца', 1500),
(1, 6, 'Мороженка', 1750),
(1, 7, 'Чизкейк', 2000),
(1, 8, 'Капкейк', 2500),
(1, 9, 'Торт', 3000),
(1, 10, 'Король', 5000);

-- ==========================================
-- Таблица рефералов
-- ==========================================
CREATE TABLE IF NOT EXISTS `referals` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ReferalName` varchar(24) NOT NULL,
  `InvitedName` varchar(24) NOT NULL,
  `BonusGiven` tinyint(1) NOT NULL DEFAULT 0,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_referal` (`ReferalName`),
  KEY `idx_invited` (`InvitedName`),
  KEY `idx_bonus` (`BonusGiven`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица домов
-- ==========================================
CREATE TABLE IF NOT EXISTS `houses` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OwnerID` int(11) DEFAULT NULL,
  `Price` int(11) NOT NULL,
  `Locked` tinyint(1) NOT NULL DEFAULT 1,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `InteriorID` smallint(5) unsigned NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LastPayment` timestamp NULL DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `idx_owner` (`OwnerID`),
  KEY `idx_price` (`Price`),
  KEY `idx_active` (`IsActive`),
  FOREIGN KEY (`OwnerID`) REFERENCES `users` (`ID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица транспорта
-- ==========================================
CREATE TABLE IF NOT EXISTS `vehicles` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `OwnerID` int(11) DEFAULT NULL,
  `ModelID` smallint(5) unsigned NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `PosA` float NOT NULL DEFAULT 0.0,
  `Color1` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `Color2` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `Fuel` float NOT NULL DEFAULT 100.0,
  `Health` float NOT NULL DEFAULT 1000.0,
  `Locked` tinyint(1) NOT NULL DEFAULT 1,
  `Insurance` int(11) NOT NULL DEFAULT 0,
  `Plate` varchar(8) DEFAULT NULL,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `Interior` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `LastUsed` timestamp NULL DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `idx_owner` (`OwnerID`),
  KEY `idx_model` (`ModelID`),
  KEY `idx_plate` (`Plate`),
  KEY `idx_active` (`IsActive`),
  FOREIGN KEY (`OwnerID`) REFERENCES `users` (`ID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица банов
-- ==========================================
CREATE TABLE IF NOT EXISTS `bans` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `PlayerName` varchar(24) NOT NULL,
  `AdminName` varchar(24) NOT NULL,
  `Reason` varchar(128) NOT NULL,
  `BanDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UnbanDate` timestamp NULL DEFAULT NULL,
  `IP` varchar(15) DEFAULT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `idx_player` (`PlayerName`),
  KEY `idx_ip` (`IP`),
  KEY `idx_active` (`IsActive`),
  KEY `idx_unban` (`UnbanDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица логов
-- ==========================================
CREATE TABLE IF NOT EXISTS `logs` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` varchar(32) NOT NULL COMMENT 'login, money, admin, faction, etc',
  `PlayerID` int(11) DEFAULT NULL,
  `AdminID` int(11) DEFAULT NULL,
  `Message` text NOT NULL,
  `AdditionalData` json DEFAULT NULL,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_type` (`Type`),
  KEY `idx_player` (`PlayerID`),
  KEY `idx_admin` (`AdminID`),
  KEY `idx_created` (`Created`),
  FOREIGN KEY (`PlayerID`) REFERENCES `users` (`ID`) ON DELETE SET NULL,
  FOREIGN KEY (`AdminID`) REFERENCES `users` (`ID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица статистики сервера
-- ==========================================
CREATE TABLE IF NOT EXISTS `server_stats` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Date` date NOT NULL,
  `UniqueConnections` int(11) NOT NULL DEFAULT 0,
  `PeakOnline` smallint(5) unsigned NOT NULL DEFAULT 0,
  `NewRegistrations` int(11) NOT NULL DEFAULT 0,
  `PlayTime` bigint(20) NOT NULL DEFAULT 0 COMMENT 'Общее время игры всех игроков',
  `MoneyEarned` bigint(20) NOT NULL DEFAULT 0,
  `MoneySpent` bigint(20) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Date` (`Date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Создание процедур для оптимизации
-- ==========================================

-- Процедура для получения информации об игроке
DELIMITER //
CREATE PROCEDURE GetPlayerData(IN playerName VARCHAR(24))
BEGIN
    SELECT 
        u.*,
        fm.FactionID,
        fm.Rank,
        fm.Materials,
        f.Name as FactionName,
        fr.RankName
    FROM users u
    LEFT JOIN faction_members fm ON u.ID = fm.UserID
    LEFT JOIN factions f ON fm.FactionID = f.ID
    LEFT JOIN faction_ranks fr ON f.ID = fr.FactionID AND fm.Rank = fr.RankLevel
    WHERE u.Name = playerName AND u.IsActive = 1;
END //

-- Процедура для сохранения позиции игрока
CREATE PROCEDURE SavePlayerPosition(
    IN playerID INT,
    IN posX FLOAT,
    IN posY FLOAT,
    IN posZ FLOAT,
    IN interior INT,
    IN virtualWorld INT
)
BEGIN
    UPDATE users SET 
        PosX = posX,
        PosY = posY,
        PosZ = posZ,
        Interior = interior,
        VirtualWorld = virtualWorld,
        LastLogin = CURRENT_TIMESTAMP
    WHERE ID = playerID;
END //

-- Процедура для добавления лога
CREATE PROCEDURE AddLog(
    IN logType VARCHAR(32),
    IN playerID INT,
    IN adminID INT,
    IN message TEXT,
    IN additionalData JSON
)
BEGIN
    INSERT INTO logs (Type, PlayerID, AdminID, Message, AdditionalData)
    VALUES (logType, playerID, adminID, message, additionalData);
END //

DELIMITER ;

-- ==========================================
-- Создание индексов для производительности
-- ==========================================

-- Составные индексы для частых запросов
CREATE INDEX idx_user_faction_rank ON faction_members (UserID, FactionID, Rank);
CREATE INDEX idx_faction_active_members ON faction_members (FactionID, UserID);
CREATE INDEX idx_logs_type_date ON logs (Type, Created);
CREATE INDEX idx_users_level_money ON users (Level, Money);

-- ==========================================
-- Создание VIEW для удобства
-- ==========================================

-- VIEW для участников фракций с полной информацией
CREATE VIEW faction_members_view AS
SELECT 
    u.ID as UserID,
    u.Name as UserName,
    u.Level,
    f.ID as FactionID,
    f.Name as FactionName,
    f.Tag as FactionTag,
    fm.Rank,
    fr.RankName,
    fr.Salary,
    fm.Materials,
    fm.JoinDate
FROM users u
JOIN faction_members fm ON u.ID = fm.UserID
JOIN factions f ON fm.FactionID = f.ID
JOIN faction_ranks fr ON f.ID = fr.FactionID AND fm.Rank = fr.RankLevel
WHERE u.IsActive = 1 AND f.IsActive = 1;

-- VIEW для топ игроков
CREATE VIEW top_players AS
SELECT 
    Name,
    Level,
    Money,
    PlayTime,
    DateReg
FROM users 
WHERE IsActive = 1 
ORDER BY Level DESC, Money DESC 
LIMIT 100;

-- ==========================================
-- Настройки оптимизации
-- ==========================================

-- Оптимизируем таблицы
OPTIMIZE TABLE users, factions, faction_members, faction_ranks, referals, logs;

-- Анализируем таблицы для обновления статистики
ANALYZE TABLE users, factions, faction_members, faction_ranks, referals, logs;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
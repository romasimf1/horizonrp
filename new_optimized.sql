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
-- Таблица работ
-- ==========================================
CREATE TABLE IF NOT EXISTS `jobs` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(64) NOT NULL,
  `Description` text NOT NULL,
  `MinLevel` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `MaxLevel` tinyint(3) unsigned NOT NULL DEFAULT 50,
  `BaseSalary` int(11) NOT NULL DEFAULT 1000,
  `BonusPerLevel` int(11) NOT NULL DEFAULT 50,
  `RequiredSkin` smallint(5) unsigned DEFAULT NULL,
  `WorkLocationX` float NOT NULL,
  `WorkLocationY` float NOT NULL,
  `WorkLocationZ` float NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`),
  KEY `idx_level` (`MinLevel`, `MaxLevel`),
  KEY `idx_active` (`IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Добавляем основные работы
INSERT INTO `jobs` (`Name`, `Description`, `MinLevel`, `MaxLevel`, `BaseSalary`, `BonusPerLevel`, `RequiredSkin`, `WorkLocationX`, `WorkLocationY`, `WorkLocationZ`) VALUES
('Грузчик', 'Загрузка и разгрузка товаров в порту Лос-Сантоса', 1, 10, 1500, 100, 27, 2751.64, -2454.12, 13.64),
('Водитель автобуса', 'Перевозка пассажиров по городу', 3, 15, 2000, 150, 255, 1809.22, -1905.45, 13.38),
('Дальнобойщик', 'Перевозка грузов между городами', 5, 20, 2500, 200, 8, 2197.43, -2663.32, 13.54),
('Таксист', 'Перевозка пассажиров на такси', 2, 12, 1800, 120, 61, 1152.33, -1760.85, 13.59),
('Механик', 'Ремонт и тюнинг автомобилей', 4, 18, 2200, 175, 50, 2386.23, -2077.44, 13.55),
('Полицейский', 'Охрана правопорядка в городе', 8, 35, 3500, 300, 280, 1554.83, -1675.52, 16.20),
('Медик', 'Оказание медицинской помощи', 6, 25, 3000, 250, 274, 1172.12, -1323.45, 15.40),
('Пожарный', 'Тушение пожаров и спасательные операции', 7, 22, 2800, 225, 277, 1762.44, -1451.23, 13.52);

-- ==========================================
-- Таблица занятости игроков
-- ==========================================
CREATE TABLE IF NOT EXISTS `player_jobs` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `JobID` int(11) NOT NULL,
  `JobLevel` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `Experience` int(11) NOT NULL DEFAULT 0,
  `TotalEarned` bigint(20) NOT NULL DEFAULT 0,
  `WorkHours` int(11) NOT NULL DEFAULT 0,
  `HiredDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `user_job` (`UserID`, `JobID`),
  KEY `idx_job` (`JobID`),
  KEY `idx_level` (`JobLevel`),
  KEY `idx_active` (`IsActive`),
  FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE,
  FOREIGN KEY (`JobID`) REFERENCES `jobs` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица банковских счетов
-- ==========================================
CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) NOT NULL,
  `AccountNumber` varchar(16) NOT NULL,
  `Balance` int(11) NOT NULL DEFAULT 0,
  `AccountType` tinyint(2) NOT NULL DEFAULT 1 COMMENT '1-Дебетовый, 2-Кредитный',
  `CreditLimit` int(11) NOT NULL DEFAULT 0,
  `InterestRate` decimal(5,2) NOT NULL DEFAULT 0.05,
  `LastInterest` timestamp NULL DEFAULT NULL,
  `PIN` varchar(4) NOT NULL,
  `IsBlocked` tinyint(1) NOT NULL DEFAULT 0,
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `UserID` (`UserID`),
  UNIQUE KEY `AccountNumber` (`AccountNumber`),
  KEY `idx_balance` (`Balance`),
  KEY `idx_blocked` (`IsBlocked`),
  FOREIGN KEY (`UserID`) REFERENCES `users` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица банковских транзакций
-- ==========================================
CREATE TABLE IF NOT EXISTS `bank_transactions` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `FromAccountID` int(11) DEFAULT NULL,
  `ToAccountID` int(11) DEFAULT NULL,
  `Amount` int(11) NOT NULL,
  `TransactionType` varchar(32) NOT NULL COMMENT 'deposit, withdraw, transfer, salary, fine',
  `Description` varchar(255) DEFAULT NULL,
  `Fee` int(11) NOT NULL DEFAULT 0,
  `BalanceBefore` int(11) NOT NULL DEFAULT 0,
  `BalanceAfter` int(11) NOT NULL DEFAULT 0,
  `ProcessedBy` int(11) DEFAULT NULL COMMENT 'Кто обработал транзакцию',
  `Created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `idx_from_account` (`FromAccountID`),
  KEY `idx_to_account` (`ToAccountID`),
  KEY `idx_type` (`TransactionType`),
  KEY `idx_created` (`Created`),
  FOREIGN KEY (`FromAccountID`) REFERENCES `bank_accounts` (`ID`) ON DELETE SET NULL,
  FOREIGN KEY (`ToAccountID`) REFERENCES `bank_accounts` (`ID`) ON DELETE SET NULL,
  FOREIGN KEY (`ProcessedBy`) REFERENCES `users` (`ID`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- Таблица банкоматов и банков
-- ==========================================
CREATE TABLE IF NOT EXISTS `atm_locations` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` tinyint(2) NOT NULL COMMENT '1-ATM, 2-Bank',
  `Name` varchar(64) NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `Interior` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `idx_type` (`Type`),
  KEY `idx_active` (`IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Добавляем банки и банкоматы в Лос-Сантосе
INSERT INTO `atm_locations` (`Type`, `Name`, `PosX`, `PosY`, `PosZ`) VALUES
(2, 'Los Santos Bank - Downtown', 1481.02, -1722.85, 13.55),
(2, 'Los Santos Bank - Commerce', 2315.95, -10.44, 26.74),
(2, 'Los Santos Bank - Vinewood', 1038.23, -1339.84, 13.74),
(1, 'ATM - Grove Street', 2229.18, -1721.71, 13.56),
(1, 'ATM - Idlewood', 2105.37, -1806.50, 13.55),
(1, 'ATM - East Los Santos', 2422.84, -1518.29, 24.00),
(1, 'ATM - Unity Station', 1928.59, -1776.33, 13.55),
(1, 'ATM - Jefferson', 2093.62, -1358.48, 24.52),
(1, 'ATM - Ganton', 2325.89, -1645.13, 14.83),
(1, 'ATM - Glen Park', 2001.23, -1114.34, 27.12);

-- ==========================================
-- Таблица мэрии и офисов трудоустройства
-- ==========================================
CREATE TABLE IF NOT EXISTS `city_offices` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Type` tinyint(2) NOT NULL COMMENT '1-City Hall, 2-Job Center, 3-Licensing',
  `Name` varchar(64) NOT NULL,
  `PosX` float NOT NULL,
  `PosY` float NOT NULL,
  `PosZ` float NOT NULL,
  `Interior` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `VirtualWorld` int(11) NOT NULL DEFAULT 0,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`),
  KEY `idx_type` (`Type`),
  KEY `idx_active` (`IsActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Добавляем мэрию и центры трудоустройства
INSERT INTO `city_offices` (`Type`, `Name`, `PosX`, `PosY`, `PosZ`) VALUES
(1, 'Los Santos City Hall', 1481.02, -1722.85, 13.55),
(2, 'Job Center - Downtown', 1368.12, -1279.89, 13.55),
(2, 'Job Center - Commerce', 1153.44, -1440.23, 15.80),
(3, 'DMV - Los Santos', 1494.32, -1770.45, 18.80);

-- Обновляем таблицу пользователей для экономической системы
ALTER TABLE `users` 
ADD COLUMN `BankAccount` varchar(16) DEFAULT NULL AFTER `Money`,
ADD COLUMN `CurrentJob` int(11) DEFAULT NULL AFTER `BankAccount`,
ADD COLUMN `JobLevel` tinyint(3) unsigned NOT NULL DEFAULT 0 AFTER `CurrentJob`,
ADD COLUMN `JobExperience` int(11) NOT NULL DEFAULT 0 AFTER `JobLevel`,
ADD COLUMN `PayCheck` int(11) NOT NULL DEFAULT 0 AFTER `JobExperience`,
ADD COLUMN `TotalEarned` bigint(20) NOT NULL DEFAULT 0 AFTER `PayCheck`,
ADD INDEX `idx_bank_account` (`BankAccount`),
ADD INDEX `idx_current_job` (`CurrentJob`);

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
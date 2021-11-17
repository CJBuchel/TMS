-- SQL Template for FLL --

CREATE USER 'fss'@'localhost' IDENTIFIED BY 'fss';

GRANT ALL PRIVILEGES ON * . * TO 'fss'@'localhost';

CREATE DATABASE IF NOT EXISTS fss_fll_database;

USE fss_fll_database;

-- Users table for different users (scorer, admin etc..)
CREATE TABLE IF NOT EXISTS `users` (
	`id` INT,
	`name` VARCHAR(35),
	`password` VARCHAR(45),
	PRIMARY KEY (`id`)
);

-- Team table of data --
-- A team will have a team number, their name, their school, what each of their match score was, and their overall rank
CREATE TABLE IF NOT EXISTS `fll_teams` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`team_number` INT,
	`team_name` TEXT,
	`school_name` TEXT,
	`match_score_1` DOUBLE,
	`match_score_2` DOUBLE,
	`match_score_3` DOUBLE,
	`rank` INT,
	PRIMARY KEY (`id`)
);
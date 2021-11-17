-- SQL Template for FLL --

DROP USER 'fss'@'localhost';
CREATE USER IF NOT EXISTS 'fss'@'localhost' IDENTIFIED BY 'fss';
GRANT ALL PRIVILEGES ON * . * TO 'fss'@'localhost';
ALTER USER 'fss'@'localhost' IDENTIFIED WITH mysql_native_password BY 'fss';
flush privileges;

DROP DATABASE fss_fll_database;
CREATE DATABASE IF NOT EXISTS fss_fll_database;

USE fss_fll_database;

-- Users table for different users (scorer, admin etc..)
CREATE TABLE IF NOT EXISTS `users` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(35),
	`password` VARCHAR(45),
	PRIMARY KEY (`id`)
);

-- Insert default users
INSERT INTO users (name, password) VALUES ('admin', 'password');
INSERT INTO users (name, password) VALUES ('scorekeeper', 'password');
INSERT INTO users (name, password) VALUES ('referee', 'password');


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
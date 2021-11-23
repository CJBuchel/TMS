-- SQL Template for FLL --

-- DROP USER 'fss'@'localhost';
CREATE USER IF NOT EXISTS 'fss'@'localhost' IDENTIFIED BY 'fss';
GRANT ALL PRIVILEGES ON * . * TO 'fss'@'localhost';
ALTER USER 'fss'@'localhost' IDENTIFIED WITH mysql_native_password BY 'fss';
flush privileges;

-- DROP DATABASE fss_fll_database;
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
	`team_number` VARCHAR(10),
	`team_name` TEXT,
	`school_name` TEXT,

	`match_score_1` DOUBLE,
	`match_score_2` DOUBLE,
	`match_score_3` DOUBLE,

	`match_gp_1` TEXT,
	`match_gp_2` TEXT,
	`match_gp_3` TEXT,

	`team_notes_1` TEXT,
	`team_notes_2` TEXT,
	`team_notes_3` TEXT,

	`ranking` INT,
	PRIMARY KEY (`id`)
);

-- Schedule data
CREATE TABLE IF NOT EXISTS `fll_teams_schedule` (
	`id` INT NOT NULL AUTO_INCREMENT,
	`match_number` VARCHAR(10),
	`start_time` TEXT, -- CSV Import is not date and time 
	`end_time` TEXT,
	`team_number` VARCHAR(10),
	PRIMARY KEY (`id`)
);

-- INSERT INTO fll_teams (team_number, team_name, school_name) VALUES ('0000', 'cj dev', 'Curtin University');
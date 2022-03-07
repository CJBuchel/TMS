-- SQL TEMPLATE --
-- Anything placed in here will deploy to database in docker --

-- User cjms (if not already setup)
CREATE USER IF NOT EXISTS 'cjms'@'localhost' IDENTIFIED BY 'cjms';
GRANT ALL PRIVILEGES ON * . * TO 'cjms'@'localhost';
ALTER USER 'cjms'@'localhost' IDENTIFIED WITH mysql_native_password BY 'cjms';
flush privileges;

DROP DATABASE IF EXISTS cjms_database;
CREATE DATABASE IF NOT EXISTS cjms_database;

USE cjms_database;

-- Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(35),
  `password` VARCHAR(45),
  PRIMARY KEY (`id`)
);

-- Insert default users and passwords
INSERT INTO users (name, password) VALUES ('admin', 'password');
INSERT INTO users (name, password) VALUES ('scorekeeper', 'password');
INSERT INTO users (name, password) VALUES ('referee', 'password');
INSERT INTO users (name, password) VALUES ('head_referee', 'password');

-- Team Table
-- They have a number, their name, affiliation, score and rank
CREATE TABLE IF NOT EXISTS `teams` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `team_number` VARCHAR(10),
  `team_name` TEXT,
  `affiliation` TEXT,

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

-- Match Schedule Data
CREATE TABLE IF NOT EXISTS `match_schedule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `match_number` INT,
  `start_time` TEXT, -- CSV Import is not date and time 
  `end_time` TEXT,
  `team_number` VARCHAR(10),
  `on_table` TEXT,
  PRIMARY KEY (`id`)
);

-- Judging Schedule Data
CREATE TABLE IF NOT EXISTS `judging_schedule` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `start_time` TEXT, -- CSV Import is not date and time 
  `end_time` TEXT,
  `team_number` VARCHAR(10),
  `room_name` TEXT,
  PRIMARY KEY (`id`)
);

-- Match Data
CREATE TABLE IF NOT EXISTS `matches` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `next_match_number` INT,

  `next_start_time` TEXT, -- CSV Import is not date and time format
  `next_end_time` TEXT,

  `on_table1` TEXT, -- First table number/name
  `on_table2` TEXT, -- Second table number/name

  `next_team1_number` VARCHAR(10),
  `next_team2_number` VARCHAR(10),

  `next_team1_score_submitted` BOOLEAN NOT NULL DEFAULT 0,
  `next_team2_score_submitted` BOOLEAN NOT NULL DEFAULT 0,

  `complete` BOOLEAN NOT NULL DEFAULT 0, -- is the match complete
  `rescheduled` BOOLEAN NOT NULL DEFAULT 0, -- has this match been rescheduled

  PRIMARY KEY (`id`)
);
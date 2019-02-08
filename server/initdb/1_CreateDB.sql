CREATE USER 'user' IDENTIFIED BY 'password'; 

CREATE DATABASE `opinidb` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

GRANT INSERT, SELECT, UPDATE ON `opinidb`.* TO 'user';

USE `opinidb`;

CREATE TABLE `opinidb`.`opinion`(
	ID  INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	USER CHAR(10),
	NUM  INT,
	OPI  CHAR(10)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (1,1,'agree');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (2,1,'opposite');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (3,1,'agree');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (1,2,'agree');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (2,2,'opposite');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (3,2,'agree');
INSERT INTO opinidb.opinion(USER,NUM,OPI) VALUES (1,2,'neutral');
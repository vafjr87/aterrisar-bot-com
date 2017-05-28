-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
SHOW WARNINGS;
-- -----------------------------------------------------
-- Schema lbd
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `lbd` ;

-- -----------------------------------------------------
-- Schema lbd
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `lbd` DEFAULT CHARACTER SET latin1 ;
SHOW WARNINGS;
USE `lbd` ;

-- -----------------------------------------------------
-- Table `Companhia`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Companhia` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Companhia` (
  `com_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `registro` VARCHAR(30) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`com_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Aeronave`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Aeronave` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Aeronave` (
  `aer_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `modelo` VARCHAR(10) NOT NULL,
  `qtd_assentos` INT(11) NOT NULL,
  `com_companhia` INT(11) NOT NULL,
  PRIMARY KEY (`aer_codigo`),
  INDEX `com_companhia` (`com_companhia` ASC),
  CONSTRAINT `aeronave_ibfk_1`
    FOREIGN KEY (`com_companhia`)
    REFERENCES `Companhia` (`com_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Aeroporto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Aeroporto` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Aeroporto` (
  `sigla` VARCHAR(3) NOT NULL,
  `local` VARCHAR(30) NOT NULL,
  `nome` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`sigla`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Assento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Assento` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Assento` (
  `ass_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `classe` SMALLINT(1) NOT NULL,
  `aer_codigo` INT(11) NOT NULL,
  `numero` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`ass_codigo`),
  INDEX `aer_codigo` (`aer_codigo` ASC),
  CONSTRAINT `assento_ibfk_1`
    FOREIGN KEY (`aer_codigo`)
    REFERENCES `Aeronave` (`aer_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Viagem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Viagem` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Viagem` (
  `via_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `origem` VARCHAR(30) NOT NULL,
  `destinho` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`via_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Passageiro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Passageiro` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Passageiro` (
  `psg_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `documento` INT(11) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `endereco` VARCHAR(50) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  PRIMARY KEY (`psg_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Historico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Historico` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Historico` (
  `his_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `psg_codigo` INT(11) NOT NULL,
  `data` DATETIME NOT NULL,
  `via_codigo` INT(11) NOT NULL,
  `valor_pago` DOUBLE NOT NULL,
  PRIMARY KEY (`his_codigo`),
  INDEX `via_codigo` (`via_codigo` ASC),
  INDEX `psg_codigo` (`psg_codigo` ASC),
  CONSTRAINT `historico_ibfk_1`
    FOREIGN KEY (`via_codigo`)
    REFERENCES `Viagem` (`via_codigo`),
  CONSTRAINT `historico_ibfk_2`
    FOREIGN KEY (`psg_codigo`)
    REFERENCES `Passageiro` (`psg_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Voo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Voo` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Voo` (
  `voo_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `origem` VARCHAR(3) NOT NULL,
  `destino` VARCHAR(3) NOT NULL,
  `data_hora_ini` DATETIME NOT NULL,
  `data_hora_fim` DATETIME NOT NULL,
  `aer_codigo` INT(11) NOT NULL,
  `disponivel` TINYINT(1) NOT NULL,
  `preco` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`voo_codigo`),
  INDEX `origem` (`origem` ASC),
  INDEX `destino` (`destino` ASC),
  INDEX `aer_codigo` (`aer_codigo` ASC),
  CONSTRAINT `voo_ibfk_1`
    FOREIGN KEY (`origem`)
    REFERENCES `Aeroporto` (`sigla`),
  CONSTRAINT `voo_ibfk_2`
    FOREIGN KEY (`destino`)
    REFERENCES `Aeroporto` (`sigla`),
  CONSTRAINT `voo_ibfk_3`
    FOREIGN KEY (`aer_codigo`)
    REFERENCES `Aeronave` (`aer_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Passagem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Passagem` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Passagem` (
  `pas_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `status` VARCHAR(30) NOT NULL,
  `psg_codigo` INT(11) NOT NULL,
  `voo_codigo` INT(11) NOT NULL,
  `ass_codigo` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`pas_codigo`),
  INDEX `psg_codigo` (`psg_codigo` ASC),
  INDEX `ass_codigo` (`ass_codigo` ASC),
  INDEX `voo_codigo` (`voo_codigo` ASC),
  CONSTRAINT `passagem_ibfk_1`
    FOREIGN KEY (`psg_codigo`)
    REFERENCES `Passageiro` (`psg_codigo`),
  CONSTRAINT `passagem_ibfk_2`
    FOREIGN KEY (`ass_codigo`)
    REFERENCES `Assento` (`ass_codigo`),
  CONSTRAINT `passagem_ibfk_3`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Promocao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Promocao` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Promocao` (
  `pro_codigo` INT(5) NOT NULL,
  `desconto` DECIMAL(3,2) NOT NULL,
  `data_ini` DATETIME NOT NULL,
  `data_fim` DATETIME NOT NULL,
  `voo_codigo` INT(11) NOT NULL,
  PRIMARY KEY (`pro_codigo`),
  INDEX `voo_codigo` (`voo_codigo` ASC),
  CONSTRAINT `promocao_ibfk_1`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table `Trecho`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Trecho` ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS `Trecho` (
  `voo_codigo` INT(11) NOT NULL,
  `via_codigo` INT(11) NOT NULL,
  INDEX `via_codigo` (`via_codigo` ASC),
  PRIMARY KEY (`via_codigo`, `voo_codigo`),
  CONSTRAINT `trecho_ibfk_1`
    FOREIGN KEY (`via_codigo`)
    REFERENCES `Viagem` (`via_codigo`),
  CONSTRAINT `trecho_ibfk_2`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

SHOW WARNINGS;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

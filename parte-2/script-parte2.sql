-- MySQL Script generated by MySQL Workbench
-- Sun May 28 06:00:05 2017
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema lbd
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `lbd` ;

-- -----------------------------------------------------
-- Schema lbd
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `lbd` DEFAULT CHARACTER SET latin1 ;
USE `lbd` ;

-- -----------------------------------------------------
-- Table `lbd`.`Companhia`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Companhia` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Companhia` (
  `com_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `registro` VARCHAR(30) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`com_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `lbd`.`Aeronave`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Aeronave` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Aeronave` (
  `aer_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `modelo` VARCHAR(10) NOT NULL,
  `qtd_assentos` INT(11) NOT NULL,
  `com_companhia` INT(11) NOT NULL,
  PRIMARY KEY (`aer_codigo`),
  CONSTRAINT `aeronave_ibfk_1`
    FOREIGN KEY (`com_companhia`)
    REFERENCES `lbd`.`Companhia` (`com_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `com_companhia` ON `lbd`.`Aeronave` (`com_companhia` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Aeroporto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Aeroporto` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Aeroporto` (
  `sigla` VARCHAR(3) NOT NULL,
  `local` VARCHAR(30) NOT NULL,
  `nome` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`sigla`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `lbd`.`Assento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Assento` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Assento` (
  `ass_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `classe` SMALLINT(1) NOT NULL,
  `aer_codigo` INT(11) NOT NULL,
  `numero` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`ass_codigo`),
  CONSTRAINT `assento_ibfk_1`
    FOREIGN KEY (`aer_codigo`)
    REFERENCES `lbd`.`Aeronave` (`aer_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `aer_codigo` ON `lbd`.`Assento` (`aer_codigo` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Viagem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Viagem` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Viagem` (
  `via_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `origem` VARCHAR(30) NOT NULL,
  `destinho` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`via_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `lbd`.`Passageiro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Passageiro` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Passageiro` (
  `psg_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `documento` INT(11) NOT NULL,
  `nome` VARCHAR(50) NOT NULL,
  `endereco` VARCHAR(50) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  PRIMARY KEY (`psg_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `lbd`.`Historico`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Historico` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Historico` (
  `his_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `psg_codigo` INT(11) NOT NULL,
  `data` DATETIME NOT NULL,
  `via_codigo` INT(11) NOT NULL,
  `valor_pago` DOUBLE NOT NULL,
  PRIMARY KEY (`his_codigo`),
  CONSTRAINT `historico_ibfk_1`
    FOREIGN KEY (`via_codigo`)
    REFERENCES `lbd`.`Viagem` (`via_codigo`),
  CONSTRAINT `historico_ibfk_2`
    FOREIGN KEY (`psg_codigo`)
    REFERENCES `lbd`.`Passageiro` (`psg_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `via_codigo` ON `lbd`.`Historico` (`via_codigo` ASC);

CREATE INDEX `psg_codigo` ON `lbd`.`Historico` (`psg_codigo` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Voo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Voo` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Voo` (
  `voo_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `origem` VARCHAR(3) NOT NULL,
  `destino` VARCHAR(3) NOT NULL,
  `data_hora_ini` DATETIME NOT NULL,
  `data_hora_fim` DATETIME NOT NULL,
  `aer_codigo` INT(11) NOT NULL,
  `disponivel` TINYINT(1) NOT NULL,
  `preco` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`voo_codigo`),
  CONSTRAINT `voo_ibfk_1`
    FOREIGN KEY (`origem`)
    REFERENCES `lbd`.`Aeroporto` (`sigla`),
  CONSTRAINT `voo_ibfk_2`
    FOREIGN KEY (`destino`)
    REFERENCES `lbd`.`Aeroporto` (`sigla`),
  CONSTRAINT `voo_ibfk_3`
    FOREIGN KEY (`aer_codigo`)
    REFERENCES `lbd`.`Aeronave` (`aer_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `origem` ON `lbd`.`Voo` (`origem` ASC);

CREATE INDEX `destino` ON `lbd`.`Voo` (`destino` ASC);

CREATE INDEX `aer_codigo` ON `lbd`.`Voo` (`aer_codigo` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Passagem`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Passagem` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Passagem` (
  `pas_codigo` INT(11) NOT NULL AUTO_INCREMENT,
  `status` VARCHAR(30) NOT NULL,
  `psg_codigo` INT(11) NOT NULL,
  `voo_codigo` INT(11) NOT NULL,
  `ass_codigo` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`pas_codigo`),
  CONSTRAINT `passagem_ibfk_1`
    FOREIGN KEY (`psg_codigo`)
    REFERENCES `lbd`.`Passageiro` (`psg_codigo`),
  CONSTRAINT `passagem_ibfk_2`
    FOREIGN KEY (`ass_codigo`)
    REFERENCES `lbd`.`Assento` (`ass_codigo`),
  CONSTRAINT `passagem_ibfk_3`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `lbd`.`Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `psg_codigo` ON `lbd`.`Passagem` (`psg_codigo` ASC);

CREATE INDEX `ass_codigo` ON `lbd`.`Passagem` (`ass_codigo` ASC);

CREATE INDEX `voo_codigo` ON `lbd`.`Passagem` (`voo_codigo` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Promocao`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Promocao` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Promocao` (
  `primary_key` INT(5) NOT NULL,
  `desconto` DECIMAL(3,2) NOT NULL,
  `data_ini` DATETIME NOT NULL,
  `data_fim` DATETIME NOT NULL,
  `voo_codigo` INT(11) NOT NULL,
  PRIMARY KEY (`primary_key`),
  CONSTRAINT `promocao_ibfk_1`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `lbd`.`Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `voo_codigo` ON `lbd`.`Promocao` (`voo_codigo` ASC);


-- -----------------------------------------------------
-- Table `lbd`.`Trecho`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `lbd`.`Trecho` ;

CREATE TABLE IF NOT EXISTS `lbd`.`Trecho` (
  `voo_codigo` INT(11) NOT NULL,
  `via_codigo` INT(11) NOT NULL,
  PRIMARY KEY (`voo_codigo`, `via_codigo`),
  CONSTRAINT `trecho_ibfk_1`
    FOREIGN KEY (`via_codigo`)
    REFERENCES `lbd`.`Viagem` (`via_codigo`),
  CONSTRAINT `trecho_ibfk_2`
    FOREIGN KEY (`voo_codigo`)
    REFERENCES `lbd`.`Voo` (`voo_codigo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;

CREATE INDEX `via_codigo` ON `lbd`.`Trecho` (`via_codigo` ASC);


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

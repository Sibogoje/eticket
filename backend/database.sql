/*
SQLyog Ultimate v13.1.1 (64 bit)
MySQL - 10.4.32-MariaDB : Database - lujuvents
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`lujuvents` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `lujuvents`;

/*Table structure for table `admins` */

DROP TABLE IF EXISTS `admins`;

CREATE TABLE `admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `admins` */

insert  into `admins`(`id`,`username`,`password`,`created_at`) values 
(1,'admin','admin123','2025-04-13 17:22:19');

/*Table structure for table `tickets` */

DROP TABLE IF EXISTS `tickets`;

CREATE TABLE `tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  `email` varchar(100) NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL,
  `age` int(11) NOT NULL,
  `ticket_type` enum('First Day','Second Day','Both Days') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `ticket_number` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `tickets` */

insert  into `tickets`(`id`,`name`,`surname`,`phone_number`,`email`,`gender`,`age`,`ticket_type`,`created_at`,`ticket_number`) values 
(1,'Siboniso ','Sibandze','76547494','sibo#gmail.com','Male',32,'First Day','2025-04-13 16:39:40',NULL),
(2,'Managliso','Shandu','7565968','manga@gmail.com','Female',23,'First Day','2025-04-13 16:49:57','LUJU-142072'),
(3,'Managliso','Shandu','7565968','manga@gmail.com','Female',23,'First Day','2025-04-13 16:50:40','LUJU-176772'),
(4,'Managliso','Shandu','7565968','manga@gmail.com','Female',23,'First Day','2025-04-13 16:50:43','LUJU-849584'),
(5,'Andile','Sibandze','78216019','and@gmail.com','Female',34,'Second Day','2025-04-13 16:51:44','LUJU-156317');

/*Table structure for table `vendors` */

DROP TABLE IF EXISTS `vendors`;

CREATE TABLE `vendors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_ticket_number` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `surname` varchar(100) NOT NULL,
  `products` text NOT NULL,
  `stall_size` enum('Small','Medium','Large') NOT NULL,
  `event_days` enum('First Day','Second Day','Both Days') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `vendor_ticket_number` (`vendor_ticket_number`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

/*Data for the table `vendors` */

insert  into `vendors`(`id`,`vendor_ticket_number`,`name`,`surname`,`products`,`stall_size`,`event_days`,`created_at`) values 
(1,'VENDOR-544064','Siboniso','Sibandze','Maize, Food','Medium','Second Day','2025-04-13 17:18:34');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

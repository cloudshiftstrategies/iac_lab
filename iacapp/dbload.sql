-- MySQL dump 10.14  Distrib 5.5.56-MariaDB, for Linux (x86_64)
--
-- Host: myproject-dev-rds-cluster-20180219003306067700000003.cluster-chnznbpd9gvb.us-east-2.rds.amazonaws.com    Database: myprojectdevdb
-- ------------------------------------------------------
-- Server version	5.6.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `authors`
--

DROP TABLE IF EXISTS `authors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `birthdate` date NOT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authors`
--

LOCK TABLES `authors` WRITE;
/*!40000 ALTER TABLE `authors` DISABLE KEYS */;
INSERT INTO `authors` VALUES (1,'Jude','Mosciski','bmcclure@example.com','2007-07-19','2013-04-03 21:53:37'),(2,'Lizeth','Beer','otilia.hettinger@example.net','2004-10-14','2016-08-12 15:34:47'),(3,'Gregory','Kovacek','shakira80@example.org','1982-03-22','1986-07-18 20:07:10'),(4,'Dedrick','Green','declan.simonis@example.org','1997-01-28','1975-11-02 01:29:09'),(5,'Liliane','Pouros','ruecker.lisette@example.org','1989-08-03','1988-03-25 00:47:19'),(6,'Aubree','Kihn','ekuvalis@example.com','1975-08-19','1987-07-20 01:59:48'),(7,'Harley','Hettinger','fdenesik@example.com','1998-07-29','2007-10-09 16:05:15'),(8,'Leta','Morissette','gayle05@example.com','1985-04-07','1987-10-01 13:56:34'),(9,'Jailyn','Terry','whermann@example.org','2013-02-25','1979-12-29 01:03:16'),(10,'Rhoda','Kemmer','sophie00@example.org','1999-10-31','1977-12-03 20:44:55'),(11,'Delaney','Robel','eleazar55@example.net','1973-03-18','2012-12-26 08:06:31'),(12,'Porter','Orn','sidney.hills@example.com','2003-06-28','1998-05-27 22:22:55'),(13,'Raymond','Abshire','howe.carolyne@example.com','1974-02-26','1971-05-17 10:40:39'),(14,'Antwon','Murray','rosemarie09@example.org','1991-11-26','2012-02-12 22:31:08'),(15,'Laisha','Olson','tess63@example.org','1970-02-01','1979-12-12 23:12:19'),(16,'Julie','Terry','destini.hilll@example.net','1977-10-11','1997-07-10 03:32:02'),(17,'Bradly','Beahan','fae86@example.com','1974-09-08','1983-10-12 09:02:43'),(18,'Amely','Ledner','fadel.jodie@example.org','1993-02-19','1979-01-09 00:20:26'),(19,'Katelynn','Dietrich','kchamplin@example.com','2007-12-28','2011-03-06 05:43:40'),(20,'Jerry','Hand','ehoeger@example.com','1978-04-08','1995-04-13 23:12:46');
/*!40000 ALTER TABLE `authors` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-02-19  2:58:11

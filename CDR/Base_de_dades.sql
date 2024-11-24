-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 192.168.1.1    Database: pbe
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `marks`
--

DROP TABLE IF EXISTS `marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `marks` (
  `id_marks` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(45) NOT NULL,
  `Subject` varchar(45) DEFAULT NULL,
  `Name` varchar(45) DEFAULT NULL,
  `Marks` float DEFAULT NULL,
  PRIMARY KEY (`id_marks`),
  KEY `idx_student_id` (`student_id`) /*!80000 INVISIBLE */,
  CONSTRAINT `student_id_marks` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `marks`
--

LOCK TABLES `marks` WRITE;
/*!40000 ALTER TABLE `marks` DISABLE KEYS */;
INSERT INTO `marks` VALUES (1,'060FFBB0','PBE','Puzzle1',8.5),(2,'060FFBB0','PBE','Puzzle2',7.85),(3,'060FFBB0','PBE','CDR',9.1),(4,'060FFBB0','PBE','Lab1',6.95),(5,'060FFBB0','PBE','Final',8.75),(6,'060FFBB0','DSBM','Parcial',8.2),(7,'060FFBB0','DSBM','Lab',9.05),(8,'060FFBB0','DSBM','Final',7.9),(9,'060FFBB0','PSAVC','Parcial',8.7),(10,'060FFBB0','PSAVC','Lab',9.15),(11,'060FFBB0','PSAVC','Final',7.75),(12,'060FFBB0','TD','Parcial',7.95),(13,'060FFBB0','TD','Lab',8.3),(14,'060FFBB0','TD','Final',9),(15,'060FFBB0','EM','Parcial',8.1),(16,'060FFBB0','EM','Lab',7.75),(17,'060FFBB0','EM','Final',7.6),(18,'13B67606','PBE','Puzzle1',9.2),(19,'13B67606','PBE','Puzzle2',8.3),(20,'13B67606','PBE','CDR',7.85),(21,'13B67606','PBE','Lab1',8.6),(22,'13B67606','PBE','Final',9.1),(23,'13B67606','DSBM','Parcial',8.5),(24,'13B67606','DSBM','Lab',9),(25,'13B67606','DSBM','Final',7.95),(26,'13B67606','TD','Parcial',8.1),(27,'13B67606','TD','Lab',7.85),(28,'13B67606','TD','Final',8.9),(29,'13B67606','ICOM','Parcial',7.75),(30,'13B67606','ICOM','Lab',8.4),(31,'13B67606','ICOM','Final',9),(32,'13B67606','IPAV','Parcial',8.85),(33,'13B67606','IPAV','Lab',9.1),(34,'13B67606','IPAV','Final',8.35),(35,'B46BE9D0','PBE','Puzzle1',8.45),(36,'B46BE9D0','PBE','Puzzle2',7.3),(37,'B46BE9D0','PBE','CDR',9.2),(38,'B46BE9D0','PBE','Lab1',6.85),(39,'B46BE9D0','PBE','Final',8.1),(40,'B46BE9D0','DSBM','Parcial',9.15),(41,'B46BE9D0','DSBM','Lab',8.7),(42,'B46BE9D0','DSBM','Final',7.5),(43,'B46BE9D0','TD','Parcial',8.25),(44,'B46BE9D0','TD','Lab',7.95),(45,'B46BE9D0','TD','Final',8.4),(46,'B46BE9D0','RP','Parcial',7.65),(47,'B46BE9D0','RP','Lab',8.8),(48,'B46BE9D0','RP','Final',6.9),(49,'B46BE9D0','PSAVC','Parcial',9.3),(50,'B46BE9D0','PSAVC','Lab',8.15),(51,'B46BE9D0','PSAVC','Final',7.85),(52,'1409DBD0','PBE','Puzzle1',7.85),(53,'1409DBD0','PBE','Puzzle2',8.4),(54,'1409DBD0','PBE','CDR',9.05),(55,'1409DBD0','PBE','Lab1',6.95),(56,'1409DBD0','PBE','Final',8.6),(57,'1409DBD0','DSBM','Parcial',8.75),(58,'1409DBD0','DSBM','Lab',7.8),(59,'1409DBD0','DSBM','Final',9),(60,'1409DBD0','TD','Parcial',7.5),(61,'1409DBD0','TD','Lab',8.1),(62,'1409DBD0','TD','Final',8.9),(63,'1409DBD0','RP','Parcial',6.95),(64,'1409DBD0','RP','Lab',9.1),(65,'1409DBD0','RP','Final',7.4),(66,'1409DBD0','PSAVC','Parcial',8.9),(67,'1409DBD0','PSAVC','Lab',7.6),(68,'1409DBD0','PSAVC','Final',9.15),(69,'F632A914','ONELE','Parcial',8.25),(70,'F632A914','ONELE','Lab',7.8),(71,'F632A914','ONELE','Final',9.1),(72,'F632A914','ICOM','Parcial',6.9),(73,'F632A914','ICOM','Lab',8.75),(74,'F632A914','ICOM','Final',7.65),(75,'F632A914','DSBM','Parcial',9),(76,'F632A914','DSBM','Lab',8.45),(77,'F632A914','DSBM','Final',7.8),(78,'F632A914','RP','Parcial',7.2),(79,'F632A914','RP','Lab',8.9),(80,'F632A914','RP','Final',6.85),(81,'F632A914','PBE','Puzzle1',9.1),(82,'F632A914','PBE','Puzzle2',7.75),(83,'F632A914','PBE','CDR',8.4),(84,'F632A914','PBE','Lab1',6.95),(85,'F632A914','PBE','Final',7.6);
/*!40000 ALTER TABLE `marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `name` varchar(45) NOT NULL,
  `student_id` varchar(45) NOT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `student_id_UNIQUE` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES ('Ivan Cedo Marco','060FFBB0'),('Oscar Parada Fernandez','13B67606'),('Vanessa Sellart Merida','1409DBD0'),('Silvia Ruano Ferrer','B46BE9D0'),('Vicenc Parera Munoz','F632A914');
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `id_tasks` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(45) NOT NULL,
  `date` date DEFAULT NULL,
  `subject` varchar(45) NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id_tasks`),
  KEY `idxm_student_id` (`student_id`),
  CONSTRAINT `fk_tasks_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'060FFBB0','2024-12-03','PBE','Critical Design Review'),(2,'060FFBB0','2024-11-29','DSBM','Estudi Previ 4'),(3,'060FFBB0','2024-12-11','PBE','Final Report'),(4,'060FFBB0','2024-12-02','DSBM','Practica 4'),(5,'13B67606','2024-12-03','PBE','Critical Design Review'),(6,'13B67606','2024-11-29','DSBM','Estudi Previ 4'),(7,'13B67606','2024-12-11','PBE','Final Report'),(8,'13B67606','2024-12-02','DSBM','Practica 4'),(9,'B46BE9D0','2024-12-03','PBE','Critical Design Review'),(10,'B46BE9D0','2024-11-29','DSBM','Estudi Previ 4'),(11,'B46BE9D0','2024-12-11','PBE','Final Report'),(12,'B46BE9D0','2024-12-02','DSBM','Practica 4'),(13,'B46BE9D0','2024-12-05','RP','Practica 5'),(14,'1409DBD0','2024-12-03','PBE','Critical Design Review'),(15,'1409DBD0','2024-11-29','DSBM','Estudi Previ 4'),(16,'1409DBD0','2024-12-11','PBE','Final Report'),(17,'1409DBD0','2024-12-02','DSBM','Practica 4'),(18,'1409DBD0','2024-12-05','RP','Practica 5'),(19,'F632A914','2024-12-03','PBE','Critical Design Review'),(20,'F632A914','2024-11-29','DSBM','Estudi Previ 4'),(21,'F632A914','2024-12-11','PBE','Final Report'),(22,'F632A914','2024-12-02','DSBM','Practica 4');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `timetables`
--

DROP TABLE IF EXISTS `timetables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `timetables` (
  `id_timetable` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(45) NOT NULL,
  `day` varchar(45) DEFAULT NULL,
  `hour` time DEFAULT NULL,
  `Subject` varchar(45) DEFAULT NULL,
  `Room` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_timetable`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `student_id` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=266 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timetables`
--

LOCK TABLES `timetables` WRITE;
/*!40000 ALTER TABLE `timetables` DISABLE KEYS */;
INSERT INTO `timetables` VALUES (206,'060FFBB0','Mon','14:00:00','EM','A3002'),(207,'060FFBB0','Mon','16:00:00','TD','A4105'),(208,'060FFBB0','Mon','18:00:00','PIE','A3002'),(209,'060FFBB0','Tue','14:00:00','DSBM','A4105'),(210,'060FFBB0','Tue','15:00:00','EM','A3002'),(211,'060FFBB0','Tue','16:00:00','PSAVC','A4105'),(212,'060FFBB0','Wed','08:00:00','LAB PBE','A4105'),(213,'060FFBB0','Wed','16:00:00','PIE','A3002'),(214,'060FFBB0','Thu','08:00:00','PBE','A4105'),(215,'060FFBB0','Thu','14:00:00','TD','A4105'),(216,'060FFBB0','Fri','12:00:00','PIE','A3002'),(217,'060FFBB0','Fri','14:00:00','DSBM','A4105'),(218,'060FFBB0','Fri','16:00:00','PSAVC','A4105'),(219,'060FFBB0','Fri','18:00:00','LAB DSBM','C5S101A'),(220,'13B67606','Mon','11:00:00','LAB IPAV','D4005'),(221,'13B67606','Mon','16:00:00','TD','A4105'),(222,'13B67606','Tue','08:00:00','IPAV','A2002'),(223,'13B67606','Tue','12:00:00','ICOM','A2002'),(224,'13B67606','Tue','14:00:00','DSBM','A4105'),(225,'13B67606','Wed','08:00:00','LAB PBE','A4105'),(226,'13B67606','Thu','08:00:00','PBE','A4105'),(227,'13B67606','Thu','10:00:00','ICOM','A2002'),(228,'13B67606','Thu','14:00:00','TD','A4105'),(229,'13B67606','Fri','08:00:00','LAB ICOM','D4001'),(230,'13B67606','Fri','12:00:00','IPAV','A2002'),(231,'13B67606','Fri','14:00:00','DSBM','A4105'),(232,'13B67606','Fri','18:00:00','LAB DSBM','C5S101A'),(233,'1409DBD0','Mon','08:00:00','LAB DSBM','C5S101A'),(234,'1409DBD0','Mon','10:00:00','RP','A4105'),(235,'1409DBD0','Mon','12:00:00','DSBM','A4105'),(236,'1409DBD0','Tue','08:00:00','PSAVC','A4105'),(237,'1409DBD0','Tue','11:00:00','TD','A4105'),(238,'1409DBD0','Wed','08:00:00','LAB PBE','A4105'),(239,'1409DBD0','Thu','08:00:00','PBE','A4105'),(240,'1409DBD0','Thu','10:00:00','RP','A4105'),(241,'1409DBD0','Thu','12:00:00','LAB RP','D3006'),(242,'1409DBD0','Fri','08:00:00','DSBM','A4105'),(243,'1409DBD0','Fri','10:00:00','PSAVC','A4105'),(244,'1409DBD0','Fri','12:00:00','TD','A4105'),(245,'B46BE9D0','Mon','08:00:00','LAB DSBM','C5S101A'),(246,'B46BE9D0','Mon','10:00:00','RP','A4105'),(247,'B46BE9D0','Mon','12:00:00','DSBM','A4105'),(248,'B46BE9D0','Tue','08:00:00','PSAVC','A4105'),(249,'B46BE9D0','Tue','11:00:00','TD','A4105'),(250,'B46BE9D0','Wed','08:00:00','LAB PBE','A4105'),(251,'B46BE9D0','Thu','08:00:00','PBE','A4105'),(252,'B46BE9D0','Thu','10:00:00','RP','A4105'),(253,'B46BE9D0','Thu','12:00:00','LAB RP','D3006'),(254,'B46BE9D0','Fri','08:00:00','DSBM','A4105'),(255,'B46BE9D0','Fri','10:00:00','PSAVC','A4105'),(256,'B46BE9D0','Fri','12:00:00','TD','A4105'),(257,'F632A914','Tue','10:00:00','ONELE','A2002'),(258,'F632A914','Tue','12:00:00','ICOM','A2002'),(259,'F632A914','Tue','14:00:00','DSBM','A4105'),(260,'F632A914','Wed','08:00:00','LAB PBE','A4105'),(261,'F632A914','Thu','08:00:00','PBE','A4105'),(262,'F632A914','Thu','10:00:00','ICOM','A2002'),(263,'F632A914','Thu','12:00:00','ONELE','A2002'),(264,'F632A914','Fri','14:00:00','DSBM','A4105'),(265,'F632A914','Fri','18:00:00','LAB DSBM','C5S101A');
/*!40000 ALTER TABLE `timetables` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-24 19:23:05

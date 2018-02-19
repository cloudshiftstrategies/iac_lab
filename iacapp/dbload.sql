DROP TABLE IF EXISTS 'authors';
CREATE TABLE `authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `birthdate` date NOT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
);
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (1, 'Jude', 'Mosciski', 'bmcclure@example.com', '2007-07-19', '2013-04-03 21:53:37');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (2, 'Lizeth', 'Beer', 'otilia.hettinger@example.net', '2004-10-14', '2016-08-12 15:34:47');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (3, 'Gregory', 'Kovacek', 'shakira80@example.org', '1982-03-22', '1986-07-18 20:07:10');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (4, 'Dedrick', 'Green', 'declan.simonis@example.org', '1997-01-28', '1975-11-02 01:29:09');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (5, 'Liliane', 'Pouros', 'ruecker.lisette@example.org', '1989-08-03', '1988-03-25 00:47:19');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (6, 'Aubree', 'Kihn', 'ekuvalis@example.com', '1975-08-19', '1987-07-20 01:59:48');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (7, 'Harley', 'Hettinger', 'fdenesik@example.com', '1998-07-29', '2007-10-09 16:05:15');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (8, 'Leta', 'Morissette', 'gayle05@example.com', '1985-04-07', '1987-10-01 13:56:34');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (9, 'Jailyn', 'Terry', 'whermann@example.org', '2013-02-25', '1979-12-29 01:03:16');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (10, 'Rhoda', 'Kemmer', 'sophie00@example.org', '1999-10-31', '1977-12-03 20:44:55');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (11, 'Delaney', 'Robel', 'eleazar55@example.net', '1973-03-18', '2012-12-26 08:06:31');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (12, 'Porter', 'Orn', 'sidney.hills@example.com', '2003-06-28', '1998-05-27 22:22:55');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (13, 'Raymond', 'Abshire', 'howe.carolyne@example.com', '1974-02-26', '1971-05-17 10:40:39');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (14, 'Antwon', 'Murray', 'rosemarie09@example.org', '1991-11-26', '2012-02-12 22:31:08');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (15, 'Laisha', 'Olson', 'tess63@example.org', '1970-02-01', '1979-12-12 23:12:19');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (16, 'Julie', 'Terry', 'destini.hilll@example.net', '1977-10-11', '1997-07-10 03:32:02');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (17, 'Bradly', 'Beahan', 'fae86@example.com', '1974-09-08', '1983-10-12 09:02:43');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (18, 'Amely', 'Ledner', 'fadel.jodie@example.org', '1993-02-19', '1979-01-09 00:20:26');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (19, 'Katelynn', 'Dietrich', 'kchamplin@example.com', '2007-12-28', '2011-03-06 05:43:40');
INSERT INTO authors (`id`, `first_name`, `last_name`, `email`, `birthdate`, `added`) VALUES (20, 'Jerry', 'Hand', 'ehoeger@example.com', '1978-04-08', '1995-04-13 23:12:46');

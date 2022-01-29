CREATE TABLE `kibra_society` (
  `id` int(11) NOT NULL,
  `items` varchar(255) NOT NULL,
  `weapons` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `kibra_society` (`id`, `items`, `weapons`) VALUES
(1, '[{\"Count\":4,\"Item\":\"water\"}]', '[{\"Count\":44,\"Item\":\"WEAPON_PISTOL\"}]');
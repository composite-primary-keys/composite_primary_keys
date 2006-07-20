CREATE TABLE `reference_types` (
  `reference_type_id` int(11) NOT NULL auto_increment,
  `type_label` varchar(50) default NULL,
  `abbreviation` varchar(50) default NULL,
  `description` varchar(50) default NULL,
  PRIMARY KEY  (`reference_type_id`)
) TYPE=InnoDB;

CREATE TABLE `reference_codes` (
  `reference_type_id` int(11) NOT NULL,
  `reference_code` int(11) NOT NULL,
  `code_label` varchar(50) default NULL,
  `abbreviation` varchar(50) default NULL,
  `description` varchar(50) default NULL,
  PRIMARY KEY  (`reference_type_id`,`reference_code`)
) TYPE=InnoDB;

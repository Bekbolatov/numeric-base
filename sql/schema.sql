use starpractice;

drop table activity;
create table activity (
id varchar(50) not null,
name varchar(50) not null,
short_description varchar(100) not null,
description varchar(200) not null,
author_name varchar(50) not null,
author_email varchar(50) not null,
author_date date not null,
version int not null,
PRIMARY KEY  (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

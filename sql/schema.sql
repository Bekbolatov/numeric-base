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

drop table if exists channel;
create table channel (
id int not null,
name varchar(50) not null,
create_date date not null,
PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- activities in an channel
drop table if exists channel_activity;
create table channel_activity (
channel_id int not null,
activity_id varchar(50) not null,
PRIMARY KEY (channel_id, activity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists end_user_profile;
create table end_user_profile (
id varchar(50) not null,
name varchar(50) not null,
create_date date not null,
PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists end_user_alias;
create table end_user_alias (
id varchar(50) not null,
end_user_profile_id varchar(50) not null,
PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- channels for end_user.group_id
drop table if exists end_user_channel;
create table end_user_channel (
end_user_profile_id varchar(50) not null,
channel_id int not null,
PRIMARY KEY (end_user_profile_id, channel_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

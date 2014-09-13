create database starpractice;

grant all on starpractice.* to 'star'@'%' identified by 'hello123' with grant option;
grant all on starpractice.* to 'star'@'localhost' identified by 'hello123' with grant option;

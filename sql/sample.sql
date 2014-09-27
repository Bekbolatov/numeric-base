use starpractice;

insert into activity (id, name, short_description, description, author_name, author_email, author_date, version) values
("com.sparkydots.numeric.tasks.t.basic_math", "Arithmetic Practice", "Practice addition, subtraction, etc", "Practice adding, subtracting, multiplying, dividing numbers", "Sparky Dots", "info@sparkydots.com", "2014-08-01", 1),
("com.sparkydots.numeric.tasks.t.multiple_choice", "Odd One Out", "Guess which item doesn't fit in the list with other items.", "Given a list of several items, guess which item doesn't fit in the list with other items.", "Sparky Dots", "info@sparkydots.com", "2014-08-01", 1),
("com.sparkydots.numeric.tasks.ssat.c.q00", "Elementary Math Problems", "Typical problems in elementary Math tests.", "In this practice set student can work on the the typical Math problems at the elementary level.", "Sparky Dots", "info@sparkydots.com", "2014-09-10", 1);


insert into channel (id, name, create_date) values
(0, "Default Public Channel", "2014-09-01");



-- select *
-- from activity a
-- left join activity_list_activity ala on (ala.activity_id = a.id)
-- left join activity_list al on (al.id = ala.activity_list_id);


--


-- All activities in activity list 0
select a.* from activity a left join activity_list_activity ala on (ala.activity_id = a.id and ala.activity_list_id = 0) where ala.activity_id is not null;




insert into activity (id, name, short_description, description, author_name, author_email, author_date, version) values
("test1", "Arithmetic Practice", "Practice addition, subtraction, etc", "Practice adding, subtracting, multiplying, dividing numbers", "Sparky Dots", "info@sparkydots.com", "2014-08-01", 1),
("test2", "Odd One Out", "Guess which item doesn't fit in the list with other items.", "Given a list of several items, guess which item doesn't fit in the list with other items.", "Sparky Dots", "info@sparkydots.com", "2014-08-01", 1),
("test3", "Elementary Math Problems", "Typical problems in elementary Math tests.", "In this practice set student can work on the the typical Math problems at the elementary level.", "Sparky Dots", "info@sparkydots.com", "2014-09-10", 1);


1bca492c9b197fa9a13c0b0b81222ba0
5e0536e3ee5c56d03541fd56f4f75eb6

744e9812a44ce67287b38dca22a69901

insert into end_user_permissions (end_user_profile_id, resource_type, resource_id, permission) values
("744e9812a44ce67287b38dca22a69901", "root", "1", 7);
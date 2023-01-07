-- Lesson # 8 Dimention vs Fact Tables

-- ---------------------- Homework from Lesson #7 ----------------------
-- Answers - Data Cleaning Project - English Dicionary
-- 1-3
create database Dictionary;
-- 4.Show counts of both tables
select count(*) from dictionary.english_dictionary_master -- 309,246
select count(*) from dictionary.english_dictionary_most_common_words -- 4,341

select * from dictionary.english_dictionary_master 
limit 25;

select * from dictionary.english_dictionary_most_common_words
limit 25;

-- 5.Create copies of both tables just in case you accidentally delete the originals
create table dictionary.english_dictionary_master_copy 
as select * from dictionary.english_dictionary_master; 

create table dictionary.english_dictionary_most_common_words_copy
as select * from dictionary.english_dictionary_most_common_words; 

-- 6.Rename column type to word_type and definition to word_def
alter table dictionary.english_dictionary_master rename column type to word_type;
alter table dictionary.english_dictionary_master rename column definition to word_def;

-- 7.Update column word_type and word_def to remove " and .
update table  dictionary.english_dictionary_master set word_type = replace(word_type, '"','');
update table  dictionary.english_dictionary_master set word_type = replace(word_type, '.','');
update dictionary.english_dictionary_master set word_def = replace(word_def, '"','');

-- 8.Add column is_common to master table and update this column with 'yes' for common words 
alter table dictionary.english_dictionary_master add column is_common varchar (6);

update dictionary.english_dictionary_master
set is_common ='yes'
where word in
(select distinct common_words from dictionary.english_dictionary_most_common_words);

 select * from dictionary.english_dictionary_master
 limit 25;

-- 9.Using trim functon get rid off extra spaces in all columns in dictionary.english_dictionary_master
create table dictionary.english_dictionary_master2 as
select trim(a.Word) as word, trim(a.word_type) as word_type, 
trim(a.Length) as length, trim(a.word_def) as word_def,
case when trim(a.word) = trim(b.common_words) then 'yes' else null end is_common
from dictionary.english_dictionary_master a
left join (select distinct trim(common_words) as common_words
from dictionary.english_dictionary_most_common_words) b
on trim(a.word) = trim(b.common_words);

drop table dictionary.english_dictionary_master;
rename table dictionary.english_dictionary_master2 to dictionary.english_dictionary_master;

-- insert auto increment Word ID
create table dictionary.english_dictionary_master2 
(WordID int (6) auto_increment,
word	varchar (100),			
word_type	varchar (50),		
length	varchar(11)	,	
word_def	varchar (1000),		
is_common	varchar(3),			
PRIMARY KEY (WordID)); 

insert into dictionary.english_dictionary_master2 (word,word_type,length,word_def,is_common)
(select * from dictionary.english_dictionary_master);

drop table dictionary.english_dictionary_master;
rename table dictionary.english_dictionary_master2 to dictionary.english_dictionary_master;
drop table dictionary.english_dictionary_master2;

-- 10. Queries
-- how many distinct common/uncommon words are in the table?
select is_common, count(distinct word) cnt_distinct_words, count(*) cnt_all_words
from dictionary.english_dictionary_master
group by is_common;

-- how many distinct word_types are in the table?
select word_type, count(distinct word) cnt_distinct_words, count(*) cnt_all_words
from dictionary.english_dictionary_master
group by word_type
order by count(*) desc;

-- find all english words for different colors (e.g. bronze, ruby, white, pink, red, azure, blue, etc.)
select word, word_type, word_def
from dictionary.english_dictionary_master 
where word_def like '%color%' and word_type = 'a';

-- randomly select 4 nouns and ajectives
select  -- select count(*) 
word, word_type, word_def -- , RAND(word) as word_rand  -- select *
from dictionary.english_dictionary_master -- where word_def like '%color%' and word_type = 'a'
where is_common = 'yes' and word_type in ('n', 'a')
order by rand()
limit 4;

-- create separtate columns for each letter in the word
select  -- select count(*) 
word, substr(word,1,1) as letter1, substr(word,2,1) letter2, 
substr(word,3,1) letter3, substr(word,4,1) letter4,
substr(word,5,1) letter5, substr(word,6,1) letter6, substr(word,7,1) letter7
-- , word_type, word_def -- , RAND(word) as word_rand  -- select *
from dictionary.english_dictionary_master -- where word_def like '%color%' and word_type = 'a'
where is_common = 'yes' and length(word) = 7 -- word_type in ('n', 'a') and substr(word,1,1)=substr(word,3,1)
order by rand();




 
-- -------------------------Lesson8 Data Warehouse - Dimention vs Fact tables ----------

/* -- What is Data Warehouse? 
https://www.guru99.com/data-warehousing-tutorial.html
A Data Warehousing (DW) is process for collecting and managing data from varied sources 
to provide meaningful business insights.
It is electronic storage of a large amount of information by a business which is designed for query 
and analysis instead of transaction processing.
data warehouses prioritize SQL databases and are generally incompatible with NoSQL databases
*/

/*Difference between Database and Data Warehouse
Parameter				Database											Data Warehouse

Purpose					Is designed to record								Is designed to analyze
Processing Method		Uses the Online Transactional Processing (OLTP)		Uses Online Analytical Processing (OLAP).
Usage					Helps to perform fundamental business operations 	Allows you to analyze your business.
Tables and Joins		Are complex as they are normalized					Are simple because they are denormalized.
Orientation				Is an application-oriented collection of data		It is a subject-oriented collection of data
Storage limit			Generally limited to a single application			Stores data from any number of applications
Availability			Data is available real-time							Data is refreshed from source systems as and when needed
Technique				Capture data										Analyze data
Data Type				Data stored in the Database is up to date.			Current and Historical Data is stored in Data Warehouse. May not be up to date.
Storage of data			Uses Flat Relational Approach method 				Uses dimensional and normalized approach for the data structure. Example: Star and snowflake schema.
Query Type				Simple transaction queries are used.				Complex queries are used for analysis purpose.
Data Summary			Detailed Data is stored in a database.				It stores highly summarized data.
*/

/* Extract, Transform and Load (ETL) Tools
Eliminating unwanted data in operational databases from loading into Data Warehouse.
Search and replace common names and definitions for data arriving from different sources.
Calculating summaries and derived data
In case of missing data, populate them with defaults.
De-duplicated repeated data arriving from multiple datasources.
These Extract, Transform, and Load tools may generate cron jobs, background jobs, Cobol programs, shell scripts, etc.
that regularly update data in datawarehouse.
*/

/*-- Data Marts
A data mart is an access layer which is used to get data out to the users. 
Data marts could be created in the same database as the Datawarehouse or a physically separate Database.
*/

/*-- What is Business Intelligence?
BI(Business Intelligence) is a set of processes, architectures, and technologies that convert raw data into 
meaningful information that drives profitable business actions. 
BI tools perform data analysis and create reports, summaries, dashboards, maps, graphs, and charts 
to provide users with detailed intelligence about the nature of the business.
BI technology can be used by Data Analysts, IT people, Business Users and Head of the Company.
*/

/*-- Types of Data Warehouse Schema:
Following are 3 chief types of multidimensional schemas each having its unique advantages.
1. Star Schema
2. Snowflake Schema
3. Galaxy Schema  (multiple fact tables share the same dimention tables)

-- Star Schema vs. Snowflake Schema (see pictures)
https://www.guru99.com/star-snowflake-data-warehousing.html
In Data Warehouse Modeling, a star schema and a snowflake schema 
consists of Fact and Dimension tables.
-- dimention (PK) vs fact (FK)

Fact Table - contains all foreign keys and is in the middle of the star surrounded by dimention tables.
Dimension Table - contains a primary key, provides descriptive information 
*/

-- Let's create your a relational db (star schema)
-- dimention
DROP DATABASE IF EXISTS family;
CREATE DATABASE IF NOT EXISTS family;

 -- dimension
CREATE TABLE family.members (
family_id INT (10) NOT NULL,
family_name VARCHAR(15) DEFAULT NULL,
gender VARCHAR(9) DEFAULT NULL,
birthdate DATE,
 PRIMARY KEY (family_id));
 
 -- dimension
 DROP TABLE IF EXISTS family.activity;
 CREATE TABLE family.activity (
activity_id INT (10) NOT NULL,
activity_name VARCHAR(15) DEFAULT NULL,
activity_description VARCHAR(9) DEFAULT NULL,
 PRIMARY KEY (activity_id));
 
 -- fact
 DROP TABLE IF EXISTS  family.schedule;
 CREATE TABLE family.schedule (
activity_date date,
family_id  INT (10) NOT NULL,
activity_id INT (10) NOT NULL
);

-- add foreign key
ALTER TABLE family.schedule
ADD FOREIGN KEY fk_fam(family_id)
REFERENCES members(family_id)
ON DELETE NO ACTION
ON UPDATE CASCADE;

ALTER TABLE family.schedule
ADD FOREIGN KEY fk_act(family_id)
REFERENCES activity(activity_id)
ON DELETE NO ACTION
ON UPDATE CASCADE;

insert into family.members
values
 (1,'Joshua', 'M', '2000-06-13'), 
 (2,'Andrew', 'M', '2003-06-14'),
 (3,'Kevin', 'M', '2005-08-28'),
 (4,'Anthony', 'M', '2013-11-05'); 
 
 insert into family.activity
values
 (1,'Gymnastics', ''), 
 (2,'Piano', ''),
 (3,'Guitar', ''),
 (4,'Art',''),
 (5,'Fencing',''),
 (6,'Chess',''); 
 
insert into family.schedule
values
 ('2022-10-17',2,1), 
 ('2022-10-18',3,5),
 ('2022-10-19',2,1),
 ('2022-10-20',3,2),
 ('2022-10-21',3,3);
 
 -- dim
 select * from family.members; -- 4
 -- dim
 select * from family.activity; -- 6
 -- fact
 select * from family.schedule; -- 5
 
-- join all tables together
 select *, 
  case when dayofweek(activity_date) = 1 then 'Sunday'
   when dayofweek(activity_date) = 2 then 'Monday'
   when dayofweek(activity_date) = 3 then 'Tuesday'
   when dayofweek(activity_date) = 4 then 'Wednesday'
   when dayofweek(activity_date) = 5 then 'Thursday'
   when dayofweek(activity_date) = 6 then 'Friday'
   when dayofweek(activity_date) = 7 then 'Sunday' else null end dayofweek
 from family.members m
 join  family.schedule s on m.family_id = s.family_id
 join family.activity a on  s.activity_id = a.activity_id; 
 
-- index
CREATE INDEX fn1 ON family.members (family_name);
-- drop index fn1 on family.members ;
show index from family.members ;

-- Create your own family database and think of new dimention tables


-- -------------------------------------------------------
-- Homework #8
-- Part1 world.sql
-- download 'world database' https://dev.mysql.com/doc/index-other.html
-- unzip, open and run sql script world.sql
-- create EER diagram and write queries
-- 1. show distinct continent, region, country
-- 2. what languages are spoken in Sydney?
-- 3. show governmentForm and number of countries (desc order)
-- 4. rank country by population (desc order)
-- 5. which country has the bigest number of languages?
-- 6. which country has the lowest LifeExpectancy
-- 7. if a country has English as one of the languages, it is an 'English Speaking' country, if not 'Non English Speaking'
-- Therefore create 'English_Language' field using CASE statement. You can also show Percentage of the language spoken 


 -- Homework #8 
 /*-- Part2 jeopardy database
create database jeopardy;
 right click of database jeopardy and download jason or csv file (both have issues) from 
 https://www.reddit.com/r/datasets/comments/1uyd0t/200000_jeopardy_questions_in_a_json_file/
*/
-- find top 5 categories
-- find a question about Shakespere
-- how many distinct show numbers?
-- what is the most common answer?
-- how many questions per each value?
-- which category has the most quesions?
-- how many questions each year?
-- show number of questions for each value in each round
-- how many questions are null?
-- how many questions have no answers?
-- how many distinct rounds in each show?
 
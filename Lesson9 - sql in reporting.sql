-- Lesson 9 - SQL and Data Visualization

-- ---------------------- HOMEWORK #8 ----------------------
-- Part1 world database answers
/* world.sql
-- download 'world database' here: https://dev.mysql.com/doc/index-other.html
-- create EER diagram and write sql where you join all tables together
*/
select * from world.city; 
select * from world.country; 
select * from world.countrylanguage; 

select count(*) from world.city; -- 4079
select count(*) from world.country; -- 239
select count(*) from world.countrylanguage; -- 984

 
-- 1 show distinct continent, region, country
select distinct continent, region, `name` from world.country;

-- 2 what languages are spoken in Sydney?
select city.name as name_city, lang.language 
from  world.city city  
join world.countrylanguage lang on city.CountryCode = lang.CountryCode
 where city.name = 'Sydney';

-- 3 show governmentForm and number of countries (desc order)
select governmentForm, count(*) as company_cnt 
from world.country
group by governmentForm
order by company_cnt desc;

-- 4 rank country by population (desc order)
select name, Population, 
RANK() OVER (ORDER BY Population DESC) as `rank`  
from world.country;

-- 5 which country has the bigest number of languages?
 select cntr.name as country_name, count(distinct language) language_cnt 
 from world.country cntr
join world.countrylanguage lang on cntr.Code = lang.CountryCode
group by cntr.name
order by language_cnt desc
limit 10;

-- 6 which country has the lowest LifeExpectancy
select continent, `name` , LifeExpectancy
from world.country
where LifeExpectancy is not null
order by LifeExpectancy
limit 1;

-- 7 if a country has English as one of the languages, it is an 'English Speaking' country, if not 'Non English Speaking'
-- Therefore create 'English_Language' field using CASE statement. You can also show Percentage of the language spoken 
 select b.Name as Country,
 case when max(a.English_or_not) = 1 then 'English Speaking' else 'Non English Speaking' end as English,
 max(a.English_percentage)English_percentage
 from (
 select l.*, 
 case when Language = 'English' then 1 else 0 end English_or_not,
 case when Language = 'English' then Percentage else 0 end as English_percentage
 from world.countrylanguage l)a
 join world.country b on a.countryCode = b.Code
 group by b.Name;

 
  -- what is the average life expectancy for countries with population < 1 million and > 1 million?
 select pop_mil, count(*) country_cnt,  sum(population) pop_sum, 
 avg(lifeexpectancy) as lifeexp_avg,
 format(avg(lifeexpectancy),2) as lifeexp_avg_formated
 from
 (select name, Continent, Population, LifeExpectancy,
 case when Population <1000000 then '<1mil' else  '>1mil' end pop_mil
 from world.country) as a
 group by pop_mil;

-- join all tables
-- 4079
select count(*)
from world.country as cntr 
join world.city as city on cntr.Code = city.CountryCode
join (select countrycode, count(language) language_cnt
from world.countrylanguage group by countrycode) as lang 
on cntr.Code = lang.CountryCode
-- where cntr.code = 'AFG';
 
-- Homework #8 
 -- Part2 jeopardy database
/*create database jeopardy;
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
-- Homework advanced
 -- https://www.reddit.com/r/datasets/comments/1uyd0t/200000_jeopardy_questions_in_a_json_file/
select * from jeopardy.jeopardy_questions; 
desc jeopardy.jeopardy_questions;
select count(*)from jeopardy.jeopardy_questions; -- 216,930

-- find top 5 categories
 select category, count(*) 
 from jeopardy.jeopardy_questions
 group by category
 order by count(*) desc
 limit 5;

-- find a question about Shakespere
select * from jeopardy.jeopardy_questions
where question like '%Shakespere%';

-- how many distinct show numbers?
select count(distinct show_number) from jeopardy.jeopardy_questions;

-- what are the 3 most common answers?
select answer, count(answer) as answer_cnt
from jeopardy.jeopardy_questions 
group by answer
order by count(answer) desc
limit 3;

-- how many questions per each value?
select value, count(question)
from jeopardy.jeopardy_questions
group by value
order by count(question) desc;

-- which category has the most quesions?
select category,  count(question)
from jeopardy.jeopardy_questions
group by category
order by count(question) desc
limit 1;

-- how many questions each year?
select case when year(air_date) is null then 'no data' else year(air_date) end as air_year,
count(*)
from jeopardy.jeopardy_questions
group by year(air_date)
order by  year(air_date);

-- show number of questions for each value in each round
select "value", round, count(*)
from jeopardy.jeopardy_questions
group by value, round
order by value desc;

-- how many questions are missing?
select count(*)
from jeopardy.jeopardy_questions
where question  ='';

-- how many questions have no answers?
select count(*)
from jeopardy.jeopardy_questions
where answer ='';

-- how many distinct rounds in each show?
select show_number, count(distinct round)
from jeopardy.jeopardy_questions
group by show_number;
-- --------------------- End of Homework  -------------








-- ------------------------------------------- Data Visualization ----------------------------------
-- 3 big Data Visualization players: Tableau, Looker, and Power BI

-- Tableau (bought by Salesforce in 2020 for 15.7 billion)
-- Free Tableau Desktop for High School and College Students (send grades) for one year https://www.tableau.com/academic/students
-- Free Tableau Desktop Trial (14 days) https://www.tableau.com/products/desktop/download
-- Free Tableau Public https://public.tableau.com/en-us/s/download

-- Looker (bought by Google for 2.6 billion) 
-- Free trial - https://looker.com/demo/free-trial

-- Microsoft Power BI (Microsoft)
-- Free trial - https://powerbi.microsoft.com/en-us/

-- Tableau vs. Power BI vs. Looker – Which tool is better for your Business? 
-- https://nineboards.com/tableau-vs-power-bi-vs-looker-which-tool-is-better-for-your-business/#:~:text=In%20short%2C%20Power%20BI%20is,build%20visualizations%20to%20gain%20insights.&text=Looker%20has%20a%20lot%20of,like%20collaborative%20data%20sharing%20etc.


-- Tableau Products
/*Tableau Desktop
Tableau Public
Tableau Prep
Tableau Reader
Tableau Server and Online
Tableau Viewer
Tableau Explorer
*/

-- Tableau Type Files
/* Workbooks (.twb) – Tableau workbook files have the .twb file extension. Workbooks hold one or more worksheets, 
plus zero or more dashboards and stories.

Packaged Workbooks (.twbx) – Tableau packaged workbooks have the .twbx file extension. 
A packaged workbook is a single zip file that contains a workbook along with any supporting local file data and 
background images. 
This format is the best way to package your work for sharing with others who don’t have access to the original data. 

Bookmarks (.tbm) – Tableau bookmark files have the .tbm file extension. 
Bookmarks contain a single worksheet and are an easy way to quickly share your work.

Extract (.hyper or .tde) – Depending on the version the extract was created in, 
Tableau extract files can have either the .hyper or .tde file extension. 
Extract files are a local copy of a subset or entire data set that you can use to share data with others, 
when you need to work offline, and improve performance. 

Data Source (.tds) – Tableau data source files have the .tds file extension. 
Data source files are shortcuts for quickly connecting to the original data that you use often. 
Data source files do not contain the actual data but rather the information necessary to connect 
to the actual data as well as any modifications you've made on top of the actual data such as changing default properties, 
creating calculated fields, adding groups, and so on.

Packaged Data Source (.tdsx) – Tableau packaged data source files have the .tdsx file extension. 
A packaged data source is a zip file that contains the data source file (.tds) described above as well as any local file 
data such as extract files (.hyper or .tde), text files, Excel files, Access files, and local cube files. 
Use this format to create a single file that you can then share with others who may not have access to the 
original data stored locally on your computer. For more information, see Save Data Sources.
*/


-- Custome Query classicmodels database - 2,996
SELECT 
c.addressLine1,
c.addressLine2,
amount,
buyPrice,
c.city,
comments,
contactFirstName,
c.country,
creditLimit,
c.customerName,
c.customerNumber,
email,
employeeNumber,
extension,
firstName,
jobTitle,
lastName,
MSRP,
e.officeCode,
orderDate,
orderLineNumber,
orders.orderNumber,
paymentDate,
c.phone,
c.postalCode,
priceEach,
pr.productCode,
productDescription,
pr.productLine,
productName,
productScale,
productVendor,
quantityInStock,
quantityOrdered,
reportsTo,
requiredDate,
salesRepEmployeeNumber,
shippedDate,
c.state,
status,
territory,
textDescription
FROM classicmodels.customers c
JOIN classicmodels.employees e ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN classicmodels.offices o ON e.officeCode = o.officeCode
JOIN (select customerNumber, max(paymentDate) as paymentDate, sum(amount) as amount 
from classicmodels.payments group by customerNumber) p ON c.customerNumber = p.customerNumber
JOIN classicmodels.orders orders ON c.customerNumber = orders.customerNumber
JOIN classicmodels.orderdetails det ON orders.orderNumber = det.orderNumber
JOIN classicmodels.products pr ON det.productCode = pr.productCode
JOIN classicmodels.productlines pl ON pr.productLine = pl.productLine

-- Homework #9
-- in Tableau finish all classicmodels queries Q1-Q24. Create dashboards
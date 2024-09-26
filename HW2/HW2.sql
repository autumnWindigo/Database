-- DATABASE:
-- chefs (chefID, name, specialty)
-- works (chefID, restID)
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- ***************************************
-- 1) Average price of foods at restaurants
--
-- NEEDED:
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- restID -> serves -> foodID
-- ***************************************
select r.name as rest_name, avg(f.price) as avg_price
from restaurants r
inner join serves s on r.restid = s.restid
inner join foods f on s.foodid = f.foodid
group by rest_name
;

-- ***************************************
-- 2) Maximum Food Price at Each Restaurant
--
-- NEEDED
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- restID -> serves -> foodID
-- ***************************************
select r.name as rest_name, max(f.price) as max_price
from restaurants r
inner join serves s on r.restid = s.restid
inner join foods f on f.foodid = s.foodid
group by r.name
;

-- ***************************************
-- 3) Count of Different Food Types Served at Each Restaurant
--
-- NEEDED:
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- restID -> serves -> foodID
-- Find unique food.type in restID
-- ***************************************
select r.name as rest_name, count(distinct f.type) as food_types
from restaurants r
inner join serves s on r.restid = s.restid
inner join foods f on f.foodid = s.foodid
group by r.name
;

-- ***************************************
-- 4) Average Price of Foods Served by Each Chef
--
-- NEEDED:
-- chefs (chefID, name, specialty)
-- works (chefID, restID)
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- chefs.specialty -> ChefID -> works ->
-- restID -> serves -> foodID -> food.type
-- chefs.specialty = food.type
-- ***************************************
select c.name as chef_name, avg(f.price) as avg_price
from chefs c
inner join works w on c.chefid = w.chefid
inner join restaurants r on w.restid = r.restid
inner join serves s on r.restid = s.restid
inner join foods f on s.foodid = f.foodid
where c.specialty = f.type
group by c.name
;

-- ***************************************
-- 5) Find the Restaurant with the Highest Average Food Price
--
-- NEEDED:
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- restID -> serves -> foodID
-- Order by price
-- Limit 1
--
-- Notes:
-- Same as prob 2, with order and limit
-- Don't need all with highest just _the_ singular highest
-- ***************************************
select r.name as rest_name, avg(f.price) as avg_price
from restaurants r
inner join serves s on r.restid = s.restid
inner join foods f on s.foodid = f.foodid
group by rest_name
order by avg_price desc
limit 1
;

-- ***************************************
-- 6) Determine which chef has the highest average price of the foods served
-- at the restaurants where they work. Include the chef’s name, the average
-- food price, and the names of the restaurants where the chef works.
-- Sort the results by the average food price in descending order.
--
-- NEEDED:
-- chefs (chefID, name, specialty)
-- works (chefID, restID)
-- restaurants (restID, name, location)
-- serves (restID, foodID, date_sold)
-- foods (foodID, name, type, price)
--
-- Constraint:
-- ChefID -> works ->
-- restID -> serves -> foodID
-- Notes:
-- Go from chef to food again
-- Get avg prices of foods at entire rest, not just by chef
-- We need to print name, avg_price, and ALL restaurants they work
-- ***************************************
select
    c.name as chef_name,
    avg(f.price) as avg_price,
    group_concat(distinct r.name) as rest_names
from chefs c
inner join works w on c.chefid = w.chefid
inner join restaurants r on w.restid = r.restid
inner join serves s on r.restid = s.restid
inner join foods f on s.foodid = f.foodid
group by chef_name
order by avg_price desc
;

/* 1) Problem Statement: Delete Duplicate Rows (Duplicate on the basis of Model & Brand),
   Provide at least 4 different ways to solve this. */

-- Create Table

CREATE TABLE cars
(
    id      INT,
    model   VARCHAR(50),
    brand   VARCHAR(40),
    color   VARCHAR(30),
    make    INT
);

-- Insert Data

INSERT INTO cars VALUES (1, 'Brezza', 'Maruti', 'Blue', 2018);
INSERT INTO cars VALUES (2, 'Seltos', 'Kia', 'Black', 2022);
INSERT INTO cars VALUES (3, 'Fortuner', 'Toyota', 'Red', 2022);
INSERT INTO cars VALUES (4, 'Aura', 'Hyundai', 'White', 2021);
INSERT INTO cars VALUES (5, 'Brezza', 'Maruti', 'Silver', 2018);
INSERT INTO cars VALUES (6, 'Aura', 'Hyundai', 'Green', 2021); 

-- Test Data

SELECT * FROM cars;

-- Solution I

DELETE FROM cars
WHERE id IN 
		(SELECT MAX(id)
		FROM cars
		GROUP BY model, brand
		HAVING COUNT(1) > 1);

-- Solution II

DELETE FROM cars
WHERE id IN (
		SELECT c2.id
		FROM cars c1
		JOIN cars c2
		ON c1.model = c2.model AND c1.brand = c2.brand
		WHERE c1.id < c2.id);

-- Solution III

DELETE FROM cars
WHERE id IN
		(WITH rn1 AS
			(SELECT id,model, brand, ROW_NUMBER() OVER(PARTITION BY model,brand) as rn
			FROM cars)
		SELECT id
		FROM rn1 
		WHERE rn > 1);

-- Solution IV

DELETE FROM cars
WHERE id NOT IN
		(SELECT MIN(id)
		FROM cars
		GROUP BY model, brand);
		
/* 2) Problem Statement: Write a SQL query to determine the daily distance traveled by a car 
based on a table that includes information about cars, days, and the cumulative distance 
traveled on each day. */

-- Create Table

CREATE TABLE cars_travel
(
        car VARCHAR(50),
	    days VARCHAR(50),
	    distance_travelled INT
);	

-- Insert Data

INSERT INTO cars_travel VALUES ('Ertiga', 'Day 1', 150);
INSERT INTO cars_travel VALUES ('Ertiga', 'Day 2', 350);
INSERT INTO cars_travel VALUES ('Ertiga', 'Day 3', 500);
INSERT INTO cars_travel VALUES ('Innova', 'Day 1', 200);
INSERT INTO cars_travel VALUES ('Innova', 'Day 2', 400);
INSERT INTO cars_travel VALUES ('Innova', 'Day 3', 400);
INSERT INTO cars_travel VALUES ('Thar', 'Day 1', 100);
INSERT INTO cars_travel VALUES ('Thar', 'Day 2', 100);
INSERT INTO cars_travel VALUES ('Thar', 'Day 3', 400);
INSERT INTO cars_travel VALUES ('Thar', 'Day 4', 450);

-- Test Data

SELECT * FROM cars_travel;

-- Solution

SELECT car, days, distance_travelled,
distance_travelled - LAG(distance_travelled, 1, 0) OVER (PARTITION BY car ORDER BY days) 
AS actual_distance
FROM cars_travel;

/*3) Problem Statement: Write a SQL query to display values from separate rows in a 
single column, with the values of two rows presented in the same column and separated 
by commas. */

-- Create Table

CREATE TABLE employees
(
  id INT,
  emp_name VARCHAR(50)
);

-- Insert Data

INSERT INTO employees VALUES (1, 'Ross');
INSERT INTO employees VALUES (2, 'Joey');
INSERT INTO employees VALUES (3, 'Monica');
INSERT INTO employees VALUES (4, 'Chandler');
INSERT INTO employees VALUES (5, 'Rachel');
INSERT INTO employees VALUES (6, 'Phoebe');
INSERT INTO employees VALUES (7, 'Janice');
INSERT INTO employees VALUES (8, 'Mike');

-- Test Data

SELECT * FROM employees;

-- Solution

WITH cte AS
		(SELECT CONCAT(id, ' ', emp_name) AS final_value,
		ntile(4) OVER (ORDER BY id) AS buckets
		FROM employees)
SELECT string_agg(final_value, ', ') as combined_value
FROM cte
GROUP BY buckets
ORDER BY buckets;

/* 4) Problem Statement: Write a SQL query to identify the employee having the 
fourth-highest salary. */

-- Add salary column to employees table

ALTER TABLE employees
ADD COLUMN salary INT;

-- Insert data in salary column

UPDATE employees
SET salary = CASE   WHEN id = 1 THEN 80000
					WHEN id = 2 THEN 85000
					WHEN id = 3 THEN 90000
					WHEN id = 4 THEN 88000
					WHEN id = 5 THEN 120000
					WHEN id = 6 THEN 60000
					WHEN id = 7 THEN 70000
					ELSE 75000 END;

-- Solution

WITH cte AS
	(SELECT * , DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
	FROM employees)

SELECT emp_name, salary
FROM cte
WHERE rnk = 4;

/* 5) Problem Statement:

Table: Tree

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| p_id        | int  |
+-------------+------+
*id is the column with unique values for this table.
*Each row of this table contains information about the id of a node and 
 the id of its parent node in a tree.
*The given structure is always a valid tree.
 
Each node in the tree can be one of three types:

"Leaf": if the node is a leaf node.
"Root": if the node is the root of the tree.
"Inner": If the node is neither a leaf node nor a root node.

Write a solution to report the type of each node in the tree.

Return the result table in any order.

The result format is in the following example.

Example 1:

Input: 
Tree table:
+----+------+
| id | p_id |
+----+------+
| 1  | null |
| 2  | 1    |
| 3  | 1    |
| 4  | 2    |
| 5  | 2    |
+----+------+
Output: 
+----+-------+
| id | type  |
+----+-------+
| 1  | Root  |
| 2  | Inner |
| 3  | Leaf  |
| 4  | Leaf  |
| 5  | Leaf  |
+----+-------+

Explanation: 
*Node 1 is the root node because its parent node is null and it has child nodes 2 and 3.
*Node 2 is an inner node because it has parent node 1 and child node 4 and 5.
*Nodes 3, 4, and 5 are leaf nodes because they have parent nodes and they do not have 
child nodes.

Example 2:

Input: 
Tree table:
+----+------+
| id | p_id |
+----+------+
| 1  | null |
+----+------+
Output: 
+----+-------+
| id | type  |
+----+-------+
| 1  | Root  |
+----+-------+
Explanation: If there is only one node on the tree, 
you only need to output its root attributes. */

-- Create Table

CREATE Table tree
( 
	id INT,
	p_id INT
);

-- Insert Data

INSERT INTO tree VALUES(1, null);
INSERT INTO tree VALUES(2, 1);
INSERT INTO tree VALUES(3, 1);
INSERT INTO tree VALUES(4, 2);
INSERT INTO tree VALUES(5, 2);
INSERT INTO tree VALUES(6, null);
INSERT INTO tree VALUES(7, null);
INSERT INTO tree VALUES(8, 7);
INSERT INTO tree VALUES(9, 8);

-- Test Data

SELECT * FROM tree;

-- Solution

SELECT id,
( CASE WHEN p_id IS null THEN 'Root'
       WHEN p_id IS NOT null AND id IN (SELECT DISTINCT p_id FROM tree) THEN 'Inner'
       ELSE 'Leaf' END
) AS type
FROM tree;

---- Happy Learning ----
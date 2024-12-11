-- Reset everything on run
DROP DATABASE IF EXISTS test;
CREATE DATABASE test;
use test
;

-- Create tables
CREATE TABLE Results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    query_type VARCHAR(50),
    description VARCHAR(255) DEFAULT '', -- Desc are empty in example
    dataset_size INT,
    index_type VARCHAR(255),
    time_microseconds DOUBLE
);

CREATE TABLE Accounts50 (
    account_num INT(16) PRIMARY KEY,
    branch_name VARCHAR(255) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL,
    account_type VARCHAR(50) NOT NULL
);

CREATE TABLE Accounts100 (
    account_num INT(16) PRIMARY KEY,
    branch_name VARCHAR(255) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL,
    account_type VARCHAR(50) NOT NULL
);

CREATE TABLE Accounts150 (
    account_num INT(16) PRIMARY KEY,
    branch_name VARCHAR(255) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL,
    account_type VARCHAR(50) NOT NULL
);

-- Generate accounts procedure
delimiter $$
CREATE PROCEDURE generate_accounts()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);

  -- Generate records for Accounts50
  WHILE i <= 50000 DO
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    INSERT INTO Accounts50 (account_num, branch_name, balance, account_type)
    -- Add 1, 2, or 3 to start of each to keep primaries unique just in case
    VALUES (CONCAT('1', LPAD(i, 6, '0')), branch_name, ROUND((RAND() * 100000), 2), account_type);
    SET i = i + 1;
  END WHILE;

  -- Generate records for Accounts100
  SET i = 50001;
  WHILE i <= 150000 DO
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    INSERT INTO Accounts100 (account_num, branch_name, balance, account_type)
    VALUES (CONCAT('2', LPAD(i, 6, '0')), branch_name, ROUND((RAND() * 100000), 2), account_type);
    SET i = i + 1;
  END WHILE;

  -- Generate records for Accounts150
  SET i = 150001;
  WHILE i <= 300000 DO
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    INSERT INTO Accounts150 (account_num, branch_name, balance, account_type)
    VALUES (CONCAT('3', LPAD(i, 6, '0')), branch_name, ROUND((RAND() * 100000), 2), account_type);
    SET i = i + 1;
  END WHILE;
END$$
delimiter ;

-- Measure query performance procedure
-- Runs a query and inserts into results table
delimiter $$
CREATE PROCEDURE measure_query_performance(IN query_string TEXT, IN dataset_size INT, IN query_type VARCHAR(50), IN index_type VARCHAR(255))
BEGIN
    -- Declar variables
  DECLARE start_time DATETIME(6);
  DECLARE end_time DATETIME(6);
  DECLARE total_time_microseconds BIGINT DEFAULT 0;
  DECLARE current_time_microseconds BIGINT;
  DECLARE i INT DEFAULT 1;

  WHILE i <= 10 DO
    -- Time passed queries
    SET start_time = NOW(6);
    PREPARE stmt FROM query_string;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET end_time = NOW(6);

    -- Get time of runs
    SET current_time_microseconds = TIMESTAMPDIFF(MICROSECOND, start_time, end_time);
    SET total_time_microseconds = total_time_microseconds + current_time_microseconds;
    SET i = i + 1;
  END WHILE;

    -- Insert results
  INSERT INTO Results (query_type, dataset_size, index_type, time_microseconds)
  VALUES (query_type, dataset_size, index_type, total_time_microseconds / 10);
END$$
delimiter ;

-- Procedure to measure queries on tables
delimiter $$
CREATE PROCEDURE measure_queries_on_table(IN table_name VARCHAR(255), IN dataset_size INT)
BEGIN
    -- Set vars
  DECLARE query1 TEXT;
  DECLARE query2 TEXT;
  DECLARE dynamic_query TEXT; -- Holds sql string for each call to set indexes

    -- INTO @dummy supresses output (made debugging easier)
  SET query1 = CONCAT('SELECT count(*) INTO @dummy FROM ', table_name, ' WHERE branch_name = "Perryridge"');
  SET query2 = CONCAT('SELECT count(*) INTO @dummy FROM ', table_name, ' WHERE branch_name = "Downtown" AND balance BETWEEN 10000 AND 50000');

    -- Run queries with no index
  CALL measure_query_performance(query1, dataset_size, 'Point', 'No Index');
  CALL measure_query_performance(query2, dataset_size, 'Range', 'No Index');

    -- Set indexes for current table
  SET dynamic_query = CONCAT('CREATE INDEX idx_branch_name ON ', table_name, '(branch_name)');
  PREPARE stmt FROM dynamic_query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  SET dynamic_query = CONCAT('CREATE INDEX idx_branch_name_account_type ON ', table_name, '(branch_name, account_type)');
  PREPARE stmt FROM dynamic_query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

    -- Run queries with indexes
  CALL measure_query_performance(query1, dataset_size, 'Point', 'branch_name, account_type');
  CALL measure_query_performance(query2, dataset_size, 'Range', 'branch_name, account_type');

    -- Remove indexes for current table
  SET dynamic_query = CONCAT('DROP INDEX idx_branch_name ON ', table_name);
  PREPARE stmt FROM dynamic_query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;

  SET dynamic_query = CONCAT('DROP INDEX idx_branch_name_account_type ON ', table_name);
  PREPARE stmt FROM dynamic_query;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
END$$
delimiter ;

-- Procedure to run tests
delimiter $$
CREATE PROCEDURE measure_performance_on_all_accounts()
BEGIN
  CALL measure_queries_on_table('Accounts50', 50000);
  CALL measure_queries_on_table('Accounts100', 100000);
  CALL measure_queries_on_table('Accounts150', 150000);
END$$
delimiter ;

-- Generate and run tests
call generate_accounts()
;
call measure_performance_on_all_accounts()
;

-- Print results
SELECT *
FROM Results
ORDER BY query_type ASC, id ASC
;

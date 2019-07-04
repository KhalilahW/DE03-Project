The first step is to log into SQL from the command line using: mysql -u root -p. 
You'll be prompted to enter the password (it's usually "password")
From the MySQL command line give the command to change to the database you want to use: use cdw_sapp;.
If your database exists, you'll get a message that reads: database changed.
Now give the command to grant all privileges to your database of choice:  grant all privileges on cdw_sapp.* to ''@'localhost';.
If successful, you'll see this message: Query OK, 0 rows affected (0.02 sec).
Exit from SQL using Ctr+C

Open a new tab for your Virtual Machine and enter this command to start the Sqoop Metastore: sqoop-metastore.

Now SQOOP your table from SQL into Hive.
I decided to import all tables at once for efficiency with the following command:

sqoop import-all-tables
--connect jdbc:mysql://localhost/cdw_sapp
--driver com.mysql.jdbc.Driver 
-m 1
--warehouse-dir /user/maria_dev/Credit_Card_System/
--fields-terminated-by '\t'

**warehouse-dir is used instead of target-dir because we're not using single table upload

_________________________________________________________________________________________________________________________________________________________

I created dynamic partitioned tables by using the following commands: 


drop table CDW_SAPP_BRANCH;
drop table CDW_SAPP_D_BRANCH;

create external table CDW_SAPP_BRANCH
(BRANCH_CODE String, BRANCH_NAME String, BRANCH_STREET String,
BRANCH_CITY String, BRANCH_STATE String, BRANCH_ZIP String, 
BRANCH_PHONE String, LAST_UPDATED Timestamp)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
location '/user/maria_dev/Credit_Card_System/CDW_SAPP_BRANCH';


create external table CDW_SAPP_D_BRANCH
(BRANCH_CODE String, BRANCH_NAME String, BRANCH_STREET String,
BRANCH_CITY String, BRANCH_ZIP String, 
BRANCH_PHONE String, LAST_UPDATED Timestamp)
partitioned by(BRANCH_STATE String)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
location '/user/maria_dev/Credit_Card_System/CDW_SAPP_D_BRANCH';


SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT OVERWRITE TABLE CDW_SAPP_D_BRANCH
PARTITION (BRANCH_STATE)
SELECT BRANCH_CODE, BRANCH_NAME, BRANCH_STREET, BRANCH_CITY, coalesce(BRANCH_ZIP, 99999) as BRANCH_ZIP, 
concat("(",substring(BRANCH_PHONE,1,3),")", substring(BRANCH_PHONE,4,3),"-", substring(BRANCH_PHONE,7,4))
as BRANCH_PHONE, LAST_UPDATED, BRANCH_STATE
From CDW_SAPP_BRANCH;

drop table CDW_SAPP_CREDITCARD;
drop table CDW_SAPP_F_CREDIT_CARD;

CREATE EXTERNAL TABLE CDW_SAPP_CREDITCARD
(TRANSACTION_ID INT, DAY INT, MONTH INT, YEAR INT, CREDIT_CARD_NO STRING, CUST_SSN INT,
BRANCH_CODE INT, TRANSACTION_TYPE STRING, TRANSACTION_VALUE DOUBLE)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_CREDITCARD';

CREATE EXTERNAL TABLE CDW_SAPP_F_CREDIT_CARD
(TRANSACTION_ID STRING, CUST_CC_NO STRING,TIMEID STRING, CUST_SSN STRING, BRANCH_CODE STRING,TRANSACTION_VALUE STRING)
PARTITIONED BY (TRANSACTION_TYPE STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_F_CREDIT_CARD';

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE CDW_SAPP_F_CREDIT_CARD
PARTITION (TRANSACTION_TYPE)
SELECT TRANSACTION_ID, CREDIT_CARD_NO AS CUST_CC_NO,
date(CONCAT(YEAR,'-',MONTH,'-',DAY)) AS TIMEID,
CUST_SSN, BRANCH_CODE,TRANSACTION_VALUE, TRANSACTION_TYPE
FROM CDW_SAPP_CREDITCARD;


drop table CDW_SAPP_CUSTOMER;
drop table CDW_SAPP_D_CUSTOMER;

CREATE EXTERNAL TABLE CDW_SAPP_CUSTOMER
(FIRST_NAME STRING,MIDDLE_NAME STRING,LAST_NAME STRING,SSN STRING, CREDIT_CARD_NO STRING,
APT_NO STRING, STREET_NAME STRING, CUST_CITY STRING,CUST_STATE STRING,CUST_COUNTRY STRING,
CUST_ZIP STRING,CUST_PHONE STRING,CUST_EMAIL STRING,LAST_UPDATED TIMESTAMP)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_CUSTOMER';


CREATE EXTERNAL TABLE CDW_SAPP_D_CUSTOMER
(CUST_SSN STRING,CUST_F_NAME STRING,CUST_M_NAME STRING,CUST_L_NAME STRING,CUST_CC_NO STRING,
STREET_NAME STRING,CUST_CITY STRING,CUST_STATE STRING,CUST_COUNTRY STRING,CUST_PHONE STRING,
CUST_EMAIL STRING, LAST_UPDATED TIMESTAMP)
PARTITIONED BY (CUST_ZIP STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_D_CUSTOMER';

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE CDW_SAPP_D_CUSTOMER
PARTITION(CUST_ZIP)
SELECT SSN AS CUST_SSN,(CONCAT(UCASE(SUBSTRING(lcase(FIRST_NAME), 1, 1)),
                               LOWER(SUBSTRING(lcase(FIRST_NAME), 2)))) AS CUST_F_NAME,
LOWER(MIDDLE_NAME) AS CUST_M_NAME, (CONCAT(UCASE(SUBSTRING(lcase(LAST_NAME), 1, 1)),
                                           LOWER(SUBSTRING(lcase(LAST_NAME), 2)))) AS CUST_L_NAME,
CREDIT_CARD_NO AS CUST_CC_NO, concat('(',STREET_NAME,', ',APT_NO,')') AS CUST_STREET,
CUST_CITY,CUST_STATE,CUST_COUNTRY,
concat(substring(CUST_PHONE,1,3),"-",substring(CUST_PHONE,4,4)) AS CUST_PHONE, CUST_EMAIL,
LAST_UPDATED, CUST_ZIP
FROM CDW_SAPP_CUSTOMER;


drop table CDW_SAPP_TIME;
drop table CDW_SAPP_D_TIME;

CREATE EXTERNAL TABLE CDW_SAPP_TIME
(TRANSACTION_ID INT, DAY INT, MONTH INT, YEAR INT, CREDIT_CARD_NO STRING, CUST_SSN Int,
BRANCH_CODE Int, TRANSACTION_TYPE STRING, TRANSACTION_VALUE Double)
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_CREDITCARD';

CREATE EXTERNAL TABLE CDW_SAPP_D_TIME
(TIMEID STRING, DAY STRING, MONTH STRING, YEAR STRING) 
Partitioned by (QUARTER String)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
LOCATION '/user/maria_dev/Credit_Card_System/CDW_SAPP_D_TIME';

SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT OVERWRITE TABLE CDW_SAPP_D_TIME
PARTITION (QUARTER)
SELECT date(CONCAT(YEAR,'-',MONTH,'-',DAY)) AS TIMEID,
DAY, MONTH, YEAR, FLOOR(INT((MONTH(date(CONCAT(YEAR, '-', MONTH, '-',DAY)))-1)/3)+1) as QUARTER
FROM CDW_SAPP_TIME;

**Adding drop table statements will prevent any conflict in case tables with the same name are already created.

_________________________________________________________________________________________________________________________________________________________

Now, we'll simplify and speed up the above process by using Ooozie. First, create a Sqoop Job for each table:

--target-dir /user/maria_dev/Credit_Card_System/CDW_SAPP_CREDITCARD
-m1

sqoop job --meta-connect jdbc:hsqldb:hsql://localhost:16000/sqoop
--create customerjob
-- import 
--connect jdbc:mysql://localhost/cdw_sapp
--driver com.mysql.jdbc.Driver 
--query  'SELECT * FROM CDW_SAPP_CUSTOMER WHERE $CONDITIONS' 
--fields-terminated-by '\t' 
--incremental append 
--check-column ssn
--last-value '0' 
--target-dir /user/maria_dev/Credit_Card_System/CDW_SAPP_CUSTOMER
-m1

sqoop job --meta-connect jdbc:hsqldb:hsql://localhost:16000/sqoop
--create timejob
-- import 
--connect jdbc:mysql://localhost/cdw_sapp
--driver com.mysql.jdbc.Driver 
--query  'SELECT * FROM CDW_SAPP_CREDITCARD WHERE $CONDITIONS' 
--fields-terminated-by '\t' 
--incremental append 
--columns "transaction_id,day,month,year"
--check-column transaction_id
--last-value '0' 
--target-dir /user/maria_dev/Credit_Card_System/CDW_SAPP_TIME
-m1

_________________________________________________________________________________________________________________________________________________________

Next, create an Ooozie workflow, which is enclosed in  separate file. 

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT INTO TABLE CDW_SAPP_D_CUSTOMER
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
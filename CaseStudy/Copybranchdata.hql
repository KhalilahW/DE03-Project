SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

INSERT INTO TABLE CDW_SAPP_D_BRANCH
PARTITION (BRANCH_STATE)
SELECT BRANCH_CODE, BRANCH_NAME, BRANCH_STREET, BRANCH_CITY, coalesce(BRANCH_ZIP, 99999) as BRANCH_ZIP, 
concat("(",substring(BRANCH_PHONE,1,3),")", substring(BRANCH_PHONE,4,3),"-", substring(BRANCH_PHONE,7,4))
as BRANCH_PHONE, LAST_UPDATED, BRANCH_STATE
From CDW_SAPP_BRANCH;
SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

INSERT INTO TABLE CDW_SAPP_D_TIME
PARTITION (QUARTER)
SELECT date(CONCAT(YEAR,'-',MONTH,'-',DAY)) AS TIMEID,
DAY, MONTH, YEAR, FLOOR(INT((MONTH(date(CONCAT(YEAR, '-', MONTH, '-',DAY)))-1)/3)+1) as QUARTER
FROM CDW_SAPP_TIME;
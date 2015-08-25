--Emily Cain 2/2/15

/*8. Give a raise to our best salesperson(s).
File to create: q8.sql
Columns to display: none
Instructions: Write an UPDATE query to increase the value of the SALESPERSONS.salary column by 9% for the most profitable salesperson(s).*/

UPDATE SALESPERSONS
SET SALESPERSONS.Salary = SALESPERSONS.Salary*1.09
WHERE SALESPERSONS.empid IN
	(
  SELECT empid
  FROM
    (
    SELECT SALESPERSONS.empid, (SUM(ORDERITEMS.qty*INVENTORY.price) - SALESPERSONS.salary) AS ProfitBySalesperson
    FROM SALESPERSONS LEFT OUTER JOIN ORDERS ON SALESPERSONS.empid = ORDERS.empid JOIN ORDERITEMS ON ORDERS.orderid = ORDERITEMS.orderid JOIN INVENTORY ON ORDERITEMS.PARTID = INVENTORY.PARTID
    GROUP BY SALESPERSONS.empid, SALESPERSONS.ename, SALESPERSONS.salary
    ORDER BY ProfitBySalesperson DESC
    )
  WHERE ROWNUM = 1
	);
COMMIT;

--Emily Cain 2/2/15


/*7. Add a new salesperson
File to create:  q7.sql 
Columns to display: none
Instructions: Write an INSERT query to insert a new salesperson into the database with the following attribute values.
empid should be one greater than the largest existing empid (no hard-coding, use SELECT)
ename should be your name (hard-code your name here)
rank should be whichever rank is associated with the lowest-paid salesperson (use SELECT).
salary is to be 9% more than the lowest-paid salesperson (another SELECT clause). */

INSERT INTO SALESPERSONS (EmpID, Ename, Rank, Salary)
VALUES (
	(
	SELECT MAX(SALESPERSONS.EmpID) + 1
	FROM SALESPERSONS
	),
	'Emily Cain',
	(
	SELECT RANK
	FROM
		(
		SELECT SALESPERSONS.RANK
		FROM SALESPERSONS
		ORDER BY Salary ASC
		)
	WHERE ROWNUM=1
	),
	(
		SELECT MIN(SALESPERSONS.Salary)*1.09
		FROM SALESPERSONS
	)
);


COMMIT;

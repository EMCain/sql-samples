/* 3. Stored Procedure 

Write a stored procedure that adds a lineitem into an order that already exists (AddLineItemSP.sql). This stored procedure will receive three parameters:  an orderid, a partid and a quantity. Issue an INSERT to the ORDERITEMS table. When the INSERT is executed, the trigger on INSERT for the ORDERITEM table will be fired.  Since the value of the Detail column will be determined inside of the INSERT trigger, you will need to provide column names on the INSERT command for just the three columns that you have data for. Remember that when you write an INSERT where the values inserted do not include every column in the table, you need to include the column names with the INSERT. Exception handling must be included. If you attempt to INSERT a partid that does not exist, a system exception will be invoked based on the foreign key constraint. */

 
 
CREATE OR REPLACE PROCEDURE AddLineItemSP ( 
		inpOrderID IN ORDERS.OrderID%TYPE,
		inpPartID IN INVENTORY.PartID%TYPE,
		inpQty IN INVENTORY.StockQty%TYPE) IS

BEGIN
	DECLARE
		OrderQtyTooHigh EXCEPTION;
		PRAGMA EXCEPTION_INIT(OrderQtyTooHigh, -20001);

		v_code NUMBER;
		v_errm VARCHAR2(64);
	
	BEGIN 
		--start process of adding rows

		INSERT INTO ORDERITEMS (Orderid, Partid, Qty)
			VALUES (inpOrderID, inpPartID, inpQty);


		COMMIT;
		DBMS_OUTPUT.PUT_LINE('Items added to order ' || inpOrderID);

	
	EXCEPTION
				
		WHEN OrderQtyTooHigh THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Insufficient items in stock. Order not updated.');
		

		--other errors:
		WHEN OTHERS THEN
			v_code := SQLCODE;
			v_errm := SUBSTR(SQLERRM, 1 , 64);
		DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);

	END;
END;
/
/*4. PL/SQL program

Write a PL/SQL Block that is given the four values, verifies that the customer is valid, verifies the orderid is in the orders table and is a valid order for this customer, verifies that the partid exists in inventory, verifies that the entered quantity is above zero, and then calls the stored procedure (Lab7.sql). You can use the PL/SQL block that you wrote for the previous lab and modify it. It is in your best educational interest to change from nested to sequential or sequential to nested but you don't have to do this. */

SET SERVEROUTPUT ON;

DECLARE
	--inputs
	
	inpCustID ORDERS.CustID%TYPE;
	inpOrderID ORDERS.OrderID%TYPE;
	inpPartID INVENTORY.PartID%TYPE;
	inpQty INVENTORY.StockQty%TYPE;
	
	--counter variable
	
	v_counter SMALLINT;
	
	--error codes
	
	v_code NUMBER;
	v_errm VARCHAR2(64);
		   
	--exceptions
	cust_not_valid EXCEPTION;
		PRAGMA EXCEPTION_INIT(cust_not_valid, -20002);
	order_not_valid EXCEPTION;
		PRAGMA EXCEPTION_INIT(order_not_valid, -20003);
	order_customer_mismatch EXCEPTION;
		PRAGMA EXCEPTION_INIT(order_customer_mismatch, -20004);
	part_not_valid EXCEPTION;
		PRAGMA EXCEPTION_INIT(part_not_valid, -20005);
	quantity_too_low EXCEPTION;
		PRAGMA EXCEPTION_INIT(quantity_too_low, -20006);
    orderQtyTooHigh EXCEPTION;
BEGIN
	--ask for inputs
	
	inpCustID := &1;
	inpOrderID := &2;
	inpPartID := &3;
	inpQty := &4;
	
		--check input for errors and raise exceptions if found
		
		SELECT COUNT(*)
			INTO v_counter
			FROM CUSTOMERS
			WHERE CUSTOMERS.custid = inpCustID;
		IF v_counter = 0  THEN
			RAISE cust_not_valid;
		END IF;
			
		SELECT COUNT(*)
			INTO v_counter
			FROM ORDERS
			WHERE ORDERS.OrderID = inpOrderID;
		IF v_counter = 0 THEN
			RAISE order_not_valid;
		END IF;

		SELECT COUNT(*)
			INTO v_counter
			FROM ORDERS 
			WHERE CustID = inpCustID AND OrderID = inpOrderID;
		IF v_counter = 0 THEN
		RAISE order_customer_mismatch;
		END IF;
		
		SELECT COUNT(*)
			INTO v_counter
			FROM INVENTORY
			WHERE PartID = inpPartID;
		IF v_counter = 0 THEN
			RAISE Part_not_valid;
		END IF;

		IF inpQty < 1 THEN
			RAISE quantity_too_low;
		END IF;
		
		AddLineItemSP(inpOrderID, inpPartID, inpQty);

EXCEPTION
	  --input errors:
	WHEN cust_not_valid THEN
		DBMS_OUTPUT.PUT_LINE('Customer ' || inpCustID || ' does not exist');
	WHEN order_not_valid THEN 
		DBMS_OUTPUT.PUT_LINE('Order ' || inpOrderID || ' does not exist');
	WHEN order_customer_mismatch THEN 
		DBMS_OUTPUT.PUT_LINE('Order ' || inpOrderID || ' does not belong to customer ' || inpCustID);
	WHEN part_not_valid THEN 
		DBMS_OUTPUT.PUT_LINE('Part ' || inpPartID || ' does not exist');
	WHEN quantity_too_low THEN 
		DBMS_OUTPUT.PUT_LINE('Quantity ' || inpQty || ' is too low. Quantity must be 1 or greater.');
    
	--other errors:
	WHEN OTHERS THEN
		v_code := SQLCODE;
		v_errm := SUBSTR(SQLERRM, 1 , 64);
    DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);
END;
/
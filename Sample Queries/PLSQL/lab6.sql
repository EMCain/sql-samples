SET SERVEROUTPUT ON;

DECLARE

	--input variables
	inpCustID ORDERS.CustID%TYPE;
	inpOrderID ORDERS.OrderID%TYPE;
	inpPartID INVENTORY.PartID%TYPE;
	inpQty INVENTORY.StockQty%TYPE;

	--calculated variables
	newDetail ORDERITEMS.Detail%TYPE;
	existingStock INVENTORY.StockQty%TYPE;
	v_counter SMALLINT;
  v_code NUMBER;
  v_errm VARCHAR2(64);
   
	--exceptions
	cust_not_valid EXCEPTION;
	order_not_valid EXCEPTION;
	order_customer_mismatch EXCEPTION;
	part_not_valid EXCEPTION;
	quantity_too_low EXCEPTION;
	insufficient_stock EXCEPTION;


BEGIN

	--ask for user input
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
	
	--if no errors found, start process of adding rows

	SELECT NVL(MAX((detail) +1), 1) 
		INTO newDetail
		FROM ORDERITEMS
    WHERE ORDERID = inpOrderID;
	
	INSERT INTO ORDERITEMS (Orderid, Detail, Partid, Qty)
		VALUES (inpOrderID, newDetail, inpPartID, inpQty);
	
	--update Inventory to reflect merchandise sold
	
--	UPDATE INVENTORY
--	SET Stockqty = Stockqty-inpQty
--	WHERE PartID = inpPartID;

	--check stock levels after update, trigger error if less than 0
	
--	SELECT Stockqty INTO ExistingStock
--		FROM INVENTORY
--		WHERE PartID = inpPartID;
    
--	IF ExistingStock  <0 THEN
--		RAISE insufficient_stock;
--	END IF;
	
	--if no errors, commit
	
	COMMIT;
		DBMS_OUTPUT.PUT_LINE('Items added to order ' || inpOrderID);

	
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
	
	
	--insufficient_stock error:	
	WHEN insufficient_stock THEN 
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Insufficient items in stock. Order not updated.');
	
	--other errors:
	WHEN OTHERS THEN
		v_code := SQLCODE;
		v_errm := SUBSTR(SQLERRM, 1 , 64);
    DBMS_OUTPUT.PUT_LINE('Error code ' || v_code || ': ' || v_errm);

END;
/
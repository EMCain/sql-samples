/*1. INSERT trigger

Write a trigger on the INSERT command of the ORDERITEMS table (InsertOrderitemsTRG.sql).  In this trigger you will determine the value of the column named Detail, which is one more than the last Detail for that Orderid (remember to code for no existing detail lines). One of the beauties of Oracle triggers is that you can assign a value to the newly inserted row.  You can access the new row inside the trigger.  Also, in this trigger you will UPDATE the inventory table to reduce the stockqty of the partid being ordered by the amount in the new lineitem.  Exception handling must be included. */

CREATE OR REPLACE TRIGGER InsOrdItmTrg
	BEFORE INSERT ON ORDERITEMS
	FOR EACH ROW
		
	DECLARE
		orderItemQty ORDERITEMS.Qty%TYPE;
		orderItemID ORDERITEMS.PartID%TYPE;
		newDetail ORDERITEMS.Detail%TYPE;
		
		OrderQtyTooHigh EXCEPTION;
		PRAGMA EXCEPTION_INIT(OrderQtyTooHigh, -20001);	
	BEGIN
		orderItemQty := :new.Qty;
		orderItemID := :new.PartID;
	--determine what the new detail should be
		SELECT MAX(Detail) +1
		INTO newDetail
		FROM ORDERITEMS
		WHERE ORDERITEMS.OrderID = :new.OrderID;
	--return or assign the value of the new detail number 
		:new.Detail := newDetail; 
	--update the INVENTORY table 
		UPDATE INVENTORY
		SET StockQty = StockQty - orderItemQty
		WHERE PartID = OrderItemID;
	EXCEPTION 
		WHEN OrderQtyTooHigh THEN
			RAISE OrderQtyTooHigh;
  
	END;
	/
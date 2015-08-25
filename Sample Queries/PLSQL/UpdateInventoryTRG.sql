/*2. UPDATE trigger

Write a trigger on the UPDATE command of the INVENTORY table (UpdateInventoryTRG.sql). This trigger will check to see if the stockqty of the part being ordered is enough to meet the new lineitem quantity. If the stockqty is not large enough, raise a user defined exception. This requires that you declare a user defined exception in the UPDATE trigger and also in any module where you wish the exception to be raised. 
*/



CREATE OR REPLACE TRIGGER UpdInvTrg
	AFTER UPDATE ON INVENTORY
	FOR EACH ROW
	
	DECLARE
		OrderQtyTooHigh EXCEPTION;
		PRAGMA EXCEPTION_INIT(OrderQtyTooHigh, -20001);
				
	BEGIN
		
		IF :new.stockqty < 0 THEN
			RAISE OrderQtyTooHigh;
		END IF;			
	END;
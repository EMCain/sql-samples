/*
********************************************************************************
3/10/15 Emily Cain
********************************************************************************
*/
USE  s276ECain;
/*
--------------------------------------------------------------------------------
CUSTOMERS.CustID validation
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
    BEGIN
        DROP PROCEDURE ValidateCustID;
    END;    -- must use block for more than one statement
-- END IF;  SQL Server does not use END IF
GO

-- Notice my found variable contains the customer name
-- YOU can/should do something else to indicate a row exists to validate CustID


IF EXISTS ( SELECT name FROM sys.objects WHERE name = 'ValidateCustID')
	BEGIN DROP PROCEDURE ValidateCustID END;
GO

CREATE PROCEDURE ValidateCustID
    @vCustid SMALLINT,
    @vFound  SMALLINT OUTPUT

AS
BEGIN
	DECLARE @vErrStr   VARCHAR(80);
    SELECT @vFound = COUNT(*)
    FROM CUSTOMERS
    WHERE CUSTOMERS.CustID = @vCustid;
	IF @vFound = 0
		BEGIN
		SET @vErrStr = 'Customer number ' + CAST(@vCustid AS CHAR (3)) + ' does not exist.';
		RAISERROR(@vErrStr, 1, 1);
		END;

END;
GO

-- testing block for ValidateCustID
BEGIN

    DECLARE @vHowManyCust CHAR(25);  -- holds value returned from procedure

    EXECUTE ValidateCustID 1, @vHowManyCust OUTPUT;
    PRINT 'ValidateCustID test with valid CustID 1 returns ' + CAST(@vHowManyCust AS CHAR(2)) + ' customer(s).';
	-- When @vHowManyCust is 1 the custid is in the table.

    EXECUTE ValidateCustID 5, @vHowManyCust OUTPUT;
    PRINT 'ValidateCustID test with valid CustID 1 returns ' + CAST(@vHowManyCust AS CHAR(2)) + ' customer(s).';
	-- When @vHowManyCust is 0 the custid is not in the CUSTOMERS table.

END;
GO

/*
--------------------------------------------------------------------------------
ORDERS.OrderID validation:
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateOrderID')
    BEGIN DROP PROCEDURE ValidateOrderID; END;
GO

CREATE PROCEDURE ValidateOrderID -- with custid and orderid input
    @vCustid SMALLINT,
	@vOrderid SMALLINT
AS
BEGIN
-- OrderID found in ORDERS table . . .
DECLARE @vErrStr   VARCHAR(80);
DECLARE @vOrdFound  SMALLINT;
DECLARE @vMatchFound SMALLINT;
SET @vOrdFound = 0;
SET @vMatchFound = 0;
    SELECT @vOrdFound = COUNT(*)
    FROM ORDERS
    WHERE OrderID = @vOrderid;
	IF @vOrdFound = 0
		BEGIN
		SET @vErrStr = 'Order number ' + CAST(@vOrderid AS VARCHAR(10)) + ' does not exist.';
		RAISERROR(@vErrStr, 1, 1) WITH SetError;
		END;
--determine if order belongs to customer
	SELECT @vMatchFound = COUNT(*)
    FROM ORDERS
    WHERE OrderID = @vOrderid AND CustID = @vCustid;
	IF @vMatchFound = 0
		BEGIN
		SET @vErrStr = 'Order number '+ CAST(@vOrderid AS VARCHAR(10)) + ' does not belong to customer ' + CAST(@vCustid AS VARCHAR(10));
		RAISERROR(@vErrStr, 1, 1) WITH SetError;
		END;


-- OrderID not found in ORDERS table is invalid.
END;
GO

-- testing block for ValidateOrderID
BEGIN
	PRINT 'testing with correct inputs';
	EXECUTE ValidateOrderID 1, 6099;

	PRINT 'testing with incorrect order number';
	EXECUTE ValidateOrderID 1, 5;

	PRINT 'testing with mismatched customer and order';
	EXECUTE ValidateOrderID 2, 6099;

END;
GO



/*
--------------------------------------------------------------------------------
INVENTORY.PartID validation:
--------------------------------------------------------------------------------
*/



IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidatePartID')
    DROP PROCEDURE ValidatePartID;
GO

CREATE PROCEDURE ValidatePartID
	@vPartid SMALLINT,
    @vFound  SMALLINT OUTPUT

AS
BEGIN
	DECLARE @vErrStr   VARCHAR(80);
    SELECT @vFound = COUNT(*)
    FROM INVENTORY
    WHERE PartID = @vPartid;
	IF @vFound = 0
		BEGIN
		SET @vErrStr = 'Part number ' + CAST(@vPartid AS VARCHAR(4)) + ' does not exist.';
		RAISERROR(@vErrStr, 1, 1) WITH SetError;
		END;
END;
GO

-- testing block for ValidateCustID
BEGIN

    DECLARE @vHowManyPart CHAR(1);  -- holds value returned from procedure
    DECLARE @vHowManyCust CHAR(1);  -- holds value returned from procedure

    EXECUTE ValidatePartID 1001, @vHowManyPart OUTPUT; --change to a valid partid
    PRINT 'ValidatePartID test with valid part 1001 returns ' + @vHowManyPart + ' part(s).';--change to correct message
	-- When @vHowManyCust is 1 the custid is in the table.

    EXECUTE ValidatePartID 1011, @vHowManyPart OUTPUT;
    PRINT 'ValidatePartID test with invalid PartID 1011 returns ' + @vHowManyPart + ' part(s).';--invalid input, correct message
	-- When @vHowManyCust is 0 the custid is not in the CUSTOMERS table.

END;
GO

SELECT * FROM INVENTORY;

/*
--------------------------------------------------------------------------------
Input quantity validation:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'ValidateQty')
    BEGIN DROP PROCEDURE ValidateQty; END;
GO

CREATE PROCEDURE ValidateQty
	@vQty SMALLINT,
	@vIsQtyValid VARCHAR(3) OUTPUT

AS
BEGIN
SET @vIsQtyValid = 'YES';
IF @vQty <1
	BEGIN
	SET @vIsQtyValid = 'NO';
	RAISERROR('Qty must be 1 or greater', 1, 1);
	END;


END;
GO

-- testing block for ValidateQty
BEGIN
	DECLARE @vIsValid VARCHAR(3);
	SET @vIsValid = 'IDK';
	EXECUTE ValidateQty 5, @vIsValid OUTPUT;
	PRINT CAST(@vIsValid AS CHAR(3)) + ', 5 is valid';
	EXECUTE ValidateQty 0, @vIsValid OUTPUT;
	PRINT CAST(@vIsValid AS CHAR(3)) + ', 0 is not valid';

END;
GO

/*
--------------------------------------------------------------------------------
ORDERITEMS.Detail determines new value:
You can handle NULL within the projection but it can be done in two steps
(SELECT and then test).  It is important to deal with the possibility of NULL
because the detail is part of the primary key and therefore cannot contain NULL.
--------------------------------------------------------------------------------
*/

SELECT COUNT(Detail), ORDERITEMS.OrderID, ORDERS.OrderID FROM ORDERITEMS FULL OUTER JOIN ORDERS ON ORDERITEMS.OrderID = ORDERS.OrderID GROUP BY ORDERITEMS.OrderID, ORDERS.OrderID;

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'GetNewDetail')
    BEGIN DROP PROCEDURE GetNewDetail; END;
GO

CREATE PROCEDURE GetNewDetail
	@vOrderID SMALLINT,
	@vNewDetail SMALLINT OUTPUT
AS
BEGIN
	SET @vNewDetail = 1;
	SELECT @vNewDetail = ISNULL(MAX(Detail)+1, 1)
	FROM ORDERITEMS
	WHERE OrderID = @vOrderID;
END;
GO

-- testing block for GetNewDetail
BEGIN
	DECLARE @vNewDetail SMALLINT;

	--test order with items
	EXECUTE GetNewDetail 6099, @vNewDetail OUTPUT;
	PRINT 'new item on order 6099 gets detail number ' + CAST(@vNewDetail AS VARCHAR(3));
	--test order with no items
	EXECUTE GetNewDetail 6107, @vNewDetail OUTPUT;
	PRINT 'new item on previously empty order 6107 gets detail number ' + CAST(@vNewDetail AS VARCHAR(3));
END;
GO

/*
--------------------------------------------------------------------------------
INVENTORY trigger for an UPDATE:
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'InventoryUpdateTRG')
    BEGIN DROP TRIGGER InventoryUpdateTRG; END;
GO

CREATE TRIGGER InventoryUpdateTRG
ON INVENTORY
FOR UPDATE
AS
BEGIN
	DECLARE @vStockQty SMALLINT;
-- compare (SELECT Stockqty FROM INSERTED) to zero
	SELECT @vStockQty = StockQty
	FROM INVENTORY
	WHERE PartID = (SELECT PartID FROM inserted);
-- your error handling
	IF @vStockQty < 0
		RAISERROR('Insufficient Stock', 1, 1);
END;
GO

-- testing blocks for InventoryUpdateTRG
-- There should be at least three testing blocks here
BEGIN
	--valid input
	DECLARE @newQty SMALLINT;

	UPDATE INVENTORY
	SET StockQty = 10
	WHERE PartID = 1001;

	SELECT @newQty = StockQty
	FROM INVENTORY
	WHERE PartID = 1001;

	PRINT 'qty is now ' + CAST(@newQty AS VARCHAR(3));

	--too low quantity


	UPDATE INVENTORY
	SET StockQty = -10
	WHERE PartID = 1001;

	SELECT @newQty = StockQty
	FROM INVENTORY
	WHERE PartID = 1001;

	PRINT 'qty is now ' + CAST(@newQty AS VARCHAR(3));

END;
GO

/*
--------------------------------------------------------------------------------
ORDERITEMS trigger for an INSERT:
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'OrderitemsInsertTRG')
    BEGIN DROP TRIGGER OrderitemsInsertTRG; END;
GO

CREATE TRIGGER OrderitemsInsertTRG
ON ORDERITEMS
FOR INSERT
AS
BEGIN
    -- get new values for qty and partid from the INSERTED table
	DECLARE @vQty SMALLINT;
	DECLARE @vPartID SMALLINT;

    SELECT @vQty = Qty FROM INSERTED;
	SELECT @vPartID = PartID FROM INSERTED;

	-- get current (changed) StockQty for this PartID
    DECLARE @oldStockQty SMALLINT;
	DECLARE @newStockQty SMALLINT;
	SELECT @oldStockQty = StockQty
	FROM INVENTORY
	WHERE PartID = @vPartID;
	SET @newStockQty = @oldStockQty - @vQty;

	-- UPDATE with current (changed) StockQty

	UPDATE INVENTORY
	SET StockQty = @newStockQty
	WHERE PartID = @vPartID;

    -- your error handling

END
GO

-- testing blocks for OrderItemsInsertTrg
-- There should be at least three testing blocks here
BEGIN
DECLARE @vNewDetail SMALLINT;

	 SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
	 SELECT * FROM INVENTORY WHERE PartID = 1001;

	--test order with items
	EXECUTE GetNewDetail 6099, @vNewDetail OUTPUT;
	INSERT INTO ORDERITEMS(OrderID, PartID, Qty, Detail)
	VALUES(6099, 1001, 10, @vNewDetail);

	 SELECT * FROM ORDERITEMS WHERE OrderID = 6099;
	 SELECT * FROM INVENTORY WHERE PartID = 1001;
END;
GO


/*
--------------------------------------------------------------------------------
The TRANSACTION, this procedure calls GetNewDetail and performs an INSERT
to the ORDERITEMS table which in turn performs an UPDATE to the INVENTORY table.
Error handling determines COMMIT/ROLLBACK.
--------------------------------------------------------------------------------
*/

IF EXISTS (SELECT name FROM sys.objects WHERE name = 'AddLineItem')
    BEGIN DROP PROCEDURE AddLineItem; END;
GO

CREATE PROCEDURE AddLineItem [with OrderID, PartID and Qty input parameters]
	@vOrderID SMALLINT,
	@vPartID SMALLINT,
	@vQty SMALLINT

AS


BEGIN
BEGIN TRANSACTION    -- this is the only BEGIN TRANSACTION for the lab assignment
    EXECUTE GetNewDetail inputorderid, outputdetail OUTPUT;
    INSERT
    -- your error handling
-- END TRANSACTION;
END;
GO

-- No AddLineItem tests, saved for main block testing
-- well, you could EXECUTE AddLineItem 6099,1001,50
GO

/*
--------------------------------------------------------------------------------
Puts all of the previous together to produce a solution for Lab8 done in
SQL Server. This stored procedure accepts the 4 pieces of input:
Custid, Orderid, Partid, and Qty (in that order please). It validates all the
data and does the transaction processing by calling the previously written and
tested modules.
--------------------------------------------------------------------------------
*/
IF EXISTS (SELECT name FROM sys.objects WHERE name = 'Lab8proc')
    BEGIN DROP PROCEDURE Lab8proc; END;
GO

CREATE PROCEDURE Lab8proc (with the four values input)
AS

BEGIN
    -- EXECUTE ValidateCustId
	-- EXECUTE ValidateOrderid
    -- EXECUTE ValidatePartId
    -- EXECUTE ValidateQty
	-- IF everything validates THEN we can do the TRANSACTION
        -- EXECUTE AddLineItem
    -- ELSE send a message?
    -- ENDIF;
END;
GO

/*
--------------------------------------------------------------------------------
-- Your testing blocks for Lab8proc goes last
--------------------------------------------------------------------------------
*/

DECLARE
BEGIN
    -- EXECUTE
END;

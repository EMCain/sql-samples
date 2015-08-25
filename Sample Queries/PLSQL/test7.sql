--testing with correct inputs
@lab7 1 6099 1001 10;

--testing with incorrect customer
@lab7 300 6099 1001 10;

--testing with incorrect order number
@lab7 1 5 1001 10;

--testing with mismatched customer and order
@lab7 2 6099 1001 10;

--testing with too-low quantity
@lab7 1 6099 1001 0;

--testing with too-high quantity
@lab7 1 6099 1001 1000;

----reset database
--@a-drop-salesdb;
--@a-create-salesdb;
--@a-index-salesdb;
--@a-load-salesdb;


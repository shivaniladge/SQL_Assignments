# Assignment Part 3
use assignments;
#1. Write a stored procedure that accepts the month and year as inputs and prints the ordernumber, orderdate and status of the orders placed in that month. 

select * from orders;
delimiter $$
create procedure `order_status`(month1 varchar(15), year1 int)
begin
select orderNumber,orderDate, status 
from orders 
where year(orderdate)=year1 and left(monthname(orderdate),3)=month1;
end $$
call assignments.order_status('feb',2005);
/*____________________________________________________________________________________________________________________________________________________________________*/

#2. Write a stored procedure to insert a record into the cancellations table for all cancelled orders.
#a.	Create a table called cancellations with the following fields

create table cancellations (ID int primary key, customernumber int,ordernumber int, 
foreign key (customernumber) references customers (customernumber),
foreign key (ordernumber) references orders (ordernumber),
Status varchar(15));
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

#b. Read through the orders table . If an order is cancelled, then put an entry in the cancellations table.

delimeter $$
CREATE PROCEDURE `cancelled_order`()
BEGIN
declare var_id int;
declare var_customernumber int;
declare var_ordernumber int;
declare var_status varchar(15) ;

declare cancelled_order cursor for select customernumber, ordernumber,status from orders;

open cancelled_order;
myloop: loop
fetch cancelled_order into var_customernumber,var_ordernumber, var_status;
if var_status='cancelled' then
insert into cancellations values (var_id, var_customernumber,var_ordernumber,var_status);
end if;
end loop;
close cancelled_order;
END $$
/*____________________________________________________________________________________________________________________________________________________________________*/

/* 3.a.Write function that takes the customernumber as input and returns the purchase_status based on the following criteria . [table:Payments]
 if the total purchase amount for the customer is < 25000 status = Silver, amount between 25000 and 50000, status = Gold
if amount > 50000 Platinum */

delimiter $$
CREATE FUNCTION `purchase_status`(cust_num bigint) RETURNS char(20) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE status_value CHAR(20);
    DECLARE total_amt numeric;
    SET total_amt = (select sum(Amount) from Payments where CustomerNumber = cust_num);

    IF (total_amt > 50000) THEN
        SET status_value = 'platinum';
    ELSEIF total_amt between 25000 and 50000 then
        set status_value='Gold';
	else
        SET status_value='silver';
	END IF;
    RETURN status_value;
END $$

select assignments.purchase_status(103);
/*---------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

#b. Write a query that displays customerNumber, customername and purchase_status from customers table.

select  customernumber,  customername, (select assignments.purchase_status(customernumber)) as Purchase_Status from customers;
/*____________________________________________________________________________________________________________________________________________________________________*/

/*4. Replicate the functionality of 'on delete cascade' and 'on update cascade' using triggers on movies and rentals tables. Note: Both tables - movies and rentals - 
don't have primary or foreign keys. Use only triggers to implement the above.*/

SELECT * FROM MOVIES;
SELECT * FROM RENTALS;

DELIMITER $$
CREATE TRIGGER trg_movies_update
AFTER DELETE ON movies
FOR EACH ROW
BEGIN
    UPDATE rentals
    SET movieid = id
    WHERE movieid = OLD.id ;
END;

DELIMITER $$
CREATE TRIGGER trg_movies_delete 
AFTER DELETE ON movies 
FOR EACH ROW 
BEGIN
    DELETE FROM  rentals
    WHERE movieid 
    NOT IN (SELECT DISTINCT id FROM movies);
END;
/*____________________________________________________________________________________________________________________________________________________________________*/

#5. Select the first name of the employee who gets the third highest salary. [table: employee]

select * from EMPLOYEE;
select first_name from `employee`
order by `salary` desc
limit 1 offset 2;
/*____________________________________________________________________________________________________________________________________________________________________*/

#6. Assign a rank to each employee  based on their salary. The person having the highest salary has rank 1. [table: employee]

SELECT first_name ,SALARY, row_number() OVER (order by salary desc) rownumber from employee;



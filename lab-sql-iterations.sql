-- 1;Write a query to find what is the total business done by each store.

SELECT 
    s.store_id, SUM(p.amount) AS total_business
FROM
    store s
        JOIN
    staff sf ON s.store_id = sf.store_id
        JOIN
    payment p ON sf.staff_id = p.staff_id
GROUP BY s.store_id;

-- 2;Convert the previous query into a stored procedure.

DELIMITER //

CREATE procedure TotalBusinessByStore(
in min_total int
)
Begin
SELECT 
    s.store_id, 
    SUM(p.amount) AS total_business
FROM
    store s
JOIN
    staff sf ON s.store_id = sf.store_id
JOIN
    payment p ON sf.staff_id = p.staff_id
GROUP BY 
    s.store_id
having
    total_business >= min_total;
end //

delimiter ;


-- 3;Convert the previous query into a stored procedure that takes the input for store_id
--  and displays the total sales for that store.

DELIMITER //

CREATE PROCEDURE TotalSalesByStore(
    IN store_id_param INT -- Input parameter for store_id
)
BEGIN
    SELECT 
        SUM(amount) AS total_sales
    FROM 
        payment
    WHERE 
        staff_id IN (SELECT staff_id FROM staff WHERE store_id = store_id_param);
END //

DELIMITER ;


-- 4;Update the previous query. Declare a variable total_sales_value of float type, 
-- that will store the returned result (of the total sales amount for the store). 
-- Call the stored procedure and print the results.

DROP PROCEDURE IF EXISTS TotalSalesByStore;

DELIMITER //

CREATE PROCEDURE TotalSalesByStore(
    IN store_id_param INT
)
BEGIN
    DECLARE total_sales_value FLOAT;
    
    SELECT 
        SUM(amount) INTO total_sales_value
    FROM 
        payment
    WHERE 
        staff_id IN (SELECT staff_id FROM staff WHERE store_id = store_id_param);
    
    SELECT total_sales_value AS total_sales;
END //

DELIMITER ;

CALL TotalSalesByStore(1);
CALL TotalSalesByStore(2);



-- 5;In the previous query, add another variable flag. If the total sales value for the
-- store is over 30.000, then label it as green_flag, otherwise label is as red_flag.
-- Update the stored procedure that takes an input as the store_id and returns total 
-- sales value for that store and flag value.

DELIMITER //

CREATE PROCEDURE TotalSalesByStoreWithFlag(
    IN store_id_value INT,
    OUT total_sales_value FLOAT,
    OUT flag VARCHAR(10)
)
BEGIN
    DECLARE total_sales FLOAT;

    SELECT SUM(amount)
    INTO total_sales
    FROM payment
    WHERE customer_id IN (
        SELECT customer_id
        FROM rental
        WHERE inventory_id IN (
            SELECT inventory_id
            FROM inventory
            WHERE store_id = store_id_value
        )
    );

    SET total_sales_value = total_sales;

    SET flag = CASE
        WHEN total_sales > 30000 THEN 'green_flag'
        ELSE 'red_flag'
    END;
END //

DELIMITER ;

CALL TotalSalesByStoreWithFlag(1, @total_sales_value, @flag);

SELECT @total_sales_value AS total_sales_value, @flag AS flag;


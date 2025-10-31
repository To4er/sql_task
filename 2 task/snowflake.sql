CREATE TABLE my_parameter_table(
    param1 date,
    param2 timestamp,
    param3 date
);

CREATE TABLE new_table(
    param1 date,
    param2 timestamp,
    param3 date
);

INSERT INTO my_parameter_table VALUES
('2025-02-06','2025-02-12 09:38:25.999982000','2025-01-28'),
('2025-02-14','2025-02-14 16:17:14.095384000','2025-02-06'),
('2025-02-20','2025-02-21 08:41:53.643244000','2025-02-14');

CREATE OR REPLACE PROCEDURE test_2(param1 date, param2 timestamp, param3 date)
RETURN NULL
LANGUAGE SQL
EXECUTE AS CALLER
AS
$$
BEGIN
    INSERT INTO new_table VALUES (:param1, :param2, :param3)
END;
$$;

EXECUTE IMMEDIATE $$
DECLARE
    c1 CURSOR FOR 
        SELECT param1, param2, param3
        FROM my_parameter_table
BEGIN
    FOR r IN c1 DO
        CALL test_2(r.param1, r.param2, r.param3);
    END FOR;
    
    RETURN 'Loop completed.';
END;
$$;

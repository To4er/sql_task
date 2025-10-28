EXECUTE IMMEDIATE $$
DECLARE
    c1 CURSOR FOR 
        SELECT param1, param2, param3
        FROM my_parameter_table
        WHERE some_condition = true;
BEGIN
    FOR r IN c1 DO
        CALL test_2(r.param1, r.param2, r.param3);
    END FOR;
    
    RETURN 'Loop completed.';
END;
$$;
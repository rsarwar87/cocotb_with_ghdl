LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- package declaration
PACKAGE types_pkg IS

    TYPE array_signed_t IS ARRAY (NATURAL RANGE <>) OF signed;

    FUNCTION from_array_signed_t(data : array_signed_t; nbit : NATURAL) RETURN signed;
    FUNCTION to_array_signed_t(data : signed; nbits : NATURAL; N : NATURAL) RETURN array_signed_t;
END PACKAGE types_pkg;
PACKAGE BODY types_pkg IS

    FUNCTION from_array_signed_t(data : array_signed_t; nbit : NATURAL) RETURN signed IS
        VARIABLE result : signed(data'length * nbit - 1 DOWNTO 0); -- Calculate the required size
    BEGIN
        FOR i IN data'RANGE LOOP
            result((i + 1) * nbit - 1 DOWNTO i * nbit) := data(i); -- Concatenate each element into the result
        END LOOP;
        RETURN result;
    END FUNCTION;

    FUNCTION to_array_signed_t(data : signed; nbits : NATURAL; N : NATURAL) RETURN array_signed_t IS
        VARIABLE result : array_signed_t(0 TO N - 1)(nbits - 1 DOWNTO 0);
    BEGIN
        FOR i IN result'RANGE LOOP
            result(i) := data((i + 1) * nbits - 1 DOWNTO i * nbits); -- Extract each 8-bit segment
        END LOOP;
        RETURN result;
    END FUNCTION;
END PACKAGE BODY;
-- functie care returneaza furnizorii care au aprovizionat o cafenea data ca parametru

CREATE OR REPLACE TYPE t_furn IS TABLE OF VARCHAR2(100);
/
CREATE OR REPLACE FUNCTION furnizori_cafenea(caf cafenea.cod_cafenea%TYPE)
RETURN t_furn
AS 
furnizori t_furn;
TYPE t_meniu IS TABLE OF meniu.id_produs%TYPE;
men t_meniu;
meniu_gol EXCEPTION;
cafenea_inexistenta EXCEPTION;
v_exists NUMBER;
BEGIN
    SELECT CASE WHEN EXISTS (SELECT 1 FROM cafenea WHERE cod_cafenea = caf) THEN 1 ELSE 0 END
    INTO v_exists
    FROM dual;

    IF v_exists = 0 THEN
        RAISE cafenea_inexistenta;
    END IF;
    
    SELECT id_produs
    BULK COLLECT INTO men
    FROM meniu
    WHERE cod_cafenea = caf;
    
    IF men.COUNT = 0 THEN
         RAISE meniu_gol;
    END IF;
    
    SELECT f.nume
    BULK COLLECT INTO furnizori
    FROM produs p, meniu m, furnizor f
    WHERE m.cod_cafenea = caf AND p.id_produs = m.id_produs AND p.cod_furnizor = f.cod_furnizor;
    
    RETURN furnizori;

EXCEPTION
    WHEN cafenea_inexistenta THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista cafeneaua data');
    WHEN meniu_gol THEN
        RAISE_APPLICATION_ERROR(-20002, 'La cafeneaua data nu se vinde niciun produs');
END furnizori_cafenea;
/
DECLARE
    furnizori t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 2;
    furnizori := furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/
DECLARE
    furnizori t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 7;
    furnizori := furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/

DECLARE
    furnizori t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 3;
    furnizori := furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/

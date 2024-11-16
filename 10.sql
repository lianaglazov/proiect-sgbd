-- trigger lmd la nivel de comanda
-- se declanseaza cand sunt inserate in tabela angajat mai mult de 15 linii

CREATE OR REPLACE TRIGGER max_promotii
BEFORE INSERT ON angajat
DECLARE 
nr INT;
BEGIN
    SELECT COUNT(*) 
    INTO nr 
    FROM angajat;
    IF nr > 15 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se pot angaja mai mult de 15 persoane');
    END IF;
END;
/
BEGIN
    FOR i IN 6..20 LOOP
        INSERT INTO angajat 
        VALUES(i, 'Popescu', 'Dan', '0746438749','1','1000',SYSDATE,NULL);
    END LOOP;
END;
/
select * from angajat;
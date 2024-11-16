-- trigger lmd la nivel de linie
-- cand se insereaza o comanda, se mareste cu 5% salariul angajatului care a preluat comanda

CREATE OR REPLACE TRIGGER marire_salariu
AFTER INSERT OR UPDATE ON comanda
FOR EACH ROW
DECLARE
v_salariu angajat.salariu%TYPE;
BEGIN
    SELECT salariu INTO v_salariu 
    FROM angajat 
    WHERE id_angajat = :NEW.id_angajat;
    
    DBMS_OUTPUT.PUT_LINE('Salariul angajatul cu id ' || :NEW.id_angajat || ' a crescut de la ' 
    || v_salariu || ' la ' || v_salariu * 1.05);
    UPDATE angajat 
    SET salariu = salariu * 1.05
    WHERE id_angajat = :NEW.id_angajat;
END;
/
INSERT INTO comanda 
VALUES(6,SYSDATE,1);

select salariu from angajat where id_angajat = 1;
rollback;

select * from comanda;
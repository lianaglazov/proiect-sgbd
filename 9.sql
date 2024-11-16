select * from cafenea;
select * from angajat;
select * from comanda;
select * from produse_comanda;
select * from produs;
select * from promotie;
select * from meniu;

-- se da o cafenea
-- daca la cafeneaua resp a fost data o comanda care include un produs care nu se afla in meniu,
-- produsul respectiv se adauga in meniu
-- in momentul update-ului se afiseaza denumirea produsului adaugat in meniu
-- select cu
-- meniu, angajat, comanda, produs, produse_comanda

SELECT p.id_produs
FROM angajat a, comanda c, produs p, produse_comanda pc
WHERE a.cod_cafenea = 4 AND
c.id_angajat = a.id_angajat AND c.nr_comanda = pc.nr_comanda
AND p.id_produs = pc.id_produs
GROUP BY p.id_produs;

SELECT p.id_produs 
FROM meniu m, angajat a, comanda c, produs p, produse_comanda pc
WHERE m.cod_cafenea = 4 AND a.cod_cafenea = 4 AND
c.id_angajat = a.id_angajat AND c.nr_comanda = pc.nr_comanda
AND p.id_produs = pc.id_produs AND p.id_produs = m.id_produs
GROUP BY p.id_produs;

CREATE OR REPLACE PROCEDURE update_meniu (caf cafenea.cod_cafenea%TYPE)
IS
    TYPE t_tabel_produse IS TABLE OF produs.id_produs%TYPE;
    tabel_produse t_tabel_produse;
    prod_meniu t_tabel_produse;
    denumire produs.denumire%TYPE;
    v_exists NUMBER;
    v_produse NUMBER;
    nu_vandut EXCEPTION;
    e_caf NUMBER;
BEGIN
    SELECT 1 INTO e_caf
    FROM cafenea
    WHERE cod_cafenea = caf;
    --cautam produsele comandate care apar in meniu
    SELECT p.id_produs BULK COLLECT INTO prod_meniu 
    FROM meniu m, angajat a, comanda c, produs p, produse_comanda pc
    WHERE m.cod_cafenea = caf AND a.cod_cafenea = caf AND
    c.id_angajat = a.id_angajat AND c.nr_comanda = pc.nr_comanda
    AND p.id_produs = pc.id_produs AND p.id_produs = m.id_produs
    GROUP BY p.id_produs;
    
    IF prod_meniu.COUNT = 0 THEN
        RAISE nu_vandut;
    END IF;
    
    -- scoatem toate produsele vandute in cafenea
    SELECT p.id_produs BULK COLLECT INTO tabel_produse
    FROM meniu m, angajat a, comanda c, produs p, produse_comanda pc
    WHERE m.cod_cafenea = caf AND a.cod_cafenea = caf AND
    c.id_angajat = a.id_angajat AND c.nr_comanda = pc.nr_comanda
    AND p.id_produs = pc.id_produs
    GROUP BY p.id_produs;
    v_produse :=0;
    --parcurgem tabelele; pt fiecare produs vandut, daca nu apare in meniu, il adaugam
    FOR i IN tabel_produse.FIRST..tabel_produse.LAST LOOP
        v_exists :=0;
        FOR j IN prod_meniu.FIRST..prod_meniu.LAST LOOP
            IF tabel_produse(i) = prod_meniu(j) THEN
                v_exists := 1;
            END IF;
        END LOOP;
        IF v_exists = 0 THEN
            v_produse := 1;
            INSERT INTO meniu (cod_cafenea, id_produs)
            VALUES(caf, tabel_produse(i));
            DBMS_OUTPUT.PUT_LINE('Produsul cu id ' || tabel_produse(i) || ' a fost adaugat in meniul cafenelei ' || caf);
        END IF;
        
    END LOOP;
    IF(v_produse = 0) THEN
        DBMS_OUTPUT.PUT_LINE('La cafeneaua ' || caf || ' nu s-a vandut niciun produs care nu apare in meniu');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Nu exista nicio cafenea cu codul dat');
    WHEN TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20002, '');
    WHEN nu_vandut THEN
        RAISE_APPLICATION_ERROR(-20003, 'La cafeneaua data nu s-a vandut niciun produs');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004,'Alta eroare!');
END;
/

BEGIN
update_meniu(5);
END;

/
ROLLBACK;



-- procedura care primeste ca parametru o denumire a unui produs si un id de cafenea
-- daca a fost vandut intr-o comanda din cafeneaua data adaugam produsul in meniul cafenelei

SELECT count(*)
FROM comanda c, angajat a, produse_comanda pc
WHERE a.cod_cafenea = 2 AND c.id_angajat = a.id_angajat 
AND c.nr_comanda = pc.nr_comanda AND pc.id_produs = 2;

CREATE OR REPLACE PROCEDURE adauga_meniu (prod produs.denumire%TYPE, caf cafenea.cod_cafenea%TYPE)
IS
    v_id_prod produs.id_produs%TYPE;
    TYPE t_tabel_produse IS TABLE OF produs.id_produs%TYPE;
    tabel_produse t_tabel_produse;
    prod_meniu t_tabel_produse;
    exista EXCEPTION;
    nu_vandut EXCEPTION;
    v_exista NUMBER;
    v_vandut NUMBER;
    e_caf NUMBER;
BEGIN
    --luam id-ul produsului dat
    SELECT id_produs INTO v_id_prod
    FROM produs
    WHERE denumire = prod;
    --verificam daca exista cafeneaua
    SELECT 1 INTO e_caf
    FROM cafenea
    WHERE cod_cafenea = caf;
    --verificam daca produsul a fost vandut la cafeneaua data
    SELECT count(*) INTO v_vandut
    FROM comanda c, angajat a, produse_comanda pc
    WHERE a.cod_cafenea = caf AND c.id_angajat = a.id_angajat 
    AND c.nr_comanda = pc.nr_comanda AND pc.id_produs = v_id_prod;
    
    IF v_vandut = 0 THEN
        RAISE nu_vandut;    
    END IF;
    
    --cautam produsele comandate care apar in meniu
    SELECT p.id_produs BULK COLLECT INTO prod_meniu 
    FROM meniu m, angajat a, comanda c, produs p, produse_comanda pc
    WHERE m.cod_cafenea = caf AND a.cod_cafenea = caf AND
    c.id_angajat = a.id_angajat AND c.nr_comanda = pc.nr_comanda
    AND p.id_produs = pc.id_produs AND p.id_produs = m.id_produs
    GROUP BY p.id_produs;
    
    --verificam daca produsul dat exista in meniul cafenelei, iar daca nu exista este adaugat
    v_exista := 0;
    FOR i IN prod_meniu.FIRST..prod_meniu.LAST LOOP
        IF v_id_prod = prod_meniu(i) THEN
                v_exista := 1;
            END IF;
    END LOOP;
    IF v_exista = 0 THEN
        INSERT INTO meniu (cod_cafenea, id_produs)
        VALUES(caf, v_id_prod);
        DBMS_OUTPUT.PUT_LINE('Produsul ' || prod || ' a fost adaugat in meniul cafenelei ' || caf);
    ELSE
        RAISE exista;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Produsul si/sau cafeneaua nu exista');
    WHEN TOO_MANY_ROWS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Sunt mai multe produse cu denumirea data');
    WHEN exista THEN
      RAISE_APPLICATION_ERROR(-20003, 'Produsul exista deja in meniul cafenelei');
    WHEN nu_vandut THEN
      RAISE_APPLICATION_ERROR(-20004, 'Produsul nu a fost vandut la cafeneaua data');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20005, 'Alta eroare');
END;
/

BEGIN
adauga_meniu('tiramisu',7);
END;
/
BEGIN
INSERT INTO PRODUS
VALUES(6,'tiramisu',10,10,2);
adauga_meniu('tiramisu',1);
END;
/
select * from produs;

BEGIN
adauga_meniu('fursec cu ciocolata',5);
END;
/
BEGIN
adauga_meniu('tiramisu',1);
END;
/
BEGIN
adauga_meniu('cafe latte',4);
END;
/
ROLLBACK;

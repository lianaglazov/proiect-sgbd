CREATE OR REPLACE PACKAGE pachet_proiect AS
    TYPE t_nr_comenzi IS TABLE OF NUMBER(4);
    PROCEDURE p_comenzi (nr_comenzi t_nr_comenzi);
    PROCEDURE produse_in_perioada(data_inceput DATE, data_sfarsit DATE);
    TYPE t_furn IS TABLE OF VARCHAR2(100);
    FUNCTION furnizori_cafenea(caf cafenea.cod_cafenea%TYPE)
    RETURN t_furn;
    PROCEDURE adauga_meniu (prod produs.denumire%TYPE, caf cafenea.cod_cafenea%TYPE);
END pachet_proiect;
/

CREATE OR REPLACE PACKAGE BODY pachet_proiect AS
--6
    PROCEDURE p_comenzi (nr_comenzi t_nr_comenzi)
    IS
    TYPE t_id_prod IS VARRAY(10) OF produs.id_produs%TYPE; --vector
    produse_in_comanda t_id_prod;
    detalii_comanda comanda%ROWTYPE;
    pret_total NUMBER;
    pret_curent produs.pret%TYPE;
    TYPE t_promo IS TABLE OF promotie%ROWTYPE INDEX BY PLS_INTEGER; --tabel indexat
    detalii_promotie t_promo;
    BEGIN
    FOR i in nr_comenzi.FIRST..nr_comenzi.LAST LOOP --parcurgerea comenzilor
        --se preiau detaliile comenzilor
        SELECT * 
        INTO detalii_comanda
        FROM comanda WHERE nr_comanda = nr_comenzi(i);
        --determinarea produselor dintr-o comanda
        SELECT pc.id_produs
        BULK COLLECT INTO  produse_in_comanda
        FROM produs p, produse_comanda pc
        WHERE p.id_produs = pc.id_produs AND pc.nr_comanda =  nr_comenzi(i);
        --se verifica pt fiecare produs daca este aplicata vreo promotie la data comenzii
        pret_total := 0;
        FOR j IN produse_in_comanda.FIRST..produse_in_comanda.LAST LOOP
            -- se selecteaza toate promotiile care au fost aplicate unui produs
            SELECT p.*
            BULK COLLECT INTO detalii_promotie
            FROM promotie p, promotii_produse pr
            WHERE pr.id_produs = produse_in_comanda(j) AND pr.id_promotie = p.id_promotie;
            
            SELECT pret
            INTO pret_curent
            FROM produs
            WHERE id_produs = produse_in_comanda(j);
            -- se parcurg promotiile si se verifica daca este una din ele activa la data comenzii curente
            -- si se adauga reducerea in acest caz
            FOR k IN detalii_promotie.FIRST..detalii_promotie.LAST LOOP
                IF detalii_comanda.data BETWEEN detalii_promotie(k).data_start AND detalii_promotie(k).data_fin THEN
                  pret_curent := pret_curent - ROUND(detalii_promotie(k).reducere/100 * pret_curent);
                END IF;
            END LOOP;
                pret_total := pret_total + pret_curent;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Comanda cu numarul ' || nr_comenzi(i) || ' costa ' || pret_total);
    END LOOP;
    
    END p_comenzi;
--7
    PROCEDURE produse_in_perioada(
      data_inceput DATE,
      data_sfarsit DATE
    )
    IS
    -- cursor care obtine toate comenzile într-o anumita perioada
        CURSOR c_com  IS
        SELECT *
        FROM comanda
        WHERE comanda.data BETWEEN data_inceput AND data_sfarsit;
    -- cursor care obtine produsele din fiecare comanda din primul cursos
        CURSOR c_prod_com (nr_com comanda.nr_comanda%TYPE) IS
        SELECT p.id_produs, p.denumire, 
        MIN(CASE
            WHEN c.data BETWEEN pr.data_start AND pr.data_fin THEN
                pret_promo_produs
            ELSE
                pret      
        END) AS pret_curent
        FROM produs p, promotie pr, promotii_produse prp, comanda c, produse_comanda pc
        WHERE p.id_produs = prp.id_produs AND pr.id_promotie = prp.id_promotie AND c.nr_comanda = nr_com
        AND pc.nr_comanda = c.nr_comanda AND pc.id_produs = p.id_produs
        GROUP BY p.id_produs, p.denumire;
    
        nr_com comanda.nr_comanda%TYPE;
        ang angajat%ROWTYPE;
    BEGIN
        FOR com IN c_com LOOP
            nr_com := com.nr_comanda;
            
            SELECT * INTO ang
            FROM angajat a
            WHERE com.id_angajat = a.id_angajat;
            
            FOR prod IN c_prod_com(nr_com) LOOP
                DBMS_OUTPUT.PUT_LINE('Produsul cu denumirea ' || prod.denumire || ' a fost cumparat la data de ' || com.data);
                DBMS_OUTPUT.PUT_LINE('intr-o comanda preluata de catre angajatul ' || ang.nume || ' ' || ang.prenume);
                DBMS_OUTPUT.PUT_LINE('la cafeneaua cu id-ul ' || ang.cod_cafenea || ' si a costat ' || prod.pret_curent || ' RON.');
                DBMS_OUTPUT.PUT_LINE('');
            END LOOP;
        END LOOP;
    END produse_in_perioada;
--8
    FUNCTION furnizori_cafenea(caf cafenea.cod_cafenea%TYPE)
    RETURN t_furn
    IS 
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
--9
    PROCEDURE adauga_meniu (prod produs.denumire%TYPE, caf cafenea.cod_cafenea%TYPE)
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
    END adauga_meniu;
END pachet_proiect;
/
--testare
EXECUTE proiect.p_comenzi(t_nr_comenzi(1,2,4));

EXECUTE pachet_proiect.produse_in_perioada('14-11-2023','29-11-2023');


DECLARE
    furnizori pachet_proiect.t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 2;
    furnizori := pachet_proiect.furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/
DECLARE
    furnizori pachet_proiect.t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 7;
    furnizori := pachet_proiect.furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/

DECLARE
    furnizori pachet_proiect.t_furn;
    id cafenea.cod_cafenea%TYPE;
BEGIN
    id := 3;
    furnizori := pachet_proiect.furnizori_cafenea(id);
    FOR i IN 1..furnizori.count LOOP
        DBMS_OUTPUT.PUT_LINE(furnizori(i));
    END LOOP;
END;
/
EXECUTE pachet_proiect.adauga_meniu('tiramisu',7);
EXECUTE pachet_proiect.adauga_meniu('fursec cu ciocolata',5);
EXECUTE pachet_proiect.adauga_meniu('tiramisu',1);
EXECUTE pachet_proiect.adauga_meniu('cafe latte',4);
EXECUTE pachet_proiect.adauga_meniu('tiramisu',7);

BEGIN
INSERT INTO PRODUS
VALUES(6,'tiramisu',10,10,2);
pachet_proiect.adauga_meniu('tiramisu',1);
END;
/

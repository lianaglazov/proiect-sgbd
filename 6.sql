-- procedura care primeste ca parametru o colectie de comenzi
-- pentru fiecare dintre comenzile respective se calculeaza pretul
-- pretul unei comenzi este suma tuturor produselor din comanda
-- unele produse se pot afla la reducere la data la care a fost data comanda 
-- daca este cazul reducerea se scade din pretul produsului

CREATE OR REPLACE TYPE t_nr_comenzi AS TABLE OF NUMBER(4); --tablou imbricat
/
CREATE OR REPLACE PROCEDURE p_comenzi (nr_comenzi t_nr_comenzi)
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
/
BEGIN
    p_comenzi(t_nr_comenzi(1,2,4));
END;
/
DROP PROCEDURE preturi_comenzi;
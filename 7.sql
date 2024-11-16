-- Generarea unui raport cu informa?ii despre produsele comandate într-o anumit? perioad?
-- afiseaza denumirea produsului, data la care a fost cumparat, pretul listat la acea data, cu reducerile aplicate
-- angajatul care a preluat comanda in care se afla produsul si cafeneaua 
select * from promotie;
select * from promotii_produse;
select * from produs;
select * from comanda;
select * from produse_comanda;
select * from cafenea;
select * from angajat;


    -- urmatorul select afiseaza un produs cu pretul sau in momentul unei comenzi date
    -- in cazul in care peste timp un produs a fost la mai multe promotii atunci acesta este afisat de mai multe ori
    -- pentru fiecare promotie aplicata in parte
    -- cu pretul curent fiind cel redus in cazul in care promotia era activa la data comenzii
    -- sau pretul normal in caz contrat
    -- se afiseaza pretul minim selectat pentru fiecare produs
    -- care este ori pretul standard in cazul in care nu a fost aplicata nicio reducere
    -- ori pretul cu reducerea corespunzatoare aplicata
    SELECT p.id_produs, p.denumire, 
    MIN(CASE
        WHEN c.data BETWEEN pr.data_start AND pr.data_fin THEN
            pret_promo_produs
        ELSE
            pret      
    END) AS pret_curent
    FROM produs p, promotie pr, promotii_produse prp, comanda c, produse_comanda pc
    WHERE p.id_produs = prp.id_produs AND pr.id_promotie = prp.id_promotie AND c.nr_comanda = 4
    AND pc.nr_comanda = c.nr_comanda AND pc.id_produs = p.id_produs
    GROUP BY p.id_produs, p.denumire;
/

CREATE OR REPLACE PROCEDURE produse_in_perioada(
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
/

BEGIN
    produse_in_perioada('14-11-2023','29-11-2023');
END;
/
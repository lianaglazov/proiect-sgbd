CREATE SEQUENCE promotie_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE cafenea_cod_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE furnizor_cod_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE angajat_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE comanda_nr_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE produs_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
    
DROP SEQUENCE promotie_id_seq;
DROP SEQUENCE cafenea_cod_seq;
DROP SEQUENCE furnizor_cod_seq;
DROP SEQUENCE angajat_id_seq;
DROP SEQUENCE comanda_nr_seq;
DROP SEQUENCE produs_id_seq;

DROP TABLE promotii_produse;
DROP TABLE produse_comanda;
DROP TABLE meniu;
DROP TABLE comanda;
DROP TABLE angajat;
DROP TABLE cafenea;
DROP TABLE produs;
DROP TABLE furnizor;
DROP TABLE promotie;


CREATE TABLE CAFENEA (  
    cod_cafenea NUMBER(5) PRIMARY KEY,  
    telefon VARCHAR2(10) NOT NULL,  
    adresa VARCHAR2(100) NOT NULL,  
    site VARCHAR2(100)
);

CREATE TABLE ANGAJAT (  
    id_angajat NUMBER(5) PRIMARY KEY,  
    nume VARCHAR2(50) NOT NULL, 
    prenume VARCHAR2(50) NOT NULL, 
    telefon VARCHAR2(10) NOT NULL, 
    cod_cafenea NUMBER(5) NOT NULL REFERENCES CAFENEA (cod_cafenea), 
    salariu NUMBER(4) NOT NULL, 
    data_angajarii DATE NOT NULL, 
    email VARCHAR2(40) 
);

CREATE TABLE COMANDA ( 
    nr_comanda NUMBER(4) PRIMARY KEY, 
    data DATE NOT NULL, 
    id_angajat NUMBER(5) NOT NULL REFERENCES ANGAJAT (id_angajat) 
);

CREATE TABLE FURNIZOR(
    cod_furnizor NUMBER(4) PRIMARY KEY,
    nume VARCHAR2(100) NOT NULL,
    telefon VARCHAR2(10) NOT NULL,
    adresa VARCHAR2(100) NOT NULL,
    email VARCHAR2(30)
);

CREATE TABLE PRODUS( 
    id_produs NUMBER(4) PRIMARY KEY, 
    denumire VARCHAR2(30) NOT NULL,
    pret NUMBER(3) NOT NULL, 
    stoc NUMBER(4), 
    cod_furnizor NUMBER(4) NOT NULL REFERENCES FURNIZOR (cod_furnizor)
);

CREATE TABLE PROMOTIE(
    id_promotie NUMBER(4) PRIMARY KEY,
    reducere NUMBER(3) NOT NULL,
    data_start DATE NOT NULL,
    data_fin DATE NOT NULL
);
CREATE TABLE PRODUSE_COMANDA(
    id_produs NUMBER(4) NOT NULL REFERENCES PRODUS(id_produs),
    nr_comanda NUMBER(4) NOT NULL REFERENCES COMANDA(nr_comanda)
);

CREATE TABLE MENIU (
    cod_cafenea NUMBER(5) NOT NULL REFERENCES CAFENEA(cod_cafenea), 
    id_produs NUMBER(4) NOT NULL REFERENCES PRODUS(id_produs)
);

CREATE TABLE PROMOTII_PRODUSE(
    id_promotie NUMBER(4) NOT NULL REFERENCES PROMOTIE(id_promotie),
    id_produs  NUMBER(4) NOT NULL REFERENCES PRODUS(id_produs),
    pret_promo_produs NUMBER(3)
);


INSERT INTO CAFENEA (cod_cafenea, telefon, adresa, site)
VALUES (cafenea_cod_seq.NEXTVAL, '0745638273', 'STR. MIHAI VITEAZU bl. 6, RADAUTI', NULL);

INSERT INTO CAFENEA (cod_cafenea, telefon, adresa, site)
VALUES (cafenea_cod_seq.NEXTVAL, '0764729387', 'STR. VLADIMIRESCU TUDOR nr. 28, VALCEA', 'cafeVAL.ce');

INSERT INTO CAFENEA (cod_cafenea, telefon, adresa, site)
VALUES (cafenea_cod_seq.NEXTVAL, '0764836274', 'BD. MOROIANU GEORGE nr. 27, SACELE', NULL);

INSERT INTO CAFENEA (cod_cafenea, telefon, adresa, site)
VALUES (cafenea_cod_seq.NEXTVAL, '0737847583', 'STR. 22 DECEMBRIE 1989 nr. 38, MURES', NULL);

INSERT INTO CAFENEA (cod_cafenea, telefon, adresa, site)
VALUES (cafenea_cod_seq.NEXTVAL, '0758493849', 'STR. CUZA I. AL. nr. 42, DOLJ', NULL);

SELECT * FROM cafenea;

INSERT INTO ANGAJAT (id_angajat, nume, prenume, telefon, cod_cafenea, salariu, data_angajarii, email)
VALUES (angajat_id_seq.NEXTVAL, 'Mironescu', 'Sorina', '0764839478', '1', '2780', DATE '2021-08-23', NULL);

INSERT INTO ANGAJAT (id_angajat, nume, prenume, telefon, cod_cafenea, salariu, data_angajarii, email)
VALUES (angajat_id_seq.NEXTVAL, 'Silivasi', 'Claudia', '0763787489', '3', '4500', DATE '2017-03-02', NULL);

INSERT INTO ANGAJAT (id_angajat, nume, prenume, telefon, cod_cafenea, salariu, data_angajarii, email)
VALUES (angajat_id_seq.NEXTVAL, 'Petran', 'Gheorghe', '0765748930', '4', '2900', DATE '2021-07-09', 'ghegheor_ptrn@gmail.com');

INSERT INTO ANGAJAT (id_angajat, nume, prenume, telefon, cod_cafenea, salariu, data_angajarii, email)
VALUES (angajat_id_seq.NEXTVAL, 'Blaga', 'Constanta', '0754637893', '5', '3480', DATE '2020-01-26', NULL);

INSERT INTO ANGAJAT (id_angajat, nume, prenume, telefon, cod_cafenea, salariu, data_angajarii, email)
VALUES (angajat_id_seq.NEXTVAL, 'Popa', 'Raul', '0765789487', '4', '3120', DATE '2019-12-03', NULL);

SELECT * FROM angajat;

INSERT INTO COMANDA (nr_comanda,data,id_angajat)
VALUES (comanda_nr_seq.NEXTVAL, DATE '2023-11-10', '2');

INSERT INTO COMANDA (nr_comanda, data, id_angajat)
VALUES (comanda_nr_seq.NEXTVAL, DATE '2023-11-29','2');

INSERT INTO COMANDA (nr_comanda, data,id_angajat)
VALUES (comanda_nr_seq.NEXTVAL, DATE '2023-11-21','4');

INSERT INTO COMANDA (nr_comanda, data,id_angajat)
VALUES (comanda_nr_seq.NEXTVAL,  DATE '2023-11-19', '3');

INSERT INTO COMANDA (nr_comanda,data, id_angajat)
VALUES (comanda_nr_seq.NEXTVAL, DATE '2023-11-13', '3');

SELECT * FROM comanda;

INSERT INTO FURNIZOR (cod_furnizor, nume, telefon, adresa, email)
VALUES (furnizor_cod_seq.NEXTVAL, 'Magazinul cu Produse', '0748374657', 'STR. PATULEA, ING. nr. 4B, BUCURESTI SECTOR 1', NULL);

INSERT INTO FURNIZOR (cod_furnizor, nume, telefon, adresa, email)
VALUES (furnizor_cod_seq.NEXTVAL, 'La Cafele', '0748392749', 'STR. VLADIMIRESCU T. nr. 30A, CONSTANTA', 'lacafe@gmail.com');

INSERT INTO FURNIZOR (cod_furnizor, nume, telefon, adresa, email)
VALUES (furnizor_cod_seq.NEXTVAL, 'De Toate', '0728398476', 'Strada 22 Decembrie 31, Zalau', NULL);

INSERT INTO FURNIZOR (cod_furnizor, nume, telefon, adresa, email)
VALUES (furnizor_cod_seq.NEXTVAL, 'ADCF', '0798476387', 'STR. CASTELULUI nr. 110 ap. 2, BRASOV', NULL);

INSERT INTO FURNIZOR (cod_furnizor, nume, telefon, adresa, email)
VALUES (furnizor_cod_seq.NEXTVAL, 'MAJI PRAJI', '0764738476', 'STR. OVAZULUI nr. 10, SIBIU', 'maji_praji@yahoo.com');

SELECT * FROM furnizor;

INSERT INTO PRODUS (id_produs,denumire, pret, stoc, cod_furnizor)
VALUES (produs_id_seq.NEXTVAL, 'cafe latte', '15', '100', '1');

INSERT INTO PRODUS (id_produs,denumire, pret, stoc, cod_furnizor)
VALUES (produs_id_seq.NEXTVAL, 'fursec cu ciocolata' ,'5', '29', '1');

INSERT INTO PRODUS (id_produs,denumire, pret, stoc, cod_furnizor)
VALUES (produs_id_seq.NEXTVAL, 'tiramisu', '20', '45', '2');

INSERT INTO PRODUS (id_produs,denumire, pret, stoc, cod_furnizor)
VALUES (produs_id_seq.NEXTVAL, 'cappuccino','10', '140','3');

INSERT INTO PRODUS (id_produs,denumire, pret, stoc, cod_furnizor)
VALUES (produs_id_seq.NEXTVAL, 'milkshake' ,'19', '15','5');

SELECT * FROM produs;

INSERT INTO PROMOTIE(id_promotie, reducere, data_start,data_fin)
VALUES(promotie_id_seq.NEXTVAL,'20',DATE '2023-11-24',DATE '2023-11-29');

INSERT INTO PROMOTIE(id_promotie, reducere, data_start,data_fin)
VALUES(promotie_id_seq.NEXTVAL,'15',DATE '2023-11-12',DATE '2023-11-23');

INSERT INTO PROMOTIE(id_promotie, reducere, data_start,data_fin)
VALUES(promotie_id_seq.NEXTVAL,'10',DATE '2023-11-30',DATE '2023-12-02');

INSERT INTO PROMOTIE(id_promotie, reducere, data_start,data_fin)
VALUES(promotie_id_seq.NEXTVAL,'25',DATE '2023-12-06',DATE '2023-12-24');

INSERT INTO PROMOTIE(id_promotie, reducere, data_start,data_fin)
VALUES(promotie_id_seq.NEXTVAL,'5',DATE '2023-11-07',DATE '2023-11-10');

SELECT * FROM promotie;

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('2','3');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('2','5');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('2','4');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('3','1');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('4','2');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('4','5');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('1','5');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('1','4');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('1','2');

INSERT INTO PRODUSE_COMANDA(id_produs, nr_comanda)
VALUES ('2','1');

SELECT * FROM produse_comanda;

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('1','2');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('1','5');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('1','3');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('4','3');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('4','4');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('5','2');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('5','5');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('2','4');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('2','3');

INSERT INTO MENIU(cod_cafenea, id_produs)
VALUES ('2','2');

select * from meniu;

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('1','2','17');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('1','1','16');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('1','4','15');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('2','2','7');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('2','5','9');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('3','2','16');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('4','2','4');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('5','3','12');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('5','4','11');

INSERT INTO PROMOTII_PRODUSE(id_produs,id_promotie,pret_promo_produs)
VALUES('5','5','14');

SELECT * FROM PROMOTII_PRODUSE;



-- trigger ldd 
-- se afiseaza un mesaj corespunzator atunci cand se adauga, altereaza sau sterge un tabel

CREATE OR REPLACE TRIGGER schimbare
AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
    v_nume_tabel VARCHAR2(50);
BEGIN
    v_nume_tabel := SYS.DICTIONARY_OBJ_NAME;
     IF SYS.SYSEVENT = 'CREATE' THEN
         DBMS_OUTPUT.PUT_LINE('Utilizatorul ' || SYS.LOGIN_USER || ' a creat obiectul ' ||
         v_nume_tabel ||' de tip ' || SYS.DICTIONARY_OBJ_TYPE);
     ELSIF SYS.SYSEVENT = 'ALTER' THEN
        DBMS_OUTPUT.PUT_LINE('Utilizatorul ' || SYS.LOGIN_USER || ' a modificat obiectul ' ||
        v_nume_tabel ||' de tip ' || SYS.DICTIONARY_OBJ_TYPE);
     ELSIF SYS.SYSEVENT = 'DROP' THEN
        DBMS_OUTPUT.PUT_LINE('Utilizatorul ' || SYS.LOGIN_USER || ' a sters obiectul ' ||
        v_nume_tabel ||' de tip ' || SYS.DICTIONARY_OBJ_TYPE);
    END IF;       
END schimbare;
/

CREATE TABLE TEST(ID NUMBER);
ALTER TABLE TEST ADD (NR NUMBER);
DROP TABLE TEST;
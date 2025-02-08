--1)Procedura utilizzata per la creazione di un ordine nel quale successivamente potranno essere inserite licenze_articolo
CREATE OR REPLACE PROCEDURE PROCEDURE_CREA_Carrello(Email VARCHAR2)
IS
Chiave    ORDINE.COD_ORD%type;
Pagamenti_mancanti    exception;
N_Pag     Number;
Codex    Number;
BEGIN
Codex:=1;
--All'inizio della procedura viene generata una chiave da utilizzare come codice dell'ordine che sta per essere creato.
--La chiave viene generata randomicamente. Qualora quest'ultima risulti uguale ad una chiave già esistente, essa viene rigenerata.
 WHILE (Codex <> 0) LOOP
    SELECT to_char(FLOOR(dbms_random.value*(9999999999-1000000000)+1000000000)) INTO CHIAVE from dual;
    SELECT COUNT(*) INTO Codex FROM ORDINE WHERE Cod_ord=Chiave;
  END LOOP;
INSERT INTO ORDINE (Cod_ord, F2_emcliente) VALUES (Chiave, Email);

--Si controlla che il cliente possieda almeno una modalità di pagamento registrata
SELECT count(*)  INTO N_Pag FROM MODALITA_PAGAMENTO WHERE F1_emclie=Email;
IF  N_Pag=0 THEN
    raise Pagamenti_mancanti;
END IF;
EXCEPTION
WHEN Pagamenti_mancanti THEN
    raise_application_error(-20020,'Il cliente non possiede alcuna modalita di pagamento');
END;
/

--2)Procedura che aggiunge la licenza di un dato software ad un dato ordine
CREATE OR REPLACE PROCEDURE PROCEDURE_AGGIUNGI_Articolo(Nome_soft VARCHAR2, Vers_Soft VARCHAR2, Nome_az VARCHAR2, Codice_ord CHAR)
IS
Troppo_giovane exception;
Eta Number(3,0);
Anni18    PRODOTTO_SOFTWARE.PIU18%type;
Em        Account.email%type;
Cod_art      Licenza_articolo.cod_licenza%type;
N_articoli  number(3,0);
Prezzo_totale    Ordine.Totale_ordine%type;
Nessun_articolo exception;
Ordine_chiuso    exception;
BEGIN

--L'ordine viene considerato chiuso nel momento in cui il suo prezzo sia già stato fissato.
--Motivo per cui viene effettuato un controllo all'inizio per vedere attraverso il prezzo se l'ordine è già stato chiuso.
--Qualora quest'ultimo sia già stato chiuso, viene impedito all'utente di aggiungervi licenze

SELECT Totale_ordine INTO Prezzo_totale FROM ORDINE WHERE Cod_ord=Codice_ord;
if(Prezzo_totale is not null) THEN
    raise Ordine_chiuso;
end if;

-- Controllo che qualora l'ordine risulti vietato ai minori di 18 anni l'utente che lo acquista sia maggiorenne
SELECT PIU18 INTO Anni18 FROM PRODOTTO_SOFTWARE WHERE nome_software=Nome_soft AND versione_software=Vers_Soft AND PF1_nomeaz=Nome_az;
  
SELECT F2_emcliente INTO Em FROM ORDINE  WHERE Cod_ord=Codice_ord;
  
SELECT FLOOR((SYSDATE-Data_nascita)/365) INTO Eta FROM ACCOUNT WHERE Email = em;

IF(Anni18='S' and ETA<18) THEN
    raise Troppo_giovane;
END IF;

--Controllo che esistano licenze per il prodotto software preso in input
select COUNT(*) INTO N_ARTICOLI from licenza_articolo where f1_codord IS NULL AND PF5_NSOFT=Nome_soft AND PF5_VSOFT=Vers_Soft AND PF3_nomeaz=Nome_az;

IF (N_ARTICOLI=0) THEN
    RAISE Nessun_articolo;
END IF;

SELECT Cod_licenza INTO Cod_art FROM LICENZA_ARTICOLO WHERE PF5_nsoft=Nome_soft AND PF5_vsoft=Vers_Soft AND PF3_nomeaz=Nome_az AND F1_codord IS NULL 
AND rownum=1;

UPDATE LICENZA_ARTICOLO SET F1_CODORD=Codice_ord WHERE Cod_licenza=Cod_art AND PF5_nsoft=Nome_soft AND PF5_vsoft=Vers_Soft AND PF3_nomeaz=Nome_az;
  
EXCEPTION
WHEN Troppo_giovane THEN
    raise_application_error(-20022,'Il seguente articolo non può essere ordinato dal utente essendo riservato ai maggiorenni');
WHEN Ordine_chiuso THEN
    raise_application_error(-20023,'Impossibile aggiungere articoli al seguente ordine essendo un ordine già chiuso');
WHEN Nessun_articolo THEN
    raise_application_error(-20024,'Non vi sono articoli disponibili per il prodotto selezionato al momento');
END;
/

--3)Procedura per la chiusura di un carrello
CREATE OR REPLACE PROCEDURE PROCEDURE_CHIUDI_Carrello(Codice_ordine char,Mod_pag char)
IS
PREZZO_ORDINE ORDINE.TOTALE_ORDINE%TYPE;
ORD_TOTALE    ORDINE.TOTALE_ORDINE%TYPE;
ORDINE_CHIUSO     exception;
PREZZI_NON_SCONTATI NUMBER;
N_mod        NUMBER;
Mod_assente    exception;
Ordine_vuoto exception;
n_licenze    NUMBER;
BEGIN
--Viene controllato attraverso il totale dell'ordine che quest'ultimo non sia già stato chiuso in precedenza
SELECT TOTALE_ORDINE INTO ORD_TOTALE FROM ORDINE WHERE Cod_ord=Codice_ordine;

IF (Ord_totale is not null) THEN
    raise ordine_chiuso;
END IF;
--Viene controllato che il cliente sia associato alla modalità di pagamento che vuole utilizzare
SELECT count(*) INTO N_mod from Ordine JOIN Cliente on F2_emcliente=PF1_emcliente JOIN MODALITA_PAGAMENTO on PF1_emcliente=F1_emclie 
WHERE Cod_ord=Codice_ordine AND Mod_pagamento=Mod_pag;

IF(N_MOD = 0) THEN
    raise Mod_assente;
END IF;
--Viene controllato che l'ordine che si vuole chiudere non sia un ordine vuoto

SELECT count(*) INTO N_licenze FROM LICENZA_ARTICOLO WHERE F1_codord=CODICE_ORDINE;

If(n_licenze=0) THEN
    raise Ordine_vuoto;
END IF;
 
--GESTIONE DEL TOTALE_ORDINE 
 
 --Si calcola la somma dei prezzi di tutte le licenze che non riguardano prodotti in offerta (licenze-licenze scontate)
SELECT SUM(PREZZO_LICENZA) INTO PREZZI_NON_SCONTATI FROM(
(SELECT COD_LICENZA,PF5_NSOFT,PF5_VSOFT,PF3_NOMEAZ,PREZZO_LICENZA FROM LICENZA_ARTICOLO WHERE F1_CODORD=CODICE_ORDINE)
MINUS
(SELECT COD_LICENZA,PF5_NSOFT,PF5_VSOFT,PF3_NOMEAZ,PREZZO_LICENZA FROM LICENZE_SCONTATE WHERE F1_CODORD=CODICE_ORDINE)
);

--Si calcola la somma dei prezzi scontati delle licenze riguardanti i prodotti in offerta

SELECT SUM(Prezzo_licenza*(1-Percentuale_sconto/100)) INTO Prezzo_ordine FROM Licenze_scontate where F1_codord=Codice_ordine;

IF PREZZO_ORDINE IS NULL THEN
PREZZO_ORDINE:=0;
END IF;

IF PREZZI_NON_SCONTATI IS NULL THEN
PREZZI_NON_SCONTATI:=0;
END IF;

--Viene aggiornato il totale dell'ordine sommando il totale tra i prezzi scontati e quelli non scontati, inoltre si pone la data di creazione
--dell'ordine alla data attuale di sistema e si registra la modalità di pagamento.

UPDATE ORDINE SET TOTALE_ORDINE=PREZZO_ORDINE+PREZZI_NON_SCONTATI,DATA_ORDINE=SYSDATE, Mod_pagamento_scelto=Mod_pag WHERE Cod_ord=Codice_ordine;

EXCEPTION
WHEN Ordine_chiuso THEN
    raise_application_error(-20025,'L ordine selezionato è già stato chiuso');
WHEN Mod_assente THEN
    raise_application_error(-20026,'La modalità di pagamento utilizzata non è registrata all account');
WHEN Ordine_vuoto THEN
    raise_application_error(-20027,'Impossibile chiudere un ordine privo di articoli');
END;
/


--4)Procedura riservata ai clienti premium che permette di rimuovere un intero carrello
CREATE OR REPLACE PROCEDURE PROCEDURE_RIMUOVI_Carrello(Codice_ord char)
IS
Em CLIENTE.PF1_emcliente%type;
Tipo    CLIENTE.Tipologia_cliente%type;
Tipo_sbagliato    exception;
Price    ORDINE.TOTALE_ORDINE%TYPE;
Closed_order exception;
BEGIN

SELECT F2_emcliente INTO Em FROM ORDINE WHERE Cod_ord=Codice_ord;

--Viene controllato che il cliente che proprietario dell'ordine non sia di tipo standard
Select Tipologia_cliente INTO Tipo FROM CLIENTE WHERE PF1_emcliente=Em;

IF Tipo='Standard' THEN
    Raise Tipo_sbagliato;
END IF;

--Viene controllato che l'ordine che si vuole rimuovere non sia già stato chiuso
Select Totale_ordine INTO Price FROM ORDINE WHERE Cod_ord=Codice_ord;

IF Price is not null THEN
    Raise Closed_order;
END IF;

UPDATE LICENZA_ARTICOLO SET F1_codord = null WHERE F1_codord=Codice_ord;

EXCEPTION
WHEN Tipo_sbagliato THEN
    raise_application_error(-20029,'Agli utenti di tipo standard non è concesso rimuovere ordini');
WHEN Closed_order THEN
    raise_application_error(-20030,'Impossibile cancellare un ordine già chiuso');
END;
/


--Procedura che assegna un gruppo assistenza ad una data richiesta di supporto in base al tipo di problema esposto
CREATE OR REPLACE PROCEDURE PROCEDURE_Gestione_Richieste(Num_richiesta Varchar)
IS
Tipo_problema GRUPPO_ASSISTENZA.CATEGORIA%type;
name_gruppo GRUPPO_ASSISTENZA.Nome_Gruppo%type;
cat RICHIESTA_DI_SUPPORTO.Categoria_problema%type;
ric RICHIESTA_DI_SUPPORTO.N_RICHIESTA%TYPE;
Nessuna_richiesta    exception;
BEGIN

--Viene controllato che la richiesta esista e non sia ancora stata associata ad alcun gruppo assistenza 

SELECT N_RICHIESTA INTO RIC FROM RICHIESTA_DI_SUPPORTO WHERE N_RICHIESTA=NUM_RICHIESTA AND F2_NOMEGRUPPO IS NULL;

IF RIC IS NULL THEN 
    Raise Nessuna_richiesta;
END IF;

--La richiesta di supporto viene associata al gruppo assistenza che si occupa della sua categoria di problema
--E che risulta gestire il minor numero di richieste in quel momento
Select Categoria_problema into cat FROM RICHIESTA_DI_SUPPORTO WHERE N_richiesta=num_richiesta;

SELECT Nome_gruppo into name_gruppo FROM GRUPPO_ASSISTENZA g1 WHERE Categoria=cat AND Rownum=1 
ORDER BY (SELECT COUNT (*) FROM RICHIESTA_DI_SUPPORTO WHERE F2_NOMEGRUPPO=g1.nome_gruppo) DESC;

UPDATE RICHIESTA_DI_SUPPORTO SET F2_NOMEGRUPPO=Name_gruppo where N_richiesta=Num_richiesta;

EXCEPTION
WHEN Nessuna_richiesta THEN
    raise_application_error(-20031, 'Richiesta di supporto inesistente o già gestita');
END;
/

--Procedura per gestire un offerta ed associarvi dei prodotti in base a quali sono quelli meno venduti
CREATE OR REPLACE PROCEDURE PROCEDURE_Gestione_Offerta(Offer varchar2)
IS
Nessun_valore exception;
N_prodotti Number;
Offerta_non_attiva exception;
Ini Offerta.Inizio_Offerta%type;
Fin Offerta.Fine_Offerta%type;
BEGIN

--Viene controllato se l'offerta selezionata è al momento attiva
SELECT Inizio_offerta,Fine_Offerta INTO Ini, Fin FROM OFFERTA WHERE Id_offerta=Offer;

IF (sysdate<Ini or sysdate>Fin) THEN
	raise Offerta_non_attiva;
END IF;

--Viene segnalato un errore nel momento in cui si verifica che tutti prodotti software siano associati ad un'offerta
Select count(*) INTO N_prodotti FROM CLASSIFICA_Prodotto_Software WHERE PF1_IDOFFERTA IS NULL;

IF (N_prodotti=0) THEN
    Raise Nessun_valore;
END IF;

--Vengono selezionati i 10 prodotti meno venduti dalla vista 'CLASSIFICA_Prodotto_Software' e vengono associati all'offerta presa in input 

INSERT INTO HA (PF2_nsoft,PF2_vsoft,PF1_Idofferta,PF2_nomeaz) Select Nome_software,Versione_Software,Offer,PF1_Nomeaz
 FROM CLASSIFICA_Prodotto_Software where PF1_IDOFFERTA IS NULL
 ORDER BY NUMERO_VENDITE DESC
FETCH FIRST 10 ROWS ONLY;

EXCEPTION
WHEN Nessun_valore THEN
    raise_application_error(-20033,'Tutti i prodotti software sono attualmente in offerta');
	
WHEN Offerta_Non_Attiva THEN
	raise_application_error(-20090,'Offerta attualmente non in vigore');
END;
/



-- Procedura che permette la rimozione di un articolo da un ordine
CREATE OR REPLACE PROCEDURE PROCEDURE_RIMUOVI_Articolo(Codice_art char,Nsoft varchar2,Vsoft varchar2,Naz varchar2)
IS
Codice    ORDINE.cod_ord%type;
Prezzo    Ordine.TOTALE_ORDINE%type;
Invalid_order    exception;
BEGIN

SELECT F1_codord INTO Codice FROM LICENZA_ARTICOLO WHERE Cod_licenza=Codice_art AND PF5_nsoft=Nsoft AND PF5_vsoft=Vsoft AND PF3_nomeaz=Naz; 

--Viene controllato che l'articolo che si vuole rimuovere non faccia parte di un ordine già chiuso

SELECT TOTALE_ORDINE INTO Prezzo FROM ORDINE WHERE Cod_ord=Codice;

IF(Prezzo is not null) THEN
    raise Invalid_order;
END IF;

UPDATE LICENZA_ARTICOLO SET F1_codord = NULL WHERE Cod_licenza=Codice_art AND PF5_nsoft=Nsoft AND PF5_vsoft=Vsoft AND PF3_nomeaz=Naz;

EXCEPTION
WHEN Invalid_order THEN
    raise_application_error(-20028,'Impossibile rimuovere articolo da un ordine già chiuso');
END;
/
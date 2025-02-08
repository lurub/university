-- TRIGGER CHE IMPEDISCE ALL'UTENTE DI AGGIORNARE LA PASSWORD IMMETTENDO QUELLA PRECEDENTE
CREATE OR REPLACE TRIGGER TRIGGER_PWD
BEFORE UPDATE of pwd on ACCOUNT
FOR EACH ROW
DECLARE
pass_ridondante  exception;
BEGIN

IF :old.pwd = :new.pwd THEN
    raise pass_ridondante;
END IF;

EXCEPTION
    WHEN pass_ridondante THEN
    raise_application_error (-20001,'La password inserita è uguale a quella vecchia');
END;
/

--LIMITA IL NUMERO DI LICENZE ALL'INTERNO DI OGNI ORDINE AD UN MASSIMO DI 100
CREATE OR REPLACE TRIGGER TRIGGER_MAX_Articoli
BEFORE INSERT ON LICENZA_ARTICOLO
FOR EACH ROW
DECLARE
n_articoli            Number(3,0);
troppi_articoli        exception;
BEGIN

SELECT COUNT(*) INTO n_articoli FROM LICENZA_ARTICOLO 
WHERE  :new.F1_CODORD IS NOT NULL AND F1_CODORD= :new.F1_CODORD; --Conteggio licenze per un dato ordine

IF n_articoli >100 THEN
    RAISE troppi_articoli;
END IF;

EXCEPTION
WHEN troppi_articoli THEN
    raise_application_error(-20002,'Il numero di articoli inseriti in un solo ordine eccede il limite consentito (100)');
END;   
/

--Trigger che limita il numero di wishlist creabili a 5 per un utente standard e a 10 per un utente premium
CREATE OR REPLACE TRIGGER TRIGGER_MAX_Nwish
BEFORE INSERT ON WISHLIST
FOR EACH ROW
DECLARE
cont_wish    number(2,0);
troppe_wish    exception;
tipo_cliente VARCHAR2(8);
BEGIN

SELECT tipologia_cliente INTO tipo_cliente FROM CLIENTE WHERE PF1_emcliente= :new.PF3_emcliente; -- ricerca tipo cliente

SELECT count(*) INTO cont_wish FROM WISHLIST WHERE PF3_emcliente = :new.PF3_emcliente; --conta le wishlist del cliete

IF tipo_cliente='Standard' AND cont_wish>5 THEN
    raise troppe_wish;
end if;

IF tipo_cliente='Premium' AND cont_wish>10 THEN
    raise troppe_wish; 
end if;
	
EXCEPTION
WHEN troppe_wish THEN
    raise_application_error(-20003,'Il numero di Wishlist inserite supera i limiti consentiti dalla tipologia del cliente');
END;
/

--Trigger che limita a 100 il prezzo massimo al quale si può vendere una licenza articolo per un venditore di tipo standard
CREATE OR REPLACE TRIGGER TRIGGER_MAX_Prezzo    
BEFORE INSERT ON LICENZA_ARTICOLO
FOR EACH ROW
DECLARE
prezzo_alto    exception;
tipo_vend VARCHAR2(13);
BEGIN

SELECT tipologia_venditore INTO tipo_vend 
FROM VENDITORE WHERE PF1_emvend = :new.F2_emvend; --controllo tipo venditoere

IF tipo_vend='Standard' AND :new.prezzo_licenza>100 THEN
    raise prezzo_alto;
END IF;

EXCEPTION
WHEN prezzo_alto THEN
    raise_application_error(-20004,'Il prezzo della licenza supera i limiti consentiti ad un venditore di tipo standard');
END;
/

--Trigger che limita a 10 le richieste di supporto effettuabili da un venditore
CREATE OR REPLACE TRIGGER TRIGGER_RDS_VEND
BEFORE INSERT ON RDS_VEND
FOR EACH ROW
DECLARE
cont_vend number(2,0);
troppe_richieste exception;
BEGIN
SELECT count(*) into cont_vend FROM RDS_VEND
WHERE F1_emvend = :new.F1_emvend; -- Conteggio richieste correlate al venditore
IF cont_vend>=10 THEN
    raise troppe_richieste;
END IF;
EXCEPTION
WHEN troppe_richieste THEN
    raise_application_error(-20005,'Il venditore ha effettuato troppe richieste di supporto');
END;
/


--Trigger che limita a 10 il numero di pubblicità presenti in un catalogo
CREATE OR REPLACE TRIGGER TRIGGER_MAX_Pubbl
BEFORE INSERT ON POSSIEDE
FOR EACH ROW
DECLARE
n_pubbl  number(2,0);
troppe_pubbl  exception;
BEGIN

SELECT count(*) INTO n_pubbl FROM POSSIEDE 
WHERE PF1_Nomecat= :new.PF1_Nomecat; -- Conteggio pubblicità correlate al catalogo

IF n_pubbl>=10 THEN
    raise troppe_pubbl;
END IF;

EXCEPTION
WHEN troppe_pubbl THEN
    raise_application_error(-20006,'Il catalogo possiede troppe pubblicita');
END;
/


--Trigger che limita a 20 il numero di richieste di supporto gestibili da ciascun gruppo assistenza
CREATE OR REPLACE TRIGGER TRIGGER_MAX_Richieste
BEFORE INSERT ON RICHIESTA_DI_SUPPORTO
FOR EACH ROW
DECLARE
n_rich  number(2,0);
troppe_rich  exception;
BEGIN

SELECT count(*) INTO n_rich FROM RICHIESTA_DI_SUPPORTO 
WHERE F2_nomegruppo= :new.F2_nomegruppo;-- Conteggio richieste di supporto gestite dal gruppo assistenza

IF n_rich>20 THEN
    raise troppe_rich;
END IF;

EXCEPTION
WHEN troppe_rich THEN
    raise_application_error(-20007,'Il gruppo assistenza può gestire massimo 20 richieste');
END;
/

--Trigger per il controllo della coerenza tra il discriminante di cliente e l'entità
CREATE OR REPLACE TRIGGER TRIGGER_DISCR_Cliente
BEFORE INSERT ON CLIENTE
FOR EACH ROW 
DECLARE
Discr    char(1);
Discr_sbagliato_C    exception;
BEGIN

SELECT C_V INTO Discr FROM    ACCOUNT
WHERE     Email= :new.PF1_emcliente; --ricerca discriminante

IF    Discr='V'    THEN
    raise Discr_sbagliato_C;
END IF;

EXCEPTION
WHEN Discr_sbagliato_C THEN
    raise_application_error(-20008,'Impossibile inserire un email di un venditore come email di un cliente (Discriminante = V)');
END;
/

--Trigger per il controllo della coerenza tra il discriminante di venditore e l'entità
CREATE OR REPLACE TRIGGER TRIGGER_DISCR_Venditore
BEFORE INSERT ON VENDITORE
FOR EACH ROW 
DECLARE
Discr    char(1);
Discr_sbagliato_V exception;
BEGIN
SELECT C_V INTO Discr FROM ACCOUNT
WHERE Email= :new.PF1_emvend; --ricerca discriminante

IF Discr='C' THEN
    raise Discr_sbagliato_V;
END IF;

EXCEPTION
WHEN Discr_sbagliato_V THEN
    raise_application_error(-20009,'Incongruenza tra tipo di Account (Venditore) e discriminante');
END;
/

--Trigger per il controllo della coerenza tra il discriminante di RDS_art e l'entità
CREATE OR REPLACE TRIGGER TRIGGER_Discr_RDS_ART
BEFORE INSERT ON RDS_ART
FOR EACH ROW
DECLARE
Discr  char(1);
Errore_Discr exception;
BEGIN

SELECT V_A INTO Discr FROM RICHIESTA_DI_SUPPORTO
WHERE N_Richiesta= :new.PF1_licart; --ricerca discriminante

IF Discr='V' THEN
	raise Errore_Discr;
END IF;

EXCEPTION
WHEN Errore_Discr THEN
    raise_application_error(-20010,'Incongruenza tra tipo di Richiesta di supporto(Articolo) e discriminante');
END;
/

--Trigger per il controllo della coerenza tra il discriminante di RDS_Vend e l'entità
CREATE OR REPLACE TRIGGER TRIGGER_Discr_RDS_VEND
BEFORE INSERT ON RDS_VEND
FOR EACH ROW
DECLARE
Discr    char(1);
Errore_Discr2    exception;
BEGIN

SELECT V_A INTO Discr
FROM RICHIESTA_DI_SUPPORTO
WHERE    N_Richiesta= :new.PF1_vend; --ricerca discriminante

IF Discr='A' THEN
	raise Errore_Discr2;
END IF;

EXCEPTION
WHEN    Errore_Discr2    THEN
    raise_application_error(-20011,'Incongruenza tra tipo di Richiesta di supporto(Venditore) e discriminante');
END;
/


--Trigger che cancella un ordine qualora esso sia vuoto
CREATE OR REPLACE TRIGGER TRIG_ORDINE_VUOTO
AFTER UPDATE OF F1_Codord ON LICENZA_ARTICOLO
FOR EACH ROW
DECLARE
Code    ORDINE.Cod_ord%type;
N_lic   Number;
Empty_order exception;
BEGIN
 -- conteggio articoli presenti nell'ordine dopo la cancellazione di una licenza
IF :new.F1_codord IS NULL THEN
    SELECT count(*) INTO N_lic FROM LICENZA_ARTICOLO WHERE F1_codord=:old.F1_Codord;
END IF;

IF N_lic=0 THEN
    DELETE FROM ORDINE WHERE COD_ORD=CODE;
END IF;
END;
/


--Trigger per controllare che il cliente abbia acquistato una licenza dal venditore che sta recensendo
CREATE OR REPLACE TRIGGER TRIGGER_Recensione
BEFORE INSERT ON RECENSIONE
FOR EACH ROW
DECLARE
N_vend    Number;
EmU ACCOUNT.Email%type;
EmV ACCOUNT.Email%type;
Rec_sbagliata exception;
BEGIN 
SELECT :new.PF2_emcliente, :new.PF2_emvend INTO EmU,EmV FROM RECENSIONE;
--Conteggio delle licenze che l'utente ha acquistato dal venditore che sta recensendo
SELECT COUNT(*) INTO N_vend FROM CLIENTE JOIN ORDINE ON PF1_emcliente = F2_emcliente
JOIN licenza_articolo ON cod_ord=F1_codord
WHERE PF1_emcliente=EmU AND F2_emvend=EmV AND Totale_ordine is not null; 

IF N_vend=0 THEN
    RAISE Rec_sbagliata;
END IF;

EXCEPTION
WHEN Rec_sbagliata THEN
    raise_application_error(-20012,'Non è possibile recensire un venditore senza averne acquistato una licenza');
END;
/
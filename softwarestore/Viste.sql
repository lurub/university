--Licenze_scontate: Permette di visualizzare tutte le licenze_scontate valide
CREATE OR REPLACE VIEW Licenze_scontate AS 
SELECT Cod_licenza,Prezzo_licenza, Percentuale_sconto,Inizio_Offerta, Fine_offerta,f1_codord,PF5_nsoft,Pf5_vsoft,PF3_nomeaz FROM 
(SELECT Cod_licenza,PF5_nsoft,Pf5_vsoft,PF3_nomeaz,prezzo_licenza,F1_CODORD FROM LICENZA_ARTICOLO)
JOIN PRODOTTO_SOFTWARE ON PF5_nsoft=Nome_Software AND PF5_vsoft=versione_software AND PF3_nomeaz=PF1_nomeaz
JOIN HA ON Nome_Software=PF2_nsoft AND Versione_Software=PF2_vsoft AND PF1_nomeaz=PF2_nomeaz
JOIN OFFERTA ON PF1_Idofferta=Id_offerta JOIN CATEGORIA_SOFTWARE ON F1_NOMECAT=NOME_CATEGORIA WHERE INIZIO_OFFERTA < SYSDATE AND SYSDATE < FINE_OFFERTA and STATO_CATEGORIA='ON';

--CLASSIFICA_Categoria_Software: Permette di visualizzare tutta le categorie_software ordinate per numero di vendite più alto
CREATE OR REPLACE VIEW CLASSIFICA_Categoria_Software AS
SELECT NOME_CATEGORIA,count(F1_NOMECAT) as Numero_vendite FROM LICENZA_ARTICOLO 
JOIN PRODOTTO_SOFTWARE ON pf5_nsoft=nome_software AND PF5_vsoft=versione_software AND PF3_nomeaz = PF1_nomeaz
JOIN CATEGORIA_SOFTWARE ON F1_NOMECAT = NOME_CATEGORIA
WHERE STATO_CATEGORIA='ON'
GROUP BY NOME_CATEGORIA
order by count(F1_NOMECAT) DESC;

--CLASSIFICA_Prodotto_software: Permette di visualizzare tutti i prodotti_software ordinati per numero di vendite più alto
CREATE OR REPLACE VIEW CLASSIFICA_Prodotto_software AS
SELECT count(COD_LICENZA) AS Numero_vendite, pf1_idofferta ,nome_software,versione_software,pf1_nomeaz FROM LICENZA_ARTICOLO
JOIN PRODOTTO_SOFTWARE ON pf5_nsoft=nome_software AND PF5_vsoft=versione_software AND PF3_nomeaz = PF1_nomeaz
LEFT OUTER JOIN (SELECT * FROM HA
JOIN (SELECT * FROM OFFERTA WHERE INIZIO_OFFERTA <SYSDATE AND FINE_OFFERTA >SYSDATE) ON PF1_idofferta=Id_offerta)
ON NOME_SOFTWARE=PF2_NSOFT AND VERSIONE_SOFTWARE = PF2_VSOFT AND PF1_NOMEAZ = PF2_NOMEAZ
JOIN CATEGORIA_SOFTWARE ON F1_NOMECAT=NOME_CATEGORIA
WHERE STATO_CATEGORIA='ON'
group by pf1_idofferta,nome_software,versione_software,pf1_nomeaz
order by count(COD_LICENZA) DESC;

--Visualizza_Licenze_disponibili: Permette di visualizzare tutte le licenze disponibili (licenze non ancora vendute)
CREATE OR REPLACE VIEW  Visualizza_Licenze_disponibili AS
SELECT PF5_nsoft,PF5_vsoft,cod_licenza FROM LICENZA_ARTICOLO where F1_Codord is NULL;

--Visualizza_Licenze_disponibili_NOPIU18: Permette di visualizzare tutte le licenze disponibili per minorenni
CREATE OR REPLACE VIEW  Visualizza_Licenze_disponibili_NOPIU18 AS
SELECT PF5_nsoft,PF5_vsoft,cod_licenza FROM LICENZA_ARTICOLO JOIN PRODOTTO_SOFTWARE ON pf5_nsoft=nome_software AND PF5_vsoft=versione_software AND PF3_nomeaz = PF1_nomeaz
JOIN CATEGORIA_SOFTWARE ON F1_NOMECAT=NOME_CATEGORIA
where F1_Codord is NULL and Piu18='N' and STATO_CATEGORIA='ON'; 

--Visualizza_TOP_venditori: Permette di visualizzare tutti i venditori ordinati per punteggio medio delle recensioni più alto
CREATE OR REPLACE VIEW  Visualizza_TOP_venditori AS
SELECT PF2_EMVEND,AVG(N_STELLE) as Punteggio_medio_recensioni FROM RECENSIONE GROUP BY PF2_EMVEND,N_STELLE ORDER BY AVG(N_STELLE) DESC;

--Visualizza_prodotti_Aziende_prop: Permette di visualizzare tutti i prodotti_software raggruppati per le le aziende_proprietarie
CREATE OR REPLACE VIEW  Visualizza_prodotti_Aziende_prop AS
SELECT pf1_nomeaz as Azienda, max(NOME_SOFTWARE) AS Software ,max(VERSIONE_SOFTWARE) as Versione FROM PRODOTTO_SOFTWARE
JOIN CATEGORIA_SOFTWARE ON F1_NOMECAT=NOME_CATEGORIA
WHERE STATO_CATEGORIA='ON'
GROUP BY pf1_nomeaz;


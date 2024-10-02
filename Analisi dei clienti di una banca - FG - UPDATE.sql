/*ANALISI DEI CLIENTI DI UNA BANCA*/

/*TEMPORARY TABLE*/
create temporary table banca.transazioni_totali (
id_cliente integer,
n_trans_uscita integer,
n_trans_entrata integer,
imp_uscita_tot float,
imp_entrata_tot float
);
create temporary table banca.conti_totali (
id_cliente integer,
n_conti_tot integer,
n_conto_base integer,
n_conto_business integer,
n_conto_privati integer,
n_conto_famiglie integer
);

create temporary table banca.transazioni_tipo_conto (
id_cliente integer,
n_trans_uscita_base integer,
n_trans_uscita_business integer,
n_trans_uscita_privati integer,
n_trans_uscita_famiglie integer,
n_trans_entrata_base integer,
n_trans_entrata_business integer,
n_trans_entrata_privati integer,
n_trans_entrata_famiglie integer,
imp_trans_uscita_base float,
imp_trans_uscita_business float,
imp_trans_uscita_privati float,
imp_trans_uscita_famiglie float,
imp_trans_entrata_base float,
imp_trans_entrata_business float,
imp_trans_entrata_privati float,
imp_trans_entrata_famiglie float
);
/*INSERIMENTO DEI VALORI NELLE TEMPORARY TABLE*/
insert into banca.transazioni_totali 
(select
cnt.id_cliente,
count(case when tr_tot.segno = '-' then cnt.id_cliente else null end) n_trans_uscita,
count(case when tr_tot.segno = '+' then cnt.id_cliente else null end) n_trans_entrata,
sum(case when tr_tot.segno = '-' then tr_tot.importo else null end) imp_uscita_tot,
sum(case when tr_tot.segno = '+' then tr_tot.importo else null end) imp_entrata_tot
from banca.conto cnt 
left join 
(select
trans.id_conto,
tipo_trans.segno,
trans.importo
from  banca.transazioni trans join banca.tipo_transazione tipo_trans on trans.id_tipo_trans = tipo_trans.id_tipo_transazione
) tr_tot on cnt.id_conto = tr_tot.id_conto
group by 1);


insert into banca.conti_totali
(select
cl.id_cliente,
count(id_conto) as n_conti_tot,
count(case when cnt.id_tipo_conto = 0 then cl.id_cliente else null end) n_conto_base,
count(case when cnt.id_tipo_conto = 1 then cl.id_cliente else null end) n_conto_business,
count(case when cnt.id_tipo_conto = 2 then cl.id_cliente else null end) n_conto_privati,
count(case when cnt.id_tipo_conto = 3 then cl.id_cliente else null end) n_conto_famiglie
from banca.cliente cl left join banca.conto cnt on cl.id_cliente = cnt.id_cliente
group by 1);


insert into banca.transazioni_tipo_conto
(select
cnt.id_cliente,
count(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=0 then cnt.id_cliente else null end) n_trans_uscita_base,
count(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=1 then cnt.id_cliente else null end) n_trans_uscita_business,
count(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=2 then cnt.id_cliente else null end) n_trans_uscita_privati,
count(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=3 then cnt.id_cliente else null end) n_trans_uscita_famiglie,
count(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=0 then cnt.id_cliente else null end) n_trans_entrata_base,
count(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=1 then cnt.id_cliente else null end) n_trans_entrata_business,
count(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=2 then cnt.id_cliente else null end) n_trans_entrata_privati,
count(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=3 then cnt.id_cliente else null end) n_trans_entrata_famiglie,
sum(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=0 then trans_tipo_conto.importo else null end) imp_trans_uscita_base,
sum(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=1 then trans_tipo_conto.importo else null end) imp_trans_uscita_business,
sum(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=2 then trans_tipo_conto.importo else null end) imp_trans_uscita_privati,
sum(case when trans_tipo_conto.segno ='-' and cnt.id_tipo_conto=3 then trans_tipo_conto.importo else null end) imp_trans_uscita_famiglie,
sum(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=0 then trans_tipo_conto.importo else null end) imp_trans_entrata_base,
sum(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=1 then trans_tipo_conto.importo else null end) imp_trans_entrata_business,
sum(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=2 then trans_tipo_conto.importo else null end) imp_trans_entrata_privati,
sum(case when trans_tipo_conto.segno ='+' and cnt.id_tipo_conto=3 then trans_tipo_conto.importo else null end) imp_trans_entrata_famiglie
from banca.conto cnt
left join
(select
trans.id_conto,
trans.importo,
tipo_trans.segno
from banca.transazioni trans left join banca.tipo_transazione tipo_trans on trans.id_tipo_trans = tipo_trans.id_tipo_transazione
) trans_tipo_conto on cnt.id_conto = trans_tipo_conto.id_conto
group by 1);

/*UNIONE DELLE TEMPORARY TABLE PER GENERARE QUERY FINALE
Gli importi sono arrotondati a due cifre decimali 
*/
select
clienti.id_cliente,
timestampdiff(year,clienti.data_nascita, now()) as eta,
case when trans_tot.n_trans_uscita is null then 0 else trans_tot.n_trans_uscita end as n_trans_uscita,
case when trans_tot.n_trans_entrata is null then 0 else trans_tot.n_trans_entrata end as n_trans_entrata,
case when trans_tot.imp_uscita_tot is null then 0 else round(trans_tot.imp_uscita_tot,2) end as imp_uscita_tot,
case when trans_tot.imp_entrata_tot is null then 0 else round(trans_tot.imp_entrata_tot,2) end as imp_entrata_tot,
case when cnt_tot.n_conti_tot is null then 0 else cnt_tot.n_conti_tot end as n_conti_tot,
case when cnt_tot.n_conto_base is null then 0 else cnt_tot.n_conto_base end as n_conto_base,
case when cnt_tot.n_conto_business is null then 0 else cnt_tot.n_conto_business end as n_conto_business,
case when cnt_tot.n_conto_privati is null then 0 else cnt_tot.n_conto_privati end as n_conto_privati,
case when cnt_tot.n_conto_famiglie is null then 0 else cnt_tot.n_conto_famiglie end as n_conto_famiglie,
case when trans_tipo_conto.n_trans_uscita_base is null then 0 else trans_tipo_conto.n_trans_uscita_base end as n_trans_uscita_base,
case when trans_tipo_conto.n_trans_uscita_business is null then 0 else trans_tipo_conto.n_trans_uscita_business end as n_trans_uscita_business,
case when trans_tipo_conto.n_trans_uscita_privati is null then 0 else trans_tipo_conto.n_trans_uscita_privati end as n_trans_uscita_privati,
case when trans_tipo_conto.n_trans_uscita_famiglie is null then 0 else trans_tipo_conto.n_trans_uscita_famiglie end as n_trans_uscita_famiglie,
case when trans_tipo_conto.n_trans_entrata_base is null then 0 else trans_tipo_conto.n_trans_entrata_base end as n_trans_entrata_base,
case when trans_tipo_conto.n_trans_entrata_business is null then 0 else trans_tipo_conto.n_trans_entrata_business end as n_trans_entrata_business,
case when trans_tipo_conto.n_trans_entrata_privati is null then 0 else trans_tipo_conto.n_trans_entrata_privati end as n_trans_entrata_privati,
case when trans_tipo_conto.n_trans_entrata_famiglie is null then 0 else trans_tipo_conto.n_trans_entrata_famiglie end as n_trans_entrata_famiglie,
case when trans_tipo_conto.imp_trans_uscita_base is null then 0 else round(trans_tipo_conto.imp_trans_uscita_base,2) end as imp_trans_uscita_base,
case when trans_tipo_conto.imp_trans_uscita_business is null then 0 else round(trans_tipo_conto.imp_trans_uscita_business,2) end as imp_trans_uscita_business,
case when trans_tipo_conto.imp_trans_uscita_privati is null then 0 else round(trans_tipo_conto.imp_trans_uscita_privati,2) end as imp_trans_uscita_privati,
case when trans_tipo_conto.imp_trans_uscita_famiglie is null then 0 else round(trans_tipo_conto.imp_trans_uscita_famiglie,2) end as imp_trans_uscita_famiglie,
case when trans_tipo_conto.imp_trans_entrata_base is null then 0 else round(trans_tipo_conto.imp_trans_entrata_base,2) end as imp_trans_entrata_base,
case when trans_tipo_conto.imp_trans_entrata_business is null then 0 else round(trans_tipo_conto.imp_trans_entrata_business,2) end as imp_trans_entrata_business,
case when trans_tipo_conto.imp_trans_entrata_privati is null then 0 else round(trans_tipo_conto.imp_trans_entrata_privati,2) end as imp_trans_entrata_privati,
case when trans_tipo_conto.imp_trans_entrata_famiglie is null then 0 else round(trans_tipo_conto.imp_trans_entrata_famiglie,2) end as imp_trans_entrata_famiglie
from banca.cliente clienti
left join banca.transazioni_totali trans_tot on clienti.id_cliente = trans_tot.id_cliente
left join banca.conti_totali cnt_tot on clienti.id_cliente = cnt_tot.id_cliente
left join banca.transazioni_tipo_conto trans_tipo_conto on clienti.id_cliente = trans_tipo_conto.id_cliente;

#ELIMINARE IL COMMENTO PER CANCELLARE LE TEMPORARY TABLE
/*
drop table banca.transazioni_totali;
drop table banca.conti_totali;
drop table banca.transazioni_tipo_conto;
*/
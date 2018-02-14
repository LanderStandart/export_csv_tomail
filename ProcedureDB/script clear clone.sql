delete from PRICES;
SET GENERATOR gen_prices_id TO 0;

--Отключаем режим все партии
ALTER TRIGGER AGENTS_WP_AIU0 INACTIVE;
ALTER TRIGGER PARTS_WP_AIU0 INACTIVE;
ALTER TRIGGER WARES_WP_AIU0 INACTIVE;

delete from ANALYTIC_DOC_DETAIL_1;
SET GENERATOR gen_analytic_doc_detail_1_id TO 0;

delete from ANALYTIC_DOC_DETAIL_2;
SET GENERATOR gen_analytic_doc_detail_2_id TO 0;


delete from ANALYTIC_DOC_DETAIL_4;
SET GENERATOR gen_analytic_doc_detail_4_id TO 0;

delete from ANALYTIC_DOC_DETAIL_8;
SET GENERATOR gen_analytic_doc_detail_8_id TO 0;

delete from ANALYTIC_MIN_ENDT;
SET GENERATOR gen_analytic_enddt_id TO 0;

delete from ANALYTIC_DOCS;
SET GENERATOR gen_analytic_docs_id TO 0;

delete from CASH_DOCS;
SET GENERATOR gen_cash_docs_id TO 0;
ALTER SEQUENCE GEN_CASH_DOCS_PACKET RESTART WITH 0;


delete from ACTIVEUSERS;

delete from WAREBASE;

delete from DOCS_LOG;
SET GENERATOR GEN_DOCS_LOG_ID TO 0;

delete from DSC_LOG;
SET GENERATOR gen_dsclog_id TO 0;

delete from PARTS_LOG;
SET GENERATOR GEN_PARTS_LOG_ID TO 0;

delete from TMP_LOG;

delete from DOC_DETAIL_ACTIVE_MMBSH;


delete from GROUP_DETAIL where GROUPTABLE='PARTS';

delete from DOC_DETAIL_VIRTUAL;

ALTER TRIGGER DOC_DETAIL_AD0 INACTIVE;
delete from DOC_DETAIL;
SET GENERATOR gen_doc_detail_id TO 0;
ALTER TRIGGER DOC_DETAIL_AD0 ACTIVE; 

delete from DOC_DETAIL_ACTIVE;
SET GENERATOR gen_doc_detail_active_id TO 0;

delete from DOC_DETAIL_ACTIVE_LOG;
SET GENERATOR GEN_DOC_DETAIL_ACTIVE_LOG_ID TO 0;

delete from DOC_DETAIL_DELETED;
SET GENERATOR gen_DOC_DETAIL_DELETED_id TO 0;

delete from DOC_DETAIL_ACTIVE_NAMEID;

update PARTS set doc_id=0, session_id=0, contract_id=0;

delete from PARTS_LOG;
SET GENERATOR GEN_PARTS_LOG_ID TO 0;


delete from SHIFT_DETAIL_KKM;
SET GENERATOR GEN_SHIFT_DETAIL_KKM_ID TO 0;

delete from DOC_DETAIL_ACTIVE_CANCELED;
delete from DOCS_CANCELED;


delete from DOCS where id>0;
SET GENERATOR gen_docs_id TO 0;
ALTER SEQUENCE GEN_DOCS_PACKET RESTART WITH 0;
update docs set packet=0, COMMITSESSION_ID = 0, audit_id=0;

delete from DOCS_CANCELED where id>0;

delete from doc_detail_doctor;

delete from warebasefolders;

delete from CONTRACTS where id>0;
SET GENERATOR gen_CONTRACTS_id TO 0;

update SP$PRIVILEGES set SP$GRANTORSESSION_ID = 0;

delete from SESSIONS where id>0;
SET GENERATOR gen_sessions_id TO 0;

delete from WORKSTATIONS where id>0;
SET GENERATOR gen_workstations_id TO 0;

delete from ZAKAZ_TMS;
SET GENERATOR GEN_ZAKAZ_TMS_ID TO 0;

delete from W$INV_DETAIL;
SET GENERATOR gen_w$inv_detail_id TO 0;

delete from W$INV;
SET GENERATOR gen_inv_id TO 0;

SET GENERATOR GEN_PACKET_DOCS TO 0;
SET GENERATOR GEN_PACKET_DOC_DETAIL TO 0;
SET GENERATOR GEN_PACKET_PARTS TO 0;
SET GENERATOR GEN_PACKET_VALS TO 0;
SET GENERATOR GEN_PACKET_WARES TO 0;
SET GENERATOR GEN_PACKET_CASH_DOCS TO 0;

update vals set packet=0 where id='0';
update wares set packet=0 where id='0';
update parts set packet=0 where id='0';
update docs set packet=0 where id='0';

delete from Z$SYNC_DELETED;

--Обнуляем пакеты, это необходимо для корректной работы синхронизации
SET GENERATOR gen_VALS_PACKET TO -1;
SET GENERATOR gen_PACKET_VALS TO -1;
update VALS set packet=0 where ID = '0';
update VALS set PACKET = PACKET Where ID <> '0';

SET GENERATOR gen_WARES_PACKET TO -1;
SET GENERATOR gen_PACKET_WARES TO -1;
update WARES set packet=0 where ID = '0';
update WARES set PACKET = PACKET Where ID <> '0';

SET GENERATOR gen_PARTS_PACKET TO -1;
SET GENERATOR gen_PACKET_PARTS TO -1;
update PARTS set packet=0 where ID = 0;
update PARTS set PACKET = PACKET Where ID <> 0;

SET GENERATOR gen_DOCS_PACKET TO -1;
SET GENERATOR gen_PACKET_DOCS TO -1;
update DOCS set packet=0 where ID = 0;
update DOCS set PACKET = PACKET Where ID <> 0;


Delete from Z$SERVICE;
SET GENERATOR gen_z$service_id TO 0;

--Delete from WAREBASE_DISTR;

delete from RECEPTS;
SET GENERATOR GEN_RECEPTS_ID TO 0;

delete from ATTRIBUTE_DETAIL;
SET GENERATOR GEN_ATTRIBUTE_DETAIL_ID TO 0;


-->20150604
commit work;
update PARAMS set d$uuid=UUID_TO_CHAR(GEN_UUID()); 
commit work;
update PARTS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update SESSIONS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update USERS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update DOCS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update DOCS_CANCELED set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update AGENTS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
update GROUP_DETAIL set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;
--20150604 <--

update AGENTS_CONTRACTS set d$uuid=UUID_TO_CHAR(GEN_UUID());
commit work;

--Включаем режим все партии
ALTER TRIGGER AGENTS_WP_AIU0 ACTIVE;
ALTER TRIGGER PARTS_WP_AIU0 ACTIVE;
ALTER TRIGGER WARES_WP_AIU0 ACTIVE;

--Чистка G$DISTRIBUTE
alter index G$DISTRIBUTE_IDX1 inactive;
alter index G$DISTRIBUTE_IDX2 inactive;
alter index G$DISTRIBUTE_IDX3 inactive;
alter index G$DISTRIBUTE_IDX4 inactive;
alter index G$DISTRIBUTE_IDX5 inactive;
alter index G$DISTRIBUTE_IDX6 inactive;
alter index G$DISTRIBUTE_IDX7 inactive;
alter index G$DISTRIBUTE_IDX8 inactive;
alter index G$DISTRIBUTE_IDX9 inactive;

delete from g$distribute d where coalesce(d.serverpacket,0)<(select max(g.serverpacket) from g$distribute g);

alter index G$DISTRIBUTE_IDX1 active;
alter index G$DISTRIBUTE_IDX2 active;
alter index G$DISTRIBUTE_IDX3 active;
alter index G$DISTRIBUTE_IDX4 active;
alter index G$DISTRIBUTE_IDX5 active;
alter index G$DISTRIBUTE_IDX6 active;
alter index G$DISTRIBUTE_IDX7 active;
alter index G$DISTRIBUTE_IDX8 active;
alter index G$DISTRIBUTE_IDX9 active;
commit work;

--очистко  egais_detail чтоб не пересекались в клонах doc_id 
delete from egais_detail;
update agents set id=id;
update users set id=id;
update docs set id=id;
update sessions set id=id;

commit work;

update params set param_value='' where param_id='EGAIS_FSRARID';
update params set param_value='0' where param_id='EGAIS_AUTO_MOVE';
update params set param_value='1' where param_id='EGAIS_WAYBILL_VER';
update params set param_value='0' where param_id='EGAIS_FORMBMODE';
update params set param_value='' where param_id='EGAIS_HOST';
commit work;
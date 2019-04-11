/******************************************************************************/
/***               Generated by IBExpert 08.04.2019 16:57:47                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/


CREATE GENERATOR GEN_PARTNER_LOAD_MOVE_ID;

CREATE TABLE PARTNER_LOAD_MOVE (
    ID                     DM_ID /* DM_ID = BIGINT */,
    PARTNER_ID             DM_ID /* DM_ID = BIGINT */,
    DRUG_NAME              DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DRUG_CODE              DM_ID /* DM_ID = BIGINT */,
    DOCNUM                 DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DOCDATE                DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    IZG_ID                 DM_UUID_NULL /* DM_UUID_NULL = CHAR(36) */,
    DRUG_PRODUCER_NAME     DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DRUG_PRODUCER_COUNTRY  DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    BARCODE                DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    CENA_ZAK               DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    GODENDO_DATE           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    SERIA                  DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    QUANT                  DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    BCODEIZG               DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DISK_T                 DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    DISK_SUM               DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    SUM_ZAK                DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    SUM_ROZN               DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    CENA_ROZN              DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    D_TYPE                 DM_ID /* DM_ID = BIGINT */,
    SUPPLIER               DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    SUPPLIER_INN           DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DEVICE_NUM             DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    N_CHEK                 DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    FIO_CHEK               DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    PP_TEG                 DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    G$PROFILE_ID           DM_ID_NULL /* DM_ID_NULL = BIGINT */,
    INSERTDT               DM_DATETIME /* DM_DATETIME = TIMESTAMP */,
    DOC_COMMITDATE         DM_DATETIME /* DM_DATETIME = TIMESTAMP */
);




/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: PARTNER_LOAD_MOVE_BI */
CREATE OR ALTER TRIGGER PARTNER_LOAD_MOVE_BI FOR PARTNER_LOAD_MOVE
ACTIVE BEFORE INSERT POSITION 0
as
begin
  if (new.id is null) then
    new.id = gen_id(gen_PARTNER_LOAD_MOVE_id,1);
end
^


/* Trigger: PARTNER_LOAD_MOVE_BI0 */
CREATE OR ALTER TRIGGER PARTNER_LOAD_MOVE_BI0 FOR PARTNER_LOAD_MOVE
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  new.insertdt=current_timestamp;
end
^


SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/

/******************************************************************************/
/***               Generated by IBExpert 01.07.2019 17:17:11                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE OUT$PHARMSM (
    SNAME     DM_TEXT1024 /* DM_TEXT1024 = VARCHAR(1024) */,
    MGN_NAME  DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    QUANT     DM_DOUBLE /* DM_DOUBLE = DOUBLE PRECISION */,
    BARCODE   DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    NAME_ID   DM_UUID_NULL /* DM_UUID_NULL = CHAR(36) */,
    SIZG      DM_TEXT /* DM_TEXT = VARCHAR(250) */
);




/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: OUT$PHARMSM_BI0 */
CREATE OR ALTER TRIGGER OUT$PHARMSM_BI0 FOR OUT$PHARMSM
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  new.name_id = (select first 1 w.name_id from wares w where w.mgn_name=new.mgn_name order by w.insertdt desc);

  new.sizg= (select first 1 svalue from VALS v where v.id=(select first 1 w.izg_id from wares w where w.name_id=new.name_id));

  new.barcode =   (select first 1 w.barcode from wares w where w.name_id=new.name_id order by w.insertdt desc);
end
^


/* Trigger: OUT$PHARMSM_BI1 */
CREATE OR ALTER TRIGGER OUT$PHARMSM_BI1 FOR OUT$PHARMSM
ACTIVE BEFORE INSERT POSITION 1
AS
begin
 new.sname = coalesce(new.mgn_name,'')||' ('||coalesce(new.sizg,'')||')';
end
^


SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/

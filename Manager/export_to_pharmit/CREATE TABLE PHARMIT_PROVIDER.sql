/******************************************************************************/
/***               Generated by IBExpert 20.09.2019 10:10:14                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE PHARMIT_PROVIDER (
    ID               DM_ID /* DM_ID = BIGINT NOT NULL */,
    NAME             DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    G$PROFILE_ID     DM_ID_NULL /* DM_ID_NULL = BIGINT */,
    GLOBAL_AGENT_ID  DM_ID_NULL /* DM_ID_NULL = BIGINT */,
    AGENT_NAME       DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    AGENT_ID         DM_ID_NULL /* DM_ID_NULL = BIGINT */
);




/******************************************************************************/
/***                                Triggers                                ***/
/******************************************************************************/


SET TERM ^ ;



/******************************************************************************/
/***                          Triggers for tables                           ***/
/******************************************************************************/



/* Trigger: PHARMIT_PROVIDER_BI0 */
CREATE OR ALTER TRIGGER PHARMIT_PROVIDER_BI0 FOR PHARMIT_PROVIDER
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
begin
  new.agent_id = (select id from agents a where a.global_id=new.global_agent_id);
  new.g$profile_id = (select g$profile_id from agents a where a.global_id=new.global_agent_id);
end
^


SET TERM ; ^



/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/

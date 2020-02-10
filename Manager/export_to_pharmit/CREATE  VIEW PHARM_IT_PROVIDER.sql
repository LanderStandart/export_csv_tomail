/*-------------------------------------------------------------------------*/
/* Dropping old views */
/*-------------------------------------------------------------------------*/

DROP VIEW PHARM_IT_PROVIDER;

/*-------------------------------------------------------------------------*/
/* Creating new views */
/*-------------------------------------------------------------------------*/

CREATE OR ALTER VIEW PHARM_IT_PROVIDER(
    ID,
    NAME,
    GLOBAL_AGENT_ID,
    CAPTION)
AS
select
    pp.ID,
    pp.name,
    pp.global_agent_id,
    pp.agent_name
     from pharmit_provider pp

;
/*-------------------------------------------------------------------------*/
/* Restoring descriptions for views */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring descriptions of view columns */
/*-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*/
/* Restoring triggers for views */
/*-------------------------------------------------------------------------*/

SET TERM ^ ;

CREATE TRIGGER PHARM_IT_PROVIDER_BIU0 FOR PHARM_IT_PROVIDER
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
BEGIN
  POST_EVENT 'DUMMY_EVENT';
END^

ALTER TRIGGER PHARM_IT_PROVIDER_BIU0
AS
begin
   update pharmit_provider pp set pp.GLOBAL_agent_id=new.global_agent_id where pp.id=new.id;
   update pharmit_provider pp set pp.agent_name=(select caption from agents a where a.global_id=new.global_agent_id) where pp.id=new.id;

end^

SET TERM ; ^

/*-------------------------------------------------------------------------*/
/* Restoring privileges */
/*-------------------------------------------------------------------------*/



GRANT SELECT,UPDATE ON PHARMIT_PROVIDER TO TRIGGER PHARM_IT_PROVIDER_BIU0;
GRANT SELECT ON AGENTS TO TRIGGER PHARM_IT_PROVIDER_BIU0;
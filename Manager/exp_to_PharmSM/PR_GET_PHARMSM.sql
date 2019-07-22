SET TERM ^ ;

create or alter procedure PR_GET_PHARMSM
as
declare variable MGN_NAME DM_TEXT;
begin
DELETE from out$pharmsm;
  INSERT into out$pharmsm (MGN_NAME,QUANT)
 select mgn_name , order_quant from( Select od.mgn_name,
coalesce(od.order_quant,od.optimal_order_quant)as order_quant

 from order_data od                       ) where order_quant>0;

  suspend;


end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON OUT$PHARMSM TO PROCEDURE PR_GET_PHARMSM;
GRANT SELECT ON ORDER_DATA TO PROCEDURE PR_GET_PHARMSM;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_GET_PHARMSM TO SYSDBA;
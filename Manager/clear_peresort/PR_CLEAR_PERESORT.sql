SET TERM ^ ;

create or alter procedure PR_CLEAR_PERESORT (
    SESSION integer)
returns (
    S DM_TEXT,
    RESULT DM_ID)
as
declare variable NEW_DOC_ID DM_ID;
declare variable PART_ID DM_ID;
declare variable QUANT DM_DOUBLE;
declare variable SUMMA DM_DOUBLE;
declare variable SNAME DM_TEXT;
declare variable PRICE_O DM_DOUBLE;
declare variable PRICE DM_DOUBLE;
declare variable PART_ID1 DM_ID;
declare variable QUANT1 DM_DOUBLE;
declare variable PRICE1 DM_DOUBLE;
declare variable SUMMA1 DM_DOUBLE;
declare variable SNAME1 DM_TEXT;
declare variable PRICE_O1 DM_DOUBLE;
begin
new_doc_id = (select doc_id from PR_NEWDOC(18,-2,0,'',null,:session));
result = 0;
for select part_id,quant,price,price*quant as summa,sname,price_o from warebase where quant<0 and price_o >=0 and price > 0
    into :part_id,:quant, :price, :summa, :sname,:price_o
    do
        begin
         for select first 1 part_id,quant,price,price*quant as summa,sname,price_o from    warebase where quant>=(-1)*(:quant)
         and
         trim(sname)=trim(:sname) and price=:price 
         into :part_id1 ,:quant1,:price1, :summa1, :sname1,:price_o1
         do 
            begin
            s = (select id from PR_RASHODPART(:new_doc_id,:part_id,:quant,:summa,'',1,0,null,0,null));

            s = (select id from PR_RASHODPART(:new_doc_id,:part_id1,:quant*(-1),:summa*(-1),'',1,0,null,0,null));
            result = 1;

            end
        end

  execute procedure PR_DOC_COMMIT(:new_doc_id,:session) ;
    s = 'Ничего не найдено !!!';
  if (result=1) then s='Сформирован документ КОРРЕКТИРОВКА ПЕРЕСОРТА';

  suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT EXECUTE ON PROCEDURE PR_NEWDOC TO PROCEDURE PR_CLEAR_PERESORT;
GRANT SELECT ON WAREBASE TO PROCEDURE PR_CLEAR_PERESORT;
GRANT EXECUTE ON PROCEDURE PR_RASHODPART TO PROCEDURE PR_CLEAR_PERESORT;
GRANT EXECUTE ON PROCEDURE PR_DOC_COMMIT TO PROCEDURE PR_CLEAR_PERESORT;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_CLEAR_PERESORT TO SYSDBA;
SET TERM ^ ;

create or alter procedure PR_PHARMIT_OUT (
    DATESTART DM_DATETIME)
as
begin
delete from pharmit_out;
  insert INTO pharmit_out (type_id,saledate,externalgoodid,goodname,producername,quantity,wholesaleprice,price,providerid,pharm,pharmbin,pharmaddress,postindex,location,userid,externalid,tender,coordinates)
  select
    iif (d.doc_type in(3),2,iif (d.doc_type in(1),1,iif(d.doc_type in(2,6),5,'-')))as typeid,
    extract(year from d.docdate)||'-'||iif(char_length(extract(month from d.docdate))=1,0||extract(month from d.docdate),extract(month from d.docdate))||'-'||
    iif(char_length(extract(day from d.docdate))=1,0||extract(day from d.docdate),extract(day from d.docdate))||'T'||
    iif(char_length(extract(hour from d.docdate))=1,0||extract(hour from d.docdate),extract(hour from d.docdate))||':'||
    iif(char_length(extract(minute from d.docdate))=1,0||extract(minute from d.docdate),extract(minute from d.docdate))||':'||
    iif(char_length(cast(extract(second from d.docdate)as numeric(1,0)))=1,0||cast(extract(second from d.docdate)as numeric(1,0)),
    cast(extract(second from d.docdate)as numeric(1,0)))||'Z' as saledate,
    p.ware_id as externalgoodid,
    w.sname as goodname,
    vizg.svalue as producername,
    abs(dd.quant) as quantity,
    p.price_o as wholesaleprice,
    p.price as price,
    (select first 1 pp.id from pharmit_provider pp where pp.agent_id = a.id) as providerid,
    g.caption as pharm,
    a.inn as pharmbin,
    a.factaddr as pharmaddress,
    '-' as postindex,
    'location' as location,
    'userID' as userID,
    'externalid' as externalid,
    1 as tender,
    'coordinates' as coordinates
    
  from docs d
    join doc_detail dd on dd.doc_id = d.id and dd.g$profile_id=d.g$profile_id
    join parts p on p.id = dd.part_id and p.g$profile_id=dd.g$profile_id
    join wares w on w.id = p.ware_id
    join vals vizg on vizg.id=w.izg_id
    join g$profiles g on g.id = d.g$profile_id
    join agents a on a.email<>'' and a.email is not null and a.email=g.id
    where d.doc_type in (1,3,2,6) ;
  suspend;
end^

SET TERM ; ^

/* Following GRANT statetements are generated automatically */

GRANT SELECT,INSERT,DELETE ON PHARMIT_OUT TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON PHARMIT_PROVIDER TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON DOCS TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON DOC_DETAIL TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON PARTS TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON WARES TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON VALS TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON G$PROFILES TO PROCEDURE PR_PHARMIT_OUT;
GRANT SELECT ON AGENTS TO PROCEDURE PR_PHARMIT_OUT;

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_PHARMIT_OUT TO SYSDBA;
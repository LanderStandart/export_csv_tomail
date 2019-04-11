SET TERM ^ ;

create or alter procedure PR_SOZVEZDIE_FORMAT_DATETIME (
    FORMATING_DATE DM_DATETIME,
    ONLYDATA DM_ID_NULL)
returns (
    RESULT DM_TEXT)
as
declare variable DAYS DM_TEXT;
declare variable MONTHS DM_TEXT;
declare variable YEARS DM_TEXT;
declare variable HOURS DM_TEXT;
declare variable MINUTES DM_TEXT;
declare variable SECONDS DM_TEXT;
begin
  if (:formating_date is null) then
  result=null;
  else
  begin
  days= extract(day from :formating_date);
  months= extract(month from :formating_date);
  years= extract(year from :formating_date);
  hours= extract(hour from :formating_date);
  minutes= extract(minute from :formating_date);
  seconds=round(extract(second from :formating_date));
  if (seconds=60) then seconds=59;
  if (:ONLYDATA is not null) then
    begin
    hours=0;minutes=0;seconds=0;
    end
  if (char_length(months)=1) then months='0'||months;
  if (char_length(days)=1) then days='0'||days;
  if (char_length(hours)=1) then hours='0'||hours;
  if (char_length(minutes)=1) then minutes='0'||minutes;
  if (char_length(seconds)=1) then seconds='0'||seconds;


  result = years||'-'||months||'-'||days||'T'||hours||':'||minutes||':'||seconds;
  end
  suspend;
end^

SET TERM ; ^

/* Existing privileges on this procedure */

GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_BATCH;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_MOVE;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO PROCEDURE PR_SOZVEZDIE_ACTION_REMHANT;
GRANT EXECUTE ON PROCEDURE PR_SOZVEZDIE_FORMAT_DATETIME TO SYSDBA;
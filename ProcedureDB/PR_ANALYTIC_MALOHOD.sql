begin
  delete from analytic_malohod where ANALYTIC_UUID=:ANALYTIC_UUID;
  STRATOFMONTH_BEG='01.'||extract(month from :PERIODBEG)||'.'||extract(year from :PERIODBEG);
  STRATOFMONTH_END='01.'||extract(month from :periodend)||'.'||extract(year from :periodend);
  s='select id from g$profiles where id in ('||G$PROFILE_ID||')';
  suspend;
  for EXECUTE STATEMENT :s into :profile_id do
    for
       select u.part_id,sum(u.quant),u.g$profile_id from
       (select wd.part_id,wd.quant,wd.g$profile_id from WAREBASE_D wd where wd.doc_commitdate=:STRATOFMONTH_BEG and
        wd.g$profile_id=:profile_id union all
       select dd.part_id,dd.quant,dd.g$profile_id from doc_detail dd where dd.doc_commitdate
       between :STRATOFMONTH_BEG and :periodbeg and dd.g$profile_id=:profile_id) u
       left join parts p on p.id=u.part_id and p.g$profile_id=u.g$profile_id
       left join wares w on w.id=p.ware_id
       group by u.part_id,u.g$profile_id
       having abs(sum(u.quant))>=:quant_beg-0.01 into
       :PART_ID,:OST_BEG,:PROFILE_ID do
    begin
      select sum(u.quant) from
       (select wd.part_id,wd.quant,wd.g$profile_id from WAREBASE_D wd where wd.part_id=:part_id and
        wd.doc_commitdate=:STRATOFMONTH_END and
        wd.g$profile_id=:profile_id union all
       select dd.part_id,dd.quant,dd.g$profile_id from doc_detail dd where dd.part_id=:part_id and
        dd.doc_commitdate  between :STRATOFMONTH_END and :periodEND and dd.g$profile_id=:profile_id) u
        into :ost_end;

     /* select quant from warebase_d where part_id=:part_id and g$profile_id=:profile_id
      and DOC_COMMITDATE=:periodend into :ost_end; */
      if (ost_end>0.001) then
        insert into analytic_malohod(ANALYTIC_UUID,G$PROFILE_ID,PART_ID,OST_BEG,PRIHOD,RASHOD,OST_END) values
      (:ANALYTIC_UUID,:PROFILE_ID,:PART_ID,:OST_BEG,:PRIHOD,:RASHOD,:OST_END);
    end
end
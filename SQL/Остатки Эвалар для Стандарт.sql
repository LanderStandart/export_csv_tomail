select first 10
    current_date,
    w.sname,
    'Аптека '||(select left(g.caption,position(' ' in g.caption)) from g$profiles g where g.id=w.g$profile_id)as Profile ,
    'Ижевск' as City,
    (select substring(g.caption from position(' ' in g.caption) for position('тел' in g.caption)-position(' ' in g.caption)) from g$profiles g where g.id=w.g$profile_id) as adress,
    w.quant,
    cast(w.price*w.quant as numeric(9,2)) as Summa,
    w.bcode_izg

          from vw_warebase w where quant > 0.01 -- and w.g$profile_id ='+InttoStr(i)+'
          and w.sizg containing 'эвалар'
               group by w.sname,w.g$profile_id,w.quant,w.price,w.bcode_izg
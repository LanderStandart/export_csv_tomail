update groups g set g.status = 1 where g.caption containing('пересорт')and g.grouptable<>'TMS';
DELETE FROM GROUPS WHERE id=999700;
SET BLOBFILE 'C:\Standart-N\clear_peresort\TMS_source.txt';
INSERT INTO GROUPS (ID, PARENT_ID, CAPTION, GROUPTABLE, STATUS, INSERTDT, SYSTEMFLAG, DESCRIPTION, IMAGEINDEX, DATA, COLOR, SORTING, BASE_AGENT_ID, SID) VALUES (999700,-400, 'Убрать пересорт', 'TMS', 0, NULL, 0, NULL, -1,:h00000000_7FFFFFFF, NULL, NULL, 0, NULL);

commit;








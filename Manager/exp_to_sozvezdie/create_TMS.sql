
DELETE FROM GROUPS WHERE id=19999;
SET BLOBFILE 'e:\TMS\Manager\exp_to_sozvezdie\TMS_SOZVEZDIE.hex';
INSERT INTO GROUPS (ID, PARENT_ID, CAPTION, GROUPTABLE, STATUS, INSERTDT, SYSTEMFLAG, DESCRIPTION, IMAGEINDEX, DATA, COLOR, SORTING, BASE_AGENT_ID, SID) VALUES (19999, 61, '�������� � ���������', 'TMS', 0, '30-MAR-2019 16:54:30', 0, NULL, -1,:h00000000_7FFFFFFF, NULL, NULL, 0, NULL);



commit;







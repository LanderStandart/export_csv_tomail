DELETE FROM GROUPS WHERE id=10803;
SET BLOBFILE 'e:\TMS\Manager\exp_to_partner\TMS_PARTNER.hex';
INSERT INTO GROUPS (ID, PARENT_ID, CAPTION, GROUPTABLE, STATUS, INSERTDT, SYSTEMFLAG, DESCRIPTION, IMAGEINDEX, DATA, COLOR, SORTING, BASE_AGENT_ID, SID) VALUES (10803, 61, '�������� � �������', 'TMS', 0, NULL, 0, NULL, -1,:h00000000_7FFFFFFF, NULL, NULL, 0, NULL);

commit;







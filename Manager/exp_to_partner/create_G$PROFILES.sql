/******************************************************************************/
/***               Generated by IBExpert 16.05.2019 14:44:14                ***/
/******************************************************************************/

/******************************************************************************/
/***      Following SET SQL DIALECT is just for the Database Comparer       ***/
/******************************************************************************/
SET SQL DIALECT 3;



/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/



CREATE TABLE G$PROFILES (
    ID            DM_ID NOT NULL /* DM_ID = BIGINT */,
    PARENT_ID     DM_ID NOT NULL /* DM_ID = BIGINT */,
    CAPTION       DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DESCRIPTION   DM_TEXT /* DM_TEXT = VARCHAR(250) */,
    DBSECUREKEY   DM_RGUID /* DM_RGUID = VARCHAR(32) */,
    INSERTDT      DM_DATETIME /* DM_DATETIME = TIMESTAMP */,
    ALLOWEDPCIDS  DM_BLOBTEXT /* DM_BLOBTEXT = BLOB SUB_TYPE 1 SEGMENT SIZE 80 */,
    ALLOWEDIPS    DM_BLOBTEXT /* DM_BLOBTEXT = BLOB SUB_TYPE 1 SEGMENT SIZE 80 */,
    DATA          DM_BLOBBIN /* DM_BLOBBIN = BLOB SUB_TYPE 0 SEGMENT SIZE 80 */,
    STATUS        DM_STATUS /* DM_STATUS = INTEGER */,
    D$UUID        DM_UUID /* DM_UUID = CHAR(36) NOT NULL */,
    D$SRVUPDDT    DM_DATETIME /* DM_DATETIME = TIMESTAMP */,
    RELATIONTYPE  DM_STATUS /* DM_STATUS = INTEGER */,
    EMAIL         DM_TEXT /* DM_TEXT = VARCHAR(250) */
);




/******************************************************************************/
/***                              Primary Keys                              ***/
/******************************************************************************/

ALTER TABLE G$PROFILES ADD CONSTRAINT PK_G$PROFILES PRIMARY KEY (ID);


/******************************************************************************/
/***                                Indices                                 ***/
/******************************************************************************/

CREATE INDEX G$PROFILES_IDX1 ON G$PROFILES (CAPTION);
CREATE INDEX G$PROFILES_IDX2 ON G$PROFILES (D$UUID);
CREATE INDEX G$PROFILES_IDX3 ON G$PROFILES (D$SRVUPDDT);


/******************************************************************************/
/***                               Privileges                               ***/
/******************************************************************************/
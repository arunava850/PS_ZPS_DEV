*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIAR_AAI_MASTER................................*
DATA:  BEGIN OF STATUS_ZFIAR_AAI_MASTER              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIAR_AAI_MASTER              .
CONTROLS: TCTRL_ZFIAR_AAI_MASTER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIAR_AAI_MASTER              .
TABLES: ZFIAR_AAI_MASTER               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

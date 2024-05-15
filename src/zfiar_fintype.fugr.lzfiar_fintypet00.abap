*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIAR_FINTYPE...................................*
DATA:  BEGIN OF STATUS_ZFIAR_FINTYPE                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIAR_FINTYPE                 .
CONTROLS: TCTRL_ZFIAR_FINTYPE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFIAR_FINTYPE                 .
TABLES: ZFIAR_FINTYPE                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

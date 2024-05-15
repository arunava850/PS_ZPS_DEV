*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_STATE_LOOKUP................................*
DATA:  BEGIN OF STATUS_ZFI_STATE_LOOKUP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_STATE_LOOKUP              .
CONTROLS: TCTRL_ZFI_STATE_LOOKUP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_STATE_LOOKUP              .
TABLES: ZFI_STATE_LOOKUP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

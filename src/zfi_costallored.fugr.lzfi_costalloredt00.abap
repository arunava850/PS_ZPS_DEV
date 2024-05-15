*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_COSTALLORED.................................*
DATA:  BEGIN OF STATUS_ZFI_COSTALLORED               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_COSTALLORED               .
CONTROLS: TCTRL_ZFI_COSTALLORED
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_COSTALLORED               .
TABLES: ZFI_COSTALLORED                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

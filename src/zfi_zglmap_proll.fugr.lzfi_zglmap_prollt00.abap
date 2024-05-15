*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_ZGLMAP_PROLL................................*
DATA:  BEGIN OF STATUS_ZFI_ZGLMAP_PROLL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_ZGLMAP_PROLL              .
CONTROLS: TCTRL_ZFI_ZGLMAP_PROLL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_ZGLMAP_PROLL              .
TABLES: ZFI_ZGLMAP_PROLL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

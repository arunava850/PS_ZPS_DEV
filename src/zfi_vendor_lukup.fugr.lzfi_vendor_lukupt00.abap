*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_VENDOR_LUKUP................................*
DATA:  BEGIN OF STATUS_ZFI_VENDOR_LUKUP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_VENDOR_LUKUP              .
CONTROLS: TCTRL_ZFI_VENDOR_LUKUP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_VENDOR_LUKUP              .
TABLES: ZFI_VENDOR_LUKUP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

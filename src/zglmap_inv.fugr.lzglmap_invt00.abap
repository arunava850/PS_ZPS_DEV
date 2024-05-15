*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGLMAP_INV......................................*
DATA:  BEGIN OF STATUS_ZGLMAP_INV                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGLMAP_INV                    .
CONTROLS: TCTRL_ZGLMAP_INV
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGLMAP_INV                    .
TABLES: ZGLMAP_INV                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

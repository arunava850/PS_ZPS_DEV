*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZAPPR_LIMIT.....................................*
DATA:  BEGIN OF STATUS_ZAPPR_LIMIT                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZAPPR_LIMIT                   .
CONTROLS: TCTRL_ZAPPR_LIMIT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZAPPR_LIMIT                   .
TABLES: ZAPPR_LIMIT                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

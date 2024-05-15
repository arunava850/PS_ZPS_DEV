*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHR_WORKDAY_EMP.................................*
DATA:  BEGIN OF STATUS_ZHR_WORKDAY_EMP               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHR_WORKDAY_EMP               .
CONTROLS: TCTRL_ZHR_WORKDAY_EMP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHR_WORKDAY_EMP               .
TABLES: ZHR_WORKDAY_EMP                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

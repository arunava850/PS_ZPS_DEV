*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_EBLD_GL_TAB.................................*
DATA:  BEGIN OF STATUS_ZFI_EBLD_GL_TAB               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_EBLD_GL_TAB               .
CONTROLS: TCTRL_ZFI_EBLD_GL_TAB
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_EBLD_GL_TAB               .
TABLES: ZFI_EBLD_GL_TAB                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

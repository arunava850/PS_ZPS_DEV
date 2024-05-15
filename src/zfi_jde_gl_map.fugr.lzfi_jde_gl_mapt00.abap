*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFI_JDE_GL_MAP..................................*
DATA:  BEGIN OF STATUS_ZFI_JDE_GL_MAP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFI_JDE_GL_MAP                .
CONTROLS: TCTRL_ZFI_JDE_GL_MAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFI_JDE_GL_MAP                .
TABLES: ZFI_JDE_GL_MAP                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .

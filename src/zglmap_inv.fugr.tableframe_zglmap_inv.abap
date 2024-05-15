*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZGLMAP_INV
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZGLMAP_INV         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.

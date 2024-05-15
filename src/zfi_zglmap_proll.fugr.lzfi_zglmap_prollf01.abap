*----------------------------------------------------------------------*
***INCLUDE LZFI_ZGLMAP_PROLLF01.
*----------------------------------------------------------------------*


FORM F_GET_GL_DESCR.

  select single TXT50 from skat into ZFI_ZGLMAP_PROLL-TXT50_SKAT where SPRAS = sy-langu
                                                                 and   KTOPL = 'PSUS'
                                                                 and   SAKNR = ZFI_ZGLMAP_PROLL-SAKNR.

ENDFORM.

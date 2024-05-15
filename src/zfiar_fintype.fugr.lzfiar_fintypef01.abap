*----------------------------------------------------------------------*
***INCLUDE LZFIAR_FINTYPEF01.
*----------------------------------------------------------------------*
FORM enter_timestamp.

  zfiar_fintype-ernam = sy-uname.
  zfiar_fintype-erdat = sy-datum.
  zfiar_fintype-erzeit = sy-uzeit.

ENDFORM.

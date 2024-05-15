*----------------------------------------------------------------------*
***INCLUDE LZFIAR_FINTYPEF03.
*----------------------------------------------------------------------*

FORM UPDATE_USER.

 zfiar_fintype-ernam = sy-uname.
  zfiar_fintype-erdat = sy-datum.
  zfiar_fintype-erzeit = sy-uzeit.

ENDFORM.

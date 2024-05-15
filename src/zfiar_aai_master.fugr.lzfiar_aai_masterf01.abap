*----------------------------------------------------------------------*
***INCLUDE LZFIAR_AAI_MASTERF01.
*----------------------------------------------------------------------*
FORM enter_tmestamp.

  zfiar_aai_master-ernam = sy-uname.
  zfiar_aai_master-erdat = sy-datum.
  zfiar_aai_master-erzeit = sy-uzeit.


ENDFORM.

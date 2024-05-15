*----------------------------------------------------------------------*
***INCLUDE LZFI_INBF01.
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Form process_capex
*&---------------------------------------------------------------------*
FORM process_capex .

  DATA(lo_capex) = NEW zcl_fi_ramp_accnt_pay( ).

  CALL METHOD lo_capex->post_document
    EXPORTING
      gt_data     = gt_capex
      iv_threhold = ''
      iv_taxgl    = ''
      iv_doctyp   = ''
    IMPORTING
      bapiret2    = gt_bapiret2.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form process_opex
*&---------------------------------------------------------------------*
FORM process_opex .

  DATA(lo_opex) = NEW zcl_fi_ramp_accnt_pay( ).

  CALL METHOD lo_opex->post_document
    EXPORTING
      gt_data     = gt_opex
      iv_threhold = ''
      iv_taxgl    = ''
      iv_doctyp   = ''
    IMPORTING
      bapiret2    = gt_bapiret2.




ENDFORM.

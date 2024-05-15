FUNCTION ZFI_AIF_COUNSEL_S4_AP_POST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  CHAR1
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  ZDT_IB_COUNSEL_LINK_MAIN
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  DATA: lt_input TYPE ztt_ib_counsel_link.

    LOOP AT curr_line-it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_input ASSIGNING FIELD-SYMBOL(<lfs_input>).
      <lfs_input> =  CORRESPONDING #( ls_data EXCEPT items ).
      <lfs_input>-items = CORRESPONDING #( ls_data-items ).
    ENDLOOP.

  CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>post_document
    EXPORTING
      it_input  = lt_input
    IMPORTING
      et_return = DATA(lt_return).

  APPEND LINES OF lt_return TO return_tab.

  IF line_exists( return_tab[ type = 'E' ] ).
    success = 'N'.
  ELSE.
    success = 'Y'.
  ENDIF.


ENDFUNCTION.

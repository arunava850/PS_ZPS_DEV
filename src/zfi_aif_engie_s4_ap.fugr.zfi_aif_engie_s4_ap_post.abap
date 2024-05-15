FUNCTION ZFI_AIF_ENGIE_S4_AP_POST.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  CHAR1
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  ZDT_IB_INPUT_ENGIE_MAIN
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  DATA: lt_input TYPE ztt_input_engie.

  lt_input = CORRESPONDING #( curr_line-it_data[] ).

  CALL METHOD zcl_fi_engie_ap_trans_s4=>post_document
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

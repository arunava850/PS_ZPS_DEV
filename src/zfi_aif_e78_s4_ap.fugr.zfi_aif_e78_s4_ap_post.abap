FUNCTION zfi_aif_e78_s4_ap_post.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  CHAR1
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  ZDT_IB_INPUT_E78_MAIN
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

  DATA: lt_input TYPE ztt_input_e78.

  lt_input = CORRESPONDING #( curr_line-it_data1[] ).

  DELETE lt_input WHERE success EQ abap_true.

  CALL METHOD zcl_fi_e78_ap_trans_s4=>post_document
*    EXPORTING
*      it_input  = lt_input
    IMPORTING
      et_return = DATA(lt_return)
    CHANGING
      ct_input  = lt_input.

  APPEND LINES OF lt_return TO return_tab.

  IF line_exists( return_tab[ type = 'E' ] ).
    success = 'N'.
  ELSE.
    success = 'Y'.
  ENDIF.

  curr_line-it_data1[] = CORRESPONDING #( lt_input ).
  zcl_ps_ib_e78_proxy=>gt_input-it_data1 = curr_line-it_data1[].

ENDFUNCTION.

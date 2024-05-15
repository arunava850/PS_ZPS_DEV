FUNCTION zfi_aif_int27_yd_post.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TESTRUN) TYPE  CHAR1
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"  CHANGING
*"     REFERENCE(DATA)
*"     REFERENCE(CURR_LINE) TYPE  ZFI_YARDI_S4_DATA_TYPE
*"     REFERENCE(SUCCESS) TYPE  /AIF/SUCCESSFLAG
*"     REFERENCE(OLD_MESSAGES) TYPE  /AIF/BAL_T_MSG
*"----------------------------------------------------------------------

data lt_return type bapiret2_t.
*  DATA: lt_input TYPE ztt_input_e78.
*
*  lt_input = CORRESPONDING #( curr_line-it_data1[] ).
*
*  CALL METHOD zcl_fi_e78_ap_trans_s4=>post_document
*    EXPORTING
*      it_input  = lt_input
*    IMPORTING
*      et_return = DATA(lt_return).
*
*  APPEND LINES OF lt_return TO return_tab.
*
*  IF line_exists( return_tab[ type = 'E' ] ).
*    success = 'N'.
*  ELSE.
*    success = 'Y'.
*  ENDIF.


  DATA : gs_data TYPE zfis_yardi_s4_gl_post,
         gt_data TYPE TABLE OF zfis_yardi_s4_gl_post.
  LOOP AT curr_line-zfi_yardi_s4_data_type-zdata[] INTO DATA(ls_data).
    gs_data = CORRESPONDING #( ls_data ).
    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.

  CALL FUNCTION 'ZFI_YARDI_S4_GLPOST_PROXY'
    EXPORTING
      et_data = gt_data
      IMPORTING
        bapiret2 = lt_return.

  APPEND LINES OF lt_return TO return_tab.

  IF line_exists( return_tab[ type = 'E' ] ).
    success = 'N'.
  ELSE.
    success = 'Y'.
  ENDIF.



ENDFUNCTION.

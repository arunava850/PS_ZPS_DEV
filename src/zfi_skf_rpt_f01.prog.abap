*&---------------------------------------------------------------------*
*& Include          ZFI_SKF_RPT_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  SELECT stagr
         date_from
         docnr
         docln
         date_to
         rbukrs
         rcntr
         prctr
         rfarea
         rbusa
         kokrs
         segment
         activ
         obart
         runit
         logsys
         rrcty
         rvers
         msl
         refdocnr
         canc_docnr
         usnam
         timestamp
         delta_ind
    FROM faglskf_pn
    INTO TABLE gt_output
   WHERE stagr IN s_stagr
     AND date_from IN s_d_from
     AND docnr IN s_docnr
     AND rbukrs IN s_rbukrs
     AND rcntr IN s_rcntr
     AND prctr IN s_prctr
     AND rbusa IN s_rbusa.
  IF sy-subrc EQ 0.
    SORT gt_output BY stagr ASCENDING
                  date_from ASCENDING.
  ELSE.
    MESSAGE TEXT-002 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_rpt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_rpt .

  DATA: lo_column         TYPE REF TO cl_salv_column_table,
        functions         TYPE REF TO cl_salv_functions_list,
        lv_errtxt         TYPE string,
        lv_msg            TYPE REF TO cx_salv_msg,
        lt_salv_not_found TYPE REF TO cx_salv_not_found.
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = gl_alv
                              CHANGING  t_table   = gt_output ).
    CATCH cx_salv_msg INTO lv_msg .
      lv_errtxt = lv_msg->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.
  TRY.
      IF gl_alv IS BOUND.
        functions = gl_alv->get_functions( ).
        functions->set_all( ).
        gl_alv->display( ).
      ENDIF.
    CATCH cx_salv_not_found INTO lt_salv_not_found.
      lv_errtxt = lt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.

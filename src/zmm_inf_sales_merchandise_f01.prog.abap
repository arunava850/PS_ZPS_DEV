*&---------------------------------------------------------------------*
*& Include          ZMM_INF_SALES_MERCHANDISE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form Initialize
*&---------------------------------------------------------------------*
*& text - Initialize 'ZRET' as default material type
*&---------------------------------------------------------------------*
FORM initialize .

  s_bwart-option = c_opti_eq.
  s_bwart-sign = c_sign_i.
  s_bwart-low = '251'.
  APPEND s_bwart.

  s_bwart-option = c_opti_eq.
  s_bwart-sign = c_sign_i.
  s_bwart-low = '252'.
  APPEND s_bwart.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text - Fetching Data to Process
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data.
  DATA: ls_tvar      TYPE tvarvc,
        lv_cpudt     TYPE matdoc-cpudt,
        lv_cputm     TYPE matdoc-cputm,
        lv_key1      TYPE string,
        lv_key2      TYPE string,
        lv_key3      TYPE string,
        lv_key4      TYPE string,
        lv_key5      TYPE string,
        lv_key6      TYPE string,
        lv_menge(30).

* Fetching Data from MATDOC joining with T001W tables
  IF chk_cpi EQ abap_true.
* Fetching Data from TVAR to get the last run date time and records processed
    SELECT *
      FROM tvarvc
      INTO TABLE @DATA(lt_tvar)
     WHERE name EQ @c_tvar_name.
    IF sy-subrc EQ 0.
      READ TABLE lt_tvar INTO ls_tvar WITH KEY sign = c_sign_i
                                               opti = c_opti_eq.
      IF sy-subrc EQ 0.
        SPLIT ls_tvar-low AT '-' INTO lv_cpudt lv_cputm.
      ENDIF.
    ENDIF.

* If date is initial then Substract 1 day from current date
* and pickup the records from that date
    IF lv_cpudt EQ '00000000'.
      lv_cpudt = sy-datum - 1.
      lv_cputm = '000000'.
    ENDIF.

    SELECT a~key1,
           a~key2,
           a~key3,
           a~key4,
           a~key5,
           a~key6,
           a~werks,
           a~dmbtr,
           a~menge,
           a~budat,
           a~cpudt,
           a~cputm,
           a~xblnr,
           a~bwart,
           a~matnr,
           b~name2
      FROM matdoc AS a
     INNER JOIN t001w AS b                             "#EC CI_BUFFJOIN
        ON a~werks EQ b~werks
      INTO TABLE @DATA(lt_matdoc)
     WHERE a~matnr IN @s_matnr
       AND a~werks IN @s_werks
       AND a~xblnr IN @s_xblnr
       AND a~bwart IN @s_bwart
       AND ( a~cpudt GT @lv_cpudt OR ( a~cpudt EQ @lv_cpudt AND a~cputm GE @lv_cputm ) ).
    IF sy-subrc EQ 0.
* Get the last record to move to TVAR for next run
      SORT lt_matdoc BY cpudt DESCENDING cputm DESCENDING.
      DATA(ls_matdoc) = lt_matdoc[ 1 ].
      DATA(lt_tvar_tmp) = lt_tvar.
      CLEAR:ls_tvar.
      REFRESH:lt_tvar.
      ls_tvar-mandt = sy-mandt.
      ls_tvar-name = c_tvar_name.
      ls_tvar-type = c_s.
      ls_tvar-sign = c_sign_i.
      ls_tvar-opti = c_opti_eq.
      ls_tvar-numb = '0000'.
      CONCATENATE ls_matdoc-cpudt ls_matdoc-cputm INTO ls_tvar-low SEPARATED BY '-'.
      lv_cpudt = ls_matdoc-cpudt.
      lv_cputm = ls_matdoc-cputm.
      APPEND ls_tvar TO lt_tvar. " Update last run date and time
      CLEAR:ls_tvar,ls_matdoc.

* Move last run second records to TVAR  to check for next run if any
* records got missed because of timing
      LOOP AT lt_matdoc INTO ls_matdoc WHERE cpudt EQ lv_cpudt
                                         AND cputm EQ lv_cputm.
        ls_tvar-mandt = sy-mandt.
        ls_tvar-name = c_tvar_name.
        ls_tvar-type = c_s.
        ls_tvar-sign = c_sign_i.
        ls_tvar-opti = c_opti_ne.
        ls_tvar-numb = ls_tvar-numb + 1.
        lv_key1 = ls_matdoc-key1.
        lv_key2 = ls_matdoc-key2.
        lv_key3 = ls_matdoc-key3.
        lv_key4 = ls_matdoc-key4.
        lv_key5 = ls_matdoc-key5.
        lv_key6 = ls_matdoc-key6.
        CONCATENATE lv_key1 lv_key2 lv_key3
                    lv_key4 lv_key5 lv_key6
               INTO ls_tvar-low SEPARATED BY '-'.
        APPEND ls_tvar TO lt_tvar.
        CLEAR:lv_key1,lv_key2,lv_key3,lv_key4,
              lv_key5,lv_key6,ls_matdoc.
      ENDLOOP.

* Update TVARVC table by deleting the current records and
* update with new time and records
      IF lt_tvar IS NOT INITIAL.
* Delete Old entries and update with new entries
        DELETE FROM tvarvc WHERE name = c_tvar_name.
        COMMIT WORK AND WAIT.
        MODIFY tvarvc FROM TABLE lt_tvar.
        COMMIT WORK AND WAIT.
      ENDIF.

* Eliminate records which already processed previous run
* and process which did not on the last second
      LOOP AT lt_tvar_tmp INTO ls_tvar WHERE sign EQ c_sign_i
                                         AND opti EQ c_opti_ne.
        SPLIT ls_tvar-low AT '-' INTO lv_key1 lv_key2 lv_key3
                                      lv_key4 lv_key5 lv_key6.
        READ TABLE lt_matdoc INTO ls_matdoc WITH KEY key1 = lv_key1
                                                     key2 = lv_key2
                                                     key3 = lv_key3
                                                     key4 = lv_key4
                                                     key5 = lv_key5
                                                     key6 = lv_key6.
        IF sy-subrc EQ 0.
          DELETE lt_matdoc INDEX sy-tabix.
        ENDIF.
        CLEAR:lv_key1,lv_key2,lv_key3,lv_key4,
        lv_key5,lv_key6,ls_matdoc, ls_tvar.
      ENDLOOP.
    ELSE.
      MESSAGE TEXT-014 TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF chk_cpi NE abap_true.
    IF chk_disp EQ abap_true.
      SELECT a~key1,
             a~key2,
             a~key3,
             a~key4,
             a~key5,
             a~key6,
             a~werks,
             a~dmbtr,
             a~menge,
             a~budat,
             a~cpudt,
             a~cputm,
             a~xblnr,
             a~bwart,
             a~matnr,
             b~name2
        FROM matdoc AS a
       INNER JOIN t001w AS b                           "#EC CI_BUFFJOIN
          ON a~werks EQ b~werks
        INTO TABLE @lt_matdoc
       WHERE a~matnr IN @s_matnr
         AND a~werks IN @s_werks
         AND a~xblnr IN @s_xblnr
         AND a~bwart IN @s_bwart
         AND a~cpudt IN @s_cpudt.
      IF sy-subrc NE 0.
        MESSAGE TEXT-013 TYPE c_s DISPLAY LIKE c_e.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.

* Process records to CPI
  LOOP AT lt_matdoc INTO ls_matdoc.
    gs_data-interface_name = 'INT0068'.
    gs_data-receiver_system = 'EDW'.
    gs_data-reference = ls_matdoc-xblnr.
    gs_data-name2 = ls_matdoc-name2.
    gs_data-material = ls_matdoc-matnr.
    gs_data-amount_in_lc = ls_matdoc-dmbtr.
    IF ls_matdoc-dmbtr NE 0
      AND ls_matdoc-menge NE 0.
      gs_data-item_cost = ls_matdoc-dmbtr / ls_matdoc-menge.
    ELSE.
      gs_data-item_cost = 0.
    ENDIF.
    gs_data-quantity  = floor( ls_matdoc-menge ).
    gs_data-movement_type = ls_matdoc-bwart.
    gs_data-posting_date = |{ ls_matdoc-budat+4(2) }/{ ls_matdoc-budat+6(2) }/{ ls_matdoc-budat+0(4) }|.
    gs_data-plant = ls_matdoc-werks.
    SHIFT gs_data-material LEFT DELETING LEADING '0'.

    IF chk_disp EQ abap_true.
      MOVE-CORRESPONDING gs_data TO gs_output.
      APPEND gs_output TO gt_output.
    ENDIF.

    IF chk_cpi EQ abap_true.
      APPEND gs_data TO gt_data.
    ENDIF.
    CLEAR:gs_output,gs_data,lv_menge.
  ENDLOOP.

  SORT gt_output BY plant ASCENDING material ASCENDING.
  SORT gt_data BY plant ASCENDING material ASCENDING.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data_cpi
*&---------------------------------------------------------------------*
*& text - Sending Data(Outbound)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_data_cpi.
  TRY.
      DATA(lr_send) = NEW zco_mm_merchandise_sales( ).
      IF lr_send IS BOUND.
        gs_out-mm_merchandise_sales_mt-zdata_mercsales[] = gt_data[].
        lr_send->send_data( output = gs_out ).
        COMMIT WORK AND WAIT.
        MESSAGE TEXT-015 TYPE c_s.
      ENDIF.
    CATCH cx_ai_system_fault INTO DATA(ls_text).
  ENDTRY.
  IF ls_text IS NOT INITIAL.
    DATA(lv_proxy_err) = ls_text->errortext.
    IF lv_proxy_err NE abap_false.
      MESSAGE lv_proxy_err TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ENDIF.
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
        DATA(lo_columns) = gl_alv->get_columns( ).
        lo_column ?= lo_columns->get_column( TEXT-005 ).
        lo_column->set_short_text( TEXT-006 ).
        lo_column->set_medium_text( TEXT-006 ).
        lo_column->set_long_text( TEXT-006 ).
        lo_column ?= lo_columns->get_column( TEXT-007 ).
        lo_column->set_short_text( TEXT-008 ).
        lo_column->set_medium_text( TEXT-008 ).
        lo_column->set_long_text( TEXT-008 ).
        lo_column ?= lo_columns->get_column( TEXT-009 ).
        lo_column->set_short_text( TEXT-010 ).
        lo_column->set_medium_text( TEXT-011 ).
        lo_column->set_long_text( TEXT-011 ).
        gl_alv->display( ).
        lo_columns->set_optimize( abap_true ).
      ENDIF.
    CATCH cx_salv_not_found INTO lt_salv_not_found.
      lv_errtxt = lt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.

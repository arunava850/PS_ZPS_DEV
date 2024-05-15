*&---------------------------------------------------------------------*
*& Include          ZMM_INF_ONHAND_MERCHANDISE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form Initialize
*&---------------------------------------------------------------------*
*& text - Initialize 'ZRET' as default material type
*&---------------------------------------------------------------------*
FORM initialize .

  s_mtart-option = c_opti_eq.
  s_mtart-sign = c_sign_i.
  s_mtart-low = c_mtart.
  APPEND s_mtart.

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

  DATA: lv_del   TYPE ekpo-menge,
        lv_sch   TYPE ekpo-menge,
        lv_delv  TYPE ekpo-menge,
        lv_unre  TYPE p DECIMALS 0,
        lv_mstae TYPE marc-mmsta.

  CONSTANTS: c_loekz_s TYPE ekpo-loekz VALUE 'S',
             c_loekz_l TYPE ekpo-loekz VALUE 'L',
             c_inf     TYPE char10 VALUE 'INT0074',
             c_rec     TYPE char3 VALUE 'EDW'.

  SELECT SINGLE *
    FROM tvarvc
    INTO @DATA(lv_low)
   WHERE name EQ 'ZMM_INF_ONHAND_MERCHANDISE_TVA'
     AND type EQ 'P'.
  IF sy-subrc EQ 0.
    lv_mstae = lv_low-low.
  ENDIF.

  SELECT a~matnr,
         a~werks,
         a~lvorm AS c_lvorm,
         a~mmsta,
         b~lvorm AS b_lvorm,
         b~mstae,
         c~name2
    FROM marc AS a
   INNER JOIN mara AS b
      ON a~matnr EQ b~matnr
   INNER JOIN t001w AS c                               "#EC CI_BUFFJOIN
      ON a~werks EQ c~werks
    INTO TABLE @DATA(lt_marc)
   WHERE b~mtart IN @s_mtart
     AND a~matnr IN @s_matnr
     AND a~werks IN @s_werks.
  IF sy-subrc EQ 0.
    SORT lt_marc BY matnr werks.
    SELECT matnr,
           werks,
           lgort,
           labst
      FROM mard
      INTO TABLE @DATA(lt_mard)
       FOR ALL ENTRIES IN @lt_marc
     WHERE matnr EQ @lt_marc-matnr
       AND werks EQ @lt_marc-werks.

    SELECT b~ebeln,
           b~ebelp,
           b~umrez,
           b~matnr,
           b~werks,
           b~loekz,
           b~elikz,
           a~etenr,
           a~menge,
           a~wemng
      FROM eket AS a
     INNER JOIN ekpo AS b
        ON a~ebeln EQ b~ebeln
       AND a~ebelp EQ b~ebelp
      INTO TABLE @DATA(lt_eket)
       FOR ALL ENTRIES IN @lt_marc
     WHERE b~matnr EQ @lt_marc-matnr
       AND b~werks EQ @lt_marc-werks.
  ENDIF.
  LOOP AT lt_marc INTO DATA(ls_marc).
    LOOP AT lt_eket INTO DATA(ls_eket) WHERE matnr EQ ls_marc-matnr
                                         AND werks EQ ls_marc-werks.
      IF ls_eket-loekz EQ c_loekz_s
      OR ls_eket-loekz EQ c_loekz_l
      OR ls_eket-elikz EQ abap_true.
        lv_sch = lv_sch + ( ls_eket-menge * ls_eket-umrez ).
        lv_delv = lv_delv + ( ls_eket-wemng * ls_eket-umrez ).
      ENDIF.
      gs_data-schedule_quantity = ( ls_eket-menge * ls_eket-umrez ) + gs_data-schedule_quantity.
      gs_data-delivered_quantity = ( ls_eket-wemng * ls_eket-umrez ) + gs_data-delivered_quantity.
    ENDLOOP.
    gs_data-interface_name = c_inf.
    gs_data-receiver_system = c_rec.
    gs_data-name2 = ls_marc-name2.
    READ TABLE lt_mard
     INTO DATA(ls_mard)
      WITH KEY matnr = ls_marc-matnr
               werks = ls_marc-werks.
    IF sy-subrc EQ 0.
      gs_data-unrestricted_stock = ls_mard-labst.
    ENDIF.
    gs_data-plant = ls_marc-werks.
    gs_data-material = ls_marc-matnr.
    lv_del = lv_sch - lv_delv. " Quantity which got PO item deleted/Blocked/End Delivery
    gs_data-open_po_quantity = gs_data-schedule_quantity - gs_data-delivered_quantity.
    gs_data-open_po_quantity = gs_data-open_po_quantity - lv_del.
    gs_data-open_po_quantity = floor( gs_data-open_po_quantity ).
    gs_data-schedule_quantity = floor( gs_data-schedule_quantity ).
    gs_data-delivered_quantity = floor( gs_data-delivered_quantity ).
    gs_data-unrestricted_stock = floor( gs_data-unrestricted_stock ).
    IF gs_data-unrestricted_stock LT 0.
      lv_unre = gs_data-unrestricted_stock.
      gs_data-unrestricted_stock = |{ lv_unre SIGN = LEFT }|.
    ENDIF.
    gs_data-report_date = |{ sy-datum+4(2) }/{ sy-datum+6(2) }/{ sy-datum+0(4) }|.
    SHIFT gs_data-material LEFT DELETING LEADING '0'.
    IF gs_data-unrestricted_stock EQ 0
     AND gs_data-delivered_quantity EQ 0
     AND gs_data-schedule_quantity EQ 0
     AND gs_data-open_po_quantity EQ 0.
      IF ( ls_marc-c_lvorm EQ abap_true )
        OR ( ls_marc-b_lvorm EQ abap_true )
        OR ( ls_marc-mstae EQ lv_mstae )
        OR ( ls_marc-mmsta EQ lv_mstae ).
        CLEAR: gs_data, lv_sch, lv_delv, lv_del,lv_unre,ls_marc,ls_mard.
        CONTINUE.
      ENDIF.
    ENDIF.
    MOVE-CORRESPONDING gs_data TO gs_output.
    APPEND gs_data TO gt_data.
    APPEND gs_output TO gt_output.
    CLEAR:gs_data, gs_output, lv_sch, lv_delv, lv_del,lv_unre,ls_mard.
  ENDLOOP.
  FREE: lt_marc, lt_mard, lt_eket.
  IF gt_output IS INITIAL.
    MESSAGE TEXT-005 TYPE c_s DISPLAY LIKE c_s.
    LEAVE LIST-PROCESSING.
  ELSE.
    SORT gt_output BY plant ASCENDING material ASCENDING.
    SORT gt_data BY plant ASCENDING material ASCENDING.
  ENDIF.

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
      DATA(lr_send) = NEW zco_mm_merchandise_onhand( ).
      IF lr_send IS BOUND.
        gs_out-mm_merchandise_onhand_mt-zdata_merchand[] = gt_data[].
        lr_send->send_data( output = gs_out ).
        COMMIT WORK AND WAIT.
        MESSAGE TEXT-006 TYPE c_s.
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
*& text - Display Output results
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
        lo_column ?= lo_columns->get_column( TEXT-007 ).
        lo_column->set_short_text( TEXT-008 ).
        lo_column->set_medium_text( TEXT-008 ).
        lo_column->set_long_text( TEXT-008 ).

        lo_column ?= lo_columns->get_column( TEXT-009 ).
        lo_column->set_short_text( TEXT-010 ).
        lo_column->set_medium_text( TEXT-011 ).
        lo_column->set_long_text( TEXT-011 ).

        lo_column ?= lo_columns->get_column( TEXT-012 ).
        lo_column->set_short_text( TEXT-013 ).
        lo_column->set_medium_text( TEXT-014 ).
        lo_column->set_long_text( TEXT-014 ).

        lo_column ?= lo_columns->get_column( TEXT-015 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-018 ).
        lo_column->set_short_text( TEXT-019 ).
        lo_column->set_medium_text( TEXT-020 ).
        lo_column->set_long_text( TEXT-020 ).

        lo_column ?= lo_columns->get_column( TEXT-021 ).
        lo_column->set_short_text( TEXT-022 ).
        lo_column->set_medium_text( TEXT-023 ).
        lo_column->set_long_text( TEXT-023 ).
        gl_alv->display( ).
        lo_columns->set_optimize( abap_true ).
      ENDIF.
    CATCH cx_salv_not_found INTO lt_salv_not_found.
      lv_errtxt = lt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.
ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZFI_INF_DRA_RECONNET_F01
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

  DATA: lv_nname   TYPE bapico_group-groupname,
        lt_col     TYPE TABLE OF zfi_ccpc_hierarchy_read_col,
        lt_col_tmp TYPE TABLE OF zfi_ccpc_hierarchy_read_col,
        lv_prono   TYPE char5.

  LOOP AT s_sname INTO DATA(ls_sname).
    IF ls_sname-sign EQ c_sign_i
      AND ls_sname-option EQ c_opti_eq.
      lv_nname = ls_sname-low.
      CALL FUNCTION 'ZFI_CCPC_HIERARCHY_READ'
        EXPORTING
          i_setclass                = '0106'
          i_subclass                = p_sclass
          i_setname                 = lv_nname
          i_col                     = abap_true
        TABLES
          output_col                = lt_col_tmp
        EXCEPTIONS
          invalid_setclass          = 1
          invalid_selection_row_col = 2
          invalid_input             = 3
          OTHERS                    = 4.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        APPEND LINES OF lt_col_tmp TO lt_col.
        REFRESH: lt_col_tmp[].
      ENDIF.
    ENDIF.
    CLEAR:lv_nname.
  ENDLOOP.

  DELETE lt_col WHERE value EQ abap_false.

  IF lt_col IS NOT INITIAL.
    LOOP AT lt_col INTO DATA(ls_col).
      gs_data-interface_name = c_inf1.
      gs_data-receiver_system = c_rec1.

      IF ls_col-ltext EQ abap_false.
        gs_data-property_name = '" "'.
      ELSE.
        CONCATENATE '"' ls_col-ltext '"' INTO gs_data-property_name.
      ENDIF.

      IF ls_col-value EQ abap_false.
        gs_data-property_number = '" "'.
      ELSE.
        REPLACE ALL OCCURRENCES OF
          REGEX '[A-Z]' IN ls_col-value ##REGEX_POSIX
          WITH space.
        REPLACE ALL OCCURRENCES OF
          REGEX '[a-z]' IN ls_col-value ##REGEX_POSIX
          WITH space.
        IF ls_col-value NE abap_false.
          CONDENSE ls_col-value.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = ls_col-value
            IMPORTING
              output = lv_prono.
          CONCATENATE '"' lv_prono '"' INTO gs_data-property_number.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

      gs_data-bank_account = '" "'.
      gs_data-blank1 = '" "'.
      gs_data-blank2 = '" "'.
      gs_data-blank3 = '" "'.
      gs_data-blank4 = '" "'.

      IF ls_col-level1 NE abap_false.
        CASE ls_col-level1+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level1 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level1 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level1+0(1) ls_col-level1+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level1+0(1) ls_col-level1+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level1+4(1)  '"' INTO gs_data-division.
          WHEN 'RG'.
            DATA(lv_rg_ln) = strlen( ls_col-level1 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level1+0(2) ls_col-level1+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level2 NE abap_false.
        CASE ls_col-level2+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level2 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level2 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level2+0(1) ls_col-level2+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level2+0(1) ls_col-level2+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level2+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level2 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level2+0(2) ls_col-level2+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level3 NE abap_false.
        CASE ls_col-level3+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level3 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level3 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level3+0(1) ls_col-level3+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level3+0(1) ls_col-level3+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level3+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level3 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level3+0(2) ls_col-level3+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level4 NE abap_false.
        CASE ls_col-level4+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level4 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level4 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level4+0(1) ls_col-level4+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level4+0(1) ls_col-level4+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level4+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level4 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level4+0(2) ls_col-level4+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level5 NE abap_false.
        CASE ls_col-level5+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level5 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level5 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level5+0(1) ls_col-level5+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level5+0(1) ls_col-level5+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level5+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level5 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level5+0(2) ls_col-level5+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level6 NE abap_false.
        CASE ls_col-level6+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level6 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level6 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level6+0(1) ls_col-level6+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level6+0(1) ls_col-level6+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level6+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level6 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level6+0(2) ls_col-level6+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level7 NE abap_false.
        CASE ls_col-level7+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level7 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level7 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level7+0(1) ls_col-level7+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level7+0(1) ls_col-level7+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level7+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level7 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level7+0(2) ls_col-level7+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF ls_col-level8 NE abap_false.
        CASE ls_col-level8+0(2).
          WHEN 'D0'.
            CONCATENATE '"' ls_col-level8 '"' INTO gs_data-district.
          WHEN 'SD'.
            CONCATENATE '"' ls_col-level8 '"' INTO gs_data-senior_district.
          WHEN 'R0'.
            CONCATENATE '"' ls_col-level8+0(1) ls_col-level8+3(2) '"' INTO gs_data-region.
          WHEN 'SR'.
            CONCATENATE '"' ls_col-level8+0(1) ls_col-level8+3(2) '"' INTO gs_data-senior_region.
          WHEN 'DI'.
            CONCATENATE '"' ls_col-level8+4(1) '"' INTO gs_data-division.
          WHEN 'RG'.
            lv_rg_ln = strlen( ls_col-level8 ).
            lv_rg_ln = lv_rg_ln - 4.
            CONCATENATE '"' ls_col-level8+0(2) ls_col-level8+4(lv_rg_ln) '"' INTO gs_data-region.
            CLEAR:lv_rg_ln.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.


      IF gs_data-district EQ abap_false.
        gs_data-district = '" "'.
      ELSE.
        DATA(lv_str) = substring( val = gs_data-district off = strlen( gs_data-district ) - 2 len = 1 ).
        IF lv_str CO sy-abcde.
          gs_data-district = substring( val = gs_data-district off = 0 len = strlen( gs_data-district ) - 2 ).
          CONCATENATE gs_data-district '"' INTO gs_data-district.
        ENDIF.
      ENDIF.

      IF gs_data-senior_district EQ abap_false.
        gs_data-senior_district = '" "'.
      ELSE.
        lv_str = substring( val = gs_data-senior_district off = strlen( gs_data-senior_district ) - 2 len = 1 ).
        IF lv_str CO sy-abcde.
          gs_data-senior_district = substring( val = gs_data-senior_district off = 0 len = strlen( gs_data-senior_district ) - 2 ).
          CONCATENATE gs_data-senior_district '"' INTO gs_data-senior_district.
        ENDIF.
      ENDIF.

      IF gs_data-region EQ abap_false.
        gs_data-region = '" "'.
      ENDIF.

      IF gs_data-senior_region EQ abap_false.
        gs_data-senior_region = '" "'.
      ENDIF.

      IF gs_data-division EQ abap_false.
        gs_data-division = '" "'.
      ENDIF.

      gs_data-blank5 = '" "'.
      gs_data-blank6 = '" "'.
      gs_data-blank7 = '" "'.
      gs_data-blank8 = '" "'.
      gs_data-blank9 = '" "'.
      SHIFT gs_data-property_number LEFT DELETING LEADING '0'.
      APPEND gs_data TO gt_data.
      MOVE-CORRESPONDING gs_data TO gs_output.
      APPEND gs_output TO gt_output.
      CLEAR:gs_data, gs_output.
    ENDLOOP.
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
      DATA(lr_send) = NEW zco_fi_dra_to_reconnet( ).
      IF lr_send IS BOUND.
        gs_out-fi_dra_to_reconnet_mt-zdata_reconnet[] = gt_data[].
        lr_send->send_data( output = gs_out ).
        COMMIT WORK AND WAIT.
        MESSAGE TEXT-005 TYPE c_s.
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
        lo_column ?= lo_columns->get_column( TEXT-006 ).
        lo_column->set_short_text( TEXT-007 ).
        lo_column->set_medium_text( TEXT-008 ).
        lo_column->set_long_text( TEXT-008 ).

        lo_column ?= lo_columns->get_column( TEXT-009 ).
        lo_column->set_short_text( TEXT-010 ).
        lo_column->set_medium_text( TEXT-011 ).
        lo_column->set_long_text( TEXT-011 ).

        lo_column ?= lo_columns->get_column( TEXT-012 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-013 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-014 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-015 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-023 ).
        lo_column->set_short_text( TEXT-023 ).
        lo_column->set_medium_text( TEXT-023 ).
        lo_column->set_long_text( TEXT-023 ).

        lo_column ?= lo_columns->get_column( TEXT-024 ).
        lo_column->set_short_text( TEXT-024 ).
        lo_column->set_medium_text( TEXT-024 ).
        lo_column->set_long_text( TEXT-024 ).

        lo_column ?= lo_columns->get_column( TEXT-025 ).
        lo_column->set_short_text( TEXT-025 ).
        lo_column->set_medium_text( TEXT-025 ).
        lo_column->set_long_text( TEXT-025 ).

        lo_column ?= lo_columns->get_column( TEXT-026 ).
        lo_column->set_short_text( TEXT-027 ).
        lo_column->set_medium_text( TEXT-028 ).
        lo_column->set_long_text( TEXT-028 ).

        lo_column ?= lo_columns->get_column( TEXT-029 ).
        lo_column->set_short_text( TEXT-030 ).
        lo_column->set_medium_text( TEXT-031 ).
        lo_column->set_long_text( TEXT-031 ).

        lo_column ?= lo_columns->get_column( TEXT-018 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-019 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-020 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-021 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        lo_column ?= lo_columns->get_column( TEXT-022 ).
        lo_column->set_short_text( TEXT-016 ).
        lo_column->set_medium_text( TEXT-017 ).
        lo_column->set_long_text( TEXT-017 ).

        gl_alv->display( ).
        lo_columns->set_optimize( abap_true ).
      ENDIF.
    CATCH cx_salv_not_found INTO lt_salv_not_found.
      lv_errtxt = lt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.

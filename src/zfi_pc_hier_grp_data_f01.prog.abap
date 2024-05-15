*&---------------------------------------------------------------------*
*& Include          ZFI_PC_HIER_GRP_DATA_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form fetch_data
*&---------------------------------------------------------------------*
*& text - Fetching Hierarchy data
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_data .

  TYPES: BEGIN OF ty_kostl,
           kostl TYPE char10,
         END OF ty_kostl.

  DATA: lv_nname   TYPE bapico_group-groupname,
        lt_row     TYPE TABLE OF zfi_ccpc_hierarchy_read,
        lt_row_tmp TYPE TABLE OF zfi_ccpc_hierarchy_read,
        lt_nodes   TYPE TABLE OF bapiset_hier,
        lt_kostl   TYPE TABLE OF ty_kostl,
        ls_kostl   TYPE ty_kostl,
        lv_count   TYPE n,
        lv_prt     TYPE zfi_ccpc_hierarchy_read-parentnode,
        lv_chi     TYPE zfi_ccpc_hierarchy_read-childnode,
        lv_pc      TYPE c,
        lv_data1   TYPE char20,
        lv_data2   TYPE char20.

  IF rb_pc EQ abap_true.
    DATA(lv_intrfc) = c_inf1.
    DATA(lv_rec) = c_rec1.
  ENDIF.
  IF rb_cc EQ abap_true.
    lv_intrfc = c_inf2.
    lv_rec = c_rec2.
  ENDIF.

  LOOP AT s_sname INTO DATA(ls_sname).
    IF ls_sname-sign EQ c_sign_i
      AND ls_sname-option EQ c_opti_eq.
      lv_nname = ls_sname-low.
      IF p_class EQ '0106'.
        lv_pc = 'P'.
      ELSE.
        lv_pc = 'C'.
      ENDIF.
      CALL FUNCTION 'ZFI_CCPC_HIERARCHY_READ'
        EXPORTING
          i_setclass                = p_class
          i_subclass                = p_sclass
          i_setname                 = lv_nname
          i_row                     = abap_true
        TABLES
          output                    = lt_row
          nodes                     = lt_nodes
        EXCEPTIONS
          invalid_setclass          = 1
          invalid_selection_row_col = 2
          invalid_input             = 3
          OTHERS                    = 4.
      IF sy-subrc <> c_cnt0.
      ELSE.
        IF lt_row IS NOT INITIAL.
          LOOP AT lt_nodes INTO DATA(ls_nodes).
            IF ls_nodes-groupname CS '~'.
              SPLIT ls_nodes-groupname AT '~' INTO lv_data1 lv_data2.
              ls_kostl-kostl = |{ lv_data2 ALPHA = IN }|.
              CLEAR:lv_data1,lv_data2.
            ELSE.
              ls_kostl-kostl = ls_nodes-groupname.
            ENDIF.
            IF ls_kostl-kostl NE abap_false.
              APPEND ls_kostl TO lt_kostl.
            ENDIF.
            CLEAR:ls_kostl.
          ENDLOOP.
          IF lt_kostl IS NOT INITIAL.
            SELECT a~prctr,
                   a~ktext,
                   a~ltext,
                   b~verak,
                   b~verak_user,
                   b~waers,
                   b~land1,
                   b~name1,
                   b~name2,
                   b~name3,
                   b~name4,
                   b~ort01,
                   b~ort02,
                   b~stras,
                   b~pstlz,
                   b~regio,
                   b~telf1,
                   b~telf2,
                   b~telfx,
                   b~bukrs,
                   b~txjcd
              FROM cepc AS b
             INNER JOIN cepct AS a                     "#EC CI_BUFFJOIN
                ON a~prctr EQ b~prctr
              INTO TABLE @DATA(lt_pc)
               FOR ALL ENTRIES IN @lt_kostl
             WHERE a~prctr EQ @lt_kostl-kostl.

            SELECT a~kostl,
                   a~ktext,
                   a~ltext,
                   b~verak,
                   b~verak_user,
                   b~waers,
                   b~land1,
                   b~name1,
                   b~name2,
                   b~name3,
                   b~name4,
                   b~ort01,
                   b~ort02,
                   b~stras,
                   b~pstlz,
                   b~regio,
                   b~telf1,
                   b~telf2,
                   b~telfx,
                   b~bukrs,
                   b~txjcd
              FROM csks AS b
             INNER JOIN cskt AS a                      "#EC CI_BUFFJOIN
                ON a~kostl EQ b~kostl
              INTO TABLE @DATA(lt_cc)
               FOR ALL ENTRIES IN @lt_kostl
             WHERE a~kostl EQ @lt_kostl-kostl.
            FREE:lt_kostl,lt_nodes.
          ENDIF.
          LOOP AT lt_row INTO DATA(ls_row).
            gs_data-interface_name = lv_intrfc.
            gs_data-receiver_system = lv_rec.
            IF ls_row-parentnode EQ lv_nname.
              gs_data-pcgrphier = lv_nname.
              DATA(lv_grphier) = gs_data-pcgrphier.
              DATA(lv_hier) = ls_row-childnode.
            ELSE.
              gs_data-pcgrphier = lv_hier.
              lv_grphier = gs_data-pcgrphier.
            ENDIF.
            IF ls_row-parentnode NE abap_false
              AND ls_row-childnode NE abap_false
              AND ls_row-value NE abap_false.
              lv_count = c_cnt2.
              IF lv_prt EQ ls_row-parentnode
                AND lv_chi EQ ls_row-childnode.
                gs_data-parentnode = ls_row-childnode.
                PERFORM get_value_c USING lv_pc ls_row-value CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-ktext.
                lv_count = c_cnt1.
              ELSE.
                gs_data-parentnode = ls_row-parentnode.
                PERFORM get_value_s USING lv_pc ls_row-childnode CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-nodename.
              ENDIF.
            ELSE.
              lv_count = c_cnt1.
              IF ls_row-value NE abap_false.
                IF ls_row-childnode EQ abap_false.
                  gs_data-parentnode = lv_grphier.
                ELSE.
                  gs_data-parentnode = ls_row-childnode.
                ENDIF.
                PERFORM get_value_c USING lv_pc ls_row-value CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-ktext.
              ELSE.
                gs_data-parentnode = ls_row-parentnode.
                PERFORM get_value_s USING lv_pc ls_row-childnode CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-nodename.
              ENDIF.
            ENDIF.
            DO lv_count TIMES.
              IF sy-index EQ c_cnt1
               AND lv_count EQ c_cnt2.
                gs_data-parentnode = ls_row-parentnode.
                PERFORM get_value_s USING lv_pc ls_row-childnode CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-nodename.
                DATA(lv_flag) = abap_true.
                DATA(lv_cn) = gs_data-childnode.
                IF gs_data-childnode CS '~'.
                  SPLIT gs_data-childnode AT '~' INTO lv_data1 lv_data2.
                  gs_data-childnode = lv_data2.
                ENDIF.
                READ TABLE lt_cc
                      INTO DATA(ls_cc)
                  WITH KEY kostl = gs_data-childnode.
                IF sy-subrc EQ c_cnt0.
                  MOVE-CORRESPONDING ls_cc TO gs_data.
                  CLEAR:ls_cc.
                ELSE.
                  READ TABLE lt_pc
                        INTO DATA(ls_pc)
                    WITH KEY prctr = gs_data-childnode.
                  IF sy-subrc EQ c_cnt0.
                    MOVE-CORRESPONDING ls_pc TO gs_data.
                    CLEAR:ls_pc.
                  ENDIF.
                ENDIF.
                gs_data-childnode = lv_cn.
                CLEAR:lv_cn.
              ENDIF.
              IF sy-index EQ c_cnt2
               AND lv_count EQ c_cnt2.
                gs_data-interface_name = lv_intrfc.
                gs_data-receiver_system = lv_rec.
                gs_data-pcgrphier = lv_grphier.
                gs_data-parentnode = ls_row-childnode.
                PERFORM get_value_c USING lv_pc ls_row-value CHANGING gs_data-childnode.
                gs_data-nodename = ls_row-ktext.
              ENDIF.
              IF lv_flag NE abap_true.
                gs_data-ktext = ls_row-ktext.
                gs_data-ltext = ls_row-ltext.
                gs_data-verak = ls_row-verak.
                gs_data-verak_user = ls_row-verak_user.
                gs_data-bukrs = ls_row-bukrs.
                gs_data-waers = ls_row-waers.
                gs_data-txjcd = ls_row-txjcd.
                gs_data-stras = ls_row-stras.
                gs_data-ort01 = ls_row-ort01.
                gs_data-ort02 = ls_row-ort02.
                gs_data-pstlz = ls_row-pstlz.
                gs_data-regio = ls_row-regio.
                gs_data-land1 = ls_row-land1.
                gs_data-name1 = ls_row-name1.
                gs_data-name2 = ls_row-name2.
                gs_data-name3 = ls_row-name3.
                gs_data-name4 = ls_row-name4.
                gs_data-telf1 = ls_row-telf1.
                gs_data-telf2 = ls_row-telf2.
                gs_data-telfx = ls_row-telfx.
              ENDIF.
              IF gs_data-parentnode CS '~'.
                SPLIT gs_data-parentnode AT '~' INTO lv_data1 lv_data2.
                IF lv_data2 NE abap_false.
                  gs_data-parentnode = lv_data2.
                ENDIF.
              ENDIF.
              CLEAR:lv_data1, lv_data2.
              IF gs_data-childnode CS '~'.
                SPLIT gs_data-childnode AT '~' INTO lv_data1 lv_data2.
                IF lv_data2 NE abap_false.
                  gs_data-childnode = lv_data2.
                ENDIF.
              ENDIF.
              CLEAR:lv_data1, lv_data2.
              IF gs_data-pcgrphier CS '~'.
                SPLIT gs_data-pcgrphier AT '~' INTO lv_data1 lv_data2.
                IF lv_data2 NE abap_false.
                  gs_data-pcgrphier = lv_data2.
                ENDIF.
              ENDIF.
              CLEAR:lv_data1, lv_data2.
              APPEND gs_data TO gt_data.
              MOVE-CORRESPONDING gs_data TO gs_output.
              APPEND gs_output TO gt_output.
              IF lv_count EQ c_cnt2.
                lv_prt = ls_row-parentnode.
                lv_chi = ls_row-childnode.
              ENDIF.
              CLEAR:gs_data, gs_output,lv_flag.
            ENDDO.
            CLEAR:lv_count.
          ENDLOOP.

        ENDIF.
        REFRESH: lt_row[].
      ENDIF.
    ENDIF.
    CLEAR:lv_nname.
  ENDLOOP.
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
      DATA(lr_send) = NEW zco_fi_pc_grp_data( ).
      IF lr_send IS BOUND.
        gs_out-fi_pc_grp_data_mt-zdata_hierarchy[] = gt_data[].
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
        IF rb_pc EQ abap_true.
          lo_column->set_short_text( TEXT-007 ).
          lo_column->set_medium_text( TEXT-008 ).
          lo_column->set_long_text( TEXT-009 ).
          lo_column ?= lo_columns->get_column( TEXT-010 ).
          lo_column->set_short_text( TEXT-011 ).
          lo_column->set_medium_text( TEXT-012 ).
          lo_column->set_long_text( TEXT-013 ).
        ENDIF.
        IF rb_cc EQ abap_true.
          lo_column->set_short_text( TEXT-014 ).
          lo_column->set_medium_text( TEXT-015 ).
          lo_column->set_long_text( TEXT-016 ).
          lo_column ?= lo_columns->get_column( TEXT-017 ).
          lo_column->set_short_text( TEXT-011 ).
          lo_column->set_medium_text( TEXT-012 ).
          lo_column->set_long_text( TEXT-018 ).
        ENDIF.
        lo_column ?= lo_columns->get_column( TEXT-019 ).
        lo_column->set_short_text( TEXT-020 ).
        lo_column->set_medium_text( TEXT-021 ).
        lo_column->set_long_text( TEXT-021 ).

        lo_column ?= lo_columns->get_column( TEXT-022 ).
        lo_column->set_short_text( TEXT-023 ).
        lo_column->set_medium_text( TEXT-023 ).
        lo_column->set_long_text( TEXT-023 ).

        lo_column ?= lo_columns->get_column( TEXT-024 ).
        lo_column->set_short_text( TEXT-025 ).
        lo_column->set_medium_text( TEXT-025 ).
        lo_column->set_long_text( TEXT-025 ).

        lo_column ?= lo_columns->get_column( TEXT-026 ).
        lo_column->set_short_text( TEXT-027 ).
        lo_column->set_medium_text( TEXT-028 ).
        lo_column->set_long_text( TEXT-028 ).

        gl_alv->display( ).
        lo_columns->set_optimize( abap_true ).
      ENDIF.
    CATCH cx_salv_not_found INTO lt_salv_not_found.
      lv_errtxt = lt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_value_c
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PC
*&      --> LS_ROW_VALUE
*&      <-- GS_DATA_CHILDNODE
*&---------------------------------------------------------------------*
FORM get_value_c  USING    p_lv_pc TYPE c
                         p_ls_row_value TYPE char10
                CHANGING p_childnode TYPE string.

  DATA:lt_CCPC    TYPE STANDARD TABLE OF zfi_pccenters.

  REFRESH:lt_ccpc.
  CALL FUNCTION 'ZCA_OUTPUT_PC'
    EXPORTING
      iv_pcenters = p_ls_row_value
      iv_pc_flag  = p_lv_pc
    TABLES
      et_output   = lt_ccpc.
  READ TABLE lt_CCPC INTO DATA(ls_ccpc) INDEX 1.
  IF sy-subrc IS INITIAL.
    p_childnode = ls_ccpc-numbr.
    CLEAR:ls_ccpc.
  ELSE.
    p_childnode = p_ls_row_value.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_value_s
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PC
*&      --> LS_ROW_VALUE
*&      <-- GS_DATA_CHILDNODE
*&---------------------------------------------------------------------*
FORM get_value_s  USING    p_lv_pc TYPE c
                         p_ls_row_value TYPE char15
                CHANGING p_childnode TYPE string.

  DATA:lt_CCPC TYPE STANDARD TABLE OF zfi_pccenters,
       lv_ccpc TYPE char10.

  REFRESH:lt_ccpc.
  lv_ccpc = p_ls_row_value.
  CALL FUNCTION 'ZCA_OUTPUT_PC'
    EXPORTING
      iv_pcenters = lv_ccpc
      iv_pc_flag  = p_lv_pc
    TABLES
      et_output   = lt_ccpc.
  READ TABLE lt_CCPC INTO DATA(ls_ccpc) INDEX 1.
  IF sy-subrc IS INITIAL.
    p_childnode = ls_ccpc-numbr.
    CLEAR:ls_ccpc.
  ELSE.
    p_childnode = p_ls_row_value.
  ENDIF.

ENDFORM.

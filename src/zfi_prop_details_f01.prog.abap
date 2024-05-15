*&---------------------------------------------------------------------*
*& Include          ZFI_PROP_DETAILS_F01
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

  DATA: ls_dis  TYPE ty_output,
        ls_sdis TYPE ty_output,
        ls_reg  TYPE ty_output,
        ls_srm  TYPE ty_output,
        ls_div  TYPE ty_output.
  IF rb_pc EQ abap_true.
    DATA(lv_intrfc) = c_inf1.
    DATA(lv_rec) = c_rec1.
  ENDIF.
  IF rb_cc EQ abap_true.
    lv_intrfc = c_inf2.
    lv_rec = c_rec2.
  ENDIF.

  s_sname-low = 'PS_DRA'.
  s_sname-sign = c_sign_i.
  s_sname-option = c_opti_eq.
  APPEND s_sname.

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
*              APPEND gs_data TO gt_data.
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

  SELECT  legacy_property_number,
          description,
          street,
          city,
          state,
          postal_code,
          county,
          direct_phone_no,
          published_phone_no,
          fax_number
      FROM zproperty
      INTO TABLE @DATA(lt_zprop)
      WHERE legacy_property_number IN @s_prop.
  IF sy-subrc IS INITIAL.

    LOOP AT lt_zprop INTO DATA(ls_zprop).
      MOVE-CORRESPONDING ls_zprop TO gs_rep_output.
      READ TABLE gt_output INTO DATA(ls_pr) WITH KEY childnode = ls_zprop-legacy_property_number.
      IF sy-subrc IS INITIAL.
*        MOVE-CORRESPONDING ls_pr TO gs_rep_output.

        READ TABLE gt_output INTO DATA(ls_step1) WITH KEY pcgrphier = ls_pr-pcgrphier childnode = ls_pr-parentnode .
        IF sy-subrc IS INITIAL.

          IF ls_step1-childnode+0(3) = 'DIV'.
            ls_div = ls_step1.
          ELSEIF ls_step1-childnode+0(2) = 'SD'.
            ls_sdis = ls_step1.
          ELSEIF ls_step1-childnode+0(1) = 'R'.
            ls_reg = ls_step1.
          ELSEIF ls_step1-childnode+0(1) = 'S'.
            ls_srm = ls_step1.
          ELSEIF ls_step1-childnode+0(1) = 'D'.
            ls_dis = ls_step1.
          ENDIF.
        ENDIF.

        READ TABLE gt_output INTO DATA(ls_step2) WITH KEY pcgrphier = ls_dis-pcgrphier  childnode = ls_dis-parentnode.
        IF sy-subrc IS INITIAL.

          IF ls_step2-childnode+0(3) = 'DIV'.
            ls_div = ls_step2.
          ELSEIF ls_step2-childnode+0(2) = 'SD'.
            ls_sdis = ls_step2.
          ELSEIF ls_step2-childnode+0(1) = 'R'.
            ls_reg = ls_step2.
          ELSEIF ls_step2-childnode+0(1) = 'S'.
            ls_srm = ls_step2.
          ELSEIF ls_step2-childnode+0(1) = 'D'.
            ls_dis = ls_step2.
          ENDIF.
        ENDIF.

        READ TABLE gt_output INTO DATA(ls_step3) WITH KEY pcgrphier = ls_sdis-pcgrphier childnode = ls_sdis-parentnode.
        IF sy-subrc IS INITIAL.

          IF ls_step3-childnode+0(3) = 'DIV'.
            ls_div = ls_step3.
          ELSEIF ls_step3-childnode+0(2) = 'SD'.
            ls_sdis = ls_step3.
          ELSEIF ls_step3-childnode+0(1) = 'R'.
            ls_reg = ls_step3.
          ELSEIF ls_step3-childnode+0(1) = 'S'.
            ls_srm = ls_step3.
          ELSEIF ls_step3-childnode+0(1) = 'D'.
            ls_dis = ls_step3.
          ENDIF.
        ENDIF.

        READ TABLE gt_output INTO DATA(ls_step4) WITH KEY pcgrphier = ls_reg-pcgrphier childnode = ls_reg-parentnode.
        IF sy-subrc IS INITIAL.

          IF ls_step4-childnode+0(3) = 'DIV'.
            ls_div = ls_step4.
          ELSEIF ls_step4-childnode+0(2) = 'SD'.
            ls_sdis = ls_step4.
          ELSEIF ls_step4-childnode+0(1) = 'R'.
            ls_reg = ls_step4.
          ELSEIF ls_step4-childnode+0(1) = 'S'.
            ls_srm = ls_step4.
          ELSEIF ls_step4-childnode+0(1) = 'D'.
            ls_dis = ls_step4.
          ENDIF.
        ENDIF.

        READ TABLE gt_output INTO DATA(ls_step5) WITH KEY pcgrphier = ls_srm-pcgrphier childnode = ls_srm-parentnode.
        IF sy-subrc IS INITIAL.

          IF ls_step5-childnode+0(3) = 'DIV'.
            ls_div = ls_step5.
          ELSEIF ls_step5-childnode+0(2) = 'SD'.
            ls_sdis = ls_step5.
          ELSEIF ls_step5-childnode+0(1) = 'R'.
            ls_reg = ls_step5.
          ELSEIF ls_step5-childnode+0(1) = 'S'.
            ls_srm = ls_step5.
          ELSEIF ls_step5-childnode+0(1) = 'D'.
            ls_dis = ls_step5.
          ENDIF.
        ENDIF.

      ENDIF.

      IF ls_dis IS NOT INITIAL.
        gs_rep_output-dist_prop = ls_dis-childnode.
        gs_rep_output-dist_ltext = ls_dis-ltext.
        gs_rep_output-dist_verak = ls_dis-verak.
        gs_rep_output-dist_stras = ls_dis-stras.
        gs_rep_output-dist_ort01 = ls_dis-ort01.
        gs_rep_output-dist_pstlz = ls_dis-pstlz.
        gs_rep_output-dist_regio = ls_dis-regio.
        gs_rep_output-dist_telf1 = ls_dis-telf1.
        gs_rep_output-dist_telf2 = ls_dis-telf2.
        gs_rep_output-dist_telfx = ls_dis-telfx.
        gs_rep_output-dist_name1 = ls_dis-name3.
        gs_rep_output-dist_name4 = ls_dis-name4.
      ENDIF.
      IF ls_sdis IS NOT INITIAL.
        gs_rep_output-sr_dist_prop = ls_sdis-childnode.
        gs_rep_output-sr_ltext = ls_sdis-ltext.
        gs_rep_output-sr_verak = ls_sdis-verak.
        gs_rep_output-sr_stras = ls_sdis-stras.
        gs_rep_output-sr_ort01 = ls_sdis-ort01.
        gs_rep_output-sr_pstlz = ls_sdis-pstlz.
        gs_rep_output-sr_regio = ls_sdis-regio.
        gs_rep_output-sr_telf1 = ls_sdis-telf1.
        gs_rep_output-sr_telf2 = ls_sdis-telf2.
        gs_rep_output-sr_telfx = ls_sdis-telfx.
        gs_rep_output-sr_name1 = ls_sdis-name3.
        gs_rep_output-sr_name4 = ls_sdis-name4.
      ENDIF.
      IF ls_reg IS NOT INITIAL.
        gs_rep_output-reg_prop = ls_reg-childnode.
        gs_rep_output-reg_ltext = ls_reg-ltext.
        gs_rep_output-reg_verak = ls_reg-verak.
        gs_rep_output-reg_stras = ls_reg-stras.
        gs_rep_output-reg_ort01 = ls_reg-ort01.
        gs_rep_output-reg_pstlz = ls_reg-pstlz.
        gs_rep_output-reg_regio = ls_reg-regio.
        gs_rep_output-reg_telf1 = ls_reg-telf1.
        gs_rep_output-reg_telf2 = ls_reg-telf2.
        gs_rep_output-reg_telfx = ls_reg-telfx.
        gs_rep_output-reg_name1 = ls_reg-name3.
        gs_rep_output-reg_name4 = ls_reg-name4.
      ENDIF.
      IF ls_srm IS NOT INITIAL.
        gs_rep_output-srm_prop = ls_srm-childnode.
        gs_rep_output-srm_ltext = ls_srm-ltext.
        gs_rep_output-srm_verak = ls_srm-verak.
        gs_rep_output-srm_stras = ls_srm-stras.
        gs_rep_output-srm_ort01 = ls_srm-ort01.
        gs_rep_output-srm_pstlz = ls_srm-pstlz.
        gs_rep_output-srm_regio = ls_srm-regio.
        gs_rep_output-srm_telf1 = ls_srm-telf1.
        gs_rep_output-srm_telf2 = ls_srm-telf2.
        gs_rep_output-srm_telfx = ls_srm-telfx.
        gs_rep_output-srm_name1 = ls_srm-name3.
        gs_rep_output-srm_name4 = ls_srm-name4.
      ENDIF.
      IF ls_div IS NOT INITIAL.
        gs_rep_output-div_prop = ls_div-childnode.
        gs_rep_output-div_ltext = ls_div-ltext.
        gs_rep_output-div_verak = ls_div-verak.
        gs_rep_output-div_stras = ls_div-stras.
        gs_rep_output-div_ort01 = ls_div-ort01.
        gs_rep_output-div_pstlz = ls_div-pstlz.
        gs_rep_output-div_regio = ls_div-regio.
        gs_rep_output-div_telf1 = ls_div-telf1.
        gs_rep_output-div_telf2 = ls_div-telf2.
        gs_rep_output-div_telfx = ls_div-telfx.
        gs_rep_output-div_name1 = ls_div-name3.
        gs_rep_output-div_name4 = ls_div-name4.
      ENDIF.

      APPEND gs_rep_output TO gt_rep_output.
      CLEAR: gs_rep_output, ls_zprop, ls_step1, ls_step2, ls_step3, ls_step4, ls_step5, ls_pr, ls_dis, ls_sdis, ls_reg, ls_srm, ls_div.
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
                              CHANGING  t_table      = gt_rep_output ).
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
*        lo_column ?= lo_columns->get_column( TEXT-006 ).
*        IF rb_pc EQ abap_true.
*          lo_column->set_short_text( TEXT-007 ).
*          lo_column->set_medium_text( TEXT-008 ).
*          lo_column->set_long_text( TEXT-009 ).
*          lo_column ?= lo_columns->get_column( TEXT-010 ).
*          lo_column->set_short_text( TEXT-011 ).
*          lo_column->set_medium_text( TEXT-012 ).
*          lo_column->set_long_text( TEXT-013 ).
*        ENDIF.
*        IF rb_cc EQ abap_true.
*          lo_column->set_short_text( TEXT-014 ).
*          lo_column->set_medium_text( TEXT-015 ).
*          lo_column->set_long_text( TEXT-016 ).
*          lo_column ?= lo_columns->get_column( TEXT-017 ).
*          lo_column->set_short_text( TEXT-011 ).
*          lo_column->set_medium_text( TEXT-012 ).
*          lo_column->set_long_text( TEXT-018 ).
*        ENDIF.
*        lo_column ?= lo_columns->get_column( TEXT-019 ).
*        lo_column->set_short_text( TEXT-020 ).
*        lo_column->set_medium_text( TEXT-021 ).
*        lo_column->set_long_text( TEXT-021 ).
*
*        lo_column ?= lo_columns->get_column( TEXT-022 ).
*        lo_column->set_short_text( TEXT-023 ).
*        lo_column->set_medium_text( TEXT-023 ).
*        lo_column->set_long_text( TEXT-023 ).
*
*        lo_column ?= lo_columns->get_column( TEXT-024 ).
*        lo_column->set_short_text( TEXT-025 ).
*        lo_column->set_medium_text( TEXT-025 ).
*        lo_column->set_long_text( TEXT-025 ).
*
*        lo_column ?= lo_columns->get_column( TEXT-026 ).
*        lo_column->set_short_text( TEXT-027 ).
*        lo_column->set_medium_text( TEXT-028 ).
*        lo_column->set_long_text( TEXT-028 ).



*        lo_column ?= lo_columns->get_column( TEXT-029 ).
*        lo_column->set_long_text( TEXT-079 )."
*        lo_column ?= lo_columns->get_column( TEXT-030 ).
*        lo_column->set_long_text( TEXT-080 )."
*        lo_column ?= lo_columns->get_column( TEXT-031 ).
*        lo_column->set_long_text( TEXT-081 )."
*        lo_column ?= lo_columns->get_column( TEXT-032 ).
*        lo_column->set_long_text( TEXT-082 )."
*        lo_column ?= lo_columns->get_column( TEXT-033 ).
*        lo_column->set_long_text( TEXT-083 )."
*        lo_column ?= lo_columns->get_column( TEXT-034 ).
*        lo_column->set_long_text( TEXT-084 )."
*        lo_column ?= lo_columns->get_column( TEXT-035 ).
*        lo_column->set_long_text( TEXT-085 )."
*        lo_column ?= lo_columns->get_column( TEXT-036 ).
*        lo_column->set_long_text( TEXT-086 )."
*        lo_column ?= lo_columns->get_column( TEXT-037 ).
*        lo_column->set_long_text( TEXT-087 )."
*        lo_column ?= lo_columns->get_column( TEXT-038 ).
*        lo_column->set_long_text( TEXT-088 )."
*        lo_column ?= lo_columns->get_column( TEXT-039 ).
*        lo_column->set_long_text( TEXT-089 )."
*        lo_column ?= lo_columns->get_column( TEXT-040 ).
*        lo_column->set_long_text( TEXT-090 )."
*        lo_column ?= lo_columns->get_column( TEXT-041 ).
*        lo_column->set_long_text( TEXT-091 )."
*        lo_column ?= lo_columns->get_column( TEXT-042 ).
*        lo_column->set_long_text( TEXT-092 )."
*        lo_column ?= lo_columns->get_column( TEXT-043 ).
*        lo_column->set_long_text( TEXT-093 )."
*        lo_column ?= lo_columns->get_column( TEXT-044 ).
*        lo_column->set_long_text( TEXT-094 )."
*        lo_column ?= lo_columns->get_column( TEXT-045 ).
*        lo_column->set_long_text( TEXT-095 )."
*        lo_column ?= lo_columns->get_column( TEXT-046 ).
*        lo_column->set_long_text( TEXT-096 )."
*        lo_column ?= lo_columns->get_column( TEXT-047 ).
*        lo_column->set_long_text( TEXT-097 )."
*        lo_column ?= lo_columns->get_column( TEXT-048 ).
*        lo_column->set_long_text( TEXT-098 )."
*        lo_column ?= lo_columns->get_column( TEXT-049 ).
*        lo_column->set_long_text( TEXT-099 )."
*        lo_column ?= lo_columns->get_column( TEXT-050 ).
*        lo_column->set_long_text( TEXT-100 )."
*        lo_column ?= lo_columns->get_column( TEXT-051 ).
*        lo_column->set_long_text( TEXT-101 )."
*        lo_column ?= lo_columns->get_column( TEXT-052 ).
*        lo_column->set_long_text( TEXT-102 )."
*        lo_column ?= lo_columns->get_column( TEXT-053 ).
*        lo_column->set_long_text( TEXT-103 )."
*        lo_column ?= lo_columns->get_column( TEXT-054 ).
*        lo_column->set_long_text( TEXT-104 )."
*        lo_column ?= lo_columns->get_column( TEXT-055 ).
*        lo_column->set_long_text( TEXT-105 )."
*        lo_column ?= lo_columns->get_column( TEXT-056 ).
*        lo_column->set_long_text( TEXT-106 )."
*        lo_column ?= lo_columns->get_column( TEXT-057 ).
*        lo_column->set_long_text( TEXT-107 )."
*        lo_column ?= lo_columns->get_column( TEXT-058 ).
*        lo_column->set_long_text( TEXT-108 )."
*        lo_column ?= lo_columns->get_column( TEXT-059 ).
*        lo_column->set_long_text( TEXT-109 )."
*        lo_column ?= lo_columns->get_column( TEXT-060 ).
*        lo_column->set_long_text( TEXT-110 )."
*        lo_column ?= lo_columns->get_column( TEXT-061 ).
*        lo_column->set_long_text( TEXT-111 )."
*        lo_column ?= lo_columns->get_column( TEXT-062 ).
*        lo_column->set_long_text( TEXT-112 )."
*        lo_column ?= lo_columns->get_column( TEXT-063 ).
*        lo_column->set_long_text( TEXT-113 )."
*        lo_column ?= lo_columns->get_column( TEXT-064 ).
*        lo_column->set_long_text( TEXT-114 )."
*        lo_column ?= lo_columns->get_column( TEXT-065 ).
*        lo_column->set_long_text( TEXT-115 )."
*        lo_column ?= lo_columns->get_column( TEXT-066 ).
*        lo_column->set_long_text( TEXT-116 )."
*        lo_column ?= lo_columns->get_column( TEXT-067 ).
*        lo_column->set_long_text( TEXT-117 )."
*        lo_column ?= lo_columns->get_column( TEXT-068 ).
*        lo_column->set_long_text( TEXT-118 )."
*        lo_column ?= lo_columns->get_column( TEXT-069 ).
*        lo_column->set_long_text( TEXT-119 )."
*        lo_column ?= lo_columns->get_column( TEXT-070 ).
*        lo_column->set_long_text( TEXT-120 )."
*        lo_column ?= lo_columns->get_column( TEXT-071 ).
*        lo_column->set_long_text( TEXT-121 )."
*        lo_column ?= lo_columns->get_column( TEXT-072 ).
*        lo_column->set_long_text( TEXT-122 )."
*        lo_column ?= lo_columns->get_column( TEXT-073 ).
*        lo_column->set_long_text( TEXT-123 )."
*        lo_column ?= lo_columns->get_column( TEXT-074 ).
*        lo_column->set_long_text( TEXT-124 )."
*        lo_column ?= lo_columns->get_column( TEXT-075 ).
*        lo_column->set_long_text( TEXT-125 )."
*        lo_column ?= lo_columns->get_column( TEXT-076 ).
*        lo_column->set_long_text( TEXT-126 )."
*        lo_column ?= lo_columns->get_column( TEXT-077 ).
*        lo_column->set_long_text( TEXT-127 )."
*        lo_column ?= lo_columns->get_column( TEXT-078 ).
*        lo_column->set_long_text( TEXT-128 )."



        lo_column ?= lo_columns->get_column( TEXT-029 ).
        lo_column->set_long_text( TEXT-079 ).
        lo_column->set_short_text( TEXT-129 ).
        lo_column->set_medium_text( TEXT-179 ).
        lo_column ?= lo_columns->get_column( TEXT-030 ).
        lo_column->set_long_text( TEXT-080 ).
        lo_column->set_short_text( TEXT-130 ).
        lo_column->set_medium_text( TEXT-180 ).
        lo_column ?= lo_columns->get_column( TEXT-031 ).
        lo_column->set_long_text( TEXT-081 ).
        lo_column->set_short_text( TEXT-131 ).
        lo_column->set_medium_text( TEXT-181 ).
        lo_column->set_visible( value = if_salv_c_bool_sap=>false ).
        lo_column ?= lo_columns->get_column( TEXT-032 ).
        lo_column->set_long_text( TEXT-082 ).
        lo_column->set_short_text( TEXT-132 ).
        lo_column->set_medium_text( TEXT-182 ).
        lo_column ?= lo_columns->get_column( TEXT-033 ).
        lo_column->set_long_text( TEXT-083 ).
        lo_column->set_short_text( TEXT-133 ).
        lo_column->set_medium_text( TEXT-183 ).
        lo_column ?= lo_columns->get_column( TEXT-034 ).
        lo_column->set_long_text( TEXT-084 ).
        lo_column->set_short_text( TEXT-134 ).
        lo_column->set_medium_text( TEXT-184 ).
        lo_column ?= lo_columns->get_column( TEXT-035 ).
        lo_column->set_long_text( TEXT-085 ).
        lo_column->set_short_text( TEXT-135 ).
        lo_column->set_medium_text( TEXT-185 ).
        lo_column ?= lo_columns->get_column( TEXT-036 ).
        lo_column->set_long_text( TEXT-086 ).
        lo_column->set_short_text( TEXT-136 ).
        lo_column->set_medium_text( TEXT-186 ).
        lo_column ?= lo_columns->get_column( TEXT-037 ).
        lo_column->set_long_text( TEXT-087 ).
        lo_column->set_short_text( TEXT-137 ).
        lo_column->set_medium_text( TEXT-187 ).
        lo_column ?= lo_columns->get_column( TEXT-038 ).
        lo_column->set_long_text( TEXT-088 ).
        lo_column->set_short_text( TEXT-138 ).
        lo_column->set_medium_text( TEXT-188 ).
        lo_column ?= lo_columns->get_column( TEXT-039 ).
        lo_column->set_long_text( TEXT-089 ).
        lo_column->set_short_text( TEXT-139 ).
        lo_column->set_medium_text( TEXT-189 ).
        lo_column ?= lo_columns->get_column( TEXT-040 ).
        lo_column->set_long_text( TEXT-090 ).
        lo_column->set_short_text( TEXT-140 ).
        lo_column->set_medium_text( TEXT-190 ).
        lo_column ?= lo_columns->get_column( TEXT-041 ).
        lo_column->set_long_text( TEXT-091 ).
        lo_column->set_short_text( TEXT-141 ).
        lo_column->set_medium_text( TEXT-191 ).
        lo_column->set_visible( value = if_salv_c_bool_sap=>false ).
        lo_column ?= lo_columns->get_column( TEXT-042 ).
        lo_column->set_long_text( TEXT-092 ).
        lo_column->set_short_text( TEXT-142 ).
        lo_column->set_medium_text( TEXT-192 ).
        lo_column ?= lo_columns->get_column( TEXT-043 ).
        lo_column->set_long_text( TEXT-093 ).
        lo_column->set_short_text( TEXT-143 ).
        lo_column->set_medium_text( TEXT-193 ).
        lo_column ?= lo_columns->get_column( TEXT-044 ).
        lo_column->set_long_text( TEXT-094 ).
        lo_column->set_short_text( TEXT-144 ).
        lo_column->set_medium_text( TEXT-194 ).
        lo_column ?= lo_columns->get_column( TEXT-045 ).
        lo_column->set_long_text( TEXT-095 ).
        lo_column->set_short_text( TEXT-145 ).
        lo_column->set_medium_text( TEXT-195 ).
        lo_column ?= lo_columns->get_column( TEXT-046 ).
        lo_column->set_long_text( TEXT-096 ).
        lo_column->set_short_text( TEXT-146 ).
        lo_column->set_medium_text( TEXT-196 ).
        lo_column ?= lo_columns->get_column( TEXT-047 ).
        lo_column->set_long_text( TEXT-097 ).
        lo_column->set_short_text( TEXT-147 ).
        lo_column->set_medium_text( TEXT-197 ).
        lo_column ?= lo_columns->get_column( TEXT-048 ).
        lo_column->set_long_text( TEXT-098 ).
        lo_column->set_short_text( TEXT-148 ).
        lo_column->set_medium_text( TEXT-198 ).
        lo_column ?= lo_columns->get_column( TEXT-049 ).
        lo_column->set_long_text( TEXT-099 ).
        lo_column->set_short_text( TEXT-149 ).
        lo_column->set_medium_text( TEXT-199 ).
        lo_column ?= lo_columns->get_column( TEXT-050 ).
        lo_column->set_long_text( TEXT-100 ).
        lo_column->set_short_text( TEXT-150 ).
        lo_column->set_medium_text( TEXT-200 ).
        lo_column ?= lo_columns->get_column( TEXT-051 ).
        lo_column->set_long_text( TEXT-101 ).
        lo_column->set_short_text( TEXT-151 ).
        lo_column->set_medium_text( TEXT-201 ).
        lo_column->set_visible( value = if_salv_c_bool_sap=>false ).
        lo_column ?= lo_columns->get_column( TEXT-052 ).
        lo_column->set_long_text( TEXT-102 ).
        lo_column->set_short_text( TEXT-152 ).
        lo_column->set_medium_text( TEXT-202 ).
        lo_column ?= lo_columns->get_column( TEXT-053 ).
        lo_column->set_long_text( TEXT-103 ).
        lo_column->set_short_text( TEXT-153 ).
        lo_column->set_medium_text( TEXT-203 ).
        lo_column ?= lo_columns->get_column( TEXT-054 ).
        lo_column->set_long_text( TEXT-104 ).
        lo_column->set_short_text( TEXT-154 ).
        lo_column->set_medium_text( TEXT-204 ).
        lo_column ?= lo_columns->get_column( TEXT-055 ).
        lo_column->set_long_text( TEXT-105 ).
        lo_column->set_short_text( TEXT-155 ).
        lo_column->set_medium_text( TEXT-205 ).
        lo_column ?= lo_columns->get_column( TEXT-056 ).
        lo_column->set_long_text( TEXT-106 ).
        lo_column->set_short_text( TEXT-156 ).
        lo_column->set_medium_text( TEXT-206 ).
        lo_column ?= lo_columns->get_column( TEXT-057 ).
        lo_column->set_long_text( TEXT-107 ).
        lo_column->set_short_text( TEXT-157 ).
        lo_column->set_medium_text( TEXT-207 ).
        lo_column ?= lo_columns->get_column( TEXT-058 ).
        lo_column->set_long_text( TEXT-108 ).
        lo_column->set_short_text( TEXT-158 ).
        lo_column->set_medium_text( TEXT-208 ).
        lo_column ?= lo_columns->get_column( TEXT-059 ).
        lo_column->set_long_text( TEXT-109 ).
        lo_column->set_short_text( TEXT-159 ).
        lo_column->set_medium_text( TEXT-209 ).
        lo_column ?= lo_columns->get_column( TEXT-060 ).
        lo_column->set_long_text( TEXT-110 ).
        lo_column->set_short_text( TEXT-160 ).
        lo_column->set_medium_text( TEXT-210 ).
        lo_column ?= lo_columns->get_column( TEXT-061 ).
        lo_column->set_long_text( TEXT-111 ).
        lo_column->set_short_text( TEXT-161 ).
        lo_column->set_medium_text( TEXT-211 ).
        lo_column->set_visible( value = if_salv_c_bool_sap=>false ).
        lo_column ?= lo_columns->get_column( TEXT-062 ).
        lo_column->set_long_text( TEXT-112 ).
        lo_column->set_short_text( TEXT-162 ).
        lo_column->set_medium_text( TEXT-212 ).
        lo_column ?= lo_columns->get_column( TEXT-063 ).
        lo_column->set_long_text( TEXT-113 ).
        lo_column->set_short_text( TEXT-163 ).
        lo_column->set_medium_text( TEXT-213 ).
        lo_column ?= lo_columns->get_column( TEXT-064 ).
        lo_column->set_long_text( TEXT-114 ).
        lo_column->set_short_text( TEXT-164 ).
        lo_column->set_medium_text( TEXT-214 ).
        lo_column ?= lo_columns->get_column( TEXT-065 ).
        lo_column->set_long_text( TEXT-115 ).
        lo_column->set_short_text( TEXT-165 ).
        lo_column->set_medium_text( TEXT-215 ).
        lo_column ?= lo_columns->get_column( TEXT-066 ).
        lo_column->set_long_text( TEXT-116 ).
        lo_column->set_short_text( TEXT-166 ).
        lo_column->set_medium_text( TEXT-216 ).
        lo_column ?= lo_columns->get_column( TEXT-067 ).
        lo_column->set_long_text( TEXT-117 ).
        lo_column->set_short_text( TEXT-167 ).
        lo_column->set_medium_text( TEXT-217 ).
        lo_column ?= lo_columns->get_column( TEXT-068 ).
        lo_column->set_long_text( TEXT-118 ).
        lo_column->set_short_text( TEXT-168 ).
        lo_column->set_medium_text( TEXT-218 ).
        lo_column ?= lo_columns->get_column( TEXT-069 ).
        lo_column->set_long_text( TEXT-119 ).
        lo_column->set_short_text( TEXT-169 ).
        lo_column->set_medium_text( TEXT-219 ).
        lo_column ?= lo_columns->get_column( TEXT-070 ).
        lo_column->set_long_text( TEXT-120 ).
        lo_column->set_short_text( TEXT-170 ).
        lo_column->set_medium_text( TEXT-220 ).
        lo_column ?= lo_columns->get_column( TEXT-071 ).
        lo_column->set_long_text( TEXT-121 ).
        lo_column->set_short_text( TEXT-171 ).
        lo_column->set_medium_text( TEXT-221 ).
        lo_column->set_visible( value = if_salv_c_bool_sap=>false ).
        lo_column ?= lo_columns->get_column( TEXT-072 ).
        lo_column->set_long_text( TEXT-122 ).
        lo_column->set_short_text( TEXT-172 ).
        lo_column->set_medium_text( TEXT-222 ).
        lo_column ?= lo_columns->get_column( TEXT-073 ).
        lo_column->set_long_text( TEXT-123 ).
        lo_column->set_short_text( TEXT-173 ).
        lo_column->set_medium_text( TEXT-223 ).
        lo_column ?= lo_columns->get_column( TEXT-074 ).
        lo_column->set_long_text( TEXT-124 ).
        lo_column->set_short_text( TEXT-174 ).
        lo_column->set_medium_text( TEXT-224 ).
        lo_column ?= lo_columns->get_column( TEXT-075 ).
        lo_column->set_long_text( TEXT-125 ).
        lo_column->set_short_text( TEXT-175 ).
        lo_column->set_medium_text( TEXT-225 ).
        lo_column ?= lo_columns->get_column( TEXT-076 ).
        lo_column->set_long_text( TEXT-126 ).
        lo_column->set_short_text( TEXT-176 ).
        lo_column->set_medium_text( TEXT-226 ).
        lo_column ?= lo_columns->get_column( TEXT-077 ).
        lo_column->set_long_text( TEXT-127 ).
        lo_column->set_short_text( TEXT-177 ).
        lo_column->set_medium_text( TEXT-227 ).
        lo_column ?= lo_columns->get_column( TEXT-078 ).
        lo_column->set_long_text( TEXT-128 ).
        lo_column->set_short_text( TEXT-178 ).
        lo_column->set_medium_text( TEXT-228 ).


        lo_column ?= lo_columns->get_column( TEXT-229 ).
        lo_column->set_long_text( TEXT-244 ).
        lo_column->set_short_text( TEXT-259 ).
        lo_column->set_medium_text( TEXT-274 ).
        lo_column ?= lo_columns->get_column( TEXT-230 ).
        lo_column->set_long_text( TEXT-245 ).
        lo_column->set_short_text( TEXT-260 ).
        lo_column->set_medium_text( TEXT-275 ).
        lo_column ?= lo_columns->get_column( TEXT-231 ).
        lo_column->set_long_text( TEXT-246 ).
        lo_column->set_short_text( TEXT-261 ).
        lo_column->set_medium_text( TEXT-276 ).
        lo_column ?= lo_columns->get_column( TEXT-232 ).
        lo_column->set_long_text( TEXT-247 ).
        lo_column->set_short_text( TEXT-262 ).
        lo_column->set_medium_text( TEXT-277 ).
        lo_column ?= lo_columns->get_column( TEXT-233 ).
        lo_column->set_long_text( TEXT-248 ).
        lo_column->set_short_text( TEXT-263 ).
        lo_column->set_medium_text( TEXT-278 ).
        lo_column ?= lo_columns->get_column( TEXT-234 ).
        lo_column->set_long_text( TEXT-249 ).
        lo_column->set_short_text( TEXT-264 ).
        lo_column->set_medium_text( TEXT-279 ).
        lo_column ?= lo_columns->get_column( TEXT-235 ).
        lo_column->set_long_text( TEXT-250 ).
        lo_column->set_short_text( TEXT-265 ).
        lo_column->set_medium_text( TEXT-280 ).
        lo_column ?= lo_columns->get_column( TEXT-236 ).
        lo_column->set_long_text( TEXT-251 ).
        lo_column->set_short_text( TEXT-266 ).
        lo_column->set_medium_text( TEXT-281 ).
        lo_column ?= lo_columns->get_column( TEXT-237 ).
        lo_column->set_long_text( TEXT-252 ).
        lo_column->set_short_text( TEXT-267 ).
        lo_column->set_medium_text( TEXT-282 ).
        lo_column ?= lo_columns->get_column( TEXT-238 ).
        lo_column->set_long_text( TEXT-253 ).
        lo_column->set_short_text( TEXT-268 ).
        lo_column->set_medium_text( TEXT-283 ).
        lo_column ?= lo_columns->get_column( TEXT-239 ).
        lo_column->set_long_text( TEXT-254 ).
        lo_column->set_short_text( TEXT-269 ).
        lo_column->set_medium_text( TEXT-284 ).
        lo_column ?= lo_columns->get_column( TEXT-240 ).
        lo_column->set_long_text( TEXT-255 ).
        lo_column->set_short_text( TEXT-270 ).
        lo_column->set_medium_text( TEXT-285 ).
        lo_column ?= lo_columns->get_column( TEXT-241 ).
        lo_column->set_long_text( TEXT-256 ).
        lo_column->set_short_text( TEXT-271 ).
        lo_column->set_medium_text( TEXT-286 ).
        lo_column ?= lo_columns->get_column( TEXT-242 ).
        lo_column->set_long_text( TEXT-257 ).
        lo_column->set_short_text( TEXT-272 ).
        lo_column->set_medium_text( TEXT-287 ).
        lo_column ?= lo_columns->get_column( TEXT-243 ).
        lo_column->set_long_text( TEXT-258 ).
        lo_column->set_short_text( TEXT-273 ).
        lo_column->set_medium_text( TEXT-288 ).


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

  DATA:lt_ccpc    TYPE STANDARD TABLE OF zfi_pccenters.

  REFRESH:lt_ccpc.
  CALL FUNCTION 'ZCA_OUTPUT_PC'
    EXPORTING
      iv_pcenters = p_ls_row_value
      iv_pc_flag  = p_lv_pc
    TABLES
      et_output   = lt_ccpc.
  READ TABLE lt_ccpc INTO DATA(ls_ccpc) INDEX 1.
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

  DATA:lt_ccpc TYPE STANDARD TABLE OF zfi_pccenters,
       lv_ccpc TYPE char10.

  REFRESH:lt_ccpc.
  lv_ccpc = p_ls_row_value.
  CALL FUNCTION 'ZCA_OUTPUT_PC'
    EXPORTING
      iv_pcenters = lv_ccpc
      iv_pc_flag  = p_lv_pc
    TABLES
      et_output   = lt_ccpc.
  READ TABLE lt_ccpc INTO DATA(ls_ccpc) INDEX 1.
  IF sy-subrc IS INITIAL.
    p_childnode = ls_ccpc-numbr.
    CLEAR:ls_ccpc.
  ELSE.
    p_childnode = p_ls_row_value.
  ENDIF.

ENDFORM.
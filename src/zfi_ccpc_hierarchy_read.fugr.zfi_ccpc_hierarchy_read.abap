FUNCTION zfi_ccpc_hierarchy_read.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_SETCLASS) TYPE  SETCLASS
*"     REFERENCE(I_SUBCLASS) TYPE  BAPICO_GROUP-CO_AREA
*"     REFERENCE(I_SETNAME) TYPE  BAPICO_GROUP-GROUPNAME
*"     REFERENCE(I_COL) TYPE  CHAR1 OPTIONAL
*"     REFERENCE(I_ROW) TYPE  CHAR1 OPTIONAL
*"  TABLES
*"      OUTPUT STRUCTURE  ZFI_CCPC_HIERARCHY_READ OPTIONAL
*"      OUTPUT_COL STRUCTURE  ZFI_CCPC_HIERARCHY_READ_COL OPTIONAL
*"      NODES STRUCTURE  BAPISET_HIER OPTIONAL
*"  EXCEPTIONS
*"      INVALID_SETCLASS
*"      INVALID_SELECTION_ROW_COL
*"      INVALID_INPUT
*"----------------------------------------------------------------------
  TYPES:r_typ TYPE RANGE OF parnode.
  DATA: ls_node    TYPE bapiset_hier,
        lt_values  TYPE TABLE OF bapi1112_values,
        ls_values  TYPE bapi1112_values,
        ls_return  TYPE bapiret2,
        ls_langu   TYPE bapi0015_10,
        lr_setname TYPE RANGE OF setleaf-setname,
        ls_setname LIKE LINE OF lr_setname,
        lr_CCPC    TYPE RANGE OF char10,
        ls_CCPC    LIKE LINE OF lr_CCPC,
        lv_bfr     TYPE bapiset_hier-hierlevel,
        lv_cnt     TYPE n,
        lv_index   TYPE c,
        lv_hierlvl TYPE bapiset_hier-hierlevel,
        r_nodes    TYPE r_typ,
        lv_pc      TYPE cepc-prctr,
        lv_cc      TYPE csks-kostl,
        ls_thisset TYPE setkeylist,
        lv_hryid   TYPE hrrp_node-hryid,
        lv_dat1    TYPE char40,
        lv_dat2    TYPE char40.

  TYPES:    BEGIN OF ty_setval.
              INCLUDE STRUCTURE setvalues.
  TYPES: END OF ty_setval.

  TYPES: BEGIN OF ty_sethier.
           INCLUDE STRUCTURE sethier.
  TYPES: END OF ty_sethier.

  TYPES: BEGIN OF ty_setleaf,
           setclass TYPE setleaf-setclass,
           subclass TYPE     setleaf-subclass,
           setname  TYPE     setleaf-setname,
           valfrom  TYPE     setleaf-valfrom,
         END OF ty_setleaf.
  DATA:
    lt_setval  TYPE TABLE OF ty_setval WITH DEFAULT KEY,
    lt_sethier TYPE TABLE OF ty_sethier WITH DEFAULT KEY,
    lt_setleaf TYPE TABLE OF ty_setleaf,
    ls_setleaf TYPE ty_setleaf.


  FIELD-SYMBOLS : <fs>    TYPE any,
                  <table> TYPE STANDARD TABLE.

* Exceptions
  IF i_setclass NE '0101'
    AND i_setclass NE '0106'.
    RAISE invalid_setclass.
  ENDIF.

  IF i_row EQ abap_true
    AND i_col EQ abap_true.
    RAISE invalid_selection_row_col.
  ENDIF.

  IF i_row NE abap_true
    AND i_col NE abap_true.
    RAISE invalid_input.
  ENDIF.

* Clear Data before calling BAPI
  CLEAR:ls_return.
  FREE:nodes,lt_values,lt_sethier,lt_setval.
  IF i_setname CS '~'.
    CONCATENATE i_setclass i_subclass i_setname INTO ls_thisset-setid.
    ls_thisset-setclass = i_setclass.
    ls_thisset-subclass = i_subclass.
    ls_thisset-setname = i_setname.
    IF i_setclass EQ '0106'.
      DATA(lo_uh_legacy) = NEW zcl_fins_uh_hrrp_pc_legacy( ).
      IF lo_uh_legacy IS NOT INITIAL.
        TRY.
            CALL METHOD lo_uh_legacy->if_fins_uh_hrrp_legacy~import_set(
              EXPORTING
                is_setkey  = ls_thisset
              IMPORTING
                et_sethier = lt_sethier[]
                et_setval  = lt_setval[] ).
            IF lt_sethier[] IS INITIAL.
              MESSAGE 'No Data selected to display' TYPE 'E' RAISING set_not_found.
            ENDIF.
          CATCH cx_fins_uh_hrrp_legacy INTO DATA(lo_fins_uh_hrrp_legacy).
            MESSAGE lo_fins_uh_hrrp_legacy->get_text( ) TYPE 'E' RAISING set_not_found.
        ENDTRY.
      ENDIF.
    ENDIF.
    IF i_setclass EQ '0101'.
      DATA(lo_uh_leg_cc) = NEW zcl_fins_uh_hrrp_cc_legacy( ).
      IF lo_uh_leg_cc IS NOT INITIAL.
        TRY.
            CALL METHOD lo_uh_leg_cc->if_fins_uh_hrrp_legacy~import_set(
              EXPORTING
                is_setkey  = ls_thisset
              IMPORTING
                et_sethier = lt_sethier[]
                et_setval  = lt_setval[] ).
            IF lt_sethier[] IS INITIAL.
              MESSAGE 'No Data selected to display' TYPE 'E' RAISING set_not_found.
            ENDIF.
          CATCH cx_fins_uh_hrrp_legacy INTO DATA(lo_fins_uh_hrrp_leg_cc).
            MESSAGE lo_fins_uh_hrrp_leg_cc->get_text( ) TYPE 'E' RAISING set_not_found.
        ENDTRY.
      ENDIF.
    ENDIF.
    IF lt_sethier[] IS NOT INITIAL.
      DATA(lv_tilt) = abap_true.
      LOOP AT lt_setval INTO DATA(ls_setval).
        ls_values-valfrom = ls_setval-from.
        ls_values-valto = ls_setval-to.
        APPEND ls_values TO lt_values.
        CLEAR:ls_values.
      ENDLOOP.
      LOOP AT lt_sethier INTO DATA(ls_sethier).
        SPLIT ls_sethier-setid AT i_subclass INTO lv_dat1 lv_dat2.
        ls_node-groupname = lv_dat2.
        ls_node-hierlevel = ls_sethier-level.
        ls_node-valcount = ls_sethier-vcount.
        ls_node-descript = ls_sethier-descript.
        APPEND ls_node TO nodes.
        CLEAR:ls_node.
      ENDLOOP.
    ELSE.
      MESSAGE 'No Data selected to display' TYPE 'E' RAISING set_not_found.
    ENDIF.
  ENDIF.

* If Queried for Cost center Hierarchy
  IF i_setclass EQ '0101'.
    IF lv_tilt EQ abap_false.
      CALL FUNCTION 'BAPI_COSTCENTERGROUP_GETDETAIL'
        EXPORTING
          controllingarea = i_subclass
          groupname       = i_setname
          language        = ls_langu
        IMPORTING
          return          = ls_return
        TABLES
          hierarchynodes  = nodes
          hierarchyvalues = lt_values.
    ENDIF.
    IF lt_values IS NOT INITIAL.
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
  INNER JOIN cskt AS a
          ON a~kostl EQ b~kostl
        INTO TABLE @DATA(lt_csks)
         FOR ALL ENTRIES IN  @lt_values
       WHERE a~kostl EQ @lt_values-valfrom.
    ENDIF.
  ENDIF.
* If Queried for Profit center Hierarchy
  IF i_setclass EQ '0106'.
    IF lv_tilt EQ abap_false.
      CALL FUNCTION 'BAPI_PROFITCENTERGRP_GETDETAIL'
        EXPORTING
          controllingarea = i_subclass
          groupname       = i_setname
          language        = ls_langu
        IMPORTING
          return          = ls_return
        TABLES
          hierarchynodes  = nodes
          hierarchyvalues = lt_values.
    ENDIF.
    IF lt_values IS NOT INITIAL.
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
       INNER JOIN cepct AS a
          ON a~prctr EQ b~prctr
        INTO TABLE @DATA(lt_cepc)
         FOR ALL ENTRIES IN  @lt_values
       WHERE a~prctr EQ @lt_values-valfrom.
    ENDIF.
  ENDIF.

  LOOP AT nodes INTO DATA(ls_nodes).
    IF ls_nodes-valcount NE 0.
      ls_setname-sign = 'I'.
      ls_setname-option = 'EQ'.
      ls_setname-low = ls_nodes-groupname.
      APPEND ls_setname TO lr_setname.
    ELSE.
      IF ls_nodes-groupname CS '~'.
        SPLIT ls_nodes-groupname AT '~' INTO lv_dat1 lv_dat2.
        ls_ccpc-low =  |{ lv_dat2 ALPHA = IN }|.
        CLEAR:lv_dat1, lv_dat2.
      ELSE.
        ls_ccpc-low =  |{ ls_nodes-groupname ALPHA = IN }|.
      ENDIF.
      ls_ccpc-sign = 'I'.
      ls_ccpc-option = 'EQ'.
      APPEND ls_ccpc TO lr_ccpc.
      CLEAR:ls_ccpc.
    ENDIF.
  ENDLOOP.

  IF lv_tilt EQ abap_true.
    SPLIT i_setname AT '~' INTO lv_dat1 lv_dat2.
    CONCATENATE 'H' i_setclass+1(3) '/' i_subclass '/' lv_dat1 INTO lv_hryid.
    SELECT hryid,
           hryver,
           nodecls,
           hrynode,
           parnode,
           hryvalto,
           nodetype,
           nodevalue
      FROM hrrp_node
      INTO TABLE @DATA(lt_hrrpnode)
     WHERE hryid EQ @lv_hryid
       AND nodetype EQ 'L'.
    IF sy-subrc EQ 0.
      SPLIT i_setname AT '~' INTO lv_dat1 lv_dat2.
      CONCATENATE lv_dat1 '~' INTO lv_dat1.
      LOOP AT lt_hrrpnode INTO DATA(ls_hrrpnode).
        ls_setleaf-setclass = i_setclass.
        ls_setleaf-subclass = i_subclass.
        REPLACE ls_hrrpnode-parnode+0(1) IN ls_hrrpnode-parnode WITH lv_dat1.
        ls_setleaf-setname = ls_hrrpnode-parnode.
        ls_setleaf-valfrom = ls_hrrpnode-nodevalue.
        APPEND ls_setleaf TO lt_setleaf.
        CLEAR:ls_setleaf.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF lr_setname IS NOT INITIAL.
      SELECT setclass,
             subclass,
             setname,
             valfrom
        FROM setleaf
        INTO TABLE @lt_setleaf
       WHERE setclass EQ @i_setclass
         AND subclass EQ @i_subclass
         AND setname IN @lr_setname.
      IF sy-subrc EQ 0.
        SORT lt_setleaf BY valfrom.
      ENDIF.
    ENDIF.
  ENDIF.
  IF lr_ccpc IS NOT INITIAL.
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
     INNER JOIN cepct AS a
        ON a~prctr EQ b~prctr
      INTO TABLE @DATA(lt_pc)
     WHERE a~prctr IN @lr_ccpc.

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
     INNER JOIN cskt AS a
        ON a~kostl EQ b~kostl
      INTO TABLE @DATA(lt_cc)
     WHERE a~kostl IN @lr_ccpc.
  ENDIF.

* Profit Center & Cost Center Column Wise logic Start
  IF i_col EQ abap_true.
    IF nodes[] IS NOT INITIAL.
      LOOP AT nodes INTO ls_nodes.
        output_col-nodename = ls_nodes-descript.
        IF ls_nodes-hierlevel LT lv_bfr.
          DATA(lv_docnt) = lv_bfr - ls_nodes-hierlevel.
          lv_cnt = ls_nodes-hierlevel.
          lv_cnt = 1 + ls_nodes-hierlevel.
          DO lv_docnt TIMES.
            CONCATENATE 'output_col-level' lv_cnt INTO DATA(lv_clear).
            ASSIGN (lv_clear) TO <fs> .
            CLEAR:<fs>.
            lv_cnt = 1 + lv_cnt.
          ENDDO.
          CLEAR: lv_docnt,lv_cnt,lv_clear.
        ENDIF.
        IF ls_nodes-hierlevel EQ 1.
          CLEAR:output_col-level1,
                output_col-level2,
                output_col-level3,
                output_col-level4,
                output_col-level5,
                output_col-level6,
                output_col-level7,
                output_col-level8.
        ENDIF.
        CASE ls_nodes-hierlevel.
          WHEN 0.
            output_col-level0 = ls_nodes-groupname.
          WHEN 1.
            output_col-level1 = ls_nodes-groupname.
          WHEN 2.
            output_col-level2 = ls_nodes-groupname.
          WHEN 3.
            output_col-level3 = ls_nodes-groupname.
          WHEN 4.
            output_col-level4 = ls_nodes-groupname.
          WHEN 5.
            output_col-level5 = ls_nodes-groupname.
          WHEN 6.
            output_col-level6 = ls_nodes-groupname.
          WHEN 7.
            output_col-level7 = ls_nodes-groupname.
          WHEN 8.
            output_col-level8 = ls_nodes-groupname.
          WHEN OTHERS.
        ENDCASE.
        LOOP AT lt_setleaf INTO ls_setleaf WHERE setclass = i_setclass
                                                   AND subclass = i_subclass
                                                   AND setname = ls_nodes-groupname.
          output_col-nodename = ls_nodes-descript.
          output_col-value = ls_setleaf-valfrom.
          IF i_setclass EQ '0106'.
            READ TABLE lt_cepc
             INTO DATA(ls_cepc)
              WITH KEY prctr = output_col-value.
          ENDIF.
          IF i_setclass EQ '0101'.
            READ TABLE lt_csks
             INTO DATA(ls_csks)
              WITH KEY kostl = output_col-value.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ls_csks TO ls_cepc.
              CLEAR:ls_csks.
            ENDIF.
          ENDIF.
          IF sy-subrc EQ 0.
            output_col-ktext = ls_cepc-ktext.
            output_col-ltext = ls_cepc-ltext.
            output_col-verak = ls_cepc-verak.
            output_col-verak_user = ls_cepc-verak_user.
            output_col-bukrs = ls_cepc-bukrs.
            output_col-waers = ls_cepc-waers.
            output_col-txjcd = ls_cepc-txjcd.
            output_col-stras = ls_cepc-stras.
            output_col-ort01 = ls_cepc-ort01.
            output_col-ort02 = ls_cepc-ort02.
            output_col-pstlz = ls_cepc-pstlz.
            output_col-regio = ls_cepc-regio.
            output_col-land1 = ls_cepc-land1.
            output_col-name1 = ls_cepc-name1.
            output_col-name2 = ls_cepc-name2.
            output_col-name3 = ls_cepc-name3.
            output_col-name4 = ls_cepc-name4.
            output_col-telf1 = ls_cepc-telf1.
            output_col-telf2 = ls_cepc-telf2.
            output_col-telfx = ls_cepc-telfx.
          ENDIF.
          APPEND output_col.
          DATA(lv_flag) = abap_true.
          CLEAR:ls_cepc,
                output_col-value,
                output_col-ktext,
                output_col-ltext,
                output_col-verak,
                output_col-verak_user,
                output_col-bukrs,
                output_col-waers,
                output_col-txjcd,
                output_col-stras,
                output_col-ort01,
                output_col-ort02,
                output_col-pstlz,
                output_col-regio,
                output_col-land1,
                output_col-name1,
                output_col-name2,
                output_col-name3,
                output_col-name4,
                output_col-telf1,
                output_col-telf2,
                output_col-telfx.
        ENDLOOP.
        IF lv_flag NE abap_true.
          IF ls_nodes-valcount EQ 0.
            CLEAR:lv_cc.
            IF ls_nodes-groupname CS '~'.
              SPLIT ls_nodes-groupname AT '~' INTO lv_dat1 lv_dat2.
              lv_cc =  |{ lv_dat2 ALPHA = IN }|.
              CLEAR:lv_dat1, lv_dat2.
            ELSE.
              lv_cc =  |{ ls_nodes-groupname ALPHA = IN }|.
            ENDIF.
            READ TABLE lt_cc
                  INTO DATA(ls_cc)
                  WITH KEY kostl = lv_cc.
            IF sy-subrc EQ 0.
              output_col-ktext = ls_cc-ktext.
              output_col-ltext = ls_cc-ltext.
              output_col-verak = ls_cc-verak.
              output_col-verak_user = ls_cc-verak_user.
              output_col-bukrs = ls_cc-bukrs.
              output_col-waers = ls_cc-waers.
              output_col-txjcd = ls_cc-txjcd.
              output_col-stras = ls_cc-stras.
              output_col-ort01 = ls_cc-ort01.
              output_col-ort02 = ls_cc-ort02.
              output_col-pstlz = ls_cc-pstlz.
              output_col-regio = ls_cc-regio.
              output_col-land1 = ls_cc-land1.
              output_col-name1 = ls_cc-name1.
              output_col-name2 = ls_cc-name2.
              output_col-name3 = ls_cc-name3.
              output_col-name4 = ls_cc-name4.
              output_col-telf1 = ls_cc-telf1.
              output_col-telf2 = ls_cc-telf2.
              output_col-telfx = ls_cc-telfx.
            ELSE.
              CLEAR:lv_pc.
              IF ls_nodes-groupname CS '~'.
                SPLIT ls_nodes-groupname AT '~' INTO lv_dat1 lv_dat2.
                lv_pc =  |{ lv_dat2 ALPHA = IN }|.
                CLEAR:lv_dat1, lv_dat2.
              ELSE.
                lv_pc =  |{ ls_nodes-groupname ALPHA = IN }|.
              ENDIF.
              READ TABLE lt_pc
                    INTO DATA(ls_pc)
                    WITH KEY prctr = lv_pc.
              IF sy-subrc EQ 0.
                output_col-ktext = ls_pc-ktext.
                output_col-ltext = ls_pc-ltext.
                output_col-verak = ls_pc-verak.
                output_col-verak_user = ls_pc-verak_user.
                output_col-bukrs = ls_pc-bukrs.
                output_col-waers = ls_pc-waers.
                output_col-txjcd = ls_pc-txjcd.
                output_col-stras = ls_pc-stras.
                output_col-ort01 = ls_pc-ort01.
                output_col-ort02 = ls_pc-ort02.
                output_col-pstlz = ls_pc-pstlz.
                output_col-regio = ls_pc-regio.
                output_col-land1 = ls_pc-land1.
                output_col-name1 = ls_pc-name1.
                output_col-name2 = ls_pc-name2.
                output_col-name3 = ls_pc-name3.
                output_col-name4 = ls_pc-name4.
                output_col-telf1 = ls_pc-telf1.
                output_col-telf2 = ls_pc-telf2.
                output_col-telfx = ls_pc-telfx.
              ENDIF.
            ENDIF.
          ENDIF.
          APPEND output_col.
          CLEAR:output_col-ktext,
                output_col-ltext,
                output_col-verak,
                output_col-verak_user,
                output_col-bukrs,
                output_col-waers,
                output_col-txjcd,
                output_col-stras,
                output_col-ort01,
                output_col-ort02,
                output_col-pstlz,
                output_col-regio,
                output_col-land1,
                output_col-name1,
                output_col-name2,
                output_col-name3,
                output_col-name4,
                output_col-telf1,
                output_col-telf2,
                output_col-telfx.
        ENDIF.
        CLEAR:lv_flag.
        lv_bfr = ls_nodes-hierlevel.
      ENDLOOP.
    ENDIF.
  ENDIF.
* Cost Center & Profit Center Column Wise Logic End
* Cost Center & Profit Center row Wise Logic Start
  DESCRIBE TABLE nodes LINES DATA(lv_lines).
  IF i_row EQ abap_true.
    IF nodes[] IS NOT INITIAL.
      LOOP AT nodes INTO ls_nodes.
        DATA(lv_tabix) = sy-tabix.
        IF ls_nodes-hierlevel EQ 0.
          output-parentnode = ls_nodes-groupname.
        ELSE.
          CLEAR: lv_hierlvl.
          lv_hierlvl = ls_nodes-hierlevel - 1.
          IF lv_hierlvl EQ 0.
            READ TABLE nodes INTO DATA(ls_parent) WITH KEY hierlevel = 0.
            IF sy-subrc EQ 0.
              output-parentnode = ls_parent-groupname.
            ENDIF.
          ELSE.
            DO lv_lines TIMES.
              lv_tabix = lv_tabix - 1.
              READ TABLE nodes INTO ls_parent INDEX lv_tabix.
              IF ls_parent-hierlevel EQ lv_hierlvl.
                output-parentnode = ls_parent-groupname.
                EXIT.
              ENDIF.
              CLEAR:ls_parent.
            ENDDO.
            CLEAR: lv_tabix.
          ENDIF.
          output-childnode = ls_nodes-groupname.
        ENDIF.
        output-nodename = ls_nodes-descript.
        LOOP AT lt_setleaf INTO ls_setleaf WHERE setclass = i_setclass
                                             AND subclass = i_subclass
                                             AND setname = ls_nodes-groupname.
          output-value = ls_setleaf-valfrom.
          output-nodename = ls_nodes-descript.
          IF i_setclass EQ '0106'.
            READ TABLE lt_cepc
                  INTO ls_cepc
              WITH KEY prctr = output-value.
          ENDIF.
          IF i_setclass EQ '0101'.
            READ TABLE lt_csks
                  INTO ls_csks
              WITH KEY kostl = output-value.
            IF sy-subrc EQ 0.
              MOVE-CORRESPONDING ls_csks TO ls_cepc.
              CLEAR:ls_csks.
            ENDIF.
          ENDIF.
          IF sy-subrc EQ 0.
            output-ktext = ls_cepc-ktext.
            output-ltext = ls_cepc-ltext.
            output-verak = ls_cepc-verak.
            output-verak_user = ls_cepc-verak_user.
            output-bukrs = ls_cepc-bukrs.
            output-waers = ls_cepc-waers.
            output-txjcd = ls_cepc-txjcd.
            output-stras = ls_cepc-stras.
            output-ort01 = ls_cepc-ort01.
            output-ort02 = ls_cepc-ort02.
            output-pstlz = ls_cepc-pstlz.
            output-regio = ls_cepc-regio.
            output-land1 = ls_cepc-land1.
            output-name1 = ls_cepc-name1.
            output-name2 = ls_cepc-name2.
            output-name3 = ls_cepc-name3.
            output-name4 = ls_cepc-name4.
            output-telf1 = ls_cepc-telf1.
            output-telf2 = ls_cepc-telf2.
            output-telfx = ls_cepc-telfx.
          ENDIF.
          APPEND output.
          lv_flag = abap_true.
          CLEAR:ls_cepc,
                output-value,
                output-ktext,
                output-ltext,
                output-verak,
                output-verak_user,
                output-bukrs,
                output-waers,
                output-txjcd,
                output-stras,
                output-ort01,
                output-ort02,
                output-pstlz,
                output-regio,
                output-land1,
                output-name1,
                output-name2,
                output-name3,
                output-name4,
                output-telf1,
                output-telf2,
                output-telfx.
        ENDLOOP.
        IF lv_flag NE abap_true.
          IF ls_nodes-valcount EQ 0.
            CLEAR:lv_cc.
            IF ls_nodes-groupname CS '~'.
              SPLIT ls_nodes-groupname AT '~' INTO lv_dat1 lv_dat2.
              lv_cc =  |{ lv_dat2 ALPHA = IN }|.
              CLEAR:lv_dat1, lv_dat2.
            ELSE.
              lv_cc =  |{ ls_nodes-groupname ALPHA = IN }|.
            ENDIF.
            READ TABLE lt_cc
                  INTO ls_cc
                  WITH KEY kostl = lv_cc.
            IF sy-subrc EQ 0.
              output-ktext = ls_cc-ktext.
              output-ltext = ls_cc-ltext.
              output-verak = ls_cc-verak.
              output-verak_user = ls_cc-verak_user.
              output-bukrs = ls_cc-bukrs.
              output-waers = ls_cc-waers.
              output-txjcd = ls_cc-txjcd.
              output-stras = ls_cc-stras.
              output-ort01 = ls_cc-ort01.
              output-ort02 = ls_cc-ort02.
              output-pstlz = ls_cc-pstlz.
              output-regio = ls_cc-regio.
              output-land1 = ls_cc-land1.
              output-name1 = ls_cc-name1.
              output-name2 = ls_cc-name2.
              output-name3 = ls_cc-name3.
              output-name4 = ls_cc-name4.
              output-telf1 = ls_cc-telf1.
              output-telf2 = ls_cc-telf2.
              output-telfx = ls_cc-telfx.
            ELSE.
              CLEAR:lv_pc.
              IF ls_nodes-groupname CS '~'.
                SPLIT ls_nodes-groupname AT '~' INTO lv_dat1 lv_dat2.
                lv_pc =  |{ lv_dat2 ALPHA = IN }|.
                CLEAR:lv_dat1, lv_dat2.
              ELSE.
                lv_pc =  |{ ls_nodes-groupname ALPHA = IN }|.
              ENDIF.
              READ TABLE lt_pc
                    INTO ls_pc
                    WITH KEY prctr = lv_pc.
              IF sy-subrc EQ 0.
                output-ktext = ls_pc-ktext.
                output-ltext = ls_pc-ltext.
                output-verak = ls_pc-verak.
                output-verak_user = ls_pc-verak_user.
                output-bukrs = ls_pc-bukrs.
                output-waers = ls_pc-waers.
                output-txjcd = ls_pc-txjcd.
                output-stras = ls_pc-stras.
                output-ort01 = ls_pc-ort01.
                output-ort02 = ls_pc-ort02.
                output-pstlz = ls_pc-pstlz.
                output-regio = ls_pc-regio.
                output-land1 = ls_pc-land1.
                output-name1 = ls_pc-name1.
                output-name2 = ls_pc-name2.
                output-name3 = ls_pc-name3.
                output-name4 = ls_pc-name4.
                output-telf1 = ls_pc-telf1.
                output-telf2 = ls_pc-telf2.
                output-telfx = ls_pc-telfx.
              ENDIF.
            ENDIF.
          ENDIF.
          APPEND output.
          CLEAR:output-ktext,
                output-ltext,
                output-verak,
                output-verak_user,
                output-bukrs,
                output-waers,
                output-txjcd,
                output-stras,
                output-ort01,
                output-ort02,
                output-pstlz,
                output-regio,
                output-land1,
                output-name1,
                output-name2,
                output-name3,
                output-name4,
                output-telf1,
                output-telf2,
                output-telfx.
        ENDIF.
        CLEAR:lv_flag,
              output.
      ENDLOOP.
    ENDIF.
  ENDIF.
* Cost Center & Profit Center row Wise Logic end
ENDFUNCTION.

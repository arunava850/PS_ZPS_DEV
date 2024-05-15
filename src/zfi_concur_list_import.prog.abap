*&---------------------------------------------------------------------*
*& Report zfi_concur_list_import
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_concur_list_import.

DATA: lv_bukrs TYPE csks-bukrs,
      lv_khinr TYPE csks-khinr,
      lv_kostl TYPE csks-kostl,
      lv_date  TYPE sy-datum.

TYPES: BEGIN OF ty_cost_center,
         kostl TYPE kostl,
       END OF ty_cost_center,

       BEGIN OF ty_setname,
         setname TYPE setnamenew,
       END OF ty_setname,

       tt_cost_center TYPE STANDARD TABLE OF ty_cost_center,
       tt_setname     TYPE STANDARD TABLE OF ty_setname.

DATA: ls_cc TYPE ty_cost_center,
      lt_cc TYPE tt_cost_center.

DATA:lfis_bukrs             TYPE fis_bukrs,
     lfis_ryear_no_conv     TYPE bkpf-gjahr,
     lfins_ledger           TYPE fins_ledger,
     lfins_fiscalperiod     TYPE bkpf-monat,
     lfis_hwaer             TYPE bkpf-waers,
     lfis_racct             TYPE fis_racct,
     lv_figlcn_disalteracct TYPE figlcn_disalteracct,
     gs_out                 TYPE zfi_concur_list_cc, " ZFI_CONCUR_LIST_CC21,"zfi_gl_monthly_bal_sp,
     gt_data                TYPE zz_list_cc_struc_tab, "zfi_gl_monthly_bal_tt_tab,
     gs_data                LIKE LINE OF gt_data,
     lv_prctr               TYPE cepc-prctr,
     gt_useful_set          TYPE tt_setname.

* Types Pools
TYPE-POOLS:
   slis.
* Types
TYPES:
  t_fieldcat TYPE slis_fieldcat_alv,
  t_events   TYPE slis_alv_event,
  t_layout   TYPE slis_layout_alv.
* Workareas
DATA:
  w_fieldcat TYPE t_fieldcat,
  w_events   TYPE t_events,
  w_layout   TYPE t_layout.
* Internal Tables
DATA:
  i_fieldcat TYPE STANDARD TABLE OF t_fieldcat,
  i_events   TYPE STANDARD TABLE OF t_events.

RANGES s_kostl_tmp FOR lv_kostl.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS : s_bukrs FOR lv_bukrs,
                   s_kostl FOR lv_kostl,
                   s_khinr FOR lv_khinr OBLIGATORY,
                   s_date  FOR lv_date.
  PARAMETERS: p_load AS CHECKBOX,
              p_test AS CHECKBOX DEFAULT abap_true.

*  SELECT-OPTIONS : s_ccode FOR lfis_bukrs OBLIGATORY,
*                   s_ledger  FOR lfins_ledger OBLIGATORY.
*  PARAMETERS:      p_fyear  TYPE fis_ryear_no_conv OBLIGATORY.
*  SELECT-OPTIONS : s_fper  FOR lfins_fiscalperiod.
*  PARAMETERS:      p_crole TYPE fac_crcyrole OBLIGATORY. "DEFAULT '10' OBLIGATORY.
*  PARAMETERS: "p_dcur  TYPE bkpf-waers OBLIGATORY,
*              p_glinf TYPE figlcn_disalteracct.


SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
  IF s_date-low IS INITIAL AND s_date-high IS INITIAL.
    s_date-sign = 'I'.
    s_date-option = 'BT'.
    s_date-low = sy-datum - 1.
    s_date-high = sy-datum.
    APPEND s_date.
    s_khinr-sign = 'I'.
    s_khinr-option = 'EQ'.
    s_khinr-low = 'PS_CORP'.
    APPEND s_khinr.
    s_khinr-low = 'PS_FACMGMT'.
    APPEND s_khinr.
    s_khinr-low = 'PS_FLDMGMT'.
    APPEND s_khinr.
  ENDIF.


START-OF-SELECTION.

  IF p_load IS NOT INITIAL.
    SELECT a~kostl, a~datbi, a~datab, a~bkzkp, a~bukrs, a~khinr, a~kokrs, b~ltext
    FROM csks AS a
    LEFT OUTER JOIN cskt AS b ON a~kostl = b~kostl   "#EC CI_BUFFJOIN
    INTO TABLE @DATA(lt_csks_all)
    WHERE a~bukrs IN  @s_bukrs
    AND a~khinr IN @s_khinr
    AND a~kokrs = 'PSCO'
    AND b~spras = 'E'.
  ELSE.
    CLEAR lt_csks_all.
    SELECT objectclas, objectid, changenr, udate
    FROM cdhdr
    INTO TABLE @DATA(lt_change_hdr)
    WHERE objectclas = 'KOSTL'
      AND udate IN @s_date.
    IF sy-subrc IS INITIAL.
      CLEAR lt_cc.
      LOOP AT lt_change_hdr INTO DATA(ls_change_hdr).
        lv_kostl =  ls_change_hdr-objectid+4(10).
        ls_cc-kostl = lv_kostl.
        APPEND ls_cc TO lt_cc.
      ENDLOOP.
      IF lt_cc IS NOT INITIAL.
        SELECT a~kostl, a~datbi, a~datab, a~bkzkp, a~bukrs, a~khinr, a~kokrs, b~ltext
          FROM csks AS a
          LEFT OUTER JOIN cskt AS b ON a~kostl = b~kostl     "#EC CI_BUFFJOIN
          INTO TABLE @DATA(lt_csks_delta)
          FOR ALL ENTRIES IN @lt_cc
          WHERE a~bukrs IN  @s_bukrs
            AND a~kostl = @lt_cc-kostl
            AND a~khinr IN @s_khinr
            AND a~kokrs = 'PSCO'
            AND b~spras = 'E'.
        IF sy-subrc IS INITIAL.
          APPEND LINES OF lt_csks_delta TO lt_csks_all.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.




  IF lt_csks_all IS NOT INITIAL.

    LOOP AT lt_csks_all INTO DATA(ls_csks_all).
      gs_data-interface_name = 'INT0032'.
      gs_data-receiver_system = 'CONCUR'.
      gs_data-list_name = 'PS - BU/Cost Center'.
      gs_data-list_cat = 'PS - BU/Cost Center'.
      gs_data-level01 = ls_csks_all-kostl.
      gs_data-value = ls_csks_all-ltext.
      IF ls_csks_all-bkzkp IS NOT INITIAL OR ls_csks_all-datbi LT sy-datum.
        gs_data-del_list_item = 'Y'.
      ELSE.
        gs_data-del_list_item = 'N'.
      ENDIF.
      APPEND gs_data TO gt_data.
      CLEAR: ls_csks_all , gs_data.
    ENDLOOP.
  ENDIF.

  SELECT setclass, subclass, setname, subsetcls, subsetscls, subsetname
  FROM setnode
  INTO TABLE @DATA(lt_all_pc_node)
  WHERE setclass = '0106'
    AND subclass = 'PSCO'.

  IF sy-subrc IS INITIAL.


    PERFORM get_child USING 'PS_DRA'.

    IF gt_useful_set IS NOT INITIAL.

      SELECT setclass, subclass, setname, langu, descript
       FROM setheadert
       INTO TABLE @DATA(lt_node_name)
       FOR ALL ENTRIES IN @gt_useful_set
       WHERE setclass = '0106'
         AND subclass = 'PSCO'
         AND langu = 'E'
         AND setname = @gt_useful_set-setname.

      IF sy-subrc IS INITIAL.

        LOOP AT lt_node_name INTO DATA(ls_node_name) .
          gs_data-interface_name = 'INT0032'.
          gs_data-receiver_system = 'CONCUR'.
          gs_data-level01 = ls_node_name-setname.
          gs_data-value = ls_node_name-descript.
          gs_data-del_list_item = 'N'.
          IF ls_node_name-setname+0(3) = 'ZON'.
            gs_data-list_name = 'PS - Zone'.
            gs_data-list_cat = 'PS - Zone'.
            APPEND gs_data TO gt_data.
          ELSEIF ls_node_name-setname+0(3) = 'DIV'.
            gs_data-list_name = 'PS - Division'.
            gs_data-list_cat = 'PS - Division'.
            APPEND gs_data TO gt_data.
          ELSEIF ls_node_name-setname+0(1) = 'R'.
            gs_data-list_name = 'PS - Region'.
            gs_data-list_cat = 'PS - Region'.
            APPEND gs_data TO gt_data.
          ELSEIF ls_node_name-setname+0(2) = 'SR'.
            gs_data-list_name = 'PS - Sr Region'.
            gs_data-list_cat = 'PS - Sr Region'.
            APPEND gs_data TO gt_data.
          ELSEIF ls_node_name-setname+0(2) = 'D0'.
            gs_data-list_name = 'PS - District'.
            gs_data-list_cat = 'PS - District'.
            APPEND gs_data TO gt_data.
          ELSEIF ls_node_name-setname+0(2) = 'SD'.
            gs_data-list_name = 'PS - Sr District'.
            gs_data-list_cat = 'PS - Sr District'.
            APPEND gs_data TO gt_data.
          ENDIF.
          CLEAR gs_data.
        ENDLOOP..
      ENDIF.

    ENDIF.

  ENDIF.

  SELECT setclass, subclass, setname, lineid, valsign, valoption, valfrom, valto
    FROM setleaf
    INTO TABLE @DATA(lt_cc_node)
    WHERE setclass = '0101'
      AND subclass = 'PSCO'
      AND setname = 'PS_DTS'.

  IF sy-subrc IS INITIAL.

    LOOP AT lt_cc_node INTO DATA(ls_cc_node).

      s_kostl_tmp-sign = ls_cc_node-valsign.
      s_kostl_tmp-option = ls_cc_node-valoption.
      s_kostl_tmp-low = ls_cc_node-valfrom.
      s_kostl_tmp-high = ls_cc_node-valto.
      APPEND s_kostl_tmp.

    ENDLOOP.

    SELECT a~kostl, a~datbi, a~datab, a~bkzkp, a~bukrs, a~khinr, a~kokrs, b~ltext
      FROM csks AS a
      LEFT OUTER JOIN cskt AS b ON a~kostl = b~kostl    "#EC CI_BUFFJOIN
      INTO TABLE @DATA(lt_csks_dts)
      WHERE a~bukrs IN  @s_bukrs
        AND a~kostl IN @s_kostl_tmp
        AND a~kokrs = 'PSCO'
        AND b~spras = 'E'.


    LOOP AT lt_csks_dts INTO DATA(ls_csks_dts).
      gs_data-interface_name = 'INT0032'.
      gs_data-receiver_system = 'CONCUR'.
      gs_data-list_name = 'PS - Subledger'.
      gs_data-list_cat = 'PS - Subledger'.
      gs_data-level01 = ls_csks_dts-kostl.
      gs_data-value = ls_csks_dts-ltext.
      IF ls_csks_dts-bkzkp IS NOT INITIAL OR ls_csks_dts-datbi LT sy-datum.
        gs_data-del_list_item = 'Y'.
      ELSE.
        gs_data-del_list_item = 'N'.
      ENDIF.
      APPEND gs_data TO gt_data.
      CLEAR: ls_csks_dts , gs_data.
    ENDLOOP.
  ENDIF.


  IF gt_data IS NOT INITIAL AND p_test IS INITIAL.
    TRY.
        DATA(lr_send) = NEW zco_zfi_concur_list_cc_proxy( ).
        gs_out-zfi_concur_list_cc-listcc = gt_data[].

        CALL METHOD lr_send->send
          EXPORTING
            output = gs_out.
        COMMIT WORK.
      CATCH cx_ai_system_fault INTO DATA(ls_text).
    ENDTRY.

  ELSEIF gt_data IS NOT INITIAL AND p_test IS NOT INITIAL.

    DATA:
          l_program TYPE sy-repid.



    l_program = sy-repid.
    w_layout-colwidth_optimize = 'X'.
    w_layout-zebra             = 'X'.


    CLEAR : w_events, i_events[].
    w_events-name = 'TOP_OF_PAGE'."Event Name
    w_events-form = 'TOP_OF_PAGE'."Callback event subroutine
    APPEND w_events TO i_events.
    CLEAR  w_events.

    CLEAR:w_fieldcat,i_fieldcat[].

    PERFORM build_fcatalog USING:
             'LIST_NAME' 'GT_DATA' 'LIST_NAME',
             'LIST_CAT' 'GT_DATA' 'LIST_CAT',
             'LEVEL01' 'GT_DATA' 'LEVEL01',
             'LEVEL02' 'GT_DATA' 'LEVEL02',
             'LEVEL03' 'GT_DATA' 'LEVEL03',
             'LEVEL04' 'GT_DATA' 'LEVEL04',
             'LEVEL05' 'GT_DATA' 'LEVEL05',
             'LEVEL06' 'GT_DATA' 'LEVEL06',
             'LEVEL07' 'GT_DATA' 'LEVEL07',
             'LEVEL08' 'GT_DATA' 'LEVEL08',
             'LEVEL08' 'GT_DATA' 'LEVEL09',
             'LEVEL10' 'GT_DATA' 'LEVEL10',
             'VALUE' 'GT_DATA' 'VALUE',
             'START_DATE' 'GT_DATA' 'START_DATE',
             'END_DATE' 'GT_DATA' 'END_DATE',
             'DEL_LIST_ITEM' 'GT_DATA' 'DEL_LIST_ITEM'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = l_program
        is_layout          = w_layout
        it_fieldcat        = i_fieldcat
        it_events          = i_events
      TABLES
        t_outtab           = gt_data
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ELSEIF gt_data IS INITIAL.
    MESSAGE i398(00) WITH 'No Data to Send'.

  ENDIF.

FORM build_fcatalog USING l_field l_tab l_text.

  w_fieldcat-fieldname      = l_field.
  w_fieldcat-tabname        = l_tab.
  w_fieldcat-seltext_m      = l_text.

  APPEND w_fieldcat TO i_fieldcat.
  CLEAR w_fieldcat.

ENDFORM.

FORM top_of_page.
  DATA :
    li_header TYPE slis_t_listheader,
    w_header  LIKE LINE OF li_header.
  DATA:
        l_date TYPE char10.
  WRITE sy-datum TO l_date.
  w_header-typ  = 'H'.
  CONCATENATE 'TEST - Cost Center Extract' ':' 'From Date' l_date INTO w_header-info SEPARATED BY space.
  APPEND w_header TO li_header.
  CLEAR w_header.

  w_header-typ  = 'S'.
  w_header-info = sy-title.
  APPEND w_header TO li_header.
  CLEAR w_header.

  w_header-typ  = 'A'.
  w_header-info = sy-uname.
  APPEND w_header TO li_header.
  CLEAR w_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = li_header.

ENDFORM.                    "top_of_page

FORM get_child USING p_setname TYPE setnamenew.

  DATA lsfo_setname TYPE ty_setname.

  LOOP AT lt_all_pc_node INTO DATA(lsfo_pc_node) WHERE setname = p_setname.

    PERFORM get_child USING lsfo_pc_node-subsetname.

    lsfo_setname-setname = lsfo_pc_node-subsetname.

    APPEND lsfo_setname TO gt_useful_set.

  ENDLOOP.

ENDFORM.

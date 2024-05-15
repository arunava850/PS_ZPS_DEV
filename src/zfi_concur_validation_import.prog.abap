*&---------------------------------------------------------------------*
*& Report zfi_concur_validation_import
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_concur_validation_import.

DATA: lv_bukrs TYPE csks-bukrs,
      lv_khinr TYPE csks-khinr,
      lv_kostl TYPE csks-kostl,
      lv_date  TYPE sy-datum.

TYPES: BEGIN OF ty_cost_center,
         kostl TYPE kostl,
       END OF ty_cost_center,

       tt_cost_center TYPE STANDARD TABLE OF ty_cost_center.

DATA: ls_cc TYPE ty_cost_center,
      lt_cc TYPE tt_cost_center.

DATA:lfis_bukrs             TYPE fis_bukrs,
     lfis_ryear_no_conv     TYPE bkpf-gjahr,
     lfins_ledger           TYPE fins_ledger,
     lfins_fiscalperiod     TYPE bkpf-monat,
     lfis_hwaer             TYPE bkpf-waers,
     lfis_racct             TYPE fis_racct,
     lv_figlcn_disalteracct TYPE figlcn_disalteracct,
     gs_out                 TYPE zfi_concur_valid_list, "zfi_concur_list_cc, " ZFI_CONCUR_LIST_CC21,"zfi_gl_monthly_bal_sp,
     gt_data                TYPE zz_valid_list_struc1_tab, "zfi_gl_monthly_bal_tt_tab,
     gs_data                LIKE LINE OF gt_data,
     lv_prctr               TYPE cepc-prctr.

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
  ENDIF.
  IF  s_khinr-low IS INITIAL AND s_khinr-high IS INITIAL.

    s_khinr-sign = 'I'.
    s_khinr-option = 'EQ'.
    s_khinr-low = 'PS_CORP'.
    APPEND s_khinr.
    s_khinr-low = 'PS_FACMGMT'.
    APPEND s_khinr.
    s_khinr-low = 'PS_FLDMGMT'.
    APPEND s_khinr.
    s_khinr-low = 'PS_DTS'.
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
    AND a~kokrs = 'PSCO'.
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
            AND a~kokrs = 'PSCO'.
        IF sy-subrc IS INITIAL.
          APPEND LINES OF lt_csks_delta TO lt_csks_all.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.




  IF lt_csks_all IS NOT INITIAL.

    LOOP AT lt_csks_all INTO DATA(ls_csks_all).
      gs_data-interface_name = 'INT0110'.
      gs_data-receiver_system = 'CONCUR'.
      gs_data-type = 'EMPCC'.
      gs_data-id1 = 'FLD'.
      gs_data-id2 = ls_csks_all-kostl.
      gs_data-id3 = ls_csks_all-ltext.
      IF ls_csks_all-bkzkp IS NOT INITIAL OR ls_csks_all-datbi LT sy-datum.
      ELSE.
        APPEND gs_data TO gt_data.
      ENDIF.
      CLEAR: ls_csks_all , gs_data.
    ENDLOOP.
  ENDIF.

  IF gt_data IS NOT INITIAL AND p_test IS INITIAL.
    TRY.
        DATA(lr_send) = NEW zco_zfi_concur_validation_list( ).
        gs_out-zfi_concur_valid_list-validlist = gt_data[].

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
             'TYPE' 'GT_DATA' 'TYPE',
             'ID1' 'GT_DATA' 'ID1',
             'ID2' 'GT_DATA' 'ID2',
             'ID3' 'GT_DATA' 'ID3',
             'ID4' 'GT_DATA' 'ID4',
             'ID5' 'GT_DATA' 'ID5',
             'ID6' 'GT_DATA' 'ID6',
             'ID7' 'GT_DATA' 'ID7',
             'DATE1' 'GT_DATA' 'DATE1',
             'DATE2' 'GT_DATA' 'DATE2',
             'AMOUNT1' 'GT_DATA' 'AMOUNT1',
             'AMOUNT2' 'GT_DATA' 'AMOUNT2',
             'CURRENCY_CODE' 'GT_DATA' 'CURRENCY_CODE',
             'FLAG1' 'GT_DATA' 'FLAG1',
             'FLAG2' 'GT_DATA' 'FLAG2'.

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
  CONCATENATE 'TEST - Validation List' ':' 'From Date' l_date INTO w_header-info SEPARATED BY space.
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

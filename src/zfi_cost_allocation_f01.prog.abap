*&---------------------------------------------------------------------*
*& Include          ZFI_COST_ALLOCATION_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form read_excel_data_fg
*&---------------------------------------------------------------------*
*& text - Read Excel Sheet data
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_excel_data_fg .

  DATA : lv_filename      TYPE string,
         lt_records       TYPE solix_tab,
         lv_headerxstring TYPE xstring,
         lv_filelength    TYPE i.

  FREE: lt_records.
  lv_filename = p_fpath.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_filename
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelength
      header                  = lv_headerxstring
    TABLES
      data_tab                = lt_records
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filelength
      IMPORTING
        buffer       = lv_headerxstring
      TABLES
        binary_tab   = lt_records
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.

    IF sy-subrc EQ 0.
      DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet .
      TRY .
          lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                                  document_name = lv_filename
                                  xdocument     = lv_headerxstring ) .
        CATCH cx_fdt_excel_core.
      ENDTRY .
      lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
        IMPORTING
          worksheet_names = DATA(lt_worksheets) ).

      IF NOT lt_worksheets IS INITIAL.
        READ TABLE lt_worksheets INTO DATA(lv_woksheetname) INDEX 1.

        DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                                 lv_woksheetname ).
        ASSIGN lo_data_ref->* TO <gt_data>.
        IF sy-subrc NE 0.
          gv_data = abap_true.
        ENDIF.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE <gt_data> LINES DATA(lv_cnt).
    SELECT SINGLE *
      FROM tvarvc
      INTO @DATA(ls_fg_cnt)
     WHERE name EQ 'ZFI_COST_ALLOCATION_FG_CNT'
       AND type EQ 'P'.
    IF sy-subrc EQ 0.
      IF lv_cnt GT ls_fg_cnt-low.
        MESSAGE 'Template lines are more than 5 please execute in Background' TYPE c_s DISPLAY LIKE c_e.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'Please check the filepath entered' TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_file_for_data
*&---------------------------------------------------------------------*
*& text - Process Excel data into internal table
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_file_for_data .

  DATA : lv_numberofcolumns   TYPE i,
         lv_date_string       TYPE string,
         lv_target_date_field TYPE datum.

  FIELD-SYMBOLS : <ls_data>  TYPE any,
                  <lv_field> TYPE any.

  IF gv_data EQ abap_false.
    LOOP AT <gt_data> ASSIGNING <ls_data> FROM 2 .
      DO 23 TIMES.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
        IF sy-subrc = 0.
          CASE sy-index.
            WHEN 1.
              gs_data-descr = <lv_field>.
            WHEN 2.
              gs_data-skstar = |{ <lv_field> ALPHA = IN }|.
            WHEN 3.
              gs_data-skstat = |{ <lv_field> ALPHA = IN }|.
            WHEN 4.
              gs_data-skostl = |{ <lv_field> ALPHA = IN }|.
            WHEN 5.
              gs_data-sndprt = <lv_field>.
            WHEN 6.
              gs_data-sprctr = <lv_field>.
            WHEN 7.
              gs_data-ssegmt = <lv_field>.
            WHEN 8.
              gs_data-samnt = <lv_field>.
            WHEN 9.
              gs_data-rkstar = <lv_field>.
            WHEN 10.
              gs_data-rccgrp = <lv_field>.
            WHEN 11.
              gs_data-rkostl = <lv_field>.
            WHEN 12.
              gs_data-rpcgrp = <lv_field>.
            WHEN 13.
              gs_data-rprctr = <lv_field>.
            WHEN 14.
              gs_data-rcci = <lv_field>.
            WHEN 15.
              gs_data-rccx = <lv_field>.
            WHEN 16.
              gs_data-rsegmt = <lv_field>.
            WHEN 17.
              gs_data-recprt = <lv_field>.
            WHEN 18.
              gs_data-nouni = <lv_field>.
            WHEN 19.
              gs_data-ramnt = <lv_field>.
            WHEN 20.
              gs_data-scena = <lv_field>.
            WHEN 21.
              gs_data-rrksta = <lv_field>.
            WHEN 22.
              gs_data-stagr = <lv_field>.
            WHEN 23.
              gs_data-factor = <lv_field>.
          ENDCASE .
        ENDIF.
      ENDDO .
      APPEND gs_data TO gt_data.
      CLEAR: gs_data.
    ENDLOOP .
  ELSE.
    MESSAGE TEXT-098 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF p_kostl IS NOT INITIAL.
    IF gt_data IS NOT INITIAL.
      DELETE gt_data WHERE skostl NE p_kostl.
      DATA(gt_data_tmp) = gt_data.
      REFRESH: gt_data.
      LOOP AT gt_data_tmp INTO DATA(gs_data_tmp).
        gs_data = gs_data_tmp.
        COLLECT gs_data INTO gt_data.
        CLEAR:gs_data_tmp,gs_data.
      ENDLOOP.
      REFRESH:gt_data_tmp.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_excel_data_bg
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_excel_data_bg .

  DATA : lv_str       TYPE xstring,
         lv_str1      TYPE xstring,
         lv_file      TYPE string,
         lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet,
         lv_archive   TYPE sapb-sappfad,
         lv_new(2000) TYPE c.

  OPEN DATASET p_bpath FOR INPUT IN BINARY MODE.
  IF sy-subrc EQ 0.
    DO.
      CLEAR lv_str1.
      READ DATASET p_bpath INTO lv_str1.
      IF lv_str1 IS NOT INITIAL.
        lv_str = lv_str1.
      ENDIF.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_bpath.

    IF lv_str IS NOT INITIAL.
      lv_file = p_bpath.
      DATA(lx_excel_core) = NEW cx_fdt_excel_core( ).
      TRY.
          lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                                document_name = lv_file
                                xdocument = lv_str ).


        CATCH cx_fdt_excel_core INTO lx_excel_core.
          DATA(lv_msg) = lx_excel_core->if_message~get_text( ).
      ENDTRY.

      ""Get list of worksheets
      lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_worksheets) ).

      IF NOT lt_worksheets IS INITIAL.
        READ TABLE lt_worksheets INTO DATA(ls_worksheets) INDEX 1.

        DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
                                                                      ls_worksheets ).
        ASSIGN lo_data_ref->* TO <gt_data>.
        IF sy-subrc NE 0.
          gv_data = abap_true.
        ENDIF.
      ENDIF.

*      CLEAR : lv_archive.
*      SPLIT p_bpath AT '/interfaces/ENH0011/' INTO DATA(lv_data1) DATA(lv_data2).
*      CONCATENATE lv_data1 '/interfaces/ENH0011' '/archive/' lv_data2 INTO lv_archive.
*
*      OPEN DATASET p_bpath FOR INPUT IN BINARY MODE.
*      OPEN DATASET lv_archive FOR OUTPUT IN BINARY MODE.
*      DO.
*        CLEAR lv_str.
*        READ DATASET p_bpath INTO lv_new.
*        IF sy-subrc EQ 0.
*          TRANSFER lv_new TO lv_archive.
*        ELSE.
*          IF lv_new IS NOT INITIAL.
*            TRANSFER lv_new TO lv_archive.
*          ENDIF.
*          EXIT.
*        ENDIF.
*      ENDDO.
*      CLOSE DATASET p_bpath.
*      CLOSE DATASET lv_archive.
*      DELETE DATASET p_bpath.
    ENDIF.
  ELSE.
    MESSAGE TEXT-091 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form validate_receiver_%_data
*&---------------------------------------------------------------------*
*& text - Vaidate receiver percentage data
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_receiver_%_data .

  DATA: lv_tot TYPE acdoca-hsl.

  DATA(lt_data_tmp) = gt_data.

  DELETE lt_data_tmp WHERE factor NE TEXT-005.

  SORT lt_data_tmp BY skstar ASCENDING
                      skostl ASCENDING.

  DATA(lt_data_tmp_v1) = lt_data_tmp.

  DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING skstar skostl.

  LOOP AT lt_data_tmp INTO DATA(ls_data).
    LOOP AT lt_data_tmp_v1 INTO gs_data WHERE skostl = ls_data-skostl
                                          AND skstar = ls_data-skstar.
      lv_tot = lv_tot + gs_data-recprt.
    ENDLOOP.
    IF lv_tot GT 100.
      CONCATENATE ls_data-skstar '&' ls_data-skostl INTO DATA(lv_error) SEPARATED BY space.
    ENDIF.
    CLEAR: lv_tot.
  ENDLOOP.

  IF lv_error IS NOT INITIAL.
    CONCATENATE lv_error TEXT-061 INTO lv_error  SEPARATED BY space.
    FREE gt_data.
    MESSAGE lv_error TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  FREE: lt_data_tmp, lt_data_tmp_v1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fetch_comp_codes
*&---------------------------------------------------------------------*
*& text - Fetching Cost Center Company codes
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_comp_codes .

  SELECT kostl,
         bukrs,
         prctr,
         datbi,
         datab
    FROM csks                                           "#EC CI_GENBUFF
    INTO TABLE @gt_ccbukrs.
  IF sy-subrc EQ 0.
    SELECT prctr,
           segment
      FROM cepc
      INTO TABLE @gt_pcsg
       FOR ALL ENTRIES IN @gt_ccbukrs
     WHERE prctr EQ @gt_ccbukrs-prctr.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form valid_ccgrp_cc_alloc_fac_data
*&---------------------------------------------------------------------*
*& text- 1) Validate Sender CC & GL both are populated
*        2) Validate alloc factor is not missing
*        3) Validate both CC group and Cost center are not populated
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM valid_ccgrp_cc_alloc_fac_data .

  DATA: lv_tabix     TYPE char10,
        lv_error_emp TYPE char255,
        lv_error_fac TYPE char255,
        lv_error     TYPE char255,
        lv_error_rp  TYPE char255,
        lv_recprt    TYPE char6,
        lv_cnt       TYPE n.

  DATA(lt_data_tmp) = gt_data.
  FREE:lt_data_tmp.
  LOOP AT gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
    lv_tabix = sy-tabix.

    IF <fs_data>-skstat EQ abap_false.
      grs_racct-sign = 'I'.
      grs_racct-option = 'EQ'.
      grs_racct-low = <fs_data>-skstar.
      APPEND grs_racct TO gr_racct.
      CLEAR: grs_racct.
      APPEND <fs_data> TO lt_data_tmp.
    ELSE.
      grs_racct-sign = 'I'.
      grs_racct-option = 'BT'.
      grs_racct-low = <fs_data>-skstar.
      grs_racct-high = <fs_data>-skstat.
      APPEND grs_racct TO gr_racct.
      APPEND grs_racct TO gr_racct_ska1.
      CLEAR: grs_racct.
      SELECT ktopl,
             saknr
        FROM ska1
        INTO TABLE @DATA(lt_ska1)
       WHERE ktopl EQ 'PSUS'
         AND saknr IN @gr_racct_ska1.
      IF sy-subrc EQ 0.
        LOOP AT lt_ska1 INTO DATA(ls_ska1).
          <fs_data>-skstar = |{ ls_ska1-saknr ALPHA = IN }|.
          APPEND <fs_data> TO lt_data_tmp.
        ENDLOOP.
      ENDIF.
      REFRESH:gr_racct_ska1,lt_ska1.
    ENDIF.

    grs_rcntr-sign = 'I'.
    grs_rcntr-option = 'EQ'.
    grs_rcntr-low = <fs_data>-skostl.
    APPEND grs_rcntr TO gr_rcntr.
    CLEAR: grs_rcntr.

    IF <fs_data>-rccgrp NE abap_false.
      lv_cnt = lv_cnt + 1.
    ENDIF.
    IF <fs_data>-rkostl NE abap_false.
      lv_cnt = lv_cnt + 1.
    ENDIF.
    IF <fs_data>-rpcgrp NE abap_false.
      lv_cnt = lv_cnt + 1.
    ENDIF.
    IF <fs_data>-rprctr NE abap_false.
      lv_cnt = lv_cnt + 1.
      IF lv_cnt EQ 1.
        READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = <fs_data>-rprctr.
        IF sy-subrc EQ 0.
          <fs_data>-rkostl = gs_ccbukrs-kostl.
        ENDIF.
      ENDIF.
    ENDIF.
    IF lv_cnt GT 1.
      CONCATENATE lv_error
                  'Row-'
                  lv_tabix
                  <fs_data>-skstar
                  '-'
                  <fs_data>-skostl
             INTO lv_error SEPARATED BY space.
      CONDENSE lv_error.
    ENDIF.
    IF <fs_data>-factor EQ abap_false.
      CONCATENATE lv_error_fac
                  'Row-'
                  lv_tabix
                  <fs_data>-skstar
                  '-'
                  <fs_data>-skostl
             INTO lv_error_fac SEPARATED BY space.
      CONDENSE lv_error_fac.
    ENDIF.
    IF <fs_data>-skstar EQ abap_false
      OR <fs_data>-skostl EQ abap_false.
      CONCATENATE lv_error_emp
                  'Row-'
                  lv_tabix
                  <fs_data>-skstar
                  '-'
                  <fs_data>-skostl
             INTO lv_error_emp SEPARATED BY space.
      CONDENSE lv_error_emp.
    ENDIF.
    IF <fs_data>-recprt GT 100.
      lv_recprt = <fs_data>-recprt.
      CONCATENATE lv_error_rp
                  'Row-'
                  lv_tabix
                  lv_recprt
             INTO lv_error_rp SEPARATED BY space.
      CONDENSE lv_error_rp.
    ENDIF.
    CLEAR:lv_cnt.
  ENDLOOP.

  IF lv_error_rp IS NOT INITIAL.
    CONCATENATE lv_error_rp
                TEXT-096
           INTO lv_error_rp SEPARATED BY space.
    FREE gt_data.
    MESSAGE lv_error_rp TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF lv_error IS NOT INITIAL.
    CONCATENATE lv_error
                TEXT-062
           INTO lv_error  SEPARATED BY space.
    FREE gt_data.
    MESSAGE lv_error TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF lv_error_fac IS NOT INITIAL.
    CONCATENATE lv_error_fac
                TEXT-063
           INTO lv_error_fac SEPARATED BY space.
    FREE gt_data.
    MESSAGE lv_error_fac TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF lv_error_emp IS NOT INITIAL.
    CONCATENATE lv_error_emp
                TEXT-064
           INTO lv_error_emp SEPARATED BY space.
    FREE gt_data.
    MESSAGE lv_error_emp TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  REFRESH: gt_data.
  gt_data = lt_data_tmp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fetch_redirect_cost_centers
*&---------------------------------------------------------------------*
*& text - Fetch all Redirect Cost Centers
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_redirect_cost_centers.

  SELECT scena,
         skostl,
         rkostl
    FROM zfi_costallored
    INTO TABLE @gt_redirect.
  IF sy-subrc EQ 0.
    SORT gt_redirect BY skostl.
    LOOP AT gt_redirect ASSIGNING FIELD-SYMBOL(<fs_redir>).
      <fs_redir>-skostl = |{ <fs_redir>-skostl ALPHA = OUT }|.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form fetch_acdoca_records
*&---------------------------------------------------------------------*
*& text - Fetch all ACDOCA records
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fetch_acdoca_records .

  SORT: gr_racct, gr_rcntr.
  DELETE ADJACENT DUPLICATES FROM gr_racct COMPARING ALL FIELDS.
  DELETE ADJACENT DUPLICATES FROM gr_rcntr COMPARING ALL FIELDS.
  IF gr_racct IS NOT INITIAL.
    SELECT rldnr,
           rbukrs,
           gjahr,
           belnr,
           docln,
           racct,
           rcntr,
           hsl
      FROM acdoca
      INTO TABLE @gt_data_doc
     WHERE rldnr EQ @p_rldnr
       AND racct IN @gr_racct
       AND rcntr IN @gr_rcntr
       AND ryear EQ @p_gjahr
       AND poper EQ @p_monat
       AND blart IN @s_blart.
    IF sy-subrc EQ 0.
      FREE:gr_rcntr,gr_racct.
      SORT gt_data_doc BY rcntr racct.
      DATA(lt_data_tmp) = gt_data_doc.
      SORT lt_data_tmp BY racct.
      DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING racct.
      LOOP AT lt_data_tmp INTO DATA(ls_doca).
        grs_racct-sign = 'I'.
        grs_racct-option = 'EQ'.
        grs_racct-low = ls_doca-racct.
        APPEND grs_racct TO gr_racct.
        CLEAR: grs_racct.
      ENDLOOP.
      DELETE gt_data WHERE skstar NOT IN gr_racct.
    ELSE.
      MESSAGE TEXT-097 TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ENDIF.
    FREE:gr_rcntr,gr_racct,lt_data_tmp.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_receiver_percentage
*&---------------------------------------------------------------------*
*& text - Process all records of Receiver Percentage allocation
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_receiver_percentage.

  DATA: lv_setcls TYPE setclass,
        lv_grp    TYPE c,
        lv_tot    TYPE acdoca-hsl.

  DATA(lt_data_tmp) = gt_data.

  DELETE lt_data_tmp WHERE factor NE TEXT-005.

  IF lt_data_tmp IS NOT INITIAL.
    SORT lt_data_tmp BY skstar ASCENDING
                        skostl ASCENDING.

    DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING skstar skostl .

    LOOP AT lt_data_tmp INTO DATA(ls_data_tmp).
      LOOP AT gt_data INTO gs_data WHERE skstar = ls_data_tmp-skstar
                                     AND skostl = ls_data_tmp-skostl
                                     AND factor = TEXT-005.
        PERFORM sumup_total USING gs_data CHANGING gv_amt.
        PERFORM populate_ix_kostls USING gs_data.
        PERFORM sen_cost_center_date_validity USING gs_data CHANGING gv_err_msg.
        IF gv_err_msg NE abap_false.
          CONTINUE.
        ENDIF.
        IF gs_data-recprt EQ abap_false.
          gs_data-recprt = '100.00'.
        ENDIF.
        CLEAR:lv_grp,lv_setcls,gv_nname.
        IF gs_data-rccgrp NE abap_false.
          lv_grp = abap_true.
          lv_setcls = '0101'.
          gv_nname = gs_data-rccgrp.
        ENDIF.
        IF gs_data-rpcgrp NE abap_false.
          lv_grp = abap_true.
          lv_setcls = '0106'.
          gv_nname = gs_data-rpcgrp.
        ENDIF.
        IF lv_grp NE abap_false.
          FREE:gt_row,gt_nodes.
          CALL FUNCTION 'ZFI_CCPC_HIERARCHY_READ'
            EXPORTING
              i_setclass                = lv_setcls
              i_subclass                = 'PSCO'
              i_setname                 = gv_nname
              i_row                     = abap_true
            TABLES
              output                    = gt_row
              nodes                     = gt_nodes
            EXCEPTIONS ##FM_SUBRC_OK
              invalid_setclass          = 1
              invalid_selection_row_col = 2
              invalid_input             = 3
              OTHERS                    = 4.
          DELETE gt_row WHERE value EQ abap_false.
          IF gt_row IS NOT INITIAL.
            PERFORM include_exclude_cceenters.
            SORT gt_row BY value.
            DELETE ADJACENT DUPLICATES FROM gt_row COMPARING value.
            LOOP AT gt_row INTO DATA(ls_row).
              READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_row-value.
              IF sy-subrc EQ 0.
                IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
                ELSE.
                  DELETE gt_row WHERE value = ls_row-value.
                ENDIF.
              ELSE.
                DELETE gt_row WHERE value = ls_row-value.
              ENDIF.
            ENDLOOP.
            DESCRIBE TABLE gt_row LINES DATA(lv_lines).
            gv_amt = gv_amt / lv_lines.
            IF gv_amt LE 0.
              PERFORM populate_error_messages USING gs_data TEXT-095.
            ELSE.
              LOOP AT gt_row INTO ls_row.
                IF lv_setcls = '0106'.
                  READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = ls_row-value.
                  IF sy-subrc EQ 0.
                    gs_data-rkostl = gs_ccbukrs-kostl.
                  ENDIF.
                ELSE.
                  gs_data-rkostl = ls_row-value.
                ENDIF.
                PERFORM check_redirect USING gs_data CHANGING gs_data.
                IF gv_amt EQ 0.
                  PERFORM populate_error_messages USING gs_data TEXT-095.
                ELSE.
                  PERFORM prepare_direct_data USING gv_amt gs_data.
                  PERFORM bapi_post USING gs_data.
                ENDIF.
              ENDLOOP.
            ENDIF.
            CLEAR: lv_lines.
          ELSE.
            CONCATENATE TEXT-068
                        gs_data-rccgrp
                   INTO gv_err_msg
              SEPARATED BY space.
            PERFORM populate_error_messages USING gs_data gv_err_msg.
          ENDIF.
          FREE:gt_row,gt_nodes,lv_setcls,lv_grp.
        ELSE.
          IF gs_data-rprctr NE abap_false.
            READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = gs_data-rprctr.
            gs_data-rkostl = gs_ccbukrs-kostl.
            gs_kostl-kostl = gs_ccbukrs-kostl.
            APPEND gs_kostl TO gt_kostl_i.
            CLEAR:gs_kostl.
          ENDIF.
          IF gs_data-rkostl NE abap_false.
            gs_kostl-kostl = gs_data-rkostl.
            APPEND gs_kostl TO gt_kostl_i.
            CLEAR:gs_kostl.
          ENDIF.
          IF gt_kostl_x IS NOT INITIAL.
            LOOP AT gt_kostl_x INTO gs_kostl.
              DELETE gt_kostl_i WHERE kostl EQ gs_kostl-kostl.
            ENDLOOP.
          ENDIF.
          CLEAR:lv_lines.
          SORT gt_kostl_i BY kostl.
          DELETE ADJACENT DUPLICATES FROM gt_kostl_i COMPARING kostl.
          LOOP AT gt_kostl_i INTO gs_kostl.
            READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = gs_kostl-kostl.
            IF sy-subrc EQ 0.
              IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
              ELSE.
                DELETE gt_kostl_i WHERE kostl = gs_kostl-kostl.
              ENDIF.
            ELSE.
              DELETE gt_kostl_i WHERE kostl = gs_kostl-kostl.
            ENDIF.
          ENDLOOP.
          DESCRIBE TABLE gt_kostl_i LINES lv_lines.
          gv_amt = gv_amt / lv_lines.
          IF gv_amt LE 0.
            PERFORM populate_error_messages USING gs_data TEXT-095.
          ELSE.
            LOOP AT gt_kostl_i INTO gs_kostl.
              gs_data-rkostl = gs_kostl-kostl.
              PERFORM check_redirect USING gs_data CHANGING gs_data.
              IF gv_amt EQ 0.
                PERFORM populate_error_messages USING gs_data TEXT-095.
              ELSE.
                PERFORM prepare_direct_data USING gv_amt gs_data.
                PERFORM bapi_post USING gs_data.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
        CLEAR:gv_amt.
        REFRESH: gt_kostl_i,gt_kostl_x.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  DELETE gt_data WHERE factor EQ TEXT-005.
  FREE: lt_data_tmp.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_receiver_units
*&---------------------------------------------------------------------*
*&text-Process all records of Receiver Units and Receiver Occuiped Units
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_receiver_units USING p_type TYPE char50.

  TYPES: BEGIN OF ty_grpcnt,
           rccgrp TYPE char15,
           count  TYPE char10,
         END OF ty_grpcnt.

  DATA: lt_row_tmp TYPE TABLE OF zfi_ccpc_hierarchy_read,
        lv_msl     TYPE faglskf-msl,
        lv_count   TYPE char10,
        lt_cnt     TYPE TABLE OF ty_grpcnt,
        ls_cnt     TYPE ty_grpcnt,
        lv_setcls  TYPE setclass,
        lv_grp     TYPE c,
        lv_rccgrp  TYPE char15.

  DATA(lt_data_tmp) = gt_data.

  DELETE lt_data_tmp WHERE factor NE p_type. "RECOCUNITS

  IF lt_data_tmp IS NOT INITIAL.
    SORT lt_data_tmp BY skstar ASCENDING
                        skostl ASCENDING.
    DATA(lt_data_tmp_v1) = lt_data_tmp.
    DATA(lt_data_tmp_v2) = lt_data_tmp.
    FREE: lt_data_tmp_v2,lt_row_tmp.
    DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING skstar skostl .
    LOOP AT lt_data_tmp INTO DATA(ls_data_tmp).
* Accumulate all Receiver Cost Centers based on Group and individual
      LOOP AT lt_data_tmp_v1 INTO DATA(ls_data_tmp_v1) WHERE skstar EQ ls_data_tmp-skstar
                                                         AND skostl EQ ls_data_tmp-skostl.
        PERFORM sen_cost_center_date_validity USING ls_data_tmp_v1 CHANGING gv_err_msg.
        IF gv_err_msg NE abap_false.
          CONTINUE.
        ENDIF.
        PERFORM populate_ix_kostls USING ls_data_tmp_v1.
        PERFORM sumup_total USING ls_data_tmp_v1 CHANGING gv_amt.
        IF gv_amt LE 0.
          PERFORM populate_error_messages USING ls_data_tmp_v1 TEXT-095.
          CONTINUE.
        ENDIF.
        IF ls_data_tmp_v1-rccgrp NE abap_false.
          lv_grp = abap_true.
          lv_setcls = '0101'.
          gv_nname = ls_data_tmp_v1-rccgrp.
        ENDIF.
        IF ls_data_tmp_v1-rpcgrp NE abap_false.
          lv_grp = abap_true.
          lv_setcls = '0106'.
          gv_nname = ls_data_tmp_v1-rpcgrp.
        ENDIF.
        IF lv_grp NE abap_false.
          CALL FUNCTION 'ZFI_CCPC_HIERARCHY_READ'
            EXPORTING
              i_setclass                = lv_setcls
              i_subclass                = 'PSCO'
              i_setname                 = gv_nname
              i_row                     = abap_true
            TABLES
              output                    = gt_row
              nodes                     = gt_nodes
            EXCEPTIONS
              invalid_setclass          = 1
              invalid_selection_row_col = 2
              invalid_input             = 3
              OTHERS                    = 4.
          IF sy-subrc EQ 0.
            IF gt_row IS INITIAL.
              IF lv_setcls EQ '0106'.
                CONCATENATE TEXT-099
                            TEXT-100
                            gv_nname
                       INTO gv_err_msg
                  SEPARATED BY space.
              ENDIF.
              IF lv_setcls EQ '0101'.
                CONCATENATE TEXT-099
                            TEXT-101
                            gv_nname
                       INTO gv_err_msg
                  SEPARATED BY space.
              ENDIF.
              PERFORM populate_error_messages USING ls_data_tmp_v1 gv_err_msg.
              CLEAR:gv_err_msg.
              CONTINUE.
            ENDIF.
            READ TABLE gt_row INTO DATA(ls_row_pa) WITH KEY parentnode = gv_nname.
            DELETE gt_row WHERE value EQ abap_false.
            PERFORM include_exclude_cceenters.
            LOOP AT gt_row ASSIGNING FIELD-SYMBOL(<fs_row>).
              <fs_row>-parentnode = ls_row_pa-parentnode.
              IF lv_setcls = '0106'.
                READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = <fs_row>-value.
                IF sy-subrc EQ 0.
                  <fs_row>-value = gs_ccbukrs-kostl.
                ENDIF.
              ENDIF.
            ENDLOOP.
            APPEND LINES OF gt_row TO lt_row_tmp.
            FREE:gt_row,gt_nodes.
          ENDIF.
        ELSE.
          IF ls_data_tmp_v1-rprctr NE abap_false.
            CLEAR:gs_ccbukrs.
            READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = ls_data_tmp_v1-rprctr.
            IF sy-subrc EQ 0.
              gs_row-value = gs_ccbukrs-kostl.
            ENDIF.
          ELSE.
            gs_row-value = ls_data_tmp_v1-rkostl.
          ENDIF.
          APPEND gs_row TO lt_row_tmp.
          CLEAR:gs_row.

          SORT gt_kostl_i BY kostl.
          DELETE ADJACENT DUPLICATES FROM gt_kostl_i COMPARING kostl.

          LOOP AT gt_kostl_i INTO gs_kostl.
            gs_row-value = gs_kostl-kostl.
            APPEND gs_row TO lt_row_tmp.
            CLEAR:gs_row.
          ENDLOOP.

          LOOP AT gt_kostl_x INTO gs_kostl.
            DELETE lt_row_tmp WHERE value EQ gs_kostl-kostl.
          ENDLOOP.
        ENDIF.
        CLEAR:lv_grp,lv_setcls,gv_nname.

* Eliminate Cost Centers which are not on Valid Posting date
        SORT lt_row_tmp BY value.
        DELETE ADJACENT DUPLICATES FROM lt_row_tmp COMPARING value.
        LOOP AT lt_row_tmp INTO DATA(ls_row).
          READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_row-value.
          IF sy-subrc EQ 0.
            IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
            ELSE.
              DELETE lt_row_tmp WHERE value = ls_row-value.
            ENDIF.
          ELSE.
            DELETE lt_row_tmp WHERE value = ls_row-value.
          ENDIF.
        ENDLOOP.
* Get No. of Units from faglskf_pn table
        IF lt_row_tmp IS NOT INITIAL.
          SELECT stagr,
                 date_from,
                 docnr,
                 docln,
                 date_to,
                 rcntr,
                 prctr,
                 msl
            FROM faglskf_pn
            INTO TABLE @DATA(lt_faglskf)
             FOR ALL ENTRIES IN @lt_row_tmp
           WHERE stagr EQ @ls_data_tmp-stagr
             AND date_from IN @s_budat
             AND rcntr EQ @lt_row_tmp-value.
          IF sy-subrc EQ 0.
            SORT lt_faglskf BY date_from DESCENDING.
          ENDIF.
        ENDIF.
* Populate No. of Units and calculate total No. of Units
        IF ls_data_tmp_v1-rprctr NE abap_false.
          READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = ls_data_tmp_v1-rprctr.
          IF sy-subrc EQ 0.
            ls_data_tmp_v1-rkostl = gs_ccbukrs-kostl.
          ENDIF.
        ENDIF.
        IF ls_data_tmp_v1-rkostl NE abap_false. " When Receiver Cost Center is populated
          READ TABLE lt_faglskf
           INTO DATA(ls_faglskf)
            WITH KEY rcntr = ls_data_tmp_v1-rkostl.
          IF sy-subrc EQ 0.
            IF ls_faglskf-msl LT 0.
              ls_faglskf-msl = ls_faglskf-msl * -1.
            ENDIF.
            ls_data_tmp_v1-nouni = ls_faglskf-msl.
            lv_msl = lv_msl + ls_data_tmp_v1-nouni.
            APPEND ls_data_tmp_v1 TO lt_data_tmp_v2.
            CLEAR:ls_faglskf.
          ELSE.
            CONCATENATE TEXT-090
                        ls_data_tmp_v1-rkostl
                   INTO gv_err_msg
            SEPARATED BY space.
            PERFORM populate_error_messages USING ls_data_tmp_v1 gv_err_msg.
            CLEAR:gv_err_msg.
            CONTINUE.
          ENDIF.
        ELSE. " When Receiver Cost Center Group is populated
          CLEAR:lv_rccgrp.
          IF ls_data_tmp_v1-rccgrp NE abap_false.
            lv_rccgrp = ls_data_tmp_v1-rccgrp.
          ENDIF.
          IF ls_data_tmp_v1-rpcgrp NE abap_false.
            lv_rccgrp = ls_data_tmp_v1-rpcgrp.
          ENDIF.
          LOOP AT lt_row_tmp INTO gs_row WHERE parentnode = lv_rccgrp.
            READ TABLE lt_faglskf
                  INTO ls_faglskf
              WITH KEY rcntr = gs_row-value.
            IF sy-subrc EQ 0.
              lv_count = lv_count + 1.
              IF ls_faglskf-msl LT 0.
                ls_faglskf-msl = ls_faglskf-msl * -1.
              ENDIF.
              ls_data_tmp_v1-nouni = ls_faglskf-msl.
              ls_data_tmp_v1-rkostl = gs_row-value.
              lv_msl = lv_msl + ls_data_tmp_v1-nouni.
              APPEND ls_data_tmp_v1 TO lt_data_tmp_v2.
              CLEAR:ls_faglskf.
            ELSE.
              CLEAR:ls_data_tmp_v1-nouni.
              ls_data_tmp_v1-rkostl = gs_row-value.
              CONCATENATE TEXT-090
                          gs_row-value
                     INTO gv_err_msg
              SEPARATED BY space.
              PERFORM populate_error_messages USING ls_data_tmp_v1 gv_err_msg.
              CLEAR:gv_err_msg.
              CONTINUE.
            ENDIF.
          ENDLOOP.
* Populate total line for each Cost Center group to split the dollar value evenly
          ls_cnt-count = lv_count.
          IF ls_data_tmp_v1-rccgrp IS NOT INITIAL.
            ls_cnt-rccgrp = ls_data_tmp_v1-rccgrp.
          ENDIF.
          IF ls_data_tmp_v1-rpcgrp IS NOT INITIAL.
            ls_cnt-rccgrp = ls_data_tmp_v1-rpcgrp.
          ENDIF.
          APPEND ls_cnt TO lt_cnt.
          CLEAR: ls_cnt.
* Populate Receiver Percentage
          LOOP AT lt_data_tmp_v2 ASSIGNING FIELD-SYMBOL(<fs_data_tmp_v2>).
            <fs_data_tmp_v2>-recprt = ( <fs_data_tmp_v2>-nouni * 100 ) / lv_msl.
          ENDLOOP.
        ENDIF.

* Process fully data populated to post
        LOOP AT lt_data_tmp_v2 ASSIGNING FIELD-SYMBOL(<fs_data_tmp_v3>).
          IF <fs_data_tmp_v3>-rccgrp EQ abap_false
            AND <fs_data_tmp_v3>-rpcgrp EQ abap_false.
            PERFORM check_redirect USING <fs_data_tmp_v3> CHANGING <fs_data_tmp_v3>.
            IF gv_amt EQ 0.
              PERFORM populate_error_messages USING <fs_data_tmp_v3> TEXT-095.
            ELSE.
              PERFORM prepare_direct_data USING gv_amt <fs_data_tmp_v3>.
              PERFORM bapi_post USING <fs_data_tmp_v3>.
            ENDIF.
          ELSE.
            CLEAR:lv_rccgrp.
            IF <fs_data_tmp_v3>-rccgrp NE abap_false.
              lv_rccgrp = <fs_data_tmp_v3>-rccgrp.
            ENDIF.
            IF <fs_data_tmp_v3>-rpcgrp NE abap_false.
              lv_rccgrp = <fs_data_tmp_v3>-rpcgrp.
            ENDIF.
            PERFORM check_redirect USING <fs_data_tmp_v3> CHANGING <fs_data_tmp_v3>.
            IF gv_amt EQ 0.
              PERFORM populate_error_messages USING <fs_data_tmp_v3> TEXT-095.
            ELSE.
              PERFORM prepare_direct_data USING gv_amt <fs_data_tmp_v3>.
              PERFORM bapi_post USING <fs_data_tmp_v3>.
            ENDIF.
          ENDIF.
        ENDLOOP.
        REFRESH:lt_row_tmp,lt_data_tmp_v2,lt_faglskf,lt_cnt.
        CLEAR:gv_amt,lv_count,lv_msl.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
  DELETE gt_data WHERE factor EQ p_type.
  FREE: lt_data_tmp, lt_data_tmp_v1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_websites
*&---------------------------------------------------------------------*
*& text - Process websites records
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_websites .

  DATA: lr_date       TYPE RANGE OF date_from,
        lv_first_date TYPE date_from,
        lv_end_date   TYPE date_from,
        lv_msl        TYPE faglskf-msl.

  DATA(lt_data_tmp) = gt_data.
  DELETE lt_data_tmp WHERE factor NE TEXT-009.

  IF lt_data_tmp IS NOT INITIAL.
* Fetch all Cost Centers for the Websites SKF's
    SELECT stagr,
           date_from,
           docnr,
           docln,
           date_to,
           rcntr,
           prctr,
           msl
      FROM faglskf_pn
      INTO TABLE @DATA(lt_faglskf)
       FOR ALL ENTRIES IN @lt_data_tmp
     WHERE stagr EQ @lt_data_tmp-stagr
       AND date_from IN @s_budat.
    IF sy-subrc EQ 0.
      SORT lt_faglskf BY date_from DESCENDING
                             rcntr DESCENDING.
      DELETE ADJACENT DUPLICATES FROM lt_faglskf COMPARING rcntr.
* Eliminate Cost Centers which are not on Valid Posting date
      LOOP AT lt_faglskf INTO DATA(ls_row).
        READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_row-rcntr.
        IF sy-subrc EQ 0.
          IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
          ELSE.
            DELETE lt_faglskf WHERE rcntr = ls_row-rcntr.
          ENDIF.
        ELSE.
          DELETE lt_faglskf WHERE rcntr = ls_row-rcntr.
        ENDIF.
      ENDLOOP.
    ENDIF.

    SORT lt_data_tmp BY skstar ASCENDING
                        skostl ASCENDING.

    DATA(lt_data_tmp_v1) = lt_data_tmp.
    DATA(lt_data_tmp_v2) = lt_data_tmp.
    FREE: lt_data_tmp_v1.
    DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING skstar skostl .

    LOOP AT lt_data_tmp INTO DATA(ls_data_tmp).
      PERFORM sumup_total USING ls_data_tmp CHANGING gv_amt.
      IF gv_amt LE 0.
        PERFORM populate_error_messages USING ls_data_tmp TEXT-095.
        CONTINUE.
      ENDIF.
      LOOP AT lt_data_tmp_v2 INTO DATA(ls_data_tmp_v2) WHERE skstar = ls_data_tmp-skstar
                                                         AND skostl = ls_data_tmp-skostl.
        PERFORM sen_cost_center_date_validity USING ls_data_tmp_v2 CHANGING gv_err_msg.
        IF gv_err_msg NE abap_false.
          CONTINUE.
        ENDIF.
        LOOP AT lt_faglskf INTO DATA(ls_faglskf) WHERE stagr EQ ls_data_tmp_v2-stagr.
          IF ls_faglskf-msl LT 0.
            ls_faglskf-msl = ls_faglskf-msl * -1.
          ENDIF.
          ls_data_tmp_v2-nouni = ls_faglskf-msl.
          ls_data_tmp_v2-rkostl = ls_faglskf-rcntr.
          lv_msl = lv_msl + ls_data_tmp_v2-nouni.
          APPEND ls_data_tmp_v2 TO lt_data_tmp_v1.
        ENDLOOP.
* Populate Receiver Percentage
        LOOP AT lt_data_tmp_v1 ASSIGNING FIELD-SYMBOL(<fs_data_tmp_v1>).
          <fs_data_tmp_v1>-recprt = ( <fs_data_tmp_v1>-nouni * 100 ) / lv_msl.
        ENDLOOP.
      ENDLOOP.
* Process fully data populated to post
      LOOP AT lt_data_tmp_v1 INTO gs_data.
        PERFORM check_redirect USING gs_data CHANGING gs_data.
        IF gv_amt EQ 0.
          PERFORM populate_error_messages USING gs_data TEXT-095.
        ELSE.
          PERFORM prepare_direct_data USING gv_amt gs_data.
          PERFORM bapi_post USING gs_data.
        ENDIF.
      ENDLOOP.
      FREE:lt_data_tmp_v1.
      CLEAR:lv_msl,gv_amt.
    ENDLOOP.
  ENDIF.
  DELETE gt_data WHERE factor EQ TEXT-009.
  FREE: lt_data_tmp, lt_data_tmp_v1,lt_data_tmp_v2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_combined_units
*&---------------------------------------------------------------------*
*& text - Process all records of Combined Units
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_combined_units .

  TYPES: BEGIN OF ty_kostl,
           skstar TYPE acdoca-racct,
           skostl TYPE acdoca-rcntr,
           rcntr  TYPE acdoca-rcntr,
         END OF ty_kostl.

  DATA: ls_kostl      TYPE ty_kostl,
        lt_kostl      TYPE TABLE OF ty_kostl,
        lr_date       TYPE RANGE OF date_from,
        lv_first_date TYPE date_from,
        lv_end_date   TYPE date_from,
        lv_msl        TYPE faglskf-msl,
        lv_grp        TYPE c,
        lv_setcls     TYPE setclass,
        lt_row_tmp    TYPE TABLE OF zfi_ccpc_hierarchy_read.

  DATA(lt_data_tmp) = gt_data.
  DELETE lt_data_tmp WHERE factor NE TEXT-008.
** Fetch all Cost Centers for the groups
  LOOP AT lt_data_tmp INTO DATA(ls_data_tmp).
    PERFORM populate_ix_kostls USING ls_data_tmp.
    IF ls_data_tmp-rccgrp NE abap_false.
      lv_grp = abap_true.
      lv_setcls = '0101'.
      gv_nname = ls_data_tmp-rccgrp.
    ENDIF.
    IF ls_data_tmp-rpcgrp NE abap_false.
      lv_grp = abap_true.
      lv_setcls = '0106'.
      gv_nname = ls_data_tmp-rpcgrp.
    ENDIF.
    IF lv_grp NE abap_false.
      CALL FUNCTION 'ZFI_CCPC_HIERARCHY_READ'
        EXPORTING
          i_setclass                = lv_setcls
          i_subclass                = 'PSCO'
          i_setname                 = gv_nname
          i_row                     = abap_true
        TABLES
          output                    = gt_row
          nodes                     = gt_nodes
        EXCEPTIONS
          invalid_setclass          = 1
          invalid_selection_row_col = 2
          invalid_input             = 3
          OTHERS                    = 4.
      IF sy-subrc EQ 0.
        READ TABLE gt_row INTO DATA(ls_row_pa) WITH KEY parentnode = gv_nname.
        DELETE gt_row WHERE value EQ abap_false.
        PERFORM include_exclude_cceenters.
        LOOP AT gt_row ASSIGNING FIELD-SYMBOL(<fs_row>).
          <fs_row>-parentnode = ls_row_pa-parentnode.
          IF lv_setcls = '0106'.
            READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = <fs_row>-value.
            IF sy-subrc EQ 0.
              <fs_row>-value = gs_ccbukrs-kostl.
            ENDIF.
          ENDIF.
          ls_kostl-skstar = ls_data_tmp-skstar.
          ls_kostl-skostl = ls_data_tmp-skostl.
          ls_kostl-rcntr = <fs_row>-value.
          ls_kostl-rcntr = |{ ls_kostl-rcntr ALPHA = IN }|.
          APPEND ls_kostl TO lt_kostl.
          CLEAR:ls_kostl.
        ENDLOOP.
        FREE:gt_row,gt_nodes.
      ENDIF.
    ELSE.
      IF ls_data_tmp-rprctr NE abap_false.
        READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY prctr = ls_data_tmp-rprctr.
        IF sy-subrc EQ 0.
          ls_kostl-rcntr = gs_ccbukrs-kostl.
        ENDIF.
      ELSE.
        ls_kostl-rcntr = ls_data_tmp-rkostl.
      ENDIF.
      ls_kostl-skstar = ls_data_tmp-skstar.
      ls_kostl-skostl = ls_data_tmp-skostl.
      ls_kostl-rcntr = |{ ls_kostl-rcntr ALPHA = IN }|.
      APPEND ls_kostl TO lt_kostl.
      CLEAR:ls_kostl.
      SORT gt_kostl_i BY kostl.
      DELETE ADJACENT DUPLICATES FROM gt_kostl_i COMPARING kostl.
      LOOP AT gt_kostl_i INTO gs_kostl.
        ls_kostl-skstar = ls_data_tmp-skstar.
        ls_kostl-skostl = ls_data_tmp-skostl.
        ls_kostl-rcntr = |{ gs_kostl-kostl ALPHA = IN }|.
        APPEND ls_kostl TO lt_kostl.
        CLEAR:ls_kostl.
      ENDLOOP.
      LOOP AT gt_kostl_x INTO gs_kostl.
        DELETE lt_kostl WHERE rcntr EQ gs_kostl-kostl.
        CLEAR:ls_kostl.
      ENDLOOP.
    ENDIF.
    CLEAR:lv_grp,lv_setcls,gv_nname.
  ENDLOOP.

  IF lt_data_tmp IS NOT INITIAL.
* Eliminate Cost Centers which are not on Valid Posting date
    SORT lt_kostl BY rcntr.
    DELETE ADJACENT DUPLICATES FROM lt_kostl COMPARING rcntr.
    LOOP AT lt_kostl INTO DATA(ls_row).
      READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_row-rcntr.
      IF sy-subrc EQ 0.
        IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
        ELSE.
          DELETE lt_kostl WHERE rcntr = ls_row-rcntr.
        ENDIF.
      ELSE.
        DELETE lt_kostl WHERE rcntr = ls_row-rcntr.
      ENDIF.
    ENDLOOP.
    DATA(lt_kostl_tmp) = lt_kostl.
    SORT lt_kostl_tmp BY rcntr.
    DELETE ADJACENT DUPLICATES FROM lt_kostl_tmp COMPARING rcntr.
    DELETE lt_kostl_tmp WHERE rcntr EQ abap_false.
    IF lt_kostl_tmp IS NOT INITIAL.
      SELECT plant,
             legacy_property_number,
             combined_surviving_number
        FROM zproperty
        INTO TABLE @DATA(lt_property)
         FOR ALL ENTRIES IN @lt_kostl_tmp
       WHERE combined_surviving_number EQ @lt_kostl_tmp-rcntr.
      IF sy-subrc EQ 0.
* Fetch all Cost Centers for the Combined SKF's
        READ TABLE lt_data_tmp INTO ls_data_tmp INDEX 1.
        IF ls_data_tmp-stagr NE abap_false.
          LOOP AT lt_property ASSIGNING FIELD-SYMBOL(<fs_prop>).
            IF <fs_prop>-legacy_property_number NE abap_false.
              <fs_prop>-legacy_property_number = |{ <fs_prop>-legacy_property_number ALPHA = IN }|.
            ENDIF.
          ENDLOOP.
          SELECT stagr,                            "#EC CI_NO_TRANSFORM
                 date_from,
                 docnr,
                 docln,
                 date_to,
                 rcntr,
                 prctr,
                 msl
            FROM faglskf_pn
            INTO TABLE @DATA(lt_faglskf)
             FOR ALL ENTRIES IN @lt_property
           WHERE stagr EQ @ls_data_tmp-stagr
             AND date_from IN @s_budat
             AND rcntr EQ @lt_property-legacy_property_number.
          IF sy-subrc EQ 0.
            SORT lt_faglskf BY date_from DESCENDING
                                   rcntr DESCENDING.
            DELETE ADJACENT DUPLICATES FROM lt_faglskf COMPARING rcntr.
            SORT lt_data_tmp BY skstar ASCENDING
                                skostl ASCENDING.

            DATA(lt_data_tmp_v1) = lt_data_tmp.
            FREE:lt_data_tmp_v1.

            DATA(lt_data_tmp_v2) = lt_data_tmp.

            DELETE ADJACENT DUPLICATES FROM lt_data_tmp COMPARING skstar skostl .
            LOOP AT lt_data_tmp INTO ls_data_tmp.
              PERFORM sumup_total USING ls_data_tmp CHANGING gv_amt.
              IF gv_amt LE 0.
                PERFORM populate_error_messages USING ls_data_tmp TEXT-095.
                CONTINUE.
              ENDIF.
              LOOP AT lt_data_tmp_v2 INTO DATA(ls_data_tmp_v2) WHERE skstar = ls_data_tmp-skstar
                                                                 AND skostl = ls_data_tmp-skostl.
                PERFORM sen_cost_center_date_validity USING ls_data_tmp_v2 CHANGING gv_err_msg.
                IF gv_err_msg NE abap_false.
                  CONTINUE.
                ENDIF.
                LOOP AT lt_kostl INTO ls_kostl WHERE skstar = ls_data_tmp-skstar
                                               AND skostl = ls_data_tmp-skostl.
                  LOOP AT lt_property INTO DATA(ls_property) WHERE combined_surviving_number EQ ls_kostl-rcntr.
                    READ TABLE lt_faglskf INTO DATA(ls_faglskf) WITH KEY rcntr = ls_property-legacy_property_number.
                    IF sy-subrc EQ 0.
                      IF ls_faglskf-msl LT 0.
                        ls_faglskf-msl = ls_faglskf-msl * -1.
                      ENDIF.
                      ls_data_tmp_v2-nouni = ls_faglskf-msl.
                      ls_data_tmp_v2-rkostl = ls_faglskf-prctr.
                      lv_msl = lv_msl + ls_data_tmp_v2-nouni.
                      APPEND ls_data_tmp_v2 TO lt_data_tmp_v1.
                    ENDIF.
                  ENDLOOP.
*                ENDLOOP.
* Populate Receiver Percentage
                  LOOP AT lt_data_tmp_v1 ASSIGNING FIELD-SYMBOL(<fs_data_tmp_v1>).
                    <fs_data_tmp_v1>-recprt = ( <fs_data_tmp_v1>-nouni * 100 ) / lv_msl.
                  ENDLOOP.
* Process fully data populated to post
                  LOOP AT lt_data_tmp_v1 ASSIGNING FIELD-SYMBOL(<fs_data_tmp_v3>).
                    PERFORM check_redirect USING <fs_data_tmp_v3> CHANGING <fs_data_tmp_v3>.
                    IF gv_amt EQ 0.
                      PERFORM populate_error_messages USING <fs_data_tmp_v3> TEXT-095.
                    ELSE.
                      PERFORM prepare_direct_data USING gv_amt <fs_data_tmp_v3>.
                      PERFORM bapi_post USING <fs_data_tmp_v3>.
                    ENDIF.
                  ENDLOOP.
                  FREE:lt_data_tmp_v1.
                ENDLOOP.
              ENDLOOP.
              CLEAR:lv_msl,gv_amt.
            ENDLOOP.
          ELSE.
            LOOP AT lt_data_tmp INTO gs_data.
              gv_err_msg = TEXT-074.
              PERFORM populate_error_messages USING gs_data gv_err_msg.
            ENDLOOP.
          ENDIF.
        ELSE.
          LOOP AT lt_data_tmp INTO gs_data.
            gv_err_msg = TEXT-075.
            PERFORM populate_error_messages USING gs_data gv_err_msg.
          ENDLOOP.
        ENDIF.
      ELSE.
        LOOP AT lt_data_tmp INTO gs_data.
          gv_err_msg = TEXT-076.
          PERFORM populate_error_messages USING gs_data gv_err_msg.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  DELETE gt_data WHERE factor EQ TEXT-008.
  FREE: lt_data_tmp, lt_data_tmp_v1,lt_data_tmp_v2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form prepare_direct_data
*&---------------------------------------------------------------------*
*& text - Populate BAPI data
*&---------------------------------------------------------------------*
*&      --> GV_AMT
*&---------------------------------------------------------------------*
FORM prepare_direct_data  USING p_gv_amt TYPE acdoca-hsl
                                ls_data TYPE ty_exldata.

  REFRESH: gt_gl,gt_amt.
  CLEAR: gs_header.

* Prepare Header
  gs_header-username = sy-uname.
  SHIFT: ls_data-skstar LEFT DELETING LEADING '0'.
  IF ls_data-skostl NA sy-abcde.
    SHIFT: ls_data-skostl LEFT DELETING LEADING '0'.
  ENDIF.
  gs_header-header_txt = ls_data-factor.
  ls_data-skstar = |{ ls_data-skstar ALPHA = IN }|.
  ls_data-skostl = |{ ls_data-skostl ALPHA = IN }|.
  CLEAR:gs_ccbukrs-bukrs.
  READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_data-skostl.
  IF sy-subrc EQ 0.
    gs_header-comp_code = gs_ccbukrs-bukrs.
    gs_data-sprctr = gs_ccbukrs-prctr.
    READ TABLE gt_pcsg
          INTO DATA(gs_pcsg)
      WITH KEY prctr = gs_data-sprctr.
    IF sy-subrc EQ 0.
      gs_data-ssegmt = gs_pcsg-segment.
    ENDIF.
  ENDIF.
  gs_header-doc_date = p_bldat.
  gs_header-pstng_date = p_budat.
  gs_header-fisc_year = p_budat+0(4).
  gs_header-fis_period = p_budat+4(2).
  gs_header-doc_type = p_bl_ab.
  SHIFT: ls_data-rkstar LEFT DELETING LEADING '0'.
  IF ls_data-rkostl NA sy-abcde.
    SHIFT: ls_data-rkostl LEFT DELETING LEADING '0'.
  ENDIF.
  CONCATENATE ls_data-rkstar ls_data-rkostl INTO gs_header-ref_doc_no SEPARATED BY space.
  ls_data-rkstar = |{ ls_data-rkstar ALPHA = IN }|.
  ls_data-rkostl = |{ ls_data-rkostl ALPHA = IN }|.

* Prepare Item Sender side
  gs_gl-itemno_acc = 1.
  gs_gl-gl_account = ls_data-skstar.
  gs_gl-comp_code = gs_ccbukrs-bukrs.
  gs_gl-costcenter = ls_data-skostl.
  IF ls_data-scena EQ abap_true.
    gs_gl-ref_key_1 = TEXT-079.
  ELSE.
    gs_gl-ref_key_1 = TEXT-080.
  ENDIF.
  gs_gl-alloc_nmbr = ls_data-stagr.
  gs_gl-item_text = ls_data-descr.
  APPEND gs_gl TO gt_gl.
  CLEAR:gs_gl.

* Prepare Item Receiver side
  gs_gl-itemno_acc = 2.
  gs_gl-gl_account = ls_data-rkstar.
  READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = ls_data-rkostl.
  IF sy-subrc EQ 0.
    gs_gl-comp_code = gs_ccbukrs-bukrs.
    gs_data-rprctr = gs_ccbukrs-prctr.
    READ TABLE gt_pcsg
          INTO gs_pcsg
      WITH KEY prctr = gs_data-rprctr.
    IF sy-subrc EQ 0.
      gs_data-rsegmt = gs_pcsg-segment.
    ENDIF.
  ENDIF.
  gs_gl-costcenter = ls_data-rkostl.
  IF ls_data-scena EQ abap_true.
    gs_gl-ref_key_1 = TEXT-072.
  ELSE.
    gs_gl-ref_key_1 = TEXT-073.
  ENDIF.
  gs_gl-trade_id = gs_header-comp_code.
  gs_gl-alloc_nmbr = ls_data-stagr.
  gs_gl-item_text = ls_data-descr.
  APPEND gs_gl TO gt_gl.
  CLEAR:gs_gl.

* Prepare Sender side Amount
  gs_amt-itemno_acc = 1.
  gs_amt-currency = 'USD'.
  gs_amt-amt_doccur = -1 * ( ( ls_data-recprt / 100 ) * p_gv_amt ) .
  APPEND gs_amt TO gt_amt.
  CLEAR: gs_amt.

* Prepare Receiver side Amount
  gs_amt-amt_doccur = ( ( ls_data-recprt / 100 ) * p_gv_amt ).
  gs_amt-itemno_acc = 2.
  gs_amt-currency = 'USD'.
  APPEND gs_amt TO gt_amt.
  CLEAR: gs_amt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form bapi_post
*&---------------------------------------------------------------------*
*& text - Post documents
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM bapi_post USING ls_data TYPE ty_exldata.

  DATA: lv_OBJ_TYPE TYPE  bapiache09-obj_type,
        lv_OBJ_KEY  TYPE  bapiache09-obj_key,
        lv_OBJ_SYS  TYPE  bapiache09-obj_sys.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader = gs_header
    IMPORTING
      obj_type       = lv_OBJ_type
      obj_key        = lv_OBJ_key
      obj_sys        = lv_OBJ_sys
    TABLES
      accountgl      = gt_gl
      currencyamount = gt_amt
      return         = gt_return.
  READ TABLE gt_return INTO gs_return WITH KEY type = c_e.
  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    SORT gt_return BY type id number.
    DELETE ADJACENT DUPLICATES FROM gt_return COMPARING type id number.
    LOOP AT gt_return INTO gs_return WHERE type = c_e.
      IF gs_return-id EQ 'RW'
        AND gs_return-number EQ '609'.
        CONTINUE.
      ENDIF.
      gs_output-descr = ls_data-descr.
      gs_output-sgl = ls_data-skstar.
      gs_output-scc = ls_data-skostl.
      gs_output-sndprt = ls_data-sndprt.
      gs_output-sprctr = ls_data-sprctr.
      gs_output-ssegmt = ls_data-ssegmt.
      gs_output-samnt  = gv_amt.
      gs_output-rgl = ls_data-rkstar.
      gs_output-rccgrp = ls_data-rccgrp.
      gs_output-rcc = ls_data-rkostl.
      gs_output-rpcgrp = ls_data-rpcgrp.
      gs_output-rprctr = ls_data-rprctr.
      gs_output-rsegmt = ls_data-rsegmt.
      gs_output-recprt = ls_data-recprt.
      gs_output-nouni = ls_data-nouni.
      gs_output-ramnt = ( ( ls_data-recprt / 100 ) * gv_amt ).
      gs_output-redirect = ls_data-scena.
      gs_output-stagr = ls_data-stagr.
      gs_output-factor = ls_data-factor.
      gs_output-gjahr = p_gjahr.
      gs_output-monat = p_budat+4(2).
      gs_output-blart = p_bl_ab.
      gs_ccbukrs = gt_ccbukrs[ kostl = ls_data-skostl ].
      gs_output-rbukrs = gs_ccbukrs-bukrs.
      gs_output-error = gs_return-message.
      gs_output-usnam = sy-uname.
      gs_output-cpudt = sy-datum.
      gs_output-cputm = sy-uzeit.
      APPEND gs_output TO gt_output.
      CLEAR: gs_output.
    ENDLOOP.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    gs_output-descr = ls_data-descr.
    gs_output-sgl = ls_data-skstar.
    gs_output-scc = ls_data-skostl.
    gs_output-sndprt = ls_data-sndprt.
    gs_output-sprctr = ls_data-sprctr.
    gs_output-ssegmt = ls_data-ssegmt.
    gs_output-samnt  = gv_amt.
    gs_output-rgl = ls_data-rkstar.
    gs_output-rccgrp = ls_data-rccgrp.
    gs_output-rcc = ls_data-rkostl.
    gs_output-rpcgrp = ls_data-rpcgrp.
    gs_output-rprctr = ls_data-rprctr.
    gs_output-rsegmt = ls_data-rsegmt.
    gs_output-recprt = ls_data-recprt.
    gs_output-nouni = ls_data-nouni.
    gs_output-ramnt = ( ( ls_data-recprt / 100 ) * gv_amt ).
    gs_output-redirect = ls_data-scena.
    gs_output-stagr = ls_data-stagr.
    gs_output-factor = ls_data-factor.
    gs_output-gjahr = p_budat+0(4).
    gs_output-monat = p_budat+4(2).
    gs_output-blart = p_bl_ab.
    gs_output-rbukrs = lv_OBJ_key+10(4).
    gs_output-belnr = lv_OBJ_key+0(10).
    gs_output-usnam = sy-uname.
    gs_output-cpudt = sy-datum.
    gs_output-cputm = sy-uzeit.
    gs_bvorg-bvorg = |{ gs_output-belnr ALPHA = IN }{ gs_output-rbukrs }{ gs_output-gjahr+2(2) }|.
    APPEND: gs_output TO gt_output,
            gs_bvorg TO gt_bvorg.
    CLEAR: gs_output,gs_bvorg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_output
*&---------------------------------------------------------------------*
*& text - Display Output after posting
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_output .

  DATA: lo_column TYPE REF TO cl_salv_column_table,
        functions TYPE REF TO cl_salv_functions_list,
        lv_errtxt TYPE string,
        lv_msg    TYPE REF TO cx_salv_msg.
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
        lo_column ?= lo_columns->get_column( TEXT-011 ).
        lo_column->set_short_text( TEXT-012 ).
        lo_column->set_medium_text( TEXT-012 ).
        lo_column->set_long_text( TEXT-012 ).

        lo_column ?= lo_columns->get_column( TEXT-013 ).
        lo_column->set_short_text( TEXT-014 ).
        lo_column->set_medium_text( TEXT-015 ).
        lo_column->set_long_text( TEXT-015 ).

        lo_column ?= lo_columns->get_column( TEXT-016 ).
        lo_column->set_short_text( TEXT-017 ).
        lo_column->set_medium_text( TEXT-018 ).
        lo_column->set_long_text( TEXT-019 ).

        lo_column ?= lo_columns->get_column( TEXT-020 ).
        lo_column->set_short_text( TEXT-021 ).
        lo_column->set_medium_text( TEXT-022 ).
        lo_column->set_long_text( TEXT-023 ).

        lo_column ?= lo_columns->get_column( TEXT-024 ).
        lo_column->set_short_text( TEXT-025 ).
        lo_column->set_medium_text( TEXT-026 ).
        lo_column->set_long_text( TEXT-026 ).

        lo_column ?= lo_columns->get_column( TEXT-027 ).
        lo_column->set_short_text( TEXT-028 ).
        lo_column->set_medium_text( TEXT-028 ).
        lo_column->set_long_text( TEXT-028 ).

        lo_column ?= lo_columns->get_column( TEXT-029 ).
        lo_column->set_short_text( TEXT-030 ).
        lo_column->set_medium_text( TEXT-031 ).
        lo_column->set_long_text( TEXT-031 ).

        lo_column ?= lo_columns->get_column( TEXT-032 ).
        lo_column->set_short_text( TEXT-033 ).
        lo_column->set_medium_text( TEXT-034 ).
        lo_column->set_long_text( TEXT-034 ).

        lo_column ?= lo_columns->get_column( TEXT-035 ).
        lo_column->set_short_text( TEXT-036 ).
        lo_column->set_medium_text( TEXT-037 ).
        lo_column->set_long_text( TEXT-038 ).

        lo_column ?= lo_columns->get_column( TEXT-039 ).
        lo_column->set_short_text( TEXT-040 ).
        lo_column->set_medium_text( TEXT-041 ).
        lo_column->set_long_text( TEXT-041 ).

        lo_column ?= lo_columns->get_column( TEXT-042 ).
        lo_column->set_short_text( TEXT-043 ).
        lo_column->set_medium_text( TEXT-044 ).
        lo_column->set_long_text( TEXT-044 ).

        lo_column ?= lo_columns->get_column( TEXT-045 ).
        lo_column->set_short_text( TEXT-046 ).
        lo_column->set_medium_text( TEXT-046 ).
        lo_column->set_long_text( TEXT-046 ).

        lo_column ?= lo_columns->get_column( TEXT-047 ).
        lo_column->set_short_text( TEXT-048 ).
        lo_column->set_medium_text( TEXT-049 ).
        lo_column->set_long_text( TEXT-049 ).

        lo_column ?= lo_columns->get_column( TEXT-050 ).
        lo_column->set_short_text( TEXT-051 ).
        lo_column->set_medium_text( TEXT-052 ).
        lo_column->set_long_text( TEXT-052 ).

        lo_column ?= lo_columns->get_column( TEXT-053 ).
        lo_column->set_short_text( TEXT-054 ).
        lo_column->set_medium_text( TEXT-054 ).
        lo_column->set_long_text( TEXT-054 ).

        lo_column ?= lo_columns->get_column( TEXT-055 ).
        lo_column->set_short_text( TEXT-056 ).
        lo_column->set_medium_text( TEXT-056 ).
        lo_column->set_long_text( TEXT-056 ).

        lo_column ?= lo_columns->get_column( TEXT-057 ).
        lo_column->set_short_text( TEXT-058 ).
        lo_column->set_medium_text( TEXT-059 ).
        lo_column->set_long_text( TEXT-060 ).

        lo_column ?= lo_columns->get_column( TEXT-083 ).
        lo_column->set_short_text( TEXT-084 ).
        lo_column->set_medium_text( TEXT-085 ).
        lo_column->set_long_text( TEXT-086 ).

        lo_column ?= lo_columns->get_column( TEXT-092 ).
        lo_column->set_short_text( TEXT-093 ).
        lo_column->set_medium_text( TEXT-094 ).
        lo_column->set_long_text( TEXT-094 ).

        lo_columns->set_optimize( abap_true ).
        gl_alv->display( ).

      ENDIF.
    CATCH cx_salv_not_found INTO gt_salv_not_found.
      lv_errtxt = gt_salv_not_found->get_text( ).
      MESSAGE lv_errtxt TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form populate_cross_company_docs
*&---------------------------------------------------------------------*
*& text - Get all Cross Company posted documents
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM populate_cross_company_docs .

  IF gt_bvorg IS NOT INITIAL.
    WAIT UP TO 5 SECONDS.
    SELECT bukrs,                                       "#EC CI_NOFIELD
           belnr,
           gjahr,
           bvorg
      FROM bkpf
      INTO TABLE @DATA(lt_bkpf)
       FOR ALL ENTRIES IN @gt_bvorg
     WHERE bvorg EQ @gt_bvorg-bvorg.
    IF sy-subrc EQ 0.
      LOOP AT lt_bkpf INTO DATA(ls_bkpf).
        READ TABLE gt_output ASSIGNING FIELD-SYMBOL(<gs_output>) WITH KEY rbukrs = ls_bkpf-bukrs
                                                     belnr = ls_bkpf-belnr
                                                     gjahr = ls_bkpf-gjahr.
        IF sy-subrc EQ 0.
          <gs_output>-bvorg = ls_bkpf-bvorg.
        ENDIF.
      ENDLOOP.
      LOOP AT gt_output INTO gs_output WHERE bvorg NE abap_false.
        LOOP AT lt_bkpf INTO ls_bkpf WHERE bukrs NE gs_output-rbukrs
                                       AND bvorg EQ gs_output-bvorg.
          gs_output-rbukrs = ls_bkpf-bukrs.
          gs_output-belnr = ls_bkpf-belnr.
          gs_output-gjahr = ls_bkpf-gjahr.
          APPEND gs_output TO gt_output_tmp.
          CLEAR:gs_output.
        ENDLOOP.
      ENDLOOP.
      IF gt_output_tmp IS NOT INITIAL.
        APPEND LINES OF gt_output_tmp TO gt_output.
        SORT gt_output BY sgl scc bvorg.
      ENDIF.
      FREE:lt_bkpf,gt_output_tmp.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form populate_error_messages
*&---------------------------------------------------------------------*
*& text - Populate Output Messages
*&---------------------------------------------------------------------*
*&      --> GS_DATA
*&      --> P_
*&---------------------------------------------------------------------*
FORM populate_error_messages  USING p_gs_data TYPE ty_exldata
                                    p_err TYPE char100.

  gs_output-descr = p_gs_data-descr.
  gs_output-sgl = p_gs_data-skstar.
  gs_output-scc = p_gs_data-skostl.
  gs_output-sndprt = p_gs_data-sndprt.
  gs_output-sprctr = p_gs_data-sprctr.
  gs_output-ssegmt = p_gs_data-ssegmt.
  gs_output-samnt  = gv_amt.
  gs_output-rgl = p_gs_data-rkstar.
  gs_output-rccgrp = p_gs_data-rccgrp.
  gs_output-rcc = p_gs_data-rkostl.
  gs_output-rprctr = p_gs_data-rprctr.
  gs_output-rsegmt = p_gs_data-rsegmt.
  gs_output-recprt = p_gs_data-recprt.
  gs_output-nouni = p_gs_data-nouni.
  gs_output-redirect = p_gs_data-scena.
  gs_output-stagr = p_gs_data-stagr.
  gs_output-factor = p_gs_data-factor.
  gs_output-gjahr = p_gjahr.
  gs_output-blart = p_bl_ab.
  gs_output-monat = p_monat.
  gs_output-error = p_err.
  gs_output-usnam = sy-uname.
  gs_output-cpudt = sy-datum.
  gs_output-cputm = sy-uzeit.
  APPEND gs_output TO gt_output.
  CLEAR: gs_output.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sumup_total
*&---------------------------------------------------------------------*
*& text - Sumup total for each Sender Cost center and GL
*&---------------------------------------------------------------------*
*&      --> LS_DATA_TMP
*&      <-- LV_TOT
*&---------------------------------------------------------------------*
FORM sumup_total  USING    p_ls_data_tmp TYPE ty_exldata
                  CHANGING p_lv_tot TYPE acdoca-hsl.

  DATA: lv_totprt TYPE acdoca-hsl.

  CLEAR:lv_totprt.
  LOOP AT gt_data_doc INTO gs_data_doc WHERE rcntr = p_ls_data_tmp-skostl
                                       AND racct = p_ls_data_tmp-skstar.
    p_lv_tot = p_lv_tot + gs_data_doc-hsl.
    CLEAR:gs_data_doc.
  ENDLOOP.
  IF p_ls_data_tmp-sndprt NE abap_false.
    lv_totprt = ( p_lv_tot * p_ls_data_tmp-sndprt ) / 100.
    p_lv_tot = lv_totprt.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form rec_cost_center_date_validity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA
*&      <-- GV_ERR_MSG
*&---------------------------------------------------------------------*
FORM rec_cost_center_date_validity  USING    p_gs_data TYPE ty_exldata
                                CHANGING p_gv_err_msg TYPE char100.

  CLEAR:p_gv_err_msg.
  READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = p_gs_data-rkostl.
  IF sy-subrc EQ 0.
    IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
    ELSE.
      CONCATENATE TEXT-087
                  p_gs_data-rkostl
             INTO p_gv_err_msg
        SEPARATED BY space.
*      PERFORM populate_error_messages USING p_gs_data p_gv_err_msg.
    ENDIF.
  ELSE.
    CONCATENATE TEXT-087
                p_gs_data-rkostl
           INTO p_gv_err_msg
      SEPARATED BY space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form sen_cost_center_date_validity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA
*&      <-- GV_ERR_MSG
*&---------------------------------------------------------------------*
FORM sen_cost_center_date_validity  USING    p_gs_data TYPE ty_exldata
                                    CHANGING p_gv_err_msg TYPE char100.
  CLEAR:p_gv_err_msg.
  READ TABLE gt_ccbukrs INTO gs_ccbukrs WITH KEY kostl = p_gs_data-skostl.
  IF sy-subrc EQ 0.
    IF p_budat BETWEEN gs_ccbukrs-datab AND gs_ccbukrs-datbi.
    ELSE.
      CONCATENATE TEXT-089
                  p_gs_data-skostl
             INTO p_gv_err_msg
        SEPARATED BY space.
*      PERFORM populate_error_messages USING p_gs_data p_gv_err_msg.
    ENDIF.
  ELSE.
    CONCATENATE TEXT-089
                p_gs_data-skostl
           INTO p_gv_err_msg
      SEPARATED BY space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form filepath_validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM filepath_validation .

  IF p_fg EQ abap_true.
    IF p_fpath EQ abap_false.
      MESSAGE 'Please enter foreground filepath' TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
      CLEAR: p_bpath.
    ENDIF.
  ENDIF.

  IF p_bg EQ abap_true.
    IF p_bpath EQ abap_false.
      MESSAGE 'Please enter background filepath' TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
      CLEAR: p_fpath.
    ENDIF.
    IF p_email EQ abap_false.
      MESSAGE 'Please enter email address to send output log' TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
      CLEAR: p_fpath.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form file_open_dir
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_open_dir .
  DATA:lv_directory(30) TYPE c.
  lv_directory = '/'.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = lv_directory
*     filemask         = '?'
    IMPORTING
      serverfile       = p_bpath
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Filepath not selected' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
*    CATCH dynpro_msg_in_help INTO DATA(ls_text).
*  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_email
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM send_email .

  DATA: lv_mgs_binary_content TYPE solix_tab,
        lv_mgs_size           TYPE so_obj_len,
        lv_ers_binary_content TYPE solix_tab,
        lv_ers_size           TYPE so_obj_len,
        lv_cntfrm             TYPE i,
        lv_cntto              TYPE i.

  DESCRIBE TABLE gt_output LINES DATA(lv_lines).

  SELECT SINGLE *
    FROM tvarvc
    INTO @DATA(ls_cnt)
   WHERE name EQ 'ZFI_COST_ALLOCATION_TVAR'
     AND type EQ 'S'
     AND sign EQ 'I'
     AND opti EQ 'BT'.

  IF lv_lines LE ls_cnt-high.
    lv_cntfrm = 1.
    lv_cntto = lv_lines.
    PERFORM create_content USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size lv_cntfrm lv_cntto.
    PERFORM send USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size.
  ELSE.
    lv_cntfrm = 1.
    lv_cntto = ls_cnt-high.
    DO.
      IF sy-index EQ 1.
        PERFORM create_content USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size lv_cntfrm lv_cntto.
        PERFORM send USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size.
      ELSE.
        lv_cntfrm = lv_cntfrm + ls_cnt-high.
        lv_cntto  = lv_cntto + ls_cnt-high.
        IF lv_cntto GE lv_lines.
          lv_cntto = lv_lines.
          PERFORM create_content USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size lv_cntfrm lv_cntto.
          PERFORM send USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size.
          EXIT.
        ELSE.
          PERFORM create_content USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size lv_cntfrm lv_cntto.
          PERFORM send USING lv_mgs_binary_content lv_mgs_size lv_ers_binary_content lv_ers_size.
        ENDIF.
      ENDIF.
    ENDDO.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTENT
*&---------------------------------------------------------------------*
*       Creating Contents
*----------------------------------------------------------------------*
FORM create_content  USING lv_mgs_binary_content TYPE solix_tab
                           lv_mgs_size           TYPE so_obj_len
                           lv_ers_binary_content TYPE solix_tab
                           lv_ers_size           TYPE so_obj_len
                           lv_cntfrm TYPE i
                           lv_cntto TYPE i.
  CONSTANTS:
    gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
    gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.
  DATA: lv_string TYPE string,
        lv_pcnt   TYPE char10,
        lv_samnt  TYPE char16,
        lv_ramnt  TYPE char16,
        lv_recprt TYPE char10.

  CONCATENATE 'Description'         gc_tab
              'Sender GL'           gc_tab
              'Sender CCenter'      gc_tab
              'Sender Percentage'   gc_tab
              'Sender Pft Center'   gc_tab
              'Sender Segment'      gc_tab
              'Sender Amt'          gc_tab
              'Receiver GL'         gc_tab
              'Receiver CCntGrp'    gc_tab
              'Receiver CC'         gc_tab
              'Receiver PCntGrp'    gc_tab
              'Receiver Pft Center' gc_tab
              'Receiver Segment'    gc_tab
              'Receiver Percentage' gc_tab
              'No.Units'            gc_tab
              'Receiver Amt'        gc_tab
              'Redirect Scenario'   gc_tab
              'SKF'                 gc_tab
              'Allocation Factor'   gc_tab
              'Fiscal year'         gc_tab
              'Posting Period'      gc_tab
              'Doc Type'            gc_tab
              'Comp Code'           gc_tab
              'Document No'         gc_tab
              'Cross Comp Code'     gc_tab
              'Error Message'       gc_tab
              'User name'           gc_tab
              'Entry Date'          gc_tab
              'Entry Time'          gc_crlf
         INTO lv_string.

  LOOP AT gt_output INTO DATA(ls_output) FROM lv_cntfrm.
    lv_pcnt = ls_output-sndprt.
    lv_samnt = ls_output-samnt.
    lv_recprt = ls_output-recprt.
    lv_ramnt = ls_output-ramnt.
    CONDENSE:lv_pcnt,lv_samnt,lv_recprt,lv_ramnt.
    CONCATENATE lv_string
         ls_output-descr gc_tab
         ls_output-sgl gc_tab
         ls_output-scc gc_tab
         lv_pcnt gc_tab
         ls_output-sprctr gc_tab
         ls_output-ssegmt gc_tab
         lv_samnt gc_tab
         ls_output-rgl gc_tab
         ls_output-rccgrp gc_tab
         ls_output-rcc gc_tab
         ls_output-rpcgrp gc_tab
         ls_output-rprctr gc_tab
         ls_output-rsegmt gc_tab
         lv_recprt gc_tab
         ls_output-nouni gc_tab
         lv_ramnt gc_tab
         ls_output-redirect gc_tab
         ls_output-stagr gc_tab
         ls_output-factor  gc_tab
         ls_output-gjahr gc_tab
         ls_output-monat gc_tab
         ls_output-blart gc_tab
         ls_output-rbukrs gc_tab
         ls_output-belnr  gc_tab
         ls_output-bvorg gc_tab
         ls_output-error gc_tab
         ls_output-usnam gc_tab
         ls_output-cpudt gc_tab
         ls_output-cputm gc_crlf
     INTO lv_string.
    CLEAR:ls_output,lv_pcnt,lv_samnt,lv_recprt,lv_ramnt.
    IF sy-tabix EQ lv_cntto.
      EXIT.
    ENDIF.
  ENDLOOP.

* convert the text string into UTF-16LE binary data including
* byte-order-mark. Mircosoft Excel prefers these settings
* all this is done by new class cl_bcs_convert (see note 1151257)
  TRY.
      cl_bcs_convert=>string_to_solix(
        EXPORTING
          iv_string   = lv_string
          iv_codepage = '4103'  "suitable for MS
          iv_add_bom  = 'X'     "for other doc ty
        IMPORTING
          et_solix  = lv_mgs_binary_content
          ev_size   = lv_mgs_size ).
    CATCH cx_bcs.
      MESSAGE e445(so).
  ENDTRY.

ENDFORM.                    " CREATE_CONTENT
*&---------------------------------------------------------------------*
*&      Form  SEND
*&---------------------------------------------------------------------*
*       Email Sending fucntionality
*----------------------------------------------------------------------*
FORM send  USING lv_mgs_binary_content TYPE solix_tab
                 lv_mgs_size           TYPE so_obj_len
                 lv_ers_binary_content TYPE solix_tab
                 lv_ers_size           TYPE so_obj_len.

  DATA:
    send_request  TYPE REF TO cl_bcs,
    document      TYPE REF TO cl_document_bcs,
    recipient     TYPE REF TO if_recipient_bcs,
    bcs_exception TYPE REF TO cx_bcs,
    main_text     TYPE bcsy_text,
    sent_to_all   TYPE os_boolean,
    lv_head       TYPE char100,
    lv_space      TYPE char50,
    lv_file       TYPE sood-objdes,
    lv_subj       TYPE char50,
    lv_file_date  TYPE char10,
    lv_email      TYPE adr6-smtp_addr.

  TRY.
      send_request = cl_bcs=>create_persistent( ).
* Subject line
      WRITE sy-datum TO lv_file_date.
      CONCATENATE p_kostl '_Cost Allocations: ' lv_file_date INTO lv_subj
        SEPARATED BY space.

* Start Email Body
      lv_head = 'Please do not reply to this email.'.
      APPEND lv_head TO main_text.
      CLEAR:lv_head.
      lv_head = 'This is an auto generated email and replies to this email id are not attended.'.
      APPEND lv_head TO main_text.
      CLEAR:lv_head.
*Add empty line in email body
      CONCATENATE space space
                  INTO lv_space.
      APPEND lv_space TO main_text.
*Add empty line in email body
      CONCATENATE space space
                  INTO lv_space.
      APPEND lv_space TO main_text.
      lv_head = 'Thank You.'.
      APPEND lv_head TO main_text.
* End Email Body

* Create Document
      document = cl_document_bcs=>create_document(
        i_type    = 'RAW'
        i_text    = main_text
        i_subject = lv_subj
         ).

* Adding O/P spread sheet as attachment to document object
      IF lv_mgs_binary_content IS NOT INITIAL.
        CONCATENATE p_kostl '_Allocation Output' '_' sy-datum '_' sy-uzeit INTO lv_file.
        document->add_attachment(
          i_attachment_type    = 'xls'
          i_attachment_subject = lv_file
          i_attachment_size    = lv_mgs_size
          i_att_content_hex    = lv_mgs_binary_content ).
      ENDIF.

      send_request->set_document( document ).
* Recipients
      LOOP AT p_email INTO DATA(ls_emails).
        lv_email = ls_emails-low.
        recipient = cl_cam_address_bcs=>create_internet_address( lv_email ).
        send_request->add_recipient( recipient ).
        CLEAR: lv_email,ls_emails.
      ENDLOOP.
* Trigger email
      sent_to_all = send_request->send( i_with_error_screen = 'X' ).
      COMMIT WORK.
    CATCH cx_bcs INTO bcs_exception.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_redirect
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_DATA
*&      <-- GS_DATA
*&---------------------------------------------------------------------*
FORM check_redirect  USING    i_gs_data TYPE ty_exldata
                     CHANGING e_gs_data TYPE ty_exldata.

  DATA: lv_kostl TYPE csks-kostl.
  lv_kostl = |{ i_gs_data-rkostl ALPHA = OUT }|.
  READ TABLE gt_redirect
        INTO gs_redirect
    WITH KEY scena = i_gs_data-scena
            skostl = lv_kostl.
  IF sy-subrc EQ 0.
    e_gs_data-rkostl = |{ gs_redirect-rkostl ALPHA = IN }|.
    IF i_gs_data-rrksta NE abap_false.
      e_gs_data-rkstar = |{ i_gs_data-rrksta ALPHA = IN }|.
    ENDIF.
  ENDIF.
  CLEAR:lv_kostl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form populate_ix_kostls
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_DATA_TMP
*&---------------------------------------------------------------------*
FORM populate_ix_kostls USING p_ls_data_tmp TYPE ty_exldata.

  DATA: lv_tmp1 TYPE kostl,
        lv_tmp2 TYPE kostl.

  REFRESH:gr_rcntr,gt_kostl_i,gt_kostl_x.
  IF p_ls_data_tmp-rcci NE abap_false.
    SPLIT p_ls_data_tmp-rcci AT '|' INTO TABLE DATA(lt_values).
    LOOP AT lt_values INTO DATA(ls_values).
      IF ls_values CS '-'.
        CLEAR: lv_tmp1, lv_tmp2.
        SPLIT ls_values AT '-' INTO lv_tmp1 lv_tmp2.
        grs_rcntr-sign = 'I'.
        grs_rcntr-option = 'BT'.
        grs_rcntr-low = lv_tmp1.
        grs_rcntr-high = lv_tmp2.
        grs_rcntr-low = |{ grs_rcntr-low ALPHA = IN }|.
        grs_rcntr-high = |{ grs_rcntr-high ALPHA = IN }|.
        APPEND grs_rcntr TO gr_rcntr.
        CLEAR: grs_rcntr.
      ELSE.
        grs_rcntr-sign = 'I'.
        grs_rcntr-option = 'EQ'.
        grs_rcntr-low = ls_values.
        grs_rcntr-low = |{ grs_rcntr-low ALPHA = IN }|.
        APPEND grs_rcntr TO gr_rcntr.
        CLEAR: grs_rcntr.
      ENDIF.
      CLEAR:ls_values.
    ENDLOOP.
  ENDIF.

  IF gr_rcntr IS NOT INITIAL.
    SELECT kostl
      FROM csks
      INTO TABLE gt_kostl_i
     WHERE kostl IN gr_rcntr.
    IF sy-subrc EQ 0.
      SORT gt_kostl_i BY kostl.
    ENDIF.
  ENDIF.

  REFRESH:lt_values,gr_rcntr.
  IF p_ls_data_tmp-rccx NE abap_false.
    SPLIT p_ls_data_tmp-rccx AT '|' INTO TABLE lt_values.
    LOOP AT lt_values INTO ls_values.
      IF ls_values CS '-'.
        CLEAR: lv_tmp1, lv_tmp2.
        SPLIT ls_values AT '-' INTO lv_tmp1 lv_tmp2.
        grs_rcntr-sign = 'I'.
        grs_rcntr-option = 'BT'.
        grs_rcntr-low = lv_tmp1.
        grs_rcntr-high = lv_tmp2.
        grs_rcntr-low = |{ grs_rcntr-low ALPHA = IN }|.
        grs_rcntr-high = |{ grs_rcntr-high ALPHA = IN }|.
        APPEND grs_rcntr TO gr_rcntr.
        CLEAR: grs_rcntr.
      ELSE.
        grs_rcntr-sign = 'I'.
        grs_rcntr-option = 'EQ'.
        grs_rcntr-low = ls_values.
        grs_rcntr-low = |{ grs_rcntr-low ALPHA = IN }|.
        APPEND grs_rcntr TO gr_rcntr.
        CLEAR: grs_rcntr.
      ENDIF.
      CLEAR:ls_values.
    ENDLOOP.
  ENDIF.

  IF gr_rcntr IS NOT INITIAL.
    SELECT kostl
      FROM csks
      INTO TABLE gt_kostl_x
     WHERE kostl IN gr_rcntr.
    IF sy-subrc EQ 0.
      SORT gt_kostl_x BY kostl.
    ENDIF.
  ENDIF.

  REFRESH:lt_values,gr_rcntr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form include_exclude_cceenters
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM include_exclude_cceenters .

  LOOP AT gt_kostl_i INTO gs_kostl.
    gs_row-parentnode = gv_nname.
    gs_row-value = gs_kostl-kostl.
    APPEND gs_row TO gt_row.
    CLEAR:gs_row.
  ENDLOOP.

  LOOP AT gt_kostl_x INTO gs_kostl.
    DELETE gt_row WHERE value EQ gs_kostl-kostl.
    CLEAR: gs_kostl.
  ENDLOOP.
  SORT gt_row BY value.
  DELETE ADJACENT DUPLICATES FROM gt_row COMPARING value.

ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZFI_CREATE_REPETITIVE_CODE_F01
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
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE 'Please check the filepath entered' TYPE 'E' DISPLAY LIKE 'S'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_file_for_data
*&---------------------------------------------------------------------*
*& text
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

  LOOP AT <gt_data> ASSIGNING <ls_data> FROM 3.
    DO 10 TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE <ls_data> TO <lv_field> .
      IF sy-subrc = 0.
        CASE sy-index.
          WHEN 1.
            gs_excel-rpcode = <lv_field>.
          WHEN 2.
            gs_excel-bukrs = <lv_field>.
          WHEN 3.
            gs_excel-hbkid = <lv_field>.
          WHEN 4.
            gs_excel-hktid = <lv_field>.
          WHEN 5.
            gs_excel-tbukr = <lv_field>.
          WHEN 6.
            gs_excel-thbki = <lv_field>.
          WHEN 7.
            gs_excel-tHKTI = <lv_field>.
          WHEN 8.
            gs_excel-zlsch = <lv_field>.
          WHEN 9.
            gs_excel-waers = <lv_field>.
          WHEN 10.
            gs_excel-rp_text = <lv_field>.
        ENDCASE .
      ENDIF.
    ENDDO .
    APPEND gs_excel TO gt_excel.
    CLEAR: gs_excel.
  ENDLOOP .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data_to_bdc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data_to_bdc .

  DATA:lv_mode   TYPE c VALUE 'N',
       lv_update TYPE c VALUE 'A'.

  LOOP AT gt_excel INTO gs_excel.

    PERFORM bdc_dynpro      USING 'FIBL_RPCODE_MAINTAIN' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'FIBL_RPCODE-HKTID'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ADD'.
    PERFORM bdc_field       USING 'FIBL_RPCODE-BUKRS'
                                  gs_excel-bukrs.
    PERFORM bdc_field       USING 'FIBL_RPCODE-HBKID'
                                  gs_excel-hbkid.
    PERFORM bdc_field       USING 'FIBL_RPCODE-HKTID'
                                  gs_excel-hktid.
    PERFORM bdc_dynpro      USING 'SAPLSPO5' '0100'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=OK'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'SPOPLI-SELFLAG(02)'.
    PERFORM bdc_field       USING 'SPOPLI-SELFLAG(01)'
                                  ''.
    PERFORM bdc_field       USING 'SPOPLI-SELFLAG(02)'
                                  'X'.
    PERFORM bdc_dynpro      USING 'FIBL_RPCODE_MAINTAIN' '0200'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'FIBL_RPCODE-WAERS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=SAVE'.
    PERFORM bdc_field       USING 'FIBL_RPCODE-RPCODE'
                                  gs_excel-rpcode.
    PERFORM bdc_field       USING 'FIBL_RPCODE-ZLSCH'
                                  gs_excel-zlsch.
    PERFORM bdc_field       USING 'FIBL_RPCODE-WAERS'
                                  gs_excel-waers.
    PERFORM bdc_field       USING 'FIBL_RPCODE-ZLSCH'
                                  gs_excel-zlsch.
    PERFORM bdc_field       USING 'FIBL_RPCODE_TDEF-RP_TEXT'
                                  gs_excel-rp_text.
    PERFORM bdc_field       USING 'STRUC_DY_BANK-PBUKR'
                                  gs_excel-tbukr.
    PERFORM bdc_field       USING 'STRUC_DY_BANK-HBKID'
                                  gs_excel-thbki.
    PERFORM bdc_field       USING 'STRUC_DY_BANK-HKTID'
                                  gs_excel-thkti.

    CALL TRANSACTION 'OT81' USING gt_bdcdata
                MODE lv_mode
              UPDATE lv_update
       MESSAGES INTO gt_bdcmsg.
    IF gt_bdcmsg IS NOT INITIAL.
      LOOP AT gt_bdcmsg INTO DATA(gs_bdcmsg).
        MOVE-CORRESPONDING gs_excel TO gs_output.
        gs_output-msgtyp = gs_bdcmsg-msgtyp.
        SELECT SINGLE *
          FROM t100
          INTO @DATA(ls_t100)
         WHERE sprsl EQ @sy-langu
           AND arbgb EQ @gs_bdcmsg-msgid
           AND msgnr EQ @gs_bdcmsg-msgnr.
        IF sy-subrc EQ 0.
          gs_output-msgv1 = ls_t100-text.
          CLEAR:ls_t100.
        ENDIF.
        APPEND gs_output TO gt_output.
        CLEAR:gs_output.
      ENDLOOP.
    ENDIF.
    CLEAR:gs_excel.
    REFRESH:gt_bdcdata,gt_bdcmsg.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM gt_output COMPARING ALL FIELDS.

ENDFORM.
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  gs_bdcdata-fnam = fnam.
  gs_bdcdata-fval = fval.
  APPEND gs_bdcdata TO gt_bdcdata.
  CLEAR gs_bdcdata.
ENDFORM.
*----------------------------------------------------------------------*
*        bdc_dynpro                                                 *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  gs_bdcdata-program  = program.
  gs_bdcdata-dynpro   = dynpro.
  gs_bdcdata-dynbegin = abap_true.
  APPEND gs_bdcdata TO gt_bdcdata.
  CLEAR gs_bdcdata.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_output
*&---------------------------------------------------------------------*
*& text - Display Output
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_rpt.

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
        lo_column ?= lo_columns->get_column( TEXT-002 ).
        lo_column->set_short_text( TEXT-003 ).
        lo_column->set_medium_text( TEXT-004 ).
        lo_column->set_long_text( TEXT-004 ).

        lo_column ?= lo_columns->get_column( TEXT-005 ).
        lo_column->set_short_text( TEXT-006 ).
        lo_column->set_medium_text( TEXT-007 ).
        lo_column->set_long_text( TEXT-007 ).

        lo_column ?= lo_columns->get_column( TEXT-008 ).
        lo_column->set_short_text( TEXT-009 ).
        lo_column->set_medium_text( TEXT-010 ).
        lo_column->set_long_text( TEXT-010 ).

        lo_column ?= lo_columns->get_column( TEXT-011 ).
        lo_column->set_short_text( TEXT-012 ).
        lo_column->set_medium_text( TEXT-013 ).
        lo_column->set_long_text( TEXT-013 ).

        lo_column ?= lo_columns->get_column( TEXT-014 ).
        lo_column->set_short_text( TEXT-015 ).
        lo_column->set_medium_text( TEXT-016 ).
        lo_column->set_long_text( TEXT-016 ).

        lo_column ?= lo_columns->get_column( TEXT-017 ).
        lo_column->set_short_text( TEXT-018 ).
        lo_column->set_medium_text( TEXT-019 ).
        lo_column->set_long_text( TEXT-019 ).

        lo_column ?= lo_columns->get_column( TEXT-020 ).
        lo_column->set_short_text( TEXT-021 ).
        lo_column->set_medium_text( TEXT-022 ).
        lo_column->set_long_text( TEXT-022 ).

        lo_column ?= lo_columns->get_column( TEXT-023 ).
        lo_column->set_short_text( TEXT-024 ).
        lo_column->set_medium_text( TEXT-025 ).
        lo_column->set_long_text( TEXT-025 ).

        lo_column ?= lo_columns->get_column( TEXT-026 ).
        lo_column->set_short_text( TEXT-027 ).
        lo_column->set_medium_text( TEXT-028 ).
        lo_column->set_long_text( TEXT-028 ).

        lo_column ?= lo_columns->get_column( TEXT-029 ).
        lo_column->set_short_text( TEXT-030 ).
        lo_column->set_medium_text( TEXT-030 ).
        lo_column->set_long_text( TEXT-031 ).

        lo_column ?= lo_columns->get_column( TEXT-031 ).
        lo_column->set_short_text( TEXT-032 ).
        lo_column->set_medium_text( TEXT-032 ).
        lo_column->set_long_text( TEXT-033 ).

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
*& Form read_repetitives
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_repetitives .

  DATA: l_bukrs    LIKE it_rpcode-pbukr,
        l_hbkid    LIKE it_rpcode-hbkid,
        l_hktid    LIKE it_rpcode-hktid,
        l_t012     TYPE t012,
        l_t012k    TYPE t012k,
        l_t012t    TYPE t012t,
        l_refzl    LIKE t012k-refzl,
        l_bnka_alt TYPE bnka,
        l_bnka_neu TYPE bnka,
        l_count    TYPE i,
        l_subrc    LIKE sy-subrc,
        ls_return  LIKE bapiret2.                           "#EC NEEDED

  DATA: BEGIN OF ld_tab OCCURS 0,
          tabix         LIKE sy-tabix,
          bukrs         LIKE it_rpcode-bukrs,
          rpcode        LIKE it_rpcode-rpcode,
          hbkid         LIKE it_rpcode-hbkid,
          hktid         LIKE it_rpcode-hktid,
          rpcode_alt    TYPE struc_dy_bank,   "part of frft_bank_rep
          bankn_alt(40) TYPE c,
          bkref_alt     LIKE struc_dy_bank-bkref,
          bkont_alt     LIKE struc_dy_bank-bkont,
          rpcode_neu    TYPE struc_dy_bank,   "part of frft_bank_rep
          bankn_neu(40) TYPE c,
          bkref_neu     LIKE struc_dy_bank-bkref,
          bkont_neu     LIKE struc_dy_bank-bkont,
        END OF ld_tab.

  RANGES lr_ptype FOR fibl_rpcode-ptype.

  PERFORM open_log CHANGING g_log_handle.

  lr_ptype-sign = 'I'.
  lr_ptype-option = 'EQ'.
  lr_ptype-low = '03'.
  APPEND lr_ptype.

*  IF  flg_sel IS INITIAL .
  REFRESH: sel_rpcode, it_rpcode.
  CLEAR: sel_rpcode, it_rpcode.

  gt_rng_grp[] = rng_grp[].
  gt_rng_buk[] = rng_buk[].
  gt_rng_hbk[] = rng_hbk[].

  CALL FUNCTION 'FIBL_RPCODE_MULTI_READ'
    EXPORTING
      id_only_released = true
    TABLES
      it_r_bukrs_sel   = gt_rng_buk
      it_r_hbkid_sel   = gt_rng_hbk
      it_r_partn_sel   = gt_rng_par
      it_r_group_sel   = gt_rng_grp
      et_fibl_rpcode_i = sel_rpcode
      it_r_ptype_sel   = lr_ptype
    EXCEPTIONS
      not_found        = 1
      no_released      = 2
      OTHERS           = 3.
  CASE sy-subrc.
    WHEN 1.
*      MESSAGE w002.
      MESSAGE 'No repetitive codes available for selection' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    WHEN 2.
*      MESSAGE w003.
      MESSAGE 'Error during dictionary request for parameter &1' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    WHEN 3.
  ENDCASE.

  DESCRIBE TABLE sel_rpcode LINES gd_anz_sel_rpcode.
  CHECK gd_anz_sel_rpcode > 0.
* fill itab for table-control, fill range for rpcode.
  gt_rng_rpcode-sign = 'I'.
  gt_rng_rpcode-option = 'EQ'.
  LOOP AT sel_rpcode.
    MOVE-CORRESPONDING sel_rpcode TO it_rpcode.
*    case GD_PTYPE.
*      when TYPE_BANK.
*        call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            INPUT  = IT_RPCODE-PARTN
*          IMPORTING
*            OUTPUT = IT_RPCODE-PARTN.
*    endcase.
    ld_tab-tabix = sy-tabix.
    CASE it_rpcode-ptype.
      WHEN type_bank.

        l_hbkid = it_rpcode-partn.
        l_hktid = it_rpcode-parta.
        l_bukrs = it_rpcode-pbukr.

        CALL FUNCTION 'FI_HOUSEBANK_READ'
          EXPORTING
            ic_bukrs = l_bukrs
            ic_hbkid = l_hbkid
          IMPORTING
            es_t012  = l_t012.

        CALL FUNCTION 'FI_HOUSEBANK_ACCOUNT_READ'
          EXPORTING
            ic_bukrs = l_bukrs
            ic_hbkid = l_hbkid
            ic_hktid = l_hktid
            ic_spras = sy-langu
          IMPORTING
            es_t012k = l_t012k
            es_t012t = l_t012t.

        IF l_t012k-bankn+17(1) NE space.

          PERFORM read_bnka USING l_t012-banks
                                  l_t012-bankl
                                  l_bnka_neu.

          CALL FUNCTION 'CONVERT_HOUSEBANK_ACCOUNT_NUM'
            EXPORTING
              i_land1      = l_t012-banks
              i_bankk      = l_t012-bankl
              i_bankn      = l_t012k-bankn
              i_bkont      = l_t012k-bkont
              i_refzl      = l_t012k-refzl
              i_bankl      = l_bnka_neu-bnklz
            IMPORTING
              e_bankn_long = ld_tab-bankn_neu
              e_refzl      = l_refzl
              e_bkont      = ld_tab-bkont_neu
              e_subrc      = l_subrc.

          ld_tab-bkref_neu = l_refzl.
        ELSE.
          ld_tab-bankn_neu = l_t012k-bankn.
          ld_tab-bkref_neu = l_t012k-refzl.
          ld_tab-bkont_neu = l_t012k-bkont.
        ENDIF.

        IF it_rpcode-bankn+17(1) NE space.

          PERFORM read_bnka USING it_rpcode-banks
                                  it_rpcode-bankl
                                  l_bnka_alt.

          CALL FUNCTION 'CONVERT_BANK_ACCOUNT_NUMBER'
            EXPORTING
              i_banks      = it_rpcode-banks
              i_bankk      = it_rpcode-bankl
              i_bankn      = it_rpcode-bankn
              i_bkont      = it_rpcode-bkont
              i_bkref      = it_rpcode-bkref
              i_bankl      = l_bnka_alt-bnklz
            IMPORTING
              e_bankn_long = ld_tab-bankn_alt
              e_bkref      = ld_tab-bkref_alt
              e_bkont      = ld_tab-bkont_alt
              e_subrc      = l_subrc.

        ELSE.
          ld_tab-bankn_alt = it_rpcode-bankn.
          ld_tab-bkref_alt = it_rpcode-bkref.
          ld_tab-bkont_alt = it_rpcode-bkont.
        ENDIF.

        IF ld_tab-bankn_alt <> ld_tab-bankn_neu
        OR l_t012-bankl     <> it_rpcode-bankl
        OR l_t012-banks     <> it_rpcode-banks
        OR l_t012k-bankn    <> it_rpcode-bankn
        OR l_t012k-bkont    <> it_rpcode-bkont
        OR l_t012k-refzl    <> it_rpcode-bkref.

          MOVE-CORRESPONDING it_rpcode TO ld_tab.

          ld_tab-rpcode_alt-pbukr = it_rpcode-pbukr.
          ld_tab-rpcode_alt-hbkid = it_rpcode-partn.
          ld_tab-rpcode_alt-hktid = it_rpcode-parta.
          ld_tab-rpcode_alt-bankl = it_rpcode-bankl.
          ld_tab-rpcode_alt-banks = it_rpcode-banks.
          ld_tab-rpcode_alt-bankn = it_rpcode-bankn.
          ld_tab-rpcode_alt-bkont = it_rpcode-bkont.
          ld_tab-rpcode_alt-bkref = it_rpcode-bkref.

*         ld_tab-rpcode_neu-pbukr = it_rpcode-pbukr.
*         ld_tab-rpcode_neu-hbkid = it_rpcode-partn.
*         ld_tab-rpcode_neu-hktid = it_rpcode-parta.
          ld_tab-rpcode_neu-bankl = l_t012-bankl.
          ld_tab-rpcode_neu-banks = l_t012-banks.
          ld_tab-rpcode_neu-bankn = l_t012k-bankn.
          ld_tab-rpcode_neu-bkont = l_t012k-bkont.
          ld_tab-rpcode_neu-bkref = l_t012k-refzl.

          APPEND ld_tab.

        ENDIF.
    ENDCASE.

    APPEND it_rpcode.
    gt_rng_rpcode-low = sel_rpcode-rpcode.
    APPEND gt_rng_rpcode.
  ENDLOOP.

  DESCRIBE TABLE ld_tab LINES l_count.
  IF l_count > 0.
    LOOP AT ld_tab.
      ls_return-type       = 'W'.
      ls_return-id         = 'FIBL_RPCODE'.
      ls_return-number     = '090'.
      ls_return-message_v1 = ld_tab-rpcode.
      ls_return-message_v2 = ld_tab-rpcode_alt-hbkid.
      ls_return-message_v3 = ld_tab-rpcode_alt-hktid.
      ls_return-message_v4 = ld_tab-rpcode_alt-pbukr.
      PERFORM collect_to_log USING g_log_handle ls_return.

      IF ld_tab-rpcode_alt-banks NE ld_tab-rpcode_neu-banks.
        ls_return-number     = '091'.
        ls_return-message_v1 = TEXT-010.
        ls_return-message_v2 = ld_tab-rpcode_alt-banks.
        ls_return-message_v3 = ld_tab-rpcode_neu-banks.
        PERFORM collect_to_log USING g_log_handle ls_return.
      ENDIF.

      IF ld_tab-rpcode_alt-bankl NE ld_tab-rpcode_neu-bankl.
        ls_return-number     = '091'.
        ls_return-message_v1 = TEXT-011.
        ls_return-message_v2 = ld_tab-rpcode_alt-bankl.
        ls_return-message_v3 = ld_tab-rpcode_neu-bankl.
        PERFORM collect_to_log USING g_log_handle ls_return.
      ENDIF.

      IF ld_tab-bankn_alt+17(1) NE space
      OR ld_tab-bankn_neu+17(1) NE space.
        IF ld_tab-bankn_alt NE ld_tab-bankn_neu.
          ls_return-number     = '091'.
          ls_return-message_v1 = TEXT-012.
          ls_return-message_v2 = ld_tab-bankn_alt.
          ls_return-message_v3 = ld_tab-bankn_neu.
          PERFORM collect_to_log USING g_log_handle ls_return.
        ENDIF.
        IF ld_tab-bkref_alt NE ld_tab-rpcode_alt-bkref.
          IF ld_tab-rpcode_alt-bkont NE ld_tab-rpcode_neu-bkont.
            ls_return-number     = '091'.
            ls_return-message_v1 = TEXT-013.
            ls_return-message_v2 = ld_tab-rpcode_alt-bkont.
            ls_return-message_v3 = ld_tab-rpcode_neu-bkont.
            PERFORM collect_to_log USING g_log_handle ls_return.
          ENDIF.
        ELSE.
          IF ld_tab-rpcode_alt-bkref NE ld_tab-rpcode_neu-bkref.
            ls_return-number     = '091'.
            ls_return-message_v1 = TEXT-014.
            ls_return-message_v2 = ld_tab-rpcode_alt-bkref.
            ls_return-message_v3 = ld_tab-rpcode_neu-bkref.
            PERFORM collect_to_log USING g_log_handle ls_return.
          ENDIF.
        ENDIF.
      ELSE.
        IF ld_tab-rpcode_alt-bankn NE ld_tab-rpcode_neu-bankn.
          ls_return-number     = '091'.
          ls_return-message_v1 = TEXT-012.
          ls_return-message_v2 = ld_tab-rpcode_alt-bankn.
          ls_return-message_v3 = ld_tab-rpcode_neu-bankn.
          PERFORM collect_to_log USING g_log_handle ls_return.
        ENDIF.
        IF ld_tab-bkref_alt NE ld_tab-bkref_neu.
          ls_return-number     = '091'.
          ls_return-message_v1 = TEXT-014.
          ls_return-message_v2 = ld_tab-bkref_alt.
          ls_return-message_v3 = ld_tab-bkref_neu.
          PERFORM collect_to_log USING g_log_handle ls_return.
        ENDIF.
        IF ld_tab-bkont_alt NE ld_tab-bkont_neu.
          ls_return-number     = '091'.
          ls_return-message_v1 = TEXT-013.
          ls_return-message_v2 = ld_tab-bkont_alt.
          ls_return-message_v3 = ld_tab-bkont_neu.
          PERFORM collect_to_log USING g_log_handle ls_return.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM show_error_log USING g_log_handle.
  ENDIF.

* fill range for receiving company-codes
* Bapi for bank-to-bank payment request has to be read using
* receiving company code.

  CLEAR: gt_rng_pbukr.
  REFRESH: gt_rng_pbukr.

  SORT it_rpcode STABLE BY pbukr.                        " note 1494211
  DATA l_rc TYPE sysubrc.                                "begin n2689486
  LOOP AT it_rpcode.
    gt_rng_pbukr-sign    = 'I'.
    gt_rng_pbukr-option  = 'EQ'.
    PERFORM check_cross_country
      USING it_rpcode-bukrs it_rpcode-pbukr
      CHANGING l_rc.
    IF l_rc EQ 0.
      gt_rng_pbukr-low   = it_rpcode-pbukr.
    ELSE.
      gt_rng_pbukr-low   = it_rpcode-bukrs.
    ENDIF.
    COLLECT gt_rng_pbukr.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  check_cross_country  (new with SAP Note 2689486)
*&---------------------------------------------------------------------*
*       Check if repetitive code triggers cross-country bank transfer
*----------------------------------------------------------------------*
FORM check_cross_country USING i_buk1 TYPE bukrs            "n2689486
                               i_buk2 TYPE bukrs
                      CHANGING e_rc   TYPE sysubrc.

  RANGES lr_bukrs FOR  payrq-bukrs.
  DATA   lt_bukrs TYPE TABLE OF icompa WITH HEADER LINE.

* cross-country check is only necessary if company codes different
  IF i_buk1 EQ i_buk2.
    CLEAR e_rc.
  ELSE.

*   check if companies can be handled by F111: same country and currency
    lr_bukrs-high   = space.
    lr_bukrs-sign   = 'I'.
    lr_bukrs-option = 'EQ'.
    lr_bukrs-low    = i_buk1. APPEND lr_bukrs.
    lr_bukrs-low    = i_buk2. APPEND lr_bukrs.
    CALL FUNCTION 'FI_PAYMENT_COMPANY_CHECK'
      TABLES
        t_rng_bukrs        = lr_bukrs
        t_buktab           = lt_bukrs
      EXCEPTIONS
        country_different  = 2
        currency_different = 2
        authority_failed   = 0.
    e_rc = sy-subrc.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  collect_to_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      --> log_handle
*      --> message
*----------------------------------------------------------------------*
FORM collect_to_log USING im_log_guid TYPE balloghndl
                          ims_return TYPE bapiret2.
  DATA:
      ls_message TYPE bal_s_msg.

  ls_message-msgty = ims_return-type.
  ls_message-msgid = ims_return-id.
  ls_message-msgno = ims_return-number.
  ls_message-msgv1 = ims_return-message_v1.
  ls_message-msgv2 = ims_return-message_v2.
  ls_message-msgv3 = ims_return-message_v3.
  ls_message-msgv4 = ims_return-message_v4.

  CALL FUNCTION 'BAL_LOG_MSG_CUMULATE'
    EXPORTING
      i_log_handle     = im_log_guid
      i_s_msg          = ls_message
    EXCEPTIONS
      log_not_found    = 1
      msg_inconsistent = 2
      log_is_full      = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                               " collect_to_log
*---------------------------------------------------------------------*
*       FORM READ_BNKA                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_BANKS                                                       *
*  -->  P_BANKL                                                       *
*---------------------------------------------------------------------*
FORM read_bnka USING p_banks TYPE bnka-banks
                     p_bankl TYPE bnka-bankl
            CHANGING p_bnka  TYPE bnka.

  STATICS: BEGIN OF st_bnka OCCURS 0.
             INCLUDE STRUCTURE bnka.
  STATICS: END OF   st_bnka.

  IF st_bnka-banks NE p_banks
  OR st_bnka-bankl NE p_bankl.

    CLEAR: st_bnka.
    READ TABLE st_bnka WITH KEY banks = p_banks
                                bankl = p_bankl.
    IF sy-subrc NE 0.

      CLEAR st_bnka.
      SELECT SINGLE * FROM bnka INTO st_bnka
                               WHERE banks EQ p_banks
                               AND   bankl EQ p_bankl.
      IF sy-subrc EQ 0.
        APPEND st_bnka.
      ENDIF.
    ENDIF.
  ENDIF.
  p_bnka = st_bnka.

ENDFORM.                               " read_bnka
*&---------------------------------------------------------------------*
*&      Form  show_error_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_G_LOG_HANDLE  text
*----------------------------------------------------------------------*
FORM show_error_log USING    im_log_handle
                    TYPE balloghndl.

  DATA:
    lt_log_handle      TYPE bal_t_logh,
    ls_display_profile TYPE bal_s_prof.

  APPEND im_log_handle TO lt_log_handle.

  CALL FUNCTION 'BAL_DSP_PROFILE_POPUP_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile.

*  ls_display_profile-title     =
  ls_display_profile-use_grid   = 'X'.
  ls_display_profile-no_toolbar = 'X'.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile  = ls_display_profile
      i_t_log_handle       = lt_log_handle
      i_amodal             = false                            "n2318144
    EXCEPTIONS
      profile_inconsistent = 1
      internal_error       = 2
      no_data_available    = 3
      no_authority         = 4
      OTHERS               = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                               " show_error_log
*&---------------------------------------------------------------------*
*&      Form  read_payrq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_payrq.
* Correction n2396202: No BAPI~~GETLIST call with receiving company code
* => Now cross-company payment requests are shown according to selection
  DATA: ld_rc    TYPE sysubrc,
        lt_payrq TYPE TABLE OF payrq WITH HEADER LINE.

  IF flg_sel IS INITIAL.
    EXIT.
  ENDIF.

  RANGES lr_origin FOR tfiblorigin-origin.

* fill range lr_origin

  lr_origin-sign = 'I'.
  lr_origin-option = 'EQ'.
  lr_origin-low    = 'TR-CM-BT'.
  APPEND lr_origin.


  REFRESH it_pay_req.
  CLEAR it_pay_req.
  SELECT * FROM   payrq  "using DB index 002                   "n2396202
    INTO   TABLE  lt_payrq
    WHERE  bukrs  IN gt_rng_pbukr
    AND    augbl  EQ space
    AND    origin IN lr_origin
    AND    zbukr  IN gt_rng_buk
    AND    hbkid  IN gt_rng_hbk.
  CHECK sy-subrc EQ 0.

* check: payrq should correspond to selection
* if check ok, move to table it_pay_req.
  LOOP AT lt_payrq.
    PERFORM check_authority_payrq
            USING lt_payrq-bukrs
                  lr_origin-low gd_auth_pq_show
            CHANGING ld_rc.
    IF ld_rc NE 0.
      CONTINUE.
    ENDIF.
    PERFORM check_payrq USING lt_payrq CHANGING ld_rc.
    IF ld_rc NE 0.
      CONTINUE.
    ENDIF.
    MOVE-CORRESPONDING lt_payrq TO it_pay_req.
* fill information from repetitive (partner object and his bank)
    PERFORM get_info_repetitive CHANGING it_pay_req.
    APPEND it_pay_req.
  ENDLOOP.
ENDFORM.                               " read_payrq
*&---------------------------------------------------------------------*
*&      Form  check_authority_payrq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LR_ORIGIN_LOW  text
*      -->P_GD_AUTH_PQ_SHOW  text
*----------------------------------------------------------------------*
FORM check_authority_payrq
          USING    im_bukrs
                   im_origin
                   im_act_type
          CHANGING ex_rc.
  CLEAR ex_rc.
  IF im_bukrs = 'DUMMY'.
    AUTHORITY-CHECK OBJECT 'F_PAYRQ'
    ID 'BUKRS' DUMMY
    ID 'ORIGIN' FIELD im_origin
    ID 'ACTVT' FIELD im_act_type.
    ex_rc = sy-subrc.
    EXIT.
  ENDIF.
  CALL FUNCTION 'FI_BL_PAYRQ_AUTH_CHECK'
    EXPORTING
      i_bukrs      = im_bukrs
      i_origin     = im_origin
      i_auth_code  = im_act_type
    EXCEPTIONS
      no_authority = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    ex_rc = sy-subrc.
  ENDIF.

ENDFORM.                               " check_authority_payrq
*&---------------------------------------------------------------------*
*&      Form  check_payrq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LD_RC  text
*----------------------------------------------------------------------*
FORM check_payrq USING im_payrq STRUCTURE payrq
                 CHANGING ex_rc .

  RANGES lr_bukrs FOR fibl_rpcode-bukrs.
  RANGES lr_hbkid FOR fibl_rpcode-hbkid.
  RANGES lr_rpcode FOR fibl_rpcode-rpcode.
  DATA: BEGIN OF lt_rpcode_in_group OCCURS 10.
          INCLUDE STRUCTURE fibl_rpcode_in_group.
  DATA: END OF lt_rpcode_in_group.

  CLEAR ex_rc.

* check paying company code.
  IF NOT im_payrq-zbukr IN gt_rng_buk.
    ex_rc = 4.
    EXIT.
  ENDIF.

* check housebank
  IF NOT im_payrq-hbkid IN gt_rng_hbk.
    ex_rc = 4.
    EXIT.
  ENDIF.
* check repetitive code
  IF NOT im_payrq-rfttrn IN gt_rng_rpcode.
    ex_rc = 4.
    EXIT.
  ENDIF.

* check if payment request is already in proposal run    "start n2718452
  DATA:
    lt_regus TYPE TABLE OF regus,
    l_count  TYPE sydbcnt.
  FIELD-SYMBOLS:
    <ls_regus> TYPE regus.
  SELECT * FROM regus INTO TABLE lt_regus
    WHERE koart = im_payrq-koart
    AND   bukrs = im_payrq-bukrs
    AND   konko = im_payrq-parno.
  LOOP AT lt_regus ASSIGNING <ls_regus>.
    SELECT COUNT( * ) INTO l_count FROM regup
      WHERE laufd EQ <ls_regus>-laufd
      AND   laufi EQ <ls_regus>-laufi
      AND   xvorl EQ 'X'
      AND   keyno EQ im_payrq-keyno.
    IF l_count NE 0.
      ex_rc = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF ex_rc NE 0.      "proposal run found => exclude from list
    EXIT.
  ENDIF.                                                   "end n2718452

* check: repetitive code of payrq in group ?
  IF gt_rng_grp[] IS INITIAL.
    EXIT.
  ENDIF.

  lr_bukrs-sign = 'I'.
  lr_bukrs-option = 'EQ'.
  lr_bukrs-low = im_payrq-zbukr.
  APPEND lr_bukrs.

  lr_hbkid-sign = 'I'.
  lr_hbkid-option = 'EQ'.
  lr_hbkid-low  = im_payrq-hbkid.
  APPEND lr_hbkid.

  lr_rpcode-sign = 'I'.
  lr_rpcode-option = 'EQ'.
  lr_rpcode-low = im_payrq-rfttrn.
  APPEND lr_rpcode.

  CALL FUNCTION 'FIBL_RPCODE_IN_GROUP'
    TABLES
      it_r_bukrs_sel     = lr_bukrs
      it_r_hbkid_sel     = lr_hbkid
      it_r_rpcode_sel    = lr_rpcode
      et_rpcode_in_group = lt_rpcode_in_group
    EXCEPTIONS
      no_group           = 1
      no_repetitive      = 2.
  IF sy-subrc <> 0.
* no groups with the required repetitive code
    ex_rc = 4.
    EXIT.
  ENDIF.
* groups with the required repetitive code exist
* do these groups belong to the requested range of groups ?
  ex_rc = 4.
  LOOP AT lt_rpcode_in_group.
    IF lt_rpcode_in_group-rpgroup IN gt_rng_grp.
      ex_rc = 0.
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " check_payrq
*&---------------------------------------------------------------------*
*&      Form  get_info_repetitive
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_IT_PAY_REQ  text
*----------------------------------------------------------------------*
FORM get_info_repetitive CHANGING is_it_pay_req STRUCTURE frft_payrq.
  DATA: ls_fibl_rpcode_i TYPE fibl_rpcode_i.
  CALL FUNCTION 'FIBL_RPCODE_SINGLE_READ'
    EXPORTING
      id_bukrs         = is_it_pay_req-zbukr
      id_hbkid         = is_it_pay_req-hbkid
      id_rpcode        = is_it_pay_req-rfttrn
    IMPORTING
      es_fibl_rpcode_i = ls_fibl_rpcode_i
    EXCEPTIONS
      OTHERS           = 0.
  CASE gd_ptype.
    WHEN type_bank.
      MOVE ls_fibl_rpcode_i-pbukr TO is_it_pay_req-pbukr.
      MOVE ls_fibl_rpcode_i-partn TO is_it_pay_req-phbkid.
      MOVE ls_fibl_rpcode_i-parta TO is_it_pay_req-phktid.
    WHEN type_cbp.
      MOVE ls_fibl_rpcode_i-pbukr TO is_it_pay_req-pbukr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = ls_fibl_rpcode_i-partn
        IMPORTING
          output = ls_fibl_rpcode_i-partn.
      MOVE ls_fibl_rpcode_i-partn TO is_it_pay_req-partnr.
      MOVE ls_fibl_rpcode_i-parta TO is_it_pay_req-bkvid.

  ENDCASE.
ENDFORM.                               " get_info_repetitive
*&---------------------------------------------------------------------*
*&      Form  create_prq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_payrq.
  DATA: ld_keyno TYPE prq_keyno.
  DATA: ld_tabix LIKE sy-tabix.
  CLEAR gd_check_payrq.

  TYPES: BEGIN OF ty_amts,
           rbukrs TYPE acdoca-rbukrs,
           rassc  TYPE acdoca-rassc,
           prctr  TYPE acdoca-prctr,
           hsl    TYPE acdoca-hsl,
         END OF ty_amts.

  TYPES: BEGIN OF ty_rpcode,
           pbukr TYPE v_faglflext_view-rbukrs,
           rassc TYPE v_faglflext_view-rassc,
           prctr TYPE v_faglflext_view-prctr,
           zuonr TYPE acdoca-zuonr,
         END OF ty_rpcode.

  DATA:
    lt_amts     TYPE TABLE OF ty_amts,
    ls_amts     TYPE ty_amts,
    lt_amts_zv  TYPE TABLE OF ty_amts,
    ls_amts_zv  TYPE ty_amts,
    lt_rpcode   TYPE TABLE OF ty_rpcode,
    ls_rpcode   TYPE ty_rpcode,
    gr_blart_e  TYPE RANGE OF acdoca-blart,
    grs_blart_e LIKE LINE OF gr_blart_e,
    gr_blart_n  TYPE RANGE OF acdoca-blart,
    grs_blart_n LIKE LINE OF gr_blart_n.

  FIELD-SYMBOLS: <fs_value> TYPE Any.

  SPLIT rng_grp AT '_' INTO DATA(lv_1) DATA(lv_2).
  LOOP AT it_rpcode.
    IF lv_2 EQ 'C'.
      ls_rpcode-pbukr = it_rpcode-bukrs.
      ls_rpcode-rassc = it_rpcode-pbukr.
    ENDIF.
    IF lv_2 EQ 'D'.
      ls_rpcode-pbukr = it_rpcode-pbukr.
      ls_rpcode-rassc = it_rpcode-bukrs.
    ENDIF.
    ls_rpcode-rassc = |{ ls_rpcode-rassc ALPHA = IN }|.
    SPLIT it_rpcode-rpcode AT '_' INTO DATA(lv_spt1) ls_rpcode-prctr.
    ls_rpcode-prctr = |{ ls_rpcode-prctr ALPHA = IN }|.
    ls_rpcode-zuonr = ls_rpcode-prctr.
    APPEND ls_rpcode TO lt_rpcode.
    CLEAR:ls_rpcode.
  ENDLOOP.

  SELECT *
    FROM tvarvc
    INTO TABLE @DATA(lt_doctyps)
   WHERE name EQ 'ZFI_CREATE_REPETITIVE_CODE_DOC'.
  IF sy-subrc EQ 0.
    LOOP AT lt_doctyps INTO DATA(ls_doctyps).
      IF ls_doctyps-sign EQ 'I'.
        grs_blart_e-sign = 'I'.
        grs_blart_e-option = 'EQ'.
        grs_blart_e-low = ls_doctyps-low.
        APPEND grs_blart_e TO gr_blart_e.
      ENDIF.
      IF ls_doctyps-sign EQ 'E'.
        grs_blart_n-sign = 'E'.
        grs_blart_n-option = 'EQ'.
        grs_blart_n-low = ls_doctyps-low.
        APPEND grs_blart_n TO gr_blart_n.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SELECT rldnr,
         rbukrs,
         gjahr,
         belnr,
         docln,
         racct,
         prctr,
         blart,
         rassc,
         hsl
    FROM acdoca
    INTO TABLE @DATA(lt_acdoca)
     FOR ALL ENTRIES IN @lt_rpcode
   WHERE ryear EQ @p_fy
     AND rldnr EQ '0L'
     AND racct EQ '0000200100'
     AND rbukrs EQ @lt_rpcode-pbukr
     AND prctr EQ @lt_rpcode-prctr
     AND rassc EQ @lt_rpcode-rassc
     AND blart IN @gr_blart_n.
  IF sy-subrc EQ 0 .
    LOOP AT lt_acdoca INTO DATA(ls_acdoca).
      ls_amts-rbukrs = ls_acdoca-rbukrs.
      ls_amts-rassc = |{ ls_acdoca-rassc ALPHA = OUT }|.
      ls_amts-prctr = ls_acdoca-prctr.
      ls_amts-hsl = ls_acdoca-hsl.
      COLLECT ls_amts INTO lt_amts.
      CLEAR:ls_amts.
    ENDLOOP.
  ENDIF.

  SELECT rldnr,
         rbukrs,
         gjahr,
         belnr,
         docln,
         racct,
         prctr,
         blart,
         rassc,
         zuonr,
         hsl
    FROM acdoca
    INTO TABLE @DATA(lt_acdoca_zv)
     FOR ALL ENTRIES IN @lt_rpcode
   WHERE ryear EQ @p_fy
     AND rldnr EQ '0L'
     AND racct EQ '0000200100'
     AND rbukrs EQ @lt_rpcode-pbukr
     AND zuonr EQ @lt_rpcode-zuonr
     AND rassc EQ @lt_rpcode-rassc
     AND blart IN @gr_blart_e.
  IF sy-subrc EQ 0 .
    LOOP AT lt_acdoca_zv INTO DATA(ls_acdoca_zv).
      ls_amts-rbukrs = ls_acdoca_zv-rbukrs.
      ls_amts-rassc = |{ ls_acdoca_zv-rassc ALPHA = OUT }|.
      ls_amts-prctr = ls_acdoca_zv-zuonr.
      ls_amts-hsl = ls_acdoca_zv-hsl.
      COLLECT ls_amts INTO lt_amts_zv.
      CLEAR:ls_amts.
    ENDLOOP.
  ENDIF.

  LOOP AT it_rpcode." WHERE ( NOT rwbtr IS INITIAL ).
    ld_tabix = sy-tabix.
    CLEAR:ls_rpcode, ls_amts, ls_amts_zv.
    SPLIT it_rpcode-rpcode AT '_' INTO lv_spt1 ls_rpcode-prctr.
    ls_rpcode-prctr = |{ ls_rpcode-prctr ALPHA = IN }|.
    IF lv_2 EQ 'C'.
      ls_rpcode-pbukr = it_rpcode-bukrs.
      ls_rpcode-rassc = it_rpcode-pbukr.
    ENDIF.
    IF lv_2 EQ 'D'.
      ls_rpcode-pbukr = it_rpcode-pbukr.
      ls_rpcode-rassc = it_rpcode-bukrs.
    ENDIF.
    READ TABLE lt_amts INTO ls_amts WITH KEY rbukrs = ls_rpcode-pbukr
                                              rassc = ls_rpcode-rassc
                                              prctr = ls_rpcode-prctr.
    READ TABLE lt_amts_zv INTO ls_amts_zv WITH KEY rbukrs = ls_rpcode-pbukr
                                                    rassc = ls_rpcode-rassc
                                                    prctr = ls_rpcode-prctr.
    it_rpcode-rwbtr = ls_amts-hsl + ls_amts_zv-hsl.
    IF it_rpcode-rwbtr LT 0.
      IF lv_spt1+2(1) EQ 'C'.
        it_rpcode-rwbtr = it_rpcode-rwbtr * -1.
        DATA(lv_flag) = abap_true.
      ELSE.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF lv_flag NE abap_true.
      IF it_rpcode-rwbtr GT 0.
        IF lv_spt1+2(1) NE 'D'.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR:lv_flag.

    IF it_rpcode-rwbtr IS INITIAL.
      CONTINUE.
    ENDIF.

    PERFORM post_payrq CHANGING ld_keyno
                                gd_check_payrq.
    IF gd_check_payrq IS INITIAL.
* payment request created, move to list of payrq
      PERFORM move_to_payrq USING ld_keyno
                                  ld_tabix.
    ENDIF.
  ENDLOOP.
* no entries with amount ?
  IF sy-subrc = 4.
    MESSAGE w069.
  ELSE.
* no problems
    IF g_log_handle IS NOT INITIAL.
      PERFORM show_error_log USING g_log_handle.
      flg_changed = 0.
    ELSE.
      MESSAGE 'Process Complete' TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.                                                    "loop
* sort it_pay_req by  keyno descending
  SORT it_pay_req BY keyno DESCENDING.
ENDFORM.                               " create_prq
*&---------------------------------------------------------------------*
*&      Form  post_payrq
*&---------------------------------------------------------------------*
*      post payment-requests
*----------------------------------------------------------------------*
*      <--ED_CHECK_PAYRQ  text
*----------------------------------------------------------------------*
FORM post_payrq CHANGING
               ex_keyno
               ed_check_payrq.
* => LFIBL_MAINPAYF01, check_consistency
  DATA: lt_address_data     TYPE yt_address_data,
        lt_bank_data        TYPE yt_bank_data,
        wa_bank_data        TYPE LINE OF yt_bank_data,
        ls_return           TYPE bapiret2,
        ld_origin           TYPE fibl_origin,
        ls_origin           TYPE bapi2021_origin,
        ls_organizations    TYPE bapi2021_organisations,
        ls_accounts         TYPE bapi2021_accounts,
        ls_amounts          TYPE bapi2021_amounts,
        ls_dates            TYPE bapi2021_dates,
        ls_paym_control     TYPE bapi2021_paymentctrl,
        ls_references       TYPE bapi2021_references,
        ls_central_bank_rep TYPE bapi2021_centralbankrep,
        ls_instructions     TYPE bapi2021_instructions,
        lt_reftxt           TYPE yt_reftxt,
        lt_extension        TYPE yt_extension,
        ls_t042z            TYPE t042z,
        ld_einz             TYPE xeinz.
  DATA: ld_rpcode TYPE rpcode,
        ld_gsber  TYPE gsber,
        ld_keyno  TYPE prq_keyno.
  DATA: ls_corrdoc TYPE  bapi2021_corrdoc.
  DATA  ls_bnka TYPE bnka.

*************************************************************
* first check consistency
*************************************************************
  CLEAR: ed_check_payrq.

*************************************************************
* general preparation for all partner types
*************************************************************

* prepare rpcode for display in error-log
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = it_rpcode-rpcode
    IMPORTING
      output = ld_rpcode.

* fill internal table lt_bank
  wa_bank_data-account_role = '2'.
  wa_bank_data-bank_ctry = it_rpcode-banks.
  wa_bank_data-bank_key = it_rpcode-bankl.
  wa_bank_data-bank_acct = it_rpcode-bankn.
  wa_bank_data-acct_hold = it_rpcode-koinh.
  wa_bank_data-coll_auth = 'X'.
  wa_bank_data-bank_ref = it_rpcode-bkref.

* support of IBAN without bank account number, for business partner only
  IF gd_ptype EQ type_cbp                                "begin n2571901
     AND wa_bank_data-bank_acct IS INITIAL
     AND NOT it_rpcode-parta    IS INITIAL.

    DATA ls_bus0bk TYPE bus0bk.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = it_rpcode-partn
      IMPORTING
        output = ls_bus0bk-partner.
    ls_bus0bk-bkvid = it_rpcode-parta.
    CALL FUNCTION 'BUP_BANK_GET'
      EXPORTING
        i_partner = ls_bus0bk-partner
        i_bkvid   = ls_bus0bk-bkvid
      IMPORTING
        e_but0bk  = ls_bus0bk
      EXCEPTIONS
        OTHERS    = 4.

*   mark IBAN without account number (technically <IBAN>)
    IF sy-subrc EQ 0 AND NOT ls_bus0bk-iban IS INITIAL.
      wa_bank_data-iban      = ls_bus0bk-iban.
      wa_bank_data-bank_acct = '<IBAN>'.
    ENDIF.

  ENDIF.                                                   "end n2571901

* fill bank-information
  CALL FUNCTION 'READ_BANK_ADDRESS'
    EXPORTING
      bank_country = it_rpcode-banks
      bank_number  = it_rpcode-bankl
    IMPORTING
      bnka_wa      = ls_bnka
    EXCEPTIONS
      not_found    = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  wa_bank_data-region = ls_bnka-provz.
  wa_bank_data-bank_no = ls_bnka-bnklz.
  wa_bank_data-swift_code = ls_bnka-swift.
  wa_bank_data-ctrl_key = it_rpcode-bkont.
  APPEND wa_bank_data TO lt_bank_data.

* organizations
  ls_organizations-comp_code      = it_rpcode-pbukr.
  ls_organizations-pay_comp_code  = it_rpcode-bukrs.
  ls_organizations-send_comp_code = it_rpcode-bukrs.

* accounts
  ls_accounts-acct_type           = 'S'.

* check: is all data available being required for the specified
* payment method ?
* check payment method for posting
  CALL FUNCTION 'FI_PAYMENT_METHOD_PROPERTIES'
    EXPORTING
      i_zlsch                = it_rpcode-zlsch
      i_zbukr                = it_rpcode-bukrs
    IMPORTING
      e_t042z                = ls_t042z
    EXCEPTIONS
      error_t042z            = 1
      error_t042e            = 2
      error_import_parameter = 3
      OTHERS                 = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ld_einz = ls_t042z-xeinz.

* check amount for methods with payment medium workbench
* for ACH-Format amount must be less or equl $99.999.999,99
  IF NOT ls_t042z-formi IS INITIAL.
    PERFORM fibl_check_amount_for_format
        USING it_rpcode-rwbtr
              it_rpcode-waers
              it_rpcode-zlsch
              ls_t042z-formi.
  ENDIF.

* check amount for methods with payment medium workbench
  IF NOT ls_t042z-formi IS INITIAL.
    CALL FUNCTION 'FIBL_CHECK_AMOUNT_FOR_FORMAT'
      EXPORTING
        im_paym_amount     = it_rpcode-rwbtr
        im_paym_curr       = it_rpcode-waers
        im_paym_method     = it_rpcode-zlsch
        im_format          = ls_t042z-formi
      EXCEPTIONS
        no_pmw_paym_method = 1
        amount_too_large   = 2
        paym_method_error  = 3
        format_error       = 4
        OTHERS             = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      EXIT.
    ENDIF.
  ENDIF.

*-- fill foreign currency
  ls_amounts-paym_curr    = it_rpcode-waers.

*-- if the payment is done in foreign currency and the domestic
*   domestic currency amount has not been specified, the field for the
*   demestic currency has to be cleared to make the Create-BAPI doing
*   calculation for the domestic amount ---
  CLEAR ls_amounts-loc_currcy.

* Dates
  IF frft_bank_rep-xkdfb IS INITIAL.                        "n1721242
    ls_dates-due_date              = sy-datlo.
  ELSE.                                                     "n1721242
    ls_dates-due_date              = reguh-valut.           "n1721242
  ENDIF.                                                    "n1721242
  ls_dates-value_date_sender     = sy-datlo.

* ls_paym_control
  ls_paym_control-housebankid = it_rpcode-hbkid.
  ls_paym_control-housebankacctid = it_rpcode-hktid.
  ls_paym_control-paycode = it_rpcode-rpcode.
  ls_paym_control-indiv_payment = it_rpcode-xpore.
  ls_paym_control-no_exchange_rate_diff = it_rpcode-xkdfb.  "n1721242
  ls_paym_control-payment_methods = it_rpcode-zlsch.
  ls_paym_control-pmtmthsupl = it_rpcode-pmtmthsupl.        "n2216440

* check bankchain
  IF NOT it_rpcode-chain IS INITIAL.
    CALL FUNCTION 'FIBL_GET_BANKCHAIN_DATA'
      EXPORTING
        im_chainid                = it_rpcode-chain
      TABLES
        ext_bank_data             = lt_bank_data
      EXCEPTIONS
        acct_num_conversion_error = 1
        OTHERS                    = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

* move text
  IF NOT it_rpcode-rp_text IS INITIAL.
    CONCATENATE '*' it_rpcode-rp_text INTO ls_references-item_text.
  ENDIF.
  ls_references-paymt_ref = it_rpcode-paymt_ref.            "n2216440

* origin logsystem
  CALL FUNCTION 'FIBL_GET_LOGSYS'
    IMPORTING
      ex_logsys = ls_origin-logsystem.

* business areas
  CALL FUNCTION 'FIBL_GET_BUS_AREA_BANK'
    EXPORTING
      im_comp_code       = it_rpcode-bukrs
      im_housebankid     = it_rpcode-hbkid
      im_paym_method     = it_rpcode-zlsch
      im_paym_curr       = it_rpcode-waers
      im_housebankacctid = it_rpcode-hktid
    IMPORTING
      ex_bus_area        = ld_gsber
    EXCEPTIONS
      no_t042y_entry     = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ls_organizations-bus_area_bank  = ld_gsber.

*******************************************************
* special preparation depending on partner type
*******************************************************

*---- partner type bank -----
  gd_ptype = '03'.
  CASE gd_ptype.
    WHEN type_bank.
* get partner bank-address
      PERFORM get_address_bank
          USING it_rpcode
          CHANGING lt_address_data.
*-- fill amount foreign currency
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXT_31' " AFLE
        EXPORTING
          currency        = ls_amounts-paym_curr
          amount_internal = it_rpcode-rwbtr
        IMPORTING
          amount_external = ls_amounts-paym_amount_long. " AFLE

*   Begin of note 2926616
*-- translate to local currency if exchange rate type is given
      PERFORM translate_lc_amount
           TABLES lt_reftxt
           USING  kurst_prq
                  gs_t001-waers
           CHANGING ls_amounts
                    ls_paym_control.
*   End of note 2926616

* origin
      ls_origin-origin = gd_origin_bank.
* business areas
      ls_organizations-bus_area = it_rpcode-gsber.
* accounts
*-- determine the partner account for field PARNO in PAYRQ ---
* for bank to bank, read t018v
      PERFORM find_partaccount_bank
           USING it_rpcode
           CHANGING ls_accounts.
      IF gv_error EQ abap_true.
        CLEAR:gv_error.
        ed_check_payrq = 4.
        EXIT.
      ENDIF.
* dates
      CALL FUNCTION 'FI_PRQ_CREDIT_DATE_DETERMINE'
        EXPORTING
          im_valut = reguh-valut
        IMPORTING
          ex_crval = ls_dates-value_date_receiver.

*--- Get IBAN ---
      DATA: lv_iban  TYPE iban,
            lv_bankn TYPE bankn.
      LOOP AT lt_bank_data ASSIGNING FIELD-SYMBOL(<fs_bank_data>).
        CLEAR lv_iban.
        lv_bankn = <fs_bank_data>-bank_acct.
        CALL FUNCTION 'READ_IBAN_HBA'
          EXPORTING
            i_banks        = <fs_bank_data>-bank_ctry
            i_bankl        = <fs_bank_data>-bank_no
            i_bankn        = lv_bankn
            i_bkont        = <fs_bank_data>-ctrl_key
            i_bkref        = <fs_bank_data>-bank_ref
          IMPORTING
            e_iban         = lv_iban
          EXCEPTIONS
            iban_not_found = 1.

        IF lv_iban IS NOT INITIAL.
          <fs_bank_data>-iban = lv_iban.
        ENDIF.
      ENDLOOP.

* --- partner type central/treasury business partner -----

    WHEN type_cbp.
* get partner bank-address
      PERFORM get_address_cbp
               USING it_rpcode
               CHANGING lt_address_data.
*-- fill amount foreign currency
      CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXT_31' " AFLE
        EXPORTING
          currency        = ls_amounts-paym_curr
          amount_internal = it_rpcode-rwbtr
        IMPORTING
          amount_external = ls_amounts-paym_amount_long. " AFLE
*     ls_amounts-paym_amount = it_rpcode-rwbtr.
* origin
      ls_origin-origin = gd_origin_cbp.
* business areas
      ls_organizations-bus_area       = ld_gsber.
* accounts
*-- determine the partner account for field PARNO in PAYRQ ---
* for cbp read account from atpra
      PERFORM find_partaccount_cbp
            USING it_rpcode
            CHANGING ls_accounts.
* dates
      CLEAR ls_dates-value_date_receiver.

      TRY.                                                  "n2480007
*       determine tax number from Treasury business partner
          DATA ls_bp1020 TYPE bp1020.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = it_rpcode-partn
            IMPORTING
              output = ls_bp1020-partnr.
          CALL FUNCTION 'FTBP_READ_BP1020'
            EXPORTING
              i_partner = ls_bp1020-partnr
            IMPORTING
              e_bp1020  = ls_bp1020
            EXCEPTIONS
              OTHERS    = 4.
          IF sy-subrc EQ 0.
            ls_central_bank_rep-tax_no_1 = ls_bp1020-stcd1.
          ELSE.
            CLEAR ls_central_bank_rep-tax_no_1.
          ENDIF.
        CATCH cx_root.
          CLEAR ls_central_bank_rep-tax_no_1.
      ENDTRY.

  ENDCASE.

*********************************************************************
* For all partner-types:                                            *
*********************************************************************

* The payment amount has been determined for both partners in the
* previous part. Now the direction of payment has to be considered
*-- outgoing payment has negative sign ---
  IF ld_einz IS INITIAL.
    ls_amounts-paym_amount_long = - ls_amounts-paym_amount_long. " AFLE
  ENDIF.

*-- fill cen. bank indicator, supplying country and instruction key
  ls_central_bank_rep-scbank_ind = it_rpcode-scbank_ind.
  ls_central_bank_rep-supcountry = it_rpcode-supcountry.
  ls_instructions-instr_key = it_rpcode-instr_key.
  ls_instructions-instr1    = it_rpcode-instr1.             "n3016343
  ls_instructions-instr2    = it_rpcode-instr2.             "n3016343
  ls_instructions-instr3    = it_rpcode-instr3.             "n3016343
  ls_instructions-instr4    = it_rpcode-instr4.             "n3016343

* Create the payment requests:
*-- Test run with additional checks ---
  CALL FUNCTION 'BAPI_PAYMENTREQUEST_CREATE'
    EXPORTING
      origin           = ls_origin
      organisations    = ls_organizations
      accounts         = ls_accounts
      amounts          = ls_amounts
      value_dates      = ls_dates
      paym_control     = ls_paym_control
      references       = ls_references                     "n2216440
      central_bank_rep = ls_central_bank_rep
      instructions     = ls_instructions
      releasepost      = 'X'
      releasepay       = space  "release not immediately
      testrun          = 'X'
    IMPORTING
      return           = ls_return
    TABLES
      address_data     = lt_address_data
      bank_data        = lt_bank_data
      reference_text   = lt_reftxt
      extensionin      = lt_extension.

  IF NOT ls_return IS INITIAL.
    PERFORM add_to_log
        USING g_log_handle
              ls_return.
    ed_check_payrq = 4.
    EXIT.
  ENDIF.

*********************************************************************
* if consistency and testrun is ok, post payrq
*********************************************************************

  CHECK ls_return IS INITIAL.

  CASE gd_ptype.
    WHEN type_cbp.
* Start with FI-document-Posting
      PERFORM fi_post_cbp
         USING it_rpcode
               ls_accounts
               ls_t042z
               ld_gsber
         CHANGING ls_amounts
                  ls_corrdoc
                  ls_references.

*-- Write payment request to database if document was posted ---
      IF ls_corrdoc-ac_doc_no IS INITIAL.
        ed_check_payrq = 4.
        EXIT.
      ENDIF.
    WHEN type_bank.
  ENDCASE.

  CALL FUNCTION 'BAPI_PAYMENTREQUEST_CREATE'
    EXPORTING
      origin           = ls_origin
      organisations    = ls_organizations
      accounts         = ls_accounts
      amounts          = ls_amounts
      value_dates      = ls_dates
      paym_control     = ls_paym_control
      corr_doc         = ls_corrdoc
      references       = ls_references
      central_bank_rep = ls_central_bank_rep
      instructions     = ls_instructions
      releasepost      = 'X'
      releasepay       = space
    IMPORTING
      return           = ls_return
      requestid        = ld_keyno
    TABLES
      address_data     = lt_address_data
      bank_data        = lt_bank_data
      reference_text   = lt_reftxt
      extensionin      = lt_extension.

  IF NOT ls_return IS INITIAL.
    PERFORM add_to_log
       USING g_log_handle
             ls_return.
    ed_check_payrq = 4.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK.
    ex_keyno = ld_keyno.
*-   write a message about success regarding PAYRQ-creation ---
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ld_keyno
      IMPORTING
        output = ld_keyno.

    ls_return-type       = 'S'.
    ls_return-id         = 'FIBL_RPCODE'.
    ls_return-number     = '068'.
    ls_return-message_v1 = ld_keyno.
    ls_return-message_v2 = ld_rpcode.
    PERFORM add_to_log
      USING
        g_log_handle
        ls_return.
  ENDIF.

ENDFORM.                               " check_consistency
*&---------------------------------------------------------------------*
*&      Form  move_to_payrq
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_to_payrq
       USING im_keyno TYPE prq_keyno
             im_tabix TYPE sy-tabix.
  DATA:ls_return TYPE bapiret2.
* move to payrq
  CLEAR it_pay_req.
  it_pay_req-keyno = im_keyno.
  it_pay_req-rfttrn = it_rpcode-rpcode.
  it_pay_req-zbukr = it_rpcode-bukrs.
  it_pay_req-hbkid = it_rpcode-hbkid.
  it_pay_req-hktid = it_rpcode-hktid.
  it_pay_req-zwels = it_rpcode-zlsch.
  it_pay_req-waers = it_rpcode-waers.
  it_pay_req-wrbtr = it_rpcode-rwbtr.
  it_pay_req-dtaws = it_rpcode-instr_key.
  it_pay_req-dtws1 = it_rpcode-instr1.                      "n3016343
  it_pay_req-dtws2 = it_rpcode-instr2.                      "n3016343
  it_pay_req-dtws3 = it_rpcode-instr3.                      "n3016343
  it_pay_req-dtws4 = it_rpcode-instr4.                      "n3016343
  it_pay_req-lzbkz = it_rpcode-scbank_ind.
  it_pay_req-landl = it_rpcode-supcountry.
  it_pay_req-uzawe = it_rpcode-pmtmthsupl.                  "n2216440
  it_pay_req-kidno = it_rpcode-paymt_ref.                   "n2216440
  it_pay_req-valut = reguh-valut.
  CONCATENATE '*' it_rpcode-rp_text INTO
              it_pay_req-sgtxt.
  it_pay_req-pbukr = it_rpcode-pbukr.
* depending on gt_ptype.
  CASE gd_ptype.
    WHEN type_bank.
      it_pay_req-phbkid = it_rpcode-partn.
      it_pay_req-phktid = it_rpcode-parta.
    WHEN type_cbp.
      it_pay_req-partnr = it_rpcode-partn.
      it_pay_req-bkvid = it_rpcode-parta.
  ENDCASE.
  IF it_pay_req-wrbtr < 0.                                  "n1566268
*    MESSAGE e086.                                           "n1566268
    CLEAR:ls_return.
    ls_return-type = 'E'.
    ls_return-id = 'FIBL_RPCODE'.
    ls_return-number = '086'.
    PERFORM add_to_log
      USING g_log_handle
            ls_return.
    EXIT.
  ENDIF.                                                    "n1566268
  APPEND it_pay_req.
* delete from it_rpcode.
  DELETE it_rpcode INDEX im_tabix.

ENDFORM.                               " move_to_payrq
*&---------------------------------------------------------------------*
*&      Form  add_to_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_LOG_HANDLE  text
*      -->P_LS_RETURN  text
*----------------------------------------------------------------------*
FORM add_to_log USING    im_log_guid TYPE balloghndl
                         ims_return TYPE bapiret2.
  DATA:
      ls_message TYPE bal_s_msg.
  ls_message-msgty = ims_return-type.
  ls_message-msgid = ims_return-id.
  ls_message-msgno = ims_return-number.
  ls_message-msgv1 = ims_return-message_v1.
  ls_message-msgv2 = ims_return-message_v2.
  ls_message-msgv3 = ims_return-message_v3.
  ls_message-msgv4 = ims_return-message_v4.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle     = im_log_guid
      i_s_msg          = ls_message
    EXCEPTIONS
      log_not_found    = 1
      msg_inconsistent = 2
      log_is_full      = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                               " add_to_log
*&---------------------------------------------------------------------*
*&      Form  FIBL_CHECK_AMOUNT_FOR_FORMAT
*&---------------------------------------------------------------------*
*       for ACH-FORMAT (NACHA) maximum amount is $99.999.999,99
*       in SAP-Enterprise replaced by function module
*       fibl_check_amount_for_format.
*
*       new with note 436295
*----------------------------------------------------------------------*
*      -->id_amount  amount
*      -->id_curr  currency
*      -->id_paymethod  payment method
*      -->id_T042Z_FORMI   Payment Medium Format
*----------------------------------------------------------------------*
FORM fibl_check_amount_for_format USING    id_amount
                                           id_curr
                                           id_paymethod
                                           id_t042z_formi.

  DATA:
    l_format          TYPE formi_fpm,
    ls_tfpm042f       TYPE tfpm042f,
    l_trunc_amount    TYPE prq_amtfc,
    l_num_amount(13)  TYPE n,
    l_char_amount(17) TYPE c.

  l_format = id_t042z_formi.

  CALL FUNCTION 'FI_PAYM_FORMAT_READ_PROPERTIES'
    EXPORTING
      i_formi            = l_format
    IMPORTING
      e_tfpm042f         = ls_tfpm042f
    EXCEPTIONS
      not_found          = 1
      parameters_invalid = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CHECK NOT ls_tfpm042f-beanz IS INITIAL.

  IF ls_tfpm042f-beanz < 13.
    UNPACK id_amount TO l_num_amount(ls_tfpm042f-beanz).
    PACK l_num_amount(ls_tfpm042f-beanz) TO l_trunc_amount.

    IF l_trunc_amount NE id_amount.
      WRITE id_amount TO l_char_amount
            CURRENCY id_curr LEFT-JUSTIFIED.
      MESSAGE e129(fibl_rpcode)
        WITH l_char_amount id_curr id_paymethod l_format
        RAISING amount_too_large.
    ENDIF.
  ENDIF.

ENDFORM.                    " FIBL_CHECK_AMOUNT_FOR_FORMAT
*&---------------------------------------------------------------------*
*&      Form  find_partaccount_bank
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->is_RPCODE  text
*      <--is_accounts text
*----------------------------------------------------------------------*
FORM find_partaccount_bank USING    is_rpcode LIKE it_rpcode
                           CHANGING is_accounts TYPE bapi2021_accounts.
* selection from T018V
  DATA: ld_hbkid TYPE hbkid,
        ld_hktid TYPE hktid.
  DATA: lt_t018v LIKE t018v OCCURS 100 WITH HEADER LINE,
        ls_t012k TYPE t012k,
        ld-gehvk LIKE t018v-gehvk.
  DATA: ld_sland TYPE t018v-sland.

  ld_hbkid = is_rpcode-partn.
  ld_hktid = is_rpcode-parta.
  SELECT * FROM t018v INTO TABLE lt_t018v
      WHERE bukrs = is_rpcode-pbukr.

* find land of sending company code
  SELECT SINGLE land1 FROM t001 INTO ld_sland
    WHERE bukrs = is_rpcode-bukrs.

* first try with complete key
  LOOP AT lt_t018v
       WHERE bukrs = is_rpcode-pbukr
       AND   hbkid = ld_hbkid
       AND   zlsch = is_rpcode-zlsch
       AND   waers = is_rpcode-waers
       AND   hktid = ld_hktid
       AND   sland = ld_sland.
    EXIT.
  ENDLOOP.
  IF sy-subrc = 0.
    ld-gehvk = lt_t018v-gehvk.
  ENDIF.

  IF ld-gehvk = space.
*  "like 1. try but without land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = is_rpcode-waers
         AND   hktid = ld_hktid
         AND   sland = space.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
*  without hktid but with land
    LOOP AT lt_t018v
     WHERE bukrs = is_rpcode-pbukr
     AND   hbkid = ld_hbkid
     AND   zlsch = is_rpcode-zlsch
     AND   waers = is_rpcode-waers
     AND   hktid = space
     AND   sland = ld_sland.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without hktid, without land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = is_rpcode-waers
         AND   hktid = space
         AND   sland = space.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without currency, with hktid, with land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = space
         AND   hktid = ld_hktid
         AND   sland = ld_sland.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without currency, with hktid, without land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = space
         AND   hktid = ld_hktid
         AND   sland = space.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without currency, without hktid, with land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = space
         AND   hktid = space
         AND   sland = ld_sland.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without currency, without hktid, without land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = is_rpcode-zlsch
         AND   waers = space
         AND   hktid = space
         AND   sland = space.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without payment-method, without currency, without hktid, with land
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = space
         AND   waers = space
         AND   hktid = space
         AND   sland = ld_sland.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

  IF ld-gehvk = space.
* without currency, hktid, land and payment method
    LOOP AT lt_t018v
         WHERE bukrs = is_rpcode-pbukr
         AND   hbkid = ld_hbkid
         AND   zlsch = space
         AND   waers = space
         AND   hktid = space
         AND   sland = space.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      ld-gehvk = lt_t018v-gehvk.
    ENDIF.
  ENDIF.

* safety check
  DATA:ls_return TYPE bapiret2.
  IF ld-gehvk IS INITIAL.
    CLEAR:ls_return.
    ls_return-type = 'E'.
    ls_return-id = 'FIBL_RPCODE'.
    ls_return-number = '065'.
    ls_return-message_v1 = is_rpcode-pbukr.
    ls_return-message_v2 = ld_hbkid.
    ls_return-message_v3 = ld_hktid.
    ls_return-message_v4 = is_rpcode-zlsch.
    PERFORM add_to_log
  USING
    g_log_handle
    ls_return.
    gv_error = abap_true.

*    MESSAGE e065 WITH is_rpcode-pbukr
*                      ld_hbkid
*                      ld_hktid
*                      is_rpcode-zlsch.
  ELSE.
    is_accounts-partner_account = ld-gehvk.
    is_accounts-reconcil_account    = is_accounts-partner_account.
  ENDIF.

*---determin payrq-ggrup from T012K

  CALL FUNCTION 'FI_HOUSEBANK_ACCOUNT_READ'
    EXPORTING
      ic_bukrs = it_rpcode-pbukr
      ic_hbkid = ld_hbkid
      ic_hktid = ld_hktid
    IMPORTING
      es_t012k = ls_t012k.

  is_accounts-partner_acct_transfer = ls_t012k-hkont.

ENDFORM.                    " find_partaccount_bank
*&---------------------------------------------------------------------*
*&      Form  find_partaccount_cbp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->Is_RPCODE  text
*      <--iS_ACCOUNTS  text
*----------------------------------------------------------------------*
FORM find_partaccount_cbp USING    is_rpcode STRUCTURE it_rpcode
                          CHANGING is_accounts TYPE bapi2021_accounts.

  CALL FUNCTION 'FIBL_GET_PAYRQ_CLEARING_ACCT'
    EXPORTING
      im_comp_code      = is_rpcode-pbukr
    IMPORTING
      ex_parno          = is_accounts-partner_account
    EXCEPTIONS
      account_not_found = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  is_accounts-reconcil_account    = is_accounts-partner_account.

ENDFORM.                    " find_partaccount_cbp
*&---------------------------------------------------------------------*
*&      Form  fi_post_cbp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IS_RPCODE  text
*      -->IS_ACCOUNTS  text
*      -->is_t042z    method properties
*      -->id_gsber    business-area
*      <--ES_AMOUNTS  text
*      <--ES_CORRDOC  text
*----------------------------------------------------------------------*
FORM fi_post_cbp USING    is_rpcode STRUCTURE it_rpcode
                          is_accounts TYPE bapi2021_accounts
                          is_t042z STRUCTURE t042z
                          id_gsber
                 CHANGING es_amounts TYPE bapi2021_amounts
                          es_corrdoc TYPE bapi2021_corrdoc
                          es_references TYPE bapi2021_references.

  DATA: ld_einz TYPE xeinz.
  DATA: ld_blart TYPE blart.
  DATA: ld_postkey TYPE bschl.
  DATA: ls_post_data TYPE fibl_opay_doc_if.
  DATA: ls_return TYPE bapiret2.
  DATA: ls_bp001 TYPE bp001.                                "536667
  DATA: ld_partner TYPE bp000-partnr.                       "536667
  DATA: badi_references TYPE fibl_opay_badi_payrq_ref.
  DATA: ld_trade_id TYPE rassc.
  DATA: p_return TYPE bapireturn.

  ld_einz = is_t042z-xeinz.
  ld_blart = is_t042z-blart.

* .....post FI-document
*determine posting key for the suspense line item
  CLEAR ld_postkey.
  IF ld_einz IS INITIAL.
    SELECT SINGLE bssso FROM t041a INTO ld_postkey
           WHERE auglv = 'AUSGZAHL'.
    IF sy-subrc NE 0 OR ld_postkey IS INITIAL.
      MESSAGE e112(fibl_rpcode) WITH 'T041A' 'AUSGZAHL' 'BSSSO'.
    ENDIF.
  ELSE.
    SELECT SINGLE bssha FROM t041a INTO ld_postkey
           WHERE auglv = 'EINGZAHL'.
    IF sy-subrc NE 0 OR ld_postkey IS INITIAL.
      MESSAGE e112(fibl_rpcode) WITH 'T041A' 'EINGZAHL' 'BSSHA'.
    ENDIF.
  ENDIF.
* fill structure ls_post_data
  ls_post_data-comp_code = is_rpcode-pbukr.
  ls_post_data-doc_type = ld_blart.
  IF fibl_mainpay_101-pstng_date IS INITIAL.
    ls_post_data-pstng_date = sy-datlo.
  ELSE.
    ls_post_data-pstng_date = fibl_mainpay_101-pstng_date.
  ENDIF.
  ls_post_data-paym_curr = is_rpcode-waers.
* IF es_amounts-paym_amount < 0.
*   ls_post_data-paym_amount = es_amounts-paym_amount * -1.
* ELSE.
*   ls_post_data-paym_amount = es_amounts-paym_amount.
* ENDIF.
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INT_31' " AFLE
    EXPORTING
      currency             = es_amounts-paym_curr
      amount_external      = es_amounts-paym_amount_long " AFLE
      max_number_of_digits = '23' " AFLE
    IMPORTING
      amount_internal      = ls_post_data-paym_amount
      return               = p_return.
  CHECK p_return IS INITIAL.
  IF es_amounts-paym_amount_long < 0.
    ls_post_data-paym_amount = ls_post_data-paym_amount * -1.
  ENDIF.

  ls_post_data-xincoming_pmnt = ld_einz.
  ls_post_data-partner_account = is_accounts-partner_account.
  ls_post_data-item_text = is_rpcode-rp_text.
  ls_post_data-bus_area_bank = id_gsber.
  ls_post_data-debited_acct = is_rpcode-hkont.
  ls_post_data-post_key = ld_postkey.
  ls_post_data-bus_area = is_rpcode-gsber.
  ls_post_data-value_date_sender = reguh-valut.
  ls_post_data-acct_type = 'S'.

* begin of H536667
* get company_id (vbund) for business partner
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_rpcode-partn
    IMPORTING
      output = ld_partner.

  CALL FUNCTION 'FSBP_READ_BP001'
    EXPORTING
      i_partner             = ld_partner
    IMPORTING
      e_bp001               = ls_bp001
    EXCEPTIONS
      partner               = 1
      partner_not_released  = 2
      wrong_parameters      = 3
      data_for_data_not_act = 4
      OTHERS                = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_post_data-trade_id = ls_bp001-vbund.
* end of H536667

* Call function module for posting
  CALL FUNCTION 'FIBL_OPAY_POST'
    EXPORTING
      ims_post_data        = ls_post_data
    IMPORTING
      exs_return           = ls_return
      exs_document         = es_corrdoc
      exs_payrq_references = badi_references
    CHANGING
      chs_amounts          = es_amounts.

  ld_trade_id = es_references-trade_id.
  MOVE-CORRESPONDING badi_references TO es_references.
  es_references-trade_id = ld_trade_id.

*-- write the message from the posting interface to the log ---
  PERFORM add_to_log
    USING
      g_log_handle
      ls_return.

ENDFORM.                    " fi_post_cbp
*&---------------------------------------------------------------------*
*&      Form  get_address_bank
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->Is_RPCODE  text
*      <--eT_ADDRESS_DATA  text
*----------------------------------------------------------------------*
FORM get_address_bank USING    is_rpcode STRUCTURE it_rpcode
                      CHANGING et_address_data TYPE yt_address_data.
  DATA: ls_addr1_sel LIKE addr1_sel.
  DATA: ls_sadr LIKE sadr.
  DATA: wa_address_data TYPE LINE OF yt_address_data.
  DATA: ls_t001 LIKE t001.
* read company code information for address
  CALL FUNCTION 'FI_COMPANY_CODE_DATA'
    EXPORTING
      i_bukrs      = is_rpcode-pbukr
    IMPORTING
      e_t001       = ls_t001
    EXCEPTIONS
      system_error = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  ls_addr1_sel-addrnumber = ls_t001-adrnr.
  IF NOT ls_t001-adrnr IS INITIAL.
    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = ls_addr1_sel
        address_group     = 'CA01'
      IMPORTING
        sadr              = ls_sadr
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.
    IF sy-subrc = 0.
* address found
      PERFORM move_adress_data
              USING ls_sadr
              CHANGING wa_address_data.
    ENDIF.
  ENDIF.

* no adr given in T001, or no information for adr found
  IF wa_address_data-name IS INITIAL.
    wa_address_data-name = ls_t001-butxt.
  ENDIF.
  IF wa_address_data-city IS INITIAL
     OR wa_address_data-country IS INITIAL.
    wa_address_data-city = ls_t001-ort01.
    wa_address_data-country = ls_t001-land1.
  ENDIF.
  IF wa_address_data-langu IS INITIAL.
    wa_address_data-langu = ls_t001-spras.
  ENDIF.
*  wa_address_data-partner_role = '02'.
*  APPEND wa_address_data TO et_address_data.
  wa_address_data-partner_role = '01'.
  APPEND wa_address_data TO et_address_data.

  IF 1 = 2.                                              " note 1625102

* payee / Zahlungsempfänger
    DATA: l_hbkid         LIKE t012-hbkid,
          l_hktid         LIKE t012k-hktid,
          l_t012          TYPE t012,
          l_bnka          TYPE bnka,
          wb_address_data LIKE wa_address_data.

    l_hbkid = is_rpcode-partn.
    l_hktid = is_rpcode-parta.
    CALL FUNCTION 'FI_HOUSEBANK_READ'
      EXPORTING
        ic_bukrs = is_rpcode-pbukr
        ic_hbkid = l_hbkid
      IMPORTING
        es_t012  = l_t012.

    CALL FUNCTION 'READ_BANK_ADDRESS'
      EXPORTING
        bank_country = l_t012-banks
        bank_number  = l_t012-bankl
      IMPORTING
        bnka_wa      = l_bnka
      EXCEPTIONS
        OTHERS       = 0.

    IF l_bnka-adrnr IS NOT INITIAL.
      ls_addr1_sel-addrnumber = l_bnka-adrnr.
      CALL FUNCTION 'ADDR_GET'
        EXPORTING
          address_selection = ls_addr1_sel
          address_group     = 'CA01'
        IMPORTING
          sadr              = ls_sadr
        EXCEPTIONS
          parameter_error   = 1
          address_not_exist = 2
          version_not_exist = 3
          internal_error    = 4
          OTHERS            = 5.
      IF sy-subrc = 0.
        PERFORM move_adress_data
                USING ls_sadr
                CHANGING wb_address_data.
      ENDIF.
    ENDIF.
    IF wb_address_data-name IS INITIAL.
      wb_address_data-name       = l_bnka-banka.
    ENDIF.
    IF wb_address_data-street IS INITIAL.
      wb_address_data-street     = l_bnka-stras.
    ENDIF.
    IF wb_address_data-city IS INITIAL
    OR wb_address_data-country IS INITIAL.
      wb_address_data-city       = l_bnka-ort01.
      wb_address_data-country    = l_t012-banks.
    ENDIF.
    IF wb_address_data-langu IS INITIAL.
      wb_address_data-langu      = l_t012-spras.
    ENDIF.
* wb_address_data = wa_address_data.
    wb_address_data-partner_role = '02'.
    APPEND wb_address_data TO et_address_data.

  ELSE.                                                  " note 1625102

    wa_address_data-partner_role = '02'.
    APPEND wa_address_data TO et_address_data.

  ENDIF.                                                 " note 1625102

ENDFORM.                    " get_address_bank
*&---------------------------------------------------------------------*
*&      Form  get_address_cbp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->is_RPCODE  text
*      <--eT_ADDRESS_DATA  text
*----------------------------------------------------------------------*
FORM get_address_cbp USING    is_rpcode STRUCTURE it_rpcode
                     CHANGING et_address_data TYPE yt_address_data.
  DATA: wa_address_data TYPE LINE OF yt_address_data.
  DATA: ls_sadr LIKE sadr.
  DATA: ls_but000 TYPE but000.
  DATA  lt_bus020_ext TYPE TABLE OF bus020_ext.
  DATA  ls_bus020_ext TYPE bus020_ext.
  DATA: ld_partner TYPE bp000-partner.
  DATA  ld_title_text LIKE tsad3t-title_medi.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = is_rpcode-partn
    IMPORTING
      output = ld_partner.

* read address-data
* name and title
  CALL FUNCTION 'FSBP_READ_BUT000'
    EXPORTING
      i_partner        = ld_partner
    IMPORTING
      e_but000         = ls_but000
    EXCEPTIONS
      wrong_parameters = 1
      no_data_found    = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* convert title  according to sy-language
  IF NOT ls_but000-title IS INITIAL.
    CALL FUNCTION 'ADDR_TSAD3T_READ'
      EXPORTING
        title_key            = ls_but000-title
      IMPORTING
        title_text           = ld_title_text
      EXCEPTIONS
        title_text_not_found = 1
        title_key_not_found  = 2
        OTHERS               = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    ls_sadr-anred = ld_title_text.
  ENDIF.

  CASE ls_but000-type.
    WHEN '1'.            "Person
      ls_sadr-name1 = ls_but000-name_last.
      ls_sadr-name2 = ls_but000-name_first.
      ls_sadr-name3 = ls_but000-name_lst2.
      ls_sadr-name4 = ls_but000-name_last2.
    WHEN '2'.            "organization
      ls_sadr-name1 = ls_but000-name_org1.
      ls_sadr-name2 = ls_but000-name_org2.
      ls_sadr-name3 = ls_but000-name_org3.
      ls_sadr-name4 = ls_but000-name_org4.
  ENDCASE.

* rest of address (city, street etc..)
  CALL FUNCTION 'FSBP_DBREAD_ADDRESS_GET_ALL'
    EXPORTING
      i_partner = ld_partner
    TABLES
      t_address = lt_bus020_ext.

*  LOOP AT lt_bus020_ext INTO ls_bus020_ext
*      WHERE xdfadr = true.
*  ENDLOOP.
  READ TABLE lt_bus020_ext INDEX 1 INTO ls_bus020_ext.

  IF sy-subrc = 0.
    ls_sadr-stras = ls_bus020_ext-street.
    ls_sadr-pfach = ls_bus020_ext-po_box.
    ls_sadr-pstl2 = ls_bus020_ext-post_code2.
    ls_sadr-land1 = ls_bus020_ext-country.
    ls_sadr-pstlz = ls_bus020_ext-post_code1.
    ls_sadr-ort01 = ls_bus020_ext-city1.
    ls_sadr-regio = ls_bus020_ext-region.
    ls_sadr-spras = ls_bus020_ext-langu.
    ls_sadr-adrnr = ls_bus020_ext-addrnumber.
    ls_sadr-telf1 = ls_bus020_ext-tel_number.
  ENDIF.

* save address
  PERFORM move_adress_data
  USING  ls_sadr
  CHANGING wa_address_data.
  wa_address_data-partner_role = '02'.
  wa_address_data-partner = ld_partner.
  APPEND wa_address_data TO et_address_data.
  wa_address_data-partner_role = '01'.
  APPEND wa_address_data TO et_address_data.

ENDFORM.                    " get_address_cbp
*&---------------------------------------------------------------------*
*&      Form  move_adress
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_SADR  text
*      <--P_WA_ADDRESS_DATA  text
*----------------------------------------------------------------------*
FORM move_adress_data
      USING  is_sadr STRUCTURE sadr
      CHANGING es_wa_address TYPE LINE OF yt_address_data.
  es_wa_address-formofaddr = is_sadr-anred.
  es_wa_address-name = is_sadr-name1.
  es_wa_address-name_2 = is_sadr-name2.
  es_wa_address-name_3 = is_sadr-name3.
  es_wa_address-name_4 = is_sadr-name4.
  es_wa_address-postl_code = is_sadr-pstlz.
  es_wa_address-city = is_sadr-ort01.
  es_wa_address-pobx_pcd = is_sadr-pstl2.
  es_wa_address-street = is_sadr-stras.
  es_wa_address-po_box = is_sadr-pfach.
  es_wa_address-country = is_sadr-land1.
  es_wa_address-region = is_sadr-regio.
  es_wa_address-langu = is_sadr-spras.
  es_wa_address-addr_no = is_sadr-adrnr.
  es_wa_address-telephone = is_sadr-telf1.

ENDFORM.                    " move_adress
*&---------------------------------------------------------------------*
*&      Form  TRANSLATE_LC_AMOUNT
*&---------------------------------------------------------------------*
*       Translation if an exchange rate type other than 'M' was entered
*
*       Created with note 2926616
*----------------------------------------------------------------------*
*      -->P_KURST  Entered exchange rate type
*      -->P_WAERS  Local currency key from used company code
*      <--P_AMOUNTS  Structure which contains the PAYRQ amounts
*      <--P_PAYM_CONTROL Structure which contains the XKDFB flag
*      <->P_RFTXT   Table for PAYRQT
*----------------------------------------------------------------------*
FORM translate_lc_amount TABLES   p_rftxt STRUCTURE bapi2021_reftext
                          USING    p_kurst TYPE kurst_regu
                                   p_hwaer TYPE waers
                          CHANGING p_amounts TYPE bapi2021_amounts
                                   p_paym_control TYPE bapi2021_paymentctrl.

  DATA ls_rftxt TYPE bapi2021_reftext.

  IF p_hwaer IS NOT INITIAL
  AND p_hwaer NE p_amounts-paym_curr
  AND p_kurst IS NOT INITIAL
  AND p_kurst NE 'M'.

    p_amounts-loc_currcy = p_hwaer.

    CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
      EXPORTING
        date             = sy-datum
        foreign_amount   = p_amounts-paym_amount_long
        foreign_currency = p_amounts-paym_curr
        local_currency   = p_hwaer
        type_of_rate     = p_kurst
      IMPORTING
        local_amount     = p_amounts-lc_amount_long.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXT_31'
      EXPORTING
        currency        = p_amounts-loc_currcy
        amount_internal = p_amounts-lc_amount_long
      IMPORTING
        amount_external = p_amounts-lc_amount_long.

*   No exchange rate differences to post in payment program
    p_paym_control-no_exchange_rate_diff = 'X'.

*   Save the used exchange rate type in PAYRQT
    ls_rftxt-ref_type   =  'I'.
    ls_rftxt-ref_number =  '0001'.
    ls_rftxt-format_col =  'KT'.
    ls_rftxt-ref_text = p_kurst.
    APPEND ls_rftxt TO p_rftxt.

  ENDIF.
ENDFORM.                    "translate_lc_amount
*&---------------------------------------------------------------------*
*&      Form  get_parameter_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_parameter_100.
  GET PARAMETER:
       ID 'BUK' FIELD fibl_rpcode-bukrs,
       ID 'HBK' FIELD fibl_rpcode-hbkid.

  CLEAR: gs_t001, gs_t012, gs_bnka.
  IF fibl_rpcode-bukrs NE space.
* read company code
    CALL FUNCTION 'FI_COMPANY_CODE_DATA'
      EXPORTING
        i_bukrs = fibl_rpcode-bukrs
      IMPORTING
        e_t001  = gs_t001
      EXCEPTIONS
        OTHERS  = 0.
    t001-butxt = gs_t001-butxt.
* read housebank
    IF ( sy-subrc = 0 AND fibl_rpcode-hbkid NE space ).
      CALL FUNCTION 'FI_HOUSEBANK_CHECK_EXISTENCE'
        EXPORTING
          company   = fibl_rpcode-bukrs
          bankid    = fibl_rpcode-hbkid
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc = 0.
        CALL FUNCTION 'FI_HOUSEBANK_READ'
          EXPORTING
            ic_bukrs = fibl_rpcode-bukrs
            ic_hbkid = fibl_rpcode-hbkid
          IMPORTING
            es_t012  = gs_t012.

        CALL FUNCTION 'READ_BANK_ADDRESS'
          EXPORTING
            bank_country = gs_t012-banks
            bank_number  = gs_t012-bankl
          IMPORTING
            bnka_wa      = gs_bnka
          EXCEPTIONS
            OTHERS       = 0.
        bnka-banka = gs_bnka-banka.
      ENDIF.                                                "hbkid ok ?
    ENDIF.                                                  "bukrs ok ?
  ENDIF.                                                    "bukrs

* initial date
  IF reguh-valut IS INITIAL.
    reguh-valut = sy-datlo.
  ENDIF.

  IF fibl_mainpay_101-pstng_date IS INITIAL.
    IF frft_bank_rep-xkdfb IS INITIAL.                      "n1721242
      fibl_mainpay_101-pstng_date = sy-datlo.
    ELSE.                                                   "n1721242
      fibl_mainpay_101-pstng_date = reguh-valut.            "n1721242
    ENDIF.                                                  "n1721242
  ENDIF.

* Begin of note 2926616
  IF gv_xinitial IS INITIAL.
    DATA ls_tfbuf TYPE tfbuf.
    gv_xinitial = 'X'.

    SELECT SINGLE * FROM tfbuf INTO ls_tfbuf
                    WHERE usnam EQ sy-uname
                    AND   applk EQ 'RP'
                    AND   lfdnr EQ '001'.
    IF sy-subrc = 0.
      kurst_prq = ls_tfbuf-buffr(4).
      gv_kurst_tcurv = kurst_prq.
    ENDIF.
  ENDIF.
* End of note 2926616

ENDFORM.                               " get_parameter_100
*&---------------------------------------------------------------------*
*&      Form  open_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_log CHANGING ex_log_handle TYPE balloghndl.

  DATA:
    ls_log    TYPE bal_s_log.

  ls_log-aluser    = sy-uname.

* first check, whether log already exists

  CALL FUNCTION 'BAL_LOG_EXIST'
    EXPORTING
      i_log_handle  = ex_log_handle
    EXCEPTIONS
      log_not_found = 1
      OTHERS        = 2.
  IF sy-subrc NE  0.
* does not yet exist => create
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = ex_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.

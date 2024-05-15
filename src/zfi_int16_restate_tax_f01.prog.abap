*&---------------------------------------------------------------------*
*& Include          ZFI_INT16_RESTATE_TAX_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form file_selection_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_selection_f4 .
  DATA: gt_filetab  TYPE filetable,
        gs_filetab  TYPE file_table,
        g_fo_title  TYPE string,
        g_fo_rc     TYPE i,
        g_fo_action TYPE i.

  g_fo_title = TEXT-fo1.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = g_fo_title
*     file_filter             = '(*.csv*)' "#EC NOTEXT
    CHANGING
      file_table              = gt_filetab
      rc                      = g_fo_rc
      user_action             = g_fo_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc = 0 AND
     g_fo_action = cl_gui_frontend_services=>action_ok.
*   get file name
    READ TABLE gt_filetab INDEX 1 INTO gs_filetab.
    IF sy-subrc = 0.
      p_file  = gs_filetab-filename.
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
*  TRY.
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = abap_false
      filemask         = '?'
    IMPORTING
      serverfile       = p_dir
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
*& Form read_file_from_pc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_file_from_pc .
  DATA lv_file TYPE string.
  lv_file = p_file.

*  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  DATA  : lt_itab1        TYPE truxs_t_text_data,
          lt_records      TYPE solix_tab,
          lv_headerstring TYPE xstring,
          lv_filelgth     TYPE i.

  FIELD-SYMBOLS : <gt_data> TYPE STANDARD TABLE.
  CONSTANTS : lc_a TYPE c LENGTH 1 VALUE 'A',
              lc_b TYPE c LENGTH 1 VALUE 'B',
              lc_c TYPE c LENGTH 1 VALUE 'C',
              lc_d TYPE c LENGTH 1 VALUE 'D',
              lc_e TYPE c LENGTH 1 VALUE 'E',
              lc_f TYPE c LENGTH 1 VALUE 'F',
              lc_g TYPE c LENGTH 1 VALUE 'G',
              lc_h TYPE c LENGTH 1 VALUE 'H',
              lc_i TYPE c LENGTH 1 VALUE 'I',
              lc_j TYPE c LENGTH 1 VALUE 'J',
              lc_k TYPE c LENGTH 1 VALUE 'K',
              lc_l TYPE c LENGTH 1 VALUE 'L',
              lc_m TYPE c LENGTH 1 VALUE 'M',
              lc_n TYPE c LENGTH 1 VALUE 'N'.


  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename            = lv_file
      filetype            = 'ASC'
      has_field_separator = abap_true
    CHANGING
      data_tab            = gt_file
    EXCEPTIONS
      file_open_error     = 1.
  IF sy-subrc EQ 0.
    DELETE gt_file INDEX 1.
  ENDIF.
*  CALL FUNCTION 'GUI_UPLOAD'
*    EXPORTING
*      filename                = lv_file
*      filetype                = 'ASC'
*      has_field_separator     = abap_true
*    IMPORTING
*      filelength              = lv_filelgth
*      header                  = lv_headerstring
*    TABLES
*      data_tab                = lt_records
** CHANGING
**     ISSCANPERFORMED         = ' '
*    EXCEPTIONS
*      file_open_error         = 1
*      file_read_error         = 2
*      no_batch                = 3
*      gui_refuse_filetransfer = 4
*      invalid_type            = 5
*      no_authority            = 6
*      unknown_error           = 7
*      bad_data_format         = 8
*      header_not_allowed      = 9
*      separator_not_allowed   = 10
*      header_too_long         = 11
*      unknown_dp_error        = 12
*      access_denied           = 13
*      dp_out_of_memory        = 14
*      disk_full               = 15
*      dp_timeout              = 16
*      OTHERS                  = 17.
*  IF sy-subrc <> 0.
**** Implement suitable error handling here
*  ENDIF.
*
*  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
*    EXPORTING
*      input_length = lv_filelgth
*      first_line   = 0
*      last_line    = 0
*    IMPORTING
*      buffer       = lv_headerstring
*    TABLES
*      binary_tab   = lt_records
*    EXCEPTIONS
*      failed       = 1
*      OTHERS       = 2.
*  IF sy-subrc <> 0.
**** Implement suitable error handling here
*  ENDIF.
*
*  IF lv_headerstring IS NOT INITIAL.
*
*    DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.
*
*    DATA(lx_excel_core) = NEW cx_fdt_excel_core( ).
*
*    TRY.
*        lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
*                              document_name = lv_file
*                              xdocument = lv_headerstring ).
*
*
*      CATCH cx_fdt_excel_core INTO lx_excel_core.
*        DATA(lv_msg) = lx_excel_core->if_message~get_text( ).
*    ENDTRY.
*
*    "Get list of worksheets
*    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
*    IMPORTING
*      worksheet_names = DATA(lt_worksheets) ).
*
*    IF NOT lt_worksheets IS INITIAL.
*      READ TABLE lt_worksheets INTO DATA(ls_worksheets) INDEX 1.
*
*      DATA(lo_data_ref) = lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
*                                                                    ls_worksheets ).
*      ASSIGN lo_data_ref->* TO <gt_data>.
*    ENDIF.
*
*
*    DATA(lv_row) = 1.
*
*    LOOP AT <gt_data> ASSIGNING FIELD-SYMBOL(<fs_data>) FROM lv_row.
*
*      ASSIGN COMPONENT lc_a OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_fld_val>).
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-prcl_year = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_b OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-tax_typ = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_c OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-tax_billid = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_d OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-prcel = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_e OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-exprt_no = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_f OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-allc_dbtgl = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_g OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-proprty_id = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_h OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-period_end = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_i OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-period_accural = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_j OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-prcl_text = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_k OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-txbill_no = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_l OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-paymnt_mthd = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_m OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-clint_fyr = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      ASSIGN COMPONENT lc_n OF STRUCTURE <fs_data> TO <fs_fld_val>.
*      IF <fs_fld_val> IS ASSIGNED.
*        gs_file-clint_fpr = <fs_fld_val>.
*        CLEAR <fs_fld_val>.
*      ENDIF.
*
*      APPEND gs_file TO gt_file.
*      CLEAR gs_file.
*    ENDLOOP.
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_file_from_al11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM  read_file_from_al11 .
  DATA : lv_string    TYPE string,
         lv_str       TYPE xstring,
         lv_str1      TYPE xstring,
         lt_dir       TYPE TABLE OF epsfili,
         lv_dir       TYPE epsf-epsdirnam,
         lv_archive   TYPE sapb-sappfad,
         lv_source    TYPE sapb-sappfad,
         lv_file      TYPE string,
         lv_new(2000) TYPE c,
         lv_chk       TYPE c.
  CONSTANTS: c_cr  TYPE abap_char1 VALUE cl_abap_char_utilities=>cr_lf,
             c_tab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
  CLEAR lv_dir.
  lv_dir = p_dir.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = lv_dir
    TABLES
      dir_list               = lt_dir
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  DATA(lv_dirc) = p_dir.
  LOOP AT lt_dir INTO DATA(ls_dir).
*    TRANSLATE ls_dir-name TO LOWER CASE.
    IF ls_dir-name CS '.txt'.
      CONCATENATE ls_dir-name+6(4) ls_dir-name+0(2) ls_dir-name+3(2) INTO gv_budat.
      CONCATENATE p_dir ls_dir-name INTO p_dir.
      OPEN DATASET p_dir FOR INPUT IN LEGACY TEXT MODE CODE PAGE '1160'.
      IF sy-subrc EQ 0.
        DO.
          READ DATASET p_dir INTO lv_string.
          CONDENSE lv_string.
          IF sy-subrc EQ 0 AND lv_string IS NOT INITIAL.
            SPLIT lv_string AT c_tab INTO
                  gs_file-prcl_year
                  gs_file-tax_typ
                  gs_file-tax_billid
                  gs_file-prcel
                  gs_file-exprt_no
                  gs_file-allc_dbtgl
                  gs_file-proprty_id
                  gs_file-period_end
                  gs_file-period_accural
                  gs_file-prcl_text
                  gs_file-txbill_no
                  gs_file-paymnt_mthd
                  gs_file-clint_fyr
                  gs_file-clint_fpr.
            REPLACE c_cr WITH space INTO gs_file-clint_fpr.
            APPEND gs_file TO gt_file.
            CLEAR:gs_file.
          ELSE.
            EXIT.
          ENDIF.
        ENDDO.
      ELSE.
        CONCATENATE 'Error opening file'
                     p_dir
                 INTO DATA(lv_msg).
        MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
*    ENDIF.
      DELETE gt_file INDEX 1.
      CLOSE DATASET p_dir.

      CLEAR : lv_archive, lv_source.
      lv_source = lv_archive = p_dir.
      REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.

      OPEN DATASET p_dir FOR INPUT IN LEGACY TEXT MODE CODE PAGE '1160'.
      OPEN DATASET lv_archive FOR OUTPUT IN LEGACY TEXT MODE CODE PAGE '1160'.
      DO.
        CLEAR lv_str.
        READ DATASET p_dir INTO lv_new.
        IF sy-subrc EQ 0.
          TRANSFER lv_new TO lv_archive.
        ELSE.
          IF lv_new IS NOT INITIAL.
            TRANSFER lv_new TO lv_archive.
          ENDIF.
          EXIT.
        ENDIF.
      ENDDO.
      CLOSE DATASET p_dir.
      CLOSE DATASET lv_archive.
      DELETE DATASET p_dir.
      ""Begin SCHITTADI ++
      DATA(lr_proc) = NEW zcl_int16_restate_tax_accural( ).

      CALL METHOD lr_proc->post_document
        EXPORTING
          gt_file   = gt_file
          gv_blart  = p_doc
          gv_dl     = p_dl
          gv_taxgl  = p_gl
          gv_budat  = gv_budat
        IMPORTING
          gt_return = DATA(gt_return).
*    MESSAGE 'Process is complete' TYPE 'S'.
      REFRESH gt_file.
      CLEAR : p_dir.
      p_dir = lv_dirc.
    ENDIF.
    ""End of SCHITTADI++
  ENDLOOP.
*ENDIF.
*ENDIF.
ENDFORM.

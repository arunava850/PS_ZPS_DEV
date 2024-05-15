*&---------------------------------------------------------------------*
*& Include          ZFI_WC_S4_TENANT_REFUND_F01
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
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory  = '/interfaces/RAMP/inbound'
*     FILEMASK   = ' '
    IMPORTING
      serverfile = p_dir
* EXCEPTIONS
*     CANCELED_BY_USER       = 1
*     OTHERS     = 2
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
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

  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  DATA lt_itab1 TYPE truxs_t_text_data.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file
*     filetype                = 'ASC'
*     HAS_FIELD_SEPARATOR     = ','
    CHANGING
      data_tab                = lt_itab1
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
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
*     i_delimiter = '"' "c_default_delimiter
      i_separator = ',' "c_default_separator
*     i_escape    =
*     i_line_separator = CL_ABAP_CHAR_UTILITIES=>NEWLINE
    RECEIVING
      r_r_conv    = lo_csv.

  LOOP AT lt_itab1 INTO DATA(ls_dat1).
    CALL METHOD lo_csv->csv_to_structure
      EXPORTING
        i_data   = ls_dat1
      IMPORTING
        e_s_data = gs_file.
    APPEND gs_file TO gt_file.
    CLEAR gs_file.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_file_from_al11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM read_file_from_al11 .
  DATA : lv_str TYPE string.
  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
*     i_delimiter = '"' "c_default_delimiter
      i_separator = ',' "c_default_separator
*     i_escape    =
*     i_line_separator = CL_ABAP_CHAR_UTILITIES=>NEWLINE
    RECEIVING
      r_r_conv    = lo_csv.

  OPEN DATASET p_dir FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  DO.
    CLEAR lv_str.
    READ DATASET p_file INTO lv_str.
    IF sy-subrc EQ 0.
      CALL METHOD lo_csv->csv_to_structure
        EXPORTING
          i_data   = lv_str
        IMPORTING
          e_s_data = gs_file.
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_file .
  data : lv_prctr TYPE prctr.
  delete gt_file INDEX 1.
  delete gt_file WHERE refnd_typ = 'DTM Refund'.
  LOOP AT gt_file INTO gs_file.
    CLEAR gs_data.
    gs_data-xblnr = gs_file-ztran_id.
*    gs_data-sortl = gs_file-zcsrtyp.
    gs_data-cr_amnt = gs_file-tot_refund.
*    gs_data-prctr = gs_file-zsiteno.
    gs_data-zsiteno = gs_file-zsiteno.
    CLEAR lv_prctr.
    lv_prctr = gs_file-zsiteno.
gs_data-prctr = lv_prctr = |{ lv_prctr ALPHA = IN }|.
    gs_data-zcontactid = gs_file-zcontactid.
    SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs  WHERE prctr = lv_prctr.
    gs_data-lifnr = gs_file-zsuppl_no.
    gs_data-dr_amnt = gs_file-refnd_line_amnt.
    gs_data-zuonr = gs_file-custmr_unt.
    DATA(lv_mm) = gs_file-date+5(2).
    DATA(lv_dd) = gs_file-date+8(2).
    DATA(lv_yy) = gs_file-date+0(4).
*    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-bldat.
    gs_data-bldat = sy-datum.
    gs_data-bktxt = gs_file-refnd_typ.
    SELECT SINGLE hkont FROM zfi_aai_gl_tab INTO gs_data-saknr WHERE zcostcode = gs_file-wc_code.
    gs_data-budat = sy-datum.
    gs_data-blart = 'ZW'.
    APPEND gs_data TO gt_data.
    CLEAR : gs_data, gs_file.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
  "Instantiation
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = DATA(lo_alv)
    CHANGING
      t_table      = gt_ret2 ).

  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Display the ALV Grid
  lo_alv->display( ).
ENDFORM.

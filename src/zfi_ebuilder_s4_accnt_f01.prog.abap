*&---------------------------------------------------------------------*
*& Include          ZFI_EBUILDER_S4_ACCNT_F01
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
      directory        = '/interfaces/ebuilder/INT0006/in'
*     FILEMASK         = ' '
    IMPORTING
      serverfile       = p_dir
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
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
      i_delimiter = '"' "c_default_delimiter
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

    CALL METHOD lo_csv->csv_to_structure
      EXPORTING
        i_data   = ls_dat1
      IMPORTING
        e_s_data = gs_filefull.
    APPEND gs_filefull TO gt_filefull.
    CLEAR gs_filefull.

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
  DATA : lv_str     TYPE string,
         lt_dir     TYPE TABLE OF epsfili,
         lv_dir     TYPE epsf-epsdirnam,
         lv_archive TYPE sapb-sappfad,
         lv_source  TYPE sapb-sappfad.
  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
      i_delimiter = '"' "c_default_delimiter
      i_separator = ',' "c_default_separator
*     i_escape    =
*     i_line_separator = CL_ABAP_CHAR_UTILITIES=>NEWLINE
    RECEIVING
      r_r_conv    = lo_csv.
  CLEAR lv_dir.
  lv_dir = p_dir.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = lv_dir
*     FILE_MASK              = ' '
*   IMPORTING
*     DIR_NAME               =
*     FILE_COUNTER           =
*     ERROR_COUNTER          =
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
  LOOP AT lt_dir INTO DATA(ls_dir).
    IF ls_dir-name CS '.csv'.
      CONCATENATE p_dir ls_dir-name INTO p_dir.

      OPEN DATASET p_dir FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      DO.
        CLEAR lv_str.
        READ DATASET p_dir INTO lv_str.
        IF sy-subrc EQ 0.
          CALL METHOD lo_csv->csv_to_structure
            EXPORTING
              i_data   = lv_str
            IMPORTING
              e_s_data = gs_file.
          APPEND gs_file TO gt_file.
          CLEAR gs_file.

          CALL METHOD lo_csv->csv_to_structure
            EXPORTING
              i_data   = lv_str
            IMPORTING
              e_s_data = gs_filefull.
          APPEND gs_filefull TO gt_filefull.
          CLEAR gs_filefull.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      CLOSE DATASET p_dir.
      IF gt_file IS NOT INITIAL.
        CLEAR : lv_archive, lv_source.
        lv_source = lv_archive = p_dir.
        REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.
*    CALL FUNCTION 'ARCHIVFILE_SERVER_TO_SERVER'
*      EXPORTING
*        sourcepath       = lv_source
*        targetpath       = lv_archive
** IMPORTING
**       LENGTH           =
*      EXCEPTIONS
*        error_file       = 1
*        no_authorization = 2
*        OTHERS           = 3.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.

        OPEN DATASET p_dir FOR INPUT IN TEXT MODE ENCODING DEFAULT.
        OPEN DATASET lv_archive FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        DO.
          CLEAR lv_str.
          READ DATASET p_dir INTO lv_str.
          IF sy-subrc EQ 0.
            TRANSFER lv_str TO lv_archive.
          ELSE.
            IF lv_str IS NOT INITIAL.
              TRANSFER lv_str TO lv_archive.
            ENDIF.
            EXIT.
          ENDIF.
        ENDDO.
        CLOSE DATASET p_dir.
        CLOSE DATASET lv_archive.

        DELETE DATASET p_dir.
      ENDIF.
    ENDIF.
  ENDLOOP.
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
  DATA  :lv_amnt  TYPE p DECIMALS 2,
         lv_prctr TYPE prctr.
  DELETE gt_file INDEX 1.
  LOOP AT gt_file INTO gs_file.
*    gs_data-prctr = .
    CLEAR lv_prctr.
    gs_data-costctr = gs_file-costctr.
    lv_prctr = gs_file-costctr+2(8).
    lv_prctr = |{ lv_prctr ALPHA = IN }|.
    SELECT SINGLE prctr FROM csks INTO gs_data-prctr WHERE kokrs = 'PSCO' AND kostl = lv_prctr.
    IF sy-subrc EQ 0.
      gs_data-prctr = gs_data-prctr.
    ELSE.
      gs_data-prctr = gs_file-costctr.
      gs_data-prctr = |{ gs_data-prctr ALPHA = IN }|.
    ENDIF.
    gs_data-zuonr = gs_file-job_no.
    gs_data-bktxt = gs_file-commit_no.
    gs_data-xblnr =  gs_file-inv_no.
    DATA(lv_yy) = gs_file-inv_dat+0(4).
    DATA(lv_mm) = gs_file-inv_dat+5(2).
    DATA(lv_dd) = gs_file-inv_dat+8(2).
    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-bldat.
*     = gs_file-inv_dat.
    gs_data-text50 = gs_file-inv_itm_des.
    CLEAR : lv_amnt, lv_prctr.
*    lv_prctr = gs_file-costctr.
*    gs_data-prctr = |{ lv_prctr ALPHA = IN }|.
    REPLACE ',' IN gs_file-net_payinv WITH ' '.
    CONDENSE gs_file-net_payinv.
    lv_amnt =  gs_file-net_payinv.
    gs_data-znetpayinv = lv_amnt.
    gs_data-cost_code = gs_file-cost_code.
*    IF gs_file-cost_code CS 'D'.
*      SELECT SINGLE ktogr FROM anka INTO @DATA(lv_ktogr) WHERE anlkl = @p_ascl.
*      IF sy-subrc EQ 0.
*        SELECT SINGLE  ktansw FROM t095 INTO gs_data-hkont WHERE ktopl = 'PSUS' AND afabe = '01' AND ktogr = lv_ktogr.
*      ENDIF.
*    ELSE.
    READ TABLE gt_lookup INTO DATA(ls_gl) WITH KEY zintf_id = 'INT_RAMP' zcostcode = gs_file-cost_code.
    IF sy-subrc EQ 0.
      gs_data-hkont = ls_gl-hkont.
    ENDIF.
*    ENDIF.
*    gs_data-hkont  = gs_file-cost_code. ""USe cost_code for G/L account in lookup table
    CLEAR : lv_amnt.
    REPLACE ',' IN gs_file-net_payline WITH ' '.
    CONDENSE gs_file-net_payline.
    lv_amnt =  gs_file-net_payline.
    gs_data-znetpayline = lv_amnt.
*gs_data-BUKRS
    SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs WHERE prctr = gs_data-prctr.
    IF sy-subrc NE 0.
      DATA(lv_cosctr) = |{ gs_data-costctr ALPHA = IN }|.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs WHERE prctr = lv_cosctr.
    ENDIF.
    SELECT SINGLE lifnr FROM lfb1 INTO gs_data-lifnr WHERE altkn = gs_file-co_num
                                                                 AND bukrs = gs_data-bukrs.
    IF sy-subrc NE 0.
      gs_data-lifnr = gs_file-co_num.
    ENDIF.
    gs_data-budat = sy-datum.
    gs_data-blart = p_blart. "'YR'.
*gs_data-ANLN1 =  ""Need to create asset number based on G/L account
    DATA(lv_lifnr) = |{ gs_data-lifnr ALPHA = OUT }|.
    DATA(lv_zuonr) = gs_data-zuonr.
    CONDENSE lv_zuonr.
    CONCATENATE lv_lifnr lv_zuonr gs_data-xblnr INTO gs_data-zkey.
    CONDENSE gs_data-zkey.
    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.
  DELETE gt_data WHERE znetpayline = 0.
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

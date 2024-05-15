*&---------------------------------------------------------------------*
*& Include          ZFI_RAMP_INBOUND_ACNT_F01
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
  DATA : lv_capex TYPE c,
         lv_opex  TYPE c,
         lv_amnt  TYPE p DECIMALS 2,
         lv_prctr TYPE prctr,
         lv_hkont TYPE hkont.
  LOOP AT gt_file INTO gs_file.
    CLEAR : lv_capex, lv_opex.
    gs_data-budat = gs_file-zbatch.
*gs_data-BUKRS
    CLEAR : lv_prctr, lv_hkont.
    lv_prctr = gs_file-zco.
    lv_prctr = |{ lv_prctr ALPHA = IN }|.
    lv_hkont = gs_file-zasset_co_obj.
    SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs WHERE prctr = lv_prctr. "#EC CI_GENBUFF
    IF sy-subrc NE 0.
      SELECT SINGLE bukrs FROM csks INTO gs_data-bukrs WHERE kostl = lv_prctr.
    ENDIF.
    gs_data-ztext = gs_file-zdescriptn2. "zdescriptn.
*gs_data-HKONT =
    lv_hkont = |{ lv_hkont ALPHA = IN }|.
*    gs_data-anln1 = gs_file-zsset_co_sub.
*    gs_data-zuonr = gs_file-zsset_co_sub.  "zadrs_no
    gs_data-zuonr = gs_file-zafe_no.
    gs_data-zafe = gs_file-zafe_no.
*    gs_data-zuonr = gs_file-zafe_no.
    gs_data-xblnr = gs_file-zinvoice.
    gs_data-inv_key = gs_file-zinvoice.
*    DATA(lv_yy) = gs_file-zinv_date+6(4).
*    DATA(lv_dd) = gs_file-zinv_date+3(2).
*    DATA(lv_mm) = gs_file-zinv_date+0(2).
    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
      EXPORTING
        date_external            = gs_file-zinv_date
*       ACCEPT_INITIAL_DATE      =
      IMPORTING
        date_internal            = gs_data-bldat
      EXCEPTIONS
        date_external_is_invalid = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

*    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-bldat.
*    gs_data-bldat = gs_file-zinv_date.
    CLEAR lv_amnt.
    REPLACE ',' IN gs_file-zgross_amnt WITH ' '.
    CONDENSE gs_file-zgross_amnt.
    lv_amnt =  gs_file-zgross_amnt.
    SELECT  xbilk INTO TABLE @DATA(lt_xbilk) FROM ska1 WHERE ktopl = 'PSUS'
                                                            AND saknr = @lv_hkont.
    READ TABLE lt_xbilk INTO DATA(ls_dat1) WITH KEY xbilk = 'X'.
    IF sy-subrc EQ 0 AND gs_file-zsset_co_sub IS NOT INITIAL.
      gs_data-capex = 'X'.
      IF lv_amnt GT p_thamnt.
        gs_data-hkont = p_capxgl.
        gs_data-zuonr = gs_file-zasset_co_obj.
      ELSE.
        gs_data-hkont = lv_hkont.
      ENDIF.
    ELSE.
      gs_data-opex = 'X'.
      IF lv_amnt GT p_thamnt.
        gs_data-hkont = p_opxgl.
        gs_data-zuonr = gs_file-zasset_co_obj.
      ELSE.
        gs_data-hkont = lv_hkont.
      ENDIF.
    ENDIF.
*    ENDIF.
    gs_data-dmbtr = lv_amnt.
    gs_data-mwsts = gs_file-ztax.
    gs_data-lifnr = gs_file-zusr_ref.
    IF p_spfx IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF p_spfx IN gs_file-zusr_ref WITH p_tpfx.
      gs_data-lifnr = gs_file-zusr_ref.
      CONDENSE gs_data-lifnr.
      gs_data-lifnr = |{ gs_data-lifnr ALPHA = IN }|.
    ENDIF.
*    gs_data-blart = 'YR'.
    gs_data-bktxt = gs_file-zdescriptn.

    gs_data-prctr = lv_prctr.
    gs_data-ord43 = gs_file-zord43.
    gs_data-anlkl = gs_file-zsset_co_sub.
    gs_data-anlkl = |{ gs_data-anlkl ALPHA = IN }|.
*** Check for AUC asset class
*    IF gs_data-anlkl IN s_asset AND s_asset[] IS NOT INITIAL.
*      CLEAR: gs_data-capex.
*      gs_data-opex = 'X'.
*    ENDIF.
*** Serial No is filled with zasset_no from file
    gs_data-sernr = gs_file-zasset_no.
    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_capex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_capex .

  DATA(lo_capex) = NEW zcl_fi_ramp_accnt_pay( ).

  CALL METHOD lo_capex->post_document
    EXPORTING
      gt_data       = gt_capex
      iv_threhold   = p_thamnt
*     iv_taxgl      = p_taxgl
      iv_doctyp     = p_docty
      ev_dl         = p_dl
      ev_filetype   = 'CAPEX'
      asset_auc     = s_asset[]
    IMPORTING
      bapiret2      = gt_bapiret2
    CHANGING
      ct_alv_output = gt_alv_output
      gt_file       = gt_file_mail.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_opex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_opex .

  DATA(lo_opex) = NEW zcl_fi_ramp_accnt_pay( ).

  CALL METHOD lo_opex->post_document
    EXPORTING
      gt_data       = gt_opex
      iv_threhold   = p_thamnt
*     iv_taxgl      = p_taxgl
      iv_doctyp     = p_docty
      ev_dl         = p_dl
      ev_filetype   = 'OPEX'
      asset_auc     = s_asset[]
    IMPORTING
      bapiret2      = gt_bapiret2
    CHANGING
      ct_alv_output = gt_alv_output
      gt_file       = gt_file_mail.

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

*  data: start type string.
*  data: ifiletable type filetable.
*  data: xfiletable like line of ifiletable.
*  data: return type i.
*
*
*  start = '/usr/sap/DS4/interfaces/RAMP/inbound'.
*
*  call method cl_gui_frontend_services=>file_open_dialog
*   exporting
**    WINDOW_TITLE            =
**    DEFAULT_EXTENSION       =
**    DEFAULT_FILENAME        =
**    FILE_FILTER             =
*      initial_directory       = start
**    MULTISELECTION          =
*    changing
*      file_table              = ifiletable
*      rc                      = return
**    USER_ACTION             =
**  EXCEPTIONS
**    FILE_OPEN_DIALOG_FAILED = 1
**    CNTL_ERROR              = 2
**    ERROR_NO_GUI            = 3
**    others                  = 4
*          .
*  if sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.
*
*  read table ifiletable into xfiletable index 1.

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = '/interfaces/ramp/INT0008/in'
*     FILEMASK         = ' '
    IMPORTING
      serverfile       = p_dir
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Filepath not selected' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.


*  p_dir = xfiletable.

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

  DATA: lc_msg TYPE REF TO cx_salv_msg.

  TRY.
      "Instantiation
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = DATA(lo_alv)
        CHANGING
          t_table      = gt_alv_output ).
    CATCH cx_salv_msg INTO lc_msg .
      gv_msg = lc_msg->get_text( ).
      MESSAGE gv_msg TYPE 'I'.
  ENDTRY.
  "Enable default ALV toolbar functions
*  lo_alv->get_functions( )->set_default( abap_true ).
  lo_alv->get_functions( )->set_all( abap_true ).
  "Set column headings
  lo_alv->get_columns( )->set_optimize( abap_true ).
  TRY.
      lo_alv->get_columns( )->get_column( 'STATUS')->set_medium_text( 'Record Status' ).
      lo_alv->get_columns( )->get_column( 'MESSAGE')->set_medium_text( 'Record Messages' ).
      lo_alv->get_columns( )->get_column( 'BLART')->set_medium_text( 'Document Type' ).
      lo_alv->get_columns( )->get_column( 'ZLONG_TEXT')->set_medium_text( 'Long Text' ).
      lo_alv->get_columns( )->get_column( 'OPEX')->set_medium_text( 'OPEX?' ).
      lo_alv->get_columns( )->get_column( 'CAPEX')->set_medium_text( 'CAPEX?' ).
      lo_alv->get_columns( )->get_column( 'ZAFE')->set_medium_text( 'Assignment' ).
      lo_alv->get_columns( )->get_column( 'PRCTR')->set_medium_text( 'Profit/Cost Center' ).
      lo_alv->get_columns( )->get_column( 'KOSTL')->set_visible( value  = if_salv_c_bool_sap=>false ).
      lo_alv->get_columns( )->get_column( 'ZAFE')->set_visible( value  = if_salv_c_bool_sap=>false ).
      lo_alv->get_columns( )->get_column( 'ZTEXT')->set_medium_text( 'Text' ).
    CATCH cx_salv_not_found INTO gt_salv_not_found.
      gv_msg = gt_salv_not_found->get_text( ).
      MESSAGE gv_msg TYPE gc_error.
  ENDTRY.
  "Display the ALV Grid
  lo_alv->display( ).

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
*         lt_dir     TYPE TABLE OF epsfili,
*         lv_dir     TYPE epsf-epsdirnam,
         lt_dir     TYPE TABLE OF eps2fili,
         lv_dir     TYPE eps2filnam,
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

*/interfaces/ramp/INT0008/archive/
  CLEAR lv_dir.
  lv_dir = p_dir.
  CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
    EXPORTING
      iv_dir_name = lv_dir
*     FILE_MASK   = ' '
* IMPORTING
*     DIR_NAME    =
*     FILE_COUNTER                 =
*     ERROR_COUNTER                =
    TABLES
      dir_list    = lt_dir
* EXCEPTIONS
*     INVALID_EPS_SUBDIR           = 1
*     SAPGPARAM_FAILED             = 2
*     BUILD_DIRECTORY_FAILED       = 3
*     NO_AUTHORIZATION             = 4
*     READ_DIRECTORY_FAILED        = 5
*     TOO_MANY_READ_ERRORS         = 6
*     EMPTY_DIRECTORY_LIST         = 7
*     OTHERS      = 8
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
*    EXPORTING
*      dir_name               = lv_dir
**     FILE_MASK              = ' '
**   IMPORTING
**     DIR_NAME               =
**     FILE_COUNTER           =
**     ERROR_COUNTER          =
*    TABLES
*      dir_list               = lt_dir
*    EXCEPTIONS
*      invalid_eps_subdir     = 1
*      sapgparam_failed       = 2
*      build_directory_failed = 3
*      no_authorization       = 4
*      read_directory_failed  = 5
*      too_many_read_errors   = 6
*      empty_directory_list   = 7
*      OTHERS                 = 8.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.

  IF lt_dir IS NOT INITIAL.
    LOOP AT lt_dir INTO DATA(ls_dir).
      IF ls_dir-name CS '.csv'.
        CONCATENATE p_dir ls_dir-name INTO p_dir.
      ENDIF.
    ENDLOOP.

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
  ELSE.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_data .

  DATA(lo_data) = NEW zcl_fi_ramp_accnt_pay( ).

  CALL METHOD lo_data->post_document
    EXPORTING
      gt_data       = gt_data
      iv_threhold   = p_thamnt
*     iv_taxgl      = p_taxgl
      iv_doctyp     = p_docty
      ev_dl         = p_dl
      ev_filetype   = 'CAPEX'
      asset_auc     = s_asset[]
    IMPORTING
      bapiret2      = gt_bapiret2
    CHANGING
      ct_alv_output = gt_alv_output
      gt_file       = gt_file_mail.

ENDFORM.

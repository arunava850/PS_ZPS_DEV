*&---------------------------------------------------------------------*
*& Include          ZFI_INT15_RESTATE_TAX_AP_F01
*&---------------------------------------------------------------------*
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
              lc_n TYPE c LENGTH 1 VALUE 'N',
              lc_o TYPE c LENGTH 1 VALUE 'O',
              lc_p TYPE c LENGTH 1 VALUE 'P',
              lc_q TYPE c LENGTH 1 VALUE 'Q',
              lc_r TYPE c LENGTH 1 VALUE 'R',
              lc_s TYPE c LENGTH 1 VALUE 'S',
              lc_t TYPE c LENGTH 1 VALUE 'T'.



  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
      filetype                = 'BIN'
    IMPORTING
      filelength              = lv_filelgth
      header                  = lv_headerstring
    TABLES
      data_tab                = lt_records
* CHANGING
*     ISSCANPERFORMED         = ' '
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
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelgth
*     FIRST_LINE   = 0
*     LAST_LINE    = 0
    IMPORTING
      buffer       = lv_headerstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF lv_headerstring IS NOT INITIAL.

    DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.

    DATA(lx_excel_core) = NEW cx_fdt_excel_core( ).

    TRY.
        lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                              document_name = lv_file
                              xdocument = lv_headerstring ).


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
    ENDIF.


    DATA(lv_row) = 1.

    LOOP AT <gt_data> ASSIGNING FIELD-SYMBOL(<fs_data>) FROM lv_row.

      ASSIGN COMPONENT lc_a OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_fld_val>).
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apchkrno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_b OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-exportno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_c OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-appmntmhd = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_d OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-state = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_e OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-jurisdict = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_f OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-aptxbillid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_g OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-txbillglno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_h OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-taxyear = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_i OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apreqdate = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_j OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apinstlmntno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_k OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-aptaxtyp = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_l OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-appyeid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_m OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-adrsbkvndr = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_n OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apvndrnam = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_o OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-prprtyid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_p OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-parcel = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_q OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apnetpyamnt = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_r OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-gldate = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_s OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-txbillno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_t OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-usecod11 = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.
  ENDIF.
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
  DATA : lv_str     TYPE xstring,
         lv_str1   TYPE xstring,
         lt_dir     TYPE TABLE OF epsfili,
         lv_dir     TYPE epsf-epsdirnam,
         lv_archive TYPE sapb-sappfad,
         lv_source  TYPE sapb-sappfad,
         lv_file TYPE string,
         lv_new(2000) TYPE c,
         lv_chk TYPE C.

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
              lc_n TYPE c LENGTH 1 VALUE 'N',
              lc_o TYPE c LENGTH 1 VALUE 'O',
              lc_p TYPE c LENGTH 1 VALUE 'P',
              lc_q TYPE c LENGTH 1 VALUE 'Q',
              lc_r TYPE c LENGTH 1 VALUE 'R',
              lc_s TYPE c LENGTH 1 VALUE 'S',
              lc_t TYPE c LENGTH 1 VALUE 'T'.

*  lv_file =

*/interfaces/ramp/INT0008/archive/
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
    IF ls_dir-name CS '.xlsx'.
      CONCATENATE p_dir ls_dir-name INTO p_dir.
      lv_chk = 'X'.
*         CLEAR : p_dir.
*    p_dir =  lv_dir.
      exit.
    ENDIF.
  ENDLOOP.
   CLEAR lv_str.
 IF lv_chk = 'X'.
  OPEN DATASET p_dir FOR INPUT IN BINARY MODE." ENCODING DEFAULT.
  DO.
    lv_file = p_dir.
    CLEAR lv_str1.
    READ DATASET p_dir INTO lv_str1.
*    CONCATENATE lv_str1 lv_str INTO lv_str.
    IF lv_str1 is NOT INITIAL.
   lv_str = lv_str1.
    ENDIF.
    IF sy-subrc EQ 0.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
  CLOSE DATASET p_dir.
*      ENDIF.
  IF lv_str IS NOT INITIAL.

    DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.

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
    ENDIF.


    DATA(lv_row) = 1.

    LOOP AT <gt_data> ASSIGNING FIELD-SYMBOL(<fs_data>) FROM lv_row.

      ASSIGN COMPONENT lc_a OF STRUCTURE <fs_data> TO FIELD-SYMBOL(<fs_fld_val>).
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apchkrno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_b OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-exportno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_c OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-appmntmhd = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_d OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-state = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_e OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-jurisdict = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_f OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-aptxbillid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_g OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-txbillglno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_h OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-taxyear = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_i OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apreqdate = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_j OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apinstlmntno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_k OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-aptaxtyp = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_l OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-appyeid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_m OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-adrsbkvndr = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_n OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apvndrnam = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_o OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-prprtyid = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_p OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-parcel = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_q OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-apnetpyamnt = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_r OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-gldate = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_s OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-txbillno = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.

      ASSIGN COMPONENT lc_t OF STRUCTURE <fs_data> TO <fs_fld_val>.
      IF <fs_fld_val> IS ASSIGNED.
        gs_file-usecod11 = <fs_fld_val>.
        CLEAR <fs_fld_val>.
      ENDIF.
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.
 CLEAR : lv_archive, lv_source.
    lv_source = lv_archive = p_dir.
    REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.

    OPEN DATASET p_dir FOR INPUT IN BINARY MODE."  ENCODING DEFAULT.
    OPEN DATASET lv_archive FOR OUTPUT IN BINARY MODE." ENCODING DEFAULT.
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
  ENDIF.
   ENDIF.
ENDFORM.
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
      directory  = '/interfaces/onesource/INT0015/in'
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
*& Form process_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_file .
*data : lv_prctr TYPE prctr.

*  REFRESH : gt_data.
*  LOOP AT gt_file INTO gs_file.
*    CONCATENATE gs_file-apchkrno gs_file-exportno INTO gs_data-xblnr SEPARATED BY space.
*    gs_data-zuonr = gs_file-appmntmhd.
*    gs_data-saknr = gs_file-txbillglno.
*    DATA(lv_dd1) = gs_file-apreqdate+8(2).
*    DATA(lv_mm1) = gs_file-apreqdate+5(2).
*    DATA(lv_yy1) = gs_file-apreqdate+0(4).
*    CONCATENATE lv_yy1 lv_mm1 lv_dd1 INTO gs_data-duedat.
**gs_data-DUEDAT = gs_file-apreqdate.
*    gs_data-bktxt = gs_file-apinstlmntno.
*    DATA(lv_dd) = gs_file-gldate+8(2).
*    DATA(lv_mm) = gs_file-gldate+5(2).
*    DATA(lv_yy) = gs_file-gldate+0(4).
*    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-budat.
*    CONCATENATE gs_file-aptaxtyp gs_file-gldate INTO gs_data-sgtxt.
*    gs_data-lifnr = gs_file-adrsbkvndr.
*    gs_data-lifnr = |{ gs_data-lifnr ALPHA = IN }|.
*    gs_data-prctr = gs_file-prprtyid.
*    gs_data-wrbtr = gs_file-apnetpyamnt.
*    gs_data-bldat = gs_data-budat.
*    gs_data-blart = p_doc.
**lv_prctr = gs_file-prprtyid.
*    gs_data-prctr = |{ gs_data-prctr ALPHA = IN }|.
*    SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs WHERE prctr = gs_data-prctr.
*    APPEND gs_data TO gt_data.
*    CLEAR:  gs_data, gs_file.
*  ENDLOOP.

ENDFORM.

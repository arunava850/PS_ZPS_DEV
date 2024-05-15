*&---------------------------------------------------------------------*
*& Include          ZFI_REV_POS_STORAGE_RETAIL_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* REVISION LOG                                                         *
*&---------------------------------------------------------------------*
* Date     | Author      | Description & reference nbr                 *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*17-Dec-2023| R Mulpuri | deleting selection range duplicate           *
*09/05/2024 | Pavan M   | Restrict to execute .csv file only           *
*----------------------------------------------------------------------*



*----------------------------------------------------------------------*
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
      directory        = '/interfaces/webchamp/INT0026/in'
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
  DATA : lv_file      TYPE string,
         lv_extension TYPE string.     "+p
  lv_file = p_file.

  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  DATA lt_itab1 TYPE truxs_t_text_data.
  SPLIT lv_file AT '.' INTO lv_file lv_extension.
  IF lv_extension = 'csv'.
    lv_file = p_file.
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_file
*       filetype                = 'ASC'
*       HAS_FIELD_SEPARATOR     = ','
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

  ELSE.
    MESSAGE 'Unable to process file due to wrong file format' TYPE 'I'  DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
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
  DATA : lv_str     TYPE string,
         lt_dir     TYPE TABLE OF epsfili,
         lv_dir     TYPE epsf-epsdirnam,
         lv_archive TYPE sapb-sappfad,
         lv_source  TYPE sapb-sappfad.
  DATA lo_csv TYPE REF TO cl_rsda_csv_converter.
  CALL METHOD cl_rsda_csv_converter=>create
    EXPORTING
*     i_delimiter = '"' "c_default_delimiter
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
  REFRESH : gr_site.
  LOOP AT lt_dir INTO DATA(ls_dir).
    IF ls_dir-name CS '.csv'.
      CONCATENATE p_dir ls_dir-name INTO p_dir.
      OPEN DATASET p_dir FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      REFRESH gt_file.
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
      IF gt_file IS NOT INITIAL AND r2 = 'X'.
        CLEAR : lv_archive, lv_source.
        lv_source = lv_archive = p_dir.
        REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.
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
        REFRESH lt_update.
        DELETE gt_file INDEX 1.
        PERFORM process_file.
      ENDIF.
    ENDIF.
    CLEAR : p_dir.
    p_dir = lv_dir.
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
  DATA : lv_fyear    TYPE bapi0002_4-fiscal_year,
         lv_period   TYPE bapi0002_4-fiscal_period,
         lr_zsiteno  TYPE RANGE OF zsiteno,
         lv_prctr    TYPE prctr,
         lv_prctrout TYPE prctr,
         lv_cnt      TYPE i,
         lv_dd(2)    TYPE n,
         lv_mm(2)    TYPE n.
  CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_INT0026_INSURANCE_GL'.
  SELECT SINGLE * FROM tvarvc INTO @DATA(ls_1000z) WHERE name = 'ZFI_INT0026_1001Z_1000_MAP'.
  SELECT * FROM tvarvc INTO TABLE @DATA(lt_insr) WHERE name = @lc_name.
*  REFRESH : gr_site.
  IF s_sitno IS NOT INITIAL.
    DELETE gt_file[] WHERE site_no NOT IN s_sitno.
  ENDIF.
  LOOP AT gt_file INTO gs_file.
    CLEAR: lv_mm, lv_dd.
    gs_data-zsiteno = gs_file-site_no.
    gs_site-sign = 'I'.
    gs_site-option = 'EQ'.
    gs_site-low = gs_file-site_no.
    APPEND gs_site TO gr_site.
    CLEAR gs_site.
    lv_dd = gs_file-record_dt+8(2).
    lv_mm = gs_file-record_dt+5(2).
    DATA(lv_yy) = gs_file-record_dt+0(4).
    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-zrec_dt.
    gs_data-zfinty_code = gs_file-finty_code.
    gs_data-zfinty_scode = gs_file-finty_scode.
    gs_data-zfin_det_typ = gs_file-findet_typ.
    gs_data-zfin_det_styp = gs_file-findet_subtyp.
    gs_data-zdue_to_from = gs_file-dueto_from.
    gs_data-zcust_typ_code = gs_file-cstmr_typc.
    gs_data-zcust_typ = gs_file-cstm_typ.
    gs_data-zTAX_TYP_CODE = gs_file-tax_typ_code.
    gs_data-ztax_typ_name = gs_file-tax_typ_code.
    gs_data-amount = gs_file-amount.
    gs_data-zdata_typ = gs_file-datatyp.
    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.
  IF  s_sitno IS NOT INITIAL..
    DELETE gt_data WHERE zsiteno NOT IN s_sitno.
  ENDIF.
  SELECT SINGLE * FROM zfi_ar_rev_post INTO @DATA(ls_datat).
  IF sy-subrc NE 0.
    gv_item = gv_item + 1.
  ELSE.
    SELECT zsno  FROM zfi_ar_rev_post INTO TABLE @DATA(lt_zsno) .
    IF sy-subrc EQ 0.
      SORT lt_zsno BY zsno DESCENDING.
      READ TABLE lt_zsno INTO DATA(ls_zsno) INDEX 1.
      IF sy-subrc EQ 0.
        gv_item = ls_zsno-zsno + 1.
      ENDIF.
    ENDIF.
  ENDIF.
*  IF p_rpc = 'X'.
  SORT gr_site.                                " Rajsekhar Mulpuri 12/17/2023
  DELETE ADJACENT DUPLICATES FROM gr_site.     " Rajsekhar Mulpuri 12/17/2023
  SELECT * FROM zfi_ar_rev_post INTO TABLE @DATA(lt_reprocess)
    FOR ALL ENTRIES IN @gt_data
    WHERE zsiteno = @gt_data-zsiteno
    AND zrec_dt = @gt_data-zrec_dt
    AND belnr = @space.
*    AND belnr EQ @space.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_reprocess ASSIGNING FIELD-SYMBOL(<fs_reprocess>).
*        SELECT SINGLE bukrs FROM cepc_bukrs INTO <fs_reprocess>-bukrs WHERE prctr = <fs_reprocess>-zsiteno.
*
*      ENDLOOP.
*    ENDIF.
* lr_zsiteno = VALUE #( FOR wa in lt_reprocess ( sign = 'I'  option = 'EQ'  low = wa-zsiteno high = ' ' ) ).
*  ENDIF.
  REFRESH lt_update.
  CLEAR lv_cnt.
*  lv_cnt = 1.
  LOOP AT gt_data INTO DATA(ls_data).
    READ TABLE lt_reprocess INTO DATA(ls_repr) WITH KEY zsiteno = ls_data-zsiteno
                                                        zrec_dt = ls_data-zrec_dt.
*                                                        zsno = ls_data-ZSNO.
*      lv_item = '1'.
*    IF sy-subrc EQ 0.
*      gs_trans-zsno = ( lv_cnt + ls_repr-zsno ).
*    ELSE.
    gs_trans-zsno = gv_item.
*    ENDIF.
    IF ls_repr-belnr IS INITIAL.
      CLEAR   lv_prctr.
      lv_prctr  = ls_data-zsiteno.
      lv_prctr = |{ lv_prctr ALPHA = IN }|.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-bukrs WHERE prctr = lv_prctr. "SCHITTADI
      gs_trans-zsiteno = ls_data-zsiteno.
      gs_trans-zrec_dt = ls_data-zrec_dt.
      gs_trans-prctr = lv_prctr.


      gs_trans-bldat = ls_data-zrec_dt.
      gs_trans-budat = ls_data-zrec_dt. "sy-datum.
      gs_trans-blart = 'CW'.  "'ZW'.
      gs_trans-bktxt = ls_data-zfin_det_styp.
      gs_trans-xblnr = ls_data-zsiteno.

      SELECT SINGLE * FROM zfiar_fintype INTO @DATA(ls_fintype) WHERE zfint = @ls_data-zfinty_code
                                                                AND zfinst =  @ls_data-zfinty_scode
                                                                AND zcust =  @ls_data-zcust_typ_code.
*IF sy-subrc eq 0.
      SELECT SINGLE * FROM zfiar_aai_master INTO @DATA(ls_saknr) WHERE zaai = @ls_fintype-zaai
                                                               AND zprctr = @lv_prctr."@ls_data-zsiteno.
      IF sy-subrc NE 0.
        CLEAR ls_saknr.
        SELECT SINGLE * FROM zfiar_aai_master INTO ls_saknr WHERE zaai = ls_fintype-zaai
                                                                 AND zprctr = '0000000000'.
      ENDIF.
*ENDIF.
      SELECT SINGLE * FROM zfiar_aai_master INTO @DATA(ls_aai) WHERE zaai = @ls_fintype-zaai
                                                               AND zprctr = @lv_prctr."ls_data-zsiteno.
*      IF sy-subrc ne 0.
*   SELECT SINGLE * FROM zfiar_aai_master INTO ls_aai WHERE zaai = @ls_fintype-zaai
*                                                               AND zprctr = '0000000000'.
*      ENDIF.
      IF sy-subrc EQ 0.
        IF ls_aai-prctr IS NOT INITIAL.
          gs_trans-kostl = ls_aai-prctr.
          IF  ls_aai-zpsfx IS NOT INITIAL.
            CLEAR: gs_trans-kostl,lv_prctrout.
            lv_prctrout = |{ ls_aai-prctr ALPHA = OUT }|.
            CONCATENATE lv_prctrout ls_aai-zpsfx INTO  gs_trans-kostl.
          ENDIF.
          gs_trans-prctr =  |{ gs_trans-kostl ALPHA = IN }|.
        ELSE.
          gs_trans-kostl = lv_prctr.
          IF  ls_aai-zpsfx IS NOT INITIAL.
            CLEAR gs_trans-kostl.
            CONCATENATE ls_data-zsiteno ls_aai-zpsfx INTO  gs_trans-kostl.
          ENDIF.
          gs_trans-prctr =  |{ gs_trans-kostl ALPHA = IN }|.
        ENDIF.
*        IF ls_aai-zpsfx IS NOT INITIAL.
        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-ibukrs WHERE prctr = gs_trans-prctr.
*        ENDIF.
*      IF sy-subrc NE 0.
*        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-ibukrs WHERE prctr = gs_trans-prctr.
*      ENDIF.
      ELSE.
        CLEAR ls_aai.
        SELECT SINGLE * FROM zfiar_aai_master INTO ls_aai WHERE zaai = ls_fintype-zaai
                                                                   AND zprctr = '0000000000'.
*      CONCATENATE ls_data-zsiteno ls_aai-zpsfx INTO  gs_trans-kostl.
*      gs_trans-prctr =  |{ gs_trans-kostl ALPHA = IN }|.
*      IF ls_aai-zpsfx IS NOT INITIAL.
*        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-ibukrs WHERE prctr = gs_trans-prctr.
*      ENDIF.
*        CONCATENATE ls_data-zsiteno ls_aai-zpsfx INTO  gs_trans-kostl.
        IF ls_aai-prctr IS NOT INITIAL.
*          gs_trans-kostl = |{ ls_aai-prctr ALPHA = OUT }|.
          gs_trans-kostl = ls_aai-prctr.
          IF ls_aai-zpsfx IS NOT INITIAL.
            CLEAR : gs_trans-kostl, lv_prctrout.
            lv_prctrout = |{ ls_aai-prctr ALPHA = OUT }|.
            CONCATENATE lv_prctrout ls_aai-zpsfx INTO  gs_trans-kostl.
          ENDIF.
          gs_trans-prctr =  |{ gs_trans-kostl ALPHA = IN }|.
        ELSE.
          gs_trans-kostl = lv_prctr.
          IF  ls_aai-zpsfx IS NOT INITIAL.
            CLEAR gs_trans-kostl.
            CONCATENATE ls_data-zsiteno ls_aai-zpsfx INTO  gs_trans-kostl.
          ENDIF.
          gs_trans-prctr =  |{ gs_trans-kostl ALPHA = IN }|.
        ENDIF.
*        IF ls_aai-zpsfx IS NOT INITIAL.
        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-ibukrs WHERE prctr = gs_trans-prctr.
*        ENDIF.
      ENDIF.
*      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-bukrs WHERE prctr = lv_prctr.
*      IF sy-subrc NE 0.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_trans-ibukrs WHERE prctr = gs_trans-prctr.
*      ENDIF.
      CLEAR : lv_period, lv_fyear.
      CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
        EXPORTING
          companycodeid = gs_trans-bukrs
          posting_date  = gs_trans-budat
        IMPORTING
          fiscal_year   = lv_fyear
          fiscal_period = lv_period
*         RETURN        =
        .
      gs_trans-gjahr = lv_fyear.
      gs_trans-monat = lv_period.
      IF ls_aai-zdrcr = 'N'.
        gs_trans-bschl = '40'.
      ELSEIF ls_aai-zdrcr = 'Y'.
        gs_trans-bschl = '50'.
      ENDIF.
      gs_trans-saknr = |{ ls_saknr-saknr ALPHA = IN }|.
      gs_trans-gkont = |{ ls_saknr-gkont ALPHA = IN }|.
      gs_trans-zuonr = ls_data-zsiteno.
      gs_trans-prctr = gs_trans-prctr.
*    gs_trans-segment = ls_aai-zpsfx.
      gs_trans-sgtxt = ls_data-zfin_det_styp.
*    IF ls_data-zdue_to_from IS NOT INITIAL.
*  COMP_CODE =

*    ENDIF.
      gs_trans-dmbtr =  ls_data-amount.
*      IF gs_trans-dmbtr LT 0.
*        gs_trans-dmbtr = gs_trans-dmbtr * -1.
*      ENDIF.
*    IF p_ins = 'X'.
      gs_trans-mandt = sy-mandt.
*    MODIFY zfi_ar_rev_post FROM gs_trans.
*    IF sy-dbcnt IS NOT INITIAL.
*      COMMIT WORK.
*    ENDIF.
      APPEND gs_trans TO lt_update.
      IF gs_trans-gkont IS NOT INITIAL.
        DATA(ls_trans_tmp) = gs_trans.
        ls_trans_tmp-zsno = ls_trans_tmp-zsno + 1.
        ls_trans_tmp-saknr = gs_trans-gkont.
        IF gs_trans-bschl = '50'.
          ls_trans_tmp-bschl = '40'.
        ELSEIF gs_trans-bschl = '40'.
          ls_trans_tmp-bschl = '50'.
        ENDIF.
        APPEND ls_trans_tmp TO lt_update.
        gv_item = gv_item + 1.
      ENDIF.
      DATA(lv_insgl) = |{ gs_trans-saknr ALPHA = OUT }|.
      READ TABLE lt_insr INTO DATA(ls_insr) WITH KEY low  = lv_insgl.
      IF sy-subrc EQ 0.
        DATA(lv_zsno) = gs_trans-zsno.
        LOOP AT lt_insr INTO DATA(ls_insr1).
          CLEAR  ls_trans_tmp.
          ls_trans_tmp = gs_trans.
          ls_trans_tmp-zsno = lv_zsno + 1.
          ls_trans_tmp-saknr = ls_insr1-high.
          ls_trans_tmp-saknr = |{ ls_trans_tmp-saknr ALPHA = IN }|.
          ls_trans_tmp-bukrs = ls_trans_tmp-ibukrs = '7200'.
          CONCATENATE ls_trans_tmp-zsiteno 'T' INTO ls_trans_tmp-prctr.
          ls_trans_tmp-kostl = ls_trans_tmp-prctr.
          IF ls_insr1-high+0(1) = 4.
            ls_trans_tmp-bschl = '50'.
          ELSE.
            ls_trans_tmp-bschl = '40'.
          ENDIF.
          APPEND ls_trans_tmp TO lt_update.
          lv_zsno = lv_zsno + 1.
          gv_item = gv_item + 1.
        ENDLOOP.
      ENDIF.
    ENDIF.
    gv_item = gv_item + 1.
    lv_cnt = lv_cnt + 1.
    CLEAR gs_trans.
  ENDLOOP.
*  READ TABLE lt_update INTO DATA(ls_up
*  DATA(lt_update_tmp) = lt_update[].
*  LOOP AT lt_update_tmp ASSIGNING FIELD-SYMBOL(<fs_upd>).
*    DATA(lv_insgl2) = |{ <fs_upd>-saknr ALPHA = OUT }|.
*    READ TABLE lt_insr INTO DATA(ls_insr2) WITH KEY high  = lv_insgl2.
*    IF sy-subrc EQ 0.
*      LOOP AT lt_update ASSIGNING FIELD-SYMBOL(<fs_upd2>) WHERE zsiteno = <fs_upd>-zsiteno.
*        <fs_upd2>-bukrs = '7200'.
*      ENDLOOP.
*    ENDIF.
*  ENDLOOP.
*  DELETE lt_reprocess WHERE belnr NE space.
*  IF lt_reprocess IS NOT INITIAL.
*    DELETE zfi_ar_rev_post FROM TABLE lt_reprocess.
*    COMMIT WORK.
*  ENDIF.
  IF lt_update IS NOT INITIAL.
    MODIFY zfi_ar_rev_post FROM TABLE lt_update.
    COMMIT WORK.
  ENDIF.
*    ENDIF.
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
      t_table      = gt_trans ).

  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Display the ALV Grid
  lo_alv->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_after_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_after_process .

  SELECT * FROM zfi_ar_rev_post  INTO  TABLE @DATA(lt_ret2)
    FOR ALL ENTRIES IN @gt_return
    WHERE zsiteno = @gt_return-zsiteno
    AND   zrec_dt = @gt_return-zrec_dt.

  "Instantiation
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = DATA(lo_alv)
    CHANGING
      t_table      = lt_ret2 ).

  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Display the ALV Grid
  lo_alv->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_raw_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_raw_data .

  DATA:
    lv_dd(2) TYPE n,
    lv_mm(2) TYPE n.
  REFRESH : gr_site.

  LOOP AT gt_file INTO gs_file.
    CLEAR: lv_mm, lv_dd.
    gs_data-zsiteno = gs_file-site_no.
    gs_site-sign = 'I'.
    gs_site-option = 'EQ'.
    gs_site-low = gs_file-site_no.
    APPEND gs_site TO gr_site.
    CLEAR gs_site.
    lv_dd = gs_file-record_dt+2(2).
    lv_mm = gs_file-record_dt+0(1).
    DATA(lv_yy) = gs_file-record_dt+5(4).
    CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-zrec_dt.
    gs_data-zfinty_code = gs_file-finty_code.
    gs_data-zfinty_scode = gs_file-finty_scode.
    gs_data-zfin_det_typ = gs_file-findet_typ.
    gs_data-zfin_det_styp = gs_file-findet_subtyp.
    gs_data-zdue_to_from = gs_file-dueto_from.
    gs_data-zcust_typ_code = gs_file-cstmr_typc.
    gs_data-zcust_typ = gs_file-cstm_typ.
    gs_data-zTAX_TYP_CODE = gs_file-tax_typ_code.
    gs_data-ztax_typ_name = gs_file-tax_typ_code.
    gs_data-amount = gs_file-amount.
    gs_data-zdata_typ = gs_file-datatyp.
    APPEND gs_data TO gt_data.
    CLEAR gs_data.
  ENDLOOP.
  cl_salv_table=>factory(
     IMPORTING
       r_salv_table = DATA(lo_alv)
     CHANGING
       t_table      = gt_data ).

  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Display the ALV Grid
  lo_alv->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_delete
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_delete .
* Local declarations.
*  DATA: lr_table      TYPE REF TO cl_salv_table,
*        lr_selections TYPE REF TO cl_salv_selections.
*  DATA: lr_columns    TYPE REF TO cl_salv_columns_table.
**... §3 Functions
*  DATA: lr_functions TYPE REF TO cl_salv_functions_list,
*        l_text       TYPE string,
*        l_icon       TYPE string.

*  SET PF-STATUS 'STANDARD'.
* Call the factory method
*  IF gr_container IS NOT BOUND.
*    IF cl_salv_table=>is_offline( ) EQ if_salv_c_bool_sap=>false.
*      CREATE OBJECT gr_container
*        EXPORTING
*          container_name = 'CONTAINER'.
*    ENDIF.
  TRY.
      cl_salv_table=>factory(
*        EXPORTING
*          list_display = 'X'
*     EXPORTING
*              r_container    = gr_container
*              container_name = 'CONTAINER'
        IMPORTING
          r_salv_table = lr_table
        CHANGING
          t_table      = gt_trans ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER

  ENDTRY.
* *-- pf_status
  SET PF-STATUS 'STANDARD'.
  lr_table->set_screen_status(
     pfstatus      =  'STANDARD'
     report       = 'ZFI_REV_POS_STORAGE_RETAIL_INT'
     set_functions = lr_table->c_functions_all ).
*... §3.1 activate ALV generic Functions
  lr_functions = lr_table->get_functions( ).
  lr_functions->set_all( gc_true ).
*... §3.2 include own functions
*    TRY.
*        l_text = TEXT-b01.
*        l_icon = icon_complete.
*        lr_functions->add_function(
*          name     = 'DELETE'
*          icon     = l_icon
*          text     = l_text
*          tooltip  = l_text
*          position = if_salv_c_function_position=>right_of_salv_functions ).
*      CATCH cx_salv_wrong_call cx_salv_existing.
*    ENDTRY.
  "events
  gr_events = lr_table->get_event( ).
  CREATE OBJECT gr_handle.
  SET HANDLER gr_handle->on_click FOR gr_events.
* Column selection
  lr_selections = lr_table->get_selections( ).
  lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

  lr_columns = lr_table->get_columns( ).
  lr_columns->set_optimize( abap_true ).

* Display
  lr_table->display( ).

* lr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
*    cl_gui_cfw=>flush( ).
*  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv_error_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_error_process .

  TRY.
      cl_salv_table=>factory(
        EXPORTING
          list_display = abap_false
        IMPORTING
          r_salv_table = lr_table
        CHANGING
          t_table      = gt_trans ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER

  ENDTRY.
* *-- pf_status
  SET PF-STATUS 'STANDARD_P'.
  lr_table->set_screen_status(
     pfstatus      =  'STANDARD_P'
     report       = 'ZFI_REV_POS_STORAGE_RETAIL_INT'
     set_functions = lr_table->c_functions_all ).
*... §3.1 activate ALV generic Functions
  lr_functions = lr_table->get_functions( ).
  lr_functions->set_all( gc_true ).

*  * Add SAVE function
*  lr_functions->add_function(
*              name = 'YE_QM_SAVE'
*              text = 'Save'
*              tooltip = 'Save Changes'
*              position = if_salv_c_function_position=>right_of_salv_functions ).

  gr_events = lr_table->get_event( ).
  CREATE OBJECT gr_handle.
  SET HANDLER gr_handle->on_click FOR gr_events.
* Column selection
  lr_selections = lr_table->get_selections( ).
  lr_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).

  lr_columns = lr_table->get_columns( ).
  lr_columns->set_optimize( abap_true ).
  ls_api = lr_table->extended_grid_api( ).
  ls_edit = ls_api->editable_restricted( ).

  ls_edit->set_attributes_for_columnname(
              EXPORTING
                columnname = 'BUKRS'
                all_cells_input_enabled = abap_true
              ).

  ls_edit->set_attributes_for_columnname(
            EXPORTING
              columnname = 'BUDAT'
              all_cells_input_enabled = abap_true
            ).
  ls_edit->set_attributes_for_columnname(
            EXPORTING
              columnname = 'BLDAT'
              all_cells_input_enabled = abap_true
            ).
  ls_edit->set_attributes_for_columnname(
          EXPORTING
            columnname = 'BSCHL'
            all_cells_input_enabled = abap_true
          ).
  ls_edit->set_attributes_for_columnname(
        EXPORTING
          columnname = 'SAKNR'
          all_cells_input_enabled = abap_true
        ).
  ls_edit->set_attributes_for_columnname(
           EXPORTING
             columnname = 'DMBTR'
             all_cells_input_enabled = abap_true
           ).
  ls_edit->set_attributes_for_columnname(
            EXPORTING
              columnname = 'KOSTL'
              all_cells_input_enabled = abap_true
            ).
  ls_edit->set_attributes_for_columnname(
          EXPORTING
            columnname = 'PRCTR'
            all_cells_input_enabled = abap_true
          ).
  ls_edit->set_attributes_for_columnname(
         EXPORTING
           columnname = 'IBUKRS'
           all_cells_input_enabled = abap_true
         ).


* Display
  lr_table->display( ).
ENDFORM.

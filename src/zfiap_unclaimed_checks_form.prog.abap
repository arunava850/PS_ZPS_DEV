*&---------------------------------------------------------------------*
*& Include          ZFIAP_UNCLAIMED_CHECKS_FORM
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
*& FORM f_send_email.
*--------------------------------------------------------------------*
FORM f_send_email.

  DATA: ls_input   TYPE zst_ps_email_excel_input,
        lv_content TYPE string.

  CONSTANTS:
    gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
    gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

  ls_input-mail_to_tvarvc = 'ZFI_PS_INT0014_TO_EMAIL_ADDR'.
  ls_input-mail_cc_tvarvc = 'ZFI_PS_INT0014_CC_EMAIL_ADDR'.
*  ls_input-mail_to_tvarvc = 'kdurai@publicstorage.com'.
  ls_input-mail_subject = 'AP Unclaimed Checks'.
  ls_input-mail_body_text =  VALUE #( ( line = 'Hello,' ) ( line = 'Please find the attached list.' ) ).
  ls_input-iv_proc_file_name = 'AP Unclaimed Checks_' && sy-datum.
  LOOP AT gt_output INTO gs_output.
    CONCATENATE lv_content
     gs_output-business_unit     gc_tab
     gs_output-doc_num           gc_tab
     gs_output-check_num         gc_tab
     gs_output-property_id       gc_tab
     gs_output-property_desc     gc_tab
     gs_output-owner_last_name   gc_tab
     gs_output-owner_first_name  gc_tab
     gs_output-owner_middle_name gc_tab
     gs_output-owner_title       gc_tab
     gs_output-owner_suffix      gc_tab
     gs_output-owner_addr1       gc_tab
     gs_output-owner_addr2       gc_tab
     gs_output-owner_city        gc_tab
     gs_output-owner_state       gc_tab
     gs_output-zip_code          gc_tab
     gs_output-owner_country     gc_tab
     gs_output-check_date        gc_tab
     gs_output-owner_id          gc_tab
     gs_output-prop_init_amount  gc_crlf   INTO lv_content.
  ENDLOOP.

  ls_input-iv_processed_data = lv_content.

  CALL METHOD zcl_ps_utility_tools=>send_email
    EXPORTING
      is_input = ls_input
    RECEIVING
      rv_subrc = DATA(lv_subrc).
  IF lv_subrc IS NOT INITIAL.
    MESSAGE 'Error in email sending..' TYPE 'I'.
  ELSE.
    MESSAGE 'Email sent successfully..' TYPE 'I'.
  ENDIF.

ENDFORM.
*--------------------------------------------------------------------*
*& FORM f_send_to_proxy.
*--------------------------------------------------------------------*
FORM f_send_to_proxy.

  DATA: ls_out_proxy  TYPE zmt_ob_msgtyp_trackerpro.

  IF gt_proxy[] IS NOT INITIAL AND cb_prxy IS NOT INITIAL.
    TRY.
        DATA(lo_obj_proxy) = NEW zco_fi_s4_to_trackerpro_srv( ).
        IF lo_obj_proxy IS BOUND.
          ls_out_proxy-zmt_ob_msgtyp_trackerpro-it_data[] = gt_proxy[].
          lo_obj_proxy->send_data( output = ls_out_proxy ).
          COMMIT WORK AND WAIT.
          MESSAGE 'The data send to CPI is initiated.' TYPE 'I'.
        ENDIF.
      CATCH cx_ai_system_fault INTO DATA(lo_fault).

        DATA(lv_error) = lo_fault->errortext.
        IF lv_error IS NOT INITIAL.
          MESSAGE lv_error TYPE 'I'.
        ENDIF.
        MESSAGE 'Exception occurred while transferring proxy data.' TYPE 'I'.

    ENDTRY.
  ENDIF.
ENDFORM.
*--------------------------------------------------------------------*
*& FORM f_date_calculation.
*--------------------------------------------------------------------*
FORM f_date_calculation.
  gv_year = sy-datum+0(4).
  gv_mon  = sy-datum+4(2).
  gv_mon = gv_mon - 1.
  IF gv_mon EQ 0.
    gv_mon = '12'.
    gv_year = gv_year - 1.
  ENDIF.
  gv_year = gv_year - 1.
  gv_date = gv_year && gv_mon && '01'.

  CLEAR: s_laufi[].

  APPEND INITIAL LINE TO s_laufi
       ASSIGNING FIELD-SYMBOL(<lfs_laufi>).
  IF sy-subrc IS INITIAL.
    <lfs_laufi>-sign   = 'I'.
    <lfs_laufi>-option = 'EQ'.
    CALL FUNCTION 'HR_JP_MONTH_BEGIN_END_DATE'
      EXPORTING
        iv_date             = gv_date
      IMPORTING
        ev_month_begin_date = <lfs_laufi>-low
        ev_month_end_date   = <lfs_laufi>-high.
    CLEAR gv_date.
  ENDIF.
ENDFORM.


*--------------------------------------------------------------------*
*& FORM f_file_selection_f4.
*--------------------------------------------------------------------*
FORM f_file_selection_f4 .

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
*& Form f_download_file_to_pc
*&---------------------------------------------------------------------*
FORM f_download_file_to_pc .

  DATA: lv_file   TYPE string.

  lv_file = p_file.

  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
*     bin_filesize            =
      filename                = lv_file
      filetype                = 'ASC'
      write_field_separator   = abap_true
*  IMPORTING
*     filelength              =
    CHANGING
      data_tab                = gt_output
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.

*--------------------------------------------------------------------*
*& FORM f_extract_data.
*--------------------------------------------------------------------*
FORM f_extract_data .
  CONSTANTS: c_quot TYPE c VALUE ''''.
  SELECT zbukr,
         chect,
         lifnr,
         vblnr,
         gjahr,
         zaldt,
         rwbtr,
         bancd,
         zanre,
         zpstl,
         zort1,
         zstra,
         zland,
         zregi
    FROM payr
    WHERE zbukr IN @s_bukrs[]
      AND zaldt IN @s_laufi[]
      AND vblnr IN @s_vblnr[]
      AND bancd IS INITIAL
    INTO TABLE @DATA(lt_payr).
  IF sy-subrc IS INITIAL.
    SORT lt_payr BY zbukr vblnr gjahr.
  ENDIF.

  DATA(lt_payr_tmp) = lt_payr.
  SORT lt_payr_tmp BY zbukr vblnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_payr_tmp
                               COMPARING zbukr vblnr gjahr.

  IF lt_payr_tmp[] IS NOT INITIAL.
    SELECT bukrs,
           belnr,
           gjahr,
           prctr,
           kostl,
           koart,
           augbl,
           wrbtr
      FROM bseg
      FOR ALL ENTRIES IN @lt_payr_tmp
      WHERE bukrs = @lt_payr_tmp-zbukr
        AND augbl = @lt_payr_tmp-vblnr
        AND gjahr = @lt_payr_tmp-gjahr
      INTO TABLE @DATA(lt_bseg_1).
    IF sy-subrc IS INITIAL.
      SORT lt_bseg_1 BY bukrs augbl gjahr.
      DATA(lt_bseg_1_tmp) = lt_bseg_1.
      SORT lt_bseg_1_tmp BY bukrs belnr gjahr.
      DELETE ADJACENT DUPLICATES FROM lt_bseg_1_tmp
                     COMPARING  bukrs belnr gjahr.
      SELECT bukrs,
             belnr,
             gjahr,
             prctr,
             kostl,
             koart,
             augbl,
             wrbtr
        FROM bseg
        FOR ALL ENTRIES IN @lt_bseg_1_tmp
        WHERE bukrs = @lt_bseg_1_tmp-bukrs
          AND belnr = @lt_bseg_1_tmp-belnr
          AND gjahr = @lt_bseg_1_tmp-gjahr
        INTO TABLE @DATA(lt_bseg).
      IF sy-subrc IS INITIAL.
        DELETE lt_bseg WHERE koart EQ 'K'.
        SORT lt_bseg BY bukrs belnr gjahr.
        LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<lfs_bseg>).
*          IF <lfs_bseg>-belnr EQ <lfs_bseg>-augbl.
*             DELETE lt_bseg.
*             CONTINUE.
*          ENDIF.
          READ TABLE lt_bseg_1_tmp INTO DATA(ls_bseg_1)
                               WITH KEY bukrs = <lfs_bseg>-bukrs
                                        belnr = <lfs_bseg>-belnr
                                        gjahr = <lfs_bseg>-gjahr
                                        BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            <lfs_bseg>-augbl = ls_bseg_1-augbl.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lt_bseg[] IS INITIAL .
    MESSAGE 'No data extracted.' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  DATA(lt_bseg_tmp) = lt_bseg.
  SORT lt_bseg_tmp BY bukrs belnr gjahr.
  DELETE ADJACENT DUPLICATES FROM lt_bseg_tmp COMPARING  bukrs belnr gjahr.
  IF lt_bseg_tmp[] IS NOT INITIAL.
    SELECT bukrs,
           belnr,
           gjahr,
           blart,
           xblnr
      FROM bkpf
      FOR ALL ENTRIES IN @lt_bseg_tmp
      WHERE bukrs = @lt_bseg_tmp-bukrs
        AND belnr = @lt_bseg_tmp-belnr
        AND gjahr = @lt_bseg_tmp-gjahr
      INTO TABLE @DATA(lt_bkpf).
    IF sy-subrc IS INITIAL.
      SORT lt_bkpf BY  bukrs belnr gjahr.
    ENDIF.
  ENDIF.

*  IF lt_bseg_tmp[] IS NOT INITIAL.
*    SELECT spras,
*           prctr,
*           kokrs,
*           ktext
*      FROM cepct
*      FOR ALL ENTRIES IN @lt_bseg_tmp
*      WHERE spras = 'E'
*        AND prctr = @lt_bseg_tmp-prctr
*        AND kokrs = 'PSCO'
*      INTO TABLE @DATA(lt_cepct).
*    IF sy-subrc IS INITIAL.
*      SORT lt_cepct BY prctr.
*    ENDIF.
*  ENDIF.
*
*  lt_bseg_tmp = lt_bseg.
*  SORT lt_bseg_tmp BY kostl.
*  DELETE ADJACENT DUPLICATES FROM lt_bseg_tmp COMPARING kostl.
*
*  IF lt_bseg_tmp[] IS NOT INITIAL.
*    SELECT spras,
*           kokrs,
*           kostl,
*           ktext
*      FROM cskt
*      FOR ALL ENTRIES IN @lt_bseg_tmp
*      WHERE spras = 'E'
*        AND kokrs = 'PSCO'
*        AND kostl = @lt_bseg_tmp-kostl
*      INTO TABLE @DATA(lt_cskt).
*    IF sy-subrc IS INITIAL.
*      SORT lt_cskt BY kostl.
*    ENDIF.
*  ENDIF.

  lt_payr_tmp = lt_payr.
  SORT lt_payr_tmp BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_payr_tmp COMPARING lifnr.
  IF lt_payr_tmp[] IS NOT INITIAL.
    SELECT a~lifnr,
           a~name1,
           a~name2,
           a~name3,
           a~stras,
           a~stcd1,
           a~stcd2,
           a~adrnr,
           b~house_num1
       FROM lfa1 AS a
       INNER JOIN adrc AS b
         ON a~adrnr = b~addrnumber
       FOR ALL ENTRIES IN @lt_payr_tmp
       WHERE lifnr = @lt_payr_tmp-lifnr
       INTO TABLE @DATA(lt_lfa1).
    IF sy-subrc IS INITIAL.
      SORT lt_lfa1 BY lifnr.
    ENDIF.
  ENDIF.

  gs_output = VALUE #( business_unit = 'Business Unit'
    doc_num           = 'Document Number'
    check_num         = 'Check Number'
    property_id       = 'Property ID Code'
    property_desc     = 'Property Description'
    owner_last_name   = 'Owner Last Name'
    owner_first_name  = 'Owner First Name'
    owner_middle_name = 'Owner Middle Name'
    owner_title       = 'Owner Title'
    owner_suffix      = 'Owner Suffix'
    owner_addr1       = 'Owner Address 1'
    owner_addr2       = 'Owner Address 2'
    owner_city        = 'Owner City'
    owner_state       = 'Owner State'
    zip_code          = 'Zip Code'
    owner_country     = 'Owner Country'
    check_date       = 'Check Date'
    owner_id         = 'Owner ID Number'
    prop_init_amount = 'Property Initial Amount'
  ).
  APPEND gs_output TO gt_output.

  LOOP AT lt_bseg INTO DATA(ls_bseg).

    IF ls_bseg-belnr EQ ls_bseg-augbl.
      CONTINUE.
    ENDIF.

    CLEAR: gs_output.

    READ TABLE lt_payr INTO DATA(ls_payr)
                       WITH KEY zbukr = ls_bseg-bukrs
                                vblnr = ls_bseg-augbl
                                gjahr = ls_bseg-gjahr
                                BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
      CONTINUE.
    ENDIF.

*    business_unit
    IF ls_bseg-prctr IS NOT INITIAL.
      gs_output-business_unit = ls_bseg-prctr.
    ELSEIF ls_bseg-kostl IS NOT INITIAL.
      gs_output-business_unit = ls_bseg-kostl.
    ENDIF.
*    property_desc
    READ TABLE lt_bkpf INTO DATA(ls_bkpf)
                        WITH KEY bukrs = ls_bseg-bukrs
                                 belnr = ls_bseg-belnr
                                 gjahr = ls_bseg-gjahr
                        BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      gs_output-property_desc = ls_bkpf-xblnr.
    ENDIF.
*    doc_num
    gs_output-doc_num = ls_bseg-belnr.
*    check_num
    gs_output-check_num = ls_payr-chect.
*    property_id
    gs_output-property_id = 'MS16'.
*    owner_title
    gs_output-owner_title = ls_payr-zanre.
*    owner_addr1
    gs_output-owner_addr1 = ls_payr-zstra.
*    owner_city
    gs_output-owner_city = ls_payr-zort1.
*    owner_state
    gs_output-owner_state = ls_payr-zregi.
*    zip_code
    gs_output-zip_code = ls_payr-zpstl.
*    owner_country
    gs_output-owner_country = ls_payr-zland.
*    check_date
    gs_output-check_date = ls_payr-zaldt.
*    prop_init_amount
    gv_value = ls_bseg-wrbtr.
    CONDENSE gv_value.
    gs_output-prop_init_amount = gv_value.


      READ TABLE lt_lfa1 INTO DATA(ls_lfa1)
                         WITH KEY lifnr = ls_payr-lifnr
                         BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        IF ls_lfa1-stcd2 IS NOT INITIAL.
*    owner_id
         IF ls_bkpf-blart = 'ZE'.
          gs_output-owner_id = ls_lfa1-stcd2.
         ENDIF.
*    owner_last_name
          gs_output-owner_last_name = ls_lfa1-name1.
        ELSEIF ls_lfa1-stcd1 IS NOT INITIAL.
*    owner_id
         IF ls_bkpf-blart = 'ZE'.
          gs_output-owner_id = ls_lfa1-stcd1.
         ENDIF.
*    owner_last_name
          gs_output-owner_last_name = ls_lfa1-name2.
*    owner_first_name
*    owner_middle_name
          SPLIT ls_lfa1-name1 AT ' ' INTO gs_output-owner_first_name gs_output-owner_middle_name.
        ENDIF.
*    owner_suffix
        gs_output-owner_suffix = ls_lfa1-name3.
*    owner_addr2
        gs_output-owner_addr2 = ls_lfa1-house_num1.
*    owner_id
*      IF ls_lfa1-stcd1 IS NOT INITIAL.
*        gs_output-owner_id = ls_lfa1-stcd1.
*      ELSEIF ls_lfa1-stcd2 IS NOT INITIAL.
*        gs_output-owner_id = ls_lfa1-stcd2.
*      ENDIF.
     ENDIF.

    IF cb_prxy IS NOT INITIAL.
      APPEND INITIAL LINE TO gt_proxy ASSIGNING FIELD-SYMBOL(<lfs_proxy>).
      <lfs_proxy> =  CORRESPONDING #( gs_output ).
      <lfs_proxy>-interface_name = 'INT0014'.
      <lfs_proxy>-receiver_system = 'TPRO'.
    ENDIF.

*    gs_output-business_unit = c_quot && gs_output-business_unit.
*    gs_output-business_unit = '"' && gs_output-business_unit && '"'.
    APPEND gs_output TO gt_output.
    CLEAR: ls_bseg,ls_lfa1,ls_payr,ls_bkpf.
  ENDLOOP.
ENDFORM.

*--------------------------------------------------------------------*
*& FORM f_validations.
*--------------------------------------------------------------------*
FORM f_validations.

  IF s_laufi[] IS INITIAL.
    MESSAGE 'Please enter Payment date' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  IF cb_file IS NOT INITIAL AND p_file IS INITIAL.
    MESSAGE 'Please enter the file path' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Include          ZFI_EXCESS_PRCDS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form read_data_frm_frontend
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM read_data_frm_frontend .
  lv_file = p_file.



  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_file
      filetype                = 'ASC'
      has_field_separator     = htab
    CHANGING
      data_tab                = gt_file
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


ENDFORM.
*&---------------------------------------------------------------------*
*& Form Update_DATA_DB
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM update_data_db .

  IF gt_file[] IS NOT INITIAL.

    LOOP AT gt_file ASSIGNING FIELD-SYMBOL(<fs_file>) .
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_file>-company_code
        IMPORTING
          output = <fs_file>-company_code.
    ENDLOOP.

    SELECT lifnr , altkn FROM lfb1
                         INTO TABLE @DATA(lt_lfb1)
                         FOR ALL ENTRIES IN @gt_file
                         WHERE ( altkn = @gt_file-tenant_number
                         OR      altkn = @gt_file-payee_number )
                         AND     bukrs = '1000' .
    SELECT * FROM tvarvc INTO TABLE @DATA(lt_glacc) WHERE name = 'ZCNV0029_GLACC' .
    SELECT * FROM cepc_bukrs INTO TABLE @DATA(lt_cpec)
             FOR ALL ENTRIES IN @gt_file
             WHERE prctr = @gt_file-company_code.
  ENDIF.

  LOOP AT gt_file ASSIGNING <fs_file> .

    APPEND INITIAL LINE TO gt_ep_data ASSIGNING FIELD-SYMBOL(<fs_ep_data>). "
    <fs_ep_data>-edi_trans_no               = <fs_file>-edi_trans_no.

    PERFORM convert_date_internal USING     <fs_file>-edi_trans_date
                                  CHANGING  <fs_ep_data>-edi_trans_date
                                  .
    <fs_ep_data>-request_type               = <fs_file>-request_type.
    <fs_ep_data>-approval_status            = <fs_file>-approval_status.
    READ TABLE lt_lfb1 ASSIGNING FIELD-SYMBOL(<fs_lfb1>) WITH KEY  altkn = <fs_file>-tenant_number.
    IF sy-subrc = 0 .
      <fs_ep_data>-tenant_number = <fs_lfb1>-lifnr .
    ELSE.
      <fs_ep_data>-tenant_number = <fs_file>-tenant_number.
      APPEND INITIAL LINE TO gt_message ASSIGNING FIELD-SYMBOL(<fs_message>).
      <fs_message>-edi_trans_no               = <fs_file>-edi_trans_no.
      <fs_message>-lifnr   = <fs_file>-tenant_number.
      <fs_message>-message = 'Tenant does not exist as Vendor'.
    ENDIF.
    <fs_ep_data>-tenant_name                = <fs_file>-tenant_name.

    READ TABLE lt_lfb1 ASSIGNING <fs_lfb1> WITH KEY  altkn = <fs_file>-payee_number.
    IF sy-subrc = 0 .
      <fs_ep_data>-payee_number = <fs_lfb1>-lifnr .
    ELSE.
      <fs_ep_data>-payee_number = <fs_file>-payee_number.
      APPEND INITIAL LINE TO gt_message ASSIGNING <fs_message>.
      <fs_message>-edi_trans_no               = <fs_file>-edi_trans_no.
      <fs_message>-lifnr   = <fs_file>-tenant_number.
      <fs_message>-message = 'Payee does not exist as Vendor'.
    ENDIF.
    <fs_ep_data>-payee_name                 = <fs_file>-payee_name.
    PERFORM convert_date_internal USING     <fs_file>-sales_date
                                  CHANGING  <fs_ep_data>-sales_date .

    READ TABLE lt_glacc ASSIGNING FIELD-SYMBOL(<fs_glacc>) WITH KEY low = <fs_file>-gl_account.
    IF sy-subrc = 0 .
      <fs_ep_data>-gl_account   = <fs_glacc>-high.
    ELSE.
      <fs_ep_data>-gl_account   = <fs_file>-gl_account.
    ENDIF.

    <fs_ep_data>-amount                     = <fs_file>-amount.
    <fs_ep_data>-waers                      = <fs_file>-waers.
    <fs_ep_data>-exp_remark                 = <fs_file>-exp_remark.
    <fs_ep_data>-invoice_number             = <fs_file>-invoice_number.
    <fs_ep_data>-business_unit_company_code = <fs_file>-business_unit_company_code.
    <fs_ep_data>-business_unit              = <fs_file>-business_unit      .
    <fs_ep_data>-business_unit_state        = <fs_file>-business_unit_state.
    <fs_ep_data>-business_unit_country      = <fs_file>-business_unit_country.
    <fs_ep_data>-tenant_state               = <fs_file>-tenant_state.
    PERFORM convert_date_internal USING     <fs_file>-posting_date
                                  CHANGING  <fs_ep_data>-posting_date .
*    READ TABLE lt_cpec ASSIGNING FIELD-SYMBOL(<fs_cpec>) WITH KEY prctr = <fs_file>-company_code.
*    IF sy-subrc = 0 .
*      <fs_ep_data>-company_code               = <fs_cpec>-bukrs.
*    ELSE.
*      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*        EXPORTING
*          input  = <fs_file>-company_code
*        IMPORTING
*          output = <fs_ep_data>-company_code.
*      APPEND INITIAL LINE TO gt_message ASSIGNING <fs_message>.
*      <fs_message>-edi_trans_no               = <fs_file>-edi_trans_no.
*      <fs_message>-lifnr   = <fs_file>-company_code.
*      <fs_message>-message = 'Invalid profit center'.
*    ENDIF.
    <fs_ep_data>-company_code               = <fs_file>-company_code.
    <fs_ep_data>-document_type              = <fs_file>-document_type.
*   <fs_ep_data>-document_number            = <fs_file>-document_number.
    <fs_ep_data>-comment_                   = <fs_file>-comment_.
    <fs_ep_data>-district                   = <fs_file>-district.
    <fs_ep_data>-senior_district            = <fs_file>-senior_district.
    <fs_ep_data>-division                   = <fs_file>-division.
    <fs_ep_data>-escheat_rule               = <fs_file>-escheat_rule.
    <fs_ep_data>-remit_type                 = <fs_file>-remit_type.
    <fs_ep_data>-holding_period             = <fs_file>-holding_period.
    <fs_ep_data>-HP_UOM                     = <fs_file>-holding_UOM .
    <fs_ep_data>-pi_delay_period            = <fs_file>-pi_delay_period.
    PERFORM convert_date_internal USING     <fs_file>-hp_expire_date
                                 CHANGING  <fs_ep_data>-hp_expire_date .
    PERFORM convert_date_internal USING  <fs_file>-tracker_sent_date
                               CHANGING  <fs_ep_data>-tracker_sent_date .
    <fs_ep_data>-created_by                 = sy-uname .
    <fs_ep_data>-create_date                = sy-datum .
    <fs_ep_data>-create_time                = sy-uzeit .
*    <fs_ep_data>-changed_by                 = <fs_file>-changed_by.
*    PERFORM convert_date_internal USING    <fs_file>-changed_date
*                                 CHANGING  <fs_ep_data>-changed_date .
*    <fs_ep_data>-changed_time               = <fs_file>-changed_time.
  ENDLOOP.


  IF gt_ep_data[] IS NOT INITIAL.
    LOOP AT gt_ep_data ASSIGNING <fs_ep_data> .
      MODIFY zfiap_ep_data FROM <fs_ep_data> .
      IF sy-subrc = 0 .
        COMMIT WORK.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_date_internal
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM convert_date_internal  USING    p_date_i
                            CHANGING p_date_o .


  DATA : lv_month TYPE char02,
         lv_day   TYPE char02,
         lv_year  TYPE char04.

  SPLIT p_date_i AT '/' INTO  lv_month lv_day  lv_year.
  IF lv_year IS NOT INITIAL.
    SHIFT lv_day RIGHT DELETING TRAILING ' ' .
    OVERLAY lv_day WITH '00' .
    CONCATENATE lv_year lv_month lv_day INTO p_date_o.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DISPLAY_Errors
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM display_errors .


  DATA : lcl_hevent           TYPE REF TO lcl_handle_events.

  TRY.
      cl_salv_table=>factory( EXPORTING
        list_display = l_list
      IMPORTING
        r_salv_table = lcl_table
      CHANGING
        t_table = gt_message ).

    CATCH cx_salv_msg INTO lcx_root.
      l_message = lcx_root->get_text( ).
      MESSAGE l_message TYPE 'I'.
      RETURN.
  ENDTRY.


  lcl_functions = lcl_table->get_functions( ).
  lcl_functions->set_all( abap_true ).
  lcl_columns = lcl_table->get_columns( ).
  lcl_column ?= lcl_columns->get_column( 'EDI_TRANS_NO' ).
  lcl_column->set_long_text( 'EDI Trans no' ).
  lcl_column->set_medium_text( 'EDI Trans no' ).
  lcl_column->set_short_text( 'EDI Trans#' ).

  lcl_column ?= lcl_columns->get_column( 'LIFNR' ).
  lcl_column->set_long_text( 'Supplier' ).
  lcl_column->set_medium_text( 'Supplier' ).
  lcl_column->set_short_text( 'Supplier' ).

  lcl_column ?= lcl_columns->get_column( 'MESSAGE' ).
  lcl_column->set_long_text( 'Message' ).
  lcl_column->set_medium_text( 'Message' ).
  lcl_column->set_short_text( 'Message' ).


*-- events
  lcl_columns->set_optimize( abap_true ).
  lcl_event  = lcl_table->get_event( ).
  CREATE OBJECT lcl_hevent.
  SET HANDLER lcl_hevent->on_link_click FOR lcl_event.

* Set titlebar
  CALL METHOD lcl_table->set_screen_status(
    EXPORTING
      report        = sy-repid
      pfstatus      = 'STANDARD'
      set_functions = lcl_table->c_functions_all ).
  lr_selections = lcl_table->get_selections( ).
  lr_selections->set_selection_mode( if_salv_c_selection_mode=>single ).

  lr_selections->set_selection_mode( if_salv_c_selection_mode=>multiple ).

  lcl_layout = lcl_table->get_layout( ).
  lcl_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
  lwa_layout_key-report = sy-repid.
  lcl_layout->set_key( lwa_layout_key ).
  lcl_layout->set_default( abap_true ).
  lcl_sorts = lcl_table->get_sorts( ).
* Set Report title
  lcl_display_settings = lcl_table->get_display_settings( ).
  lcl_table->set_top_of_list( lcl_top_of_page_grid ).
  lcl_table->display( ).




ENDFORM.

class ZCL_MM_PUR_PO_OUTPUT_CALLBACK definition
  public
  final
  create public .

public section.

  interfaces IF_APOC_RECEIVER .
  interfaces IF_BADI_INTERFACE .
  interfaces IF_APOC_BRF_SETTINGS .
  interfaces IF_APOC_COMMON_API .
  interfaces IF_SOMU_BADI_FORM_MASTER .
  interfaces IF_APOC_AUTHORITY .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF lty_auth_check,
        user       TYPE xubname,
        object     TYPE xuobject,
        actvt      TYPE activ_auth,
        field      TYPE xufield,
        fieldvalue TYPE xuval,
        result     LIKE sy-subrc,
      END OF   lty_auth_check .
  types:
    BEGIN OF lty_purchase_order,
            purchase_order TYPE ebeln,
          END OF lty_purchase_order .
  types:
    BEGIN OF lty_partner_address,
            supplier TYPE LIFNR,
            addressid TYPE adrnr,
          END OF lty_partner_address .
  types:
    BEGIN OF lty_partner,
            purchasingdocument TYPE ebeln,
            partnerfunction TYPE parvw,
            supplier TYPE lifnr,
          END OF lty_partner .

  data:
    mt_partner_address TYPE STANDARD TABLE OF lty_partner_address .
  data:
    mt_partner TYPE STANDARD TABLE OF lty_partner .
  class-data:
    mt_authority_check_result TYPE TABLE OF lty_auth_check .

  class-methods PERFORM_AUTHORITY_CHECK
    importing
      !IS_AUTHORITY_CHECK type LTY_AUTH_CHECK
    returning
      value(RV_USER_IS_AUTHORIZED) type XFELD .
  methods GET_PARTNER_SUPPLIER_DATA
    importing
      !IV_EBELN type EBELN
    exporting
      !ES_PARTNER type LTY_PARTNER
      !ES_PARTNER_ADDRESS type LTY_PARTNER_ADDRESS .
ENDCLASS.



CLASS ZCL_MM_PUR_PO_OUTPUT_CALLBACK IMPLEMENTATION.


  METHOD GET_PARTNER_SUPPLIER_DATA.

    CONSTANTS lc_supplier_role TYPE parvw VALUE 'LF'.

    SELECT SINGLE supplieraddressid FROM i_purchaseordersupplieraddress WITH PRIVILEGED ACCESS
          WHERE purchaseorder = @iv_ebeln
          INTO @DATA(ls_supplier_address).
      es_partner_address-addressid = ls_supplier_address.

    SELECT SINGLE supplier FROM i_purchaseorder WITH PRIVILEGED ACCESS
        WHERE purchaseorder = @iv_ebeln
      INTO @DATA(ls_supplier).
    es_partner_address-supplier = ls_supplier.

    es_partner-purchasingdocument = iv_ebeln.
    es_partner-partnerfunction    = lc_supplier_role.
    es_partner-supplier = ls_supplier.

  ENDMETHOD.


METHOD IF_APOC_AUTHORITY~CHECK.
  DATA: lv_ebeln TYPE ebeln.

  lv_ebeln = is_data-appl_object_id.

  rv_authorized = abap_false.


*   perform Authority Check
  cl_mm_pur_po_maint_v2_auth_prv=>check_auth_for_om( EXPORTING iv_ebeln           = lv_ebeln
                                                  RECEIVING rv_user_is_authorized = rv_authorized ).



ENDMETHOD.


  method IF_APOC_BRF_SETTINGS~CHECK_DECISION_TABLE.
  endmethod.


  METHOD IF_APOC_COMMON_API~CHECK_AUTHORITY.

    DATA lo_badi_authority TYPE REF TO apoc_authority.
    DATA ls_data           TYPE if_apoc_authority=>ty_s_auth_data.
    DATA lv_output_param   TYPE apoc_output_parameter.
    DATA lv_activity       TYPE activ_auth.
    DATA lo_msg_collector  TYPE REF TO if_apoc_t100_message_collector.

    " Get BAdI for given Application Object Type
    GET BADI lo_badi_authority FILTERS appl_object_type = is_or_item-appl_object_type.

    " Map data
    ls_data-appl_object_type = is_or_item-appl_object_type.
    ls_data-appl_object_id   = is_or_item-appl_object_id.

    SELECT SINGLE outputparametertext FROM i_outputrequest WITH PRIVILEGED ACCESS
      WHERE outputrequestuuid = @is_or_item-parent_key
      INTO @lv_output_param.

      ls_data-output_parameter = lv_output_param.

      " Map message collector
      lo_msg_collector = CAST #( io_msg_collector ).

      " Map Action Key to Activity
      CASE iv_action_key.
        WHEN if_apoc_output_request_c=>sc_action-item-get_document.
          lv_activity = if_apoc_or_c=>gc_activity_display.
        WHEN if_apoc_output_request_c=>sc_action-item-issue_output.
          lv_activity = if_apoc_or_c=>gc_activity_change.
        WHEN if_apoc_output_request_c=>sc_action-item-preview.
          lv_activity = if_apoc_or_c=>gc_activity_display.
        WHEN if_apoc_output_request_c=>sc_action-item-resend.
          CASE is_or_item-status.
            WHEN if_apoc_or_c=>gc_output_status_error.
              lv_activity = if_apoc_or_c=>gc_activity_change.
            WHEN if_apoc_or_c=>gc_output_status_successful.
              lv_activity = if_apoc_or_c=>gc_activity_create.
          ENDCASE.
      ENDCASE.

      CALL BADI lo_badi_authority->check
        EXPORTING
          is_data                   = ls_data
          iv_activity               = lv_activity
          io_t100_message_collector = lo_msg_collector
        RECEIVING
          rv_authorized             = rv_authorized.

    ENDMETHOD.


METHOD IF_APOC_COMMON_API~GET_DATA_FOR_ROLE.

  DATA lv_language_p        TYPE bu_langu_corr.       " Person: Communication Langague
  DATA lv_language_o        TYPE spras.
  DATA lt_mail              TYPE stty_srt_wsp_adsmtp. " Organization: Language
  DATA lv_supplieraddressid TYPE adrnr.
  DATA lt_purchase_order    TYPE STANDARD TABLE OF lty_purchase_order.
  DATA ls_purchase_order    TYPE lty_purchase_order.
  DATA lt_partners_adrnr    TYPE STANDARD TABLE OF lty_partner_address.
  DATA ls_partners_adrnr    TYPE lty_partner_address.
  DATA lt_partners          TYPE STANDARD TABLE OF lty_partner.
  DATA ls_partners          TYPE lty_partner.
  CONSTANTS lc_supplier_role TYPE parvw VALUE 'LF'.

  IF ct_role_data IS NOT INITIAL.
    LOOP AT ct_role_data INTO DATA(ls_role_data).
      ls_purchase_order = ls_role_data-appl_object_id.
      APPEND ls_purchase_order TO lt_purchase_order.
    ENDLOOP.
    IF lt_purchase_order IS NOT INITIAL.
        IF ls_role_data-role = lc_supplier_role.
          "For supplier role LF, as the address can be updated in purchase order document
          LOOP AT lt_purchase_order INTO DATA(ls_p_order).
            get_partner_supplier_data( EXPORTING iv_ebeln           = ls_p_order-purchase_order
                                       IMPORTING es_partner         = ls_partners
                                                 es_partner_address = ls_partners_adrnr ).
            APPEND ls_partners TO lt_partners.
            APPEND ls_partners_adrnr TO lt_partners_adrnr.
          ENDLOOP.
        ELSE.
          "For other partner fetch the data from Master data
          SELECT purchasingdocument, partnerfunction, supplier FROM i_purchasingdocumentpartner WITH PRIVILEGED ACCESS
            FOR ALL ENTRIES IN @lt_purchase_order WHERE purchasingdocument = @lt_purchase_order-purchase_order INTO TABLE @lt_partners.
          IF sy-subrc EQ 0.
            "Read the partners from the purchase order
            SELECT supplier, addressid FROM i_supplier WITH PRIVILEGED ACCESS
              FOR ALL ENTRIES IN @lt_partners WHERE supplier = @lt_partners-supplier INTO TABLE @lt_partners_adrnr.
          ENDIF.
        ENDIF.
    ENDIF.
    SELECT partner, langu_corr FROM but000 FOR ALL ENTRIES IN @ct_role_data
      WHERE partner = @ct_role_data-id INTO TABLE @DATA(lt_but000).
    IF lt_partners_adrnr IS NOT INITIAL.
* Get country code and language for organization
      SELECT addressid, country, correspondencelanguage FROM i_address WITH PRIVILEGED ACCESS
        FOR ALL ENTRIES IN @lt_partners_adrnr
        WHERE addressid = @lt_partners_adrnr-addressid INTO TABLE @DATA(lt_address).
    ENDIF.

    LOOP AT ct_role_data ASSIGNING FIELD-SYMBOL(<ls_role_data>).
      READ TABLE lt_partners INTO DATA(ls_partner) WITH KEY partnerfunction = <ls_role_data>-role.
      IF sy-subrc EQ 0.
        <ls_role_data>-id = ls_partner-supplier.
        READ TABLE lt_partners_adrnr INTO DATA(ls_partner_adrnr) WITH KEY supplier = ls_partner-supplier.
        IF sy-subrc EQ 0.
          lv_supplieraddressid = ls_partner_adrnr-addressid.
        ENDIF.
        READ TABLE lt_but000 INTO DATA(ls_but000) WITH KEY partner = <ls_role_data>-id.
        IF sy-subrc EQ 0.
          lv_language_p = ls_but000-langu_corr.
        ENDIF.
        READ TABLE lt_address INTO DATA(ls_address) WITH KEY addressid = lv_supplieraddressid.
        IF sy-subrc EQ 0.
          <ls_role_data>-country = ls_address-country.
          lv_language_o = ls_address-correspondencelanguage.
        ENDIF.
*** Set language depending on what has been found
        IF lv_language_p IS NOT INITIAL.
          <ls_role_data>-language = lv_language_p.
        ELSEIF lv_language_o IS NOT INITIAL.
          <ls_role_data>-language = lv_language_o.
        ENDIF.
        IF lv_supplieraddressid IS NOT INITIAL.
*** Set Email address
          TEST-SEAM addr_comm_get_seam.
            CALL FUNCTION 'ADDR_COMM_GET'
              EXPORTING
                address_number    = lv_supplieraddressid
                language          = <ls_role_data>-language
                table_type        = `ADSMTP`
              TABLES
                comm_table        = lt_mail
              EXCEPTIONS
                parameter_error   = 1
                address_not_exist = 2
                internal_error    = 3
                address_blocked   = 4
                OTHERS            = 5.
            IF sy-subrc <> 0.
              CLEAR lt_mail.
            ENDIF.
          END-TEST-SEAM.
          READ TABLE lt_mail WITH KEY flgdefault = abap_true INTO DATA(ls_mail).
          <ls_role_data>-email_uri = ls_mail-smtp_addr.
        ENDIF.
      ENDIF.
    ENDLOOP.
    DELETE ct_role_data WHERE id IS INITIAL.
  ENDIF.
ENDMETHOD.


METHOD IF_APOC_COMMON_API~GET_DATA_FOR_SENDER.
  LOOP AT ct_sender_data REFERENCE INTO DATA(lr_sender_data).
    SELECT SINGLE * FROM i_purchaseorder WITH PRIVILEGED ACCESS
      WHERE purchaseorder = @lr_sender_data->appl_object_id
      INTO @DATA(ls_head).

    lr_sender_data->organization_id   = ls_head-companycode.
    lr_sender_data->organization_type = 'COMPANY'.
    lr_sender_data->org_unit_id       = ls_head-purchasingorganization.
    lr_sender_data->org_unit_type     = 'EKORG'.
*sender Country from EKORG
    SELECT SINGLE country FROM i_companycode WITH PRIVILEGED ACCESS WHERE companycode = @ls_head-companycode INTO @lr_sender_data->country_code.

    SELECT SINGLE * FROM i_purchasinggroup WITH PRIVILEGED ACCESS
      WHERE purchasinggroup = @ls_head-purchasinggroup
      INTO @DATA(ls_purch_group).
    lr_sender_data->email_uri         = ls_purch_group-emailaddress.
  ENDLOOP.
ENDMETHOD.


METHOD IF_APOC_COMMON_API~GET_EMAIL_TEMPLATE_CDS_KEYS.
  DATA ls_cds_key TYPE if_apoc_common_api=>ty_gs_cds_key.

  ls_cds_key-name   = 'PurchaseOrder'.
  ls_cds_key-value  = is_application_object-id.
  INSERT ls_cds_key INTO TABLE et_cds_key.
ENDMETHOD.


METHOD IF_APOC_COMMON_API~GET_FDP_PARAMETER.
  DATA: ls_key           TYPE if_apoc_common_api=>ty_gs_fdp_key,
        lt_key           TYPE if_apoc_common_api=>ty_gt_fdp_key,
        ls_fdp_parameter TYPE if_apoc_common_api=>ty_gs_fdp_parameter.

  CLEAR et_fdp_parameter.

  LOOP AT it_output_request_info REFERENCE INTO DATA(lr_output_request_info).
    CLEAR: lt_key, ls_key, ls_fdp_parameter.

    ls_key-name  = 'PurchaseOrder'.
    ls_key-value = lr_output_request_info->appl_object_id.
    INSERT ls_key INTO TABLE lt_key.

    CLEAR ls_key.
    ls_key-name  = 'SenderCountry'.
    ls_key-value = lr_output_request_info->sender_country.
    INSERT ls_key INTO TABLE lt_key.

    CLEAR ls_key.
    ls_key-name  = 'PurchaseOrderChangeFlag'.
    ls_key-value = lr_output_request_info->change_indicator.
    INSERT ls_key INTO TABLE lt_key.

    CLEAR ls_key.
    ls_key-name  = 'ReceiverPartnerNumber'.
    ls_key-value = lr_output_request_info->receiver_id.
    INSERT ls_key INTO TABLE lt_key.

    ls_fdp_parameter-fdp_srvc_name = lr_output_request_info->fdp_srvc_name.
    ls_fdp_parameter-keys = lt_key.

    INSERT ls_fdp_parameter INTO TABLE et_fdp_parameter.
**                      ENDCASE.
  ENDLOOP.


ENDMETHOD.


                  METHOD IF_APOC_COMMON_API~GET_LEGACY_DATA.

                    DATA    ls_parmbind TYPE abap_parmbind.

                    CLEAR et_legacy_data.


                    ls_parmbind-name = 'KAPPL'.
                    GET REFERENCE OF 'EF' INTO ls_parmbind-value.

                    INSERT ls_parmbind INTO TABLE et_legacy_data.

                    CLEAR ls_parmbind.
                    ls_parmbind-name = 'KSCHL'.
                    GET REFERENCE OF 'NEU ' INTO ls_parmbind-value.
                    INSERT ls_parmbind INTO TABLE et_legacy_data.

                  ENDMETHOD.


  method IF_APOC_COMMON_API~RENDER_DOCUMENT_LEGACY.
  endmethod.


METHOD IF_APOC_RECEIVER~IS_BLOCKED.
  IF iv_receiver_role = if_mm_pur_output_c=>gc_receiver_role_es.
    rv_blocked = abap_false.
  ENDIF.
ENDMETHOD.


METHOD IF_SOMU_BADI_FORM_MASTER~GET_FORM_MASTER_DATA.
  DATA ls_adrs  TYPE adrs_print.
  DATA lv_supplieraddressid TYPE ad_addrnum.
  DATA lc_supplier_role TYPE char2 VALUE 'LF'.

* Sanity Check
  IF iv_appl_object_id IS INITIAL
    OR iv_sender_country IS INITIAL.
    RETURN. "<<<
  ENDIF.
  IF iv_recipient_role = lc_supplier_role OR iv_recipient_role IS INITIAL.
* Get Receiver Address in Print Form
    SELECT SINGLE supplieraddressid FROM i_purchaseordersupplieraddress WITH PRIVILEGED ACCESS
        WHERE purchaseorder = @iv_appl_object_id INTO @lv_supplieraddressid.
  ELSE.
    SELECT partnerfunction, supplier FROM i_purchasingdocumentpartner WITH PRIVILEGED ACCESS
          WHERE purchasingdocument = @iv_appl_object_id INTO TABLE @DATA(lt_partners).
    IF sy-subrc EQ 0.
      READ TABLE lt_partners INTO DATA(ls_partner) WITH KEY partnerfunction = iv_recipient_role.
      IF sy-subrc EQ 0.
        SELECT SINGLE supplieraddressnumber FROM c_purdoclistsuppaddr WITH PRIVILEGED ACCESS
          WHERE supplier = @ls_partner-supplier INTO @lv_supplieraddressid.
      ENDIF.
    ENDIF.
  ENDIF.
**************************************************************
* Temporary and simple workaround for 1805/1808/1811:
* In S4HC we can rely on country ISO code values. This will also work for most OP systems.
*                    DATA: lv_language_country_name TYPE spras.
*                    IF iv_sender_country = 'CN'
*                      OR iv_sender_country = 'JP'
*                      OR iv_sender_country = 'KR' .
*                      lv_language_country_name = 'E'.
*                    ENDIF.
****************************************************************
  IF lv_supplieraddressid IS NOT INITIAL.
    TEST-SEAM address_into_printform_seam.
      CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
        EXPORTING
          address_type        = `1`
          address_number      = lv_supplieraddressid
          "person_number       = ls_vbpa-adrnp
*         receiver_language   = iv_form_template_language
          sender_country      = iv_sender_country
          number_of_lines     = 8
          street_has_priority = abap_false
*         language_for_country_name = lv_language_country_name
        IMPORTING
          address_printform   = ls_adrs.
    END-TEST-SEAM.
* Map Receiver Address
    cs_form_master_data-receiver_address-address_id     = lv_supplieraddressid.
    "cs_form_master_data-receiver_address-person_id      = ls_vbpa-adrnp.
    cs_form_master_data-receiver_address-address_type   = `1`.
    cs_form_master_data-receiver_address-address_line_1 = ls_adrs-line0.
    cs_form_master_data-receiver_address-address_line_2 = ls_adrs-line1.
    cs_form_master_data-receiver_address-address_line_3 = ls_adrs-line2.
    cs_form_master_data-receiver_address-address_line_4 = ls_adrs-line3.
    cs_form_master_data-receiver_address-address_line_5 = ls_adrs-line4.
    cs_form_master_data-receiver_address-address_line_6 = ls_adrs-line5.
    cs_form_master_data-receiver_address-address_line_7 = ls_adrs-line6.
    cs_form_master_data-receiver_address-address_line_8 = ls_adrs-line7.
  ENDIF.

ENDMETHOD.


    METHOD PERFORM_AUTHORITY_CHECK.
  DATA: ls_authority_result TYPE lty_auth_check.
  DATA: ls_authority_check  TYPE lty_auth_check.

*   perform authority check
*   check if authority check was already performed
  READ TABLE mt_authority_check_result
    WITH KEY user       = sy-uname
             object     = is_authority_check-object
             actvt      = is_authority_check-actvt
             field      = is_authority_check-field
             fieldvalue = is_authority_check-fieldvalue
    INTO ls_authority_result TRANSPORTING result.
  IF sy-subrc = 0.
*     check already performed: set returning parameter to 'X' in case user has authority
    IF ls_authority_result-result = 0.
      rv_user_is_authorized = abap_true.
    ENDIF.
  ELSE.
*     check not yet performed: perform authority check now
    AUTHORITY-CHECK OBJECT is_authority_check-object
      ID 'ACTVT'                  FIELD is_authority_check-actvt
      ID is_authority_check-field FIELD is_authority_check-fieldvalue.
    DATA(lv_authority_check_result) = sy-subrc.

*     append current record to MT_AUTHORITY_CHECK_RESULT
    MOVE-CORRESPONDING is_authority_check TO ls_authority_check.
    ls_authority_check-result = lv_authority_check_result.
    ls_authority_check-user   = sy-uname.
    APPEND ls_authority_check TO mt_authority_check_result.

*     set returning parameter to 'X' in case user has authority
    IF ls_authority_check-result = 0.
      rv_user_is_authorized = abap_true.
    ENDIF.
  ENDIF.
ENDMETHOD.
ENDCLASS.

CLASS ltc_unit_tests DEFINITION DEFERRED.
CLASS zcl_mm_pur_po_output_callback DEFINITION LOCAL FRIENDS ltc_unit_tests.

CLASS ltc_unit_tests DEFINITION FINAL FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_/bobf/act_key,
        /bobf/act_key TYPE /bobf/act_key,
      END OF   ty_/bobf/act_key .
    CLASS-DATA:environment TYPE REF TO if_osql_test_environment.
    CLASS-DATA:mv_ponumber TYPE        ebeln.

    CLASS-METHODS:class_setup.
    CLASS-METHODS:class_teardown.

    DATA:f_cut              TYPE REF TO            cl_mm_pur_po_output_callback.
    DATA:lt_puordsupadd     TYPE STANDARD TABLE OF i_purchaseordersupplieraddress.
    DATA:lt_address         TYPE STANDARD TABLE OF i_address.
    DATA:lt_purchaseorder   TYPE STANDARD TABLE OF i_purchaseorder.
    DATA:lt_but000          TYPE STANDARD TABLE OF but000.
    DATA:lt_puord_op_params TYPE STANDARD TABLE OF m_v_purchord_output_params.
    DATA:lt_companycode     TYPE STANDARD TABLE OF i_companycode.
    DATA:lt_purchasinggroup TYPE STANDARD TABLE OF i_purchasinggroup.
    DATA:lt_outputrequest   TYPE STANDARD TABLE OF i_outputrequest.
*    DATA lt_po_supplier      TYPE STANDARD TABLE OF i_purchaseordersupplieraddress.
    DATA lt_partner_supplier TYPE STANDARD TABLE OF i_supplier.

    METHODS:setup,teardown.
    METHODS:check                        FOR TESTING.
*    METHODS:get_form_master_data         FOR TESTING.
    METHODS:initial_get_form_master_data FOR TESTING,
            suplr_get_form_master_data FOR TESTING,
            OA_get_form_master_data FOR TESTING.

    METHODS:get_fdp_parameter            FOR TESTING.
    METHODS:get_data_for_role            FOR TESTING.
    METHODS:no_partners_get_data_for_role FOR TESTING.
    METHODS get_data_for_role_oa_partner FOR TESTING.
    METHODS:get_data_for_sender          FOR TESTING.
    METHODS:get_email_template_cds_keys  FOR TESTING.
    METHODS:get_legacy_data              FOR TESTING.
    METHODS:perform_authority_check      FOR TESTING.
    METHODS:is_blocked                   FOR TESTING.
    METHODS:check_authority              FOR TESTING.

ENDCLASS.


CLASS ltc_message_collector DEFINITION.
  PUBLIC SECTION.
    INTERFACES: if_apoc_t100_message_collector,
      if_apoc_basic_mess_collector.
ENDCLASS.


CLASS ltc_unit_tests IMPLEMENTATION.

  METHOD class_setup.

    environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'i_purchaseorder'   )
                                                                                 ( 'i_purchaseordersupplieraddress'   ) ( 'but000' )
                                                                                 ( 'i_address' ) ( 'm_v_purchord_output_params' ) ( 'I_COMPANYCODE' )
                                                                                 ( 'I_PurchasingGroup' ) ( 'i_outputrequest' ) ( 'i_purchasingdocumentpartner' ) ( 'c_purdoclistsuppaddr' )
                                                                                 ( 'i_supplier' ) )  ).

    mv_ponumber = '4500070473'.

  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).

  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
    CREATE OBJECT f_cut.
  ENDMETHOD.

  METHOD teardown.
    FREE:lt_puordsupadd,
         lt_but000,lt_address,
         lt_purchaseorder,
         lt_puord_op_params,
         lt_companycode,
         lt_purchasinggroup,
         lt_outputrequest.
  ENDMETHOD.

  METHOD check.
    DATA is_data                   TYPE        if_apoc_authority=>ty_s_auth_data.
    DATA iv_activity               TYPE        activ_auth.
    DATA io_t100_message_collector TYPE REF TO if_apoc_t100_message_collector.
    DATA rv_authorized             TYPE         abap_bool.

    is_data-appl_object_id = mv_ponumber.
    lt_puord_op_params = VALUE #( ( purchaseorder = '4500070473' purchaseordertype = 'NB' purchasingorganization = '0001' purchasinggroup = '001' ) ).
    environment->insert_test_data( lt_puord_op_params ).

    rv_authorized = f_cut->if_apoc_authority~check(
    is_data = is_data
*        IV_ACTION_NAME = iv_Action_Name
    iv_activity = iv_activity
    io_t100_message_collector = io_t100_message_collector ).

    cl_abap_unit_assert=>assert_equals(
     EXPORTING
       act                  =  'X'
       exp                  =  'X'
        ).
  ENDMETHOD.

*  METHOD get_form_master_data.
*    DATA:io_msg_collector    TYPE REF TO if_apoc_basic_mess_collector,
*         lv_appl_object_type TYPE        char30,
*         lv_appl_object_id   TYPE        char255,
*         lv_sender_country   TYPE        land1,
*         ct_form_master_data TYPE        if_somu_badi_form_master=>ty_gs_fm_appl_data.
*
*    lv_appl_object_id = mv_ponumber.
*    lv_sender_country = 'KR'.
*
*    lt_puordsupadd = VALUE #( ( purchaseorder = '4500070473' supplieraddressid = '668571' purchaseordertype = 'NB'
*                                purchasingorganization = '0001' purchasinggroup = '001' ) ).
*    environment->insert_test_data( lt_puordsupadd ).
*
*    TEST-INJECTION address_into_printform_seam.
*      ls_adrs-line0 = 'Epcos'.
*      ls_adrs-line1 = 'Epcos 2'.
*      ls_adrs-line2 = 'Epcos 3'.
*      ls_adrs-line3 = 'Epcos 4'.
*      ls_adrs-line4 = 'Epcos AG'.
*      ls_adrs-line5 = 'AG Epcos 2'.
*      ls_adrs-line6 = 'Kemet Corp'.
*      ls_adrs-line7 = 'Asia General Electronics Co., Ltd'.
*    END-TEST-INJECTION.
*    f_cut->if_somu_badi_form_master~get_form_master_data(
*       EXPORTING
*          iv_appl_object_type       =  lv_appl_object_type
*          iv_appl_object_id         =  lv_appl_object_id
*          iv_sender_country         =  lv_sender_country
*          iv_form_template_country  =  lv_sender_country
*          iv_form_template_language =  sy-langu
*          iv_recipient_role         =  ''
*       CHANGING
*          cs_form_master_data       = ct_form_master_data
*             ).
*
*    cl_abap_unit_assert=>assert_equals(
*       EXPORTING
*         act                  =  '668571'
*         exp                  =  ct_form_master_data-receiver_address-address_id
*           ).
*  ENDMETHOD.
  METHOD initial_get_form_master_data.
    DATA:lv_appl_object_type TYPE        char30,
         lv_appl_object_id   TYPE        char255,
         lv_sender_country   TYPE        land1,
         ct_form_master_data TYPE        if_somu_badi_form_master=>ty_gs_fm_appl_data.

    f_cut->if_somu_badi_form_master~get_form_master_data(
      EXPORTING
        iv_appl_object_type       =  lv_appl_object_type
        iv_appl_object_id         =  lv_appl_object_id
        iv_sender_country         =  lv_sender_country
        iv_form_template_country  =  lv_sender_country
        iv_form_template_language =  sy-langu
        iv_recipient_role         =  ''
      CHANGING
        cs_form_master_data       = ct_form_master_data
           ).
    cl_abap_unit_assert=>assert_initial(
       EXPORTING
         act              = sy-subrc
            ).

  ENDMETHOD.

  METHOD suplr_get_form_master_data.

    DATA: lv_appl_object_type TYPE        char30,
          lv_appl_object_id   TYPE        char255,
          lv_sender_country   TYPE        land1,
          ls_expected         TYPE        sfm_s_form_address,
          ct_form_master_data TYPE        if_somu_badi_form_master=>ty_gs_fm_appl_data,
          lt_purchasingdocpartner TYPE STANDARD TABLE OF i_purchasingdocumentpartner,
          lt_purdoclistsuppaddr   TYPE STANDARD TABLE OF c_purdoclistsuppaddr.

    lv_appl_object_id = '1123456789'.
    lv_sender_country = 'US'.

*     er_entity-adrnr = 'SUPPLIER1'.
*    er_entity-name1 = 'OrderingAddress'.
*    er_entity-tel_number = '123456789'.
*    er_entity-telfx = '080-123-456'.
*    er_entity-smtp_addr = 'orderingaddress@sap.com'.
    ls_expected-address_type = '1'.
    ls_expected-address_id = '56789'.
    ls_expected-address_line_1 = '138'.
    ls_expected-address_line_2 = 'street 14'.

    lt_puordsupadd = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
    environment->insert_test_data( lt_puordsupadd ).

    lt_purchasingdocpartner = VALUE #( ( purchasingdocument = '0123456789' purchasingorganization = '0001' partnerfunction = 'BA' supplier = 'SUPPLIER1')
                                 ( purchasingdocument = '1123456789' purchasingorganization = '0001' partnerfunction = 'LF' supplier = 'SUPPLIER2')
                                 ).
    environment->insert_test_data( lt_purchasingdocpartner ).

    lt_purdoclistsuppaddr = VALUE #( ( supplier = 'SUPPLIER1' supplieraddressnumber = '1234' supplieraddressname = 'OrderingAddress' supplieraddressphonenumber = '123456789' supplieraddressfaxnumber = '080-123-456')
                                     ( supplier = 'SUPPLIER2' supplieraddressnumber = '56789' supplieraddressname = 'SupplierAddress' supplieraddressphonenumber = '9876543210' supplieraddressfaxnumber = '040-456-789') ) .

    environment->insert_test_data( lt_purdoclistsuppaddr ).

    TEST-INJECTION address_into_printform_seam.
      ls_adrs-line0 = '138'.
      ls_adrs-line1 = 'street 14'.
    END-test-INJECTION.


    f_cut->if_somu_badi_form_master~get_form_master_data(
      EXPORTING
        iv_appl_object_type       =  lv_appl_object_type
        iv_appl_object_id         =  lv_appl_object_id
        iv_sender_country         =  lv_sender_country
        iv_form_template_country  =  lv_sender_country
        iv_form_template_language =  sy-langu
        iv_recipient_role         =  'LF'
      CHANGING
        cs_form_master_data       = ct_form_master_data
           ).
    cl_abap_unit_assert=>assert_equals(
       EXPORTING
         act              = ct_form_master_data-receiver_address
         exp              = ls_expected
            ).
  ENDMETHOD.

  METHOD oa_get_form_master_data.

    DATA: lv_appl_object_type TYPE        char30,
          lv_appl_object_id   TYPE        char255,
          lv_sender_country   TYPE        land1,
          ls_expected         TYPE        sfm_s_form_address,
          ct_form_master_data TYPE        if_somu_badi_form_master=>ty_gs_fm_appl_data,
          lt_purchasingdocpartner TYPE STANDARD TABLE OF i_purchasingdocumentpartner,
          lt_purdoclistsuppaddr   TYPE STANDARD TABLE OF c_purdoclistsuppaddr.

    lv_appl_object_id = '0123456789'.
    lv_sender_country = 'US'.

*     er_entity-adrnr = 'SUPPLIER1'.
*    er_entity-name1 = 'OrderingAddress'.
*    er_entity-tel_number = '123456789'.
*    er_entity-telfx = '080-123-456'.
*    er_entity-smtp_addr = 'orderingaddress@sap.com'.
    ls_expected-address_type = '1'.
    ls_expected-address_id = '1234'.
    ls_expected-address_line_1 = '138'.
    ls_expected-address_line_2 = 'street 14'.

    lt_puordsupadd = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '34567' )
                              ( purchaseorder = '0123456789' supplieraddressid = '56789' ) ).
    environment->insert_test_data( lt_puordsupadd ).

    lt_purchasingdocpartner = VALUE #( ( purchasingdocument = '0123456789' purchasingorganization = '0001' partnerfunction = 'BA' supplier = 'SUPPLIER1')
                                 ( purchasingdocument = '1123456789' purchasingorganization = '0001' partnerfunction = 'LF' supplier = 'SUPPLIER2')
                                 ).
    environment->insert_test_data( lt_purchasingdocpartner ).

    lt_purdoclistsuppaddr = VALUE #( ( supplier = 'SUPPLIER1' supplieraddressnumber = '1234' supplieraddressname = 'OrderingAddress' supplieraddressphonenumber = '123456789' supplieraddressfaxnumber = '080-123-456')
                                     ( supplier = 'SUPPLIER2' supplieraddressnumber = '56789' supplieraddressname = 'SupplierAddress' supplieraddressphonenumber = '9876543210' supplieraddressfaxnumber = '040-456-789') ) .

    environment->insert_test_data( lt_purdoclistsuppaddr ).

    TEST-INJECTION address_into_printform_seam.
      ls_adrs-line0 = '138'.
      ls_adrs-line1 = 'street 14'.
    END-test-INJECTION.


    f_cut->if_somu_badi_form_master~get_form_master_data(
      EXPORTING
        iv_appl_object_type       =  lv_appl_object_type
        iv_appl_object_id         =  lv_appl_object_id
        iv_sender_country         =  lv_sender_country
        iv_form_template_country  =  lv_sender_country
        iv_form_template_language =  sy-langu
        iv_recipient_role         =  'BA'
      CHANGING
        cs_form_master_data       = ct_form_master_data
           ).
    cl_abap_unit_assert=>assert_equals(
       EXPORTING
         act              = ct_form_master_data-receiver_address
         exp              = ls_expected
            ).
  ENDMETHOD.


  METHOD get_fdp_parameter.
    DATA it_output_request_info TYPE        if_apoc_common_api=>ty_gt_output_request_info.
    DATA et_fdp_parameter       TYPE        if_apoc_common_api=>ty_gt_fdp_parameter.
    DATA ls_output_request_info TYPE        if_apoc_common_api=>ty_gs_output_request_info.

    ls_output_request_info-fdp_srvc_name = 'FDP_EF_PURCHASE_ORDER_SRV'.
    ls_output_request_info-appl_object_id = '4500070473'.
    ls_output_request_info-sender_country = 'IN'.
    ls_output_request_info-change_indicator = 'X'.
    APPEND ls_output_request_info TO it_output_request_info.

    f_cut->if_apoc_common_api~get_fdp_parameter(
       EXPORTING
       it_output_request_info = it_output_request_info
*           IO_MSG_COLLECTOR = io_Msg_Collector
         IMPORTING
           et_fdp_parameter = et_fdp_parameter
         ).
    READ TABLE et_fdp_parameter INTO DATA(ls_fdp_parameter) INDEX 1.
    cl_abap_unit_assert=>assert_equals(
       act   = 'FDP_EF_PURCHASE_ORDER_SRV'
       exp   = ls_fdp_parameter-fdp_srvc_name          "<--- please adapt expected value
       " msg   = 'Testing value et_Fdp_Parameter'
*         level =
         ).
  ENDMETHOD.


  METHOD get_data_for_role.
    DATA ct_role_data     TYPE        if_apoc_common_api=>ty_gt_role_data.
    DATA ls_role_data     TYPE        if_apoc_common_api=>ty_gs_role_data.
    DATA: lv_ponumber TYPE ebeln,
          lt_purchasingdocpartner TYPE STANDARD TABLE OF i_purchasingdocumentpartner,
          lt_purdoclistsuppaddr   TYPE STANDARD TABLE OF c_purdoclistsuppaddr.

    lv_ponumber = '1123456789'.
    lt_puordsupadd = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
    environment->insert_test_data( lt_puordsupadd ).

    lt_purchasingdocpartner = VALUE #( ( purchasingdocument = '0123456789' purchasingorganization = '0001' partnerfunction = 'BA' supplier = 'SUPPLIER1')
                                 ( purchasingdocument = '1123456789' purchasingorganization = '0001' partnerfunction = 'LF' supplier = 'SUPPLIER2')
                                 ).
    environment->insert_test_data( lt_purchasingdocpartner ).

    lt_purdoclistsuppaddr = VALUE #( ( supplier = 'SUPPLIER1' supplieraddressnumber = '1234' supplieraddressname = 'OrderingAddress' supplieraddressphonenumber = '123456789' supplieraddressfaxnumber = '080-123-456')
                                     ( supplier = 'SUPPLIER2' supplieraddressnumber = '56789' supplieraddressname = 'SupplierAddress' supplieraddressphonenumber = '9876543210' supplieraddressfaxnumber = '040-456-789') ) .
    environment->insert_test_data( lt_purdoclistsuppaddr ).

    lt_but000 = VALUE #( ( partner = 'SUPPLIER1' type = '2' langu_corr = 'EN' ) ).
    environment->insert_test_data( lt_but000 ).

    lt_address =  VALUE #( ( person = 'person1' addressid = '1234' country = 'US' correspondencelanguage = 'EN' )
                           ( person = 'person2' addressid = '56789' country = 'DE' correspondencelanguage = 'DE' ) ).
    environment->insert_test_data( lt_address ).

    lt_partner_supplier = VALUE #( ( supplier = 'SUPPLIER2' addressid = '56789' ) ).
    environment->insert_test_data( lt_partner_supplier ).

*    lt_po_supplier = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
*    environment->insert_test_data( lt_po_supplier ).

    lt_purchaseorder = VALUE #( ( purchaseorder = '1123456789'  supplier = 'SUPPLIER2' ) ).
    environment->insert_test_data( lt_purchaseorder ).


    ls_role_data-appl_object_id = lv_ponumber.
    ls_role_data-role = 'LF'.
    APPEND ls_role_data TO ct_role_data.

    TEST-INJECTION addr_comm_get_seam.
      lt_mail = VALUE #( ( flgdefault = abap_true smtp_addr = 'purchaser@sap.com' ) ).
    END-TEST-INJECTION.
    f_cut->if_apoc_common_api~get_data_for_role(
*          EXPORTING
*            IO_MSG_COLLECTOR = io_Msg_Collector
       CHANGING
         ct_role_data = ct_role_data ).
    READ TABLE ct_role_data INTO ls_role_data INDEX 1.
    cl_abap_unit_assert=>assert_equals(
        exp   = 'purchaser@sap.com'
        act   = ls_role_data-email_uri         "<--- please adapt expected value
       " msg   = 'Testing value ct_Role_Data'
*          level =
          ).
  ENDMETHOD.

  METHOD no_partners_get_data_for_role.
    DATA ct_role_data     TYPE        if_apoc_common_api=>ty_gt_role_data.
    DATA ls_role_data     TYPE        if_apoc_common_api=>ty_gs_role_data.
    DATA: lv_ponumber TYPE ebeln,
          lt_purchasingdocpartner TYPE STANDARD TABLE OF i_purchasingdocumentpartner,
          lt_posuplieradrc TYPE STANDARD TABLE OF i_purchaseordersupplieraddress,
          lt_purdoclistsuppaddr   TYPE STANDARD TABLE OF c_purdoclistsuppaddr.

    lv_ponumber = '1123456789'.
    lt_posuplieradrc = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
    environment->insert_test_data( lt_posuplieradrc ).

    lt_purchasingdocpartner = VALUE #( ( purchasingdocument = '9988776655' purchasingorganization = '0001' partnerfunction = 'BA' supplier = 'SUPPLIER1')
                                 ( purchasingdocument = '4433221100' purchasingorganization = '0001' partnerfunction = 'LF' supplier = 'SUPPLIER2')
                                 ).
    environment->insert_test_data( lt_purchasingdocpartner ).

    lt_purchaseorder = VALUE #( ( purchaseorder = '1123456789'  supplier = 'SUPPLIER2' ) ).
    environment->insert_test_data( lt_purchaseorder ).

    lt_but000 = VALUE #( ( partner = 'SUPPLIER1' type = '2' langu_corr = 'EN' ) ).
    environment->insert_test_data( lt_but000 ).

    lt_address =  VALUE #( ( person = 'person1' addressid = '1234' country = 'US' correspondencelanguage = 'EN' )
                           ( person = 'person2' addressid = '56789' country = 'DE' correspondencelanguage = 'DE' ) ).
    environment->insert_test_data( lt_address ).

    ls_role_data-appl_object_id = lv_ponumber.
    ls_role_data-role = 'LF'.
    APPEND ls_role_data TO ct_role_data.

    TEST-INJECTION addr_comm_get_seam.
      lt_mail = VALUE #( ( flgdefault = abap_true smtp_addr = 'purchaser@sap.com' ) ).
    END-TEST-INJECTION.
    f_cut->if_apoc_common_api~get_data_for_role(
*          EXPORTING
*            IO_MSG_COLLECTOR = io_Msg_Collector
       CHANGING
         ct_role_data = ct_role_data ).
    READ TABLE ct_role_data INTO ls_role_data INDEX 1.
    cl_abap_unit_assert=>assert_equals(
        exp   = 'purchaser@sap.com'
        act   = ls_role_data-email_uri         "<--- please adapt expected value
       " msg   = 'Testing value ct_Role_Data'
*          level =
          ).
  ENDMETHOD.

  METHOD get_data_for_sender.
    DATA ct_sender_data TYPE if_apoc_common_api=>ty_gt_sender_data.
    DATA lt_sender_data TYPE if_apoc_common_api=>ty_gt_sender_data.
    DATA ls_sender_data TYPE if_apoc_common_api=>ty_gs_sender_data.

    ls_sender_data-appl_object_id = mv_ponumber.
    APPEND ls_sender_data TO ct_sender_data.
    lt_purchaseorder = VALUE #( ( purchaseorder = '4500070473'  companycode = '0001' purchasingorganization = '0001' purchasinggroup = '001' ) ).
    environment->insert_test_data( lt_purchaseorder ).
    lt_companycode = VALUE #( ( companycode = '0001' country = 'DE' ) ).
    environment->insert_test_data( lt_companycode ).
    lt_purchasinggroup = VALUE #( ( purchasinggroup = '001' emailaddress = 'purchaser@sap.com' ) ).
    environment->insert_test_data( lt_purchasinggroup ).
    lt_sender_data = VALUE #( ( appl_object_id = '4500070473' organization_id = '0001' organization_type = 'COMPANY' org_unit_id  = '0001'
                                org_unit_type = 'EKORG' country_code = 'DE' email_uri = 'purchaser@sap.com' ) ).

    f_cut->if_apoc_common_api~get_data_for_sender(
      CHANGING
        ct_sender_data = ct_sender_data ).

    cl_abap_unit_assert=>assert_equals(
      act   = lt_sender_data
      exp   = ct_sender_data          "<--- please adapt expected value
    ).
  ENDMETHOD.

  METHOD get_email_template_cds_keys.
    DATA is_application_object TYPE if_apoc_common_api=>ty_gs_application_object.
    DATA iv_cds_view_name TYPE char30.
    DATA et_cds_key TYPE if_apoc_common_api=>ty_gt_cds_key.
    DATA lt_cds_key TYPE if_apoc_common_api=>ty_gt_cds_key.

    lt_cds_key = VALUE #( ( name = 'PurchaseOrder' ) ).

    f_cut->if_apoc_common_api~get_email_template_cds_keys(
      EXPORTING
        is_application_object = is_application_object
        iv_cds_view_name = iv_cds_view_name
*       IO_MSG_COLLECTOR = io_Msg_Collector
     IMPORTING
       et_cds_key = et_cds_key
    ).

    cl_abap_unit_assert=>assert_equals(
      act   = lt_cds_key
      exp   = et_cds_key          "<--- please adapt expected value
    ).
  ENDMETHOD.
  METHOD get_legacy_data.
    DATA is_or_item TYPE apoc_s_or_item.
    DATA et_legacy_data TYPE abap_parmbind_tab.
    DATA lt_legacy_data TYPE abap_parmbind_tab.
    DATA ls_parmbind TYPE abap_parmbind.
*    lt_legacy_data = VALUE #( ( name = 'KAPPL' ) ( name = 'KSCHL') ).
    ls_parmbind-name = 'KAPPL'.
    GET REFERENCE OF 'EF' INTO ls_parmbind-value.
    INSERT ls_parmbind INTO TABLE lt_legacy_data.
    CLEAR ls_parmbind.

    ls_parmbind-name = 'KSCHL'.
    GET REFERENCE OF 'NEU ' INTO ls_parmbind-value.
    INSERT ls_parmbind INTO TABLE lt_legacy_data.
    CLEAR ls_parmbind.

    f_cut->if_apoc_common_api~get_legacy_data(
      EXPORTING
        is_or_item = is_or_item
     IMPORTING
       et_legacy_data = et_legacy_data
    ).

    cl_abap_unit_assert=>assert_equals(
      act   = lt_legacy_data
      exp   = et_legacy_data          "<--- please adapt expected value
    ).
  ENDMETHOD.

  METHOD perform_authority_check.
    DATA is_authority_check TYPE zcl_mm_pur_po_output_callback=>lty_auth_check.
    DATA rv_user_is_authorized TYPE xfeld.

    is_authority_check-object = ''.
    is_authority_check-actvt = ''.
    is_authority_check-fieldvalue = ''.

    rv_user_is_authorized = zcl_mm_pur_po_output_callback=>perform_authority_check( is_authority_check ).

    cl_abap_unit_assert=>assert_equals(
      act   = abap_false
      exp   = rv_user_is_authorized          "<--- please adapt expected value
    " msg   = 'Testing value rv_User_Is_Authorized'
    ).
  ENDMETHOD.
  METHOD is_blocked.
    DATA:lv_receiver_id    TYPE apoc_receiver_id,
         lv_appl_object_id TYPE apoc_appl_object_id,
         lv_receiver_role  TYPE  apoc_role_code VALUE 'ES',
         rv_blocked        TYPE xfeld.

    f_cut->if_apoc_receiver~is_blocked(
      EXPORTING
        iv_appl_object_id =  lv_appl_object_id                " Application Object ID
        iv_receiver_id    =  lv_receiver_id                " Recipient ID
        iv_receiver_role  =  lv_receiver_role                " Role Code
    RECEIVING
      rv_blocked        =   rv_blocked               " Is blocked (yes/no)
    ).
    cl_aunit_assert=>assert_equals(
      EXPORTING
        exp                  = rv_blocked                                    " Data Object with Expected Type
        act                  =  abap_false                                   " Data Object with Current Value
    ).

  ENDMETHOD.
  METHOD check_authority.
    DATA: lo_message_collector TYPE REF TO ltc_message_collector,
          lv_ponumber          TYPE        ebeln,
          ls_item              TYPE        apoc_s_or_item,
          lt_act_key           TYPE STANDARD TABLE OF ty_/bobf/act_key,
          lo_auth_check        TYPE REF TO cl_mm_pur_po_output_callback,
          lv_authorized        TYPE        abap_bool.
    lt_act_key = VALUE #( ( /bobf/act_key = '005056BA4F0D1ED4A7ABD052CA63009F' ) ( /bobf/act_key = '005056917F6C1EE49BDF69D12D5C10CE' )
                                             ( /bobf/act_key = '005056BA72D51ED48EC9BBA035A5CF8F' ) ( /bobf/act_key = '005056BA72D51ED48EC9BD359BF28F95' ) ).
    lt_outputrequest = VALUE #( ( outputrequestuuid = '005056AC156F1ED5B0852374BBEBDE66' outputparametertext = ' ' ) ).
    environment->insert_test_data( lt_outputrequest ).
    CREATE OBJECT lo_message_collector.
    lv_ponumber = cl_mmpur_create_test_pos=>create_po( ).
    ls_item-appl_object_type = 'PURCHASE_ORDER'.
    ls_item-appl_object_id = lv_ponumber.
    ls_item-parent_key = '005056AC156F1ED5B0852374BBEBDE66'.
    CREATE OBJECT lo_auth_check.
    LOOP AT lt_act_key INTO DATA(ls_act_key).
      IF ls_act_key-/bobf/act_key = '005056BA72D51ED48EC9BD359BF28F95'.
        ls_item-status = '4'.
      ENDIF.

      lo_auth_check->if_apoc_common_api~check_authority( EXPORTING is_or_item    = ls_item
                                                              iv_action_key     = ls_act_key-/bobf/act_key
                                                              io_msg_collector  = lo_message_collector
                                                    RECEIVING rv_authorized     = lv_authorized ).
      IF ls_item-item_id = '00010'.
        cl_aunit_assert=>assert_equals(
                         exp = abap_true
                         act = lv_authorized
                         msg = 'PO should have authorizations for output' ).
      ELSE.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.




  METHOD get_data_for_role_oa_partner.
    DATA ct_role_data     TYPE        if_apoc_common_api=>ty_gt_role_data.
    DATA ls_role_data     TYPE        if_apoc_common_api=>ty_gs_role_data.
    DATA: lv_ponumber TYPE ebeln,
          lt_purchasingdocpartner TYPE STANDARD TABLE OF i_purchasingdocumentpartner,
          lt_purdoclistsuppaddr   TYPE STANDARD TABLE OF c_purdoclistsuppaddr.

    lv_ponumber = '1123456789'.
    lt_puordsupadd = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
    environment->insert_test_data( lt_puordsupadd ).

    lt_purchasingdocpartner = VALUE #( ( purchasingdocument = '1123456789' purchasingorganization = '0001' partnerfunction = 'BA' supplier = 'SUPPLIER1')
                                 ( purchasingdocument = '1123456789' purchasingorganization = '0001' partnerfunction = 'LF' supplier = 'SUPPLIER2')
                                 ).
    environment->insert_test_data( lt_purchasingdocpartner ).

    lt_purdoclistsuppaddr = VALUE #( ( supplier = 'SUPPLIER1' supplieraddressnumber = '1234' supplieraddressname = 'OrderingAddress' supplieraddressphonenumber = '123456789' supplieraddressfaxnumber = '080-123-456')
                                     ( supplier = 'SUPPLIER2' supplieraddressnumber = '56789' supplieraddressname = 'SupplierAddress' supplieraddressphonenumber = '9876543210' supplieraddressfaxnumber = '040-456-789') ) .
    environment->insert_test_data( lt_purdoclistsuppaddr ).

    lt_but000 = VALUE #( ( partner = 'SUPPLIER1' type = '2' langu_corr = 'EN' ) ).
    environment->insert_test_data( lt_but000 ).

    lt_address =  VALUE #( ( person = 'person1' addressid = '1234' country = 'US' correspondencelanguage = 'EN' )
                           ( person = 'person2' addressid = '56789' country = 'DE' correspondencelanguage = 'DE' ) ).
    environment->insert_test_data( lt_address ).

    lt_partner_supplier = VALUE #( ( supplier = 'SUPPLIER1' addressid = '56789' ) ).
    environment->insert_test_data( lt_partner_supplier ).

*    lt_po_supplier = VALUE #( ( purchaseorder = '1123456789' supplieraddressid = '56789' ) ).
*    environment->insert_test_data( lt_po_supplier ).

    lt_purchaseorder = VALUE #( ( purchaseorder = '1123456789'  supplier = 'SUPPLIER1' ) ).
    environment->insert_test_data( lt_purchaseorder ).


    ls_role_data-appl_object_id = lv_ponumber.
    ls_role_data-role = 'BA'.
    APPEND ls_role_data TO ct_role_data.

    TEST-INJECTION addr_comm_get_seam.
      lt_mail = VALUE #( ( flgdefault = abap_true smtp_addr = 'purchaser@sap.com' ) ).
    END-TEST-INJECTION.
    f_cut->if_apoc_common_api~get_data_for_role(
*          EXPORTING
*            IO_MSG_COLLECTOR = io_Msg_Collector
       CHANGING
         ct_role_data = ct_role_data ).
    READ TABLE ct_role_data INTO ls_role_data INDEX 1.
    cl_abap_unit_assert=>assert_equals(
        exp   = 'purchaser@sap.com'
        act   = ls_role_data-email_uri         "<--- please adapt expected value
       " msg   = 'Testing value ct_Role_Data'
*          level =
          ).
  ENDMETHOD.

ENDCLASS.

CLASS ltc_message_collector IMPLEMENTATION.
  METHOD if_apoc_basic_mess_collector~add_t100_message.
  ENDMETHOD.
  METHOD if_apoc_basic_mess_collector~add_message_from_single_excep.
  ENDMETHOD.
  METHOD if_apoc_basic_mess_collector~has_messages.
  ENDMETHOD.
  METHOD if_apoc_t100_message_collector~add_bobf_frw_msg.
  ENDMETHOD.
  METHOD if_apoc_t100_message_collector~get_highest_severity.
  ENDMETHOD.
ENDCLASS.

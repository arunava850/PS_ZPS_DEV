*"* use this source file for your ABAP unit test classes

CLASS ltc_fins_uh_hrrp_pc_legacy DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>ltc_Fins_Uh_Hrrp_Pc_Legacy
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_FINS_UH_HRRP_PC_LEGACY
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_cut TYPE REF TO cl_fins_uh_hrrp_pc_legacy.  "class under test
    CLASS-DATA:
      environment TYPE REF TO if_osql_test_environment.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.

    METHODS: setup.
    METHODS: teardown.
    CLASS-DATA:
      so_uh_third_party_api_mock TYPE REF TO if_fins_uh_third_party_api,
      so_uh_authority_check_mock TYPE REF TO if_fins_uh_authority_check.
    METHODS: prepare_test_data.

    METHODS: import_set_desc_value FOR TESTING.
    METHODS: import_set_no_desc FOR TESTING.
    METHODS: import_set_no_value FOR TESTING.

    METHODS: import_sets FOR TESTING.

    METHODS: select_sets FOR TESTING.
    METHODS: select_sets_with_date_range FOR TESTING.
    METHODS: select_sets_by_name FOR TESTING.
    METHODS: select_sets_ranges FOR TESTING.
ENDCLASS.       "ltc_Fins_Uh_Hrrp_Pc_Legacy


CLASS ltc_fins_uh_hrrp_pc_legacy IMPLEMENTATION.
  METHOD class_setup.
    so_uh_third_party_api_mock ?= cl_abap_testdouble=>create('IF_FINS_UH_THIRD_PARTY_API').
    so_uh_authority_check_mock ?= cl_abap_testdouble=>create('IF_FINS_UH_AUTHORITY_CHECK').
    environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'hrrp_node' )
                                                                                 ( 'hrrp_directory' )
                                                                                 ( 'hrrp_nodet' )
                                                                                 ( 'hrrp_attr_dir' )
                                                                                 )
                                                                                  ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).

    f_cut = NEW cl_fins_uh_hrrp_pc_legacy( io_third_party_api = so_uh_third_party_api_mock io_uh_authority = so_uh_authority_check_mock ).
    f_cut->set_ignore_app_check( iv_ignore = abap_true ).

    cl_abap_testdouble=>configure_call(
      double = so_uh_authority_check_mock
    )->ignore_all_parameters( )->returning( 0 ).

    so_uh_authority_check_mock->check_uh_hierarchy_authority( iv_hry_type = '' iv_activity = '03' ).
  ENDMETHOD.

  METHOD teardown.



  ENDMETHOD.

  METHOD prepare_test_data.
    DATA lt_hrrp_node TYPE STANDARD TABLE OF hrrp_node.
    DATA lt_hrrp_nodet TYPE STANDARD TABLE OF hrrp_nodet.
    DATA lt_hrrp_directory TYPE STANDARD TABLE OF hrrp_directory.
    DATA lt_hrrp_attr_dir TYPE STANDARD TABLE OF hrrp_attr_dir.

    lt_hrrp_node = VALUE #( ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              nodecls = '0001'
                              hrynode = '0724ZM'
                              parnode = ''
                              hryvalto = '99991231'
                              hryvalfrom = '20010101'
                              balind = ''
                              nodetype = 'R'
                              nodevalue = '0724ZM'
                              hryseqnbr = '000001'
                              hrylevel = '000000' )
                             ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              nodecls = '0001'
                              hrynode = '01'
                              parnode = '0724ZM'
                              hryvalto = '99991231'
                              hryvalfrom = '20010101'
                              balind = ''
                              nodetype = 'N'
                              nodevalue = '1'
                              hryseqnbr = '000001'
                              hrylevel = '000001'
                               )
                              ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              nodecls = '0001'
                              hrynode = '02'
                              parnode = '0724ZM'
                              hryvalto = '99991231'
                              hryvalfrom = '20010101'
                              balind = ''
                              nodetype = 'N'
                              nodevalue = '2'
                              hryseqnbr = '000002'
                              hrylevel = '000001'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              nodecls = '0001'
                              hrynode = '1leaf'
                              parnode = '01'
                              hryvalto = '99991231'
                              hryvalfrom = '20010101'
                              balind = ''
                              nodetype = 'L'
                              nodevalue = 'leaf'
                              hryseqnbr = '000001'
                              hrylevel = '000002'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000001'
                              nodecls = '0001'
                              hrynode = '0725ZM'
                              parnode = ''
                              hryvalto = '20180722'
                              hryvalfrom = '20010101'
                              balind = ''
                              nodetype = 'R'
                              nodevalue = '0725ZM'
                              hryseqnbr = '000001'
                              hrylevel = '000000' )
                              ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000002'
                              nodecls = '0001'
                              hrynode = '0725ZM'
                              parnode = ''
                              hryvalto = '99991231'
                              hryvalfrom = '20180723'
                              balind = ''
                              nodetype = 'R'
                              nodevalue = '0725ZM'
                              hryseqnbr = '000001'
                              hrylevel = '000000' )
                              ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000002'
                              nodecls = '0001'
                              hrynode = '01'
                              parnode = '0725ZM'
                              hryvalto = '99991231'
                              hryvalfrom = '20180723'
                              balind = ''
                              nodetype = 'N'
                              nodevalue = '1'
                              hryseqnbr = '000001'
                              hrylevel = '000001' )
                               ).

    lt_hrrp_directory = VALUE #( ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              hryvalto = '99991231'
                              hryvalfrom = '20010101'
                              hrytyp = '0106'
                              updtime = sy-datum
                              upduser = sy-uname
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000001'
                              hryvalto = '20180722'
                              hryvalfrom = '20010101'
                              hrytyp = '0106'
                              updtime = sy-datum
                              upduser = sy-uname
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000002'
                              hryvalto = '99991231'
                              hryvalfrom = '20180723'
                              hrytyp = '0106'
                              updtime = sy-datum
                              upduser = sy-uname
                               )
                               ).
    lt_hrrp_attr_dir = VALUE #( ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              hryvalto = '99991231'
                              hryattrname = 'LEGACY_USAGE'
                              hryattrvalue = 'X'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0724ZM'
                              hryver = '000000000000001'
                              hryvalto = '99991231'
                              hryattrname = 'SOURCE'
                              hryattrvalue = 'UH'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000001'
                              hryvalto = '20180722'
                              hryattrname = 'LEGACY_USAGE'
                              hryattrvalue = 'X'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/07245ZM'
                              hryver = '000000000000001'
                              hryvalto = '20180722'
                              hryattrname = 'SOURCE'
                              hryattrvalue = 'UH'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000002'
                              hryvalto = '99991231'
                              hryattrname = 'LEGACY_USAGE'
                              hryattrvalue = 'X'
                               )
                               ( mandt = sy-mandt
                              hryid = 'H106/0001/0725ZM'
                              hryver = '000000000000002'
                              hryvalto = '99991231'
                              hryattrname = 'SOURCE'
                              hryattrvalue = 'UH'
                               )
                               ).
    lt_hrrp_nodet = VALUE #( ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0724ZM'
                          hryver = '000000000000001'
                          nodecls = '0001'
                          hrynode = '0724ZM'
                          parnode = ''
                          hryvalto = '99991231'
                          hryvalfrom = '20010101'
                          nodetxt = '0724ZM (0724ZM T)' )
                         ( mandt = sy-mandt
                         spras = 'EN'
                          hryid = 'H106/0001/0724ZM'
                          hryver = '000000000000001'
                          nodecls = '0001'
                          hrynode = '01'
                          parnode = '0724ZM'
                          hryvalto = '99991231'
                          hryvalfrom = '20010101'
                          nodetxt = '1 (1)' )
                          ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0724ZM'
                          hryver = '000000000000001'
                          nodecls = '0001'
                          hrynode = '02'
                          parnode = '0724ZM'
                          hryvalto = '99991231'
                          hryvalfrom = '20010101'
                          nodetxt = '2 (2)' )
                           ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0724ZM'
                          hryver = '000000000000001'
                          nodecls = '0001'
                          hrynode = ''
                          parnode = '0724ZM'
                          hryvalto = '99991231'
                          hryvalfrom = '20010101'
                          nodetxt = '2 (2)' )

                          ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0725ZM'
                          hryver = '000000000000001'
                          nodecls = '0001'
                          hrynode = '1leaf'
                          parnode = '01'
                          hryvalto = '20180722'
                          hryvalfrom = '20010101'
                          nodetxt = 'leaf (1leaf)' )
                          ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0725ZM'
                          hryver = '000000000000002'
                          nodecls = '0001'
                          hrynode = '0725ZM'
                          parnode = ''
                          hryvalto = '99991231'
                          hryvalfrom = '20180723'
                          nodetxt = '0725ZM (0725ZM T)' )
                          ( mandt = sy-mandt
                          spras = 'EN'
                          hryid = 'H106/0001/0725ZM'
                          hryver = '000000000000002'
                          nodecls = '0001'
                          hrynode = '01'
                          parnode = '0725ZM'
                          hryvalto = '99991231'
                          hryvalfrom = '20180723'
                          nodetxt = '1 (1)' )
                           ).
    environment->insert_test_data( lt_hrrp_node ).
    environment->insert_test_data( lt_hrrp_nodet ).
    environment->insert_test_data( lt_hrrp_directory ).
    environment->insert_test_data( lt_hrrp_attr_dir ).
  ENDMETHOD.

  METHOD import_set_desc_value.
    me->prepare_test_data( ).

    DATA ls_setkey TYPE setkeylist.
    ls_setkey-subclass = '0001'.
    ls_setkey-setname = '0724ZM~'.
    TRY.
        f_cut->if_fins_uh_hrrp_legacy~import_set(
        EXPORTING
          is_setkey = ls_setkey
          iv_no_descriptions = ''
          iv_no_values = ''
        IMPORTING
          et_sethier = DATA(lt_sethier)
          et_setval  = DATA(lt_setval) ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.


    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 3
              act = lines( lt_sethier )
    ).
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 1
              act = lines( lt_setval )
    ).
  ENDMETHOD.

  METHOD import_set_no_desc.
    me->prepare_test_data( ).

    DATA ls_setkey TYPE setkeylist.
    ls_setkey-setid = '010600010724ZM~'.
    ls_setkey-subclass = '0001'.
    ls_setkey-setname = '0724ZM~'.
    TRY.
        f_cut->if_fins_uh_hrrp_legacy~import_set(
        EXPORTING
          is_setkey = ls_setkey
          iv_no_descriptions = 'X'
          iv_no_values = ''
        IMPORTING
          et_sethier = DATA(lt_sethier)
          et_setval  = DATA(lt_setval) ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 3
              act = lines( lt_sethier )
    ).
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 1
              act = lines( lt_setval )
    ).
  ENDMETHOD.

  METHOD import_set_no_value.
       me->prepare_test_data( ).

    DATA ls_setkey TYPE setkeylist.
    ls_setkey-subclass = '0001'.
    ls_setkey-setname = '0724ZM~'.
    TRY.
        f_cut->if_fins_uh_hrrp_legacy~import_set(
        EXPORTING
          is_setkey = ls_setkey
          iv_no_descriptions = ''
          iv_no_values = 'X'
        IMPORTING
          et_sethier = DATA(lt_sethier)
          et_setval  = DATA(lt_setval) ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 3
              act = lines( lt_sethier )
    ).
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 0
              act = lines( lt_setval )
    ).
  ENDMETHOD.

  METHOD: import_sets.
    me->prepare_test_data( ).

    DATA lt_set TYPE setlist_t.
    data ls_set TYPE SETLIST.

    ls_set-setname = '010600010724ZM~'.
    append ls_set to lt_set.

    ls_set-setname = '010600010725ZM~'.
    append ls_set to lt_set.

    TRY.
        f_cut->if_fins_uh_hrrp_legacy~import_sets(
        EXPORTING
          it_setkey = lt_set
        IMPORTING
          et_sethier = DATA(lt_sethier)
        ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 2
              act = lines( lt_sethier )
    ).
*    cl_aunit_assert=>assert_equals(
*      EXPORTING
*              exp = 0
*              act = lines( lt_setval )
*    ).

  ENDMETHOD.


  METHOD select_sets.
     me->prepare_test_data( ).

    DATA lt_set TYPE setlist_t.

*    ls_set-setname = '010600010724ZM~'.
*    append ls_set to lt_set.
*
*    ls_set-setname = '010600010725ZM~'.
*    append ls_set to lt_set.

    TRY.
        f_cut->if_fins_uh_hrrp_legacy~select_sets(
        EXPORTING
          iv_setname = '0725ZM~'
        CHANGING
          ct_setlist = lt_set
        ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 1
              act = lines( lt_set )
    ).
*    cl_aunit_assert=>assert_equals(
*      EXPORTING
*              exp = 0
*              act = lines( lt_setval )
*    ).

  ENDMETHOD.

  METHOD select_sets_with_date_range.
     me->prepare_test_data( ).

    DATA lt_set TYPE setlist_t.

*    ls_set-setname = '010600010724ZM~'.
*    append ls_set to lt_set.
*
*    ls_set-setname = '010600010725ZM~'.
*    append ls_set to lt_set.
    f_cut->set_date_range( iv_valid_from = '20010101' iv_valid_to = '99991231' ).
    TRY.
        f_cut->if_fins_uh_hrrp_legacy~select_sets(
        EXPORTING
          iv_setname = '0725ZM~'
        CHANGING
          ct_setlist = lt_set
        ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 1
              act = lines( lt_set )
    ).
*    cl_aunit_assert=>assert_equals(
*      EXPORTING
*              exp = 0
*              act = lines( lt_setval )
*    ).

  ENDMETHOD.


  METHOD select_sets_by_name.
    me->prepare_test_data( ).

*    DATA lt_set TYPE setlist_t.

*    ls_set-setname = '010600010724ZM~'.
*    append ls_set to lt_set.
*
*    ls_set-setname = '010600010725ZM~'.
*    append ls_set to lt_set.
    f_cut->set_date_range( iv_valid_from = '20010101' iv_valid_to = '20010123' ).
    TRY.
        f_cut->if_fins_uh_hrrp_legacy~select_sets_by_name(
        EXPORTING
          iv_setname = '0725ZM~'
        IMPORTING
          et_setkeylist = data(lt_set)
        ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 1
              act = lines( lt_set )
    ).
*    cl_aunit_assert=>assert_equals(
*      EXPORTING
*              exp = 0
*              act = lines( lt_setval )
*    ).



  ENDMETHOD.


  METHOD select_sets_ranges.
    me->prepare_test_data( ).

    DATA: lt_subclass TYPE TABLE OF gsr_subcls,
          lt_setname TYPE TABLE OF gsr_setnam,
          lt_title TYPE TABLE OF gsr_title,
          lv_typelist TYPE c,
          lt_setclass TYPE  TABLE OF gsr_class,
          ct_setlist TYPE sethier,
          ls_subclass like LINE OF lt_subclass,
          ls_setname like LINE OF lt_setname,
          ls_title like LINE OF lt_title,
          ls_setclass like line of lt_setclass,
          lt_set TYPE TABLE OF sethier.

     lv_typelist = 'B'.

    ls_subclass-sign = 'I'.
    ls_subclass-option = 'EQ'.
    ls_subclass-low = '0001'.
    append ls_subclass TO lt_subclass.

    ls_setname-sign = 'I'.
    ls_setname-option = 'EQ'.
    ls_setname-low = '0724ZM~'.
    APPEND ls_setname to lt_setname.

    ls_setclass-sign = 'I'.
    ls_setclass-option = 'EQ'.
    ls_setclass-low = '0106'.
    APPEND ls_setclass to lt_setclass.



    TRY.
        f_cut->if_fins_uh_hrrp_legacy~select_sets_ranges(
        EXPORTING
          it_subclass = lt_subclass
          it_setname = lt_setname
          it_title = lt_title
          iv_typelist = lv_typelist
          it_setclass = lt_setclass
        CHANGING
          ct_setlist = lt_set
        ).

      CATCH cx_fins_uh_hrrp_legacy.
        cl_aunit_assert=>fail( ).
    ENDTRY.
    cl_aunit_assert=>assert_equals(
      EXPORTING
              exp = 0
              act = lines( lt_set )
    ).
*    cl_aunit_assert=>assert_equals(
*      EXPORTING
*              exp = 0
*              act = lines( lt_setval )
*    ).



  ENDMETHOD.

ENDCLASS.

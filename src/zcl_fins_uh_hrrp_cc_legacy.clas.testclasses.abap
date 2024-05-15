class ltc_Fins_Uh_Hrrp_Cc_Legacy definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>ltc_Fins_Uh_Hrrp_Legacy
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_FINS_UH_HRRP_LEGACY
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  private section.
    data:
      lo_fins_uh_hrrp_cc_legacy type ref to cl_Fins_Uh_Hrrp_Cc_Legacy.  "class under test
    class-methods: class_Setup.
    class-methods: class_Teardown.
    CLASS-DATA:
      so_uh_third_party_api_mock TYPE REF TO if_fins_uh_third_party_api,
      so_uh_authority_check_mock TYPE REF TO if_fins_uh_authority_check.
    methods: setup.
    methods: teardown.
    methods: prepare_test_data.
    CLASS-DATA:environment          TYPE REF TO if_osql_test_environment.
    methods: import_Set for testing.
    methods: select_sets_B for testing.
    methods: select_sets_S for testing.
    methods: select_sets_top_only for testing.
    methods: select_sets_by_name for testing.
    methods: select_sets_by_name_none for testing.
    methods: select_sets_by_range for testing.
    methods: import_sets for testing.
endclass.       "ltc_Fins_Uh_Hrrp_Legacy


class ltc_Fins_Uh_Hrrp_Cc_Legacy implementation.

  method class_Setup.
    so_uh_third_party_api_mock ?= cl_abap_testdouble=>create('IF_FINS_UH_THIRD_PARTY_API').
    so_uh_authority_check_mock ?= cl_abap_testdouble=>create('IF_FINS_UH_AUTHORITY_CHECK').
    environment = cl_osql_test_environment=>create( i_dependency_list = VALUE #( ( 'HRRP_NODE' )
                                                                                 ( 'HRRP_ATTR_DIR' )
                                                                                 ( 'HRRP_DIRECTORY' )
                                                                                 ( 'HRRP_NODET' ) ) ).

  endmethod.


  method class_Teardown.
    environment->destroy( ).
  endmethod.

  method setup.
    environment->clear_doubles( ).

    lo_fins_uh_hrrp_cc_legacy = NEW cl_fins_uh_hrrp_cc_legacy( io_third_party_api = so_uh_third_party_api_mock io_uh_authority = so_uh_authority_check_mock ).
    lo_fins_uh_hrrp_cc_legacy->set_ignore_app_check( iv_ignore = abap_true ).

    cl_abap_testdouble=>configure_call(
      double = so_uh_authority_check_mock
    )->ignore_all_parameters( )->returning( 0 ).

    so_uh_authority_check_mock->check_uh_hierarchy_authority( iv_hry_type = '' iv_activity = '03' ).
  endmethod.

  method teardown.

  endmethod.

  method import_Set.
    me->prepare_test_data( ).
    DATA ls_setkey TYPE setkeylist.
    ls_setkey = VALUE #( setid    = 'HRY01~ROOT'
                         setclass = '0101'
                         subclass = '0001'
                         setname  = 'HRY01~ROOT' ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~import_set(
        EXPORTING
          is_setkey = ls_setkey
        IMPORTING
          et_sethier = DATA(lt_sethier)
          et_setval  = DATA(lt_setval) ).

    DATA ls_sethier LIKE LINE OF lt_sethier.
    ls_sethier = VALUE #( level = '0'
                          fieldname = 'KOSTL'
                          setid = 'HRY01~ROOT'
                          type = 'S'
                          vcount = '1'
                          tabname = 'CCSS'
                          creuser = sy-uname
                          upduser = sy-uname
                          descript = 'ROOT'
                          searchfld = '0001'
                          setclass = '0101'
                          shortname = 'HRY01~ROOT'
                          kokrs = '0001'
                          subclass = '0001'
                          rollname = 'KOSTL'
                          set_olangu = 'E' ).

     cl_abap_unit_assert=>assert_table_contains(
        EXPORTING
          table                 = lt_sethier
          line                  = ls_sethier
     ).

    ls_sethier = VALUE #( level = '1'
                          fieldname = 'KOSTL'
                          setid = '01010001HRY01~NODE1'
                          type = 'B'
                          vcount = '1'
                          tabname = 'CCSS'
                          creuser = sy-uname
                          upduser = sy-uname
                          descript = 'NODE1'
                          setclass = '0101'
                          searchfld = '0001'
                          shortname = 'HRY01~NODE1'
                          kokrs = '0001'
                          subclass = '0001'
                          rollname = 'KOSTL'
                          set_olangu = 'E' ).

     cl_abap_unit_assert=>assert_table_contains(
        EXPORTING
          table                 = lt_sethier
          line                  = ls_sethier
     ).

    ls_sethier = VALUE #( level = '1'
                          fieldname = 'KOSTL'
                          setid = '01010001HRY01~NODE2'
                          type = 'B'
                          vcount = '0'
                          tabname = 'CCSS'
                          creuser = sy-uname
                          upduser = sy-uname
                          descript = 'NODE2'
                          setclass = '0101'
                          searchfld = '0001'
                          shortname = 'HRY01~NODE2'
                          kokrs = '0001'
                          subclass = '0001'
                          rollname = 'KOSTL'
                          set_olangu = 'E' ).

     cl_abap_unit_assert=>assert_table_contains(
        EXPORTING
          table                 = lt_sethier
          line                  = ls_sethier
     ).

     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 3
          act                   = LINES( lt_sethier )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method import_sets.
    me->prepare_test_data( ).
    DATA lt_setkey TYPE setlist_t.
    lt_setkey = VALUE #( ( setname = '01010001HRY01~ROOT' )
                         ( setname = '01010001HRY01~NODE1' )
                         ( setname = '01010001HRY01~NODE3' )
                         ( setname = '01010001HRY01NODE4' ) ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~import_sets(
        EXPORTING
          it_setkey  = lt_setkey
        IMPORTING
          et_sethier = DATA(lt_sethier) ).

     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 2
          act                   = LINES( lt_sethier )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_B.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    DATA ct_setlist TYPE IF_FINS_UH_HRRP_LEGACY=>tt_setlist.
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets(
        EXPORTING
          iv_kokrs = '0001'
          iv_setname = 'HRY%'
          iv_typelist = 'B'
        CHANGING
          ct_setlist = ct_setlist ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 2
          act                   = LINES( ct_setlist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_s.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    DATA ct_setlist TYPE IF_FINS_UH_HRRP_LEGACY=>tt_setlist.
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets(
        EXPORTING
          iv_kokrs = '0001'
          iv_setname = 'HRY%'
          iv_typelist = 'S'
        CHANGING
          ct_setlist = ct_setlist ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 1
          act                   = LINES( ct_setlist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_top_only.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    DATA ct_setlist TYPE IF_FINS_UH_HRRP_LEGACY=>tt_setlist.
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets(
        EXPORTING
          iv_kokrs = '0001'
          iv_setname = 'HRY%'
          iv_typelist = ''
        CHANGING
          ct_setlist = ct_setlist ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 1
          act                   = LINES( ct_setlist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_by_name.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    DATA ct_setlist TYPE IF_FINS_UH_HRRP_LEGACY=>tt_setlist.
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets_by_name(
        EXPORTING
          iv_setname = 'HRY01~ROOT'
        IMPORTING
          et_setkeylist = DATA(lt_setkeylist) ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 1
          act                   = LINES( lt_setkeylist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_by_name_none.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets_by_name(
        EXPORTING
          iv_setname = 'HRY01~ROOT2'
        IMPORTING
          et_setkeylist = DATA(lt_setkeylist) ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 0
          act                   = LINES( lt_setkeylist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method select_sets_by_range.
    me->prepare_test_data( ).
    TRY.

*    cl_abap_testdouble=>configure_call(
*      double = so_uh_third_party_api_mock
*    )->returning( 'KSH3' ).
*
*    so_uh_third_party_api_mock->get_gui_tcode( ).

    DATA lt_subclass TYPE IF_FINS_UH_HRRP_LEGACY=>ttr_subclass.
    DATA lt_setname TYPE IF_FINS_UH_HRRP_LEGACY=>ttr_setname.
    DATA lt_title TYPE IF_FINS_UH_HRRP_LEGACY=>ttr_title.
    DATA lt_setclass TYPE IF_FINS_UH_HRRP_LEGACY=>ttr_setclass.
    DATA ct_setlist TYPE IF_FINS_UH_HRRP_LEGACY=>tt_sethier.
    lo_fins_uh_hrrp_cc_legacy->if_fins_uh_hrrp_legacy~select_sets_ranges(
        EXPORTING
          it_subclass = lt_subclass
          it_setname = lt_setname
          it_title = lt_title
          iv_typelist = 'BS'
          it_setclass = lt_setclass
        CHANGING
          ct_setlist = ct_setlist ).


     cl_abap_unit_assert=>assert_equals(
        EXPORTING
          exp                   = 3
          act                   = LINES( ct_setlist )
     ).
      CATCH cx_fins_uh_hrrp_legacy.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.
  endmethod.

  method prepare_test_data.
    DATA lt_hrrp_directory TYPE STANDARD TABLE OF hrrp_directory.
    lt_hrrp_directory = VALUE #( ( mandt      = sy-mandt
                                   hryid      = 'H101/0001/HRY01'
                                   hryver     = '1'
                                   hryvalto   = '99991231'
                                   hryvalfrom = '20170101'
                                   hrytyp     = '0101'
                                   updtime    = sy-datum
                                   upduser    = sy-uname )
                                 ( mandt      = sy-mandt
                                   hryid      = 'H101/0001/HRY02'
                                   hryver     = '1'
                                   hryvalto   = '99991231'
                                   hryvalfrom = sy-datum + 10
                                   hrytyp     = '0101'
                                   updtime    = sy-datum
                                   upduser    = sy-uname ) ).
    environment->insert_test_data( lt_hrrp_directory ).

    DATA lt_hrrp_attr_dir TYPE STANDARD TABLE OF hrrp_attr_dir.
    lt_hrrp_attr_dir = VALUE #( ( mandt = sy-mandt
                                  hryid = 'H101/0001/HRY01'
                                  hryver     = '1'
                                  hryvalto   = '99991231'
                                  hryattrname = 'LEGACY_USAGE'
                                  hryattrvalue = 'X' )
                                ( mandt = sy-mandt
                                  hryid = 'H101/0001/HRY02'
                                  hryver     = '1'
                                  hryvalto   = '99991231'
                                  hryattrname = 'LEGACY_USAGE'
                                  hryattrvalue = 'X' ) ).
    environment->insert_test_data( lt_hrrp_attr_dir ).

    DATA lt_hrrp_node TYPE STANDARD TABLE OF hrrp_node.
    lt_hrrp_node = VALUE #( ( mandt       = sy-mandt
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0ROOT'
                              parnode     = ''
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              balind      = ''
                              nodetype    = 'R'
                              nodevalue   = 'ROOT'
                              hryseqnbr   = '000001'
                              hrylevel    = '000000' )
                            ( mandt       = sy-mandt
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0NODE1'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              balind      = ''
                              nodetype    = 'N'
                              nodevalue   = 'NODE1'
                              hryseqnbr   = '000002'
                              hrylevel    = '000001' )
                            ( mandt       = sy-mandt
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0NODE2'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              balind      = ''
                              nodetype    = 'N'
                              nodevalue   = 'NODE2'
                              hryseqnbr   = '000003'
                              hrylevel    = '000001' )
                            ( mandt       = sy-mandt
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0LEAF1'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              balind      = ''
                              nodetype    = 'L'
                              nodevalue   = 'CC1'
                              hryseqnbr   = '000004'
                              hrylevel    = '000001' )
                            ( mandt       = sy-mandt
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0LEAF2'
                              parnode     = '0NODE1'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              balind      = ''
                              nodetype    = 'L'
                              nodevalue   = 'CC2'
                              hryseqnbr   = '000005'
                              hrylevel    = '000002' ) ).
    environment->insert_test_data( lt_hrrp_node ).

    DATA lt_hrrp_nodet TYPE STANDARD TABLE OF hrrp_nodet.
    lt_hrrp_nodet = VALUE #( ( mandt       = sy-mandt
                              spras       = 'E'
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0ROOT'
                              parnode     = ''
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              nodetxt     = 'ROOT' )
                            ( mandt       = sy-mandt
                              spras       = 'E'
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0NODE1'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              nodetxt     = 'NODE1' )
                            ( mandt       = sy-mandt
                              spras       = 'E'
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0NODE2'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              nodetxt     = 'NODE2' )
                            ( mandt       = sy-mandt
                              spras       = 'E'
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0LEAF1'
                              parnode     = '0ROOT'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              nodetxt     = 'LEAF1' )
                            ( mandt       = sy-mandt
                              spras       = 'E'
                              hryid       = 'H101/0001/HRY01'
                              hryver      = '1'
                              nodecls     = '0001'
                              hrynode     = '0LEAF2'
                              parnode     = '0NODE1'
                              hryvalto    = '99991231'
                              hryvalfrom  = '20170101'
                              nodetxt     = 'LEAF2' ) ).
    environment->insert_test_data( lt_hrrp_nodet ).

  endmethod.

endclass.

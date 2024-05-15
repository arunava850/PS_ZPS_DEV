class ZCL_FINS_UH_HRRP_CC_LEGACY definition
  public
  inheriting from CL_FINS_UH_HRRP_LEGACY
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IO_THIRD_PARTY_API type ref to IF_FINS_UH_THIRD_PARTY_API optional
      !IO_UH_AUTHORITY type ref to IF_FINS_UH_AUTHORITY_CHECK optional .

  methods ADD_LEVEL
    redefinition .
  methods IF_FINS_UH_HRRP_LEGACY~IMPORT_SET
    redefinition .
  methods IF_FINS_UH_HRRP_LEGACY~IMPORT_SETS
    redefinition .
  methods IF_FINS_UH_HRRP_LEGACY~SELECT_SETS
    redefinition .
  methods IF_FINS_UH_HRRP_LEGACY~SELECT_SETS_BY_NAME
    redefinition .
  methods IF_FINS_UH_HRRP_LEGACY~SELECT_SETS_RANGES
    redefinition .
protected section.
ENDCLASS.



CLASS ZCL_FINS_UH_HRRP_CC_LEGACY IMPLEMENTATION.


  METHOD ADD_LEVEL.

    TYPES: BEGIN OF lty_parnode,
             parnode   TYPE parnode,
             nodevalue TYPE nodevalue,
             nodetxt   TYPE nodetxt,
           END OF lty_parnode.
    DATA: ls_setval  TYPE setvalues,
          lt_parnode TYPE STANDARD TABLE OF lty_parnode,
          ls_sethier TYPE sethier,
          lv_tabix   TYPE i.

    APPEND cs_sethier TO ct_sethier ASSIGNING FIELD-SYMBOL(<fs_sethier>).

    <fs_sethier>-type = 'B'.
    <fs_sethier>-vcount = 0.

*   Get child nodes and values
    READ TABLE it_node WITH KEY parnode = iv_parnode TRANSPORTING NO FIELDS BINARY SEARCH.
    IF sy-subrc = 0.
      DATA(lv_index) = sy-tabix.
      LOOP AT it_node ASSIGNING FIELD-SYMBOL(<fs_node>) FROM lv_index.
        IF <fs_node>-parnode <> iv_parnode.
          EXIT.
        ENDIF.
        lv_tabix = lv_tabix + 1.
        CASE <fs_node>-nodetype.
          WHEN if_fins_hrrp_hier_builder=>cv_nodetype_node.
            APPEND VALUE #( parnode = <fs_node>-hrynode nodevalue = <fs_node>-nodevalue nodetxt = <fs_node>-nodetxt )
              TO lt_parnode.
          WHEN if_fins_hrrp_hier_builder=>cv_nodetype_leaf.
            <fs_sethier>-vcount = <fs_sethier>-vcount + 1.
            ls_setval-from = ls_setval-to = <fs_node>-nodevalue.
            ls_setval-old_line = lv_tabix.
            APPEND ls_setval TO ct_setval.
        ENDCASE.
      ENDLOOP.
    ENDIF.

*   Process single sets, i.e. hierarchy nodes with nodes as children, recursively
    CHECK lt_parnode IS NOT INITIAL.
    <fs_sethier>-type = 'S'.
    cs_sethier-level = cs_sethier-level + 1.
    SPLIT iv_hryid AT '/'  INTO DATA(lv_hierarchy_namespace) DATA(lv_subclass) DATA(lv_hryid).
    IF lv_hryid IS INITIAL.
      lv_hryid = lv_subclass.
      CLEAR lv_subclass.
    ENDIF.
    LOOP AT lt_parnode ASSIGNING FIELD-SYMBOL(<fs_parnode>).

      cs_sethier-shortname = lv_hryid && if_fins_uh_hrrp_legacy~gc_virtual_tag && <fs_parnode>-nodevalue.
      IF mv_set_class CP gsetc_all_co_setclasses.
        DATA(lv_kokrs) = CONV kokrs( lv_subclass ).
      ENDIF.
      CALL FUNCTION 'G_SET_ENCRYPT_SETID'
        EXPORTING
          setclass  = mv_set_class
          kokrs     = lv_kokrs
          shortname = cs_sethier-shortname
          subclass  = CONV setsubcls( lv_subclass )
        IMPORTING
          setid     = cs_sethier-setid.
      IF iv_no_descriptions = abap_false.
        cs_sethier-descript = <fs_parnode>-nodetxt.
      ENDIF.
      add_level(
        EXPORTING
          it_node            = it_node
          iv_date            = iv_date
          iv_hryid           = iv_hryid
          iv_no_descriptions = iv_no_descriptions
          iv_parnode         = <fs_parnode>-parnode
          iv_version         = iv_version
        CHANGING
          cs_sethier = cs_sethier
          ct_sethier = ct_sethier
          ct_setval  = ct_setval ).
    ENDLOOP.

    cs_sethier-level = cs_sethier-level - 1.

  ENDMETHOD.


  method CONSTRUCTOR.
    super->constructor( io_third_party_api = io_third_party_api io_uh_authority = io_uh_authority ).
    MV_HRRP_PREFIX_PATTERN = 'H101/%'.
    MV_SET_CLASS = '0101'.
    MV_HRRP_TYPE = '0101'.
  endmethod.


  METHOD IF_FINS_UH_HRRP_LEGACY~IMPORT_SET.
    DATA: ls_sethier   TYPE sethier,
          ls_setval    TYPE setvalues,
          lt_node      TYPE tt_node,
          lv_hryid     TYPE hrrp_node-hryid,
          lv_nodevalue TYPE hrrp_node-nodevalue,
          lv_key_date  TYPE datum.

*    IF me->check_allow_legacy( iv_is_import = abap_true ) <> 0.
*      RAISE EXCEPTION TYPE cx_fins_uh_hrrp_legacy
*        EXPORTING
*          textid = cx_fins_uh_hrrp_legacy=>hierarchy_can_not_be_used
*          para1  = CONV symsgv( is_setkey-setname ).
*    ENDIF.

    CLEAR: et_sethier, et_setval.

    lv_key_date = mv_key_date.
    IF lv_key_date IS INITIAL.
      lv_key_date = sy-datum.
    ENDIF.

    CHECK is_setkey-subclass IS NOT INITIAL.
    CHECK is_setkey-setname CS if_fins_uh_hrrp_legacy~gc_virtual_tag.
    SPLIT is_setkey-setname AT if_fins_uh_hrrp_legacy~gc_virtual_tag INTO lv_hryid lv_nodevalue.

    IF lv_nodevalue IS INITIAL.
      lv_nodevalue = lv_hryid.
    ENDIF.
    DATA(lv_hid_length) = strlen( lv_hryid ).
    CHECK lv_hid_length LE cl_fins_uh_constants=>c_length_restriction-hid_for_legacy. "Hierarchy ID must be max. 8 characters after second /, as this goes into the "prefix" of the set name
    DATA(lv_total_length) = strlen( is_setkey-setname ) - 1.
    CHECK lv_total_length LE cl_fins_uh_constants=>c_length_restriction-hid_node_val_for_legacy. "Nodevalue goes into the "suffix" of the set name, total length is 15 including '~'

    lv_hryid = mv_hrrp_prefix_pattern && is_setkey-subclass && '/' && lv_hryid.

*   Select hierarchy node versions corresponding to the given set ID
    SELECT DISTINCT n~hryid, n~hryver, n~nodecls, n~hrynode, n~parnode, n~hryvalto, n~hryvalfrom, n~nodetype INTO TABLE @DATA(lt_hrrp)
      FROM hrrp_node AS n INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
      AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
      WHERE n~hryid     LIKE @lv_hryid
        AND n~hryid     NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
        AND n~nodecls   = @is_setkey-subclass
        AND n~nodevalue = @lv_nodevalue
        AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
        AND n~hryvalto GE @lv_key_date AND n~hryvalfrom LE @lv_key_date
        AND a~hryattrvalue = 'X'.
    CHECK sy-subrc = 0.

    SORT lt_hrrp BY hryid DESCENDING hryver DESCENDING. "Newest version on top
    READ TABLE lt_hrrp ASSIGNING FIELD-SYMBOL(<fs_top>) INDEX 1.
    DELETE lt_hrrp WHERE hryid <> <fs_top>-hryid.

*   Fill SETHIER information about top node
    ls_sethier-level = 0.
    me->get_table_info_by_set_class(
      EXPORTING
        iv_setclass = mv_set_class
      IMPORTING
        ev_roll_name  = ls_sethier-rollname
        ev_tab_name   = ls_sethier-tabname
        ev_field_name = ls_sethier-fieldname
    ).
    IF mv_set_class CP gsetc_all_co_setclasses.
      ls_sethier-kokrs = is_setkey-subclass.
    ENDIF.
    ls_sethier-setid = is_setkey-setid.
    ls_sethier-setclass = is_setkey-setclass.
    ls_sethier-subclass = is_setkey-subclass.
    ls_sethier-shortname = is_setkey-setname.
    ls_sethier-searchfld = is_setkey-subclass.

*   Add creation and update time & user information
    READ TABLE lt_hrrp ASSIGNING FIELD-SYMBOL(<fs_bottom>) INDEX lines( lt_hrrp ).
    SELECT hryver, updtime, upduser INTO TABLE @DATA(lt_directory)
      FROM  hrrp_directory
      WHERE hryid = @<fs_top>-hryid
        AND ( hryver = @<fs_top>-hryver AND hryvalto = @<fs_top>-hryvalto OR
              hryver = @<fs_bottom>-hryver AND hryvalto = @<fs_bottom>-hryvalto ).
    SORT lt_directory BY hryver DESCENDING.
    READ TABLE lt_directory INTO DATA(ls_directory) INDEX 1.
    ls_sethier-upduser = ls_directory-upduser.
    TRY.
        cl_abap_tstmp=>systemtstmp_utc2syst( EXPORTING utc_tstmp = ls_directory-updtime
                                             IMPORTING syst_date = ls_sethier-upddate
                                                       syst_time = ls_sethier-updtime ).
      CATCH cx_parameter_invalid_range ##no_handler.
    ENDTRY.
    READ TABLE lt_directory INTO ls_directory INDEX lines( lt_directory ).
    ls_sethier-creuser = ls_directory-upduser.
    TRY.
        cl_abap_tstmp=>systemtstmp_utc2syst( EXPORTING utc_tstmp = ls_directory-updtime
                                             IMPORTING syst_date = ls_sethier-credate
                                                       syst_time = ls_sethier-cretime ).
      CATCH cx_parameter_invalid_range ##no_handler.
    ENDTRY.

*   Add descriptions
    DATA: lv_date    TYPE char10,
          lv_version TYPE i.
    WRITE <fs_top>-hryvalfrom TO lv_date.
    lv_version = <fs_top>-hryver.
    IF iv_no_descriptions = abap_false.
      SELECT SINGLE nodetxt INTO @ls_sethier-descript FROM hrrp_nodet
        WHERE spras    = @sy-langu
          AND hryid    = @<fs_top>-hryid
          AND hryver   = @<fs_top>-hryver
          AND nodecls  = @<fs_top>-nodecls
          AND hrynode  = @<fs_top>-hrynode
          AND parnode  = @<fs_top>-parnode
          AND hryvalto = @<fs_top>-hryvalto.
      ls_sethier-set_olangu = sy-langu.
      IF iv_no_values = abap_true. "Add version information for lists of sets only, not when reading the entire hierarchy
        ls_sethier-descript = ls_sethier-descript.
      ENDIF.
    ENDIF.

*   Complete information for top node if this is the only requested node
    IF iv_no_values = abap_true.
*      READ TABLE lt_hrrp WITH KEY hryid = <fs_top>-hryid
*          hryver   = <fs_top>-hryver
*          nodecls  = <fs_top>-nodecls
*          parnode  = <fs_top>-hrynode
*          nodetype = if_fins_hrrp_hier_builder=>cv_nodetype_node TRANSPORTING NO FIELDS.
      IF iv_no_descriptions = abap_true.
        SELECT parnode, hrynode, nodetype, nodevalue
          INTO CORRESPONDING FIELDS OF TABLE @lt_node
          FROM hrrp_node
          WHERE hryid   = @<fs_top>-hryid
            AND hryver  = @<fs_top>-hryver
            AND nodecls = @<fs_top>-nodecls
            AND ( nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node OR nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root ).
      ELSE.
        SELECT n~parnode, n~hrynode, n~nodetype, n~nodevalue, n~hryseqnbr, t~nodetxt
          INTO CORRESPONDING FIELDS OF TABLE @lt_node
          FROM hrrp_node AS n LEFT OUTER JOIN hrrp_nodet AS t
            ON  t~spras    = @sy-langu
            AND t~hryid    = n~hryid
            AND t~hryver   = n~hryver
            AND t~nodecls  = n~nodecls
            AND t~hrynode  = n~hrynode
            AND t~parnode  = n~parnode
            AND t~hryvalto = n~hryvalto
          WHERE n~hryid   = @<fs_top>-hryid
            AND n~hryver  = @<fs_top>-hryver
            AND n~nodecls = @<fs_top>-nodecls
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root ).
      ENDIF.

*   Read entire hierarchy
    ELSE.
      IF iv_no_descriptions = abap_true.
        SELECT parnode, hrynode, nodetype, nodevalue
          INTO CORRESPONDING FIELDS OF TABLE @lt_node
          FROM hrrp_node
          WHERE hryid   = @<fs_top>-hryid
            AND hryver  = @<fs_top>-hryver
            AND nodecls = @<fs_top>-nodecls
            AND ( nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node OR nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_leaf ).
      ELSE.
        SELECT n~parnode, n~hrynode, n~nodetype, n~nodevalue, n~hryseqnbr, t~nodetxt
          INTO CORRESPONDING FIELDS OF TABLE @lt_node
          FROM hrrp_node AS n LEFT OUTER JOIN hrrp_nodet AS t
            ON  t~spras    = @sy-langu
            AND t~hryid    = n~hryid
            AND t~hryver   = n~hryver
            AND t~nodecls  = n~nodecls
            AND t~hrynode  = n~hrynode
            AND t~parnode  = n~parnode
            AND t~hryvalto = n~hryvalto
          WHERE n~hryid   = @<fs_top>-hryid
            AND n~hryver  = @<fs_top>-hryver
            AND n~nodecls = @<fs_top>-nodecls
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_leaf ).
      ENDIF.
    ENDIF.

    CHECK sy-subrc = 0.
    SORT lt_node BY parnode hryseqnbr.
*   Add child nodes recursively
    add_level(
      EXPORTING
        it_node            = lt_node
        iv_date            = lv_date
        iv_hryid           = <fs_top>-hryid
        iv_no_descriptions = iv_no_descriptions
        iv_parnode         = <fs_top>-hrynode
        iv_version         = lv_version
      CHANGING
        cs_sethier = ls_sethier
        ct_sethier = et_sethier
        ct_setval  = et_setval ).

  ENDMETHOD.


  METHOD IF_FINS_UH_HRRP_LEGACY~IMPORT_SETS.
    TYPES: BEGIN OF ts_setkeylistextend,
             setclass     TYPE setclass,
             setname      TYPE setnamenew,
             subclass     TYPE c LENGTH 12,
             hryidpattern TYPE hryid,
             nodevalue    TYPE c LENGTH 40,
           END OF ts_setkeylistextend.
    DATA lt_cust_hryidpattern TYPE RANGE OF hryid.
    DATA lv_setclass  TYPE setclass.
    DATA lt_setkeylist_ccpc TYPE STANDARD TABLE OF ts_setkeylistextend.
    DATA ls_setkeylist TYPE ts_setkeylistextend.
    DATA ls_sethier LIKE LINE OF et_sethier.
    DATA lv_kokrs   TYPE kokrs.
    DATA lv_ktopl   TYPE ktopl.

    LOOP AT it_setkey ASSIGNING FIELD-SYMBOL(<fs_setkey>).
      CLEAR: ls_setkeylist, lv_kokrs, lv_ktopl.
      CALL FUNCTION 'G_SET_DECRYPT_SETID'
        EXPORTING
          setid     = <fs_setkey>-setname
        IMPORTING
          setclass  = ls_setkeylist-setclass
          shortname = ls_setkeylist-setname
          kokrs     = lv_kokrs
          ktopl     = lv_ktopl
          subclass  = ls_setkeylist-subclass.
      IF ls_setkeylist-setname NA if_fins_uh_hrrp_legacy~gc_virtual_tag.
        CONTINUE.
      ENDIF.
      SPLIT ls_setkeylist-setname AT if_fins_uh_hrrp_legacy~gc_virtual_tag INTO DATA(lv_hryid) DATA(lv_nodevalue).

      IF ls_setkeylist-subclass IS INITIAL.
        ls_setkeylist-subclass = lv_kokrs.
      ENDIF.
      ls_setkeylist-hryidpattern = 'H' && ls_setkeylist-setclass+1(3) && '/' && ls_setkeylist-subclass && '/' && lv_hryid.

      ls_setkeylist-nodevalue = lv_nodevalue.
      IF ls_setkeylist-nodevalue IS INITIAL.
        ls_setkeylist-nodevalue = lv_hryid.
      ENDIF.

      APPEND ls_setkeylist TO lt_setkeylist_ccpc.
    ENDLOOP.

    IF lt_setkeylist_ccpc IS INITIAL.
      RETURN.
    ENDIF.

    IF lt_setkeylist_ccpc IS NOT INITIAL.
      SELECT DISTINCT n~hryid, n~hryver, n~nodecls, n~hrynode, n~hryvalto, n~nodevalue, n~nodetype, t~nodetxt, d~hrytyp, category~hryattrvalue AS category, rollname~hryattrvalue AS rollname INTO TABLE
        @DATA(lt_node)
        FROM hrrp_node AS n
        INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver
        AND n~hryvalto = d~hryvalto
        LEFT JOIN hrrp_attr_dir AS category ON n~hryid = category~hryid AND n~hryver = category~hryver
        AND n~hryvalto = category~hryvalto AND category~hryattrname = @cl_fins_uh_constants=>c_hierarchy_category
        LEFT JOIN hrrp_attr_dir AS rollname ON n~hryid = rollname~hryid AND n~hryver = rollname~hryver
        AND n~hryvalto = rollname~hryvalto AND rollname~hryattrname = @cl_fins_uh_constants=>c_rollname
        LEFT JOIN hrrp_nodet AS t
        ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras = @sy-langu
        AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto FOR ALL ENTRIES IN @lt_setkeylist_ccpc
         WHERE ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
          AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
          AND n~hryid = @lt_setkeylist_ccpc-hryidpattern
          AND n~nodevalue = @lt_setkeylist_ccpc-nodevalue.
*          AND n~hryver EQ ( SELECT max( hryver ) from hrrp_directory where hryid = @lt_setkeylist-hryidpattern ).
    ENDIF.

    SORT lt_node BY hryid hryver hryvalto hrynode.
    DELETE ADJACENT DUPLICATES FROM lt_node COMPARING hryid hryver hryvalto hrynode.

    LOOP AT lt_node ASSIGNING FIELD-SYMBOL(<fs_node>).
      CLEAR: lv_setclass, ls_sethier.
      ls_sethier-descript = <fs_node>-nodetxt.
      ls_sethier-level = 0.
      lv_setclass = gsetc_costcenter_setclass.

      me->get_table_info_by_set_class(
        EXPORTING
          iv_setclass = lv_setclass
        IMPORTING
          ev_roll_name  = ls_sethier-rollname
          ev_tab_name   = ls_sethier-tabname
          ev_field_name = ls_sethier-fieldname
      ).
      ls_sethier-kokrs = <fs_node>-nodecls.
      SPLIT <fs_node>-hryid AT '/'  INTO DATA(lv_hierarchy_namespace) DATA(lv_subclass) lv_hryid.
      lv_subclass = <fs_node>-nodecls.

      IF <fs_node>-nodetype = if_fins_hrrp_hier_builder=>cv_nodetype_root.
        DATA(lv_shortname) = lv_hryid && if_fins_uh_hrrp_legacy~gc_virtual_tag.
      ELSE.
        lv_shortname = lv_hryid && if_fins_uh_hrrp_legacy~gc_virtual_tag && <fs_node>-nodevalue.
      ENDIF.
      CALL FUNCTION 'G_SET_ENCRYPT_SETID'
        EXPORTING
          setclass  = lv_setclass
          kokrs     = ls_sethier-kokrs
          ktopl     = ls_sethier-ktopl
          shortname = CONV setnamenew( lv_shortname )
          subclass  = CONV setsubcls( lv_subclass )
        IMPORTING
          setid     = ls_sethier-setid.
      ls_sethier-setclass = lv_setclass.
      ls_sethier-subclass = lv_subclass.
      ls_sethier-shortname = lv_shortname.
      ls_sethier-searchfld = lv_subclass.

      APPEND ls_sethier TO et_sethier.
    ENDLOOP.
  ENDMETHOD.


  METHOD IF_FINS_UH_HRRP_LEGACY~SELECT_SETS.
    DATA: lv_setid      TYPE setid,
          lv_hryid      TYPE hrrp_node-hryid,
          lv_nodevalue  TYPE hrrp_node-nodevalue,
          lv_setname    TYPE setnamenew,
          lv_subclass   TYPE setsubcls,
          lv_createuser LIKE iv_createuser,
          lv_updateuser LIKE iv_updateuser,
          ls_sethier    TYPE sethier.

    IF me->check_allow_legacy( ) <> 0.
      RETURN.
    ENDIF.

    IF me->check_authority( iv_hry_type = mv_hrrp_type ) <> 0.
      RETURN.
    ENDIF.

    lv_subclass = iv_kokrs .
    TRANSLATE lv_subclass USING '+_*%'.

    IF iv_createuser IS INITIAL.
      lv_createuser = '%'.
    ELSE.
      lv_createuser = iv_createuser.
      TRANSLATE lv_createuser USING '+_*%'.
    ENDIF.

    IF iv_updateuser IS INITIAL.
      lv_updateuser = '%'.
    ELSE.
      lv_updateuser = iv_updateuser.
      TRANSLATE lv_updateuser USING '+_*%'.
    ENDIF.

    lv_setname = iv_setname.
    IF lv_setname IS INITIAL.
      lv_setname = '%'.
    ENDIF.
    IF lv_setname CS if_fins_uh_hrrp_legacy~gc_virtual_tag.
      SPLIT lv_setname AT if_fins_uh_hrrp_legacy~gc_virtual_tag INTO lv_hryid lv_nodevalue.
      IF lv_nodevalue IS INITIAL.
        lv_nodevalue = lv_hryid.
      ENDIF.
      lv_hryid = mv_hrrp_prefix_pattern && lv_subclass && '/' && lv_hryid.
    ELSEIF lv_setname CA '_%'. "Need to filter later
      lv_hryid = mv_hrrp_prefix_pattern && lv_subclass && '/%'.
      lv_nodevalue = '%'.
    ELSE.
      RETURN.
    ENDIF.

    IF iv_typelist IS NOT INITIAL AND iv_typelist NA 'BS'.
      RETURN.
    ENDIF.

    DATA lv_keydate TYPE sy-datum.
    lv_keydate = sy-datum.

    IF mv_valid_from IS INITIAL OR mv_valid_to IS INITIAL.
      IF iv_typelist IS NOT INITIAL AND ( iv_typelist NS 'S' OR iv_typelist NS 'B' ).
*       BASIC/SINGLE SETS WITH CHILDNODE COUNT
        SELECT DISTINCT n~hryid, n~hryver, n~hryvalto, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count INTO TABLE @DATA(lt_hrrp)
        FROM hrrp_node AS n INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
        AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
        LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
        LEFT JOIN hrrp_nodet AS t
        ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
        AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
        INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
        WHERE a~hryattrvalue = 'X'
          AND n~hryid LIKE @lv_hryid
          AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
          AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
          AND n~nodevalue LIKE @lv_nodevalue
          AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
          AND d~upduser LIKE @lv_createuser
          AND d~upduser LIKE @lv_updateuser
          GROUP BY n~hryid, n~hryver, n~hryvalto, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt.
      ELSE.
*       TOP NODES ONLY
        IF iv_typelist IS INITIAL.
          SELECT DISTINCT n~hryid, n~hryver, n~hryvalto, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt INTO TABLE @lt_hrrp
          FROM hrrp_node AS n INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
          AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
          LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE a~hryattrvalue = 'X'
            AND n~hryid LIKE @lv_hryid
            AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root )
            AND n~nodevalue LIKE @lv_nodevalue
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND d~upduser LIKE @lv_createuser
            AND d~upduser LIKE @lv_updateuser.
        ELSE.
*       ALL NODES
          SELECT DISTINCT n~hryid, n~hryver, n~hryvalto, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt INTO TABLE @lt_hrrp
          FROM hrrp_node AS n INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
          AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
          LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE a~hryattrvalue = 'X'
            AND n~hryid LIKE @lv_hryid
            AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
            AND n~nodevalue LIKE @lv_nodevalue
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND d~upduser LIKE @lv_createuser
            AND d~upduser LIKE @lv_updateuser.
        ENDIF.
      ENDIF.
    ELSE.
      DATA lt_valid_hrrp_dir TYPE RANGE OF hryid.
      "GET hierarchy for this period
      SELECT DISTINCT d~hryid, d~hryver, d~hryvalto, d~hryvalfrom INTO TABLE @DATA(lt_hrrp_dir)
      FROM hrrp_directory AS d INNER JOIN hrrp_attr_dir AS a ON d~hryid = a~hryid AND d~hryver = a~hryver
      AND d~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
      WHERE a~hryattrvalue = 'X'
        AND d~hryid LIKE @lv_hryid
        AND d~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
        AND d~hryvalto GE @mv_valid_from AND d~hryvalfrom LE @mv_valid_to
        AND d~upduser LIKE @lv_createuser
        AND d~upduser LIKE @lv_updateuser.

      SORT lt_hrrp_dir BY hryid hryvalfrom.

      DATA lt_timelap TYPE if_fins_uh_hrrp_legacy=>tt_timelap.
      LOOP AT lt_hrrp_dir REFERENCE INTO DATA(lr_hrrp_dir_grp) GROUP BY lr_hrrp_dir_grp->hryid.
        CLEAR: lt_timelap.
        LOOP AT GROUP lr_hrrp_dir_grp REFERENCE INTO DATA(lr_hrrp_dir).
          APPEND VALUE #( hryvalfrom = lr_hrrp_dir->hryvalfrom
                          hryvalto   = lr_hrrp_dir->hryvalto ) TO lt_timelap.
        ENDLOOP.

        DATA(lv_valid) = me->check_validity( it_timelap = lt_timelap
                                             iv_valid_from = mv_valid_from
                                             iv_valid_to = mv_valid_to ).
        IF lv_valid EQ abap_true.
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low = lr_hrrp_dir_grp->hryid ) TO lt_valid_hrrp_dir.
        ENDIF.
      ENDLOOP.

      IF lt_valid_hrrp_dir IS INITIAL.
        RETURN.
      ENDIF.

      IF mv_valid_from <= sy-datum AND mv_valid_to >= sy-datum.
      ELSEIF sy-datum < mv_valid_from.
        lv_keydate = mv_valid_from.
      ELSEIF sy-datum > mv_valid_to.
        lv_keydate = mv_valid_to.
      ENDIF.

      IF iv_typelist IS NOT INITIAL AND ( iv_typelist NS 'S' OR iv_typelist NS 'B' ).
*       BASIC/SINGLE SETS WITH CHILDNODE COUNT
        SELECT n~hryid, n~hryver, n~hryvalto, n~hryvalfrom, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count INTO TABLE @DATA(lt_hrrp_time)
        FROM hrrp_node AS n
        LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
        LEFT JOIN hrrp_nodet AS t
        ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras = @sy-langu
        AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
        INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
        WHERE n~hryid IN @lt_valid_hrrp_dir
          AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
          AND n~nodevalue LIKE @lv_nodevalue
          AND n~hryvalto GE @mv_valid_from AND n~hryvalfrom LE @mv_valid_to
          GROUP BY n~hryid, n~hryver, n~hryvalto, n~hryvalfrom, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt.
      ELSE.
*       TOP NODES ONLY
        IF iv_typelist IS INITIAL.
          SELECT n~hryid, n~hryver, n~hryvalto, n~hryvalfrom, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt INTO TABLE @lt_hrrp_time
          FROM hrrp_node AS n
          LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE n~hryid IN @lt_valid_hrrp_dir
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root )
            AND n~nodevalue LIKE @lv_nodevalue
            AND n~hryvalto GE @mv_valid_from AND n~hryvalfrom LE @mv_valid_to.
        ELSE.
*       ALL NODES
          SELECT n~hryid, n~hryver, n~hryvalto, n~hryvalfrom, n~nodecls, n~hrynode, n~nodevalue, n~nodetype,d~upduser,d~updtime, t~nodetxt INTO TABLE @lt_hrrp_time
          FROM hrrp_node AS n
          LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE n~hryid IN @lt_valid_hrrp_dir
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
            AND n~nodevalue LIKE @lv_nodevalue
            AND n~hryvalto GE @mv_valid_from AND n~hryvalfrom LE @mv_valid_to.
        ENDIF.
      ENDIF.

      SORT lt_hrrp_time BY hryid hrynode hryvalfrom.
      DATA ls_hrrp LIKE LINE OF lt_hrrp.
      LOOP AT lt_hrrp_time REFERENCE INTO DATA(lr_hrrp_time_dir_grp) GROUP BY lr_hrrp_time_dir_grp->hryid .
        LOOP AT GROUP lr_hrrp_time_dir_grp REFERENCE INTO DATA(lr_hrrp_time_node_grp) GROUP BY lr_hrrp_time_node_grp->hrynode.
        CLEAR: lt_timelap, ls_hrrp.
          LOOP AT GROUP lr_hrrp_time_node_grp REFERENCE INTO DATA(lr_hrrp_time_node).
            APPEND VALUE #( hryvalfrom = lr_hrrp_time_node->hryvalfrom
                            hryvalto   = lr_hrrp_time_node->hryvalto ) TO lt_timelap.
            IF lr_hrrp_time_node->hryvalfrom LE lv_keydate AND lr_hrrp_time_node->hryvalto GE lv_keydate.
              MOVE-CORRESPONDING lr_hrrp_time_node->* TO ls_hrrp.
            ENDIF.
          ENDLOOP.
          lv_valid = me->check_validity( it_timelap = lt_timelap
                                         iv_valid_from = mv_valid_from
                                         iv_valid_to = mv_valid_to ).
          IF lv_valid EQ abap_true.
            APPEND ls_hrrp TO lt_hrrp.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    TRANSLATE lv_setname USING '_+%*'.
    TRANSLATE lv_subclass USING '_+%*'.

    IF lt_hrrp IS INITIAL.
      RETURN.
    ENDIF.

    "Authority Check on ID level
    DATA(lt_hrrp_cp_hryid) = lt_hrrp.
    SORT lt_hrrp_cp_hryid BY hryid.
    DELETE ADJACENT DUPLICATES FROM lt_hrrp_cp_hryid COMPARING hryid.
    LOOP AT lt_hrrp_cp_hryid ASSIGNING FIELD-SYMBOL(<fs_hrrp_cp_hryid>).
      SPLIT <fs_hrrp_cp_hryid>-hryid AT '/'  INTO DATA(lv_hryid_part1) DATA(lv_hryid_part2) DATA(lv_hryid_part3).
      IF lv_hryid_part3 IS NOT INITIAL.
        DATA(lv_hryid_auth) = lv_hryid_part3.
      ELSEIF lv_hryid_part2 IS NOT INITIAL.
        lv_hryid_auth = lv_hryid_part2.
      ELSE.
        lv_hryid_auth = lv_hryid_part1.
      ENDIF.

      IF me->CHECK_AUTHORITY( iv_hry_type = mv_hrrp_type iv_hryid = CONV hryid( lv_hryid_auth ) ) <> 0.
        DELETE lt_hrrp WHERE hryid = <fs_hrrp_cp_hryid>-hryid.
      ENDIF.

      CLEAR: lv_hryid_part1, lv_hryid_part2, lv_hryid_part3, lv_hryid_auth.
    ENDLOOP.

    DATA lv_syszone TYPE systzonlo.

    CALL FUNCTION 'GET_SYSTEM_TIMEZONE'
      IMPORTING
        timezone            = lv_syszone
      EXCEPTIONS
        customizing_missing = 1
        OTHERS              = 2.

    IF sy-subrc <> 0.
      lv_syszone = sy-zonlo.
    ENDIF.

   LOOP AT lt_hrrp ASSIGNING FIELD-SYMBOL(<fs_hrrp>).

      SPLIT <fs_hrrp>-hryid AT '/'  INTO DATA(lv_hierarchy_namespace) lv_subclass lv_hryid.
      IF lv_hryid IS INITIAL.
        lv_hryid = lv_subclass.
        CLEAR lv_subclass.
      ENDIF.
      DATA(lv_hid_length) = strlen( lv_hryid ).
      CHECK lv_hid_length LE cl_fins_uh_constants=>c_length_restriction-hid_for_legacy. "Hierarchy ID must be max. 8 characters after second /, as this goes into the "prefix" of the set name
      IF <fs_hrrp>-nodetype EQ if_fins_hrrp_hier_builder=>cv_nodetype_root.
        <fs_hrrp>-nodevalue = ''.
      ENDIF.
      DATA(lv_total_length) = strlen( lv_hryid ) + strlen( <fs_hrrp>-nodevalue ).
      CHECK lv_total_length LE cl_fins_uh_constants=>c_length_restriction-hid_node_val_for_legacy. "Nodevalue goes into the "suffix" of the set name, total length is 15 including '~'
      DATA(lv_shortname) = lv_hryid && if_fins_uh_hrrp_legacy~gc_virtual_tag && <fs_hrrp>-nodevalue.
      CHECK lv_shortname CP lv_setname.
      IF mv_set_class CP gsetc_all_co_setclasses.
        DATA(lv_kokrs) = CONV kokrs( lv_subclass ).
      ENDIF.
      CALL FUNCTION 'G_SET_ENCRYPT_SETID'
        EXPORTING
          setclass  = mv_set_class
          kokrs     = lv_kokrs
          shortname = CONV setnamenew( lv_shortname )
          subclass  = lv_subclass
        IMPORTING
          setid     = lv_setid.
      IF iv_descript IS NOT INITIAL.
        CHECK <fs_hrrp>-nodetxt CP iv_descript.
      ENDIF.

      IF iv_typelist IS NOT INITIAL AND ( iv_typelist NS 'S' OR iv_typelist NS 'B' ). "Check type restriction (B = lowest level)
*        SELECT COUNT(*) FROM hrrp_node
*          WHERE hryid    = <fs_hrrp>-hryid
*            AND hryver   = <fs_hrrp>-hryver
*            AND nodecls  = <fs_hrrp>-nodecls
*            AND parnode  = <fs_hrrp>-hrynode
*            AND nodetype = if_fins_hrrp_hier_builder=>cv_nodetype_node.
        IF <fs_hrrp>-count > 0. "There are other nodes as children => expose as single set
          CHECK iv_typelist CS 'S'.
        ELSE.            "No child nodes => expose as basic set
          CHECK iv_typelist CS 'B'.
        ENDIF.
      ENDIF.
      APPEND lv_setid TO ct_setlist.

      IF et_sethier IS REQUESTED.
        CLEAR: ls_sethier.
        ls_sethier-descript = <fs_hrrp>-nodetxt.
        ls_sethier-level = 0.

        ls_sethier-setid = lv_setid.
        ls_sethier-setclass = mv_set_class.
        ls_sethier-shortname = lv_shortname.
        ls_sethier-creuser = <fs_hrrp>-upduser.
        CONVERT TIME STAMP <fs_hrrp>-updtime TIME ZONE lv_syszone INTO DATE ls_sethier-credate TIME ls_sethier-cretime.
        ls_sethier-upduser = <fs_hrrp>-upduser.
        ls_sethier-upddate = ls_sethier-credate.
        ls_sethier-updtime = ls_sethier-cretime.
        APPEND ls_sethier TO et_sethier.
      ENDIF.
    ENDLOOP.

    SORT ct_setlist.
    DELETE ADJACENT DUPLICATES FROM ct_setlist COMPARING ALL FIELDS.
  ENDMETHOD.


  method IF_FINS_UH_HRRP_LEGACY~SELECT_SETS_BY_NAME.
    DATA: lv_hryid     TYPE hrrp_node-hryid,
          lv_nodevalue TYPE hrrp_node-nodevalue.

    IF me->check_allow_legacy( ) <> 0.
      RETURN.
    ENDIF.

    IF me->check_authority( iv_hry_type = mv_hrrp_type ) <> 0.
      RETURN.
    ENDIF.

    CLEAR et_setkeylist.

    CHECK iv_setname CS if_fins_uh_hrrp_legacy~gc_virtual_tag.
    SPLIT iv_setname AT if_fins_uh_hrrp_legacy~gc_virtual_tag INTO lv_hryid lv_nodevalue.
    DATA(lv_hid_max_length) = strlen( lv_hryid ).
    CHECK lv_hid_max_length LE cl_fins_uh_constants=>c_length_restriction-hid_for_legacy.
    DATA(lv_total_length) = strlen( lv_hryid ) + strlen( lv_nodevalue ).
    CHECK lv_total_length LE cl_fins_uh_constants=>c_length_restriction-hid_node_val_for_legacy. "Nodevalue goes into the "suffix" of the set name, total length is 15 including '~'
    IF lv_nodevalue IS INITIAL.
      lv_nodevalue = lv_hryid.
    ENDIF.
    lv_hryid = mv_hrrp_prefix_pattern && '____/' && lv_hryid.

    DATA lv_keydate TYPE sy-datum.
    lv_keydate = sy-datum.

    IF mv_valid_from IS INITIAL OR mv_valid_to IS INITIAL.

      SELECT DISTINCT n~hryid, n~nodevalue INTO TABLE @DATA(lt_hrrp)
        FROM hrrp_node as n
        INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
        AND n~hryvalto = a~hryvalto and a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
        WHERE n~hryid     LIKE @lv_hryid
        AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
        AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
        AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
        AND n~nodevalue   =  @lv_nodevalue
        AND a~hryattrvalue = 'X'.

    ELSE.
      DATA lt_valid_hrrp_dir TYPE RANGE OF hryid.
      "GET hierarchy for this period
      SELECT DISTINCT d~hryid, d~hryver, d~hryvalto, d~hryvalfrom INTO TABLE @DATA(lt_hrrp_dir)
      FROM hrrp_directory AS d INNER JOIN hrrp_attr_dir AS a ON d~hryid = a~hryid AND d~hryver = a~hryver
      AND d~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
      WHERE a~hryattrvalue = 'X'
        AND d~hryid LIKE @lv_hryid
        AND d~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
        AND d~hryvalto GE @mv_valid_from AND d~hryvalfrom LE @mv_valid_to.

      SORT lt_hrrp_dir BY hryid hryvalfrom.

      DATA lt_timelap TYPE if_fins_uh_hrrp_legacy=>tt_timelap.
      LOOP AT lt_hrrp_dir REFERENCE INTO DATA(lr_hrrp_dir_grp) GROUP BY lr_hrrp_dir_grp->hryid.
        CLEAR: lt_timelap.
        LOOP AT GROUP lr_hrrp_dir_grp REFERENCE INTO DATA(lr_hrrp_dir).
          APPEND VALUE #( hryvalfrom = lr_hrrp_dir->hryvalfrom
                          hryvalto   = lr_hrrp_dir->hryvalto ) TO lt_timelap.
        ENDLOOP.

        DATA(lv_valid) = me->check_validity( it_timelap = lt_timelap
                                             iv_valid_from = mv_valid_from
                                             iv_valid_to = mv_valid_to ).
        IF lv_valid EQ abap_true.
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low = lr_hrrp_dir_grp->hryid ) TO lt_valid_hrrp_dir.
        ENDIF.
      ENDLOOP.

      IF lt_valid_hrrp_dir IS INITIAL.
        RETURN.
      ENDIF.

      IF mv_valid_from <= sy-datum AND mv_valid_to >= sy-datum.
      ELSEIF sy-datum < mv_valid_from.
        lv_keydate = mv_valid_from.
      ELSEIF sy-datum > mv_valid_to.
        lv_keydate = mv_valid_to.
      ENDIF.

      SELECT DISTINCT n~hryid, n~hrynode, n~hryvalto, n~hryvalfrom, n~nodevalue INTO TABLE @DATA(lt_hrrp_time)
        FROM hrrp_node as n
        WHERE n~hryid IN @lt_valid_hrrp_dir
        AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root OR n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node )
        AND n~hryvalto GE @mv_valid_from AND n~hryvalfrom LE @mv_valid_to
        AND n~nodevalue = @lv_nodevalue.

      SORT lt_hrrp_time BY hryid hrynode hryvalfrom.
      DATA ls_hrrp LIKE LINE OF lt_hrrp.
      LOOP AT lt_hrrp_time REFERENCE INTO DATA(lr_hrrp_time_dir_grp) GROUP BY lr_hrrp_time_dir_grp->hryid .
        LOOP AT GROUP lr_hrrp_time_dir_grp REFERENCE INTO DATA(lr_hrrp_time_node_grp) GROUP BY lr_hrrp_time_node_grp->hrynode.
        CLEAR: lt_timelap, ls_hrrp.
          LOOP AT GROUP lr_hrrp_time_node_grp REFERENCE INTO DATA(lr_hrrp_time_node).
            APPEND VALUE #( hryvalfrom = lr_hrrp_time_node->hryvalfrom
                            hryvalto   = lr_hrrp_time_node->hryvalto ) TO lt_timelap.
            IF lr_hrrp_time_node->hryvalfrom LE lv_keydate AND lr_hrrp_time_node->hryvalto GE lv_keydate.
              MOVE-CORRESPONDING lr_hrrp_time_node->* TO ls_hrrp.
            ENDIF.
          ENDLOOP.
          lv_valid = me->check_validity( it_timelap = lt_timelap
                                         iv_valid_from = mv_valid_from
                                         iv_valid_to = mv_valid_to ).
          IF lv_valid EQ abap_true.
            APPEND ls_hrrp TO lt_hrrp.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    "Authority Check on ID level
    DATA(lt_hrrp_cp_hryid) = lt_hrrp.
    SORT lt_hrrp_cp_hryid BY hryid.
    DELETE ADJACENT DUPLICATES FROM lt_hrrp_cp_hryid COMPARING hryid.
    LOOP AT lt_hrrp_cp_hryid ASSIGNING FIELD-SYMBOL(<fs_hrrp_cp_hryid>).
      SPLIT <fs_hrrp_cp_hryid>-hryid AT '/'  INTO DATA(lv_hryid_part1) DATA(lv_hryid_part2) DATA(lv_hryid_part3).
      IF lv_hryid_part3 IS NOT INITIAL.
        DATA(lv_hryid_auth) = lv_hryid_part3.
      ELSEIF lv_hryid_part2 IS NOT INITIAL.
        lv_hryid_auth = lv_hryid_part2.
      ELSE.
        lv_hryid_auth = lv_hryid_part1.
      ENDIF.

      IF me->CHECK_AUTHORITY( iv_hry_type = mv_hrrp_type iv_hryid = CONV hryid( lv_hryid_auth ) ) <> 0.
        DELETE lt_hrrp WHERE hryid = <fs_hrrp_cp_hryid>-hryid.
      ENDIF.

      CLEAR: lv_hryid_part1, lv_hryid_part2, lv_hryid_part3, lv_hryid_auth.
    ENDLOOP.

    me->get_table_info_by_set_class(
      EXPORTING
        iv_setclass = mv_set_class
      IMPORTING
        ev_roll_name  = DATA(lv_roll_name)
        ev_tab_name   = DATA(lv_tab_name)
        ev_field_name = DATA(lv_field_name)
    ).
    LOOP AT lt_hrrp ASSIGNING FIELD-SYMBOL(<fs_hrrp>).
      SPLIT <fs_hrrp>-hryid AT '/'  INTO DATA(lv_hierarchy_namespace) DATA(lv_subclass) lv_hryid.
      IF lv_hryid IS INITIAL."no subclass
        lv_hryid = lv_subclass.
        CLEAR lv_subclass.
      ENDIF.
      APPEND VALUE #( setclass = mv_set_class subclass = lv_subclass
                      setname = iv_setname rollname = lv_roll_name tabname = lv_tab_name )
      TO et_setkeylist.
    ENDLOOP.

    SORT et_setkeylist.
    DELETE ADJACENT DUPLICATES FROM et_setkeylist COMPARING ALL FIELDS.
  endmethod.


  METHOD IF_FINS_UH_HRRP_LEGACY~SELECT_SETS_RANGES.
    DATA: lv_setid     TYPE setid,
          lv_hryid     TYPE hrrp_node-hryid,
          lv_nodevalue TYPE hrrp_node-nodevalue,
          lv_setname   TYPE setnamenew,
          ls_sethier   LIKE LINE OF ct_setlist.

    IF me->check_allow_legacy( ) <> 0.
      RETURN.
    ENDIF.

    IF me->check_authority( iv_hry_type = mv_hrrp_type ) <> 0.
      RETURN.
    ENDIF.

    IF iv_typelist IS NOT INITIAL AND iv_typelist NA 'BS'.
      RETURN.
    ENDIF.

    DATA lv_keydate TYPE sy-datum.
    lv_keydate = sy-datum.

    IF mv_valid_from IS INITIAL OR mv_valid_to IS INITIAL.
      IF iv_typelist IS NOT INITIAL.
*       BASIC/SINGLE SETS WITH CHILDNODE COUNT
        SELECT n~hryid, n~hryver, n~nodecls, n~hrynode, n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, d~updtime, d~upduser, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count
          FROM hrrp_node AS n LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
          INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
          WHERE n~hryid LIKE @mv_hrrp_prefix_pattern
            AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
            AND substring( n~hryid, 6, 4 ) IN @it_subclass
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND ( ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), concat( '~', n~nodevalue ) ) IN @it_setname ) OR
            ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), '~' ) IN @it_setname ) )
            AND a~hryattrvalue = 'X'
            AND d~upduser IN @it_createuser
            AND d~upduser IN @it_updateuser
            AND d~hrytyp  IN @it_setclass
          GROUP BY n~hryid, n~hryver, n~nodecls, n~hrynode,  n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, t~nodetxt, d~updtime, d~upduser
          INTO TABLE @DATA(lt_hrrp).
      ELSE.
*       TOP NODES ONLY
        SELECT n~hryid, n~hryver, n~nodecls, n~hrynode, n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, d~updtime, d~upduser, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count
          FROM hrrp_node AS n LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
          INNER JOIN hrrp_attr_dir AS a ON n~hryid = a~hryid AND n~hryver = a~hryver
          AND n~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE n~hryid LIKE @mv_hrrp_prefix_pattern
            AND n~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root )
            AND substring( n~hryid, 6, 4 ) IN @it_subclass
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), '~' ) IN @it_setname
            AND a~hryattrvalue = 'X'
            AND d~upduser IN @it_createuser
            AND d~upduser IN @it_updateuser
            AND d~hrytyp  IN @it_setclass
          GROUP BY n~hryid, n~hryver, n~nodecls, n~hrynode,  n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, t~nodetxt, d~updtime, d~upduser
          INTO TABLE @lt_hrrp.

      ENDIF.
    ELSE.
      DATA lt_valid_hrrp_dir TYPE RANGE OF hryid.
      "GET hierarchy for this period
      SELECT DISTINCT d~hryid, d~hryver, d~hryvalto, d~hryvalfrom INTO TABLE @DATA(lt_hrrp_dir)
      FROM hrrp_directory AS d INNER JOIN hrrp_attr_dir AS a ON d~hryid = a~hryid AND d~hryver = a~hryver
      AND d~hryvalto = a~hryvalto AND a~hryattrname = @cl_fins_uh_constants=>c_legacy_usage
      WHERE a~hryattrvalue = 'X'
        AND d~hryid LIKE @mv_hrrp_prefix_pattern
        AND d~hryid NOT LIKE @if_fins_uh_hrrp_legacy~gc_draft_pattern
        AND d~hryvalto GE @mv_valid_from AND d~hryvalfrom LE @mv_valid_to
        AND d~upduser IN @it_createuser
        AND d~upduser IN @it_updateuser
        AND d~hrytyp  IN @it_setclass.

      SORT lt_hrrp_dir BY hryid hryvalfrom.

      DATA lt_timelap TYPE if_fins_uh_hrrp_legacy=>tt_timelap.
      LOOP AT lt_hrrp_dir REFERENCE INTO DATA(lr_hrrp_dir_grp) GROUP BY lr_hrrp_dir_grp->hryid.
        CLEAR: lt_timelap.
        LOOP AT GROUP lr_hrrp_dir_grp REFERENCE INTO DATA(lr_hrrp_dir).
          APPEND VALUE #( hryvalfrom = lr_hrrp_dir->hryvalfrom
                          hryvalto   = lr_hrrp_dir->hryvalto ) TO lt_timelap.
        ENDLOOP.

        DATA(lv_valid) = me->check_validity( it_timelap = lt_timelap
                                             iv_valid_from = mv_valid_from
                                             iv_valid_to = mv_valid_to ).
        IF lv_valid EQ abap_true.
          APPEND VALUE #( sign = 'I'
                          option = 'EQ'
                          low = lr_hrrp_dir_grp->hryid ) TO lt_valid_hrrp_dir.
        ENDIF.
      ENDLOOP.

      IF lt_valid_hrrp_dir IS INITIAL.
        RETURN.
      ENDIF.

      IF mv_valid_from <= sy-datum AND mv_valid_to >= sy-datum.
      ELSEIF sy-datum < mv_valid_from.
        lv_keydate = mv_valid_from.
      ELSEIF sy-datum > mv_valid_to.
        lv_keydate = mv_valid_to.
      ENDIF.

       IF iv_typelist IS NOT INITIAL.
*       BASIC/SINGLE SETS WITH CHILDNODE COUNT
        SELECT n~hryid, n~hryver, n~nodecls, n~hrynode, n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, d~updtime, d~upduser, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count
          FROM hrrp_node AS n LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE n~hryid IN @lt_valid_hrrp_dir
            AND substring( n~hryid, 6, 4 ) IN @it_subclass
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND ( ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), concat( '~', n~nodevalue ) ) IN @it_setname ) OR
            ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), '~' ) IN @it_setname ) )
          GROUP BY n~hryid, n~hryver, n~nodecls, n~hrynode,  n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, t~nodetxt, d~updtime, d~upduser
          INTO TABLE @DATA(lt_hrrp_time).
      ELSE.
*       TOP NODES ONLY
        SELECT n~hryid, n~hryver, n~nodecls, n~hrynode, n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, d~updtime, d~upduser, t~nodetxt, COUNT( DISTINCT c~hrynode ) AS count
          FROM hrrp_node AS n LEFT JOIN hrrp_nodet AS t
          ON n~hryid = t~hryid AND n~hryver = t~hryver AND n~nodecls = t~nodecls AND t~spras    = @sy-langu
          AND n~hrynode = t~hrynode AND n~parnode = t~parnode AND n~hryvalto = t~hryvalto
          LEFT JOIN hrrp_node AS c ON c~parnode = n~hrynode AND n~nodecls = c~nodecls  AND c~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_node AND n~hryid = c~hryid AND n~hryver = c~hryver AND n~hryvalto = c~hryvalto
          INNER JOIN hrrp_directory AS d ON n~hryid = d~hryid AND n~hryver = d~hryver AND n~hryvalto = d~hryvalto
          WHERE n~hryid IN @lt_valid_hrrp_dir
            AND ( n~nodetype = @if_fins_hrrp_hier_builder=>cv_nodetype_root )
            AND substring( n~hryid, 6, 4 ) IN @it_subclass
            AND n~hryvalto GE @sy-datum AND n~hryvalfrom LE @sy-datum
            AND concat( rtrim( substring( n~hryid, 11, 10 ), @space ), '~' ) IN @it_setname
          GROUP BY n~hryid, n~hryver, n~nodecls, n~hrynode,  n~hryvalto, n~hryvalfrom, n~nodevalue, n~nodetype, t~nodetxt, d~updtime, d~upduser
          INTO TABLE @lt_hrrp_time.
      ENDIF.

      SORT lt_hrrp_time BY hryid hrynode hryvalfrom.
      DATA ls_hrrp LIKE LINE OF lt_hrrp.
      LOOP AT lt_hrrp_time REFERENCE INTO DATA(lr_hrrp_time_dir_grp) GROUP BY lr_hrrp_time_dir_grp->hryid .
        LOOP AT GROUP lr_hrrp_time_dir_grp REFERENCE INTO DATA(lr_hrrp_time_node_grp) GROUP BY lr_hrrp_time_node_grp->hrynode.
        CLEAR: lt_timelap, ls_hrrp.
          LOOP AT GROUP lr_hrrp_time_node_grp REFERENCE INTO DATA(lr_hrrp_time_node).
            APPEND VALUE #( hryvalfrom = lr_hrrp_time_node->hryvalfrom
                            hryvalto   = lr_hrrp_time_node->hryvalto ) TO lt_timelap.
            IF lr_hrrp_time_node->hryvalfrom LE lv_keydate AND lr_hrrp_time_node->hryvalto GE lv_keydate.
              MOVE-CORRESPONDING lr_hrrp_time_node->* TO ls_hrrp.
            ENDIF.
          ENDLOOP.
          lv_valid = me->check_validity( it_timelap = lt_timelap
                                         iv_valid_from = mv_valid_from
                                         iv_valid_to = mv_valid_to ).
          IF lv_valid EQ abap_true.
            APPEND ls_hrrp TO lt_hrrp.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    me->get_table_info_by_set_class(
      EXPORTING
        iv_setclass = mv_set_class
      IMPORTING
        ev_roll_name  = DATA(lv_roll_name)
        ev_tab_name   = DATA(lv_tab_name)
        ev_field_name = DATA(lv_field_name)
    ).

    "Authority Check on ID level
    DATA(lt_hrrp_cp_hryid) = lt_hrrp.
    SORT lt_hrrp_cp_hryid BY hryid.
    DELETE ADJACENT DUPLICATES FROM lt_hrrp_cp_hryid COMPARING hryid.
    LOOP AT lt_hrrp_cp_hryid ASSIGNING FIELD-SYMBOL(<fs_hrrp_cp_hryid>).
      SPLIT <fs_hrrp_cp_hryid>-hryid AT '/'  INTO DATA(lv_hryid_part1) DATA(lv_hryid_part2) DATA(lv_hryid_part3).
      IF lv_hryid_part3 IS NOT INITIAL.
        DATA(lv_hryid_auth) = lv_hryid_part3.
      ELSEIF lv_hryid_part2 IS NOT INITIAL.
        lv_hryid_auth = lv_hryid_part2.
      ELSE.
        lv_hryid_auth = lv_hryid_part1.
      ENDIF.

      IF me->CHECK_AUTHORITY( iv_hry_type = mv_hrrp_type iv_hryid = CONV hryid( lv_hryid_auth ) ) <> 0.
        DELETE lt_hrrp WHERE hryid = <fs_hrrp_cp_hryid>-hryid.
      ENDIF.

      CLEAR: lv_hryid_part1, lv_hryid_part2, lv_hryid_part3, lv_hryid_auth.
    ENDLOOP.

    LOOP AT lt_hrrp ASSIGNING FIELD-SYMBOL(<fs_hrrp>).
      SPLIT <fs_hrrp>-hryid AT '/'  INTO DATA(lv_hierarchy_namespace) DATA(lv_subclass) lv_hryid.
      IF lv_hryid IS INITIAL.
        lv_hryid = lv_subclass.
        CLEAR lv_subclass.
      ENDIF.
      DATA(lv_hid_length) = strlen( lv_hryid ).
      CHECK lv_hid_length LE cl_fins_uh_constants=>c_length_restriction-hid_for_legacy. "Hierarchy ID must be max. 8 characters after second /, as this goes into the "prefix" of the set name
      IF <fs_hrrp>-nodetype = if_fins_hrrp_hier_builder=>cv_nodetype_root.
        <fs_hrrp>-nodevalue = ''.
      ENDIF.
      DATA(lv_total_length) = strlen( lv_hryid ) + strlen( <fs_hrrp>-nodevalue ).
      CHECK lv_total_length LE cl_fins_uh_constants=>c_length_restriction-hid_node_val_for_legacy. "Nodevalue goes into the "suffix" of the set name, total length is 15 including '~'
      lv_setname = lv_hryid && if_fins_uh_hrrp_legacy~gc_virtual_tag && <fs_hrrp>-nodevalue.
      IF it_setname IS NOT INITIAL.
        CHECK lv_setname IN it_setname.
      ENDIF.

      IF mv_set_class CP gsetc_all_co_setclasses.
        DATA(lv_kokrs) = CONV kokrs( lv_subclass ).
      ENDIF.
      CALL FUNCTION 'G_SET_ENCRYPT_SETID'
        EXPORTING
          setclass  = mv_set_class
          kokrs     = lv_kokrs
          shortname = lv_setname
          subclass  = CONV setsubcls( lv_subclass )
        IMPORTING
          setid     = lv_setid.
      CLEAR ls_sethier.
      ls_sethier-level = 0.
      ls_sethier-fieldname = lv_field_name.
      ls_sethier-tabname = lv_tab_name.
      ls_sethier-creuser = ls_sethier-upduser = <fs_hrrp>-upduser.
      TRY.
      cl_abap_tstmp=>systemtstmp_utc2syst( EXPORTING utc_tstmp = <fs_hrrp>-updtime
                                           IMPORTING syst_date = DATA(lv_create_date)
                                                     syst_time = DATA(lv_create_time) ).
        CATCH cx_parameter_invalid_range ##no_handler.
      ENDTRY.
      ls_sethier-credate = ls_sethier-upddate = lv_create_date.
      ls_sethier-rollname = lv_roll_name.
      ls_sethier-kokrs = lv_kokrs.
      ls_sethier-setid = lv_setid.
      ls_sethier-setclass = mv_set_class.
      ls_sethier-subclass = lv_subclass.
      ls_sethier-shortname = lv_setname.
      ls_sethier-set_olangu = sy-langu.
      ls_sethier-descript = <fs_hrrp>-nodetxt.
      IF it_title IS NOT INITIAL.
        CHECK ls_sethier-descript IN it_title.
      ENDIF.

      IF <fs_hrrp>-count > 0. "There are other nodes as children => expose as single set
        IF iv_typelist IS NOT INITIAL.
          CHECK iv_typelist CS 'S'.
        ENDIF.
        ls_sethier-type = 'S'.
      ELSE.            "No child nodes => expose as basic set
        IF iv_typelist IS NOT INITIAL.
          CHECK iv_typelist CS 'B'.
        ENDIF.
        ls_sethier-type = 'B'.
      ENDIF.

      APPEND ls_sethier TO ct_setlist.
    ENDLOOP.

    SORT ct_setlist.
    DELETE ADJACENT DUPLICATES FROM ct_setlist COMPARING ALL FIELDS.
  ENDMETHOD.
ENDCLASS.

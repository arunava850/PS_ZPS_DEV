REPORT z_mc_reset_acsplan.

CLASS lcl_rep_handler DEFINITION.

  PUBLIC SECTION.
    METHODS execute.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_cobj,
        mtid    TYPE dmc_mt_identifier,
        ident   TYPE dmc_ident,
        guid    TYPE dmc_guid,
        tabname TYPE tabname,
      END OF ty_cobj.

    TYPES ty_t_cobj TYPE TABLE OF ty_cobj WITH DEFAULT KEY.

    METHODS scan RETURNING VALUE(ret) TYPE ty_t_cobj.

    METHODS delete_acsplan IMPORTING in TYPE dmc_guid.

    METHODS reset_calculated_flag IMPORTING in TYPE ty_cobj.

ENDCLASS.

CLASS lcl_rep_handler IMPLEMENTATION.

  METHOD execute.

    DATA(lt_cobj) = scan( ).

    IF lt_cobj IS INITIAL.
      WRITE: 'No errors detected'.
      RETURN.
    ELSE.
      DATA(total) = lines( lt_cobj ).
      WRITE: 'Number of migration objects that have been corrected: ' && total.
      ULINE AT /(40).
    ENDIF.

    LOOP AT lt_cobj ASSIGNING FIELD-SYMBOL(<cobj>).
      delete_acsplan( <cobj>-guid ).
      reset_calculated_flag( <cobj> ).
      WRITE: / <cobj>-ident.
    ENDLOOP.

  ENDMETHOD.

  METHOD scan.

    DATA:
      lt_cobj TYPE TABLE OF ty_cobj.

    SELECT sin~mt_id, sin~cobj_ident_trg, cobj~guid, cobj~cobj_alias
      FROM dmc_sin_migobj AS sin
      INNER JOIN dmc_cobj AS cobj ON sin~cobj_ident_trg = cobj~ident
      WHERE sin~cobj_ident_trg IS NOT INITIAL
    INTO TABLE @lt_cobj.

    LOOP AT lt_cobj ASSIGNING FIELD-SYMBOL(<cobj>).
      SELECT SINGLE guid FROM dmc_acs_plan_hdr WHERE owner = @<cobj>-guid AND id = '00001' INTO @DATA(l_acp).

      IF sy-subrc = 0.
        SELECT SINGLE guid FROM dmc_selstring WHERE guid = @l_acp INTO @DATA(l_guid).
        IF sy-subrc <> 0.
          APPEND <cobj> TO ret.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD delete_acsplan.

    SELECT SINGLE guid INTO @DATA(l_acp) FROM dmc_acs_plan_hdr WHERE owner = @in AND id = '00001'.
    DELETE FROM dmc_access_plan WHERE guid = l_acp.
    DELETE FROM dmc_acs_plan_hdr WHERE guid = l_acp.

  ENDMETHOD.

  METHOD reset_calculated_flag.

    DATA lo_mt_model TYPE REF TO if_dmc_mt_model.

    lo_mt_model ?= cl_dmc_obj_model_access=>create_by_model(
      EXPORTING
        iv_mt_id      = in-mtid
        iv_model_type = if_dmc_obj_model_constants=>gc_mt_model
    ).

    lo_mt_model->update_mt_tables_fields(
      EXPORTING
        iv_where_tabname    = in-tabname
        iv_failed           = dmct_false
        iv_calculated       = dmct_false
        iv_access_plan_type = ''
    ).

  ENDMETHOD.

ENDCLASS.



START-OF-SELECTION.

  NEW lcl_rep_handler( )->execute( ).

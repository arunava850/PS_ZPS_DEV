*&---------------------------------------------------------------------*
*& Include          ZFI_REV_POS_STORAGE_RETAIL_TOP
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_file,
          site_no(10)       TYPE c,
          record_dt(20)     TYPE c,
          finty_code(8)     TYPE c,
          finty_scode(8)    TYPE c,
          findet_typ(25)    TYPE c,
          findet_subtyp(25) TYPE c,
          dueto_from(10)    TYPE c,
          cstmr_typc(10)    TYPE c,
          cstm_typ(20)      TYPE c,
          tax_typ_code(4)   TYPE c,
          tax_typ_nam(20)   TYPE c,
          amount(25)        TYPE c,
          datatyp(15)       TYPE c,
        END OF ty_file.

DATA : gt_file   TYPE TABLE OF ty_file,
       gs_file   TYPE ty_file,
       gt_data   TYPE zfit_revpos_sto_ret_ins,
       gs_data   TYPE zfi_revpos_sto_ret_ins,
       gt_trans  TYPE TABLE OF zfi_ar_rev_post,
       gs_trans  TYPE zfi_ar_rev_post,
       gt_return TYPE TABLE OF zfi_ar_rev_post,
       gv_item   TYPE int4,
       lt_update TYPE TABLE OF zfi_ar_rev_post,
       gr_site   TYPE RANGE OF zsiteno,
       gs_site   LIKE LINE OF gr_site.

DATA: lr_table      TYPE REF TO cl_salv_table,
      lr_selections TYPE REF TO cl_salv_selections.
DATA:ls_api   TYPE REF TO if_salv_gui_om_extend_grid_api,
     ls_edit  TYPE REF TO if_salv_gui_om_edit_restricted,
     lv_grbew TYPE lvc_fname,
     lv_note  TYPE lvc_fname.
DATA: lr_columns    TYPE REF TO cl_salv_columns_table.
*... §3 Functions
DATA: lr_functions TYPE REF TO cl_salv_functions_list,
      l_text       TYPE string,
      l_icon       TYPE string.
CONSTANTS: gc_true TYPE sap_bool VALUE 'X',

           BEGIN OF gc_s_display,
             list       TYPE i VALUE 1,
             fullscreen TYPE i VALUE 2,
             grid       TYPE i VALUE 3,
           END   OF gc_s_display.
*... §5 Definition is later
CLASS lcl_handle_events DEFINITION DEFERRED.
DATA: gr_events TYPE REF TO cl_salv_events_table,
      gr_handle TYPE REF TO lcl_handle_events.
DATA: gr_container TYPE REF TO cl_gui_custom_container.
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_before_salv_function FOR EVENT before_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_after_salv_function FOR EVENT after_salv_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column,
      on_click FOR EVENT added_function OF cl_salv_events.
ENDCLASS.                    "lcl_handle_events DEFINITION

CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
*    PERFORM show_function_info USING e_salv_function TEXT-i08.
  ENDMETHOD.                    "on_user_command

  METHOD on_before_salv_function.
*    PERFORM show_function_info USING e_salv_function TEXT-i09.
  ENDMETHOD.                    "on_before_salv_function

  METHOD on_after_salv_function.
*    PERFORM show_function_info USING e_salv_function TEXT-i10.
  ENDMETHOD.                    "on_after_salv_function

  METHOD on_double_click.
*    PERFORM show_cell_info USING row column TEXT-i07.
  ENDMETHOD.                    "on_double_click

  METHOD on_link_click.
*    PERFORM show_cell_info USING row column TEXT-i06.
  ENDMETHOD.                    "on_single_click
  METHOD on_click.
*    MESSAGE ' button clicked' TYPE 'I'.
    DATA: lo_selections TYPE REF TO cl_salv_selections.
    DATA lt_rows TYPE salv_t_row.
    DATA : ls_row       TYPE i,
           lt_trans     TYPE TABLE OF zfi_ar_rev_post,
           lt_del_trans TYPE TABLE OF zfi_ar_rev_post.
    lo_selections = lr_table->get_selections( ).
    lt_rows = lo_selections->get_selected_rows( ).
    IF sy-ucomm = 'DELT'.
      LOOP AT lt_rows INTO ls_row.
        READ TABLE gt_trans INTO DATA(gs_trns_del) INDEX ls_row.
        APPEND gs_trns_del TO lt_del_trans.
        CLEAR gs_trns_del.
*        COMMIT WORK.
      ENDLOOP.
      IF lt_del_trans IS NOT INITIAL.
        DELETE zfi_ar_rev_post FROM TABLE lt_del_trans.
        LOOP AT lt_del_trans INTO DATA(ls_tr_del).
          DELETE TABLE gt_trans FROM ls_tr_del.
        ENDLOOP.
      ENDIF.
    ELSEIF sy-ucomm = 'POST'.
      DATA(lr_prcs) = NEW zcl_fi_revpos_ret_sto_ins( ).
      REFRESH : lt_trans.
      LOOP AT lt_rows INTO ls_row.
        READ TABLE gt_trans INTO DATA(gs_trns_pos) INDEX ls_row.
        APPEND gs_trns_pos TO lt_trans.
        CLEAR gs_trns_pos.
      ENDLOOP.
      delete lt_trans WHERE belnr NE space.
      CALL METHOD lr_prcs->post_document
        EXPORTING
          et_data = lt_trans
          gt_file = gt_file
        IMPORTING
          it_ret2 = gt_return.
      LOOP AT lt_rows INTO ls_row.
        READ TABLE gt_trans ASSIGNING FIELD-SYMBOL(<fs_trns_upd>) INDEX ls_row.
        IF sy-subrc EQ 0.
          READ TABLE gt_return INTO DATA(ls_return) WITH KEY zsiteno = <fs_trns_upd>-zsiteno zsno = <fs_trns_upd>-zsno.
          IF sy-subrc EQ 0.
            <fs_trns_upd> = CORRESPONDING #( ls_return ).
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSEIF  sy-ucomm = 'SAVE'.
      TRY.
          ls_edit->validate_changed_data(
                IMPORTING
                  is_input_data_valid = DATA(s)
                ).

   MODIFY ZFI_AR_REV_POST FROM TABLE gt_trans[].
    lr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
    cl_gui_cfw=>flush( ).
        CATCH cx_salv_not_found.
      ENDTRY.
    ENDIF.
    REFRESH : lt_rows. " clear out selections
    CLEAR : lt_rows.
    lo_selections = lr_table->get_selections( ).
    lo_selections->set_selected_rows( lt_rows ).
    lr_table->refresh( refresh_mode = if_salv_c_refresh=>full ).
    cl_gui_cfw=>flush( ).
  ENDMETHOD.                    "on_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION

*&---------------------------------------------------------------------*
*& Include          ZFI_EXCESS_PRCDS_TOP
*&---------------------------------------------------------------------*
CONSTANTS : htab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
            gc_x TYPE c VALUE 'X',
            ctab TYPE c VALUE ','.


TYPES : BEGIN OF ty_file,
          edi_trans_no(10)              TYPE c,
*          attachment(255)               TYPE c,
          edi_trans_date(12)            TYPE c,
          request_type(2)               TYPE c,
          approval_status(1)            TYPE c,
          tenant_number(10)             TYPE c,
          tenant_name(80)               TYPE c,
          payee_number(10)              TYPE c,
          payee_name(80)                TYPE c,
          sales_date(10)                TYPE c,
          gl_account(10)                TYPE c,
          amount(23)                    TYPE c,
          waers(5)                      TYPE c,
          exp_remark(40)                TYPE c,
          invoice_number(16)            TYPE c,
          business_unit_company_code(4) TYPE c,
          business_unit(10)             TYPE c,
          business_unit_state(3)        TYPE c,
          business_unit_country(35)     TYPE c,
          tenant_state(3)               TYPE c,
          posting_date(10)              TYPE c,
          company_code(10)              TYPE c,
          document_type(2)              TYPE c,
          document_number(10)           TYPE c,
          comment_(90)                  TYPE c,
          district(35)                  TYPE c,
          senior_district(35)           TYPE c,
          division(35)                  TYPE c,
          escheat_rule(30)              TYPE c,
          remit_type(30)                TYPE c,
          holding_period(4)             TYPE c,
          holding_UOM(10)               TYPE c,
          pi_delay_period(4)            TYPE c,
          hp_expire_date(10)            TYPE c,
          tracker_sent_date(10)         TYPE c,
          created_by(12)                TYPE c,
          create_date(10)               TYPE c,
          create_time(10)               TYPE c,
          changed_by(12)                TYPE c,
          changed_date(10)              TYPE c,
          changed_time(10)              TYPE c,
          comments(255)                 TYPE c,
        END OF ty_file.

TYPES : BEGIN OF ty_message,
          edi_trans_no TYPE zwtn,
          lifnr        TYPE lifnr,
          message      TYPE zatch,
        END OF ty_message .

* Variables Declaration
*=======================================================================
DATA lv_file TYPE string.
DATA : gt_file    TYPE TABLE OF ty_file,
       gs_file    TYPE ty_file,
       gt_ep_data TYPE TABLE OF zfiap_ep_data,
       gt_message TYPE TABLE OF ty_message.

*$*$-----Display ALV list.
DATA: lcl_table            TYPE REF TO cl_salv_table,
      lcl_functions        TYPE REF TO cl_salv_functions_list,
      lcl_columns          TYPE REF TO cl_salv_columns_table,
      lcl_column           TYPE REF TO cl_salv_column_table,
      lcl_layout           TYPE REF TO cl_salv_layout,
      lcl_sorts            TYPE REF TO cl_salv_sorts,
      lcl_event            TYPE REF TO cl_salv_events_table,
      lcx_root             TYPE REF TO cx_root,
      lcl_display_settings TYPE REF TO cl_salv_display_settings,
      lcl_top_of_page_grid TYPE REF TO cl_salv_form_layout_grid,
      lwa_layout_key       TYPE salv_s_layout_key,
      l_message            TYPE string,
      l_list               TYPE xfeld,
      ref1                 TYPE REF TO cl_gui_alv_grid.
DATA: lr_selections TYPE REF TO cl_salv_selections.


CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.
DATA: event_handler TYPE REF TO lcl_handle_events.

*---------------------
* class implimentation
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_link_click.
    READ TABLE gt_ep_data ASSIGNING FIELD-SYMBOL(<fs_ep_data>) INDEX row.
    CHECK sy-subrc = 0.



  ENDMETHOD.                    "on_link_click
ENDCLASS.


* Parameters
*=======================================================================
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file TYPE rlgrap-filename .
SELECTION-SCREEN END OF BLOCK b1.

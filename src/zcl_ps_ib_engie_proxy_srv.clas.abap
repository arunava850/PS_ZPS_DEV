class ZCL_PS_IB_ENGIE_PROXY_SRV definition
  public
  create public .

public section.

  interfaces ZII_PS_IB_ENGIE_PROXY_SRV .
protected section.
private section.
ENDCLASS.



CLASS ZCL_PS_IB_ENGIE_PROXY_SRV IMPLEMENTATION.


  METHOD zii_ps_ib_engie_proxy_srv~post_data.
*** **** INSERT IMPLEMENTATION HERE **** ***
*      CONSTANTS:
*      co_class TYPE seoclsname VALUE 'CX_MDC_STANDARD_MESSAGE_FAULT'.
*      DATA: lo_app_fault TYPE REF TO cx_ai_application_fault,
*            lo_exep      TYPE REF TO cx_mdc_standard_message_fault.
*      TRY.
*          CALL METHOD /aif/cl_enabler_proxy=>process_message
*            EXPORTING
*              is_input               = input
*              iv_exception_classname = co_class.
*        CATCH cx_ai_application_fault INTO lo_app_fault.
*          lo_exep ?= lo_app_fault.
*          RAISE EXCEPTION lo_exep.
*      ENDTRY.

  DATA: lt_input TYPE ztt_input_engie.
   lt_input = CORRESPONDING #( input-zmt_ib_msgtyp_engie-it_data[] ).
    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lfs_input>).
*      <lfs_input>-vendor_no = |{ <lfs_input>-vendor_no ALPHA = IN }|.
      DATA(lv_len) = strlen( <lfs_input>-property_no ).
      IF lv_len > 10.
        CLEAR <lfs_input>-property_no.
      ENDIF.
    ENDLOOP.

    CALL METHOD zcl_fi_engie_ap_trans_s4=>post_document
      EXPORTING
        it_input  = lt_input
      IMPORTING
        et_return = DATA(lt_return).

  ENDMETHOD.
ENDCLASS.

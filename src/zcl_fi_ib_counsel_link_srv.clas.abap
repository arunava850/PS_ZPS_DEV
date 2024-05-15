class ZCL_FI_IB_COUNSEL_LINK_SRV definition
  public
  create public .

public section.

  interfaces ZII_FI_IB_COUNSEL_LINK_SRV .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_IB_COUNSEL_LINK_SRV IMPLEMENTATION.


  METHOD zii_fi_ib_counsel_link_srv~post_document.

    DATA: lt_input TYPE ztt_ib_counsel_link,
          lv_vendor TYPE lifnr.

*****************************
*    IF 1 = 2.
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

*    ENDIF.
**************************8*

    LOOP AT input-zmt_ib_counsel_link-it_data INTO DATA(ls_data).
      APPEND INITIAL LINE TO lt_input ASSIGNING FIELD-SYMBOL(<lfs_input>).
*      lv_vendor = <lfs_input>-vendor_no.
*      lv_vendor = |{ lv_vendor ALPHA = IN }|.
*      <lfs_input>-vendor_no = lv_vendor.
      <lfs_input> =  CORRESPONDING #( ls_data EXCEPT items ).
      LOOP AT ls_data-items INTO DATA(ls_item).
        DATA(lv_len) = strlen( ls_item-property_no ).
        IF lv_len > 10.
          CLEAR ls_item-property_no.
        ENDIF.
        APPEND INITIAL LINE TO <lfs_input>-items
                           ASSIGNING FIELD-SYMBOL(<lfs_item>).
        <lfs_item> = CORRESPONDING #( ls_item ).
      ENDLOOP.
    ENDLOOP.

    CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>post_document
      EXPORTING
        it_input  = lt_input
      IMPORTING
        et_return = DATA(lt_return).

  ENDMETHOD.
ENDCLASS.

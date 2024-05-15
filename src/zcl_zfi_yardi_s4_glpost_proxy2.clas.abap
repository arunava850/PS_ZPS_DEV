class ZCL_ZFI_YARDI_S4_GLPOST_PROXY2 definition
  public
  create public .

public section.

  interfaces ZII_ZFI_YARDI_S4_GLPOST_PROXY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_YARDI_S4_GLPOST_PROXY2 IMPLEMENTATION.


  METHOD zii_zfi_yardi_s4_glpost_proxy~post_doc.
*** **** INSERT IMPLEMENTATION HERE **** ***
    DATA : gs_data TYPE zfis_yardi_s4_gl_post,
           gt_data TYPE TABLE OF zfis_yardi_s4_gl_post.

       CONSTANTS:
      co_class TYPE seoclsname VALUE 'CX_MDC_STANDARD_MESSAGE_FAULT'.
      DATA: lo_app_fault TYPE REF TO cx_ai_application_fault,
            lo_exep      TYPE REF TO cx_mdc_standard_message_fault.
*      TRY.
*          CALL METHOD /aif/cl_enabler_proxy=>process_message
*            EXPORTING
*              is_input               = input
*              iv_exception_classname = co_class.
*        CATCH cx_ai_application_fault INTO lo_app_fault.
*          lo_exep ?= lo_app_fault.
*          RAISE EXCEPTION lo_exep.
*      ENDTRY.


    LOOP AT input-zfi_yardi_s4_data_type-zdata INTO DATA(ls_data).
      gs_data = CORRESPONDING #( ls_data ).
      APPEND gs_data TO gt_data.
      CLEAR gs_data.
    ENDLOOP.

    CALL FUNCTION 'ZFI_YARDI_S4_GLPOST_PROXY'
      EXPORTING
        et_data = gt_data.


  ENDMETHOD.
ENDCLASS.

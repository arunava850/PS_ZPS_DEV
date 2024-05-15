class ZCL_ZFI_YARDI_S4_GLPOST_PROXY definition
  public
  create public .

public section.

  interfaces ZII_ZFI_YARDI_S4_GLPOST_PROXY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_YARDI_S4_GLPOST_PROXY IMPLEMENTATION.


  METHOD zii_zfi_yardi_s4_glpost_proxy~post_fin.
*** **** INSERT IMPLEMENTATION HERE **** ***
*
    DATA : gt_data TYPE zfit_yardi_s4_gl_post,
           gs_data TYPE zfis_yardi_s4_gl_post.
    LOOP AT input-zyd_post_fin-zdata INTO DATA(ls_input).
      gs_data = CORRESPONDING #( input-zyd_post_fin ).
      APPEND gs_data TO gt_data.
      CLEAR gs_data.
    ENDLOOP.
    IF gt_data IS NOT INITIAL.

      CALL FUNCTION 'ZFI_YARDI_S4_GLPOST_PROXY'
        EXPORTING
          et_data = gt_data.

    ENDIF.

  ENDMETHOD.
ENDCLASS.

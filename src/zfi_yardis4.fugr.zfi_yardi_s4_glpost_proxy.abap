FUNCTION zfi_yardi_s4_glpost_proxy.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ET_DATA) TYPE  ZFIT_YARDI_S4_GL_POST OPTIONAL
*"  EXPORTING
*"     VALUE(BAPIRET2) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------

  DATA : gt_finan  TYPE zfit_yardi_s4_gl_post,
         gt_stat   TYPE zfit_yardi_s4_gl_post,
         gt_return TYPE TABLE OF bapiret2.

  DATA(gr_process) = NEW zcl_fi_yardi_s4_glpost( ).

  gt_finan = et_data[].

*  IF sy-uname = 'SCHITTADI'.
*DELETE gt_finan WHERE zdatatype NE 'FINANCIAL'.
*else.
*  DELETE gt_finan WHERE zdatatype NE 'Financial'.
*  ENDIF.
  IF gt_finan IS NOT INITIAL.
    CALL METHOD gr_process->post_financial
      EXPORTING
        gt_data   = gt_finan
      IMPORTING
        gt_return = gt_return.
    bapiret2 = gt_return[].
  ENDIF.

*  gt_stat = et_data[].
*  DELETE gt_stat WHERE zdatatype = 'Financial'.
*  IF gt_stat IS NOT INITIAL.
*    CALL METHOD gr_process->post_statistical
*      EXPORTING
*        gt_data   = gt_stat
*      IMPORTING
*        gt_return = gt_return.
*  ENDIF.

ENDFUNCTION.

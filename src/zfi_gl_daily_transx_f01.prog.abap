*&---------------------------------------------------------------------*
*& Include          ZFI_GL_DAILY_TRANSX_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_data .


  SELECT acdoca~rldnr , acdoca~rbukrs , acdoca~gjahr   , acdoca~belnr    ,
         acdoca~prctr , acdoca~rcntr  , acdoca~racct   , bkpf~cpudt      ,
         acdoca~budat , acdoca~poper  , acdoca~rhcur   , acdoca~drcrk    ,
         acdoca~hsl   , acdoca~blart  , bkpf~xblnr     , bkpf~bktxt      ,
         acdoca~sgtxt , acdoca~zuonr  , acdoca~segment , acdoca~lifnr    ,
         acdoca~anln1 , acdoca~anln2  , acdoca~anbwa   , acdoca~bwasl_pn ,
         acdoca~bldat ,   "KDURAI 18/03/2024
         lfa1~name1 , acdoca~awref , acdoca~docln
        INTO  TABLE @gt_final
        FROM  acdoca INNER JOIN bkpf
        ON acdoca~gjahr = bkpf~gjahr
        AND acdoca~belnr = bkpf~belnr
        AND acdoca~rbukrs = bkpf~bukrs
        INNER JOIN lfa1
        ON lfa1~lifnr = acdoca~lifnr
        WHERE  acdoca~rldnr   IN   @s_rldnr
          AND  acdoca~rbukrs  IN   @s_rbukrs
          AND  acdoca~prctr   IN   @s_prctr
          AND  bkpf~cpudt     IN   @s_cpudt.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form Send_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM send_data .
  DATA: lv_count TYPE i .
  DATA(lr_send) = NEW zco_co_fi_daily_transx( ).

  LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<fs_acdoca>) .
    IF lv_count = pv_count.
      gs_out-fi_daily_transx_mt-zdata = gt_data[].
      TRY.
          CALL METHOD lr_send->send
            EXPORTING
              output = gs_out.
          COMMIT WORK.
        CATCH cx_ai_system_fault INTO DATA(ls_text).
      ENDTRY.
      CLEAR : lv_count , gt_data[] , gs_out-fi_daily_transx_mt-zdata[] .
    ENDIF.
    lv_count = lv_count + 1 .
    APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>) .
    MOVE-CORRESPONDING <fs_acdoca> TO <fs_data> .
    <fs_data>-lifnr = |{ <fs_acdoca>-lifnr ALPHA = OUT }|.
    <fs_data>-interface_name  = 'INT0073'.
    <fs_data>-receiver_system = 'CNSL'.
    IF <fs_data>-rcntr NE abap_false.
      PERFORM get_value USING 'C' <fs_data>-rcntr CHANGING <fs_data>-rcntr.
    ENDIF.
    IF <fs_data>-prctr NE abap_false.
      PERFORM get_value USING 'P' <fs_data>-prctr CHANGING <fs_data>-prctr.
    ENDIF.
  ENDLOOP.

  IF gt_data IS NOT INITIAL.
    gs_out-fi_daily_transx_mt-zdata = gt_data[].
    TRY.
        CALL METHOD lr_send->send
          EXPORTING
            output = gs_out.
        COMMIT WORK.
      CATCH cx_ai_system_fault INTO ls_text.
    ENDTRY.
  ENDIF.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form Initialize
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialize .

  s_rldnr-low = '0L' .
  APPEND s_rldnr.


  s_cpudt-low = sy-datum - 1 .
  APPEND s_cpudt.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PC
*&      --> LV_CC
*&      <-- <FS_DATA>_RCNTR
*&---------------------------------------------------------------------*
FORM get_value  USING       p_cc TYPE c
                            p_lv_cc TYPE string
                   CHANGING p_rcntr TYPE string.

  DATA:lt_ccpc TYPE STANDARD TABLE OF zfi_pccenters,
       lv_ccpc TYPE char10.

  REFRESH:lt_ccpc.
  lv_ccpc = p_lv_cc.
  CALL FUNCTION 'ZCA_OUTPUT_PC'
    EXPORTING
      iv_pcenters = lv_ccpc
      iv_pc_flag  = p_cc
    TABLES
      et_output   = lt_ccpc.
  READ TABLE lt_CCPC INTO DATA(ls_ccpc) INDEX 1.
  IF sy-subrc IS INITIAL.
    p_rcntr = ls_ccpc-numbr.
    CLEAR:ls_ccpc.
  ELSE.
    p_rcntr = lv_ccpc.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Report ZFI_REFUND_STAT_UPDATE_WC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_refund_stat_update_wc.

TABLES : regup.
TYPES : BEGIN OF ty_final,
          interface_name(10) TYPE c,
          receiver_system(4) TYPE c,
          lifnr              TYPE lifnr,
          bktxt              TYPE bktxt,
          chect              TYPE chect,
          zaldt              TYPE dzaldt,
          vblnr              TYPE vblnr,
        END OF ty_final.
DATA : gt_final TYPE TABLE OF ty_final,
       gs_final TYPE ty_final,
       lv_date  TYPE sy-datum,
       gs_out   TYPE zfi_payment_update_mt,
       gt_data  TYPE zfi_wc_py_dt_tab,
       gs_data  LIKE LINE OF gt_data.


CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_PAYMENT_WC_UPDT'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_laufd FOR regup-laufd,
   s_laufi FOR regup-laufi NO-EXTENSION NO INTERVALS.
  SELECT-OPTIONS : s_lifnr FOR regup-lifnr,
                 s_blart FOR regup-blart NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
*  LOOP AT s_blart.
  s_blart-low = 'ZW'.
  APPEND s_blart.
*  ENDLOOP.


START-OF-SELECTION.
  lv_date = sy-datum - 1.
*  SELECT 'I' AS sign,
*          'EQ' AS option,
*          low AS low,
*          low AS high FROM tvarvc INTO TABLE @DATA(lr_date)
*    WHERE name = @lc_name.


  SELECT laufd,
  laufi,
  xvorl,
  zbukr,
  lifnr,
  kunnr,
  empfg,
  vblnr,
  bukrs,
  belnr,
  gjahr,
  buzei,
  xblnr
    FROM regup INTO TABLE @DATA(lt_regup)
    WHERE laufd IN @s_laufd
     AND  laufi IN @s_laufi
     AND lifnr IN @s_lifnr
     AND blart IN @s_blart
     AND xvorl EQ @space.
  IF sy-subrc EQ 0.
    SORT lt_regup BY laufd laufi.

    SELECT zbukr,
    hbkid,
    hktid,
    rzawe,
    chect,
    checf,
    laufd,
    laufi,
    lifnr,
    kunnr,
    empfg,
    ubhkt,
    zaldt FROM payr INTO TABLE @DATA(lt_payr)
    FOR ALL ENTRIES IN @lt_regup
    WHERE laufd =  @lt_regup-laufd
      AND laufi =  @lt_regup-laufi
      and lifnr = @lt_regup-lifnr.

    SELECT bukrs,
           belnr,
           gjahr,
           bktxt FROM bkpf INTO TABLE @DATA(lt_bkpf)
      FOR ALL ENTRIES IN @lt_regup
      WHERE bukrs =  @lt_regup-bukrs
      AND  belnr = @lt_regup-belnr
       AND gjahr = @lt_regup-gjahr.
    LOOP AT lt_regup INTO DATA(ls_data).
      gs_data-lifnr = |{ ls_data-lifnr ALPHA = OUT }|.
      gs_data-vblnr = ls_data-vblnr.
      gs_data-xblnr = ls_data-xblnr.
      READ TABLE lt_payr INTO DATA(ls_payr) WITH KEY laufd = ls_data-laufd
                                                     laufi = ls_data-laufi
                                                     lifnr = ls_data-lifnr.
      IF sy-subrc EQ 0.
        gs_data-chect = ls_payr-chect.
        gs_data-zaldt = ls_payr-zaldt.
*>> BOC KDURAI 15/05/2024
      ELSE.
        CONTINUE.
*<< EOC KDURAI 15/05/2024
      ENDIF.
*      READ TABLE lt_bkpf INTO DATA(ls_bkpf) WITH KEY bukrs = ls_data-bukrs
*                                                     belnr = ls_data-belnr
*                                                     gjahr = ls_data-gjahr.
*      IF sy-subrc EQ 0.
*        gs_data-bktxt = ls_bkpf-bktxt.
*      ENDIF.
      gs_data-interface_name = 'INT0031'.
      gs_data-receiver_system = 'WC'.
      APPEND gs_data TO gt_data.
      CLEAR gs_data.
    ENDLOOP.
    IF gt_data IS NOT INITIAL.
      DATA(lr_send) = NEW zco_zfi_payment_update_proxy( ).
      gs_out-zfi_payment_update_mt-zdata1 = gt_data[].
      TRY.
          CALL METHOD lr_send->send
            EXPORTING
              output = gs_out.
          COMMIT WORK.
        CATCH cx_ai_system_fault INTO DATA(ls_text).
      ENDTRY.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*& Report ZFI_REFUND_STAT_UPDATE_WC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_rfund_stat_update_ramp.

TABLES : regup.
TYPES : BEGIN OF ty_final,
          interface_name(10) TYPE c,
          receiver_system(4) TYPE c,
          laufi              TYPE laufi,
          chect              TYPE chect,
          zaldt              TYPE dzaldt,
          voidd              TYPE voidd,
          xblnr              TYPE xblnr,
          lifnr              TYPE lifnr,
          bktxt              TYPE bktxt,
          budat              TYPE budat,
          stodt              TYPE stodt,
*          vblnr              TYPE vblnr,
        END OF ty_final.
DATA : gt_final TYPE TABLE OF ty_final,
       gs_final TYPE ty_final,
       lv_date  TYPE sy-datum,
       gs_out   TYPE zfi_payment_update_mt,
       gt_data  TYPE zfi_wc_py_dt_tab,
       gs_data  LIKE LINE OF gt_data.

DATA : lr_belnr TYPE RANGE OF BSIK_view-belnr,
       ls_belnr LIKE LINE OF lr_belnr.

CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_PAYMENT_WC_UPDT'.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_laufd FOR regup-laufd,
  s_laufi FOR regup-laufi NO-EXTENSION NO INTERVALS.
  SELECT-OPTIONS : s_lifnr FOR regup-lifnr,
                 s_blart FOR regup-blart NO-EXTENSION NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  s_blart-low = 'YR'.
  APPEND s_blart.

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
  xblnr,
  budat,
  wrbtr
  FROM regup INTO TABLE @DATA(lt_regup)
    WHERE laufd IN @s_laufd
    AND  laufi IN @s_laufi
     AND lifnr IN @s_lifnr
     AND blart IN @s_blart
     AND xvorl EQ @space.
  IF sy-subrc EQ 0.
    SORT lt_regup BY laufd laufi.
    DATA(lt_regup_tmp) = lt_regup[].
    SORT lt_regup_tmp BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_regup_tmp COMPARING lifnr.
    IF lt_regup_tmp IS NOT INITIAL.
      SELECT lifnr, altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_1)
        FOR ALL ENTRIES IN @lt_regup_tmp
        WHERE lifnr = @lt_regup_tmp-lifnr.
    ENDIF.
    SELECT laufd,
    laufi,
    xvorl,
    zbukr,
    lifnr,
    kunnr,
    empfg,
    vblnr,
    rzawe FROM reguh INTO TABLE @DATA(lt_reguh)
      FOR ALL ENTRIES IN @lt_regup
        WHERE laufd =  @lt_regup-laufd
          AND laufi =  @lt_regup-laufi
          AND xvorl EQ @space.

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
    vblnr,
    zaldt,
    voidd   FROM payr INTO TABLE @DATA(lt_payr)
    FOR ALL ENTRIES IN @lt_regup
    WHERE laufd =  @lt_regup-laufd
      AND laufi =  @lt_regup-laufi
      AND lifnr = @lt_regup-lifnr.

    SELECT bukrs,
           belnr,
           gjahr,
           blart,
           xblnr,
           bktxt,
           stodt,
           xstov
       FROM bkpf INTO TABLE @DATA(lt_bkpf)
      FOR ALL ENTRIES IN @lt_regup
      WHERE bukrs =  @lt_regup-bukrs
      AND  belnr = @lt_regup-belnr
       AND gjahr = @lt_regup-gjahr.

    SELECT bukrs,
            belnr,
            gjahr,
            blart,
            xblnr,
            bktxt,
            stodt,
            xstov
        FROM bkpf INTO TABLE @DATA(lt_bkpf_zp)
       FOR ALL ENTRIES IN @lt_regup
       WHERE bukrs =  @lt_regup-bukrs
       AND  belnr = @lt_regup-vblnr
        AND gjahr = @lt_regup-gjahr
        AND blart = 'ZP'.

    LOOP AT lt_regup INTO DATA(ls_data).
      READ TABLE lt_lfb1_1 INTO DATA(ls_lfb1_1) WITH KEY lifnr = ls_data-lifnr.
      IF sy-subrc EQ 0.
        gs_data-lifnr = |{ ls_lfb1_1-altkn ALPHA = OUT }|.
        CONDENSE gs_data-lifnr.
      ELSE.
        gs_data-lifnr = |{ ls_data-lifnr ALPHA = OUT }|.
      ENDIF.
*      gs_data-lifnr = |{ ls_data-lifnr ALPHA = OUT }|.
      gs_data-laufi = ls_data-laufi.
      gs_data-wrbtr = ls_data-wrbtr.
      gs_data-budat = ls_data-budat.
      gs_data-edtn = ls_data-belnr.

      READ TABLE lt_bkpf_zp INTO DATA(ls_bkpfzp) WITH KEY bukrs = ls_data-bukrs
                                                     belnr = ls_data-vblnr
                                                     gjahr = ls_data-gjahr.
      IF sy-subrc EQ 0.
        gs_data-bktxt = ls_bkpfzp-bktxt.
      ENDIF.
      READ TABLE lt_bkpf INTO DATA(ls_bkpf) WITH KEY bukrs = ls_data-bukrs
                                                     belnr = ls_data-belnr
                                                     gjahr = ls_data-gjahr.
      IF sy-subrc EQ 0.
        gs_data-xblnr = ls_bkpf-xblnr.
        IF ls_bkpf-xstov = 'X'.
          gs_data-stodt = ls_bkpf-stodt.
        ENDIF.
      ENDIF.
      READ TABLE lt_reguh INTO DATA(ls_reguh) WITH KEY laufd = ls_data-laufd
                                                     laufi = ls_data-laufi
                                                     vblnr = ls_data-vblnr.
      IF sy-subrc EQ 0 AND ls_reguh-rzawe = 'C'.
        READ TABLE lt_payr INTO DATA(ls_payr) WITH KEY laufd = ls_data-laufd
                                                         laufi = ls_data-laufi
                                                         lifnr = ls_data-lifnr
                                                          vblnr = ls_data-vblnr.
        IF sy-subrc EQ 0.
          gs_data-chect = ls_payr-chect.
          gs_data-voidd = ls_payr-voidd.
          gs_data-zaldt = ls_payr-zaldt.
          IF  ls_payr-voidd IS INITIAL.  "ls_payr-zaldt IS NOT INITIAL AND
            gs_data-matchdoc_typ = 'PK'.
            CLEAR gs_data-voidd.
          ELSEIF ls_payr-voidd IS NOT INITIAL.
            gs_data-matchdoc_typ = 'PO'.
*            CLEAR gs_data-chect.
          ENDIF.
        ENDIF.
      ENDIF.
      gs_data-interface_name = 'INT0077'.
      gs_data-receiver_system = 'RAMP'.
      APPEND gs_data TO gt_data.
      ls_belnr-sign = 'I'.
      ls_belnr-option = 'EQ'.
      ls_belnr-low = ls_data-belnr.
      APPEND ls_belnr TO lr_belnr.
      CLEAR : gs_data, ls_belnr.
    ENDLOOP.
  ENDIF.
  IF s_laufi IS INITIAL.


    SELECT bukrs,
           belnr,
           gjahr,
           cpudt,
           budat,
           bldat,
           blart,
           stblg,
           xblnr,
           xreversed
        FROM bkpf INTO TABLE @DATA(lt_bkpf_yr)
       WHERE blart IN @s_blart
*     AND belnr NOT IN @lr_belnr
       AND cpudt IN @s_laufd.
    IF lt_bkpf_yr IS NOT INITIAL.
      SORT lt_bkpf_yr.
      SELECT bukrs,
            belnr,
          gjahr,
        lifnr,
            budat,
            bldat,
             xblnr ,
             wrbtr,
             xstov
        FROM bsik_view INTO TABLE @DATA(lt_bsik)
        FOR ALL ENTRIES IN @lt_bkpf_yr
        WHERE belnr = @lt_bkpf_yr-belnr
        AND bukrs = @lt_bkpf_yr-bukrs
        AND gjahr = @lt_bkpf_yr-gjahr.
      IF sy-subrc EQ 0.
        SORT lt_bsik BY bukrs belnr gjahr.
        DATA(lt_regup_tmp1) = lt_bsik[].
        SORT lt_regup_tmp1 BY lifnr.
        DELETE ADJACENT DUPLICATES FROM lt_regup_tmp1 COMPARING lifnr.
        IF lt_regup_tmp1 IS NOT INITIAL.
          SELECT lifnr, altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_2)
            FOR ALL ENTRIES IN @lt_regup_tmp1
            WHERE lifnr = @lt_regup_tmp1-lifnr.
        ENDIF.
      ENDIF.
      SELECT bukrs,
           belnr,
           gjahr,
          lifnr,
           budat,
           bldat,
            xblnr ,
            wrbtr,
            xstov
       FROM bsak_view INTO TABLE @DATA(lt_bsak)
       FOR ALL ENTRIES IN @lt_bkpf_yr
       WHERE belnr = @lt_bkpf_yr-belnr
       AND bukrs = @lt_bkpf_yr-bukrs
       AND gjahr = @lt_bkpf_yr-gjahr.
      IF sy-subrc EQ 0.
        SORT lt_bsak BY bukrs belnr gjahr.
        DATA(lt_regup_tmp2) = lt_bsak[].
        SORT lt_regup_tmp2 BY lifnr.
        DELETE ADJACENT DUPLICATES FROM lt_regup_tmp2 COMPARING lifnr.
        IF lt_regup_tmp2 IS NOT INITIAL.
          SELECT lifnr, altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_3)
            FOR ALL ENTRIES IN @lt_regup_tmp2
            WHERE lifnr = @lt_regup_tmp2-lifnr.
        ENDIF.
      ENDIF.
    ENDIF.
    IF lr_belnr IS NOT INITIAL.
      DELETE lt_bkpf_yr WHERE belnr IN lr_belnr.
      DELETE lt_bsik WHERE belnr IN lr_belnr.
    ENDIF.
    LOOP AT lt_bkpf_yr INTO DATA(ls_bkpf_yr)." WHERE belnr NOT IN lr_belnr.
      READ TABLE lt_bsik INTO DATA(ls_bsik) WITH KEY bukrs = ls_bkpf_yr-bukrs
                                                     belnr = ls_bkpf_yr-belnr
                                                     gjahr = ls_bkpf_yr-gjahr.
      IF sy-subrc EQ 0.
        READ TABLE lt_lfb1_2 INTO DATA(ls_bsik_2) WITH KEY lifnr = ls_bsik-lifnr.
        IF sy-subrc EQ 0.
          gs_data-lifnr = |{ ls_bsik_2-altkn ALPHA = OUT }|.
          CONDENSE gs_data-lifnr.
        ELSE.
          gs_data-lifnr = |{ ls_bsik-lifnr ALPHA = OUT }|.  .
        ENDIF.
*      gs_data-lifnr = |{ ls_bsik-lifnr ALPHA = OUT }|.
*      gs_data-laufi = ls_bsik-laufi.
        gs_data-wrbtr = ls_bsik-wrbtr.
        gs_data-budat = ls_bsik-bldat.
*      gs_data-edtn = ls_bsik-belnr.
        gs_data-xblnr = ls_bsik-xblnr.
*      IF ls_bsik-xstov = 'X'.
*      gs_data-voidd = ls_bsik-budat.
*      ENDIF.
        gs_data-interface_name = 'INT0077'.
        gs_data-receiver_system = 'RAMP'.
        CONDENSE : gs_data-lifnr, gs_data-wrbtr.
        APPEND gs_data TO gt_data.
        CLEAR gs_data.
      ELSEIF ls_bkpf_yr-xreversed = ' '.
*      gs_data-budat = ls_bkpf_yr-budat.
*      gs_data-stodt = ls_bkpf_yr-cpudt.
*      gs_data-xblnr = ls_bkpf_yr-xblnr.
        READ TABLE lt_bsak INTO DATA(ls_bsak) WITH KEY  bukrs = ls_bkpf_yr-bukrs
                                                        belnr = ls_bkpf_yr-belnr
                                                        gjahr = ls_bkpf_yr-gjahr.
        IF sy-subrc EQ 0.
*        gs_data-lifnr = |{ ls_bsak-lifnr ALPHA = OUT }|.
          READ TABLE lt_lfb1_3 INTO DATA(ls_bsik_3) WITH KEY lifnr = ls_bsak-lifnr.
          IF sy-subrc EQ 0.
            gs_data-lifnr = |{ ls_bsik_3-altkn ALPHA = OUT }|.
            CONDENSE gs_data-lifnr.
          ELSE.
            gs_data-lifnr = |{ ls_bsak-lifnr ALPHA = OUT }|.
          ENDIF.
          gs_data-wrbtr = ls_bsak-wrbtr.
          gs_data-budat = ls_bkpf_yr-budat.
          gs_data-stodt = ls_bkpf_yr-cpudt.
          gs_data-xblnr = ls_bkpf_yr-xblnr.
          gs_data-interface_name = 'INT0077'.
          gs_data-receiver_system = 'RAMP'.
          CONDENSE : gs_data-lifnr, gs_data-wrbtr.
          APPEND gs_data TO gt_data.
        ENDIF.
*      gs_data-interface_name = 'INT0077'.
*      gs_data-receiver_system = 'RAMP'.
*      CONDENSE : gs_data-lifnr, gs_data-wrbtr.
*      APPEND gs_data TO gt_data.
        CLEAR gs_data.
      ENDIF.
      CLEAR gs_data.
    ENDLOOP.
  ENDIF.
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

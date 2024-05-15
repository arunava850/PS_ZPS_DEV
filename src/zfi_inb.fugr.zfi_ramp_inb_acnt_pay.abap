FUNCTION zfi_ramp_inb_acnt_pay.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_INPUT) TYPE  ZFI_RAMP_INB_ACNT OPTIONAL
*"  EXPORTING
*"     VALUE(EV_ERROR) TYPE  FLAG
*"----------------------------------------------------------------------

  DATA : lv_capex TYPE c,
         lv_opex  TYPE c,
         lv_amnt  TYPE p DECIMALS 2,
         lv_prctr TYPE prctr,
         lv_hkont TYPE hkont.


  CLEAR : lv_capex, lv_opex.
  gs_data-budat = is_input-zbatch.
*gs_data-BUKRS
  CLEAR : lv_prctr, lv_hkont.
  lv_prctr = is_input-zco+0(5).
  lv_prctr = |{ lv_prctr ALPHA = IN }|.
  lv_hkont = is_input-zasset_co_obj.
  SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_data-bukrs WHERE prctr = lv_prctr.
  gs_data-ztext = is_input-zdescriptn.
*gs_data-HKONT =
  lv_hkont = |{ lv_hkont ALPHA = IN }|.
*    gs_data-anln1 = IS_INPUT-zsset_co_sub.
  gs_data-zuonr = is_input-zsset_co_sub.
*    gs_data-zuonr = IS_INPUT-zafe_no.
  gs_data-xblnr = is_input-zinvoice.
  DATA(lv_yy) = is_input-zinv_date+6(4).
  DATA(lv_dd) = is_input-zinv_date+3(2).
  DATA(lv_mm) = is_input-zinv_date+0(2).
  CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-bldat.
*    gs_data-bldat = IS_INPUT-zinv_date.
  CLEAR lv_amnt.
  REPLACE ',' IN is_input-zgross_amnt WITH ' '.
  CONDENSE is_input-zgross_amnt.
  lv_amnt =  is_input-zgross_amnt.
  SELECT  xbilk INTO TABLE @DATA(lt_xbilk) FROM ska1 WHERE ktopl = 'PSUS'
                                                          AND saknr = @lv_hkont.
  READ TABLE lt_xbilk INTO DATA(ls_dat1) WITH KEY xbilk = 'X'.
  IF sy-subrc EQ 0.
    gs_data-capex = 'X'.
*      IF lv_amnt GE p_thamnt.
*    gs_data-hkont = p_capxgl.
*    gs_data-zuonr = p_capxgl.
*      ELSE.
    gs_data-hkont = lv_hkont.
*      ENDIF.
  ELSE.
    gs_data-opex = 'X'.
*      IF lv_amnt GE p_thamnt.
*    gs_data-hkont = p_opxgl.
*    gs_data-zuonr = p_opxgl.
*      ELSE.
    gs_data-hkont = lv_hkont.
*      ENDIF.
  ENDIF.
*    ENDIF.
  gs_data-dmbtr = lv_amnt.
  gs_data-mwsts = is_input-ztax.
  gs_data-lifnr = is_input-zusr_ref.
*    gs_data-blart = 'YR'.
*    gs_data-bktxt = 'Ramp to S4 account payable data'.

  gs_data-prctr = lv_prctr.
  APPEND gs_data TO gt_data.
  CLEAR gs_data.



  gt_capex[] = gt_data[].
  DELETE gt_capex[] WHERE opex = 'X'.
  IF gt_capex IS NOT INITIAL.
    PERFORM process_capex.
  ENDIF.
  DATA(gt_ret2) = gt_bapiret2[].
  gt_opex[] = gt_data[].
  DELETE gt_opex[] WHERE capex = 'X'.
  IF gt_opex IS NOT INITIAL.
    PERFORM process_opex.
  ENDIF.
**  gt_bapiret2
*  LOOP AT gt_ret2 INTO DATA(ls_ret2).
*    APPEND ls_ret2 TO gt_bapiret2.
*  ENDLOOP.
  IF gt_ret2[] IS NOT INITIAL.
    ev_error = abap_true.
  ENDIF.



ENDFUNCTION.

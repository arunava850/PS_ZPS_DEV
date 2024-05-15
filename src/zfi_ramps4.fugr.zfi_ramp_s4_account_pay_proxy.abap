FUNCTION zfi_ramp_s4_account_pay_proxy.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ZET_RAMPACCPAY) TYPE  ZFITT_RAMP_ACC_PAY
*"----------------------------------------------------------------------

  DATA : gt_bapiret2 TYPE TABLE OF bapiret2.

  DATA(gr_process) = NEW zcl_fi_ramp_accnt_pay( ).

  IF zet_rampaccpay IS NOT INITIAL.

    ""BAPI_FIXEDASSET_CREATE1

    CALL METHOD gr_process->create_asset_master
      EXPORTING
        gt_data  = zet_rampaccpay
      IMPORTING
        bapiret2 = gt_bapiret2
        .


    CALL METHOD gr_process->post_document
      EXPORTING
        gt_data  = zet_rampaccpay
      IMPORTING
        bapiret2 = gt_bapiret2.



  ENDIF.



ENDFUNCTION.

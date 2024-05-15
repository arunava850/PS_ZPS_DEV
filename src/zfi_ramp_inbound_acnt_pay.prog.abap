*&---------------------------------------------------------------------*
*& Report ZFI_RAMP_INBOUND_ACNT_PAY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_ramp_inbound_acnt_pay.


INCLUDE  zfi_ramp_inbound_acnt_top.

INCLUDE  zfi_ramp_inbound_acnt_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM file_selection_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  PERFORM file_open_dir.

START-OF-SELECTION.
  IF p_rb1 = 'X'.
    PERFORM read_file_from_pc.
  ELSE.
    PERFORM read_file_from_al11.
  ENDIF.
  PERFORM process_file.
  gt_file_mail = gt_file.
*  delete gt_data[] INDEX 1.
*** Commented to create accounting document with both capex and opex entries
*  gt_capex[] = gt_data[].
*  DELETE gt_capex[] WHERE opex = 'X'.
*  IF gt_capex IS NOT INITIAL.
*    PERFORM process_capex.
*  ENDIF.
*  DATA(gt_ret2) = gt_bapiret2[].
*  gt_opex[] = gt_data[].
*  DELETE gt_opex[] WHERE capex = 'X'.
*  IF gt_opex IS NOT INITIAL.
*    PERFORM process_opex.
*  ENDIF.
if gt_data[] is not initial.
  perform process_data.
endif.
*  gt_bapiret2
*  LOOP AT gt_ret2 INTO DATA(ls_ret2).
*    APPEND ls_ret2 TO gt_bapiret2.
*  ENDLOOP.

  IF gt_file_mail IS NOT INITIAL.
    DATA(lr_mail) = NEW zcl_fi_ramp_accnt_pay( ).

    CALL METHOD lr_mail->send_mail
      EXPORTING
        gt_data     = gt_data
        gt_file     = gt_file_mail
        ev_dl       = p_dl
        ev_filetype = 'File'.
  ENDIF.
  IF gt_alv_output IS NOT INITIAL AND p_rb1 = 'X'.
    PERFORM display_alv.
  ENDIF.
  INCLUDE  zfi_ramp_inbound_acnt_f01.

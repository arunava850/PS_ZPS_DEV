*&-------------------------------------------------------------------*
*& Report ZFIAP_CONCUR_PAYMENT_CONF
*&-------------------------------------------------------------------*
*&
*&-------------------------------------------------------------------*
REPORT zfiap_concur_payment_conf.

*--------------------------------------------------------------------*
*& Includes
*--------------------------------------------------------------------*
INCLUDE ZFIAP_CONCUR_PAYMENT_CONF_top.
INCLUDE ZFIAP_CONCUR_PAYMENT_CONF_sel.
INCLUDE ZFIAP_CONCUR_PAYMENT_CONF_form.



*--------------------------------------------------------------------*
*& AT SELECTION-SCREEN.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  CONCATENATE'/interfaces/workday/INT0111/out/' 'workday_concur_'
                sy-datum+4(2) sy-datum+6(2) sy-datum+2(2) '.xlsx' INTO p_path.

AT SELECTION-SCREEN.

  PERFORM screen_validations.

  PERFORM fill_xref_data.

*--------------------------------------------------------------------*
*& START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM extract_data.           "Get accounting document data

END-OF-SELECTION.
*** Interface 34 outbound functionalities
  IF cb_alv EQ abap_true AND gt_final IS NOT INITIAL AND cb_int34 EQ abap_true.
    PERFORM display_alv.
  ENDIF.

  IF cb_prxy IS NOT INITIAL AND cb_int34 EQ abap_true AND gt_proxy  IS NOT INITIAL.
    PERFORM f_send_to_proxy.
  ENDIF.

*** Interface 111 outbound functionalities

  IF cb_alv EQ abap_true AND cb_it111 EQ abap_true AND gt_final_wd IS NOT INITIAL.
    PERFORM display_workday_alv.
  ENDIF.

  IF cb_mail IS NOT INITIAL AND cb_it111 EQ abap_true AND gt_final_wd IS NOT INITIAL.
    PERFORM f_send_email.
  ENDIF.

  IF cb_prxy IS NOT INITIAL AND cb_it111 EQ abap_true AND gt_mail_wd IS NOT INITIAL.
*    PERFORM f_send_to_proxy_workday.

    perform f_send_to_al11.
  ENDIF.

*&---------------------------------------------------------------------*
*& Report ZFIAP_UNCLAIMED_CHECKS
*&---------------------------------------------------------------------*
*& Unclaimed AP Checks Extract for TrackerPro - KDURAI - 16/08/2023
*&---------------------------------------------------------------------*
REPORT zfiap_unclaimed_checks.

*--------------------------------------------------------------------*
*& Includes
*--------------------------------------------------------------------*
 INCLUDE zfiap_unclaimed_checks_top.
 INCLUDE zfiap_unclaimed_checks_sel.
 INCLUDE zfiap_unclaimed_checks_form.

*--------------------------------------------------------------------*
*& INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

  PERFORM f_date_calculation.

*--------------------------------------------------------------------*
*& AT SELECTION-SCREEN ON VALUE-REQUEST
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM f_file_selection_f4.

*--------------------------------------------------------------------*
*& AT SELECTION-SCREEN.
*--------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF sy-batch IS NOT INITIAL
    AND s_laufi[] IS INITIAL.
    PERFORM f_date_calculation.
  ENDIF.

*--------------------------------------------------------------------*
*& START-OF-SELECTION.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_validations.

  PERFORM f_extract_data.

*--------------------------------------------------------------------*
*& END-OF-SELECTION.
*--------------------------------------------------------------------*
END-OF-SELECTION.

  IF cb_file IS NOT INITIAL.
    PERFORM f_download_file_to_pc.
  ENDIF.

  IF cb_prxy IS NOT INITIAL.
    PERFORM f_send_to_proxy.
  ENDIF.

  IF cb_mail IS NOT INITIAL.
    PERFORM f_send_email.
  ENDIF.

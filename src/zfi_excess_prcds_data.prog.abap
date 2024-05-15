*&---------------------------------------------------------------------*
*& Report ZFI_EXCEL_UPLOAD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


REPORT zfi_excess_prcds_data NO STANDARD PAGE HEADING.
* Include
*=======================================================================
INCLUDE zfi_excess_prcds_top.

*** --- value request for p_file
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

*** --- START-OF-SELECTION
START-OF-SELECTION.

  PERFORM read_data_frm_frontend.

  PERFORM update_data_db.

END-OF-SELECTION.

if gt_message[] is not INITIAL.
  PERFORM display_errors .
 ELSE.
   MESSAGE 'Successfully update' TYPE 'I'.
endif.

  INCLUDE zfi_excess_prcds_f01.

*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZFI_CREATE_REPETITIVE_CODES
* T-Code        : ZFI007
* Creation Date : 02/28/2024
* Jira #        : https://storage.atlassian.net/browse/SAP-1955
* DESCRIPTION   : ENH0016
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_create_repetitive_code
       NO STANDARD PAGE HEADING LINE-SIZE 255 MESSAGE-ID fibl_rpcode.

INCLUDE zfi_create_repetitive_code_top. " Top Declarations

INCLUDE zfi_create_repetitive_code_sel. " Selection-Screen Declarations

INCLUDE zfi_create_repetitive_code_f01. " Subroutines Declarations

*&---------------------------------------------------------------------*
*& Selection-Screen
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath.

  IF p_ot EQ abap_true.
    CALL METHOD cl_gui_frontend_services=>file_open_dialog
      EXPORTING
        window_title            = 'Select File' ##NO_TEXT
      CHANGING
        file_table              = gt_file
        rc                      = gv_rc
      EXCEPTIONS
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        OTHERS                  = 5.
    IF sy-subrc <> 0.
      MESSAGE TEXT-004 TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ELSE.
      READ TABLE gt_file INTO gs_file INDEX 1.
      p_fpath = gs_file-filename.
    ENDIF.
  ENDIF.

START-OF-SELECTION.

  IF p_ot EQ abap_true.
    IF rng_grp IS NOT INITIAL
    OR rng_buk IS NOT INITIAL
    OR rng_hbk IS NOT INITIAL
    OR p_fy IS NOT INITIAL.
      MESSAGE 'Do not enter FRFT_B input parameters when OT81 RB is choosed' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    IF p_fpath IS INITIAL.
      MESSAGE 'Please enter filepath' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    PERFORM read_excel_data_fg.
    PERFORM process_file_for_data.
    PERFORM process_data_to_bdc.
  ENDIF.

  IF p_fr EQ abap_true.
    IF p_fpath IS NOT INITIAL.
      MESSAGE 'Do not enter filepath when FRFT_B RB is choosed' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    IF rng_grp IS INITIAL
      OR p_fy IS INITIAL.
      MESSAGE 'Please enter all input parameters' TYPE c_s DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    PERFORM get_parameter_100.
    PERFORM read_repetitives.
    PERFORM read_payrq.
    PERFORM create_payrq.
  ENDIF.

END-OF-SELECTION.
  IF p_ot EQ abap_true.
    IF gt_output IS NOT INITIAL.
      PERFORM display_rpt.
      MESSAGE 'Process Complete' TYPE c_s.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

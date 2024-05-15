*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZFI_COST_ALLOCATION_WRAPPER
* T-Code        : ZFI002
* Creation Date : 05/13/2024
* Jira #        : https://storage.atlassian.net/browse/SAPA-396
* DESCRIPTION   : ENH0011 Cost Allocation Wrapper main prg is
*                 ZFI_COST_ALLOCATION
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_cost_allocation_wrapper.

INCLUDE zfi_cost_allo_wrapper_top. " Top Declarations

INCLUDE zfi_cost_allo_wrapper_sel. " Selection-Screen Declarations

INCLUDE zfi_cost_allo_wrapper_f01. " Subroutines Declarations

*------------------------------------------------------------------------*
* AT SELECTION-SCREEN
*------------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpath.

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

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bpath.
  PERFORM file_open_dir.

AT SELECTION-SCREEN OUTPUT.
  IF p_fg = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'P_EMAIL'
        OR screen-name = '%_P_EMAIL_%_APP_%-OPTI_PUSH'
        OR screen-name = '%_P_EMAIL_%_APP_%-TO_TEXT'
        OR screen-name = '%_P_EMAIL_%_APP_%-VALU_PUSH'
        OR screen-name = 'P_EMAIL-LOW'
        OR screen-name = 'P_EMAIL-HIGH'
        OR screen-name = '%_P_EMAIL_%_APP_%-TEXT'.
        screen-active = 0.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*------------------------------------------------------------------------*
* START-OF-SELECTION.
*------------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM filepath_validation.

  IF p_bg EQ abap_true.
    PERFORM read_excel_data_bg.
    PERFORM process_file_for_data.
    PERFORM schedule_jobs.
    PERFORM archive_file.
  ENDIF.

  IF p_fg EQ abap_true.
    PERFORM read_excel_data_fg.
    PERFORM fetch_comp_codes.
    PERFORM process_file_for_data.
    PERFORM validate_receiver_%_data.
    PERFORM valid_ccgrp_cc_alloc_fac_data.
    PERFORM fetch_redirect_cost_centers.
    PERFORM fetch_acdoca_records.
    PERFORM process_receiver_percentage.
    PERFORM process_receiver_units USING TEXT-006.
    PERFORM process_receiver_units USING TEXT-007.
    PERFORM process_websites.
    PERFORM process_combined_units.
    PERFORM populate_cross_company_docs.
  ENDIF.
*------------------------------------------------------------------------*
* END-OF-SELECTION.
*------------------------------------------------------------------------*
END-OF-SELECTION.
  IF p_fg EQ abap_true.
    IF gt_output IS NOT INITIAL.
      PERFORM display_output.
    ELSE.
      MESSAGE TEXT-010 TYPE c_s DISPLAY LIKE c_e.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
    MESSAGE 'File process is Complete' TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

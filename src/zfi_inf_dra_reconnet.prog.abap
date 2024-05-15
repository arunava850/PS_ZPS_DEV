*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZFI_INF_DRA_RECONNET
* T-Code        : ZFI001
* Creation Date : Nov 1st 2023
* Jira #        : https://storage.atlassian.net/browse/SAP-348
* DESCRIPTION   : INT0038 - Maser data including DRA to ReconNET. Serial
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_inf_dra_reconnet.

INCLUDE zfi_inf_dra_reconnet_top. " Top Declarations

INCLUDE zfi_inf_dra_reconnet_sel. " Selection-Screen Declarations

INCLUDE zfi_inf_dra_reconnet_f01. " Subroutines Declarations

*------------------------------------------------------------------------*
* START-OF-SELECTION.
*------------------------------------------------------------------------*
START-OF-SELECTION.

  IF chk_cpi EQ abap_false
    AND chk_disp EQ abap_false.
    MESSAGE TEXT-003 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

  PERFORM fetch_data.

  IF gt_data IS INITIAL.
    MESSAGE TEXT-004 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

*------------------------------------------------------------------------*
* END-OF-SELECTION.
*------------------------------------------------------------------------*
END-OF-SELECTION.

  IF chk_cpi EQ abap_true.
    PERFORM send_data_cpi.
  ENDIF.

  IF chk_disp EQ abap_true.
    PERFORM display_rpt.
  ENDIF.

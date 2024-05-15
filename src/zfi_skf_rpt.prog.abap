*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZFI_SKF_RPT
* T-Code        : ZFI008
* Creation Date : 04/11/2024
* Jira #        : https://storage.atlassian.net/browse/SAP-508
* DESCRIPTION   : ENH0011 Cost Allocation SKF Report
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_skf_rpt.

INCLUDE zfi_skf_rpt_top. " Top Declarations

INCLUDE zfi_skf_rpt_sel. " Selection-Screen Declarations

INCLUDE zfi_skf_rpt_f01. " Subroutines Declarations

*------------------------------------------------------------------------*
* START-OF-SELECTION.
*------------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM fetch_data.

*------------------------------------------------------------------------*
* END-OF-SELECTION.
*------------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM display_rpt.

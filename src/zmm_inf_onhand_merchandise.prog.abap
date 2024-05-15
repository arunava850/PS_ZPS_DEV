*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZMM_INF_ONHAND_MERCHANDISE
* T-Code        : ZMM001
* Creation Date : Oct 23rd 2023
* Jira #        : https://storage.atlassian.net/browse/SAP-502
* DESCRIPTION   : INT0074 MerchandiseOnHand (on hand qty & po) Interface
*                 to EDW
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zmm_inf_onhand_merchandise.

INCLUDE zmm_inf_onhand_merchandise_top. " Top Declarations

INCLUDE zmm_inf_onhand_merchandise_sel. " Selection-Screen Declarations

INCLUDE zmm_inf_onhand_merchandise_f01. " Subroutines Declarations

*------------------------------------------------------------------------*
* INITIALIZATION
*------------------------------------------------------------------------*
INITIALIZATION.

  PERFORM initialize .

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

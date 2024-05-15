*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Report ID     : ZFI_PC_HIER_GRP_DATA
* T-Code        : ZFI006
* Creation Date : Nov 30th 2023
* Jira #        : https://storage.atlassian.net/browse/SAP-1412
*                 https://storage.atlassian.net/browse/SAP-1413
* DESCRIPTION   : PC and CC Standard and Alternate Groups Data
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_pc_hier_grp_data.

INCLUDE zfi_pc_hier_grp_data_top. " Top Declarations

INCLUDE zfi_pc_hier_grp_data_sel. " Selection-Screen Declarations

INCLUDE zfi_pc_hier_grp_data_f01. " Subroutines Declarations

*------------------------------------------------------------------------*
* At-Selection
*------------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  IF rb_pc EQ abap_true.
    p_class = c_pc.
  ENDIF.
  IF rb_cc EQ abap_true.
    p_class = c_cc.
  ENDIF.
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

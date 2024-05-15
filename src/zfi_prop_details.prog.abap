*------------------------------------------------------------------------*
* Developer ID  : AMONDAL
* Developer Name: Arunava Mondal
* Report ID     : ZFI_PROP_DETAILS
* T-Code        : ZFIPROP
* Creation Date : Mar 30th 2024
* Jira #        : https://storage.atlassian.net/browse/SAP-
* DESCRIPTION   : Property Details Report
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
REPORT zfi_prop_details.

INCLUDE ZFI_PROP_DETAILS_TOP.   " Top Declarations

INCLUDE ZFI_PROP_DETAILS_SEL.   " Selection-Screen Declarations

INCLUDE ZFI_PROP_DETAILS_F01.   " Subroutines Declarations


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
*  IF chk_cpi EQ abap_false
*    AND chk_disp EQ abap_false.
*    MESSAGE TEXT-003 TYPE c_s DISPLAY LIKE c_e.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

  PERFORM fetch_data.

  IF gt_rep_output IS INITIAL.
    MESSAGE TEXT-004 TYPE c_s DISPLAY LIKE c_e.
    LEAVE LIST-PROCESSING.
  ENDIF.

*------------------------------------------------------------------------*
* END-OF-SELECTION.
*------------------------------------------------------------------------*
END-OF-SELECTION.

*  IF chk_cpi EQ abap_true.
*    PERFORM send_data_cpi.
*  ENDIF.

  IF chk_disp EQ abap_true.
    PERFORM display_rpt.
  ENDIF.

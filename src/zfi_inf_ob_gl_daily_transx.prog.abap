*------------------------------------------------------------------------*
* Report     : ZFI_INF_OB_GL_DAILY_TRANSX
* Jira #     : https://storage.atlassian.net/browse/SAP-501
* DEVELOPER  : RajSekhar Mulpuri
* DESCRIPTION: INT0073-Daily Transaction Data for Property Finance Details
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*

REPORT zfi_inf_ob_gl_daily_transx.


INCLUDE zfi_gl_daily_transx_top.

INCLUDE zfi_gl_daily_transx_sel.

INCLUDE zfi_gl_daily_transx_f01.

INITIALIZATION.
  PERFORM initialize .

START-OF-SELECTION.

  PERFORM get_data.

  PERFORM send_data.

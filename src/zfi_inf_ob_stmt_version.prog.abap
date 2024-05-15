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

REPORT zfi_inf_ob_stmt_version.


INCLUDE zfi_gl_stmt_version_top.

INCLUDE zfi_gl_stmt_version_sel.

INCLUDE zfi_gl_stmt_version_f01.

START-OF-SELECTION.

  PERFORM get_data.

  PERFORM send_data.

*&---------------------------------------------------------------------*
*& Report ZFI_EBUILDER_S4_ACCNT_PAY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_ebuilder_s4_accnt_pay.

INCLUDE zfi_ebuilder_s4_accnt_top.

INCLUDE zfi_ebuilder_s4_accnt_sel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM file_selection_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  PERFORM file_open_dir.

START-OF-SELECTION.
  IF p_rb1 = 'X'.
    PERFORM read_file_from_pc.
  ELSE.
    PERFORM read_file_from_al11.
  ENDIF.
  SELECT * FROM zfi_ebld_gl_tab INTO TABLE gt_lookup.
  DELETE gt_filefull INDEX 1.
  PERFORM process_file.
  DATA(lr_prc) = NEW zcl_fi_ebuildr_s4_accpay( ).

  CALL METHOD lr_prc->post_document
    EXPORTING
      et_data  = gt_data
      ev_anlkl = p_ascl
      et_file  = gt_filefull "gt_file
      ev_dl    = p_dl
    IMPORTING
      it_ret2  = gt_ret2.

  IF gt_ret2 IS NOT INITIAL AND p_rb1 = 'X'.
    PERFORM display_alv.
  ENDIF.

  INCLUDE zfi_ebuilder_s4_accnt_f01.

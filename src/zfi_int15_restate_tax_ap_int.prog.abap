*&---------------------------------------------------------------------*
*& Report ZFI_INT15_RESTATE_TAX_AP_INT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_int15_restate_tax_ap_int.

INCLUDE zfi_int15_restate_tax_ap_top.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : p_file TYPE rlgrap-filename,
               p_dir  TYPE rlgrap-filename,
               p_dl   TYPE soobjinfi1-obj_name,
*               p_gl   TYPE saknr,
               p_doc  TYPE blart.

  PARAMETERS : p_rb1 RADIOBUTTON GROUP rg1,
               p_rb2 RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

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
*  PERFORM process_file.
  IF gt_file IS NOT INITIAL.
    DATA(lc_proc) = NEW zcl_int15_restate_tax_ap_int( ).
    CALL METHOD lc_proc->post_document
      EXPORTING
        gt_data   = gt_data
        gt_file   = gt_file
        gv_blart  = p_doc
        gv_dl     = p_dl
      IMPORTING
        gt_return = DATA(lt_return).
  ENDIF.
  INCLUDE zfi_int15_restate_tax_ap_f01.

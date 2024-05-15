*&---------------------------------------------------------------------*
*& Report ZFI_WC_S4_TENANT_REFUND_INT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_wc_s4_tenant_refund_int.

INCLUDE zfi_wc_s4_tenant_refund_top.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file TYPE rlgrap-filename,
               p_dir  TYPE rlgrap-filename,
               p_dl   TYPE soobjinfi1-obj_name.

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
  PERFORM process_file.
  IF gt_data IS NOT INITIAL.
    DATA(lr_prc) = NEW zcl_wc_s4_tenant_refund_int( ).

    CALL METHOD lr_prc->post_document
      EXPORTING
        gt_data = gt_data
        ev_dl   = p_dl
      IMPORTING
        it_ret2 = gt_ret2.
  ENDIF.
  IF p_rb1 = 'X'.
PERFORM display_alv.
  ENDIF.
  INCLUDE zfi_wc_s4_tenant_refund_f01.

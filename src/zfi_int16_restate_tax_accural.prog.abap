*&---------------------------------------------------------------------*
*& Report ZFI_INT16_RESTATE_TAX_ACCURAL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_int16_restate_tax_accural.

INCLUDE zfi_int16_restate_tax_top.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  PARAMETERS : p_file TYPE rlgrap-filename,
               p_dir  TYPE rlgrap-filename,
               p_dl   TYPE soobjinfi1-obj_name,
               p_gl   TYPE saknr,
               p_doc  TYPE blart.

  PARAMETERS : p_rb1 RADIOBUTTON GROUP rg1,
               p_rb2 RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM file_selection_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  PERFORM file_open_dir.


START-OF-SELECTION.
  IF p_rb1 = abap_true.
    IF p_file EQ abap_false.
      MESSAGE 'Please enter filepath' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
    CALL FUNCTION 'SO_SPLIT_FILE_AND_PATH'
      EXPORTING
        full_name     = p_file
      IMPORTING
        stripped_name = gv_filename
        file_path     = gv_filepath.
    IF sy-subrc EQ 0.
      CONCATENATE gv_filename+6(4) gv_filename+0(2) gv_filename+3(2) INTO gv_budat.
    ENDIF.
  ELSE.
    IF p_dir EQ abap_false.
      MESSAGE 'Please enter filepath' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
  IF p_rb1 = abap_true.
    PERFORM read_file_from_pc.
  ELSE.
    PERFORM read_file_from_al11.
  ENDIF.
  IF gt_file IS NOT INITIAL and p_rb1 = abap_true.  ""SCHITTADI
    DATA(lr_proc) = NEW zcl_int16_restate_tax_accural( ).

    CALL METHOD lr_proc->post_document
      EXPORTING
        gt_file   = gt_file
        gv_blart  = p_doc
        gv_dl     = p_dl
        gv_taxgl  = p_gl
        gv_budat  = gv_budat
      IMPORTING
        gt_return = DATA(gt_return).
    MESSAGE 'Process is complete' TYPE 'S'.
  ENDIF.

  INCLUDE zfi_int16_restate_tax_f01.

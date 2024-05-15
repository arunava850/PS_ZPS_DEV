*&---------------------------------------------------------------------*
*& Report ZFI_REV_POS_STORAGE_RETAIL_INT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_rev_pos_storage_retail_int.

TABLES : zfi_ar_rev_post, adr6.
INCLUDE zfi_rev_pos_storage_retail_top.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file TYPE rlgrap-filename,
               p_dir  TYPE rlgrap-filename.

  SELECT-OPTIONS : s_sitno FOR zfi_ar_rev_post-zsiteno.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS : p_rb1 RADIOBUTTON GROUP rg1 USER-COMMAND cm1.
    SELECTION-SCREEN COMMENT 35(15) TEXT-rb1.
    PARAMETERS:  p_rb2 RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 55(20) TEXT-rb2.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 33.
    PARAMETERS : r1 RADIOBUTTON GROUP rg2 USER-COMMAND cm2.
    SELECTION-SCREEN COMMENT 35(15) TEXT-r01.
    PARAMETERS : r2 RADIOBUTTON GROUP rg2.
    SELECTION-SCREEN COMMENT 55(20) TEXT-r02.
  SELECTION-SCREEN END OF LINE.

*  SELECT-OPTIONS : s_mail FOR adr6-smtp_addr NO INTERVALS .
PARAMETERS : p_dl   TYPE soobjinfi1-obj_name.
*  PARAMETERS : c_rp AS CHECKBOX USER-COMMAND cm1.

*PARAMETERS : p_ins AS CHECKBOX,
*             p_rpc AS CHECKBOX.

*SELECTION-SCREEN END OF BLOCK b1.
*
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.

  PARAMETERS : p_r RADIOBUTTON GROUP rg2,
               p_e RADIOBUTTON GROUP rg2,
               p_d RADIOBUTTON GROUP rg2.

  PARAMETERS : p_er AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
* IF p_rb1 = 'X'.
  LOOP AT SCREEN.
    IF screen-name = 'P_DIR'.
      screen-input = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
*  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  IF p_rb1 = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'P_DIR'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF p_rb2 = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'P_FILE'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF p_r = 'X' OR p_e = 'X' OR p_d = 'X'.
    LOOP AT SCREEN.
      IF screen-name = 'P_FILE'.
        screen-input = 0.
      ELSEIF screen-name = 'P_DIR'.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

IF p_e = 'X'.
LOOP AT SCREEN.
IF screen-name = 'P_ER'.
 screen-input = 0.
ENDIF.
MODIFY SCREEN.
ENDLOOP.
ENDIF.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM file_selection_f4.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dir.
  PERFORM file_open_dir.


START-OF-SELECTION.
*  IF c_rp NE 'X'.
  IF r1 = 'X' OR r2 = 'X'.
    IF p_rb1 = 'X'.
      PERFORM read_file_from_pc.
    ELSE.
      PERFORM read_file_from_al11.
    ENDIF.
  ENDIF.
  IF r1 = 'X'.
    DELETE gt_file INDEX 1.
    PERFORM display_raw_data.
  ELSEIF r2 = 'X'.

    REFRESH lt_update.
    IF p_rb1 = 'X'.
    DELETE gt_file INDEX 1.
    REFRESH : gr_site.
    PERFORM process_file.
    ENDIF.
*    ENDIF.
*  ELSE.
*    CLEAR r1.
*    r2 = 'X'.
*    r1 = 'X'.
*  ENDIF.
*  IF r2 = 'X'.
*
*  ENDIF.
*  IF NOT lt_update IS INITIAL.
*    SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans
*      FOR ALL ENTRIES IN lt_update
*      WHERE zsiteno = lt_update-zsiteno
*      AND belnr = space
*      AND zsiteno IN s_sitno.
*  ELSE.
    SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans WHERE zsiteno IN gr_site
                                                          and belnr EQ space.
*
*  ENDIF.
    DATA(lr_prcs) = NEW zcl_fi_revpos_ret_sto_ins( ).
    CALL METHOD lr_prcs->post_document
      EXPORTING
        et_data = gt_trans
        gt_file = gt_file
        ev_dl = p_dl
      IMPORTING
        it_ret2 = gt_return.
    PERFORM display_after_process.
*  ENDIF.
  ELSEIF p_r = 'X'.
    IF s_sitno IS NOT INITIAL.
      IF p_er = 'X'.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans WHERE zsiteno IN s_sitno AND belnr NE space.
      ELSE.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans WHERE zsiteno IN s_sitno.
      ENDIF.
    ELSE.
      IF p_er = 'X'.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans WHERE belnr NE space." WHERE zsiteno IN s_sitno.
      ELSE.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans.
      ENDIF.
    ENDIF.
    SORT gt_trans BY zsiteno zsno.
    PERFORM display_alv.
  ELSEIF p_d = 'X'.
    IF p_er = 'X'.
      IF s_sitno IS NOT INITIAL..
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans  WHERE belnr NE space AND  zsiteno IN s_sitno.
      ELSE.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans  WHERE belnr NE space.
      ENDIF.
    ELSE.
      IF s_sitno IS NOT INITIAL.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans WHERE zsiteno IN s_sitno.
      ELSE.
        SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans." WHERE zsiteno IN s_sitno.
      ENDIF.
    ENDIF.
    SORT gt_trans BY zsiteno zsno.
    PERFORM display_alv_delete.
  ELSEIF p_e = 'X'.
    IF s_sitno IS NOT INITIAL.
      SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans  WHERE belnr = space AND zsiteno IN s_sitno.
    ELSE.
      SELECT * FROM zfi_ar_rev_post  INTO  TABLE gt_trans  WHERE belnr = space." and zsiteno IN s_sitno.
    ENDIF.

    SORT gt_trans BY zsiteno zsno.
    PERFORM display_alv_error_process.
  ENDIF.
  INCLUDE zfi_rev_pos_storage_retail_F01.

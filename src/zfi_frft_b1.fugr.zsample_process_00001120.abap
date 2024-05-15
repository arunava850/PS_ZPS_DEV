FUNCTION zsample_process_00001120.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BKDF) TYPE  BKDF OPTIONAL
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_BKPFSUB STRUCTURE  BKPF_SUBST
*"      T_BSEGSUB STRUCTURE  BSEG_SUBST
*"      T_BSEC STRUCTURE  BSEC OPTIONAL
*"  CHANGING
*"     REFERENCE(I_BKDFSUB) TYPE  BKDF_SUBST OPTIONAL
*"--------------------------------------------------------------------
  DATA: lv_prctr TYPE cepc-prctr.

  LOOP AT t_bsegsub ASSIGNING FIELD-SYMBOL(<fs_bseg>).
    SPLIT <fs_bseg>-zuonr AT '_' INTO DATA(lv_data1) lv_prctr.
    IF <fs_bseg>-zuonr EQ <fs_bseg>-sgtxt.
      lv_prctr = |{ lv_prctr ALPHA = IN }|.
      SELECT SINGLE prctr
        FROM cepc
        INTO @DATA(lv_prt)
       WHERE prctr EQ @lv_prctr.
      IF sy-subrc EQ 0.
        DATA(lv_flag) = abap_true.
        EXIT.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_flag EQ abap_true.
    LOOP AT t_bsegsub ASSIGNING FIELD-SYMBOL(<fs_bseg_chg>).
      <fs_bseg_chg>-zuonr = lv_prctr.
      <fs_bseg_chg>-sgtxt = lv_prctr.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.

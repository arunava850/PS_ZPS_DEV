"Name: \PR:SAPLPC23\EX:MASTERIDOC_CREATE_PRCMAS_G2\EI
ENHANCEMENT 0 ZFI_ENH_PRCMAS_OB_IDOC.
  DATA:lt_ccpc    TYPE STANDARD TABLE OF zfi_pccenters,
       lv_ccpc    TYPE char10,
       ls_e1kepcm TYPE e1kepcm.
  LOOP AT t_idoc_data ASSIGNING FIELD-SYMBOL(<lfs_idoc_data>) WHERE segnam = 'E1KEPCM'.
    ls_e1kepcm = <lfs_idoc_data>-sdata.
    lv_ccpc = ls_e1kepcm-prctr.
    CLEAR:lt_ccpc[].
    CALL FUNCTION 'ZCA_OUTPUT_PC'
      EXPORTING
        iv_pcenters = lv_ccpc
        iv_pc_flag  = 'P'
      TABLES
        et_output   = lt_ccpc.
    READ TABLE lt_ccpc INTO DATA(ls_ccpc) INDEX 1.
    IF sy-subrc IS INITIAL.
      ls_e1kepcm-prctr = ls_ccpc-numbr.
      CLEAR:ls_ccpc.
    ELSE.
      ls_e1kepcm-prctr = lv_ccpc.
    ENDIF.
    <lfs_idoc_data>-sdata = ls_e1kepcm.
  ENDLOOP.
ENDENHANCEMENT.

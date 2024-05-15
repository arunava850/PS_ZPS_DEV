"Name: \PR:SAPLKS01\EX:MASTERIDOC_CREATE_COSMAS_G2\EI
ENHANCEMENT 0 ZFI_ENH_COSMAS_OB_IDOC.
  DATA:lt_ccpc    TYPE STANDARD TABLE OF zfi_pccenters,
       lv_ccpc    TYPE char10,
       ls_e1csksm TYPE e1csksm.
  LOOP AT t_idoc_data ASSIGNING FIELD-SYMBOL(<lfs_idoc_data>) WHERE segnam = 'E1CSKSM'.
    ls_e1csksm = <lfs_idoc_data>-sdata.
    lv_ccpc = ls_e1csksm-kostl.
    CLEAR:lt_ccpc[].
    CALL FUNCTION 'ZCA_OUTPUT_PC'
      EXPORTING
        iv_pcenters = lv_ccpc
        iv_pc_flag  = 'C'
      TABLES
        et_output   = lt_ccpc.
    READ TABLE lt_ccpc INTO DATA(ls_ccpc) INDEX 1.
    IF sy-subrc IS INITIAL.
      ls_e1csksm-kostl = ls_ccpc-numbr.
      CLEAR:ls_ccpc.
    ELSE.
      ls_e1csksm-kostl = lv_ccpc.
    ENDIF.
    <lfs_idoc_data>-sdata = ls_e1csksm.
  ENDLOOP.
ENDENHANCEMENT.

FUNCTION zdmc_mig_bp_cvi_create.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DATA) TYPE  MIG_CVIS_EI_EXTERN_T
*"     REFERENCE(IT_EXT_BP_CEN) TYPE  MIG_CMDS_EI_BP_CEN_EXT_T OPTIONAL
*"     REFERENCE(IT_EXT_CUST_CEN) TYPE  MIG_CMDS_EI_CUST_CEN_EXT_T
*"       OPTIONAL
*"     REFERENCE(IT_EXT_VEND_CEN) TYPE  MIG_CMDS_EI_VEND_CEN_EXT_T
*"       OPTIONAL
*"     REFERENCE(IV_SUPPRESS_TAXJUR_CHECK) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IV_PROCESSING_MODE) TYPE
*"        CMD_BP_MIGRATE_PROCESSING_TYPE OPTIONAL
*"     REFERENCE(IV_TEST_RUN) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IT_EXT_CUST_CMP_COD) TYPE
*"        MIG_CMDS_EI_CUST_CMP_COD_EXT_T OPTIONAL
*"     REFERENCE(IT_EXT_CUST_SALES) TYPE  MIG_CMDS_EI_CUST_SALES_EXT_T
*"       OPTIONAL
*"     REFERENCE(IT_EXT_SUPP_CMP_COD) TYPE
*"        MIG_CMDS_EI_SUPP_CMP_COD_EXT_T OPTIONAL
*"     REFERENCE(IT_EXT_SUPP_PUR) TYPE  MIG_CMDS_EI_SUPP_PUR_EXT_T
*"       OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BAPIRETM
*"     REFERENCE(ET_RETURN_NEW) TYPE  FS4MIG_T_BAPIRET2
*"     REFERENCE(ET_KEY_MAPPING) TYPE  MIG_CVIS_KEY_MAPPING_BP_T
*"----------------------------------------------------------------------

  DATA : lt_data TYPE  mig_cvis_ei_extern_t.
  lt_data[] =  It_data[] .

  SELECT * FROM t001 INTO TABLE @DATA(lt_t001) WHERE bukrs NE '1000'
                                                 AND ktopl = 'PSUS'.

  LOOP AT Lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

    READ TABLE <fs_data>-companyvnd ASSIGNING FIELD-SYMBOL(<fs_bukrs>) INDEX 1.
    IF sy-subrc = 0 .
      LOOP AT lt_t001 ASSIGNING FIELD-SYMBOL(<fs_t001>) WHERE bukrs NE <fs_bukrs>-bUKRSKEY.
        APPEND INITIAL LINE TO <fs_data>-companyvnd ASSIGNING FIELD-SYMBOL(<fs_new>).
        <fs_new> = <fs_bukrs>.
        <fs_new>-bUKRSKEY = <fs_t001>-bukrs.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


  CALL FUNCTION 'CMD_MIG_BP_CVI_CREATE'
    EXPORTING
      it_data                  = Lt_data
      it_ext_bp_cen            = it_ext_bp_cen
      it_ext_cust_cen          = it_ext_cust_cen
      it_ext_vend_cen          = it_ext_vend_cen
      iv_suppress_taxjur_check = iv_suppress_taxjur_check
      iv_processing_mode       = iv_processing_mode
      iv_test_run              = iv_test_run
      it_ext_cust_cmp_cod      = it_ext_cust_cmp_cod
      it_ext_cust_sales        = it_ext_cust_sales
      it_ext_supp_cmp_cod      = it_ext_supp_cmp_cod
      it_ext_supp_pur          = It_ext_supp_pur
    IMPORTING
      et_return                = et_return
      et_return_new            = et_return_new
      et_key_mapping           = et_key_mapping.


ENDFUNCTION.

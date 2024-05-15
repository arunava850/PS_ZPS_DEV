class ZCL_ZFI_WC_TENANT_RFND_PROXY definition
  public
  create public .

public section.

  interfaces ZII_ZFI_WC_TENANT_RFND_PROXY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_WC_TENANT_RFND_PROXY IMPLEMENTATION.


  METHOD zii_zfi_wc_tenant_rfnd_proxy~post_doc.
*** **** INSERT IMPLEMENTATION HERE **** ***

    TYPES : BEGIN OF ty_file,
              ztran_id(16)         TYPE c,
              tot_refund(17)      TYPE c,
              zsiteno(10)         TYPE c,
*          zcsrtyp(3)          TYPE c,
              zcontactid(9)       TYPE c,
*          zbpmstrwckey(20)    TYPE c,
              zsuppl_no(10)       TYPE c,
              zlob(1)             TYPE c,
              refnd_line_amnt(17) TYPE c,
              custmr_unt(25)      TYPE c,
              date(20)            TYPE c,
              refnd_typ(30)       TYPE c,
              wc_code(10)         TYPE c,
            END OF ty_file.

    DATA : gt_file TYPE TABLE OF ty_file,
           gs_file TYPE ty_file,
           gt_data TYPE zfit_wc_s4_tenant_refund_int,
           gs_data TYPE zfis_wc_s4_tenant_refund_int,
           gt_ret2 TYPE bapiret2_t.
    DATA : lv_prctr TYPE prctr,
           lv_dl    TYPE soobjinfi1-obj_name.
    ""Begin of INT0013 development
    DATA : gs_int13 TYPE zfiap_ep_data, " zfi_wcs4_tenantr,
           gt_int13 TYPE TABLE OF zfiap_ep_data. " zfi_wcs4_tenantr.
    ""End of INT0013 development
    LOOP AT input-zfi_wc_tenant_rfnd_mt-zdata INTO DATA(ls_data).
      gs_file = CORRESPONDING #( ls_data ).
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.
    IF gt_file IS NOT INITIAL.
*      DELETE gt_file WHERE refnd_typ = 'DTM Refund'.
      LOOP AT gt_file INTO gs_file.
        CLEAR gs_data.
        gs_data-xblnr = gs_file-ztran_id.
*    gs_data-sortl = gs_file-zcsrtyp.
        gs_data-cr_amnt = gs_file-tot_refund.
*    gs_data-prctr = gs_file-zsiteno.
        gs_data-zsiteno = gs_file-zsiteno.
        CLEAR lv_prctr.
        lv_prctr = gs_file-zsiteno.
        gs_data-prctr = lv_prctr = |{ lv_prctr ALPHA = IN }|.
        gs_data-zcontactid = gs_file-zcontactid.
        SELECT SINGLE * FROM cepc_bukrs INTO @DATA(ls_cepc_bukrs)   WHERE prctr = @lv_prctr.
        IF sy-subrc EQ 0.
          gs_data-bukrs = ls_cepc_bukrs-bukrs.
        ENDIF.
        gs_data-lifnr = gs_file-zsuppl_no.
        gs_data-dr_amnt = gs_file-refnd_line_amnt.
        gs_data-zuonr = gs_file-custmr_unt.
*        DATA(lv_mm) = gs_file-date+0(2).
*        DATA(lv_dd) = gs_file-date+3(2).
*        DATA(lv_yy) = gs_file-date+6(4).
*        CONCATENATE lv_yy lv_mm lv_dd INTO gs_data-bldat.
        gs_data-bldat = gs_file-date.
        gs_data-bktxt = gs_file-refnd_typ.
        SELECT SINGLE hkont FROM zfi_aai_gl_tab INTO gs_data-saknr WHERE zcostcode = gs_file-wc_code.
        gs_data-budat = sy-datum.
        gs_data-blart = 'ZW'.

        ""INT0013 Development
        gs_int13-mandt = sy-mandt.
        gs_int13-edi_trans_no =  gs_file-ztran_id.
        gs_int13-edi_trans_date = sy-datum.
        gs_int13-tenant_number = gs_file-zsuppl_no.
        gs_int13-payee_number =   gs_int13-tenant_number = |{ gs_int13-tenant_number ALPHA = IN }|.
        gs_int13-sales_date = gs_data-bldat.
        gs_int13-gl_account = gs_data-saknr.
        gs_int13-amount = gs_data-cr_amnt.
        gs_int13-exp_remark = gs_file-refnd_typ.
        gs_int13-invoice_number = gs_file-custmr_unt.
        gs_int13-company_code = gs_data-bukrs.
        gs_int13-business_unit = gs_data-prctr.
        gs_int13-created_by = sy-uname.
        gs_int13-create_date = sy-datum.
        ""Changes on FS version2
        gs_int13-request_type = '00'.
        gs_int13-approval_status = 'P'.
        gs_int13-waers = 'USD'.
        gs_int13-business_unit_company_code = gs_data-bukrs.
        SELECT SINGLE * FROM cepc INTO @DATA(ls_cepc) WHERE prctr = @lv_prctr.
        IF sy-subrc EQ 0.
          gs_int13-business_unit_state = ls_cepc-regio.
          gs_int13-business_unit_country = ls_cepc-land1.
        ENDIF.
        SELECT SINGLE * FROM lfa1 INTO @DATA(ls_lfa1) WHERE lifnr = @gs_int13-tenant_number.
        IF sy-subrc EQ 0.
          gs_int13-payee_name = gs_int13-tenant_name = ls_lfa1-name1.
          gs_int13-tenant_state = ls_lfa1-regio.
        ENDIF.
        SELECT SINGLE * FROM setleaf INTO @DATA(ls_setleaf) WHERE setclass = '0106'
                                                              AND valto = @lv_prctr.
        IF sy-subrc EQ 0.
          gs_int13-district = ls_setleaf-setname.
          SELECT SINGLE * FROM setnode INTO @DATA(ls_setnode) WHERE subsetname = @ls_setleaf-setname.
          IF sy-subrc EQ 0.
            gs_int13-senior_district = ls_setnode-setname.
            SELECT SINGLE * FROM setnode INTO @DATA(ls_setnode2) WHERE subsetname = @ls_setnode-setname.
            IF sy-subrc EQ 0.
              gs_int13-region = ls_setnode2-setname.
              SELECT SINGLE * FROM setnode INTO @DATA(ls_setnode3) WHERE subsetname = @ls_setnode2-setname.
              IF sy-subrc EQ 0.
                gs_int13-senior_region  = ls_setnode3-setname.
                SELECT SINGLE * FROM setnode INTO @DATA(ls_setnode4) WHERE  subsetname = @ls_setnode3-setname.
                IF sy-subrc EQ 0.
                  gs_int13-division = ls_setnode4-setname.
                  SELECT SINGLE * FROM setnode INTO @DATA(ls_setnode5) WHERE  subsetname = @ls_setnode4-setname.
                  IF sy-subrc EQ 0.
                    gs_int13-zzone = ls_setnode5-setname.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        SELECT SINGLE * FROM zfiap_ep_rules INTO @DATA(ls_zfiap_ep_rules)  WHERE state = @gs_int13-business_unit_state.
        IF sy-subrc EQ 0.
          gs_int13-escheat_rule = ls_zfiap_ep_rules-escheat_rule.
          gs_int13-remit_type = ls_zfiap_ep_rules-remit_type.
          gs_int13-holding_period = ls_zfiap_ep_rules-holding_period.
          gs_int13-hp_uom = ls_zfiap_ep_rules-hp_uom.
          gs_int13-pi_delay_period = ls_zfiap_ep_rules-pi_delay.
        ENDIF.
        gs_int13-create_time = sy-uzeit.
        APPEND gs_int13 TO gt_int13.
        APPEND gs_data TO gt_data.
        CLEAR : gs_data, gs_file, gs_int13.
      ENDLOOP.

      DELETE gt_data[] WHERE bktxt = 'DTM Refund'.
      DELETE gt_int13[] WHERE exp_remark NE 'DTM Refund'.
      ""INT0013 Development
      IF gt_int13 IS NOT INITIAL.
        MODIFY zfiap_ep_data FROM TABLE gt_int13.
        IF sy-dbcnt IS NOT INITIAL.
          COMMIT WORK.
        ENDIF.
      ENDIF.
      ""INT0013 Development
    ENDIF.
    IF gt_data IS NOT INITIAL.
      DATA(lr_prc) = NEW zcl_wc_s4_tenant_refund_int( ).

      CALL METHOD lr_prc->post_document
        EXPORTING
          gt_data = gt_data
          ev_dl   = lv_dl
          gt_file = gt_file
        IMPORTING
          it_ret2 = gt_ret2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

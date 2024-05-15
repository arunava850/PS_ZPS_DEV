class ZCL_INT16_RESTATE_TAX_ACCURAL definition
  public
  final
  create public .

public section.

  methods POST_DOCUMENT
    importing
      value(GT_FILE) type ANY TABLE
      value(GV_BLART) type BLART optional
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GV_TAXGL) type SAKNR
      value(GV_BUDAT) type BUDAT
    exporting
      value(GT_RETURN) type BAPIRET2_T .
  methods SEND_MAIL
    importing
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type ANY TABLE .
  methods SEND_MAIL_NEW
    importing
      value(GT_DATA) type ZFI_INT16_REST_TAX_ACCURAL optional
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type ANY TABLE
    exceptions
      EO_BCS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT16_RESTATE_TAX_ACCURAL IMPLEMENTATION.


  METHOD post_document.

    TYPES : BEGIN OF ty_file,
              status(7)          TYPE c,
              message(1024)      TYPE c,
              idoc_no(16)        TYPE n,
              prcl_year(6)       TYPE c,
              tax_typ(4)         TYPE c,
              tax_billid(50)     TYPE c,
              prcel(20)          TYPE c,
              exprt_no(16)       TYPE c,
              allc_dbtgl(15)     TYPE c,
              proprty_id(10)     TYPE c,
              period_end(10)     TYPE c,
              period_accural(16) TYPE p DECIMALS 2,
              prcl_text(60)      TYPE c,
              txbill_no(10)      TYPE c,
              paymnt_mthd(10)    TYPE c,
              clint_fyr(4)       TYPE c,
              clint_fpr(2)       TYPE c,
*              comments(1028)     TYPE c,
            END OF ty_file,
            BEGIN OF ty_file2,
              prcl_year(6)       TYPE c,
              tax_typ(4)         TYPE c,
              tax_billid(50)     TYPE c,
              prcel(20)          TYPE c,
              exprt_no(16)       TYPE c,
              allc_dbtgl(15)     TYPE c,
              proprty_id(10)     TYPE c,
              period_end(10)     TYPE c,
              period_accural(30) TYPE c,
              prcl_text(60)      TYPE c,
              txbill_no(10)      TYPE c,
              paymnt_mthd(10)    TYPE c,
              clint_fyr(4)       TYPE c,
              clint_fpr(2)       TYPE c,
*              comments(1028)     TYPE c,
            END OF ty_file2.

    DATA : gt_statfile TYPE TABLE OF ty_file,
           gs_statfile TYPE ty_file,
           gt_file2    TYPE TABLE OF ty_file2,
           ls_data     TYPE zfi_int16_rest_tax_accural,
           lv_wrbtr    TYPE p DECIMALS 2.
    DATA: lv_idocno TYPE edi_docnum.
    DATA : gs_docheader TYPE bapiache09,
           gt_ret       TYPE TABLE OF bapiret2,
           gt_accntgl   TYPE TABLE OF bapiacgl09,
           gs_accntgl   TYPE bapiacgl09,
*           gt_accntpay  TYPE TABLE OF bapiacap09,
*           gs_accntpay  TYPE bapiacap09,
           gt_curr      TYPE TABLE OF bapiaccr09,
           gs_curr      TYPE bapiaccr09,
           gt_accntax   TYPE TABLE OF bapiactx09,
           gs_accntax   TYPE bapiactx09,
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           gt_withtx    TYPE TABLE OF bapiacwt09,
           gs_ret       TYPE bapiret2,
           lv_fyear     TYPE bapi0002_4-fiscal_year,
           lv_period    TYPE bapi0002_4-fiscal_period,
           lv_item      TYPE posnr_acc,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           lv_flg       TYPE c,
           lv_diff      TYPE wrbtr,
           lv_objnr     TYPE j_objnr,
           lv_perio     TYPE co_perio,
           lv_WTP       TYPE bp_wpt,
           lv_fldwtp(5) TYPE c,
           lv_date_int  TYPE d.
*           ls_data      TYPE zfi_int15_rest_tax_ap.

    DATA : ls_key      TYPE bapi1022_key,
           lv_asset    TYPE bapi1022_1-assetmaino,
           ls_gen      TYPE bapi1022_feglg001,
           ls_genx     TYPE bapi1022_feglg001x,
           ls_ret2     TYPE bapiret2,
           ls_time     TYPE bapi1022_feglg003,
           ls_timex    TYPE bapi1022_feglg003x,
           lv_subasset TYPE bapi1022_1-assetsubno,
           ls_origin   TYPE bapi1022_feglg009,
           ls_originx  TYPE bapi1022_feglg009x,
           lr_ktansw   TYPE RANGE OF ktansw,
           ls_ktansw   LIKE LINE OF lr_ktansw,
           lv_ktansw   TYPE ktansw,
           lv_anlkl    TYPE anlkl.
    DATA: lt_deparea  TYPE TABLE OF bapi1022_dep_areas,
          ls_deparea  TYPE bapi1022_dep_areas,
          lt_depareax TYPE TABLE OF bapi1022_dep_areasx,
          ls_depareax TYPE bapi1022_dep_areasx.

    TYPES: BEGIN OF ty_prctr,
             prctr TYPE cepc-prctr,
           END OF ty_prctr.
    DATA: lt_prctr TYPE TABLE OF ty_prctr,
          ls_prctr TYPE ty_prctr.

    TYPES: BEGIN OF ty_zfi_jde_gl_map,
             zjde_gl TYPE zfi_jde_gl_map-zjde_gl,
           END OF ty_zfi_jde_gl_map.
    DATA: lt_saknr TYPE TABLE OF ty_zfi_jde_gl_map,
          ls_saknr TYPE ty_zfi_jde_gl_map.
    CONSTANTS : lc_aucgl TYPE saknr VALUE '0000130051'.
*        DELETE gt_file INDEX 1.
    gt_file2 = CORRESPONDING #( gt_file ).
*    DELETE gt_file2 INDEX 1.
    gt_statfile = CORRESPONDING #( gt_file2 ).

* Fetch all select query records
    DATA(gt_statfile_tmp) = gt_statfile.
    SORT gt_statfile_tmp BY proprty_id.
    DELETE ADJACENT DUPLICATES FROM gt_statfile_tmp COMPARING proprty_id.
    DELETE gt_statfile_tmp WHERE proprty_id EQ abap_false.
    IF gt_statfile_tmp IS NOT INITIAL.
      SELECT SINGLE *
        FROM tvarvc
        INTO @DATA(ls_tvar)
       WHERE name EQ 'ZCL_INT16_RESTATE_TAX'
         AND type EQ 'P'.
      LOOP AT gt_statfile_tmp INTO DATA(ls_statfile_tmp).
        ls_prctr-prctr = ls_statfile_tmp-proprty_id.
        ls_prctr-prctr = |{ ls_prctr-prctr ALPHA = IN }|.
        APPEND ls_prctr TO lt_prctr.
        CLEAR:ls_prctr.
      ENDLOOP.
      SELECT a~bukrs,
             a~anln1,
             a~anln2,
             a~bdatu,
             a~prctr,
             b~anlkl
        FROM anlz AS a
       INNER JOIN anla AS b
          ON a~bukrs EQ b~bukrs
         AND a~anln1 EQ b~anln1
         AND a~anln2 EQ b~anln2
        INTO TABLE @DATA(lt_anlz)
         FOR ALL ENTRIES IN @lt_prctr
       WHERE a~prctr EQ @lt_prctr-prctr
         AND b~anlkl EQ @ls_tvar-low
         AND  b~ldt_date EQ '00000000'.


      SELECT kokrs,
             prctr,
             bukrs
        INTO TABLE @DATA(lt_cepc_bukrs)
        FROM cepc_bukrs
         FOR ALL ENTRIES IN @lt_prctr
       WHERE prctr EQ @lt_prctr-prctr.

      SELECT kokrs,
             kostl,
             datbi,
             prctr
        INTO TABLE @DATA(lt_csks)
        FROM csks
         FOR ALL ENTRIES IN @lt_prctr
       WHERE kokrs EQ 'PSCO'
         AND prctr EQ @lt_prctr-prctr.
    ENDIF.

    REFRESH: gt_statfile_tmp.
    gt_statfile_tmp = gt_statfile.
    SORT gt_statfile_tmp BY allc_dbtgl.
    DELETE ADJACENT DUPLICATES FROM gt_statfile_tmp COMPARING allc_dbtgl.
    DELETE gt_statfile_tmp WHERE allc_dbtgl EQ abap_false.
    REFRESH : lr_ktansw.
    ls_ktansw-sign = 'I'.
    ls_ktansw-option = 'EQ'.
    LOOP AT gt_statfile_tmp INTO ls_statfile_tmp.
      CLEAR lv_ktansw.
      lv_ktansw = ls_statfile_tmp-allc_dbtgl.
      ls_ktansw-low = |{ lv_ktansw ALPHA = IN }|.
      APPEND ls_ktansw TO lr_ktansw.
      CLEAR ls_statfile_tmp.
    ENDLOOP.
    SELECT ktopl,
           ktogr,
           afabe,
           ktansw FROM t095 INTO TABLE @DATA(lt_t095)
      WHERE ktansw IN @lr_ktansw.
    IF sy-subrc EQ 0 AND lt_t095 IS NOT INITIAL.

      SELECT bukrs,
      anln1,
      anln2,
      anlkl,
      ktogr FROM anla INTO TABLE @DATA(lt_anla)
        FOR ALL ENTRIES IN @lt_t095
        WHERE ktogr = @lt_t095-ktogr
        AND anlkl = @ls_tvar-low.

    ENDIF.

*    SELECT
*    LOOP AT gt_statfile_tmp INTO ls_statfile_tmp.
*      ls_saknr-zjde_gl = ls_statfile_tmp-allc_dbtgl.
*      APPEND ls_saknr TO lt_saknr.
*      CLEAR:ls_saknr.
*    ENDLOOP.
*    IF lt_saknr IS NOT INITIAL.
*      SELECT zjde_gl,
*             saknr
*        INTO TABLE @DATA(lt_jd_mapping)
*        FROM zfi_jde_gl_map
*         FOR ALL ENTRIES IN @lt_saknr
*       WHERE zjde_gl EQ @lt_saknr-zjde_gl.
*    ENDIF.

    SELECT SINGLE xbilk
      INTO @DATA(lv_xbilk_taxgl)
      FROM ska1
     WHERE saknr = @gv_taxgl
       AND ktopl = 'PSUS'.
    SELECT SINGLE xbilk
      INTO @DATA(lv_xbilk_500040)
      FROM ska1
     WHERE saknr = '0000500040'
       AND ktopl = 'PSUS'.

* Fetch all select query records
*    DELETE gt_statfile INDEX 1.
    LOOP AT gt_statfile ASSIGNING FIELD-SYMBOL(<fs_file>).
      CLEAR ls_data.
*      CONCATENATE <fs_file>-apchkrno <fs_file>-exportno INTO ls_data-xblnr SEPARATED BY space.   "+p
      IF <fs_file>-allc_dbtgl IS INITIAL.
        CONTINUE.
      ELSE.
        IF <fs_file>-period_end NE abap_false.
          CONCATENATE <fs_file>-prcl_year <fs_file>-tax_typ <fs_file>-period_end INTO ls_data-bktxt SEPARATED BY '/'.
        ELSE.
          CONCATENATE <fs_file>-prcl_year <fs_file>-tax_typ INTO ls_data-bktxt SEPARATED BY '/'.
        ENDIF.
        ls_data-sgtxt = <fs_file>-tax_billid.
        CONCATENATE <fs_file>-prcel  <fs_file>-paymnt_mthd INTO ls_data-zuonr SEPARATED BY space.
        ls_data-saknr = <fs_file>-allc_dbtgl.
        ls_data-saknr = |{ ls_data-saknr ALPHA = IN }|.
        ls_data-prctr = <fs_file>-proprty_id.
        ls_data-prctr = |{ ls_data-prctr ALPHA = IN }|.
        READ TABLE lt_cepc_bukrs
              INTO DATA(ls_cepc_bukrs)
          WITH KEY prctr = ls_data-prctr.
        IF sy-subrc EQ 0.
          ls_data-bukrs = ls_cepc_bukrs-bukrs.
        ENDIF.
        CLEAR : lv_ktansw.
        READ TABLE lt_t095 INTO DATA(ls_t095) WITH KEY ktansw = ls_data-saknr.
        IF sy-subrc EQ 0. "ls_data-saknr = lc_aucgl.
          READ TABLE lt_anlz
          INTO DATA(ls_anlz)
          WITH KEY prctr = ls_data-prctr
                   bukrs = ls_data-bukrs
                   anlkl = ls_tvar-low.
          IF sy-subrc NE 0.
            ""Create asset.
            CLEAR : ls_key.
            ls_key-companycode = ls_data-bukrs.
            ls_key-asset = ls_data-zuonr.

            ls_gen-descript = <fs_file>-tax_billid."ls_data-bktxt.
            ls_genx-descript = abap_true.



            ls_gen-assetclass = ls_tvar-low.
            ls_genx-assetclass = abap_true.

            ls_time-profit_ctr = ls_data-prctr.



            ls_timex-profit_ctr = 'X'.
            lv_anlkl = |{ ls_gen-assetclass ALPHA = OUT }|.
            IF lv_anlkl(1) NE 3.
*            IF ls_gen-assetclass(1) NE 3.
              ls_time-costcenter = ls_data-prctr.  ""ls_data-costctr+2(8). "
              ls_timex-costcenter = 'X'.
            ENDIF.

***** Allow negative values for while creating document
            ls_deparea-area = '01'.
            ls_deparea-neg_values = 'X'.
            APPEND ls_deparea TO lt_deparea.

            ls_depareax-area = '01'.
            ls_depareax-neg_values = 'X'.
            APPEND ls_depareax TO lt_depareax.

            CLEAR:lv_subasset,ls_ret2, lv_asset.
            CALL FUNCTION 'BAPI_FIXEDASSET_CREATE1'
              EXPORTING
                key                = ls_key
                generaldata        = ls_gen
                generaldatax       = ls_genx
                timedependentdata  = ls_time
                timedependentdatax = ls_timex
                origin             = ls_origin
                originx            = ls_originx
              IMPORTING
                asset              = lv_asset
                subnumber          = lv_subasset
                return             = ls_ret2
              TABLES
                depreciationareas  = lt_deparea
                depreciationareasx = lt_depareax.

            IF ls_ret2-type NE 'E'.
              DATA(lv_asset_flag) = abap_true.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*            EXPORTING
*              WAIT          =
*            IMPORTING
*              RETURN        =
                .
              lv_ktansw = ls_t095-ktansw.
            ENDIF.
          ELSE.
            lv_asset_flag = abap_true.
            lv_asset = ls_anlz-anln1.
            lv_subasset = ls_anlz-anln2.
            lv_ktansw = ls_t095-ktansw.
          ENDIF.
*        ELSE.
*          READ TABLE lt_jd_mapping
*           INTO DATA(ls_jd_mapping)
*            WITH KEY zjde_gl = ls_data-saknr.
*          IF sy-subrc EQ 0.
*            ls_data-saknr = ls_jd_mapping-saknr.
*          ENDIF.
        ENDIF.

        ls_data-xblnr = <fs_file>-exprt_no.
        ls_data-budat = gv_budat.
        CLEAR: lv_wrbtr,lv_date_int.
        MOVE <fs_file>-period_accural TO lv_wrbtr.
        ls_data-wrbtr = lv_wrbtr.

        ls_data-bldat = ls_data-budat.
        ls_data-blart = gv_blart.
        ls_data-prctr = |{ ls_data-prctr ALPHA = IN }|.
        READ TABLE lt_cepc_bukrs
         INTO ls_cepc_bukrs
          WITH KEY prctr = ls_data-prctr.
        IF sy-subrc EQ 0.
          ls_data-bukrs = ls_cepc_bukrs-bukrs.
        ENDIF.

        gs_docheader-obj_type = 'BKPFF'.
        gs_docheader-bus_act = 'RFBU'.
        gs_docheader-doc_status = '3'.
        gs_docheader-username = sy-uname.
        gs_docheader-comp_code = ls_data-bukrs.
        gs_docheader-doc_date = ls_data-bldat.
        gs_docheader-pstng_date = ls_data-budat.
        gs_docheader-doc_type =  ls_data-blart.
        gs_docheader-ref_doc_no  = ls_data-xblnr.
        gs_docheader-header_txt = ls_data-bktxt.
        lv_item = '1'.
        CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
          EXPORTING
            companycodeid = ls_data-bukrs
            posting_date  = ls_data-budat
          IMPORTING
            fiscal_year   = lv_fyear
            fiscal_period = lv_period
*           RETURN        =
          .
        gs_docheader-fisc_year = lv_fyear.
        gs_docheader-fis_period = lv_period.

        READ TABLE lt_csks
         INTO DATA(ls_csks)
          WITH KEY prctr = ls_data-prctr.
        IF sy-subrc EQ 0.
          DATA(lv_kostl) = ls_csks-kostl.
        ENDIF.
        IF sy-subrc EQ 0.
          gs_accntgl-costcenter = lv_kostl.
          gs_accntgl-costcenter = |{ gs_accntgl-costcenter ALPHA = IN }|.
        ENDIF.
        CLEAR: lv_objnr,lv_perio,lv_diff,lv_flg.
        lv_perio = lv_period.
        CONCATENATE 'KSPSCO' gs_accntgl-costcenter INTO lv_objnr.

*        SELECT SINGLE * FROM bppe INTO @DATA(ls_bppe)
*          WHERE objnr = @lv_objnr
*          AND gjahr = @lv_fyear.
*        IF sy-subrc EQ 0.
*          CONCATENATE 'WTP' lv_period INTO lv_fldwtp.
*          ASSIGN COMPONENT lv_fldwtp OF STRUCTURE ls_bppe TO FIELD-SYMBOL(<fs_wtp>).
*          IF <fs_wtp> IS  ASSIGNED AND <fs_wtp> IS NOT INITIAL.
*            lv_diff = ls_data-wrbtr - <fs_wtp>.
*            lv_flg = 'X'.
*          ENDIF.
*        ENDIF.

        gs_accntgl-itemno_acc = lv_item.
        IF lv_asset_flag EQ abap_true.
          gs_accntgl-gl_account = lv_ktansw.
          gs_accntgl-acct_type = 'A'.
          gs_accntgl-asset_no = lv_asset.
          gs_accntgl-sub_number = lv_subasset.
          gs_accntgl-cs_trans_t = '100'.
          gs_accntgl-acct_key = 'ANL'.
        ELSE.
          gs_accntgl-gl_account = |{ ls_data-saknr ALPHA = IN }|.
        ENDIF.
        gs_accntgl-alloc_nmbr = ls_data-zuonr.
        gs_accntgl-item_text = ls_data-sgtxt.
        APPEND gs_accntgl TO gt_accntgl.
        CLEAR: gs_accntgl,lv_asset_flag.

        gs_curr-itemno_acc = lv_item.
        gs_curr-currency = 'USD'.
        gs_curr-amt_doccur = ls_data-wrbtr.
        gs_curr-amt_base =  ls_data-wrbtr .
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.

        SELECT SINGLE xbilk
       INTO @DATA(lv_xbilk_saknr)
       FROM ska1
      WHERE saknr = @gs_accntgl-gl_account
        AND ktopl = 'PSUS'.
        IF lv_xbilk_saknr = space.
          gs_charfld-itemno_acc = lv_item.
          gs_charfld-fieldname = 'PRCTR'.
          gs_charfld-character = gs_accntgl-profit_ctr.
          APPEND gs_charfld TO gt_charfld.
          CLEAR gs_charfld.
        ENDIF.
        gs_accntgl-itemno_acc = lv_item + 1.
        gs_accntgl-gl_account = |{ gv_taxgl ALPHA = IN }|.
        gs_accntgl-alloc_nmbr = ls_data-zuonr.
        gs_accntgl-item_text = ls_data-sgtxt.
        gs_accntgl-profit_ctr  = ls_data-prctr.
        APPEND gs_accntgl TO gt_accntgl.

        IF lv_xbilk_taxgl = space. " Venkat
          gs_charfld-itemno_acc = lv_item + 1.
          gs_charfld-fieldname = 'PRCTR'.
          gs_charfld-character = gs_accntgl-profit_ctr.
          APPEND gs_charfld TO gt_charfld.
          CLEAR gs_charfld.
        ENDIF.

        CLEAR gs_accntgl.
        gs_curr-itemno_acc = lv_item + 1.
        gs_curr-currency = 'USD'.
        gs_curr-amt_doccur = ls_data-wrbtr * -1.
        gs_curr-amt_base =  ls_data-wrbtr * -1.
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.
*        IF lv_flg = 'X'.
*          READ TABLE lt_csks
*                INTO ls_csks
*            WITH KEY prctr = ls_data-prctr.
*          IF sy-subrc EQ 0.
*            DATA(lv_kostl2) = ls_csks-kostl.
*          ENDIF.
*          IF sy-subrc EQ 0.
*            gs_accntgl-costcenter = lv_kostl2.
*            gs_accntgl-costcenter = |{ gs_accntgl-costcenter ALPHA = IN }|.
*          ENDIF.
*          gs_accntgl-itemno_acc = lv_item + 2.
*          gs_accntgl-gl_account = '0000500040'.
*          gs_accntgl-alloc_nmbr = ls_data-zuonr.
*          gs_accntgl-item_text = ls_data-sgtxt.
*          APPEND gs_accntgl TO gt_accntgl.
*          CLEAR gs_accntgl.
*
*          IF lv_xbilk_500040 = space. " lv_xbilk_500040 is fetched before loop
*            gs_charfld-itemno_acc = lv_item + 2.
*            gs_charfld-fieldname = 'PRCTR'.
*            gs_charfld-character = ls_data-prctr.
*            APPEND gs_charfld TO gt_charfld.
*            CLEAR gs_charfld.
*          ENDIF.
*          gs_curr-itemno_acc = lv_item + 2.
*          gs_curr-currency = 'USD'.
*          IF lv_diff GT 0.
*            gs_curr-amt_doccur = lv_diff.
*            gs_curr-amt_base =  lv_diff .
*          ELSE.
*            gs_curr-amt_doccur = lv_diff * -1.
*            gs_curr-amt_base =  lv_diff * -1.
*          ENDIF.
*          APPEND gs_curr TO gt_curr.
*          CLEAR gs_curr.
*
*          gs_accntgl-itemno_acc = lv_item + 3.
*          gs_accntgl-gl_account = '0000210010'.
*          gs_accntgl-alloc_nmbr = ls_data-zuonr.
*          gs_accntgl-item_text = ls_data-sgtxt.
*          gs_accntgl-profit_ctr  = ls_data-prctr.
*          APPEND gs_accntgl TO gt_accntgl.
*          CLEAR gs_accntgl.
*
*          gs_curr-itemno_acc = lv_item + 3.
*          gs_curr-currency = 'USD'.
*          IF lv_diff GT 0.
*            gs_curr-amt_doccur = lv_diff * -1.
*            gs_curr-amt_base =  lv_diff * -1.
*          ELSE.
*            gs_curr-amt_doccur = lv_diff.
*            gs_curr-amt_base =  lv_diff.
*          ENDIF.
*          APPEND gs_curr TO gt_curr.
*          CLEAR gs_curr.
*        ENDIF.

        CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = gs_docheader
          IMPORTING
            ev_docnum      = lv_idocno
          TABLES
            accountgl      = gt_accntgl
            currencyamount = gt_curr
            criteria       = gt_charfld
            return         = gt_ret
            accountwt      = gt_withtx.
*** Error handling to fill email output data
        IF lv_idocno IS NOT INITIAL.
          CALL METHOD zcl_ps_utility_tools=>get_idoc_status_records
            EXPORTING
              iv_idoc_no = lv_idocno
            IMPORTING
              es_status  = DATA(ls_status).
          IF ls_status-status EQ '53'.
            <fs_file>-status = 'Success'.
            <fs_file>-idoc_no = lv_idocno.
            <fs_file>-message = ls_status-message.
          ELSEIF ls_status-status EQ '51'.
            <fs_file>-status = 'Error'.
            <fs_file>-idoc_no = lv_idocno.
            <fs_file>-message = ls_status-message.
          ELSE.
            <fs_file>-status = 'Check'.
            <fs_file>-idoc_no = lv_idocno.
            <fs_file>-message = ls_status-message.
          ENDIF.
        ELSE.
          <fs_file>-status = 'Error'.
          <fs_file>-idoc_no = lv_idocno.
          <fs_file>-message = 'Unable to get Idoc Data'.
        ENDIF.
      ENDIF.
      REFRESH : gt_accntgl, gt_accntax, gt_curr, gt_charfld, gt_ret.
      CLEAR : gs_docheader.
    ENDLOOP.
    IF gt_statfile IS NOT INITIAL.
      DATA(lo_mail) = NEW zcl_int16_restate_tax_accural( ).
      CALL METHOD lo_mail->send_mail_new      "++p
        EXPORTING
          gv_dl   = gv_dl
          gt_file = gt_statfile.
    ENDIF.
  ENDMETHOD.


  METHOD send_mail.
    TYPES : BEGIN OF ty_file,
              prcl_year(6)       TYPE c,
              tax_typ(4)         TYPE c,
              tax_billid(50)     TYPE c,
              prcel(20)          TYPE c,
              exprt_no(16)       TYPE c,
              allc_dbtgl(15)     TYPE c,
              proprty_id(10)     TYPE c,
              period_end(10)     TYPE c,
              period_accural(30) TYPE c,
              prcl_text(60)      TYPE c,
              txbill_no(10)      TYPE c,
              paymnt_mthd(10)    TYPE c,
              clint_fyr(4)       TYPE c,
              clint_fpr(2)       TYPE c,
              comments           TYPE string,
            END OF ty_file.


    DATA : gt_mail TYPE TABLE OF ty_file,
           gs_mail TYPE ty_file.
    gt_mail[] = corresponding #( gt_file[] ).
    DATA send_request   TYPE REF TO cl_bcs.
    DATA document       TYPE REF TO cl_document_bcs.
    DATA recipient      TYPE REF TO if_recipient_bcs.
    DATA bcs_exception  TYPE REF TO cx_bcs.

    DATA main_text      TYPE bcsy_text.
    DATA binary_content TYPE solix_tab.
    DATA binary_content1 TYPE solix_tab.
    DATA size           TYPE so_obj_len.
    DATA size1           TYPE so_obj_len.
    DATA sent_to_all    TYPE os_boolean.
    DATA  : mailto        TYPE ad_smtpadr,
            lv_dmbtr(25)  TYPE c,
            lv_mwsts(25)  TYPE c,
            lv_attach_sub TYPE sood-objdes.
    DATA: l_text TYPE string.     " Text content for mail attachment
    DATA: l_con(50)   TYPE c,        " Field Content in character format
          lv_date(10) TYPE c.
    CONSTANTS:
      gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

*    ""
*    """
*    LOOP AT gt_mail ASSIGNING FIELD-SYMBOL(<fs_scs>).
*      CONCATENATE l_text
*  <fs_scs>-prcl_year gc_tab
*  <fs_scs>-tax_typ gc_tab
*  <fs_scs>-tax_billid gc_tab
*  <fs_scs>-prcel gc_tab
*  <fs_scs>-exprt_no gc_tab
*  <fs_scs>-allc_dbtgl gc_tab
*  <fs_scs>-proprty_id gc_tab
*  <fs_scs>-period_end gc_tab
*  <fs_scs>-period_accural gc_tab
*    <fs_scs>-prcl_text gc_tab
*    <fs_scs>-txbill_no gc_tab
*  <fs_scs>-paymnt_mthd gc_tab
*  <fs_scs>-clint_fyr gc_tab
*  <fs_scs>-clint_fpr gc_tab
**  <fs_scs>-apvndrnam gc_tab
**  <fs_scs>-prprtyid gc_tab
**  <fs_scs>-parcel gc_tab
**  <fs_scs>-apnetpyamnt gc_tab
**    <fs_scs>-gldate gc_tab
**      <fs_scs>-txbillno gc_tab
**   <fs_scs>-usecod11 gc_tab
*    <fs_scs>-comments gc_crlf
*  INTO l_text.
*    ENDLOOP.
*    TRY.
*        cl_bcs_convert=>string_to_solix(
*          EXPORTING
*            iv_string   = l_text
*            iv_codepage = '4103'  "suitable for MS Excel, leave empty
*            iv_add_bom  = 'X'     "for other doc types
*          IMPORTING
*            et_solix  = binary_content
*            ev_size   = size ).
*      CATCH cx_bcs.
*        MESSAGE e445(so).
*    ENDTRY.


    TRY.
*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
*        APPEND 'OneSource to S/4HANA Real Estate Tax Accural Status' TO main_text. "#EC NOTEXT
        CLEAR lv_date.
        DATA(lv_yy) = sy-datum+0(4).
        DATA(lv_mm) = sy-datum+4(2).
        DATA(lv_dd) = sy-datum+6(2).
        CONCATENATE lv_mm '-' lv_dd '-' lv_yy INTO lv_date.
        CONCATENATE 'INT0016 has been processed on   ' lv_date '/' sy-uzeit INTO  DATA(lv_text) SEPARATED BY space.
        APPEND lv_text TO main_text.
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
          i_subject = 'INT0016 has been processed' ).       "#EC NOTEXT

**     add the spread sheet as attachment to document object
*        document->add_attachment(
*          i_attachment_type    = 'xls'                      "#EC NOTEXT
*          i_attachment_subject = lv_attach_sub              "#EC NOTEXT
*          i_attachment_size    = size
*          i_att_content_hex    = binary_content ).

*   add the spread sheet as attachment to document object
*        document->add_attachment(
*          i_attachment_type    = 'xls'                      "#EC NOTEXT
*          i_attachment_subject = 'Failed_file'              "#EC NOTEXT
*          i_attachment_size    = size1
*          i_att_content_hex    = binary_content1 ).

*     add document object to send request
        send_request->set_document( document ).

*Get the mails for distribution list.
        recipient = cl_distributionlist_bcs=>getu_persistent(
        i_dliname = gv_dl
        i_private = space ).
*     create recipient object
*        recipient = cl_cam_address_bcs=>create_internet_address( mailto ).

*     add recipient object to send request
        send_request->add_recipient( i_recipient = recipient
                                     i_express = 'X'
                                     i_copy = 'X'
                                        ).

*     ---------- send document ---------------------------------------
        sent_to_all = send_request->send( i_with_error_screen = 'X' ).

        COMMIT WORK.
*        IF sent_to_all IS INITIAL.
**          MESSAGE i500(sbcoms) WITH mailto.
*        ELSE.
**          MESSAGE s022(so).
*        ENDIF.
*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
      CATCH cx_bcs INTO bcs_exception.
*        MESSAGE i865(so) WITH bcs_exception->error_type.
    ENDTRY.
  ENDMETHOD.


  method SEND_MAIL_NEW.
 TYPES : BEGIN OF ty_file,
              status(7)        TYPE c,
              message(1024)    TYPE c,
              idoc_no(16)      TYPE n,
              prcl_year(6)       TYPE c,
              tax_typ(4)         TYPE c,
              tax_billid(50)     TYPE c,
              prcel(20)          TYPE c,
              exprt_no(16)       TYPE c,
              allc_dbtgl(15)     TYPE c,
              proprty_id(10)     TYPE c,
              period_end(10)     TYPE c,
              period_accural(30) TYPE c,
              prcl_text(60)      TYPE c,
              txbill_no(10)      TYPE c,
              paymnt_mthd(10)    TYPE c,
              clint_fyr(4)       TYPE c,
              clint_fpr(2)       TYPE c,
            END OF ty_file.

     DATA : lt_file TYPE TABLE OF ty_file,
           ls_file TYPE ty_file.

    lt_file[] = CORRESPONDING #( gt_file[] ).
    DATA send_request   TYPE REF TO cl_bcs.
    DATA document       TYPE REF TO cl_document_bcs.
    DATA recipient      TYPE REF TO if_recipient_bcs.
    DATA bcs_exception  TYPE REF TO cx_bcs.

    DATA main_text      TYPE bcsy_text.
    DATA binary_content TYPE solix_tab.
    DATA binary_content1 TYPE solix_tab.
    DATA size           TYPE so_obj_len.
    DATA size1           TYPE so_obj_len.
    DATA sent_to_all    TYPE os_boolean.
    DATA  : mailto        TYPE ad_smtpadr,
            lv_dmbtr(25)  TYPE c,
            lv_mwsts(25)  TYPE c,
            lv_attach_sub TYPE sood-objdes.
    DATA: lt_body TYPE soli_tab,
          ls_body TYPE soli.
    DATA:  lv_view              TYPE string.
    DATA: lv_subject      TYPE so_obj_des."STRING.
    DATA: lt_mailsubject     TYPE sodocchgi1.
    DATA: lv_length TYPE i.
    DATA: ls_mailtxt TYPE string. "SOLI.
    CONSTANTS:
      gc_tab     TYPE c VALUE ',' , "cl_bcs_convert=>gc_tab,
      gc_formula TYPE c VALUE '=''',
      gc_crlf    TYPE c VALUE cl_bcs_convert=>gc_crlf,
      gc_qc      TYPE c VALUE '"'.
*          lt_text TYPE ANY TABLE.
    DATA: l_text TYPE string.     " Text content for mail attachment
    DATA: l_con(50) TYPE c.        " Field Content in character format
    DATA: lv_index TYPE sy-index VALUE 0.
    CLEAR : l_text,
    lv_attach_sub.

**** Append log data to xstring
    LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_scs>).

      CONCATENATE l_text
        gc_qc <fs_scs>-status gc_qc gc_tab
        gc_qc <fs_scs>-message gc_qc gc_tab
        gc_qc <fs_scs>-idoc_no gc_qc gc_tab
        gc_qc <fs_scs>-prcl_year gc_qc gc_tab
        gc_qc <fs_scs>-tax_typ gc_qc gc_tab
        gc_qc <fs_scs>-tax_billid gc_qc gc_tab
        gc_qc <fs_scs>-prcel gc_qc gc_tab
        gc_qc <fs_scs>-exprt_no gc_qc gc_tab
        gc_qc <fs_scs>-allc_dbtgl gc_qc gc_tab
        gc_qc <fs_scs>-proprty_id gc_qc gc_tab
        gc_qc <fs_scs>-period_end gc_qc gc_tab
        gc_qc <fs_scs>-period_accural gc_qc gc_tab
        gc_qc <fs_scs>-prcl_text gc_qc gc_tab
        gc_qc <fs_scs>-txbill_no gc_qc gc_tab
        gc_qc <fs_scs>-paymnt_mthd gc_qc gc_tab
        gc_qc <fs_scs>-clint_fyr gc_qc gc_tab
        <fs_scs>-clint_fpr gc_crlf
          INTO l_text.
    ENDLOOP.

    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = l_text
*            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix  = binary_content
            ev_size   = size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
    TRY.

***   To Convert the valid from and to date
        CONCATENATE 'Inbound Real Estate Tax Accrual - ' sy-datum+4(2) '/' sy-datum+6(2) '/'
         sy-datum+0(4) lv_view INTO lv_subject.

* Subject.
        lt_mailsubject-obj_name = 'Inbound Real Estate Tax Accrual File'.
        lt_mailsubject-obj_langu = sy-langu.
        lt_mailsubject-obj_descr = lv_subject.


********send emails***************************************************
        DATA: message      TYPE REF TO cl_bcs,      " envelope
              lo_recipient TYPE REF TO cl_cam_address_bcs,
              lo_sender    TYPE REF TO cl_cam_address_bcs.


        CONCATENATE 'Hi'
           '<html></br></htm>' '<html></br></htm>' INTO ls_mailtxt "LT_MAILTXT
        RESPECTING BLANKS.
        DATA: lv_trecords TYPE string,
              lv_erecords TYPE string,
              lv_srecords TYPE string.
        DESCRIBE TABLE lt_file LINES lv_trecords.
        DELETE lt_file WHERE status EQ 'Success'.
        DESCRIBE TABLE lt_file LINES lv_erecords.
        lv_srecords = lv_trecords - lv_erecords.

        CONCATENATE ls_mailtxt 'Here is the INT0016 Inbound Real Estate Tax Accrual status with file attachment for your review and reprocess error records if required any.'
           '<html></br></htm>' '<html></br></htm>'  INTO ls_mailtxt  RESPECTING BLANKS.
        CONCATENATE ls_mailtxt 'Total Number of Records: ' lv_trecords '<html></br></htm>' INTO ls_mailtxt RESPECTING BLANKS.
        CONCATENATE ls_mailtxt 'Successfully Processed: ' lv_srecords '<html></br></htm>' INTO ls_mailtxt RESPECTING BLANKS.
        CONCATENATE ls_mailtxt 'Error Records: ' lv_erecords '<html></br></htm>' '<html></br></htm>' INTO ls_mailtxt RESPECTING BLANKS.
        CONCATENATE ls_mailtxt 'Please do not reply to the sender of this email.' '<html></br></htm>' '<html></br></htm>' INTO ls_mailtxt  RESPECTING BLANKS.
        CONCATENATE ls_mailtxt 'Thanks' INTO ls_mailtxt RESPECTING BLANKS.


        DATA: lv_size_mailtxt      TYPE so_obj_len,
              lt_output_mailtxt    TYPE TABLE OF solix,
              lt_attachment_header TYPE TABLE OF soli,
              ls_attachment_header TYPE soli,
              lv_filename          TYPE string.

        lv_filename = 'Inbound Real Estate Tax Accrual to SAP File.csv'.
        CONCATENATE '&SO_FILENAME=' lv_filename INTO ls_attachment_header.
        APPEND ls_attachment_header TO lt_attachment_header.

        DATA eo_bcs  TYPE REF TO cx_bcs.
        TRY.
            cl_bcs_convert=>string_to_solix(
                EXPORTING
                     iv_string = ls_mailtxt   " your delimited string
                IMPORTING
                     et_solix = lt_output_mailtxt        " the binary, XLS file
                       ev_size = lv_size_mailtxt ).

          CATCH cx_bcs INTO eo_bcs.
            RAISE eo_bcs.
        ENDTRY.

        TRY.
            message = cl_bcs=>create_persistent( ).
          CATCH cx_bcs INTO eo_bcs.
            RAISE eo_bcs.
        ENDTRY.

        TRY.
            document = cl_document_bcs=>create_document(
              i_type = 'HTM'
              i_hex = lt_output_mailtxt
              i_subject = lv_subject ).

          CATCH cx_bcs INTO eo_bcs.
            RAISE eo_bcs.
        ENDTRY.

        lv_attach_sub = 'RESTATE_TO_SAP_FILE'.
        CALL METHOD document->add_attachment
          EXPORTING
            i_attachment_type    = 'csv'
            i_attachment_subject = lv_attach_sub
            i_attachment_size    = size
            i_att_content_hex    = binary_content.

* next, put the letter in the envelope
        DATA eo_send_req_bcs TYPE REF TO cx_send_req_bcs.

        TRY .
            message->set_document( document ).
*    CATCH cx_send_req_bcs INTO eo_send_req_bcs.
*      RAISE eo_send_req_bcs.

        ENDTRY.

*        send_request->set_document( document ).

*Get the mails for distribution list.
        recipient = cl_distributionlist_bcs=>getu_persistent(
        i_dliname = gv_dl
        i_private = space ).
*     create recipient object
*        recipient = cl_cam_address_bcs=>create_internet_address( mailto ).

*     add recipient object to send request
        message->add_recipient( i_recipient = recipient
                                     i_express = 'X'
                                     i_copy = 'X'
                                        ).

*     ---------- send document ---------------------------------------
        sent_to_all = message->send( i_with_error_screen = 'X' ).

        COMMIT WORK.
        IF sent_to_all IS INITIAL.
          MESSAGE i500(sbcoms) WITH mailto.
        ELSE.
          MESSAGE s022(so).
        ENDIF.
*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
      CATCH cx_bcs INTO bcs_exception.
        MESSAGE i865(so) WITH bcs_exception->error_type.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.

class ZCL_FI_RAMP_ACCNT_PAY definition
  public
  final
  create public .

public section.

  data GT_DATA type ZFITT_RAMP_ACC_PAY .
  data GS_DATA type ZFIS_RAMP_ACC_PAY .

  methods CREATE_ASSET_MASTER
    importing
      value(GT_DATA) type ZFITT_RAMP_ACC_PAY optional
      value(ASSET_AUC) type STANDARD TABLE optional
    exporting
      value(BAPIRET2) type BAPIRET2_TT
      value(EV_ASSET) type ANLN1
      value(EV_SUBAS) type ANLN2
    exceptions
      EO_BCS .
  methods POST_DOCUMENT
    importing
      value(GT_DATA) type ZFITT_RAMP_ACC_PAY optional
      value(IV_THREHOLD) type DMBTR optional
      value(IV_TAXGL) type SAKNR optional
      value(IV_DOCTYP) type BLART optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(EV_FILETYPE) type CHAR5 optional
      value(ASSET_AUC) type STANDARD TABLE optional
    exporting
      value(BAPIRET2) type BAPIRET2_TT
    changing
      value(GT_FILE) type STANDARD TABLE optional
      value(CT_ALV_OUTPUT) type ZFITT_RAMP_ACC_PAY_ALV .
  methods SEND_MAIL
    importing
      value(GT_DATA) type ZFITT_RAMP_ACC_PAY optional
      value(GT_FILE) type STANDARD TABLE optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(EV_FILETYPE) type CHAR5 optional
    exceptions
      EO_BCS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_RAMP_ACCNT_PAY IMPLEMENTATION.


  METHOD create_asset_master.

*TYPES: begin of ty_anla,
*       anln1 type anln1,
*       END OF ty_anla.
*data: gt_anla type STANDARD TABLE OF ty_anla.
    DATA : ls_key    TYPE bapi1022_key,
           lv_asset  TYPE bapi1022_1-assetmaino,
           ls_gen    TYPE bapi1022_feglg001,
           ls_genx   TYPE bapi1022_feglg001x,
           ls_ret2   TYPE bapiret2,
           ls_time   TYPE bapi1022_feglg003,
           ls_timex  TYPE bapi1022_feglg003x,
           ls_alloc  TYPE bapi1022_feglg004,
           ls_allocx TYPE bapi1022_feglg004x,
           ls_posin  TYPE bapi1022_feglg002,
           ls_posinx TYPE bapi1022_feglg002x,
           lv_anlkl  TYPE anlkl.
    DATA: lt_deparea  TYPE TABLE OF bapi1022_dep_areas,
          ls_deparea  TYPE bapi1022_dep_areas,
          lt_depareax TYPE TABLE OF bapi1022_dep_areasx,
          ls_depareax TYPE bapi1022_dep_areasx.
    DATA: lv_subasset  TYPE char01,
          lv_SUBNUMBER TYPE bapi1022_1-assetsubno.

    READ TABLE gt_data INTO DATA(ls_data) INDEX 1.

    ""Get the Account Determination from table T095 based on COA = PSUS, Dep Area = 01 and Bal.Sh.Acct APC = GL #

    CLEAR: ls_key, lv_subasset.


    ls_gen-assetclass = ls_data-anlkl.
    lv_anlkl = |{ ls_gen-assetclass ALPHA = OUT }|.
*** Fill cost center and profit center
    SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
    IF sy-subrc EQ 0.
      IF lv_anlkl(1) NE 3.
        ls_time-costcenter = lv_kostl.
        ls_timex-costcenter = 'X'.
      ENDIF.
      ls_time-profit_ctr = ls_data-prctr.
      ls_timex-profit_ctr = 'X'.
    ELSE.
      SELECT SINGLE prctr INTO @DATA(lv_prctr) FROM csks WHERE kokrs = 'PSCO' AND kostl = @ls_data-prctr.
      IF sy-subrc EQ 0.
        ls_time-profit_ctr = lv_prctr.
        ls_timex-profit_ctr = 'X'.
        IF lv_anlkl(1) NE 3.
          ls_time-costcenter = ls_data-prctr.
          ls_timex-costcenter = 'X'.
        ENDIF.
        lv_kostl = ls_data-prctr.
      ENDIF.
    ENDIF.

**** Check if asset is created for company code, Asset class, and Cost Center
*    SELECT SINGLE anln1 FROM anla INTO @DATA(lv_anln1) WHERE bukrs = @ls_data-bukrs
*                                                       AND  anlkl = @ls_data-anlkl.
*    ls_data-sernr = |{ ls_data-sernr ALPHA = IN }|.
    SELECT a~bukrs, a~anln1, a~anlkl, b~kostl FROM anla AS a INNER JOIN anlz AS b
                                                       ON a~bukrs = b~bukrs
                                                       AND a~anln1 = b~anln1
                                                      INTO TABLE @DATA(gt_anla)
                                                        WHERE a~bukrs = @ls_data-bukrs
                                                        AND anlkl = @ls_data-anlkl
                                                        AND kostl = @lv_kostl.
*    SELECT bukrs, anln1, sernr FROM anla INTO TABLE @DATA(gt_anla)  WHERE bukrs = @ls_data-bukrs
*                                                       AND  anlkl = @ls_data-anlkl.
*                                                       AND sernr = @ls_data-sernr.
    IF sy-subrc EQ 0.
      SORT gt_anla BY bukrs anln1 DESCENDING.
      READ TABLE gt_anla INTO DATA(gs_anla) INDEX 1.

      SELECT SINGLE luntn FROM anlh INTO @DATA(lv_LUNTN) WHERE bukrs = @ls_data-bukrs
                                                          AND anln1 = @gs_anla-anln1.
      IF sy-subrc EQ 0.
        ls_key-asset  = gs_anla-anln1.
        IF asset_auc IS NOT INITIAL AND ls_data-anlkl IN asset_auc.
          ev_asset = gs_anla-anln1.
          ev_subas = lv_LUNTN.
          EXIT.
        ELSE.
          ls_key-subnumber = lv_LUNTN + 1.
        ENDIF.
        ls_key-subnumber = |{ ls_key-subnumber ALPHA = IN }|.
        lv_subasset = 'X'.
      ENDIF.
* sort gt_anla by anln1 DESCENDING.
*READ TABLE gt_anla index1.
*      ENDIF.
    ENDIF.
*    CLEAR : ls_key.

    ls_key-companycode = ls_data-bukrs.
*BREAK-POINT.

    ls_gen-descript = ls_data-ztext."ls_data-bktxt.
*        ls_gen-acct_detrm = lv_ktogr.
*    ls_time-profit_ctr = ls_data-prctr.
**    ls_time-costcenter = lv_kostl.
*    ls_timex-profit_ctr = 'X'.

*    IF lv_anlkl(1) NE 3.
**if ls_gen-assetclass(1) NE 3.
*      ls_time-costcenter = lv_kostl.
**ls_time-FROM_DATE = sy-datum.
**ls_time-to_date = '20231231'.
*      ls_timex-costcenter = 'X'.
*
*    ENDIF.



*ls_timex-FROM_DATE = 'X'.
*ls_timex-to_date = 'X'.

    ls_genx-assetclass = abap_true.
    ls_genx-descript = abap_true.
    IF ls_data-sernr IS NOT INITIAL.
      ls_gen-serial_no = ls_data-sernr.
      ls_genx-serial_no = 'X'.
    ENDIF.
*        ls_genx-acct_detrm = abap_true.

    IF ls_data-ord43 IS NOT INITIAL.
      ls_alloc-evalgroup3 = ls_data-ord43.
      ls_allocx-evalgroup3 = 'X'.
    ENDIF.
**** Fill Asset capitalization date
*    IF ls_data-budat IS NOT INITIAL.
*      ls_posin-cap_date = ls_data-budat.
*      ls_posinx-cap_date = 'X'.
*
*    ENDIF.

***** Allow negative values for while creating document
    ls_deparea-area = '01'.
    ls_deparea-neg_values = 'X'.
    APPEND ls_deparea TO lt_deparea.

    ls_depareax-area = '01'.
    ls_depareax-neg_values = 'X'.
    APPEND ls_depareax TO lt_depareax.

    CALL FUNCTION 'BAPI_FIXEDASSET_CREATE1'
      EXPORTING
        key                = ls_key
*       REFERENCE          =
        createsubnumber    = lv_subasset
*       postcap            = abap_true
*       CREATEGROUPASSET   =
*       TESTRUN            =
        generaldata        = ls_gen
        generaldatax       = ls_genx
*       INVENTORY          =
*       INVENTORYX         =
*       postinginformation = ls_posin
*       postinginformationx = ls_posinx
        timedependentdata  = ls_time
        timedependentdatax = ls_timex
        allocations        = ls_alloc
        allocationsx       = ls_allocx
*       ORIGIN             =
*       ORIGINX            =
*       INVESTACCTASSIGNMNT =
*       INVESTACCTASSIGNMNTX       =
*       NETWORTHVALUATION  =
*       NETWORTHVALUATIONX =
*       REALESTATE         =
*       REALESTATEX        =
*       INSURANCE          =
*       INSURANCEX         =
*       LEASING            =
*       LEASINGX           =
*       GLO_RUS_GEN        =
*       GLO_RUS_GENX       =
*       GLO_RUS_TRC        =
*       GLO_RUS_TRCX       =
*       GLO_RUS_PTX        =
*       GLO_RUS_PTXX       =
*       GLO_RUS_TTX        =
*       GLO_RUS_TTXX       =
*       GLO_RUS_LTX        =
*       GLO_RUS_LTXX       =
*       GLO_IN_GEN         =
*       GLO_IN_GENX        =
*       GLO_JP_ANN16       =
*       GLO_JP_ANN16X      =
*       GLO_JP_PTX         =
*       GLO_JP_PTXX        =
*       GLO_TIME_DEP       =
*       GLO_RUS_GENTD      =
*       GLO_RUS_GENTDX     =
*       GLO_RUS_PTXTD      =
*       GLO_RUS_PTXTDX     =
*       GLO_RUS_TTXTD      =
*       GLO_RUS_TTXTDX     =
*       GLO_RUS_LTXTD      =
*       GLO_RUS_LTXTDX     =
*       GLO_JP_IMPTD       =
*       GLO_JP_IMPTDX      =
*       GLO_KR_BUS_PLACE   =
*       GLO_KR_BUS_PLACEX  =
*       GLO_NATL_CLFN_CODE =
*       GLO_NATL_CLFN_CODEX =
*       GLO_PT_FSCL_MAPS   =
*       GLO_PT_FSCL_MAPSX  =
      IMPORTING
*       COMPANYCODE        =
        asset              = lv_asset
        subnumber          = lv_SUBNUMBER
*       ASSETCREATED       =
        return             = ls_ret2
      TABLES
        depreciationareas  = lt_deparea
        depreciationareasx = lt_depareax.

    IF ls_ret2-type = 'E' OR ls_ret2-type = 'A' OR ls_ret2-type = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
* IMPORTING
*   RETURN        =
        .
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
* IMPORTING
*         RETURN        =
        .
      ev_asset = lv_asset.
      ev_subas = lv_SUBNUMBER.
    ENDIF.
    APPEND ls_ret2 TO bapiret2.
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD post_document.
    TYPES : BEGIN OF ty_file,
              zusr_id(10)         TYPE c,
              zbatch(15)          TYPE c,
              ztran_no(22)        TYPE c,
              zline_no(7)         TYPE c,
              zsp(1)              TYPE c,
              zco(10)             TYPE c,
              zdescriptn(30)      TYPE c,
              zdescriptn2(30)     TYPE c,
              znew(1)             TYPE c,
              zremark(30)         TYPE c,
              zremark2(30)        TYPE c,
              zasset_co_obj(6)    TYPE c,
              zsset_co_sub(8)     TYPE c,
              zacc_cls(3)         TYPE c,
              zst(3)              TYPE c,
              zafe_no(12)         TYPE c,
              zuniqueid(15)       TYPE c,
              zadrs_no(8)         TYPE c,
              zinvoice(25)        TYPE c,
              zinv_date(10)       TYPE c,
              zgross_amnt(15)     TYPE c,
              ztax(15)            TYPE c,
              ztax2(15)           TYPE c,
              zdat_acq(10)        TYPE c,
              zasset_no(18)       TYPE c,
              zusr_code(3)        TYPE c,
              zusr_date(10)       TYPE c,
              zusr_amount(15)     TYPE c,
              zusr_no(8)          TYPE c,
              zusr_ref(15)        TYPE c,
              zusrid(10)          TYPE c,
              zprog(10)           TYPE c,
              zwork_stn(10)       TYPE c,
              zdate_upd(10)       TYPE c,
              ztime_upd(6)        TYPE c,
              zopex_capex_code(5) TYPE c,
              zord43(4)           TYPE c,
              status(7)           TYPE c,
              message(1024)       TYPE c,
            END OF ty_file.

    DATA : lt_file TYPE TABLE OF ty_file,
           ls_file TYPE ty_file.
    DATA : gs_docheader TYPE bapiache09,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           gt_ret       TYPE TABLE OF bapiret2,
           gt_accntgl   TYPE TABLE OF bapiacgl09,
           gs_accntgl   TYPE bapiacgl09,
           gt_accntpay  TYPE TABLE OF bapiacap09,
           gs_accntpay  TYPE bapiacap09,
           gt_curr      TYPE TABLE OF bapiaccr09,
           gs_curr      TYPE bapiaccr09,
           gt_accntax   TYPE TABLE OF bapiactx09,
           gs_accntax   TYPE bapiactx09,
           gs_ret       TYPE bapiret2,
           lv_fyear     TYPE bapi0002_4-fiscal_year,
           lv_period    TYPE bapi0002_4-fiscal_period,
           lt_data      TYPE zfitt_ramp_acc_pay,
           lv_ANLN1     TYPE anln1,
           lv_anln2     TYPE anln2,
           gt_bapiret2  TYPE bapiret2_tt,
           lv_item      TYPE posnr_acc,
           er_data      TYPE TABLE OF zfis_ramp_acc_pay,
           lv_go        TYPE c.
    DATA: lv_xblnr      TYPE xblnr1.
    DATA: lv_err_msg(1024) TYPE c.
    DATA: lv_prctr_out  TYPE prctr,
          lv_prctr_file TYPE prctr.

    DATA: lv_payamt TYPE bapidoccur.
    DATA: ls_alv_output TYPE zfis_ramp_acc_pay_alv.


    REFRESH er_data.
    lt_file = gt_file.
    SORT gt_data BY inv_key bukrs.
    LOOP AT gt_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
      CLEAR: ls_alv_output.
      MOVE-CORRESPONDING ls_data TO ls_alv_output.
      IF ls_data-xblnr EQ lv_xblnr AND lv_go EQ 'X'.
        ls_alv_output-message = lv_err_msg.
        ls_alv_output-status = 'Error'.
      ELSE.
        CLEAR: lv_go, lv_msg1, lv_err_msg.
      ENDIF.
      lv_xblnr = ls_data-xblnr.
      REFRESH lt_data.
      IF ls_data-prctr IS NOT INITIAL.
        SELECT SINGLE prctr FROM cepc INTO @DATA(lv_prtmp) WHERE prctr = @ls_data-prctr.
        IF sy-subrc NE 0.
          SELECT SINGLE kostl FROM csks INTO @DATA(lv_kostmp) WHERE kostl = @ls_data-prctr.
          IF sy-subrc NE 0.
            lv_go = 'X'.
            CONCATENATE 'Profit center/Cost center '   ls_data-prctr ' is invalid'  INTO lv_msg1 SEPARATED BY space.
          ENDIF.
        ENDIF.
      ELSEIF ls_data-bukrs IS INITIAL.
        CONCATENATE 'Profit Center ' ls_data-prctr 'is invalid' INTO lv_msg1 SEPARATED BY space.
        lv_go = 'X'.
      ENDIF.
*      ENDIF.
      IF ls_data-hkont IS NOT INITIAL.
        SELECT SINGLE saknr FROM ska1 INTO @DATA(lv_saknr) WHERE saknr = @ls_data-hkont.
        IF sy-subrc NE 0.
          CONCATENATE 'GL account' ls_data-hkont 'is invalid' INTO lv_msg1 SEPARATED BY space.
          lv_go = 'X'.
        ENDIF.
      ELSEIF ls_data-hkont IS INITIAL.
        CONCATENATE 'G/L account is blank' ' ' INTO lv_msg1 SEPARATED BY space.
        lv_go = 'X'.
      ENDIF.
      IF lv_go IS INITIAL.
*SELECT SINGLE bukrs FROM CEPC INTO @data(lv_bukrs) WHERE prctr =
        AT NEW bukrs.

          CLEAR  : lv_item, gs_docheader, lv_payamt.
          REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr.
          gs_docheader-obj_type = 'BKPFF'.
          gs_docheader-bus_act = 'RFBU'.
          gs_docheader-username = sy-uname.
          gs_docheader-comp_code = ls_data-bukrs.
          gs_docheader-doc_date = ls_data-bldat.
          gs_docheader-pstng_date = ls_data-budat.
          gs_docheader-doc_type =  iv_doctyp. "ls_data-blart.
          gs_docheader-ref_doc_no  = ls_data-xblnr.
          gs_docheader-header_txt = ls_data-bktxt.
          lv_item = 1.

          CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
            EXPORTING
              companycodeid = ls_data-bukrs
              posting_date  = ls_data-budat
            IMPORTING
              fiscal_year   = lv_fyear
              fiscal_period = lv_period
*             RETURN        =
            .
          gs_docheader-fisc_year = lv_fyear.
          gs_docheader-fis_period = lv_period.

          ""ACCOUNTPAYABLE
          gs_accntpay-itemno_acc  = lv_item. "'0000000001'.
          gs_accntpay-vendor_no = |{ ls_data-lifnr ALPHA = IN }|.
*      gs_accntpay-acct_type = 'K'.
*      gs_accntpay-profit_ctr = 'PS_CORP'.
          IF ls_data-dmbtr LE iv_threhold.
            gs_accntpay-alloc_nmbr = ls_data-zuonr.
          ELSE.
            gs_accntpay-alloc_nmbr = ls_data-zafe.
          ENDIF.
          gs_accntpay-item_text = ls_data-ztext.
          APPEND gs_accntpay TO gt_accntpay.
          CLEAR gs_accntpay.
        ENDAT.
*** Fill amount for account payable
        lv_payamt = lv_payamt + ls_data-dmbtr.
        ""Asset # mandatory for CAPEX if the dollar amount exceeds the threshold
        IF ls_data-capex = 'X'.
          IF ls_data-dmbtr LE iv_threhold.
            APPEND ls_data TO lt_data.
            ""Create asset number
            DATA(lo_asset) = NEW zcl_fi_ramp_accnt_pay( ).
            CALL METHOD lo_asset->create_asset_master
              EXPORTING
                gt_data   = lt_data
                asset_auc = asset_auc
              IMPORTING
                bapiret2  = gt_bapiret2
                ev_asset  = lv_anln1
                ev_subas  = lv_anln2.
            IF lv_anln1 IS INITIAL AND gt_bapiret2 IS NOT INITIAL.
              READ TABLE gt_bapiret2 ASSIGNING FIELD-SYMBOL(<lfs_bapiret2>) WITH KEY type = 'E'.
              IF sy-subrc EQ 0.
                CONCATENATE  TEXT-001 <lfs_bapiret2>-message INTO ls_alv_output-message SEPARATED BY ' : '.
                ls_alv_output-status = 'Error'.
*                APPEND ls_alv_output TO ct_alv_output.
                lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
                LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file>) WHERE  zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr .
                  lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
                  IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
                    <fs_file>-status = ls_alv_output-status.
                    <fs_file>-message = ls_alv_output-message.
                  ENDIF.
                ENDLOOP.
                LOOP AT ct_alv_output ASSIGNING FIELD-SYMBOL(<fs_alv_output>) WHERE xblnr = ls_data-xblnr
                                                                              AND bukrs = ls_data-bukrs.
                  <fs_alv_output>-status = ls_alv_output-status.
                  <fs_alv_output>-message = ls_alv_output-message.
                ENDLOOP.
                lv_err_msg = ls_alv_output-message.
                lv_go = 'X'.
              ELSE.
                READ TABLE gt_bapiret2 ASSIGNING <lfs_bapiret2> WITH KEY type = 'A'.
                IF sy-subrc EQ 0.
                  CONCATENATE  TEXT-001 <lfs_bapiret2>-message INTO ls_alv_output-message SEPARATED BY ' : '.
                  ls_alv_output-status = 'Error'.
*                  APPEND ls_alv_output TO ct_alv_output.
                  lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
                  LOOP AT lt_file ASSIGNING <fs_file>  WHERE  zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr .
                    lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
                    IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
                      <fs_file>-status = ls_alv_output-status.
                      <fs_file>-message = ls_alv_output-message.
                    ENDIF.
                  ENDLOOP.
                  LOOP AT ct_alv_output ASSIGNING <fs_alv_output> WHERE xblnr = ls_data-xblnr
                                                                      AND bukrs = ls_data-bukrs.
                    <fs_alv_output>-status = ls_alv_output-status.
                    <fs_alv_output>-message = ls_alv_output-message.
                  ENDLOOP.
                  lv_err_msg = ls_alv_output-message.
                  lv_go = 'X'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

        IF lv_go NE 'X'.
          ""*ACCOUNTGL
          gs_accntgl-itemno_acc = lv_item + 1. "'0000000002'.
          gs_accntgl-gl_account = ls_data-hkont.  ""logic to identify OPEX and CAPEX accounts
          gs_accntgl-item_text = ls_data-ztext.
          IF ls_data-capex = 'X' AND ls_data-dmbtr LE iv_threhold.
*        BREAK-POINT.
            gs_accntgl-acct_type = 'A'."only if the invoice is to be posted to an Asset (CAPEX transactions that are within the threshold defined
            gs_accntgl-asset_no = lv_anln1.  ""'000090000001
            gs_accntgl-sub_number = lv_anln2.
            gs_accntgl-cs_trans_t = '100'.
            gs_accntgl-acct_key = 'ANL'.
          ENDIF.
          gs_accntgl-alloc_nmbr = ls_data-zuonr.
          IF ls_data-mwsts IS NOT INITIAL.
            gs_accntgl-tax_code = 'E1'.
            gs_accntgl-taxjurcode = 'CA00000000'.
*        gs_accntgl-itemno_tax = '000001'.
          ENDIF.
          IF ls_data-opex = 'X' OR gs_accntgl-acct_type NE 'A'.
            SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
            IF sy-subrc EQ 0.
              gs_accntgl-costcenter = lv_kostl.
              gs_accntgl-profit_ctr  = ls_data-prctr.
            ELSE.
              SELECT SINGLE prctr INTO @DATA(lv_prctr) FROM csks WHERE kokrs = 'PSCO' AND kostl = @ls_data-prctr.
              IF sy-subrc EQ 0.
                gs_accntgl-costcenter = ls_data-prctr.
                gs_accntgl-profit_ctr  = lv_prctr.
              ENDIF.
            ENDIF.
          ELSEIF ls_data-capex  = 'X'.
            SELECT SINGLE kostl INTO lv_kostl FROM csks WHERE kokrs = 'PSCO' AND kostl = ls_data-prctr.
            IF sy-subrc EQ 0.
              gs_accntgl-costcenter = lv_kostl.
            ENDIF.
          ENDIF.
          gs_accntgl-comp_code = ls_data-bukrs.
*          gs_accntgl-profit_ctr  = ls_data-prctr.
          CLEAR: lv_kostl, lv_prctr.
          ""asset # created in the program, only needed if ACCT_TYPE is “A”
*       gs_accntgl-ASSET_NO  = ls_data-ANLN1.
          APPEND gs_accntgl TO gt_accntgl.
          CLEAR gs_accntgl.
          IF ls_data-mwsts IS NOT INITIAL.
            "ACCOUNTTAX
            gs_accntax-itemno_acc  = lv_item + 2. "'0000000003'.
*        gs_accntax-gl_account  = iv_taxgl.
            gs_accntax-cond_key = 'JP1I'.
            gs_accntax-acct_key = 'NVV'.
            gs_accntax-tax_code = 'E1'.
            gs_accntax-taxjurcode = 'CA00000000'.
*        gs_accntax-itemno_tax = '000001'.
            APPEND gs_accntax TO gt_accntax.
            CLEAR gs_accntax.

            gs_curr-itemno_acc =  lv_item + 2. "'0000000003'.
            gs_curr-currency = 'USD'.
            gs_curr-amt_doccur = ls_data-mwsts.
            gs_curr-amt_base = ls_data-dmbtr - ls_data-mwsts.
*  AMT_BASE = ??
*      gs_curr-tax_amt = ls_data-mwsts.
            APPEND gs_curr TO gt_curr.
            CLEAR gs_curr.
          ENDIF.
*        ""Currency amounts
*        gs_curr-itemno_acc = lv_item.
*        gs_curr-currency = 'USD'.
*        gs_curr-amt_doccur = ls_data-dmbtr * -1.
*        gs_curr-amt_base = ( ls_data-dmbtr - ls_data-mwsts ) * -1.
**  AMT_BASE = ??
** gs_curr-TAX_AMT = ls_data-MWSTS.
*        APPEND gs_curr TO gt_curr.
*        CLEAR gs_curr.

          gs_curr-itemno_acc = lv_item + 1.
          gs_curr-currency = 'USD'.
          gs_curr-amt_doccur = ls_data-dmbtr.
          gs_curr-amt_base = ( ls_data-dmbtr - ls_data-mwsts ).
*  AMT_BASE = ??
*      gs_curr-tax_amt = ls_data-mwsts.
          APPEND gs_curr TO gt_curr.
          CLEAR gs_curr.
          AT END OF bukrs.

            ""Currency amounts
            gs_curr-itemno_acc = '0000000001'.
            gs_curr-currency = 'USD'.
            gs_curr-amt_doccur = lv_payamt * -1.
            gs_curr-amt_base = ( lv_payamt - ls_data-mwsts ) * -1.
*  AMT_BASE = ??
* gs_curr-TAX_AMT = ls_data-MWSTS.
            APPEND gs_curr TO gt_curr.
            CLEAR gs_curr.

            SORT gt_curr BY itemno_acc ASCENDING.

            CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
              EXPORTING
                documentheader = gs_docheader
*               CUSTOMERCPD    =
*               CONTRACTHEADER =
* IMPORTING
*               OBJ_TYPE       =
*               OBJ_KEY        =
*               OBJ_SYS        =
              TABLES
                accountgl      = gt_accntgl
*               ACCOUNTRECEIVABLE       =
                accountpayable = gt_accntpay
                accounttax     = gt_accntax
                currencyamount = gt_curr
*               CRITERIA       =
*               VALUEFIELD     =
*               EXTENSION1     =
                return         = gt_ret
*               PAYMENTCARD    =
*               CONTRACTITEM   =
*               EXTENSION2     =
*               REALESTATE     =
*               ACCOUNTWT      =
              .
            READ TABLE gt_ret INTO DATA(ls_ret) WITH KEY type = 'E'.
            IF sy-subrc EQ 0..
              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
* IMPORTING
*   RETURN        =
                .
              APPEND ls_data TO er_data.
              CLEAR : lv_msg, lv_msg1.
              LOOP AT gt_ret INTO ls_ret WHERE type = 'E'.
                CALL FUNCTION 'FORMAT_MESSAGE'
                  EXPORTING
                    id        = ls_ret-id
                    lang      = sy-langu
                    no        = ls_ret-number
                    v1        = ls_ret-message_v1
                    v2        = ls_ret-message_v2
                    v3        = ls_ret-message_v3
                    v4        = ls_ret-message_v4
                  IMPORTING
                    msg       = lv_msg1
                  EXCEPTIONS
                    not_found = 1
                    OTHERS    = 2.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ENDIF.
                IF lv_msg IS NOT INITIAL.
                  CONCATENATE  lv_msg1 ' / ' lv_msg INTO lv_msg SEPARATED BY space.
                ELSE.
                  lv_msg = lv_msg1.
                ENDIF.
                CLEAR : ls_ret, lv_msg1.
              ENDLOOP.
*          LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file>) WHERE zinvoice = ls_data-xblnr.
*            <fs_file>-error = lv_msg.
*          ENDLOOP.
*** ALV Output Message
              ls_alv_output-status = 'Error'.
              CONCATENATE  TEXT-003 lv_msg INTO ls_alv_output-message SEPARATED BY ' : '.
              lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
              LOOP AT lt_file ASSIGNING <fs_file> WHERE  zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr .
                lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
                IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
                  <fs_file>-status = ls_alv_output-status.
                  <fs_file>-message = ls_alv_output-message.
                ENDIF.
              ENDLOOP.
              LOOP AT ct_alv_output ASSIGNING <fs_alv_output> WHERE xblnr = ls_data-xblnr
                                                                  AND bukrs = ls_data-bukrs.
                <fs_alv_output>-status = ls_alv_output-status.
                <fs_alv_output>-message = ls_alv_output-message.
              ENDLOOP.
*          ls_alv_output-message = lv_msg.
            ELSE.
              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                EXPORTING
                  wait = abap_true
* IMPORTING
*                 RETURN        =
                .
              CLEAR : lv_msg, lv_msg1.
              LOOP AT gt_ret INTO ls_ret.
                CALL FUNCTION 'FORMAT_MESSAGE'
                  EXPORTING
                    id        = ls_ret-id
                    lang      = sy-langu
                    no        = ls_ret-number
                    v1        = ls_ret-message_v1
                    v2        = ls_ret-message_v2
                    v3        = ls_ret-message_v3
                    v4        = ls_ret-message_v4
                  IMPORTING
                    msg       = lv_msg1
                  EXCEPTIONS
                    not_found = 1
                    OTHERS    = 2.
                IF sy-subrc <> 0.
* Implement suitable error handling here
                ENDIF.
                IF lv_msg IS NOT INITIAL.
                  CONCATENATE  lv_msg1 ' / ' lv_msg INTO lv_msg SEPARATED BY space.
                ELSE.
                  lv_msg = lv_msg1.
                ENDIF.
                CLEAR : ls_ret, lv_msg1.
              ENDLOOP.
*          LOOP AT lt_file ASSIGNING <fs_file> WHERE zinvoice = ls_data-xblnr.
*            <fs_file>-error = lv_msg.
*          ENDLOOP.
*** ALV Output Message
              ls_alv_output-status = 'Success'.
              ls_alv_output-message = lv_msg.
              lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
              LOOP AT lt_file ASSIGNING <fs_file> WHERE  zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr .
                lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
                IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
                  <fs_file>-status = ls_alv_output-status.
                  <fs_file>-message = ls_alv_output-message.
                ENDIF.
              ENDLOOP.
              LOOP AT ct_alv_output ASSIGNING <fs_alv_output> WHERE xblnr = ls_data-xblnr
                                                              AND bukrs = ls_data-bukrs.
                <fs_alv_output>-status = ls_alv_output-status.
                <fs_alv_output>-message = ls_alv_output-message.
              ENDLOOP.
            ENDIF.
            LOOP AT gt_ret INTO ls_ret WHERE type NE 'A'.
              CLEAR gs_ret.
              gs_ret = CORRESPONDING #( ls_ret ).
              APPEND gs_ret TO bapiret2.
            ENDLOOP.
            CLEAR  : lv_item, gs_docheader, lv_payamt.
            REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr.
          ENDAT.
        ELSE.
*** ALV Output Message
*        ls_alv_output-message = lv_msg1.
*        LOOP AT lt_file ASSIGNING <fs_file> WHERE zinvoice = ls_data-xblnr.
*          <fs_file>-error = lv_msg1.
*        ENDLOOP.
          lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
          LOOP AT lt_file ASSIGNING <fs_file> WHERE  zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr .
            lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
            IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
              <fs_file>-status = ls_alv_output-status.
              <fs_file>-message = ls_alv_output-message.
            ENDIF.
          ENDLOOP.
          LOOP AT ct_alv_output ASSIGNING <fs_alv_output> WHERE xblnr = ls_data-xblnr
                                                              AND bukrs = ls_data-bukrs.
            <fs_alv_output>-status = ls_alv_output-status.
            <fs_alv_output>-message = ls_alv_output-message.
          ENDLOOP.
          lv_err_msg = ls_alv_output-message.
          lv_go = 'X'.
          CLEAR gs_ret.
          gs_ret-type = 'E'.
          gs_ret-message = lv_msg1.
          gs_ret-log_no = ls_data-xblnr.
          APPEND gs_ret TO bapiret2.
          CLEAR : gs_ret, lv_msg1.
        ENDIF.
      ELSE.
*** ALV Output Message
        ls_alv_output-status = 'Error'.
        CONCATENATE TEXT-002 lv_msg1 INTO ls_alv_output-message SEPARATED BY ' : '.
*        ls_alv_output-message = lv_msg1.
*        LOOP AT lt_file ASSIGNING <fs_file> WHERE zinvoice = ls_data-xblnr.
*          <fs_file>-error = lv_msg1.
*        ENDLOOP.
        lv_prctr_out = |{ ls_data-prctr ALPHA = OUT  }|.
        LOOP AT lt_file ASSIGNING <fs_file> WHERE zinvoice = ls_data-xblnr OR zinvoice+0(16) = ls_data-xblnr.
          lv_prctr_file  = |{ <fs_file>-zco ALPHA = OUT  }|.
          IF lv_prctr_file EQ lv_prctr_out.
*                                                  AND zasset_co_obj = ls_data-hkont
*                                                  AND zasset_no = ls_data-sernr.
            <fs_file>-status = ls_alv_output-status.
            <fs_file>-message = ls_alv_output-message.
          ENDIF.
        ENDLOOP.
        LOOP AT ct_alv_output ASSIGNING <fs_alv_output> WHERE xblnr = ls_data-xblnr
                                                                    AND bukrs = ls_data-bukrs.
          <fs_alv_output>-status = ls_alv_output-status.
          <fs_alv_output>-message = ls_alv_output-message.
        ENDLOOP.
        lv_err_msg = ls_alv_output-message.
        lv_go = 'X'.
        CLEAR gs_ret.
        gs_ret-type = 'E'.
        gs_ret-message = lv_msg1.
        gs_ret-log_no = ls_data-xblnr.
        APPEND gs_ret TO bapiret2.
        CLEAR : gs_ret, lv_msg1.
      ENDIF.
*      CLEAR  : lv_item, gs_docheader.
*      REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr.
*      lv_item = 1.
****create ALV output data
      APPEND ls_alv_output TO ct_alv_output.
*      CLEAR: ls_alv_output.
*      LOOP AT lt_file ASSIGNING FIELD-SYMBOL(<fs_file_ml>) WHERE zinvoice = ls_data-xblnr.
*        <fs_file_ml>-error = lv_msg.
*      ENDLOOP.
*      IF sy-subrc = 0.

*          CONCATENATE  TEXT-001 <lfs_bapiret2>-message INTO ls_alv_output-message SEPARATED BY ' : '.
      lv_item = lv_item + 1.
    ENDLOOP.
*    DELETE lt_file WHERE error = space.
*    IF lt_file IS NOT INITIAL.
*      DATA(lr_mail) = NEW zcl_fi_ramp_accnt_pay( ).
*
*      CALL METHOD lr_mail->send_mail
*        EXPORTING
*          gt_data     = er_data
*          gt_file     = lt_file
*          ev_dl       = ev_dl
*          ev_filetype = ev_filetype.
*
*    ENDIF.
    LOOP AT lt_file ASSIGNING <fs_file> WHERE status EQ ' '.
      lv_prctr_file  = |{ <fs_file>-zco ALPHA = IN }|.
      READ TABLE ct_alv_output ASSIGNING <fs_alv_output> WITH KEY prctr = lv_prctr_file
                                                            xblnr  = <fs_file>-zinvoice.
      IF sy-subrc EQ 0.
        <fs_file>-status = <fs_alv_output>-status.
        <fs_file>-message = <fs_alv_output>-message.
      ENDIF.

    ENDLOOP.
    gt_file = lt_file.


  ENDMETHOD.


  METHOD send_mail.
    TYPES : BEGIN OF ty_file,
              zusr_id(10)         TYPE c,
              zbatch(15)          TYPE c,
              ztran_no(22)        TYPE c,
              zline_no(7)         TYPE c,
              zsp(1)              TYPE c,
              zco(10)             TYPE c,
              zdescriptn(30)      TYPE c,
              zdescriptn2(30)     TYPE c,
              znew(1)             TYPE c,
              zremark(30)         TYPE c,
              zremark2(30)        TYPE c,
              zasset_co_obj(6)    TYPE c,
              zsset_co_sub(8)     TYPE c,
              zacc_cls(3)         TYPE c,
              zst(3)              TYPE c,
              zafe_no(12)         TYPE c,
              zuniqueid(15)       TYPE c,
              zadrs_no(8)         TYPE c,
              zinvoice(25)        TYPE c,
              zinv_date(10)       TYPE c,
              zgross_amnt(15)     TYPE c,
              ztax(15)            TYPE c,
              ztax2(15)           TYPE c,
              zdat_acq(10)        TYPE c,
              zasset_no(18)       TYPE c,
              zusr_code(3)        TYPE c,
              zusr_date(10)       TYPE c,
              zusr_amount(15)     TYPE c,
              zusr_no(8)          TYPE c,
              zusr_ref(15)        TYPE c,
              zusrid(10)          TYPE c,
              zprog(10)           TYPE c,
              zwork_stn(10)       TYPE c,
              zdate_upd(10)       TYPE c,
              ztime_upd(6)        TYPE c,
              zopex_capex_code(5) TYPE c,
              zord43(4)           TYPE c,
              status(7)           TYPE c,
              message(1024)       TYPE c,
            END OF ty_file.


    DATA : lt_file TYPE TABLE OF ty_file,
           ls_file TYPE ty_file.

    lt_file[] = gt_file[].
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
*** Remove any special symbols in start of text
      IF <fs_scs>-zdescriptn IS NOT INITIAL.
        lv_length = strlen( <fs_scs>-zdescriptn ).
        DO lv_length TIMES.
          IF <fs_scs>-zdescriptn+lv_index(1) CA 'ABCDEFGHIJKHLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 '.
            EXIT.
          ELSE.
            SHIFT <fs_scs>-zdescriptn BY sy-index PLACES.
          ENDIF.
        ENDDO.
      ENDIF.
      IF <fs_scs>-zremark IS NOT INITIAL.
        lv_length = strlen( <fs_scs>-zremark ).
        DO lv_length TIMES.
          IF <fs_scs>-zremark+lv_index(1) CA 'ABCDEFGHIJKHLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 '.
            EXIT.
          ELSE.
            SHIFT <fs_scs>-zremark BY sy-index PLACES.
          ENDIF.
        ENDDO.
      ENDIF.
      IF <fs_scs>-zdescriptn2 IS NOT INITIAL.
        lv_length = strlen( <fs_scs>-zdescriptn2 ).
        DO lv_length TIMES.
          IF <fs_scs>-zdescriptn2+lv_index(1) CA 'ABCDEFGHIJKHLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 '.
            EXIT.
          ELSE.
            SHIFT <fs_scs>-zdescriptn2 BY sy-index PLACES.
          ENDIF.
        ENDDO.
      ENDIF.
      IF <fs_scs>-zremark2 IS NOT INITIAL.
        lv_length = strlen( <fs_scs>-zremark2 ).
        DO lv_length TIMES.
          IF <fs_scs>-zremark2+lv_index(1) CA 'ABCDEFGHIJKHLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 '.
            EXIT.
          ELSE.
            SHIFT <fs_scs>-zremark2 BY sy-index PLACES.
          ENDIF.
        ENDDO.
      ENDIF.
      CONCATENATE l_text
        gc_qc <fs_scs>-zusr_id gc_qc gc_tab
        gc_qc <fs_scs>-zbatch gc_qc gc_tab
        gc_qc <fs_scs>-ztran_no gc_qc gc_tab
        gc_qc <fs_scs>-zline_no gc_qc gc_tab
        gc_qc <fs_scs>-zsp gc_qc gc_tab
        gc_qc <fs_scs>-zco gc_qc gc_tab
        gc_qc <fs_scs>-zdescriptn gc_qc gc_tab
        gc_qc <fs_scs>-zdescriptn2 gc_qc gc_tab
        gc_qc <fs_scs>-znew gc_qc gc_tab
        gc_qc <fs_scs>-zremark gc_qc gc_tab
        gc_qc <fs_scs>-zremark2 gc_qc gc_tab
        gc_qc <fs_scs>-zasset_co_obj gc_qc gc_tab
        gc_qc <fs_scs>-zsset_co_sub gc_qc gc_tab
        gc_qc <fs_scs>-zacc_cls gc_qc gc_tab
        gc_qc <fs_scs>-zst gc_qc gc_tab
        gc_qc <fs_scs>-zafe_no gc_qc gc_tab
        gc_qc <fs_scs>-zuniqueid gc_qc gc_tab
        gc_qc <fs_scs>-zadrs_no gc_qc gc_tab
        gc_qc <fs_scs>-zinvoice gc_qc gc_tab
        gc_qc <fs_scs>-zinv_date gc_qc gc_tab
        gc_qc <fs_scs>-zgross_amnt gc_qc gc_tab
        gc_qc <fs_scs>-ztax gc_qc gc_tab
        gc_qc <fs_scs>-ztax2 gc_qc gc_tab
        gc_qc <fs_scs>-zdat_acq gc_qc gc_tab
        gc_qc <fs_scs>-zasset_no gc_qc gc_tab
        gc_qc <fs_scs>-zusr_code gc_qc gc_tab
        gc_qc <fs_scs>-zusr_date gc_qc gc_tab
        gc_qc <fs_scs>-zusr_amount gc_qc gc_tab
        gc_qc <fs_scs>-zusr_no gc_qc gc_tab
        gc_qc <fs_scs>-zusr_ref gc_qc gc_tab
        gc_qc <fs_scs>-zusrid gc_qc gc_tab
        gc_qc <fs_scs>-zprog gc_qc gc_tab
        gc_qc <fs_scs>-zwork_stn gc_qc gc_tab
        gc_qc <fs_scs>-zdate_upd gc_qc gc_tab
        gc_qc <fs_scs>-ztime_upd gc_qc gc_tab
        gc_qc <fs_scs>-zopex_capex_code gc_qc gc_tab
        gc_qc <fs_scs>-zord43 gc_qc gc_tab
        gc_qc <fs_scs>-status gc_qc gc_tab
        <fs_scs>-message gc_crlf
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
**     -------- create persistent send request ------------------------
*        send_request = cl_bcs=>create_persistent( ).
**     create document object from internal table with text
*        ls_body-line = 'Hi,'.
*        APPEND ls_body TO lt_body.
*        CLEAR: ls_body.
*        ls_body-line = 'This is system generated email for RAMP to SAP Error Log'.
*        APPEND ls_body TO lt_body.
*        CLEAR: ls_body.
*        APPEND 'RAMP to S4 postings status' TO main_text.   "#EC NOTEXT
*        document = cl_document_bcs=>create_document(
*          i_type    = 'RAW'
**          i_text    = main_text
*i_text    = lt_body
*          i_subject = 'RAMP to S4 postings status' ).       "#EC NOTEXT

*        lv_view = 'Ramp File Data'.


***   To Convert the valid from and to date
        CONCATENATE 'Ramp to SAP File - ' sy-datum+4(2) '/' sy-datum+6(2) '/'
         sy-datum+0(4) lv_view INTO lv_subject.

* Subject.
        lt_mailsubject-obj_name = 'Ramp to SAP File'.
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

        CONCATENATE ls_mailtxt 'Here is the INT0112 RAMP to S4 interface status with file attachment for your review and reprocess error records if required any.'
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

        lv_filename = 'Ramp to SAP File.csv'.
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

        lv_attach_sub = 'RAMP_TO_SAP_FILE'.
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
        i_dliname = ev_dl
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

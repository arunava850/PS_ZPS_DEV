class ZCL_FI_EBUILDR_S4_ACCPAY definition
  public
  final
  create public .

public section.

  methods CREATE_ASSET
    importing
      value(ET_DATA) type ZFIT_EBUILDR_S4_ACCPAY
      value(EV_ANLKL) type ANLKL optional
      value(EV_SUB) type CHAR1 optional
    exporting
      value(IV_ANLN1) type ANLN1
      value(IT_RET2) type BAPIRET2_T
      value(IV_SUBASSET) type BAPI1022_1-ASSETSUBNO .
  methods POST_DOCUMENT
    importing
      value(ET_DATA) type ZFIT_EBUILDR_S4_ACCPAY
      value(EV_ANLKL) type ANLKL optional
      value(ET_FILE) type STANDARD TABLE optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
    exporting
      value(IT_RET2) type BAPIRET2_T .
  methods SEND_MAIL
    importing
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(ET_DATA) type STANDARD TABLE optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_EBUILDR_S4_ACCPAY IMPLEMENTATION.


  METHOD create_asset.
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
           lt_deparea  TYPE TABLE OF bapi1022_dep_areas,
           ls_deparea  TYPE bapi1022_dep_areas,
           lt_depareax TYPE TABLE OF bapi1022_dep_areasx,
           ls_depareax TYPE bapi1022_dep_areasx,
           lv_hkont    TYPE hkont,
           lv_anlkl    TYPE anlkl.

    READ TABLE et_data INTO DATA(ls_data) INDEX 1.

    ""Get the Account Determination from table T095 based on COA = PSUS, Dep Area = 01 and Bal.Sh.Acct APC = GL #

*    SELECT SINGLE  ktogr FROM t095 INTO @DATA(lv_ktogr) WHERE ktopl = 'PSUS' AND afabe = '01' AND ktansw = @ls_data-hkont.
*    IF sy-subrc EQ 0.
    " Based on Account Determiination get the Asset Class from table ANKA
*    SELECT SINGLE anlkl FROM anka INTO @DATA(lv_anlkl) WHERE anlkl = @ls_data-hkont. "ktogr = @lv_ktogr.
*      IF sy-subrc EQ 0.
    SELECT SINGLE kostl FROM csks INTO @DATA(lv_kostl) WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
    IF sy-subrc NE 0.
      DATA(lv_prctr) = |{ ls_data-prctr ALPHA = IN }|.
      SELECT SINGLE kostl FROM csks INTO lv_kostl WHERE kokrs = 'PSCO' AND prctr = lv_prctr.
    ENDIF.

    CLEAR : ls_key, lv_hkont,lv_anlkl.
    ls_key-companycode = ls_data-bukrs.
    ls_key-asset = ls_data-zuonr.
*BREAK-POINT.
    lv_hkont = |{ ls_data-hkont ALPHA = OUT }|.
    lv_anlkl = lv_hkont.
*    IF ls_data-cost_code CS 'D'.
    ls_gen-assetclass = |{ lv_anlkl ALPHA = IN }|.
*    ELSE.
*      ls_gen-assetclass = ls_data-hkont.
*    ENDIF.
    ls_origin-type_name = ls_data-cost_code.
    ls_originx-type_name = 'X'.

    ls_gen-descript = ls_data-text50."ls_data-bktxt.
*        ls_gen-acct_detrm = lv_ktogr.
    ls_time-profit_ctr = ls_data-prctr.
    lv_anlkl = |{ ls_gen-assetclass ALPHA = OUT }|.
    IF lv_anlkl(1) NE 3.
      IF lv_kostl IS NOT INITIAL.
        ls_time-costcenter = lv_kostl.  ""ls_data-costctr+2(8). "
        ls_timex-costcenter = 'X'.
      ENDIF.
    ENDIF.
*ls_time-FROM_DATE = sy-datum.
*ls_time-to_date = '20231231'.

    ls_timex-profit_ctr = 'X'.

*ls_timex-FROM_DATE = 'X'.
*ls_timex-to_date = 'X'.

    ls_genx-assetclass = abap_true.
    ls_genx-descript = abap_true.
*        ls_genx-acct_detrm = abap_true.

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
        createsubnumber    = ev_sub
*       POSTCAP            =
*       CREATEGROUPASSET   =
*       TESTRUN            =
        generaldata        = ls_gen
        generaldatax       = ls_genx
*       INVENTORY          =
*       INVENTORYX         =
*       POSTINGINFORMATION =
*       POSTINGINFORMATIONX        =
        timedependentdata  = ls_time
        timedependentdatax = ls_timex
*       ALLOCATIONS        =
*       ALLOCATIONSX       =
        origin             = ls_origin
        originx            = ls_originx
      IMPORTING
*       COMPANYCODE        =
        asset              = lv_asset
        subnumber          = lv_subasset
*       ASSETCREATED       =
        return             = ls_ret2
      TABLES
        depreciationareas  = lt_deparea
        depreciationareasx = lt_depareax
*       INVESTMENT_SUPPORT =
*       EXTENSIONIN        =
      .
    IF ls_ret2-type = 'E' OR ls_ret2-type = 'A' OR ls_ret2-type = 'X'.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
* IMPORTING
*   RETURN        =
        .
      iv_anln1 = ls_key-asset.
      IF ev_sub = 'X'.
        iv_subasset = lv_subasset.
      ELSE.
        iv_subasset = '0000'.
      ENDIF.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
* IMPORTING
*         RETURN        =
        .
      iv_anln1 = lv_asset.
      iv_subasset = lv_subasset.
    ENDIF.
    APPEND ls_ret2 TO it_ret2.
    CLEAR : ls_key, ls_gen, ls_genx, ls_origin, ls_originx.

  ENDMETHOD.


  METHOD post_document.
    TYPES : BEGIN OF ty_file,
              ediuser(10)     TYPE c,
              edibatch(15)    TYPE c,
              tranno(10)      TYPE c,
              lineno(10)      TYPE c,
              sccess_prc(1)   TYPE c,
              costctr(10)     TYPE c,
              job_no(18)      TYPE c,
              co_num(10)      TYPE c,
              commit_no(25)   TYPE c,
              inv_no(100)     TYPE c,
              inv_dat(10)     TYPE c,
              inv_itm_des(50) TYPE c,
              net_payinv(25)  TYPE c,
              cost_code(10)   TYPE c,
              subledg(10)     TYPE c,
              subtype(1)      TYPE c,
              net_payline(25) TYPE c,
              pr_cntr(10)     TYPE c,
              usr_id(10)      TYPE c,
              pgm_id(10)      TYPE c,
              wk_id(10)       TYPE c,
              date_xprt(10)   TYPE c,
              compno(10)      TYPE c,
              commit_item(10) TYPE c,
              error           TYPE string,
            END OF ty_file.

    DATA : gt_error_temp TYPE TABLE OF ty_file,
           gt_error      TYPE TABLE OF ty_file,
           gs_error      TYPE ty_file,
           lv_msg        TYPE string,
           lv_msg1       TYPE string.
    DATA : gs_docheader TYPE bapiache09,
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
           lt_data      TYPE zfit_ebuildr_s4_accpay,
           lv_anln1     TYPE anln1,
           gt_bapiret2  TYPE bapiret2_tt,
           lv_subasset  TYPE bapi1022_1-assetsubno,
           lv_item      TYPE posnr_acc,
           lv_key       TYPE char42,
           lv_chk       TYPE c,
           lv_prctr     TYPE prctr,
           lv_hkont     TYPE hkont,
           lv_anlkl     TYPE anlkl.

*    gt_error_temp = CORRESPONDING #( et_file ).
*    DELETE gt_error_temp WHERE net_payline = 0.
*    LOOP AT gt_error_temp INTO DATA(ls_error_temp).
*      gs_error = ls_error_temp.
*      gs_error-inv_no = ls_error_temp-inv_no+0(16).
*      append gs_error to gt_error.
*      clear: ls_error_temp, gs_error.
*    ENDLOOP.
    gt_error = CORRESPONDING #( et_file ).
    DELETE gt_error WHERE net_payline = 0.
    SORT et_data BY zkey.
    DATA(lo_asset) = NEW zcl_fi_ebuildr_s4_accpay( ).
    LOOP AT et_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO @DATA(lv_tmp_bukrs) WHERE prctr = @ls_data-prctr.
      IF sy-subrc EQ 0.
*        DATA(lv_hkont_tmp) = |{ ls_data-hkont ALPHA = IN }|.
*        SELECT SINGLE saknr FROM ska1 INTO @DATA(lv_tmp_hkont) WHERE saknr = @lv_hkont_tmp.
*        IF sy-subrc EQ 0.
        REFRESH lt_data.
        CLEAR :  lv_hkont,lv_anlkl.
        lv_hkont = |{ ls_data-hkont ALPHA = OUT }|.
        lv_anlkl = lv_hkont.
        lv_anlkl = |{ lv_anlkl ALPHA = IN }|.
*SELECT SINGLE bukrs FROM CEPC INTO @data(lv_bukrs) WHERE prctr =
        AT NEW zkey.
          lv_prctr = ls_data-prctr.
          gs_docheader-obj_type = 'BKPFF'.
          gs_docheader-bus_act = 'RFBU'.
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
*             RETURN        =
            .
          gs_docheader-fisc_year = lv_fyear.
          gs_docheader-fis_period = lv_period.

          APPEND ls_data TO lt_data.
          IF ls_data-cost_code CS 'D'.
            SELECT SINGLE a~bukrs,
                          a~anln1,
                          a~anln2,
                          a~anlkl,
                          b~prctr
              FROM anla AS a
              INNER JOIN anlz AS b
              ON  a~bukrs = b~bukrs
              AND  a~anln1 = b~anln1
              AND a~anln2 = b~anln2
              INTO @DATA(ls_anla1) WHERE a~bukrs = @ls_data-bukrs
                                         AND a~anlkl = @lv_anlkl
                                         AND a~ldt_date EQ '00000000'
                                         AND b~prctr = @ls_data-prctr
                                         AND b~bdatu  GE @sy-datum.
            "typbz = @ls_data-cost_code.

            IF sy-subrc NE 0.
              CALL METHOD lo_asset->create_asset
                EXPORTING
                  et_data     = lt_data
                  ev_anlkl    = ev_anlkl
                IMPORTING
                  it_ret2     = gt_bapiret2
                  iv_anln1    = lv_anln1
                  iv_subasset = lv_subasset.
            ELSE.
*                SELECT SINGLE * FROM anla INTO ls_anla1 WHERE bukrs = ls_data-bukrs
*                                                              AND anln1 = ls_data-zuonr
*                                                           AND typbz = ls_data-cost_code.
*                IF sy-subrc EQ 0.
              lv_anln1 = ls_anla1-anln1.
              lv_subasset = ls_anla1-anln2.
*                ENDIF.
            ENDIF.
          ELSEIF  ls_data-cost_code CS 'C'.
            CALL METHOD lo_asset->create_asset
              EXPORTING
                et_data     = lt_data
                ev_anlkl    = ev_anlkl
              IMPORTING
                it_ret2     = gt_bapiret2
                iv_anln1    = lv_anln1
                iv_subasset = lv_subasset.
          ENDIF.
          lv_key = ls_data-zkey.
          lv_chk = 'X'.
          ""ACCOUNTPAYABLE
          gs_accntpay-itemno_acc  = lv_item.
          gs_accntpay-vendor_no = |{ ls_data-lifnr ALPHA = IN }|.
          gs_accntpay-alloc_nmbr = ls_data-zuonr.
          gs_accntpay-item_text = ls_data-text50.
*      gs_accntpay-acct_type = 'K'.
*      gs_accntpay-profit_ctr = 'PS_CORP'.
          APPEND gs_accntpay TO gt_accntpay.
          CLEAR gs_accntpay.

          ""Currency amounts
          gs_curr-itemno_acc = lv_item.
          gs_curr-currency = 'USD'.
          gs_curr-amt_doccur = ls_data-znetpayinv * -1.
          gs_curr-amt_base = ls_data-znetpayinv * -1.
* gs_curr-TAX_AMT = ls_data-MWSTS.
          APPEND gs_curr TO gt_curr.
          CLEAR gs_curr.
        ENDAT.
        IF lv_chk IS INITIAL.
          ls_data-prctr = lv_prctr.
          ls_data-bukrs = gs_docheader-comp_code.
          APPEND ls_data TO lt_data.
          IF ls_data-cost_code CS 'D'.
            SELECT SINGLE a~bukrs
                         a~anln1
                         a~anln2
                         a~anlkl
                         b~prctr
             FROM anla AS a
             INNER JOIN anlz AS b
             ON  a~bukrs = b~bukrs
             AND  a~anln1 = b~anln1
             AND a~anln2 = b~anln2
             INTO ls_anla1 WHERE a~bukrs = ls_data-bukrs
                                        AND a~anlkl = lv_anlkl
                                        AND a~ldt_date EQ '00000000'
                                        AND b~prctr = ls_data-prctr
                                        AND b~bdatu  GE sy-datum.
            IF sy-subrc NE 0.
              CALL METHOD lo_asset->create_asset
                EXPORTING
                  et_data     = lt_data
                  ev_anlkl    = ev_anlkl
*                 ev_sub      = 'X'
                IMPORTING
                  it_ret2     = gt_bapiret2
                  iv_anln1    = lv_anln1
                  iv_subasset = lv_subasset.
            ELSE.
**                SELECT SINGLE * FROM anla INTO ls_anla2 WHERE bukrs = ls_data-bukrs
**                                                                     AND anln1 = ls_data-zuonr AND typbz = ls_data-cost_code.
**                IF sy-subrc EQ 0.
*                  lv_anln1 = ls_anla1-anln1.
*                  lv_subasset = ls_anla1-anln2.
**                ELSE.
**                  CALL METHOD lo_asset->create_asset
**                    EXPORTING
**                      et_data     = lt_data
**                      ev_anlkl    = ev_anlkl
**                      ev_sub      = 'X'
**                    IMPORTING
**                      it_ret2     = gt_bapiret2
**                      iv_anln1    = lv_anln1
**                      iv_subasset = lv_subasset.
**                ENDIF.
              lv_anln1 = ls_anla1-anln1.
              lv_subasset = ls_anla1-anln2.
            ENDIF.
          ELSEIF ls_data-cost_code CS 'C'.
            CALL METHOD lo_asset->create_asset
              EXPORTING
                et_data     = lt_data
                ev_anlkl    = ev_anlkl
*               ev_sub      = 'X'
              IMPORTING
                it_ret2     = gt_bapiret2
                iv_anln1    = lv_anln1
                iv_subasset = lv_subasset.
          ENDIF.
        ENDIF.
        ""*ACCOUNTGL "
        gs_accntgl-itemno_acc = lv_item + 1.
        gs_accntgl-gl_account = ls_data-hkont.
*  SELECT
        gs_accntgl-item_text = ls_data-text50.
        IF ls_data-cost_code NS 'P'.
          CLEAR gs_accntgl-gl_account.
          gs_accntgl-gl_account = '0000120200'.
          gs_accntgl-acct_type = 'A'.
          gs_accntgl-asset_no = lv_anln1.
          gs_accntgl-sub_number = lv_subasset.
          gs_accntgl-cs_trans_t = '100'.
          gs_accntgl-acct_key = 'ANL'.
        ENDIF.
        gs_accntgl-alloc_nmbr = ls_data-zuonr.

        SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
        gs_accntgl-costcenter = lv_kostl.
*      ENDIF.

        gs_accntgl-profit_ctr  = ls_data-prctr.

        ""asset # created in the program, only needed if ACCT_TYPE is “A”
*       gs_accntgl-ASSET_NO  = ls_data-ANLN1.
        APPEND gs_accntgl TO gt_accntgl.
        CLEAR gs_accntgl.
*      IF ls_data-mwsts IS NOT INITIAL.
*        "ACCOUNTTAX
*        gs_accntax-itemno_acc  = '0000000003'.
**        gs_accntax-gl_account  = iv_taxgl.
*        gs_accntax-cond_key = 'JP1I'.
*        gs_accntax-acct_key = 'NVV'.
*        gs_accntax-tax_code = 'E1'.
*        gs_accntax-taxjurcode = 'CA00000000'.
**        gs_accntax-itemno_tax = '000001'.
*        APPEND gs_accntax TO gt_accntax.
*        CLEAR gs_accntax.
*
*        gs_curr-itemno_acc = '0000000003'.
*        gs_curr-currency = 'USD'.
*        gs_curr-amt_doccur = ls_data-mwsts.
*        gs_curr-amt_base = ls_data-dmbtr - ls_data-mwsts.
**  AMT_BASE = ??
**      gs_curr-tax_amt = ls_data-mwsts.
*        APPEND gs_curr TO gt_curr.
*        CLEAR gs_curr.
*      ENDIF.


        gs_curr-itemno_acc = lv_item + 1.
        gs_curr-currency = 'USD'.
        gs_curr-amt_doccur = ls_data-znetpayline.
        gs_curr-amt_base =  ls_data-znetpayline .
*  AMT_BASE = ??
*      gs_curr-tax_amt = ls_data-mwsts.
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.
        lv_item = lv_item + 1.
        CLEAR lv_chk.
        AT END OF zkey.
          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = gs_docheader
*             CUSTOMERCPD    =
*             CONTRACTHEADER =
* IMPORTING
*             OBJ_TYPE       =
*             OBJ_KEY        =
*             OBJ_SYS        =
            TABLES
              accountgl      = gt_accntgl
*             ACCOUNTRECEIVABLE       =
              accountpayable = gt_accntpay
              accounttax     = gt_accntax
              currencyamount = gt_curr
*             CRITERIA       =
*             VALUEFIELD     =
*             EXTENSION1     =
              return         = gt_ret
*             PAYMENTCARD    =
*             CONTRACTITEM   =
*             EXTENSION2     =
*             REALESTATE     =
*             ACCOUNTWT      =
            .
          READ TABLE gt_ret INTO DATA(ls_ret) WITH KEY type = 'E'.
          IF sy-subrc EQ 0..
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CLEAR :  lv_msg,  lv_msg1.
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
              CONCATENATE  lv_msg1 ' / '  lv_msg INTO lv_msg SEPARATED BY space.
              CLEAR : ls_ret, lv_msg1.
            ENDLOOP.
            LOOP AT gt_error ASSIGNING FIELD-SYMBOL(<fs_er>) WHERE inv_no(16) = ls_data-xblnr.
              <fs_er>-error = lv_msg.
            ENDLOOP.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.
            CLEAR :  lv_msg,  lv_msg1.
            LOOP AT gt_ret INTO ls_ret WHERE type = 'S'.
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
              CONCATENATE  lv_msg1 ' / '  lv_msg INTO lv_msg SEPARATED BY space.
              CLEAR : ls_ret, lv_msg1.
            ENDLOOP.
            LOOP AT gt_error ASSIGNING FIELD-SYMBOL(<fs_er3>) WHERE inv_no(16) = ls_data-xblnr.
              <fs_er3>-error = lv_msg.
            ENDLOOP.
          ENDIF.
          LOOP AT gt_ret INTO ls_ret.
            CLEAR gs_ret.
            gs_ret = CORRESPONDING #( ls_ret ).
            APPEND gs_ret TO it_ret2.
          ENDLOOP.
*    ENDLOOP.
          CLEAR : lv_chk, lv_item, gs_docheader, lv_prctr, lv_anln1, lv_subasset.
          REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr.
        ENDAT.
*      ELSE.
**        ELSE.
**          CLEAR lv_msg.
**          CONCATENATE ls_data-hkont ' Invalid G/L account '  INTO lv_msg SEPARATED BY space.
**          LOOP AT gt_error ASSIGNING FIELD-SYMBOL(<fs_er2>) WHERE inv_no = ls_data-xblnr.
**            <fs_er2>-error = lv_msg.
**          ENDLOOP.
**          gs_ret-message = lv_msg.
**          APPEND gs_ret TO it_ret2.
**        ENDIF.
      ELSE.
        CLEAR lv_msg.
        CONCATENATE ls_data-prctr ' Invalid profit center / '  ' No company code determined for this profit center' INTO lv_msg SEPARATED BY space.
        LOOP AT gt_error ASSIGNING FIELD-SYMBOL(<fs_er1>) WHERE inv_no(16) = ls_data-xblnr.
          <fs_er1>-error = lv_msg.
        ENDLOOP.
        gs_ret-message = lv_msg.
        APPEND gs_ret TO it_ret2.
      ENDIF.
    ENDLOOP.
    DELETE gt_error[] WHERE error = space.
    IF gt_error IS NOT INITIAL.
      DATA(lr_mail) = NEW zcl_fi_ebuildr_s4_accpay( ).

      CALL METHOD lr_mail->send_mail
        EXPORTING
          et_data = gt_error
          ev_dl   = ev_dl.

    ENDIF.
  ENDMETHOD.


  METHOD send_mail.
    TYPES : BEGIN OF ty_file,
              ediuser(10)     TYPE c,
              edibatch(15)    TYPE c,
              tranno(10)      TYPE c,
              lineno(10)      TYPE c,
              sccess_prc(1)   TYPE c,
              costctr(10)     TYPE c,
              job_no(18)      TYPE c,
              co_num(10)      TYPE c,
              commit_no(25)   TYPE c,
              inv_no(100)     TYPE c,
              inv_dat(10)     TYPE c,
              inv_itm_des(50) TYPE c,
              net_payinv(25)  TYPE c,
              cost_code(10)   TYPE c,
              subledg(10)     TYPE c,
              subtype(1)      TYPE c,
              net_payline(25) TYPE c,
              pr_cntr(10)     TYPE c,
              usr_id(10)      TYPE c,
              pgm_id(10)      TYPE c,
              wk_id(10)       TYPE c,
              date_xprt(10)   TYPE c,
              compno(10)      TYPE c,
              commit_item(10) TYPE c,
              error           TYPE string,
            END OF ty_file.
    DATA : lt_error TYPE TABLE OF ty_file.

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
    DATA  : mailto       TYPE ad_smtpadr,
            lv_dmbtr(25) TYPE c,
            lv_mwsts(25) TYPE c.
    CONSTANTS:
      gc_tab  TYPE c VALUE ',' , "cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf,
      gc_qc   TYPE c VALUE '"'.
*          lt_text TYPE ANY TABLE.
    DATA: l_text TYPE string.     " Text content for mail attachment
    DATA: l_con(50) TYPE c.        " Field Content in character format
    CLEAR l_text.
*    mailto =   'swarrier@publicstorage.com'.
    lt_error = CORRESPONDING #( et_data ).
    LOOP AT lt_error ASSIGNING FIELD-SYMBOL(<fs_scs>).
      CONCATENATE l_text
  gc_qc <fs_scs>-ediuser gc_qc gc_tab
gc_qc <fs_scs>-edibatch gc_qc gc_tab
gc_qc <fs_scs>-tranno gc_qc gc_tab
gc_qc <fs_scs>-lineno gc_qc gc_tab
gc_qc <fs_scs>-sccess_prc gc_qc gc_tab
gc_qc <fs_scs>-costctr gc_qc  gc_tab
gc_qc <fs_scs>-job_no gc_qc gc_tab
gc_qc <fs_scs>-co_num gc_qc gc_tab
gc_qc <fs_scs>-commit_no gc_qc gc_tab
gc_qc <fs_scs>-inv_no gc_qc gc_tab
gc_qc <fs_scs>-inv_dat gc_qc gc_tab
gc_qc <fs_scs>-inv_itm_des gc_qc  gc_tab
gc_qc <fs_scs>-net_payinv gc_qc gc_tab
gc_qc <fs_scs>-cost_code gc_qc gc_tab
gc_qc <fs_scs>-subledg gc_qc gc_tab
gc_qc <fs_scs>-subtype gc_qc gc_tab
gc_qc <fs_scs>-net_payline gc_qc gc_tab
gc_qc <fs_scs>-pr_cntr gc_qc gc_tab
gc_qc <fs_scs>-usr_id gc_qc gc_tab
gc_qc <fs_scs>-pgm_id gc_qc gc_tab
gc_qc <fs_scs>-wk_id gc_qc gc_tab
gc_qc <fs_scs>-date_xprt gc_qc gc_tab
gc_qc <fs_scs>-compno gc_qc gc_tab
gc_qc <fs_scs>-commit_item gc_qc gc_tab
<fs_scs>-error gc_crlf
  INTO l_text.
    ENDLOOP.
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = l_text
            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix    = binary_content
            ev_size     = size ).
      CATCH cx_bcs.
*        MESSAGE e445(so).
    ENDTRY.
    TRY.

*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
        APPEND 'eBuilder to S4 postings status.' TO main_text. "#EC NOTEXT
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
          i_subject = 'eBuilder to S4 postings status.' ).   "#EC NOTEXT

*     add the spread sheet as attachment to document object
        document->add_attachment(
          i_attachment_type    = 'TXT'                      "#EC NOTEXT
          i_attachment_subject = 'eBuilder_process_file' "#EC NOTEXT
          i_attachment_size    = size
          i_att_content_hex    = binary_content ).

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
          i_dliname = ev_dl
          i_private = space ).
*     create recipient object
*        recipient = cl_cam_address_bcs=>create_internet_address( mailto ).
        recipient = cl_distributionlist_bcs=>getu_persistent(
          i_dliname = ev_dl
          i_private = space ).

*     add recipient object to send request
        send_request->add_recipient( i_recipient = recipient
                                     i_express   = 'X'
                                     i_copy      = 'X'
                                     ).
*     ---------- send document ---------------------------------------
        sent_to_all = send_request->send( i_with_error_screen = 'X' ).
        COMMIT WORK.
        IF sent_to_all IS INITIAL.
*          MESSAGE i500(sbcoms) WITH mailto.
        ELSE.
*          MESSAGE s022(so).
        ENDIF.
*   ------------ exception handling ----------------------------------
*   replace this rudimentary exception handling with your own one !!!
      CATCH cx_bcs INTO bcs_exception.
*        MESSAGE i865(so) WITH bcs_exception->error_type.
    ENDTRY.





  ENDMETHOD.
ENDCLASS.

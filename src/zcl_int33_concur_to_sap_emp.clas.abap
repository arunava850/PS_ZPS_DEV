class ZCL_INT33_CONCUR_TO_SAP_EMP definition
  public
  final
  create public .

public section.

  methods POST_DOC
    importing
      value(GT_FILE) type ANY TABLE optional
    exporting
      value(GT_RETURN) type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT33_CONCUR_TO_SAP_EMP IMPLEMENTATION.


  METHOD post_doc.

    TYPES : BEGIN OF ty_file,
              zreportid(20)      TYPE c,
              zempid(20)         TYPE c,
              zlast_name(50)     TYPE c,
              zfirst_name(50)    TYPE c,
              zreport_key(30)    TYPE c,
              zrep_submt_dt(10)  TYPE c,
              zrept_name(30)     TYPE c,
              zrep_org_unit1(20) TYPE c,
              zrep_custom(30)    TYPE c,
              zexpense_typ(10)   TYPE c,
              zacnt_code(20)     TYPE c,
              zdrcr(10)          TYPE c,
              zamount(30)        TYPE c,
              zallocation(30)    TYPE c,
            END OF ty_file.

    DATA : gt_data TYPE TABLE OF ty_file,
           gs_data TYPE ty_file.
    DATA : gs_docheader  TYPE bapiache09,
           gt_ret        TYPE TABLE OF bapiret2,
           gt_accntgl    TYPE TABLE OF bapiacgl09,
           gs_accntgl    TYPE bapiacgl09,
           gt_accntpay   TYPE TABLE OF bapiacap09,
           gs_accntpay   TYPE bapiacap09,
           gt_curr       TYPE TABLE OF bapiaccr09,
           gs_curr       TYPE bapiaccr09,
           gt_accntax    TYPE TABLE OF bapiactx09,
           gs_accntax    TYPE bapiactx09,
           gt_withtx     TYPE TABLE OF bapiacwt09,
           gs_ret        TYPE bapiret2,
           lv_fyear      TYPE bapi0002_4-fiscal_year,
           lv_period     TYPE bapi0002_4-fiscal_period,
           lv_item       TYPE posnr_acc,
           lv_amnt       TYPE p DECIMALS 4,
           lv_amnt2      TYPE bapidoccur,
           gt_charfld    TYPE TABLE OF bapiackec9,
           gs_charfld    TYPE bapiackec9,
           lv_msg        TYPE string,
           lv_msg1       TYPE string,
           lv_prctr      TYPE prctr,
           lv_add        TYPE c,
           lv_fees       TYPE p DECIMALS 4,
           lv_kostl      TYPE kostl,
           lv_kostl2     TYPE kostl,
           lv_saknr      TYPE saknr,
           lt_extension2 TYPE TABLE OF bapiparex,
           ls_extension2 TYPE bapiparex,
           lv_char2(2)   TYPE c.
    gt_data[] = CORRESPONDING #( gt_file ).
    SORT gt_data BY zreportid.

    LOOP AT gt_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
      AT NEW zreportid.
        lv_item = '1'.
        gs_docheader-bus_act = 'RFBU'.
        gs_docheader-username = sy-uname.
        CLEAR : lv_kostl.
        lv_kostl = ls_data-zrep_org_unit1.
        lv_kostl = |{ lv_kostl ALPHA = IN }|.
*        ls_data-zpropid = to_upper( ls_data-zpropid ).
*        SELECT SINGLE * FROM csks INTO @data(ls_csks)
*          WHERE kostl = @lv_kostl.
*      gs_docheader-comp_code = ls_csks-bukrs.
        gs_docheader-doc_date = ls_data-zrep_submt_dt.
        gs_docheader-pstng_date = sy-datum.
        gs_docheader-doc_type =  'YC'.
        gs_docheader-header_txt = ls_data-zreportid.
        gs_docheader-ref_doc_no = ls_data-zreport_key.
*        gs_docheader-glo_ref1_hd = ls_data-zrep_custom.
        ls_extension2-structure = 'EXTENSION2'.
        ls_extension2-valuepart1 = 'XREF1_HD'.
        ls_extension2-valuepart2 = ls_data-zrep_custom.
        APPEND ls_extension2 TO lt_extension2.
        CLEAR ls_extension2.
        CLEAR : lv_fyear, lv_period.
        CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
          EXPORTING
            companycodeid = gs_docheader-comp_code
            posting_date  = gs_docheader-pstng_date
          IMPORTING
            fiscal_year   = lv_fyear
            fiscal_period = lv_period.
*           RETURN                 =
*
        gs_docheader-fis_period = lv_period.
        gs_docheader-fisc_year = lv_fyear.
      ENDAT.
      ""Item1 G/L line
      CLEAR : lv_saknr, lv_prctr, lv_kostl2.
      lv_saknr = ls_data-zacnt_code.
      lv_saknr = |{ lv_saknr ALPHA = IN }|.
      gs_accntgl-itemno_acc = lv_item.
      gs_accntgl-gl_account = lv_saknr.
      gs_accntgl-alloc_nmbr = |{ ls_data-zexpense_typ }|."|{ ls_data-zfirst_name }| && |{ '  ' }| && |{ ls_data-zlast_name }|.
      lv_kostl2 = ls_data-zallocation.
      lv_kostl2 = |{ lv_kostl2 ALPHA = IN }|.

*      gs_accntgl-profit_ctr = lv_prctr.
*      gs_accntgl-item_text = ls_data-zempid.
      CONCATENATE ls_data-zempid '/' ls_data-zlast_name ls_data-zfirst_name INTO gs_accntgl-item_text SEPARATED BY space.
*      gs_accntgl-item_text = |{ ls_data-zempid }| && |{ ' / ' }| && |{ ls_data-zfirst_name }| && |{ lv_char2 }|
*                                 && |{ ls_data-zlast_name }|." && |{ '/' }| && |{ ls_data-zexpense_typ }|.
      SELECT SINGLE * FROM csks INTO @DATA(ls_csks)
        WHERE kostl = @lv_kostl2.
      IF sy-subrc EQ 0.
        gs_accntgl-comp_code  = ls_csks-bukrs.
        SELECT SINGLE * FROM ska1 INTO @DATA(ls_ska1)
          WHERE ktopl = 'PSUS'
          AND ktoks = 'ERG.'
*       and GLACCOUNT_TYPE = 'P'
          AND saknr = @gs_accntgl-gl_account.
        IF ls_ska1-glaccount_type = 'P'.
          gs_accntgl-costcenter = lv_kostl2.
        ELSE.
          gs_accntgl-profit_ctr = ls_csks-prctr.
        ENDIF.
      ENDIF.
      SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account
                                                          AND  ktopl = 'PSUS'.

      IF lv_xbilk = space.
        gs_charfld-itemno_acc = lv_item.
        gs_charfld-fieldname = 'PRCTR'.
        gs_charfld-character = gs_accntgl-profit_ctr.
        APPEND gs_charfld TO gt_charfld.
        CLEAR gs_charfld.
      ENDIF.
*      gs_accntgl-item_text = ls_data-zfindetsubtyp.
      APPEND gs_accntgl TO gt_accntgl.
      CLEAR gs_accntgl.


      ""Currency amounts
      CLEAR : lv_amnt.
      gs_curr-itemno_acc = lv_item.
      gs_curr-currency = 'USD'.
      CLEAR lv_amnt.
      REPLACE ',' IN ls_data-zamount WITH ' '.
      CONDENSE ls_data-zamount.
      lv_amnt = ls_data-zamount.
      IF ls_data-zdrcr EQ 'DR'.
        gs_curr-amt_doccur = lv_amnt.
      ELSE.
        gs_curr-amt_doccur = lv_amnt * -1.
        IF gs_curr-amt_doccur GT 0.
          gs_curr-amt_doccur = gs_curr-amt_doccur * -1.
        ENDIF.
      ENDIF.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.

      ""Line item2 G/L line
      lv_item = lv_item + 1.
*      gs_accntgl-itemno_acc = lv_item.
*      gs_accntgl-gl_account = '0000205000'.
*      gs_accntgl-alloc_nmbr = |{ ls_data-zfirst_name }| && |{ space }| && |{ ls_data-zlast_name }|.
*      lv_kostl2 = lv_prctr = ls_data-zallocation.
*      lv_kostl2 = lv_prctr = |{ lv_prctr ALPHA = IN }|.
*      gs_accntgl-costcenter = lv_kostl2.
*      gs_accntgl-profit_ctr = lv_prctr.
*      gs_accntgl-item_text = ls_data-zrept_name.
*      SELECT SINGLE bukrs FROM csks INTO gs_accntgl-comp_code WHERE kostl = lv_kostl2.
*      APPEND gs_accntgl TO gt_accntgl.
*      CLEAR gs_accntgl.

*      CLEAR : lv_amnt.

      CLEAR lv_amnt.
      REPLACE ',' IN ls_data-zamount WITH ' '.
      CONDENSE ls_data-zamount.
      lv_amnt = ls_data-zamount.
      IF ls_data-zdrcr EQ 'DR'.
        lv_amnt =  lv_amnt * -1.
        IF lv_amnt GT 0.
          lv_amnt = lv_amnt * -1.
        ENDIF.
      ELSE.
        lv_amnt = lv_amnt.
        IF lv_amnt LT 0.
          lv_amnt = lv_amnt * -1.
        ENDIF.
      ENDIF.
      lv_amnt2 = lv_amnt2 + lv_amnt.

*      lv_item = lv_item + 1.
      AT END OF zreportid.
        lv_item = lv_item + 1.
        gs_accntgl-itemno_acc = lv_item.
        gs_accntgl-gl_account = '0000205000'.
        gs_accntgl-alloc_nmbr = ls_data-zreport_key."|{ ls_data-zfirst_name }| && |{ '  ' }| && |{ ls_data-zlast_name }|.
        lv_kostl2 = lv_prctr = ls_data-zallocation.
        lv_kostl2 = lv_prctr = |{ lv_prctr ALPHA = IN }|.
        gs_accntgl-costcenter = '1000Z'.
        gs_accntgl-profit_ctr = '1000Z'.
        CONCATENATE ls_data-zempid '/' ls_data-zlast_name ls_data-zfirst_name  INTO gs_accntgl-item_text SEPARATED BY space.
*        gs_accntgl-item_text = |{ ls_data-zempid }| && |{ ' / ' }| && |{ ls_data-zfirst_name }| && |{ lv_char2 }|
*                                 && |{ ls_data-zlast_name }|. "ls_data-zrept_name.
        SELECT SINGLE bukrs FROM csks INTO gs_accntgl-comp_code WHERE kostl = '1000Z'.
        APPEND gs_accntgl TO gt_accntgl.
        CLEAR gs_accntgl.

        gs_curr-itemno_acc = lv_item.
        gs_curr-currency = 'USD'.
        gs_curr-amt_doccur = lv_amnt2.
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.

        CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = gs_docheader
*           CUSTOMERCPD    =
*           CONTRACTHEADER =
*           IMPORTING
*           OBJ_TYPE       =
*           OBJ_KEY        =
*           OBJ_SYS        =
          TABLES
            accountgl      = gt_accntgl
*           ACCOUNTRECEIVABLE       =
*           ACCOUNTPAYABLE =
*           ACCOUNTTAX     =
            currencyamount = gt_curr
            criteria       = gt_charfld
*           VALUEFIELD     =
*           EXTENSION1     =
            return         = gt_ret
*           PAYMENTCARD    =
*           CONTRACTITEM   =
            extension2     = lt_extension2
*           REALESTATE     =
            accountwt      = gt_withtx.

        CLEAR : lv_item, gs_docheader, lv_amnt2.
        REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld, gt_withtx.
        CLEAR: lt_extension2[]. " KDURAI 24/04/2024
      ENDAT.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.

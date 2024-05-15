class ZCL_INT107_CREDIT_CARD_FEES definition
  public
  final
  create public .

public section.

  methods POST_DOC
    importing
      value(GT_FILE) type ANY TABLE
    exporting
      value(GT_RETURN) type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT107_CREDIT_CARD_FEES IMPLEMENTATION.


  METHOD post_doc.

    TYPES : BEGIN OF ty_file,
              zsiteno(10)       TYPE c,
              zrecord_dt(10)    TYPE c,
              zfintycode(8)     TYPE c,
              zfintyscode(8)    TYPE c,
              zfindetyp(25)     TYPE c,
              zfindetsubtyp(25) TYPE c,
              zduetofrom(10)    TYPE c,
              zcustypcode(10)   TYPE c,
              zcustyp(20)       TYPE c,
              ztaxtypcode(4)    TYPE c,
              ztaxtypname(20)   TYPE c,
              zamount(10)       TYPE c,
              zdatatyp(15)      TYPE c,
            END OF ty_file.
    DATA : gt_data TYPE TABLE OF ty_file,
           gs_data TYPE ty_file.
    DATA : gs_docheader   TYPE bapiache09,
           gt_ret         TYPE TABLE OF bapiret2,
           gt_accntgl     TYPE TABLE OF bapiacgl09,
           gs_accntgl     TYPE bapiacgl09,
           gt_accntpay    TYPE TABLE OF bapiacap09,
           gs_accntpay    TYPE bapiacap09,
           gt_curr        TYPE TABLE OF bapiaccr09,
           gs_curr        TYPE bapiaccr09,
           gt_accntax     TYPE TABLE OF bapiactx09,
           gs_accntax     TYPE bapiactx09,
           gt_withtx      TYPE TABLE OF bapiacwt09,
           gs_ret         TYPE bapiret2,
           lv_fyear       TYPE bapi0002_4-fiscal_year,
           lv_period      TYPE bapi0002_4-fiscal_period,
           lv_item        TYPE posnr_acc,
           lv_amnt        TYPE p DECIMALS 2,
           gt_charfld     TYPE TABLE OF bapiackec9,
           gs_charfld     TYPE bapiackec9,
           er_data        TYPE zfit_yardi_s4_gl_post,
*           ls_data      TYPE zfis_yardi_s4_gl_post,
           lv_msg         TYPE string,
           lv_msg1        TYPE string,
           lv_prctr       TYPE prctr,
           lv_add         TYPE c,
           lv_fees        TYPE p DECIMALS 2,
           lv_object_type TYPE c,
           lv_prct_new    TYPE prctr,
           lv_special     TYPE char1 VALUE abap_true..
    CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_107_CREDITCARD_FEES' .
    SELECT SINGLE * FROM tvarvc INTO @DATA(ls_tvarvc) WHERE name = @lc_name.
    gt_data[] = CORRESPONDING #( gt_file ).
    SORT gt_data BY zsiteno.
    LOOP AT gt_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
      CLEAR lv_prctr.
*      ls_data = ls_data1.
      lv_prctr = ls_data-zsiteno.
      lv_prctr = |{ lv_prctr ALPHA = IN }|.
*      CLEAR  lv_item.
      AT NEW zsiteno.
        lv_item = '1'.
        gs_docheader-bus_act = 'RFBU'.
        gs_docheader-username = sy-uname.
*        ls_data-zpropid = to_upper( ls_data-zpropid ).
        SELECT SINGLE * FROM zfiar_fintype INTO @DATA(ls_zaai2) WHERE zfint = @ls_data-zfintycode
                                                                 AND zfinst =  @ls_data-zfintyscode
                                                                 AND zcust =  @ls_data-zcustypcode.
        IF sy-subrc EQ 0.
          SELECT SINGLE * FROM zfiar_aai_master INTO @DATA(ls_saknr2) WHERE zaai = @ls_zaai2-zaai
                                                                         AND zprctr = @lv_prctr."@ls_data-zsiteno.
          IF sy-subrc NE 0.
            CLEAR ls_saknr2.
            SELECT SINGLE * FROM zfiar_aai_master INTO ls_saknr2 WHERE zaai = ls_zaai2-zaai
                                                                     AND zprctr = '0000000000'.
          ENDIF.
        ENDIF.
        IF ls_saknr2-zpsfx IS NOT INITIAL.
          DATA(lv_newprctr) = |{ lv_prctr ALPHA = OUT }|.
          CONDENSE lv_newprctr.
          CLEAR lv_prct_new.
          CONCATENATE lv_newprctr ls_saknr2-zpsfx INTO lv_prct_new.
          SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prct_new.
          IF sy-subrc NE 0.
            CONCATENATE '0' lv_prct_new INTO lv_prct_new.
            SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prct_new.
            IF sy-subrc NE 0.
              CONCATENATE '0' lv_prct_new INTO lv_prct_new.
              SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prct_new.
            ENDIF.
          ENDIF.
        ELSE.
          lv_prct_new = lv_prctr.
          SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prct_new.
        ENDIF.
        IF gs_docheader-comp_code IS INITIAL.
          SELECT SINGLE bukrs FROM csks INTO gs_docheader-comp_code WHERE prctr = lv_prct_new.
        ENDIF.
        gs_docheader-comp_code = '1000'.
        gs_docheader-doc_date = ls_data-zrecord_dt.
        gs_docheader-pstng_date = gs_docheader-doc_date.
        gs_docheader-doc_type =  'ZC'.
        gs_docheader-header_txt = ls_data-zfindetsubtyp.
        gs_docheader-ref_doc_no = ls_data-zsiteno.
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
      gs_accntgl-itemno_acc = lv_item.
      SELECT SINGLE * FROM zfiar_fintype INTO @DATA(ls_zaai) WHERE zfint = @ls_data-zfintycode
                                                               AND zfinst =  @ls_data-zfintyscode
                                                               AND zcust =  @ls_data-zcustypcode.
      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM zfiar_aai_master INTO @DATA(ls_saknr) WHERE zaai = @ls_zaai-zaai
                                                                       AND zprctr = @lv_prctr."@ls_data-zsiteno.
        IF sy-subrc NE 0.
          CLEAR ls_saknr.
          SELECT SINGLE * FROM zfiar_aai_master INTO ls_saknr WHERE zaai = ls_zaai-zaai
                                                                   AND zprctr = '0000000000'.
        ENDIF.
      ENDIF.
      gs_accntgl-gl_account = |{ ls_saknr-saknr ALPHA = IN }|.  ""logic to identify OPEX and CAPEX accounts
      IF ls_saknr-prctr IS NOT INITIAL.
        ls_saknr-prctr = |{ ls_saknr-prctr ALPHA = IN }|.
*        CONCATENATE ls_saknr-prctr ls_saknr-zpsfx INTO  DATA(lv_kostl).
*        CONDENSE lv_kostl.
        DATA(lv_cost) =  |{ ls_saknr-prctr ALPHA = IN }|.
      ELSE.
        IF ls_saknr-zpsfx IS NOT INITIAL.
          DATA(lv_prctrn) = |{ lv_prctr ALPHA = OUT }|.
          CONDENSE lv_prctrn.
          CONCATENATE lv_prctrn ls_saknr-zpsfx INTO DATA(lv_kostl).
          lv_kostl = |{ lv_prctrn }| && |{ ls_saknr-zpsfx }|.
          CONDENSE lv_kostl.
          lv_cost =  |{ lv_kostl ALPHA = IN }|.
*          CONCATENATE '0' lv_cost INTO lv_cost.
        ELSE.
          lv_cost =  |{ lv_prctr ALPHA = IN }|.
        ENDIF.
*        lv_cost = lv_prctr.
      ENDIF.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = lv_cost.
      IF sy-subrc NE 0.
        CONCATENATE '0' lv_cost INTO lv_cost.
        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = lv_cost.
        IF sy-subrc NE 0.
          CONCATENATE '0' lv_cost INTO lv_cost.
          SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = lv_cost.
        ENDIF.
      ENDIF.
      SELECT SINGLE kstar FROM cska INTO @DATA(lv_kstar) WHERE kstar = @gs_accntgl-gl_account.
      IF sy-subrc EQ 0.
        gs_accntgl-costcenter = lv_cost.
      ELSE.
        gs_accntgl-profit_ctr = lv_cost.
      ENDIF.
*      IF lv_item = '1'.
*      gs_accntgl-comp_code = '1000'.
*      ENDIF.

      IF lv_item = '1'.
        IF gs_accntgl-comp_code <> '1000'.
          lv_special = abap_true.
        ENDIF.
      ENDIF.

      IF lv_special = abap_true.
        gs_accntgl-itemno_acc = lv_item + 1.
      ENDIF.


      SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account
                                                          AND  ktopl = 'PSUS'.

      IF lv_xbilk = space.
        gs_charfld-itemno_acc = lv_item.
        IF lv_special = abap_true.
          gs_charfld-itemno_acc = lv_item + 1.
        ENDIF.
        gs_charfld-fieldname = 'PRCTR'.
        gs_charfld-character = gs_accntgl-profit_ctr.
        APPEND gs_charfld TO gt_charfld.
        CLEAR gs_charfld.
      ENDIF.
      gs_accntgl-item_text = ls_data-zfindetsubtyp.
      APPEND gs_accntgl TO gt_accntgl.
      CLEAR gs_accntgl.

      ""Currency amounts
      gs_curr-itemno_acc = lv_item.
      IF lv_special = abap_true.
        gs_curr-itemno_acc = lv_item + 1.
      ENDIF.
      gs_curr-currency = 'USD'.
      CLEAR lv_amnt.
      REPLACE ',' IN ls_data-zamount WITH ' '.
      CONDENSE ls_data-zamount.
      CLEAR : lv_fees.
      REPLACE ALL OCCURRENCES OF '%' IN ls_zaai-zccf WITH space.
      CONDENSE ls_zaai-zccf.
      lv_fees = ls_zaai-zccf.
      lv_amnt =  ls_data-zamount * ( lv_fees / 100 ).
      IF ls_saknr-zdrcr = 'N'.
        gs_curr-amt_doccur = lv_amnt.
      ELSE.
        gs_curr-amt_doccur = lv_amnt * -1.
      ENDIF.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.

      lv_item = lv_item + 1.

      gs_accntgl-gl_account = ls_tvarvc-low. "'0000200130'.
      gs_accntgl-gl_account = |{ gs_accntgl-gl_account ALPHA = IN }|.
      gs_accntgl-itemno_acc = lv_item.
      IF lv_special = abap_true.
        gs_accntgl-itemno_acc = lv_item - 1.
      ENDIF.
      gs_accntgl-profit_ctr = ls_tvarvc-high. "'1001Z'.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
      gs_accntgl-item_text = ls_data-zfindetsubtyp.
      APPEND gs_accntgl TO gt_accntgl.
      CLEAR gs_accntgl.

      gs_curr-itemno_acc = lv_item.
      IF lv_special = abap_true.
        gs_curr-itemno_acc = lv_item - 1.
      ENDIF.
      gs_curr-currency = 'USD'.
      IF ls_saknr-zdrcr = 'N'.
        gs_curr-amt_doccur = lv_amnt * -1.
      ELSE.
        gs_curr-amt_doccur = lv_amnt.
      ENDIF.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.
      AT END OF zsiteno.
        SORT gt_accntgl BY itemno_acc.
        SORT gt_curr BY itemno_acc.
        SORT gt_charfld BY itemno_acc.
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
*           EXTENSION2     =
*           REALESTATE     =
            accountwt      = gt_withtx.

        CLEAR : lv_item, gs_docheader.
        REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld.
      ENDAT.
      lv_item = lv_item + 1.
*      IF lv_add NE 'X'.
*      APPEND ls_data TO er_data.
*      ENDIF.
      CLEAR : lv_add, ls_data.
      lv_special = abap_false.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

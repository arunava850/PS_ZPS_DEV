class ZCL_FI_REVPOS_RET_STO_INS definition
  public
  final
  create public .

public section.

  methods POST_DOCUMENT
    importing
      value(ET_DATA) type ZFIT_AR_REV_POST optional
      value(GT_FILE) type STANDARD TABLE optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
    exporting
      value(IT_RET2) type ZFIT_AR_REV_POST .
  methods SEND_MAIL
    importing
      value(ET_DATA) type ZFIT_AR_REV_POST optional
      value(GT_FILE) type STANDARD TABLE optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional .
  methods POST_INSURANCE
    importing
      value(ET_DATA) type ZFIT_AR_REV_POST optional
      value(GT_FILE) type STANDARD TABLE optional
    exporting
      value(IT_RET2) type ZFIT_AR_REV_POST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_REVPOS_RET_STO_INS IMPLEMENTATION.


  METHOD post_document.
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
           lv_item      TYPE posnr_acc,
           lv_amnt      TYPE p DECIMALS 2,
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           lv_objky     TYPE bapiache09-obj_key,
           lv_objtyp    TYPE bapiache09-obj_type,
           lv_objsys    TYPE bapiache09-obj_sys,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           lv_chk       TYPE c,
           lv_tabix     TYPE sy-tabix,
           lt_new_ins   TYPE TABLE OF zfi_ar_rev_post,
           ls_new_ins   TYPE zfi_ar_rev_post,
           lr_zsiteno   TYPE RANGE OF zsiteno,
           ls_zsiteno   LIKE LINE OF lr_zsiteno.
    TYPES: BEGIN OF ty_new_data,
             key(22) TYPE c.
             INCLUDE TYPE zfi_ar_rev_post.
    TYPES : END OF ty_new_data.
    DATA : wa_new_data TYPE ty_new_data,
           it_new_data TYPE TABLE OF ty_new_data.
    CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_INT0026_INSURANCE_GL'.
*    FIELD-SYMBOLS : <ls_data>  TYPE ZFI_AR_REV_POST.
*   types : BEGIN OF ls_error.
*      INCLUDE STRUCTURE ZFI_AR_REV_POST.
*     types: error TYPE string,
*            END OF ls_error,
*            lt_error type TABLE OF ls_error.
    SELECT * FROM tvarvc INTO TABLE @DATA(lt_insr) WHERE name = @lc_name.
    SELECT SINGLE * FROM tvarvc INTO @DATA(ls_1000z) WHERE name = 'ZFI_INT0026_1001Z_1000_MAP'.
    IF et_data IS NOT INITIAL.


      SELECT bukrs, prctr FROM cepc_bukrs INTO TABLE @DATA(lt_cepc_bukrs)
        FOR ALL ENTRIES IN @et_data
         WHERE prctr = @et_data-prctr.

      SELECT saknr, xbilk FROM ska1
        INTO TABLE @DATA(lt_xbilk)
        FOR ALL ENTRIES IN @et_data
        WHERE saknr = @et_data-saknr AND ktopl = 'PSUS'.
    ENDIF.
    SORT et_data BY zsiteno.
*    delete
    DATA(lt_data) = et_data[].
    delete lt_data WHERE belnr NE space.
    REFRESH : it_new_data.
*    SORT lt_data BY ibukrs ASCENDING.
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data1>).
      wa_new_data = CORRESPONDING #( <ls_data1> ).
      CONCATENATE <ls_data1>-zsiteno <ls_data1>-zrec_dt <ls_data1>-bukrs INTO wa_new_data-key.
      APPEND wa_new_data TO it_new_data.
      CLEAR wa_new_data.
    ENDLOOP.
    SORT it_new_data BY key ibukrs.

*    LOOP AT it_new_data ASSIGNING FIELD-SYMBOL(<ls_data2>).
**      <ls_data> = <ls_data1>.
*      DATA(lv_insgl3) = |{ <ls_data2>-saknr ALPHA = OUT }|.
*      READ TABLE lt_insr INTO DATA(ls_insr3) WITH KEY high  = lv_insgl3.
*      IF sy-subrc EQ 0 AND <ls_data2>-bukrs = '7200'.
*        ls_new_ins = CORRESPONDING #( <ls_data2> ).
*        APPEND ls_new_ins TO lt_new_ins.
*        CLEAR ls_new_ins.
*        DELETE it_new_data[] FROM <ls_data2>.
*      ENDIF.
*    ENDLOOP.
*    BREAK schittadi.
    LOOP AT it_new_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*      <ls_data> = <ls_data1>.
      DATA(lv_insgl3) = |{ <ls_data>-saknr ALPHA = OUT }|.
      READ TABLE lt_insr INTO DATA(ls_insr3) WITH KEY high  = lv_insgl3.
      IF sy-subrc EQ 0 AND <ls_data>-bukrs = '7200'.
        ls_new_ins = CORRESPONDING #( <ls_data> ).
        APPEND ls_new_ins TO lt_new_ins.
        CLEAR ls_new_ins.
      ELSE.
        AT NEW key.
          lv_item = '1'.
          gs_docheader-bus_act = 'RFBU'.
          gs_docheader-username = sy-uname.
*      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = <ls_data>-zsiteno.
          gs_docheader-comp_code = <ls_data>-bukrs.
*          SELECT SINGLE high FROM tvarvc INTO @DATA(lv_high) WHERE name = 'ZFI_INT0026_1001Z_1000_MAP' AND low = @<ls_data>-prctr.
 gs_docheader-pstng_date = gs_docheader-doc_date = <ls_data>-bldat.
*           = sy-datum.
          gs_docheader-doc_type =  <ls_data>-blart.
*        gs_docheader-header_txt = <ls_data>-bktxt.
          CONCATENATE <ls_data>-zsiteno '_'  <ls_data>-zrec_dt INTO gs_docheader-header_txt.
          gs_docheader-ref_doc_no = <ls_data>-xblnr.
          CLEAR : lv_period, lv_fyear.
          CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
            EXPORTING
              companycodeid = gs_docheader-comp_code
              posting_date  = gs_docheader-pstng_date " sy-datum Change - SAPA-310
            IMPORTING
              fiscal_year   = lv_fyear
              fiscal_period = lv_period
*             RETURN        =
            .
          gs_docheader-fisc_year = lv_fyear.
          gs_docheader-fis_period = lv_period.
          READ TABLE it_new_data INTO DATA(ls_new) WITH KEY prctr = ls_1000z-low.
          IF sy-subrc EQ 0.
            gs_docheader-comp_code = ls_1000z-high.
          ENDIF.
        ENDAT.
*      DATA(lv_insgl3) = |{ <ls_data>-saknr ALPHA = OUT }|.
*      READ TABLE lt_insr INTO DATA(ls_insr3) WITH KEY high  = lv_insgl3.
*      IF sy-subrc EQ 0 AND <ls_data>-bukrs = '7200'.
*        ls_new_ins = CORRESPONDING #( <ls_data> ).
*        APPEND ls_new_ins TO lt_new_ins.
*        CLEAR ls_new_ins.
*        DELETE it_new_data[] WHERE key = <ls_data>-key
*                                AND    saknr = <ls_data>-saknr.
*        DATA(lv_ins_flg) = abap_true.
*      ENDIF.
*         IF ls_1000z-low = <ls_data>-prctr.
*            gs_docheader-comp_code = ls_1000z-high.
*          ENDIF.
*      IF lv_ins_flg = abap_false.
        gs_accntgl-itemno_acc = lv_item.
        gs_accntgl-gl_account = <ls_data>-saknr.
        gs_accntgl-alloc_nmbr = <ls_data>-zuonr.
        gs_accntgl-profit_ctr = |{ <ls_data>-prctr ALPHA = IN }|.
*      gs_accntgl-segment = <ls_data>-segment.
        gs_accntgl-item_text = <ls_data>-sgtxt.
        DATA(lv_insgl2) = |{ <ls_data>-saknr ALPHA = OUT }|.
        READ TABLE lt_insr INTO DATA(ls_insr2) WITH KEY low  = lv_insgl2.
        IF sy-subrc EQ 0.
          REPLACE ALL OCCURRENCES OF 'T' IN gs_accntgl-profit_ctr WITH space.
          CONDENSE gs_accntgl-profit_ctr.
          gs_accntgl-profit_ctr = |{ gs_accntgl-profit_ctr ALPHA = IN }|.
        ENDIF.
        IF <ls_data>-ibukrs IS NOT INITIAL.
*          SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
          READ TABLE lt_cepc_bukrs INTO DATA(ls_cepcbukrs) WITH KEY  prctr = gs_accntgl-profit_ctr.
          IF sy-subrc EQ 0.
            gs_accntgl-comp_code = ls_cepcbukrs-bukrs.
          ENDIF.
*         = <ls_data>-ibukrs.
        ENDIF.
        APPEND gs_accntgl TO gt_accntgl.
*        SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account AND ktopl = 'PSUS'.4
        READ TABLE lt_xbilk INTO DATA(ls_xbilk) WITH KEY saknr = gs_accntgl-gl_account.
        IF ls_xbilk-xbilk = space AND sy-subrc EQ 0.
          gs_charfld-itemno_acc = lv_item.
          gs_charfld-fieldname = 'PRCTR'.
          gs_charfld-character = gs_accntgl-profit_ctr. "|{ gs_accntgl-profit_ctr ALPHA = IN }|.
          APPEND gs_charfld TO gt_charfld.
          CLEAR gs_charfld.
        ENDIF.
        CLEAR gs_accntgl.

        ""Currency amounts
        gs_curr-itemno_acc = lv_item.
        gs_curr-currency = 'USD'.
        IF <ls_data>-bschl = '50'.
          gs_curr-amt_doccur = <ls_data>-dmbtr * -1.
        ELSEIF <ls_data>-bschl = '40'.
          gs_curr-amt_doccur = <ls_data>-dmbtr.
        ENDIF.
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.
        ""Fill offset entry
        CLEAR lv_chk.
*      IF <ls_data>-gkont IS NOT INITIAL.
*        lv_chk = 'X'.
**        ls_new_ins = CORRESPONDING #( <ls_data> ).
*        gs_accntgl-itemno_acc = lv_item + 1.
*        gs_accntgl-gl_account = <ls_data>-gkont.
*        gs_accntgl-alloc_nmbr = <ls_data>-zuonr.
*        gs_accntgl-profit_ctr = |{ <ls_data>-prctr ALPHA = IN }|.
**        gs_accntgl-segment = <ls_data>-segment.
*        gs_accntgl-item_text = <ls_data>-sgtxt.
*        SELECT SINGLE xbilk INTO lv_xbilk FROM ska1 WHERE saknr = gs_accntgl-gl_account AND ktopl = 'PSUS'.
*        IF lv_xbilk = space.
*          gs_charfld-itemno_acc = lv_item + 1.
*          gs_charfld-fieldname = 'PRCTR'.
*          gs_charfld-character = gs_accntgl-profit_ctr. "|{ gs_accntgl-profit_ctr ALPHA = IN }|.
*          APPEND gs_charfld TO gt_charfld.
*          CLEAR gs_charfld.
*        ENDIF.
*        IF <ls_data>-ibukrs IS NOT INITIAL.
*          SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
*        ENDIF.
*        APPEND gs_accntgl TO gt_accntgl.
*        CLEAR gs_accntgl.
*        ""Currency amounts
*        gs_curr-itemno_acc = lv_item + 1.
*        gs_curr-currency = 'USD'.
*        IF <ls_data>-bschl = '50'.
*          gs_curr-amt_doccur = <ls_data>-dmbtr.
*        ELSEIF <ls_data>-bschl = '40'.
*          gs_curr-amt_doccur = <ls_data>-dmbtr * -1.
*        ENDIF.
*        APPEND gs_curr TO gt_curr.
*        CLEAR gs_curr.
*      ENDIF.
        DATA(lv_insgl) = |{ <ls_data>-saknr ALPHA = OUT }|.
        READ TABLE lt_insr INTO DATA(ls_insr) WITH KEY high  = lv_insgl.
        IF sy-subrc EQ 0.
          gs_docheader-comp_code = '7200'.
*        LOOP AT lt_insr INTO DATA(ls_insr1).
**      lv_chk = 'X'.
**      lv_tabix = sy-index.
*          gs_accntgl-itemno_acc = lv_item + 1.
*          gs_accntgl-gl_account = ls_insr1-high.
*          gs_accntgl-gl_account = |{ gs_accntgl-gl_account ALPHA = IN }|.
*          gs_accntgl-alloc_nmbr = <ls_data>-zuonr.
**          gs_accntgl-profit_ctr = '7200T'. "|{ <ls_data>-prctr ALPHA = IN }|.
*          CONCATENATE <ls_data>-zsiteno 'T' INTO gs_accntgl-profit_ctr.
*          gs_accntgl-comp_code = '7200'.
**          gs_accntgl-segment = <ls_data>-segment.
*          gs_accntgl-item_text = <ls_data>-sgtxt.
*          SELECT SINGLE xbilk INTO lv_xbilk FROM ska1 WHERE saknr = gs_accntgl-gl_account AND ktopl = 'PSUS'.
*          IF lv_xbilk = space.
*            gs_charfld-itemno_acc = lv_item + 1.
*            gs_charfld-fieldname = 'PRCTR'.
*            gs_charfld-character = gs_accntgl-profit_ctr. "|{ gs_accntgl-profit_ctr ALPHA = IN }|.
*            APPEND gs_charfld TO gt_charfld.
*            CLEAR gs_charfld.
*          ENDIF.
**          IF <ls_data>-ibukrs IS NOT INITIAL.
**            SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
**            gs_accntgl-comp_code = '1000'.
**          gs_accntgl-profit_ctr = '0000007200'.
**          ENDIF.
*          APPEND gs_accntgl TO gt_accntgl.
*          CLEAR gs_accntgl.
*          ""Currency amounts
*          gs_curr-itemno_acc = lv_item + 1.
*          gs_curr-currency = 'USD'.
*          IF ls_insr1-high+0(1) = 4.
*            gs_curr-amt_doccur = <ls_data>-dmbtr * -1.
*          ELSE.
*            gs_curr-amt_doccur = <ls_data>-dmbtr.
*          ENDIF.
*          APPEND gs_curr TO gt_curr.
*          CLEAR gs_curr.
*          lv_item = lv_item + 1.
*        ENDLOOP.
        ENDIF.
        IF lv_chk = 'X'.
          lv_item = lv_item + 2.
        ELSE.
          lv_item = lv_item + 1.
        ENDIF.

        AT END OF key.
          CLEAR lv_objky.
          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = gs_docheader
*             CUSTOMERCPD    =
*             CONTRACTHEADER =
            IMPORTING
              obj_type       = lv_objtyp
              obj_key        = lv_objky
              obj_sys        = lv_objsys
            TABLES
              accountgl      = gt_accntgl
*             ACCOUNTRECEIVABLE       =
*             accountpayable = gt_accntpay
*             accounttax     = gt_accntax
              currencyamount = gt_curr
              criteria       = gt_charfld
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
          IF sy-subrc EQ 0.
            CLEAR : ls_zsiteno.
            ls_zsiteno-sign = 'I'.
            ls_zsiteno-option = 'EQ'.
            ls_zsiteno-low = <ls_data>-zsiteno.
            APPEND ls_zsiteno TO lr_zsiteno.
            CLEAR ls_zsiteno.
*             REFRESH lt_new_ins.
            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
            CLEAR lv_msg.
            LOOP AT gt_ret INTO ls_ret WHERE type = 'E'.
              CLEAR lv_msg1.
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
              CONCATENATE lv_msg1 ' ' lv_msg INTO lv_msg SEPARATED BY '|'.
            ENDLOOP.
            <ls_data>-remark = lv_msg.
*            <ls_data>-bukrs = gs_docheader-comp_code.
            DATA(lt_tmp) = et_data[].
            DELETE lt_tmp WHERE zsiteno NE <ls_data>-zsiteno.
            LOOP AT lt_tmp ASSIGNING FIELD-SYMBOL(<fs_tmp>) WHERE zsiteno = <ls_data>-zsiteno.
              DATA(lv_insgl4) = |{ <fs_tmp>-saknr ALPHA = OUT }|.
              READ TABLE lt_insr INTO DATA(ls_insr4) WITH KEY high  = lv_insgl4.
              IF sy-subrc NE 0.
                <fs_tmp>-remark = <ls_data>-remark.
                <fs_tmp>-bukrs = gs_docheader-comp_code.
              ENDIF.
            ENDLOOP.
            MODIFY zfi_ar_rev_post FROM TABLE lt_tmp.
            IF sy-dbcnt IS NOT INITIAL.
              COMMIT WORK.
            ENDIF.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = abap_true.

            <ls_data>-belnr = lv_objky+0(10).
            <ls_data>-buzei = lv_item.
*          <ls_data>-remark = lv_objky.
            CONCATENATE 'Document ' <ls_data>-belnr ' Posted Successfully' INTO <ls_data>-remark SEPARATED BY space.
            DATA(lt_tmp1) = et_data[].
            DELETE lt_tmp1 WHERE zsiteno NE <ls_data>-zsiteno.
            LOOP AT lt_tmp1 ASSIGNING FIELD-SYMBOL(<fs_tmp1>) WHERE zsiteno = <ls_data>-zsiteno.
              DATA(lv_insgl5) = |{ <fs_tmp1>-saknr ALPHA = OUT }|.
              READ TABLE lt_insr INTO DATA(ls_insr5) WITH KEY high  = lv_insgl5.
              IF sy-subrc NE 0.
                <fs_tmp1>-remark = <ls_data>-remark.
                <fs_tmp1>-belnr =  <ls_data>-belnr.
                <fs_tmp1>-buzei =  <ls_data>-buzei.
                <fs_tmp1>-remark = <ls_data>-remark.
                <fs_tmp1>-bukrs = gs_docheader-comp_code.
              ENDIF.
            ENDLOOP.
            MODIFY zfi_ar_rev_post FROM TABLE lt_tmp1.
            IF sy-dbcnt IS NOT INITIAL.
              COMMIT WORK.
            ENDIF.


*            DATA(lr_mail) = NEW zcl_fi_revpos_ret_sto_ins( ).
*            IF lt_new_ins IS NOT INITIAL .
*
*              CALL METHOD lr_mail->post_insurance
*                EXPORTING
*                  et_data = lt_new_ins
**                 gt_file =
**  IMPORTING
**                 it_ret2 =
*                .
*            ENDIF.
*          MODIFY zfi_ar_rev_post FROM <ls_data> WHERE zsiteno = <ls_data>-zsiteno.
          ENDIF.
*      LOOP AT gt_ret INTO ls_ret.
*        CLEAR gs_ret.
*        gs_ret = CORRESPONDING #( ls_ret ).
*        APPEND gs_ret TO it_ret2.
*      ENDLOOP.
          CLEAR : lv_item, gs_docheader.
          REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld." lt_new_ins.
        ENDAT.
      ENDIF.
*      CLEAR lv_ins_flg.
*      ENDIF.
    ENDLOOP.


*    it_ret2[] = et_data[].
*      it_ret2
    DATA(lr_mail2) = NEW zcl_fi_revpos_ret_sto_ins( ).
    IF lr_zsiteno IS NOT INITIAL.
      DELETE lt_new_ins WHERE zsiteno IN lr_zsiteno.
    ENDIF.
    REFRESH lr_zsiteno.
    IF lt_new_ins IS NOT INITIAL .

      CALL METHOD lr_mail2->post_insurance
        EXPORTING
          et_data = lt_new_ins
*         gt_file =
*  IMPORTING
*         it_ret2 =
        .
      REFRESH lt_new_ins.
    ENDIF.

    SELECT * FROM zfi_ar_rev_post INTO TABLE it_ret2
         FOR ALL ENTRIES IN lt_data
         WHERE zsiteno = lt_data-zsiteno.

    CALL METHOD lr_mail2->send_mail
      EXPORTING
        et_data = it_ret2
*       gt_file =
       ev_dl   = ev_dl
      .

  ENDMETHOD.


  METHOD POST_INSURANCE.
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
           lv_item      TYPE posnr_acc,
           lv_amnt      TYPE p DECIMALS 2,
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           lv_objky     TYPE bapiache09-obj_key,
           lv_objtyp    TYPE bapiache09-obj_type,
           lv_objsys    TYPE bapiache09-obj_sys,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           lv_chk       TYPE c,
           lv_tabix     TYPE sy-tabix,
           lt_new_ins  TYPE TABLE OF zfi_ar_rev_post,
           ls_new_ins TYPE zfi_ar_rev_post.
   TYPES: BEGIN OF ty_new_data,
             key(22) TYPE c.
             INCLUDE TYPE zfi_ar_rev_post.
    TYPES : END OF ty_new_data.
 data : wa_new_data TYPE ty_new_data,
        it_new_data TYPE TABLE OF ty_new_data.
    CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_INT0026_INSURANCE_GL'.
*    FIELD-SYMBOLS : <ls_data>  TYPE ZFI_AR_REV_POST.
*   types : BEGIN OF ls_error.
*      INCLUDE STRUCTURE ZFI_AR_REV_POST.
*     types: error TYPE string,
*            END OF ls_error,
*            lt_error type TABLE OF ls_error.
    SELECT * FROM tvarvc INTO TABLE @DATA(lt_insr) WHERE name = @lc_name.
    SORT et_data BY zsiteno.
    DATA(lt_data) = et_data[].
    REFRESH : it_new_data.
    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<ls_data1>).
      wa_new_data = CORRESPONDING #( <ls_data1> ).
      CONCATENATE <ls_data1>-zsiteno <ls_data1>-zrec_dt <ls_data1>-bukrs INTO wa_new_data-key.
      APPEND wa_new_data TO it_new_data.
      CLEAR wa_new_data.
    ENDLOOP.
    SORT it_new_data BY key.
    LOOP AT it_new_data ASSIGNING FIELD-SYMBOL(<ls_data>).
*      <ls_data> = <ls_data1>.
      AT NEW key.
        lv_item = '1'.
        gs_docheader-bus_act = 'RFBU'.
        gs_docheader-username = sy-uname.
*      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = <ls_data>-zsiteno.
        gs_docheader-comp_code = <ls_data>-bukrs.
        gs_docheader-doc_date = <ls_data>-bldat.
        gs_docheader-pstng_date = <ls_data>-bldat. " sy-datum.
        gs_docheader-doc_type =  <ls_data>-blart.
*        gs_docheader-header_txt = <ls_data>-bktxt.
        CONCATENATE <ls_data>-zsiteno '_'  <ls_data>-zrec_dt INTO gs_docheader-header_txt.
        gs_docheader-ref_doc_no = <ls_data>-xblnr.
        CLEAR : lv_period, lv_fyear.
        CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
          EXPORTING
            companycodeid = gs_docheader-comp_code
            posting_date  = gs_docheader-pstng_date " sy-datum Change - SAPA-310
          IMPORTING
            fiscal_year   = lv_fyear
            fiscal_period = lv_period
*           RETURN        =
          .
        gs_docheader-fisc_year = lv_fyear.
        gs_docheader-fis_period = lv_period.
      ENDAT.
      gs_accntgl-itemno_acc = lv_item.
      gs_accntgl-gl_account = <ls_data>-saknr.
      gs_accntgl-alloc_nmbr = <ls_data>-zuonr.
      gs_accntgl-profit_ctr = |{ <ls_data>-prctr ALPHA = IN }|.
*      gs_accntgl-segment = <ls_data>-segment.
      gs_accntgl-item_text = <ls_data>-sgtxt.
*      DATA(lv_insgl2) = |{ <ls_data>-saknr ALPHA = OUT }|.
*      READ TABLE lt_insr INTO DATA(ls_insr2) WITH KEY low  = lv_insgl2.
*      IF sy-subrc EQ 0.
*        REPLACE ALL OCCURRENCES OF 'T' IN gs_accntgl-profit_ctr WITH space.
*        CONDENSE gs_accntgl-profit_ctr.
*        gs_accntgl-profit_ctr = |{ gs_accntgl-profit_ctr ALPHA = IN }|.
*      ENDIF.
      IF <ls_data>-ibukrs IS NOT INITIAL.
        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
*         = <ls_data>-ibukrs.
      ENDIF.
      APPEND gs_accntgl TO gt_accntgl.
      SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account AND ktopl = 'PSUS'.
      IF lv_xbilk = space.
        gs_charfld-itemno_acc = lv_item.
        gs_charfld-fieldname = 'PRCTR'.
        gs_charfld-character = gs_accntgl-profit_ctr. "|{ gs_accntgl-profit_ctr ALPHA = IN }|.
        APPEND gs_charfld TO gt_charfld.
        CLEAR gs_charfld.
      ENDIF.
      CLEAR gs_accntgl.

      ""Currency amounts
      gs_curr-itemno_acc = lv_item.
      gs_curr-currency = 'USD'.
      IF <ls_data>-bschl = '50'.
        gs_curr-amt_doccur = <ls_data>-dmbtr * -1.
      ELSEIF <ls_data>-bschl = '40'.
        gs_curr-amt_doccur = <ls_data>-dmbtr.
      ENDIF.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.
      ""Fill offset entry
      CLEAR lv_chk.
      DATA(lv_insgl) = |{ <ls_data>-saknr ALPHA = OUT }|.
      READ TABLE lt_insr INTO DATA(ls_insr) WITH KEY high  = lv_insgl.
      IF sy-subrc EQ 0.
     gs_docheader-comp_code = '7200'.
      ENDIF.
*      IF lv_chk = 'X'.
*        lv_item = lv_item + 2.
*      ELSE.
        lv_item = lv_item + 1.
*      ENDIF.

      AT END OF key.
        CLEAR lv_objky.
        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = gs_docheader
*           CUSTOMERCPD    =
*           CONTRACTHEADER =
          IMPORTING
            obj_type       = lv_objtyp
            obj_key        = lv_objky
            obj_sys        = lv_objsys
          TABLES
            accountgl      = gt_accntgl
*           ACCOUNTRECEIVABLE       =
*           accountpayable = gt_accntpay
*           accounttax     = gt_accntax
            currencyamount = gt_curr
            criteria       = gt_charfld
*           VALUEFIELD     =
*           EXTENSION1     =
            return         = gt_ret
*           PAYMENTCARD    =
*           CONTRACTITEM   =
*           EXTENSION2     =
*           REALESTATE     =
*           ACCOUNTWT      =
          .
        READ TABLE gt_ret INTO DATA(ls_ret) WITH KEY type = 'E'.
        IF sy-subrc EQ 0..
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
          CLEAR lv_msg.
          LOOP AT gt_ret INTO ls_ret WHERE type = 'E'.
            CLEAR lv_msg1.
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
            CONCATENATE lv_msg1 ' ' lv_msg INTO lv_msg SEPARATED BY '|'.
          ENDLOOP.
          <ls_data>-remark = lv_msg.
          DATA(lt_tmp) = et_data[].
          DELETE lt_tmp WHERE zsiteno NE <ls_data>-zsiteno.
          LOOP AT lt_tmp ASSIGNING FIELD-SYMBOL(<fs_tmp>) WHERE zsiteno = <ls_data>-zsiteno.
*            <fs_tmp>-bukrs = '7200'.
            <fs_tmp>-remark = <ls_data>-remark.
          ENDLOOP.
          MODIFY zfi_ar_rev_post FROM TABLE lt_tmp.
          IF sy-dbcnt IS NOT INITIAL.
            COMMIT WORK.
          ENDIF.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = abap_true.

          <ls_data>-belnr = lv_objky+0(10).
          <ls_data>-buzei = lv_item.
*          <ls_data>-remark = lv_objky.
          CONCATENATE 'Document ' <ls_data>-belnr ' Posted Successfully' INTO <ls_data>-remark SEPARATED BY space.
          DATA(lt_tmp1) = et_data[].
          DELETE lt_tmp1 WHERE zsiteno NE <ls_data>-zsiteno.
          LOOP AT lt_tmp1 ASSIGNING FIELD-SYMBOL(<fs_tmp1>) WHERE zsiteno = <ls_data>-zsiteno.
            <fs_tmp1>-remark = <ls_data>-remark.
            <fs_tmp1>-belnr =  <ls_data>-belnr.
            <fs_tmp1>-buzei =  <ls_data>-buzei.
*            <fs_tmp1>-bukrs = '7200'.
*             MODIFY zfi_ar_rev_post FROM <fs_tmp1>." WHERE zsiteno = <ls_data>-zsiteno.
*            IF sy-dbcnt IS NOT INITIAL.
*            COMMIT WORK.
*          ENDIF.
          ENDLOOP.
          MODIFY zfi_ar_rev_post FROM TABLE lt_tmp1[].
          IF sy-dbcnt IS NOT INITIAL.
            COMMIT WORK.
          ENDIF.
*          MODIFY zfi_ar_rev_post FROM <ls_data> WHERE zsiteno = <ls_data>-zsiteno.
        ENDIF.
*      LOOP AT gt_ret INTO ls_ret.
*        CLEAR gs_ret.
*        gs_ret = CORRESPONDING #( ls_ret ).
*        APPEND gs_ret TO it_ret2.
*      ENDLOOP.
        CLEAR : lv_item, gs_docheader.
        REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld.
      ENDAT.
    ENDLOOP.

*    SELECT * FROM zfi_ar_rev_post INTO TABLE it_ret2
*      FOR ALL ENTRIES IN lt_data
*      WHERE zsiteno = lt_data-zsiteno.
*    it_ret2[] = et_data[].
*      it_ret2
*    DATA(lr_mail) = NEW zcl_fi_revpos_ret_sto_ins( ).
*
*    CALL METHOD lr_mail->send_mail
*      EXPORTING
*        et_data = it_ret2
**       gt_file =
**       ev_dl   =
*      .

  ENDMETHOD.


  METHOD send_mail.
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
    DATA   mailto TYPE ad_smtpadr.
    DATA : lv_sno(10) TYPE c,
           lv_dmbtr(25) TYPE c.
    CONSTANTS:
      gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.
*          lt_text TYPE ANY TABLE.
    DATA: l_text TYPE string.     " Text content for mail attachment
    DATA: l_con(50) TYPE c.        " Field Content in character format

*    mailto = 'sbhagat@publicstorage.com'.
    CREATE OBJECT document.
    LOOP AT et_data ASSIGNING FIELD-SYMBOL(<fs_scs>).
      CLEAR : lv_sno, lv_dmbtr.
      lv_sno = <fs_scs>-zsno.
      lv_dmbtr = <fs_scs>-dmbtr.
      CONCATENATE l_text
      <fs_scs>-zsiteno gc_tab
 lv_sno gc_tab
<fs_scs>-zrec_dt gc_tab
<fs_scs>-bukrs gc_tab
<fs_scs>-monat gc_tab
<fs_scs>-gjahr gc_tab
<fs_scs>-blart gc_tab
<fs_scs>-bktxt gc_tab
<fs_scs>-xblnr gc_tab
<fs_scs>-budat gc_tab
<fs_scs>-bldat gc_tab
<fs_scs>-bschl gc_tab
<fs_scs>-saknr gc_tab
<fs_scs>-gkont gc_tab
lv_dmbtr gc_tab
<fs_scs>-zuonr gc_tab
<fs_scs>-kostl gc_tab
<fs_scs>-prctr gc_tab
*<fs_scs>-segment gc_tab
<fs_scs>-sgtxt gc_tab
<fs_scs>-ibukrs gc_tab
<fs_scs>-belnr gc_tab
<fs_scs>-buzei gc_tab
<fs_scs>-remark gc_crlf
  INTO l_text.
    ENDLOOP.
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = l_text
            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix  = binary_content
            ev_size   = size ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.

    TRY.

*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
        APPEND 'Revenue postings, Retail Merchandise & Tenant Insurance Status.' TO main_text.  "#EC NOTEXT
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
          i_subject = 'Revenue Retail Merchandise, Tenant Insurance.' ). "#EC NOTEXT

*     add the spread sheet as attachment to document object
        document->add_attachment(
          i_attachment_type    = 'xls'                      "#EC NOTEXT
          i_attachment_subject = 'Status_file'              "#EC NOTEXT
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
*     create recipient object
*        recipient = cl_cam_address_bcs=>create_internet_address( mailto ).
    recipient = cl_distributionlist_bcs=>getu_persistent(
        i_dliname = ev_dl
        i_private = space ).

*     add recipient object to send request
        send_request->add_recipient( i_recipient = recipient
                                     i_express = 'X'
*                                     i_copy = 'X'
                                        ).

*     ---------- send document ---------------------------------------
        sent_to_all = send_request->send( i_with_error_screen = 'X' ).

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

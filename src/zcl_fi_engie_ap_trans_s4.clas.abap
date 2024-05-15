class ZCL_FI_ENGIE_AP_TRANS_S4 definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF  TY_LFB1 ,
          lifnr TYPE lifnr,
          bukrs TYPE bukrs,
          altkn TYPE altkn,
        END OF ty_lfb1 .
  types:
    tyt_lfb1 TYPE TABLE OF TY_LFB1 .

  class-methods POST_DOCUMENT
    importing
      !IT_INPUT type ZTT_INPUT_ENGIE
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods SEND_EMAIL
    importing
      !IT_DATA type ZTT_INPUT_ENGIE optional
      !IT_BODY type BCSY_TEXT optional
    exporting
      !EX_SUBRC type SYSUBRC .
  class-methods POST_ACC_DOCUMENT
    importing
      !IT_INPUT type ZTT_INPUT_ENGIE
      !IT_LFB1_1 type TYT_LFB1 optional
      !IT_LFB1_2 type TYT_LFB1 optional
      !IV_LIFNR type LIFNR optional
      !IV_TEST type CHAR1 optional
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_ENGIE_AP_TRANS_S4 IMPLEMENTATION.


  METHOD post_acc_document.

    DATA : ls_docheader      TYPE bapiache09,
           lt_ret            TYPE TABLE OF bapiret2,
           gt_withtx         TYPE TABLE OF bapiacwt09,
           lt_accntgl        TYPE TABLE OF bapiacgl09,
           ls_accntgl        TYPE bapiacgl09,
           lt_accntpay       TYPE TABLE OF bapiacap09,
           ls_accntpay       TYPE bapiacap09,
           lt_curr           TYPE TABLE OF bapiaccr09,
           ls_curr           TYPE bapiaccr09,
           lt_accntax        TYPE TABLE OF bapiactx09,
           ls_accntax        TYPE bapiactx09,
           ls_ret            TYPE bapiret2,
           lv_fyear          TYPE bapi0002_4-fiscal_year,
           lv_item           TYPE posnr_acc,
           lv_amnt           TYPE p DECIMALS 2,
           lt_charfld        TYPE TABLE OF bapiackec9,
           ls_charfld        TYPE bapiackec9,
           lt_processed_data TYPE ztt_input_e78,
           ls_data           TYPE zst_input_e78,
           lv_msg            TYPE string,
           lv_msg1           TYPE string,
           lv_add            TYPE c,
           lv_vendor         TYPE lifnr,
           lv_vendor_1       TYPE lifnr,
           lv_client_vendor  TYPE lifnr,
           lv_error          TYPE c,
*           lt_vendor         TYPE TABLE OF ty_vendor WITH EMPTY KEY.
           lv_object_type    TYPE c.


    DATA(lt_input) = it_input[].
    lv_vendor = iv_lifnr.

    LOOP AT lt_input INTO DATA(ls_input1).

      DATA(ls_input) = ls_input1.
      ls_data = CORRESPONDING #( ls_input ).

      AT NEW property_no.
        lv_item = '1'.
        ls_docheader-bus_act = 'RFBU'.
        ls_docheader-username = sy-uname.
        ls_input-property_no = |{ ls_input-property_no ALPHA = IN }|.
        CLEAR: lv_object_type.
        CALL METHOD zcl_ps_utility_tools=>get_company_code
          EXPORTING
            iv_object_num  = ls_input-property_no
            iv_object_type = 'P'
          RECEIVING
            rv_company     = ls_docheader-comp_code.
        IF ls_docheader-comp_code IS NOT INITIAL.
          lv_object_type = 'P'. " Profit center
        ELSE.
          CALL METHOD zcl_ps_utility_tools=>get_company_code
            EXPORTING
              iv_object_num  = ls_input-property_no
              iv_object_type = 'C'
            RECEIVING
              rv_company     = ls_docheader-comp_code.
          IF ls_docheader-comp_code IS NOT INITIAL.
            lv_object_type = 'C'." Cost center
          ENDIF.
        ENDIF.
*      ls_docheader-comp_code = ls_data-bukrs.
        ls_docheader-doc_status = '3'. " 12/03/2024
        ls_docheader-doc_date = ls_input-doc_date.
        ls_docheader-pstng_date = sy-datum.
        ls_docheader-doc_type =  'YG'.
        CONCATENATE ls_input-hdr_txt '-' 'Engie'
         INTO ls_docheader-header_txt SEPARATED BY space.
        ls_docheader-ref_doc_no = ls_input-ref_doc_no.
        CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
          EXPORTING
            companycodeid = ls_docheader-comp_code
            posting_date  = ls_docheader-pstng_date
          IMPORTING
            fiscal_year   = lv_fyear.

        ls_docheader-fisc_year = lv_fyear.

        CLEAR: lv_error,lv_client_vendor.
*// Client vendor check
*        READ TABLE lt_lfb1_1 INTO DATA(ls_lfb1)
*                             WITH KEY lifnr = |{ ls_input-vendor_no ALPHA = IN }|
*                                      bukrs = ls_docheader-comp_code
*                                      BINARY SEARCH.
*        IF sy-subrc IS NOT INITIAL.
        lv_vendor_1 = ls_input-vendor_no.
        lv_vendor_1 = |{ lv_vendor_1 ALPHA = IN }|.
        READ TABLE it_lfb1_2 INTO DATA(ls_lfb1)
                              WITH KEY lifnr = lv_vendor_1
                                       bukrs = ls_docheader-comp_code
                                     BINARY SEARCH.
*          IF sy-subrc IS NOT INITIAL.
*           READ TABLE it_lfb1_2 INTO ls_lfb1
*                              WITH KEY lifnr = ls_input-vendor_no
*                                       bukrs = ls_docheader-comp_code.
*          ENDIF.
*        IF sy-subrc IS NOT INITIAL.
*          lv_error = abap_true.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '001'.
*          ls_ret-message_v1 = ls_input-vendor_no.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
*        ENDIF.
*        ENDIF.
        lv_client_vendor = ls_lfb1-lifnr.
        IF lv_client_vendor IS INITIAL.
          lv_client_vendor = ls_input-vendor_no.
        ENDIF.
        CLEAR ls_lfb1.
*// Engie vendor check
*        READ TABLE it_lfb1_1 INTO ls_lfb1
*                             WITH KEY lifnr = |{ lv_vendor ALPHA = IN }|
*                                      bukrs = ls_docheader-comp_code
*                                      BINARY SEARCH.
*        IF sy-subrc IS NOT INITIAL.
*          lv_error = 'Y'.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '004'.
*          ls_ret-message_v1 = lv_vendor.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
*        ENDIF.

*// Company and Profit center check
*        IF ls_docheader-comp_code IS INITIAL.
*          lv_error = 'C'.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '000'.
*          ls_ret-message_v1 = ls_data-property_no.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
*        ENDIF.


        ls_accntpay-itemno_acc = lv_item.
        ls_accntpay-vendor_no = lv_client_vendor.
*        ls_accntpay-vendor_no = |{ ls_accntpay-vendor_no ALPHA = IN }|.
        ls_accntpay-comp_code = ls_docheader-comp_code.       " Company code
        ls_accntpay-item_text = ls_input-sgtxt.
*        ls_accntpay-profit_ctr = ls_input-property_no.
*        ls_accntpay-profit_ctr = |{ ls_accntpay-profit_ctr ALPHA = IN }|.
        ls_accntpay-pmnttrms = 'NT00'.
        APPEND ls_accntpay TO lt_accntpay.
        CLEAR ls_accntpay.

        ls_curr-itemno_acc = lv_item.
        ls_curr-currency = 'USD'.
        CLEAR lv_amnt.
        lv_amnt =  ls_input-amt_doccur_cr.
        lv_amnt = lv_amnt * ( -1 ).
        ls_curr-amt_doccur = lv_amnt.
        APPEND ls_curr TO lt_curr.
        CLEAR ls_curr.
      ENDAT.

      lv_item = lv_item + 1.
      ls_accntgl-itemno_acc = lv_item.
      ls_accntgl-gl_account = |{ ls_input-gl_account ALPHA = IN }|.  ""logic to identify OPEX and CAPEX accounts

      ls_accntgl-comp_code = ls_docheader-comp_code.
      ls_accntgl-item_text = ls_input-sgtxt.
      ls_accntgl-profit_ctr  = ls_input-property_no.
      ls_accntgl-profit_ctr = |{ ls_accntgl-profit_ctr ALPHA = IN }|.
*      SELECT SINGLE ktopl,saknr,glaccount_type  FROM ska1 INTO @DATA(ls_ska1)
*        WHERE ktopl = 'PSUS'
*          AND saknr = @ls_accntgl-gl_account.
*      IF sy-subrc IS INITIAL AND ls_ska1-glaccount_type NE 'N'.
*        ls_accntgl-costcenter = ls_accntgl-profit_ctr.
*      ENDIF.
*      ls_accntgl-costcenter = ls_accntgl-profit_ctr.
      DATA(lv_prctr) = ls_accntgl-profit_ctr.
      CASE lv_object_type.
        WHEN 'P'.
         ls_accntgl-costcenter = lv_prctr.
        WHEN 'C'.

        SELECT kokrs,kostl,prctr FROM csks INTO @DATA(ls_csks) UP TO 1 ROWS
          WHERE kokrs = 'PSCO'
            AND kostl = @lv_prctr.
        ENDSELECT.
        IF sy-subrc IS INITIAL.
          lv_prctr = ls_csks-prctr.
        ELSE.
          CLEAR:lv_prctr.
        ENDIF.
         ls_accntgl-costcenter = ls_accntgl-profit_ctr.
         ls_accntgl-profit_ctr = lv_prctr.

        WHEN OTHERS.
         ls_accntgl-costcenter = lv_prctr.
         ls_accntgl-profit_ctr = lv_prctr.
      ENDCASE.

      APPEND ls_accntgl TO lt_accntgl.
      CLEAR ls_accntgl.

*// profitability segement
      CLEAR ls_charfld.
      ls_charfld-itemno_acc = lv_item.
      ls_charfld-fieldname = 'PRCTR'.
      ls_charfld-character = lv_prctr.
      APPEND ls_charfld TO lt_charfld.
      CLEAR ls_charfld.

      ""Currency amounts
      ls_curr-itemno_acc = lv_item.
      ls_curr-currency = 'USD'.
      CLEAR lv_amnt.
      lv_amnt =  ls_input-amt_doccur_dr.
      ls_curr-amt_doccur = lv_amnt.
      APPEND ls_curr TO lt_curr.
      CLEAR ls_curr.

*      CLEAR ls_ret.
*      CASE lv_error.
*        WHEN 'C'.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '000'.
*          ls_ret-message_v1 = ls_data-property_no.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
*        WHEN 'Y'.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '004'.
*          ls_ret-message_v1 = lv_vendor.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
*        WHEN abap_true.
*          ls_ret-type = 'E'.
*          ls_ret-id = 'ZMSG'.
*          ls_ret-number = '001'.
*          ls_ret-message_v1 = ls_input-vendor_no.
*          ls_ret-message_v2 = ls_docheader-comp_code.
*          APPEND ls_ret TO lt_ret.
*          CLEAR ls_ret.
**      ENDIF.
*      ENDCASE.

      AT END OF property_no.

** Debit to Utility Vendor
        lv_item = lv_item + 1.
        ls_accntpay-itemno_acc = lv_item.
        ls_accntpay-vendor_no = lv_client_vendor.
*        ls_accntpay-vendor_no = |{ ls_accntpay-vendor_no ALPHA = IN }|.
        ls_accntpay-comp_code = ls_docheader-comp_code.       " Company code
*      ls_accntpay-TAX_CODE = TBL_GL-MWSKZ.
        ls_accntpay-item_text = ls_input-sgtxt.
*        ls_accntpay-profit_ctr = ls_input-property_no.
*        ls_accntpay-profit_ctr = |{ ls_accntpay-profit_ctr ALPHA = IN }|.
        ls_accntpay-pmnttrms = 'NT00'.
        APPEND ls_accntpay TO lt_accntpay.
        CLEAR ls_accntpay.

        ls_curr-itemno_acc = lv_item.
        ls_curr-currency = 'USD'.
        CLEAR lv_amnt.
        lv_amnt =  ls_input-amt_doccur_cr.
        ls_curr-amt_doccur = lv_amnt.
        APPEND ls_curr TO lt_curr.
        CLEAR ls_curr.

*>> Credit to E78 Vendor
        lv_item = lv_item + 1.
        ls_accntpay-itemno_acc = lv_item.
        ls_accntpay-vendor_no = lv_vendor.
        ls_accntpay-vendor_no = |{ ls_accntpay-vendor_no ALPHA = IN }|.
        ls_accntpay-comp_code = ls_docheader-comp_code.       " Company code
        ls_accntpay-item_text = ls_input-sgtxt.
*        ls_accntpay-profit_ctr = ls_input-property_no.
*        ls_accntpay-profit_ctr = |{ ls_accntpay-profit_ctr ALPHA = IN }|.
        ls_accntpay-pmnttrms = 'NT00'.
        APPEND ls_accntpay TO lt_accntpay.
        CLEAR ls_accntpay.

        ls_curr-itemno_acc = lv_item.
        ls_curr-currency = 'USD'.
        CLEAR lv_amnt.
        lv_amnt =  ls_input-amt_doccur_cr.
        lv_amnt = lv_amnt * ( -1 ).
        ls_curr-amt_doccur = lv_amnt.
        APPEND ls_curr TO lt_curr.
        CLEAR ls_curr.
*
*        IF lv_error IS INITIAL.
*          CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
*            EXPORTING
*              documentheader = ls_docheader
*            TABLES
*              accountgl      = lt_accntgl
*              accountpayable = lt_accntpay
*              currencyamount = lt_curr
*              return         = lt_ret.
*
*          IF NOT line_exists( lt_ret[ type = 'E' ] ) AND
*            NOT line_exists( lt_ret[ type = 'A' ] )  AND
*            iv_test IS INITIAL.

*            CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*              EXPORTING
*                documentheader = ls_docheader
*              TABLES
*                accountgl      = lt_accntgl
*                accountpayable = lt_accntpay
*                currencyamount = lt_curr
**               criteria       = lt_charfld
*                return         = lt_ret.
        CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
          EXPORTING
            documentheader = ls_docheader
*           CUSTOMERCPD    =
*           CONTRACTHEADER =
*           IMPORTING
*           OBJ_TYPE       =
*           OBJ_KEY        =
*           OBJ_SYS        =
          TABLES
            accountgl      = lt_accntgl
*           ACCOUNTRECEIVABLE       =
            accountpayable = lt_accntpay
*           ACCOUNTTAX     =
            currencyamount = lt_curr
            criteria       = lt_charfld
*           VALUEFIELD     =
*           EXTENSION1     =
            return         = lt_ret
*           PAYMENTCARD    =
*           CONTRACTITEM   =
*           EXTENSION2     =
*           REALESTATE     =
            accountwt      = gt_withtx.
*          ENDIF.
*          IF  line_exists( lt_ret[ type = 'E' ] ) OR
*             line_exists( lt_ret[ type = 'A' ] ) .
**            CLEAR: lv_msg1, lv_msg.
*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
**            LOOP AT lt_ret INTO ls_ret WHERE type = 'E'.
**              CALL FUNCTION 'FORMAT_MESSAGE'
**                EXPORTING
**                  id        = ls_ret-id
**                  lang      = sy-langu
**                  no        = ls_ret-number
**                  v1        = ls_ret-message_v1
**                  v2        = ls_ret-message_v2
**                  v3        = ls_ret-message_v3
**                  v4        = ls_ret-message_v4
**                IMPORTING
**                  msg       = lv_msg1
**                EXCEPTIONS
**                  not_found = 1
**                  OTHERS    = 2.
**              IF sy-subrc <> 0.
*** Implement suitable error handling here
**              ENDIF.
**              CONCATENATE  ls_data-msg lv_msg1 INTO ls_data-msg SEPARATED BY space.
**              CLEAR lv_msg1.
**            ENDLOOP.
*
*            ls_data-success = ' '.
**            APPEND ls_data TO lt_processed_data.
*            lv_add = 'X'.
*
*          ELSE.
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                wait = abap_true.
**            CLEAR lv_msg.
**            LOOP AT lt_ret INTO ls_ret WHERE type = 'S'.
**              CALL FUNCTION 'FORMAT_MESSAGE'
**                EXPORTING
**                  id        = ls_ret-id
**                  lang      = sy-langu
**                  no        = ls_ret-number
**                  v1        = ls_ret-message_v1
**                  v2        = ls_ret-message_v2
**                  v3        = ls_ret-message_v3
**                  v4        = ls_ret-message_v4
**                IMPORTING
**                  msg       = lv_msg
**                EXCEPTIONS
**                  not_found = 1
**                  OTHERS    = 2.
**              IF sy-subrc <> 0.
*** Implement suitable error handling here
**              ENDIF.
**              CONCATENATE  ls_data-msg lv_msg  INTO ls_data-msg SEPARATED BY space.
**              CLEAR lv_msg.
**            ENDLOOP.
*            ls_data-success = 'X'.
**            APPEND ls_data TO lt_processed_data.
*            lv_add = 'X'.
*          ENDIF.
*          ENDIF.
*        ENDIF.

        APPEND LINES OF lt_ret TO et_return.
        CLEAR lv_msg.
        LOOP AT lt_ret INTO ls_ret .
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
              msg       = lv_msg
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
          CONCATENATE  ls_data-msg lv_msg  INTO ls_data-msg SEPARATED BY space.
          CLEAR lv_msg.
        ENDLOOP.

        IF lv_add EQ abap_true.
          APPEND ls_data TO lt_processed_data.
          MODIFY lt_processed_data FROM ls_data TRANSPORTING success msg
                                   WHERE property_no = ls_data-property_no.
        ENDIF.


        CLEAR :lv_item, ls_docheader, ls_accntpay,lt_accntpay,
               lt_accntgl, lt_curr, lt_charfld,lt_ret.
      ENDAT.
      IF lv_add NE 'X'.
        APPEND ls_data TO lt_processed_data.
      ENDIF.
      CLEAR : lv_add, ls_data.
    ENDLOOP.

*>> Send email
*    IF iv_test IS INITIAL.
*      CALL METHOD zcl_fi_engie_ap_trans_s4=>send_email
*        EXPORTING
*          it_data  = lt_processed_data
*        IMPORTING
*          ex_subrc = DATA(lv_subrc).
*    ENDIF.
  ENDMETHOD.


  METHOD post_document.

    TYPES: BEGIN OF ty_vendor,
             vendor_no TYPE lifnr,
           END OF ty_vendor.
    TYPES: tyt_vendor TYPE TABLE OF ty_vendor WITH EMPTY KEY.

    DATA : lv_vendor TYPE lifnr,
           lt_vendor TYPE TABLE OF ty_vendor WITH EMPTY KEY.


    DATA(lt_input) = it_input[].

    SELECT SINGLE * FROM tvarvc INTO @DATA(ls_tvarvc)
      WHERE name = 'ZFI_INT0011_ENGIE_VENDOR'. "#EC CI_ALL_FIELDS_NEEDED
    IF sy-subrc IS INITIAL.
      lv_vendor = ls_tvarvc-low.
      lv_vendor = |{ lv_vendor ALPHA = IN }|.
    ENDIF.

    lt_vendor = CORRESPONDING #( it_input ).
    SORT lt_vendor BY vendor_no.
    DELETE ADJACENT DUPLICATES FROM lt_vendor COMPARING vendor_no.
    DATA(lt_vendor_1) = lt_vendor.
    CLEAR: lt_vendor.
*    IF lv_vendor IS NOT INITIAL.
*      APPEND INITIAL LINE TO lt_vendor ASSIGNING FIELD-SYMBOL(<lfs_vendor>).
*      IF <lfs_vendor> IS ASSIGNED.
*        <lfs_vendor>-vendor_no =  lv_vendor.
*      ENDIF.
*    ENDIF.
*    IF lt_vendor[] IS NOT INITIAL.
*      SELECT lifnr,bukrs,altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_1)
*        FOR ALL ENTRIES IN @lt_vendor
*        WHERE lifnr = @lt_vendor-vendor_no.
*      IF sy-subrc IS INITIAL.
*        SORT lt_lfb1_1 BY lifnr bukrs.
*      ENDIF.
*    ENDIF.

    IF lt_vendor_1[] IS NOT INITIAL.
*      SELECT lifnr,bukrs,altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_2)
*        FOR ALL ENTRIES IN @lt_vendor_1
*        WHERE altkn = @lt_vendor_1-vendor_no.
*      IF sy-subrc IS INITIAL.
**        SORT lt_lfb1_2 BY bukrs altkn.
*      ENDIF.
      LOOP AT lt_vendor_1 ASSIGNING FIELD-SYMBOL(<lfs_vendor_1>).
        <lfs_vendor_1>-vendor_no = |{ <lfs_vendor_1>-vendor_no ALPHA = IN }|.
      ENDLOOP.
      SELECT lifnr,bukrs,altkn FROM lfb1 INTO TABLE @DATA(lt_lfb1_2)
        FOR ALL ENTRIES IN @lt_vendor_1
        WHERE lifnr = @lt_vendor_1-vendor_no.
      IF sy-subrc IS INITIAL.
*        SORT lt_lfb1_2 BY bukrs altkn.
      ENDIF.
      SORT lt_lfb1_2 BY lifnr bukrs.
      DELETE ADJACENT DUPLICATES FROM lt_lfb1_2 COMPARING lifnr bukrs.
*      SORT lt_lfb1_2 BY bukrs altkn.
    ENDIF.
*
**// Simulation
*    CALL METHOD zcl_fi_engie_ap_trans_s4=>post_acc_document
*      EXPORTING
*        it_input  = lt_input
*        it_lfb1_1 = lt_lfb1_1
*        it_lfb1_2 = lt_lfb1_2
*        iv_lifnr  = lv_vendor
*        iv_test   = abap_true
*      IMPORTING
*        et_return = et_return.

*// Actual posting
*    IF NOT line_exists( et_return[ type = 'E' ] ) AND
*      NOT line_exists( et_return[ type = 'A' ] ).
      CLEAR et_return[].
      CALL METHOD zcl_fi_engie_ap_trans_s4=>post_acc_document
        EXPORTING
          it_input  = lt_input
*          it_lfb1_1 = lt_lfb1_1
          it_lfb1_2 = lt_lfb1_2
          iv_lifnr  = lv_vendor
          iv_test   = space
        IMPORTING
          et_return = et_return.
*     ENDIF.

  ENDMETHOD.


  METHOD SEND_EMAIL.

    DATA: ls_mail_input TYPE zst_ps_email_excel_input,
          lv_content    TYPE string,
          lv_hdr_amnt   TYPE char30,
          lv_itm_amnt   TYPE char30,
          lv_first      TYPE c.

    CONSTANTS:
      gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

    ls_mail_input-mail_to_tvarvc = 'ZFI_INT0011_ENGIE_EMAIL'.
*  ls_input-mail_cc_tvarvc = 'ZFI_PS_INT0014_CC_EMAIL_ADDR'.
*  ls_input-mail_to_tvarvc = 'kdurai@publicstorage.com'.
    ls_mail_input-mail_subject = 'ENGIE Telecon AP Transactions'.
    IF it_body IS NOT INITIAL.
     ls_mail_input-mail_body_text = it_body.
    ELSE.
    ls_mail_input-mail_body_text =  VALUE #( ( line = 'Hello,' ) ( line = 'Please find the attached list.' ) ).
    ENDIF.

    ls_mail_input-iv_proc_file_name = 'ENGIE Posted Telecon AP Transactions_' && sy-datum.
    LOOP AT it_data INTO DATA(ls_data) WHERE success IS NOT INITIAL.
      IF lv_first IS INITIAL.
        CONCATENATE lv_content
            'Store Number'        gc_tab " property_no
            'Bill ID'             gc_tab " hdr_txt
            'Bill Date'           gc_tab " doc_date
            'Current Charges'     gc_tab " amt_doccur_cr
            'Client Vendor'       gc_tab " vendor_no
            'Invoice No'          gc_tab " ref_doc_no
            'Utility Acct Number' gc_tab " sgtxt
            'GL Amt Prorated Tax' gc_tab " amt_doccur_dr
            'GL Account'          gc_tab " gl_account
            'Msg'          gc_tab " gl_account
             gc_crlf
           INTO lv_content.
        lv_first = abap_true.
      ENDIF.

      lv_hdr_amnt = ls_data-amt_doccur_cr.
      CONDENSE lv_hdr_amnt.
      lv_itm_amnt = ls_data-amt_doccur_dr.
      CONDENSE lv_itm_amnt.
      CONCATENATE lv_content
          ls_data-property_no      gc_tab " property_no
          ls_data-hdr_txt          gc_tab " hdr_txt
          ls_data-doc_date         gc_tab " doc_date
          lv_hdr_amnt              gc_tab " amt_doccur_cr
          ls_data-vendor_no        gc_tab " vendor_no
          ls_data-ref_doc_no       gc_tab " ref_doc_no
          ls_data-sgtxt            gc_tab " sgtxt
          lv_itm_amnt              gc_tab " amt_doccur_dr
          ls_data-gl_account       gc_tab " gl_account
          ls_data-msg              gc_tab " gl_account
           gc_crlf
         INTO lv_content.

    ENDLOOP.

    ls_mail_input-iv_processed_data = lv_content.

    CLEAR:lv_first, lv_content.
    ls_mail_input-iv_error_file_name = 'ENGIE Error Telecon AP Transactions_' && sy-datum.
    LOOP AT it_data INTO ls_data WHERE success IS INITIAL.
      IF lv_first IS INITIAL.
        CONCATENATE lv_content
            'Store Number'        gc_tab " property_no
            'Bill ID'             gc_tab " hdr_txt
            'Bill Date'           gc_tab " doc_date
            'Current Charges'     gc_tab " amt_doccur_cr
            'Client Vendor'       gc_tab " vendor_no
            'Invoice No'          gc_tab " ref_doc_no
            'Utility Acct Number' gc_tab " sgtxt
            'GL Amt Prorated Tax' gc_tab " amt_doccur_dr
            'GL Account'          gc_tab " gl_account
            'Msg'          gc_tab " gl_account
             gc_crlf
           INTO lv_content.
        lv_first = abap_true.
      ENDIF.

      lv_hdr_amnt = ls_data-amt_doccur_cr.
      CONDENSE lv_hdr_amnt.
      lv_itm_amnt = ls_data-amt_doccur_dr.
      CONDENSE lv_itm_amnt.
      CONCATENATE lv_content
          ls_data-property_no      gc_tab " property_no
          ls_data-hdr_txt          gc_tab " hdr_txt
          ls_data-doc_date         gc_tab " doc_date
          lv_hdr_amnt              gc_tab " amt_doccur_cr
          ls_data-vendor_no        gc_tab " vendor_no
          ls_data-ref_doc_no       gc_tab " ref_doc_no
          ls_data-sgtxt            gc_tab " sgtxt
          lv_itm_amnt              gc_tab " amt_doccur_dr
          ls_data-gl_account       gc_tab " gl_account
          ls_data-msg              gc_tab " gl_account
           gc_crlf
         INTO lv_content.
    ENDLOOP.

    ls_mail_input-iv_error_data = lv_content.

    CALL METHOD zcl_ps_utility_tools=>send_email
      EXPORTING
        is_input = ls_mail_input
      RECEIVING
        rv_subrc = DATA(lv_subrc).

  ENDMETHOD.
ENDCLASS.

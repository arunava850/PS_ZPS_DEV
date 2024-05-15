class ZCL_FI_COUNSEL_LINK_AP_TRAN_S4 definition
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
  types:
    TYT_AAI_GL TYPE TABLE OF zglmap_inv .

  constants GV_INTF_ID type CHAR30 value 'INT0009_COUNSEL' ##NO_TEXT.

  class-methods POST_DOCUMENT
    importing
      !IT_INPUT type ZTT_IB_COUNSEL_LINK
    exporting
      !ET_RETURN type BAPIRET2_T .
  class-methods SEND_EMAIL
    importing
      !IT_DATA type ZTT_IB_COUNSEL_LINK optional
      !IT_BODY type BCSY_TEXT optional
    exporting
      !EX_SUBRC type SYSUBRC .
  class-methods POST_ACC_DOCUMENT
    importing
      !IT_INPUT type ZTT_IB_COUNSEL_LINK
      !IT_GL_TABLE type TYT_AAI_GL optional
      !IT_LFB1 type TYT_LFB1 optional
      !IV_TEST type CHAR1 optional
    exporting
      !ET_RETURN type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_COUNSEL_LINK_AP_TRAN_S4 IMPLEMENTATION.


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
           lt_processed_data TYPE ztt_ib_counsel_link,
           ls_data           TYPE zst_ib_counsel_link,
           lv_msg            TYPE string,
           lv_msg1           TYPE string,
           lv_add            TYPE c,
           lv_vendor         TYPE lifnr,
           lv_vendor_1       TYPE lifnr,
           lv_client_vendor  TYPE lifnr,
           lv_error          TYPE c,
           lv_first          TYPE c,
           lv_total          TYPE bapidoccur,
           lv_char           TYPE char30,
           lv_gl_account     TYPE char30.
*           lt_vendor         TYPE TABLE OF ty_vendor WITH EMPTY KEY.

    DATA(lt_input) = it_input[].

    LOOP AT lt_input INTO DATA(ls_input).

      ls_data = CORRESPONDING #( ls_input ).
      ls_docheader-bus_act = 'RFBU'.
      ls_docheader-username = sy-uname.
      ls_docheader-doc_date = ls_input-doc_date.
*>> BOC KDURAI 26/04/2024
*      ls_docheader-pstng_date = ls_input-pstng_date.
      ls_docheader-pstng_date = sy-datum.
*<< EOC KDURAI 26/04/2024
      IF ls_docheader-pstng_date IS INITIAL.
        ls_docheader-pstng_date = sy-datum.
      ENDIF.
      ls_docheader-doc_type =  'YL'.
      ls_docheader-header_txt = ls_input-bktxt.
      ls_docheader-ref_doc_no = ls_input-ref_doc_no.

      CLEAR lv_first.
*      lv_item = '1'.
      LOOP AT ls_input-items INTO DATA(ls_item).
*        ls_item-property_no = |{ ls_item-property_no ALPHA = IN }|.
        CLEAR lv_gl_account.
        SPLIT ls_item-gl_account AT '.' INTO lv_char lv_gl_account.
        CONDENSE lv_gl_account NO-GAPS.
        ls_item-gl_account = lv_gl_account.

        IF lv_first IS INITIAL.
          lv_first = abap_true.
          lv_item = '1'.
*          lv_item = lv_item + 1.

          ls_docheader-comp_code = ls_item-comp_code.

          CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
            EXPORTING
              companycodeid = ls_docheader-comp_code
              posting_date  = ls_docheader-pstng_date
            IMPORTING
              fiscal_year   = lv_fyear.

          ls_docheader-fisc_year = lv_fyear.

          CLEAR: lv_error,lv_client_vendor.
*// Profit center check
*          IF ls_docheader-comp_code IS INITIAL .
*            lv_error = abap_true.
**            EXIT.
*            ls_ret-type = 'E'.
*            ls_ret-id = 'ZMSG'.
*            ls_ret-number = '000'.
*            ls_ret-message_v1 = ls_item-property_no.
*            ls_ret-message_v2 = ls_docheader-comp_code.
*            APPEND ls_ret TO lt_ret.
*            CLEAR ls_ret.
*          ENDIF.
*// Client vendor check
          lv_vendor_1 = ls_input-vendor_no.
          lv_vendor_1 = |{ lv_vendor_1 ALPHA = IN }|.
          READ TABLE it_lfb1 INTO DATA(ls_lfb1)
                                WITH KEY lifnr = lv_vendor_1
                                         bukrs = ls_docheader-comp_code
                                       BINARY SEARCH.
*          IF sy-subrc IS NOT INITIAL.
*           READ TABLE it_lfb1 INTO ls_lfb1
*                              WITH KEY lifnr = ls_input-vendor_no
*                                       bukrs = ls_docheader-comp_code.
*          ENDIF.
*          IF sy-subrc IS NOT INITIAL.
*            lv_error = abap_true.
*            ls_ret-type = 'E'.
*            ls_ret-id = 'ZMSG'.
*            ls_ret-number = '001'.
*            ls_ret-message_v1 = ls_input-vendor_no.
*            ls_ret-message_v2 = ls_docheader-comp_code.
*            APPEND ls_ret TO lt_ret.
*            CLEAR ls_ret.
** *            EXIT.
*          ENDIF.

          lv_client_vendor = ls_lfb1-lifnr.
          IF lv_client_vendor IS INITIAL.
            lv_client_vendor = ls_input-vendor_no.
          ENDIF.

          CLEAR ls_lfb1.

          ls_accntpay-itemno_acc = lv_item.
          ls_accntpay-vendor_no = lv_client_vendor.
          ls_accntpay-comp_code = ls_docheader-comp_code.       " Company code
          ls_accntpay-alloc_nmbr = ls_input-zunor.
          ls_accntpay-item_text = ls_input-sgtxt.
*          ls_accntpay-profit_ctr = ls_item-property_no.
*          ls_accntpay-profit_ctr = |{ ls_accntpay-profit_ctr ALPHA = IN }|.
          ls_accntpay-pmnttrms = 'NT00'.
          APPEND ls_accntpay TO lt_accntpay.
          CLEAR ls_accntpay.

          ls_curr-itemno_acc = lv_item.
          ls_curr-currency = 'USD'.
          CLEAR lv_amnt.
          lv_amnt =  ls_input-amt_doccur.
          lv_amnt = lv_amnt * ( -1 ).
          ls_curr-amt_doccur = lv_amnt.
          APPEND ls_curr TO lt_curr.
          CLEAR ls_curr.

        ENDIF.

** GL account and Profit center mapping
        READ TABLE it_gl_table INTO DATA(ls_gl)
                                 WITH KEY zid = gv_intf_id
                                          zigl = ls_item-gl_account
                                          zsto = space
                                          BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          IF ls_item-property_no CO '0123456789 '.
            READ TABLE it_gl_table INTO ls_gl
                                     WITH KEY zid = gv_intf_id
                                              zigl = ls_item-gl_account
                                              zsto = 'Y'
                                              BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.

            ENDIF.
          ELSE.
            READ TABLE it_gl_table INTO ls_gl
                                     WITH KEY zid = gv_intf_id
                                              zigl = ls_item-gl_account
                                              zsto = 'N'
                                              BINARY SEARCH.
            IF sy-subrc IS NOT INITIAL.

            ENDIF.
          ENDIF.
        ENDIF.

        IF ls_item-comp_code = '9950'.
          ls_accntgl-gl_account = ls_gl-zsaknr.
*          IF ls_gl-zsaknr IS INITIAL.
*            lv_error = abap_true.
**              EXIT.
*            ls_ret-type = 'E'.
*            ls_ret-id = 'ZMSG'.
*            ls_ret-number = '002'.
*            ls_ret-message_v1 = ls_item-gl_account.
**            ls_ret-message_v2 = ls_docheader-comp_code.
*            APPEND ls_ret TO lt_ret.
*            CLEAR ls_ret.
*          ENDIF.
          IF ls_gl-zprctr IS NOT INITIAL.
            ls_item-property_no = ls_gl-zprctr.
          ENDIF.
        ELSE.
          ls_accntgl-gl_account = ls_gl-saknr.
*          IF ls_gl-saknr IS INITIAL.
*            lv_error = abap_true.
**              EXIT.
*            ls_ret-type = 'E'.
*            ls_ret-id = 'ZMSG'.
*            ls_ret-number = '003'.
*            ls_ret-message_v1 = ls_item-gl_account.
*            APPEND ls_ret TO lt_ret.
*            CLEAR ls_ret.
*          ENDIF.
          IF ls_gl-prctr IS NOT INITIAL.
            ls_item-property_no = ls_gl-prctr.
          ENDIF.
        ENDIF.

        ls_item-property_no = |{ ls_item-property_no ALPHA = IN }|.

        lv_item = lv_item + 1.
        ls_accntgl-itemno_acc = lv_item.

        ls_accntgl-gl_account = |{ ls_accntgl-gl_account ALPHA = IN }|.  ""logic to identify OPEX and CAPEX accounts
        ls_accntgl-comp_code = ls_docheader-comp_code.
        ls_accntgl-alloc_nmbr = ls_input-zunor.
        ls_accntgl-item_text = ls_input-sgtxt.
        ls_accntgl-profit_ctr  = ls_item-property_no.
        ls_accntgl-profit_ctr = |{ ls_accntgl-profit_ctr ALPHA = IN }|.
*        SELECT SINGLE ktopl,saknr,glaccount_type  FROM ska1 INTO @DATA(ls_ska1)
*          WHERE ktopl = 'PSUS'
*            AND saknr = @ls_accntgl-gl_account.
*        IF sy-subrc IS INITIAL AND ls_ska1-glaccount_type NE 'N'.
*          ls_accntgl-costcenter = ls_accntgl-profit_ctr.
*        ENDIF.
        DATA(lv_prctr) = ls_accntgl-profit_ctr.
        CASE ls_item-object_type.
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
        lv_amnt =  ls_item-amt_doccur.
        ls_curr-amt_doccur = lv_amnt.
        APPEND ls_curr TO lt_curr.
        CLEAR ls_curr.

      ENDLOOP.

*      IF lv_error IS INITIAL.
*        CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
*          EXPORTING
*            documentheader = ls_docheader
*          TABLES
*            accountgl      = lt_accntgl
*            accountpayable = lt_accntpay
*            currencyamount = lt_curr
*            return         = lt_ret.
*
*        IF NOT line_exists( lt_ret[ type = 'E' ] ) AND
*          NOT line_exists( lt_ret[ type = 'A' ] )
*          AND iv_test IS INITIAL.

*          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*            EXPORTING
*              documentheader = ls_docheader
*            TABLES
*              accountgl      = lt_accntgl
*              accountpayable = lt_accntpay
*              currencyamount = lt_curr
**             criteria       = lt_charfld
*              return         = lt_ret.
      ""Begin of SCHITTADI for Idoc
      CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = ls_docheader
*         CUSTOMERCPD    =
*         CONTRACTHEADER =
*           IMPORTING
*         OBJ_TYPE       =
*         OBJ_KEY        =
*         OBJ_SYS        =
        TABLES
          accountgl      = lt_accntgl
*         ACCOUNTRECEIVABLE       =
          accountpayable = lt_accntpay
*         ACCOUNTTAX     =
          currencyamount = lt_curr
          criteria       = lt_charfld
*         VALUEFIELD     =
*         EXTENSION1     =
          return         = lt_ret
*         PAYMENTCARD    =
*         CONTRACTITEM   =
*         EXTENSION2     =
*         REALESTATE     =
          accountwt      = gt_withtx.
      ""End of SCHITTADI for Idoc

*          READ TABLE lt_ret INTO ls_ret WITH KEY type = 'E'.
*          IF sy-subrc EQ 0.
*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*            CLEAR: lv_msg1, lv_msg.
*            LOOP AT lt_ret INTO ls_ret WHERE type = 'E'.
*              CALL FUNCTION 'FORMAT_MESSAGE'
*                EXPORTING
*                  id        = ls_ret-id
*                  lang      = sy-langu
*                  no        = ls_ret-number
*                  v1        = ls_ret-message_v1
*                  v2        = ls_ret-message_v2
*                  v3        = ls_ret-message_v3
*                  v4        = ls_ret-message_v4
*                IMPORTING
*                  msg       = lv_msg1
*                EXCEPTIONS
*                  not_found = 1
*                  OTHERS    = 2.
*              IF sy-subrc <> 0.
** Implement suitable error handling here
*              ENDIF.
*              CONCATENATE  ls_data-msg lv_msg1 INTO ls_data-msg SEPARATED BY space.
*              CLEAR lv_msg1.
*            ENDLOOP.

*            ls_data-success = ' '.
**            APPEND ls_data TO lt_processed_data.
**            lv_add = 'X'.
*          ELSE.
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*              EXPORTING
*                wait = abap_true.
*            CLEAR lv_msg.
*            LOOP AT lt_ret INTO ls_ret WHERE type = 'S'.
*              CALL FUNCTION 'FORMAT_MESSAGE'
*                EXPORTING
*                  id        = ls_ret-id
*                  lang      = sy-langu
*                  no        = ls_ret-number
*                  v1        = ls_ret-message_v1
*                  v2        = ls_ret-message_v2
*                  v3        = ls_ret-message_v3
*                  v4        = ls_ret-message_v4
*                IMPORTING
*                  msg       = lv_msg
*                EXCEPTIONS
*                  not_found = 1
*                  OTHERS    = 2.
*              IF sy-subrc <> 0.
** Implement suitable error handling here
*              ENDIF.
*              CONCATENATE  ls_data-msg lv_msg  INTO ls_data-msg SEPARATED BY space.
*              CLEAR lv_msg.
*            ENDLOOP.
*            ls_data-success = 'X'.
**            APPEND ls_data TO lt_processed_data.
**            lv_add = 'X'.
*          ENDIF.
*        ENDIF.
*      ENDIF.
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
      CLEAR :lv_item, ls_docheader, ls_accntpay,lt_accntpay,
             lt_accntgl, lt_curr, lt_ret, lt_charfld.

*      IF lv_add NE 'X'.
      APPEND ls_data TO lt_processed_data.
*      ENDIF.
      CLEAR : lv_add, ls_data.
    ENDLOOP.

*    IF iv_test IS INITIAL.
**>> Send email
*      CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>send_email
*        EXPORTING
*          it_data  = lt_processed_data
*        IMPORTING
*          ex_subrc = DATA(lv_subrc).
*    ENDIF.

  ENDMETHOD.


  METHOD post_document.

    TYPES: BEGIN OF ty_vendor,
             vendor_no TYPE lifnr,
           END OF ty_vendor,
           BEGIN OF ty_comp,
             comp_code TYPE bukrs,
           END OF ty_comp.

    TYPES: tyt_vendor TYPE TABLE OF ty_vendor WITH EMPTY KEY,
           tyt_comp   TYPE TABLE OF ty_comp WITH EMPTY KEY.
    DATA : lt_comp    TYPE tyt_comp,
           lt_input_1 TYPE ztt_ib_counsel_link,
           lv_total   TYPE zst_ib_counsel_link-amt_doccur.

    DATA : lt_vendor         TYPE TABLE OF ty_vendor WITH EMPTY KEY.

    DATA(lt_input) = it_input[].

    lt_vendor = CORRESPONDING #( it_input ).
    SORT lt_vendor BY vendor_no.
    DELETE ADJACENT DUPLICATES FROM lt_vendor COMPARING vendor_no.
    DATA(lt_vendor_1) = lt_vendor.

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


    SELECT * FROM zglmap_inv
      INTO TABLE @DATA(lt_aai_gl)
      WHERE zid = @gv_intf_id.
    IF sy-subrc IS INITIAL.
      SORT lt_aai_gl BY zid zigl zsto.
    ENDIF.


    LOOP AT lt_input ASSIGNING FIELD-SYMBOL(<lfs_input>).
      CLEAR:lt_comp,lv_total.
      LOOP AT <lfs_input>-items ASSIGNING FIELD-SYMBOL(<lfs_item>).
        DATA(lv_prctr) = <lfs_item>-property_no.
        lv_prctr = |{ lv_prctr ALPHA = IN }|.
        CALL METHOD zcl_ps_utility_tools=>get_company_code
          EXPORTING
            iv_object_num  = lv_prctr
            iv_object_type = 'P'
          RECEIVING
            rv_company     = <lfs_item>-comp_code.
        IF <lfs_item>-comp_code IS NOT INITIAL.
           <lfs_item>-object_type = 'P'.
        ELSE.
          CALL METHOD zcl_ps_utility_tools=>get_company_code
            EXPORTING
              iv_object_num  = lv_prctr
              iv_object_type = 'C'
            RECEIVING
              rv_company     = <lfs_item>-comp_code.
          IF <lfs_item>-comp_code IS NOT INITIAL.
             <lfs_item>-object_type = 'C'.
          ENDIF.
        ENDIF.
        IF NOT line_exists( lt_comp[ comp_code = <lfs_item>-comp_code ] ).
          APPEND INITIAL LINE TO lt_comp ASSIGNING FIELD-SYMBOL(<lfs_comp>).
          <lfs_comp>-comp_code = <lfs_item>-comp_code.
        ENDIF.
      ENDLOOP.
      DATA(ls_input) = <lfs_input>.
      LOOP AT lt_comp ASSIGNING <lfs_comp>.
        ls_input-comp_code = <lfs_comp>-comp_code.
        CLEAR: ls_input-items[],lv_total.
        LOOP AT  <lfs_input>-items INTO DATA(ls_item) WHERE comp_code =  <lfs_comp>-comp_code.
          APPEND ls_item TO ls_input-items.
          lv_total = lv_total + ls_item-amt_doccur.
        ENDLOOP.
*        ls_input-items = VALUE #( FOR ls_item IN <lfs_input>-items
*                                              WHERE ( comp_code = <lfs_comp>-comp_code )
*                                             ( ls_item ) ).
        ls_input-amt_doccur = lv_total.
*        ls_input-vendor_no = |{ ls_input-vendor_no ALPHA = IN }|.
        APPEND ls_input TO lt_input_1.
      ENDLOOP.
    ENDLOOP.

**// Simulation check
*    CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>post_acc_document
*      EXPORTING
*        it_input    = lt_input_1
*        it_gl_table = lt_aai_gl
*        it_lfb1     = lt_lfb1_2
*        iv_test     = abap_true
*      IMPORTING
*        et_return   = et_return.
*
**// Actual posting
*    IF NOT line_exists( et_return[ type = 'E' ] ) AND
*       NOT line_exists( et_return[ type = 'A' ] ).
      CLEAR et_return[].
      CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>post_acc_document
        EXPORTING
          it_input    = lt_input_1
          it_gl_table = lt_aai_gl
          it_lfb1     = lt_lfb1_2
          iv_test     = space
        IMPORTING
          et_return   = et_return.
*    ENDIF.

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

    ls_mail_input-mail_to_tvarvc = 'ZFI_INT0009_COUNSEL_LINK_EMAIL'.
    ls_mail_input-mail_subject = 'Legal/Counsel Link AP Transactions'.

    IF it_body IS NOT INITIAL.
     ls_mail_input-mail_body_text = it_body.
    ELSE.
     ls_mail_input-mail_body_text =  VALUE #( ( line = 'Hello,' ) ( line = 'Please find the attached list.' ) ).
    ENDIF.

    ls_mail_input-iv_proc_file_name = 'Legal/CounselLink Posted AP Transactions_' && sy-datum.
    LOOP AT it_data INTO DATA(ls_data) WHERE success IS NOT INITIAL.
     IF lv_first IS INITIAL.
        CONCATENATE lv_content
            'Vendor ID'           gc_tab " vendor_no
            'Invoice No'          gc_tab " ref_doc_no
            'Invoice Date'        gc_tab " doc_date
            'Invoice Amount'      gc_tab " amt_doccur
            'Invoice Description' gc_tab " sgtxt
            'AB Num'              gc_tab " zunor
            'Approved Date'       gc_tab " pstng_date
            'Matter Information'  gc_tab " bktxt
            'Property No'         gc_tab " property_no
            'GL Account'          gc_tab " gl_account
            'GL Amount'           gc_tab " amt_doccur
            'Msg'                 gc_tab " Msg
             gc_crlf
           INTO lv_content.
        lv_first = abap_true.
      ENDIF.
      lv_hdr_amnt = ls_data-amt_doccur.
      CONDENSE lv_hdr_amnt.
     LOOP AT ls_data-items INTO DATA(ls_item).
      lv_itm_amnt = ls_item-amt_doccur.
      CONDENSE lv_itm_amnt.
      CONCATENATE lv_content
            ls_data-vendor_no           gc_tab " vendor_no
            ls_data-ref_doc_no          gc_tab " ref_doc_no
            ls_data-doc_date            gc_tab " doc_date
            lv_hdr_amnt                 gc_tab " amt_doccur
            ls_data-sgtxt               gc_tab " sgtxt
            ls_data-zunor               gc_tab " zunor
            ls_data-pstng_date          gc_tab " pstng_date
            ls_data-bktxt               gc_tab " bktxt
            ls_item-property_no         gc_tab " property_no
            ls_item-gl_account          gc_tab " gl_account
            lv_itm_amnt                 gc_tab " amt_doccur
            ls_data-Msg                 gc_tab " Msg
           gc_crlf
         INTO lv_content.
      ENDLOOP.

    ENDLOOP.

    ls_mail_input-iv_processed_data = lv_content.

    CLEAR:lv_first, lv_content.
    ls_mail_input-iv_error_file_name = 'Legal/CounselLink Error AP Transactions_' && sy-datum.
    LOOP AT it_data INTO ls_data WHERE success IS INITIAL.
     IF lv_first IS INITIAL.
        CONCATENATE lv_content
            'Vendor ID'           gc_tab " vendor_no
            'Invoice No'          gc_tab " ref_doc_no
            'Invoice Date'        gc_tab " doc_date
            'Invoice Amount'      gc_tab " amt_doccur
            'Invoice Description' gc_tab " sgtxt
            'AB Num'              gc_tab " zunor
            'Approved Date'       gc_tab " pstng_date
            'Matter Information'  gc_tab " bktxt
            'Property No'         gc_tab " property_no
            'GL Account'          gc_tab " gl_account
            'GL Amount'           gc_tab " amt_doccur
            'Msg'                 gc_tab " Msg
             gc_crlf
           INTO lv_content.
        lv_first = abap_true.
      ENDIF.
      lv_hdr_amnt = ls_data-amt_doccur.
      CONDENSE lv_hdr_amnt.
     LOOP AT ls_data-items INTO ls_item.
      lv_itm_amnt = ls_item-amt_doccur.
      CONDENSE lv_itm_amnt.
      CONCATENATE lv_content
            ls_data-vendor_no           gc_tab " vendor_no
            ls_data-ref_doc_no          gc_tab " ref_doc_no
            ls_data-doc_date            gc_tab " doc_date
            lv_hdr_amnt                 gc_tab " amt_doccur
            ls_data-sgtxt               gc_tab " sgtxt
            ls_data-zunor               gc_tab " zunor
            ls_data-pstng_date          gc_tab " pstng_date
            ls_data-bktxt               gc_tab " bktxt
            ls_item-property_no         gc_tab " property_no
            ls_item-gl_account          gc_tab " gl_account
            lv_itm_amnt                 gc_tab " amt_doccur
            ls_data-Msg                 gc_tab " Msg
           gc_crlf
         INTO lv_content.
      ENDLOOP.

    ENDLOOP.

    ls_mail_input-iv_error_data = lv_content.

    CALL METHOD zcl_ps_utility_tools=>send_email
      EXPORTING
        is_input = ls_mail_input
      RECEIVING
        rv_subrc = DATA(lv_subrc).

  ENDMETHOD.
ENDCLASS.

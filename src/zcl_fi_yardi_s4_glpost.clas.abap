class ZCL_FI_YARDI_S4_GLPOST definition
  public
  final
  create public .

public section.

  methods POST_FINANCIAL
    importing
      value(GT_DATA) type ZFIT_YARDI_S4_GL_POST
    exporting
      value(GT_RETURN) type BAPIRET2_T .
  methods POST_STATISTICAL
    importing
      value(GT_DATA) type ZFIT_YARDI_S4_GL_POST
    exporting
      value(GT_RETURN) type BAPIRET2_T .
  methods SEND_MAIL
    importing
      value(ET_DATA) type ZFIT_YARDI_S4_GL_POST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_YARDI_S4_GLPOST IMPLEMENTATION.


  METHOD post_financial.

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
           gt_withtx    TYPE TABLE OF bapiacwt09,
           gs_ret       TYPE bapiret2,
           lv_fyear     TYPE bapi0002_4-fiscal_year,
           lv_item      TYPE posnr_acc,
           lv_amnt      TYPE p DECIMALS 2,
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           er_data      TYPE zfit_yardi_s4_gl_post,
           ls_data      TYPE zfis_yardi_s4_gl_post,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           lv_prctr     TYPE prctr,
           lv_add       TYPE c.

    SORT gt_data BY zcounter.
    CLEAR lv_add.
    LOOP AT gt_data INTO DATA(ls_data1).
      CLEAR :ls_data,lv_prctr.
      ls_data = ls_data1.
      lv_prctr = ls_data-zpropid = to_upper( ls_data-zpropid ).
      lv_prctr = |{ lv_prctr ALPHA = IN }|.
*      CLEAR  lv_item.
      AT NEW zcounter.
        lv_item = '1'.
        gs_docheader-bus_act = 'RFBU'.
        gs_docheader-username = sy-uname.
*        ls_data-zpropid = to_upper( ls_data-zpropid ).
        SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prctr.
*      gs_docheader-comp_code = ls_data-bukrs.
        gs_docheader-doc_date = ls_data-budat. "ls_data-bldat.
        gs_docheader-pstng_date = ls_data-bldat. "ls_data-budat.
        gs_docheader-doc_type =  'YY'.
        gs_docheader-header_txt = ls_data-bktxt.
        gs_docheader-ref_doc_no = ls_data-zpropid.
*       . CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
*          EXPORTING
*            companycodeid = gs_docheader-comp_code
*            posting_date  = ls_data-budat
*          IMPORTING
*            fiscal_year   = lv_fyear
**           FISCAL_PERIOD =
**           RETURN        =
*          .
*        gs_docheader-fisc_year = lv_fyear.
      ENDAT.

      gs_accntgl-itemno_acc = lv_item.
      gs_accntgl-gl_account = |{ ls_data-hkont ALPHA = IN }|.  ""logic to identify OPEX and CAPEX accounts
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = lv_prctr.
      SELECT SINGLE kstar FROM cska INTO @DATA(lv_kstar) WHERE kstar = @gs_accntgl-gl_account.
      IF sy-subrc EQ 0.
*        SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @lv_prctr.
*        IF sy-subrc EQ 0.
          gs_accntgl-costcenter = lv_prctr.
*        ENDIF.
      ELSE.
*        gs_accntgl-profit_ctr  = ls_data-zpropid.
        gs_accntgl-profit_ctr = lv_prctr.
      ENDIF.

      SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account
                                                               and KTOPL = 'PSUS'.
*      gs_accntgl-item_text = ls_data-ztext.
*      gs_accntgl-acct_type = 'A'."only if the invoice is to be posted to an Asset (CAPEX transactions that are within the threshold defined
*      gs_accntgl-alloc_nmbr = ls_data-zuonr.
      IF lv_xbilk = space.
*        SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-zpropid.
*        IF sy-subrc EQ 0.
*          gs_accntgl-costcenter = lv_kostl.
*        ENDIF.
*        gs_accntgl-profit_ctr  = ls_data-zpropid.
        gs_charfld-itemno_acc = lv_item.
        gs_charfld-fieldname = 'PRCTR'.
        gs_charfld-character = lv_prctr. "gs_accntgl-profit_ctr.
        APPEND gs_charfld TO gt_charfld.
        CLEAR gs_charfld.
*        gs_charfld-itemno_acc = lv_item.
*        gs_charfld-fieldname = 'KOSTL'.
*        gs_charfld-character = gs_accntgl-costcenter.
*        APPEND gs_charfld TO gt_charfld.
*        CLEAR gs_charfld.
      ENDIF.
      gs_accntgl-item_text = 'CBT'.
      APPEND gs_accntgl TO gt_accntgl.
      CLEAR gs_accntgl.

      ""Currency amounts
      gs_curr-itemno_acc = lv_item.
      gs_curr-currency = 'USD'.
      CLEAR lv_amnt.
      REPLACE ',' IN ls_data-dmbtr WITH ' '.
      CONDENSE ls_data-dmbtr.
      lv_amnt =  ls_data-dmbtr.
      gs_curr-amt_doccur = lv_amnt.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.
      lv_item = lv_item + 1.
      AT END OF zcounter.
*        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*          EXPORTING
*            documentheader = gs_docheader
**           CUSTOMERCPD    =
**           CONTRACTHEADER =
** IMPORTING
**           OBJ_TYPE       =
**           OBJ_KEY        =
**           OBJ_SYS        =
*          TABLES
*            accountgl      = gt_accntgl
**           ACCOUNTRECEIVABLE       =
**           accountpayable = gt_accntpay
**           accounttax     = gt_accntax
*            currencyamount = gt_curr
*            criteria       = gt_charfld
**           VALUEFIELD     =
**           EXTENSION1     =
*            return         = gt_ret
**           PAYMENTCARD    =
**           CONTRACTITEM   =
**           EXTENSION2     =
**           REALESTATE     =
**           ACCOUNTWT      =
*          .

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

*        READ TABLE gt_ret INTO DATA(ls_ret) WITH KEY type = 'E'.
*        IF sy-subrc EQ 0.
*         clear: lv_msg1, lv_msg.
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*          LOOP AT gt_ret INTO ls_ret WHERE type = 'E'.
*            CALL FUNCTION 'FORMAT_MESSAGE'
*              EXPORTING
*                id        = ls_ret-id
*                lang      = sy-langu
*                no        = ls_ret-number
*                v1        = ls_ret-message_v1
*                v2        = ls_ret-message_v2
*                v3        = ls_ret-message_v3
*                v4        = ls_ret-message_v4
*              IMPORTING
*                msg       = lv_msg1
*              EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.
*            IF sy-subrc <> 0.
** Implement suitable error handling here
*            ENDIF.
*            CONCATENATE  ls_data-msg lv_msg1 INTO ls_data-msg SEPARATED BY space.
*            CLEAR lv_msg1.
*          ENDLOOP.
*
*          ls_data-success = ' '.
*          APPEND ls_data TO er_data.
*          lv_add = 'X'.
*        ELSE.
*          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*            EXPORTING
*              wait = abap_true.
*          CLEAR lv_msg.
*          LOOP AT gt_ret INTO ls_ret WHERE type = 'S'.
*            CALL FUNCTION 'FORMAT_MESSAGE'
*              EXPORTING
*                id        = ls_ret-id
*                lang      = sy-langu
*                no        = ls_ret-number
*                v1        = ls_ret-message_v1
*                v2        = ls_ret-message_v2
*                v3        = ls_ret-message_v3
*                v4        = ls_ret-message_v4
*              IMPORTING
*                msg       = lv_msg
*              EXCEPTIONS
*                not_found = 1
*                OTHERS    = 2.
*            IF sy-subrc <> 0.
** Implement suitable error handling here
*            ENDIF.
*            CONCATENATE  ls_data-msg lv_msg  INTO ls_data-msg SEPARATED BY space.
*            CLEAR lv_msg.
*          ENDLOOP.
*          ls_data-success = 'X'.
*          APPEND ls_data TO er_data.
*          lv_add = 'X'.
*        ENDIF.
*        LOOP AT gt_ret INTO ls_ret.
*          CLEAR gs_ret.
*          gs_ret = CORRESPONDING #( ls_ret ).
*          APPEND gs_ret TO gt_return.
*        ENDLOOP.
        CLEAR : lv_item, gs_docheader.
        REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld.
      ENDAT.
*      IF lv_add NE 'X'.
*      APPEND ls_data TO er_data.
*      ENDIF.
      CLEAR : lv_add, ls_data.
    ENDLOOP.

*    DATA(lr_mail) = NEW zcl_fi_yardi_s4_glpost( ).
*
*    CALL METHOD lr_mail->send_mail
*      EXPORTING
*        et_data = er_data.


*  ENDLOOP.
  ENDMETHOD.


  method POST_STATISTICAL.



LOOP AT gt_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
*      CLEAR  lv_item.
      AT NEW zcounter.


      ENDAT.
*    CALL FUNCTION 'BAPI_ACC_POST_STAT_KEYFIGURE'
*      EXPORTING
*        documentheader       =
*      tables
*        linedata             =
*        extension1           =
*        return               =
*              .



ENDLOOP.
  endmethod.


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
    CONSTANTS:
      gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
      gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.
*          lt_text TYPE ANY TABLE.
    DATA: l_text TYPE string.     " Text content for mail attachment
    DATA: l_con(50) TYPE c.        " Field Content in character format
    DATA(lt_tmp) = et_data[].
    DATA(lt_success) = et_data[].
    LOOP AT lt_tmp INTO DATA(wa_data).
      IF wa_data-success = 'X'.
        LOOP AT lt_success ASSIGNING FIELD-SYMBOL(<fs_sucs>) WHERE zcounter = wa_data-zcounter.
          <fs_sucs>-success = 'X'.
          <fs_sucs>-msg = wa_data-msg.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    DATA(lt_fail) = lt_success[].
    DELETE lt_fail WHERE success = 'X'.
    LOOP AT lt_tmp INTO wa_data.
    IF wa_data-success NE 'X'.
    LOOP AT lt_fail ASSIGNING FIELD-SYMBOL(<fs_fai>) WHERE zcounter = wa_data-zcounter.
    <fs_fai>-msg =  wa_data-msg.
    ENDLOOP.
    endif.
    ENDLOOP.
    DELETE lt_success WHERE success = ' '.
    SELECT SINGLE low FROM TVARVC INTO mailto WHERE name = 'ZFI_INT0027_EMAIL_NOTIF'.
      CONDENSE mailto.
*    mailto = 'sbhagat@publicstorage.com'.
    CREATE OBJECT document.
    LOOP AT lt_success ASSIGNING FIELD-SYMBOL(<fs_scs>).
      CONCATENATE l_text
  <fs_scs>-zcounter gc_tab
  <fs_scs>-zpropid gc_tab
  <fs_scs>-budat gc_tab
  <fs_scs>-bldat gc_tab
  <fs_scs>-bktxt gc_tab
  <fs_scs>-dmbtr gc_tab
  <fs_scs>-hkont gc_tab
  <fs_scs>-msg gc_crlf
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
    CLEAR l_text.
    LOOP AT lt_fail ASSIGNING FIELD-SYMBOL(<fs_fail>).
      CONCATENATE l_text
      <fs_fail>-zcounter gc_tab
      <fs_fail>-zpropid gc_tab
      <fs_fail>-budat gc_tab
      <fs_fail>-bldat gc_tab
      <fs_fail>-bktxt gc_tab
      <fs_fail>-dmbtr gc_tab
      <fs_fail>-hkont gc_tab
      <fs_fail>-msg gc_crlf
      INTO l_text.
    ENDLOOP.
    TRY.
        cl_bcs_convert=>string_to_solix(
          EXPORTING
            iv_string   = l_text
            iv_codepage = '4103'  "suitable for MS Excel, leave empty
            iv_add_bom  = 'X'     "for other doc types
          IMPORTING
            et_solix  = binary_content1
            ev_size   = size1 ).
      CATCH cx_bcs.
        MESSAGE e445(so).
    ENDTRY.
    TRY.

*     -------- create persistent send request ------------------------
        send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
        APPEND 'Yardi to S4 postings status' TO main_text.  "#EC NOTEXT
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
          i_subject = 'Yardi to S4 postings status' ).      "#EC NOTEXT

*     add the spread sheet as attachment to document object
        document->add_attachment(
          i_attachment_type    = 'xls'                      "#EC NOTEXT
          i_attachment_subject = 'Success_file'             "#EC NOTEXT
          i_attachment_size    = size
          i_att_content_hex    = binary_content ).

*   add the spread sheet as attachment to document object
        document->add_attachment(
          i_attachment_type    = 'xls'                      "#EC NOTEXT
          i_attachment_subject = 'Failed_file'              "#EC NOTEXT
          i_attachment_size    = size1
          i_att_content_hex    = binary_content1 ).

*     add document object to send request
        send_request->set_document( document ).
*     create recipient object
        recipient = cl_cam_address_bcs=>create_internet_address( mailto ).

*     add recipient object to send request
        send_request->add_recipient( recipient ).

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

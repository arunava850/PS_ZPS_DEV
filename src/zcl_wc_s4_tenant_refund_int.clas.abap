class ZCL_WC_S4_TENANT_REFUND_INT definition
  public
  final
  create public .

public section.

  methods POST_DOCUMENT
    importing
      value(GT_DATA) type ZFIT_WC_S4_TENANT_REFUND_INT
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type STANDARD TABLE optional
    exporting
      value(IT_RET2) type BAPIRET2_T .
  methods SEND_MAIL
    importing
      value(GT_DATA) type ZFIT_WC_S4_TENANT_REFUND_INT optional
      value(EV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type STANDARD TABLE optional .
protected section.
private section.
ENDCLASS.



CLASS ZCL_WC_S4_TENANT_REFUND_INT IMPLEMENTATION.


  METHOD post_document.

    TYPES : BEGIN OF ty_file,
              ztran_id(9)         TYPE c,
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
              comments(1024)      TYPE c,
            END OF ty_file.

    DATA : gt_error TYPE TABLE OF ty_file,
           gs_error TYPE ty_file.
    DATA : gs_docheader TYPE bapiache09,
           gt_ret       TYPE TABLE OF bapiret2,
           gt_withtx    TYPE TABLE OF bapiacwt09,
           gt_accntgl   TYPE TABLE OF bapiacgl09,
           gs_accntgl   TYPE bapiacgl09,
           gt_accntpay  TYPE TABLE OF bapiacap09,
           gs_accntpay  TYPE bapiacap09,
           gt_curr      TYPE TABLE OF bapiaccr09,
           gs_curr      TYPE bapiaccr09,
           gt_accntax   TYPE TABLE OF bapiactx09,
           gs_accntax   TYPE bapiactx09,
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           gs_ret       TYPE bapiret2,
           lv_fyear     TYPE bapi0002_4-fiscal_year,
           lv_period    TYPE bapi0002_4-fiscal_period,
           lt_data      TYPE zfit_ebuildr_s4_accpay,
           lv_ANLN1     TYPE anln1,
           gt_bapiret2  TYPE bapiret2_tt,
           lv_subasset  TYPE bapi1022_1-assetsubno,
           lv_item      TYPE posnr_acc,
           lv_key       TYPE char42,
           lv_chk       TYPE c,
           lv_prctr     TYPE prctr,
           lv_msg       TYPE string,
           lv_msg1      TYPE string.

    gt_error = CORRESPONDING #( gt_file[] ).
    SORT gt_data BY xblnr.
    LOOP AT gt_data INTO DATA(ls_data1).
      DATA(ls_data) = ls_data1.
*      IF ls_data-bukrs IS NOT INITIAL.
*        DATA(ls_lif) = |{ ls_data-saknr ALPHA = IN }|.
*        SELECT SINGLE saknr FROM ska1 INTO @DATA(ls_lif_tmp) WHERE saknr = @ls_lif.
*        IF sy-subrc EQ 0.
          AT NEW xblnr." zcontactid.
            gs_docheader-obj_type = 'BKPFF'.
            gs_docheader-bus_act = 'RFBU'.
            gs_docheader-username = sy-uname.
            gs_docheader-comp_code = ls_data-bukrs.
            gs_docheader-doc_date = ls_data-bldat.
            gs_docheader-pstng_date = ls_data-budat.
            gs_docheader-doc_type =  ls_data-blart.
            gs_docheader-ref_doc_no  = ls_data-xblnr.
            lv_item = '1'.
            CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
              EXPORTING
                companycodeid = ls_data-bukrs
                posting_date  = ls_data-budat
              IMPORTING
                fiscal_year   = lv_fyear
                fiscal_period = lv_period
*               RETURN        =
              .
            gs_docheader-fisc_year = lv_fyear.
            gs_docheader-fis_period = lv_period.

            gs_accntpay-itemno_acc  = lv_item.
            gs_accntpay-vendor_no = |{ ls_data-lifnr ALPHA = IN }|.
*      gs_accntpay-acct_type = 'K'.
*      gs_accntpay-profit_ctr = 'PS_CORP'.
            APPEND gs_accntpay TO gt_accntpay.
            CLEAR gs_accntpay.

            ""Currency amounts
            gs_curr-itemno_acc = lv_item.
            gs_curr-currency = 'USD'.
            gs_curr-amt_doccur = ls_data-cr_amnt * -1.
            gs_curr-amt_base = ls_data-cr_amnt * -1.
* gs_curr-TAX_AMT = ls_data-MWSTS.
            APPEND gs_curr TO gt_curr.
            CLEAR gs_curr.
          ENDAT.
          ""*ACCOUNTGL
          gs_accntgl-itemno_acc = lv_item + 1.
          gs_accntgl-gl_account = |{ ls_data-saknr ALPHA = IN }|.
          gs_accntgl-alloc_nmbr = ls_data-zuonr.
          SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
          gs_accntgl-costcenter = ls_data-prctr. " lv_kostl.
          gs_accntgl-profit_ctr  = ls_data-prctr.
          APPEND gs_accntgl TO gt_accntgl.


          SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account
                                                              and  ktopl = 'PSUS'.
          IF lv_xbilk = space.
            gs_charfld-itemno_acc = lv_item + 1.
            gs_charfld-fieldname = 'PRCTR'.
            gs_charfld-character = gs_accntgl-profit_ctr.
            APPEND gs_charfld TO gt_charfld.
            CLEAR gs_charfld.
          ENDIF.
          CLEAR gs_accntgl.

          gs_curr-itemno_acc = lv_item + 1.
          gs_curr-currency = 'USD'.
          gs_curr-amt_doccur = ls_data-dr_amnt.
          gs_curr-amt_base =  ls_data-dr_amnt .
*  AMT_BASE = ??
*      gs_curr-tax_amt = ls_data-mwsts.
          APPEND gs_curr TO gt_curr.
          CLEAR gs_curr.
          lv_item = lv_item + 1.
          AT END OF xblnr. " zcontactid.
*            CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
*              EXPORTING
*                documentheader = gs_docheader
**               CUSTOMERCPD    =
**               CONTRACTHEADER =
** IMPORTING
**               OBJ_TYPE       =
**               OBJ_KEY        =
**               OBJ_SYS        =
*              TABLES
*                accountgl      = gt_accntgl
**               ACCOUNTRECEIVABLE       =
*                accountpayable = gt_accntpay
*                accounttax     = gt_accntax
*                currencyamount = gt_curr
*                criteria       = gt_charfld
**               VALUEFIELD     =
**               EXTENSION1     =
*                return         = gt_ret
**               PAYMENTCARD    =
**               CONTRACTITEM   =
**               EXTENSION2     =
**               REALESTATE     =
**               ACCOUNTWT      =
*              .
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
           ACCOUNTPAYABLE =  gt_accntpay
           ACCOUNTTAX     = gt_accntax
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

*            READ TABLE gt_ret INTO DATA(ls_ret) WITH KEY type = 'E'.
*            IF sy-subrc EQ 0..
*              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*              CLEAR lv_msg.
*              LOOP AT gt_ret INTO ls_ret WHERE type = 'E'.
*                CALL FUNCTION 'FORMAT_MESSAGE'
*                  EXPORTING
*                    id        = ls_ret-id
*                    lang      = sy-langu
*                    no        = ls_ret-number
*                    v1        = ls_ret-message_v1
*                    v2        = ls_ret-message_v2
*                    v3        = ls_ret-message_v3
*                    v4        = ls_ret-message_v4
*                  IMPORTING
*                    msg       = lv_msg1
*                  EXCEPTIONS
*                    not_found = 1
*                    OTHERS    = 2.
*                IF sy-subrc <> 0.
** Implement suitable error handling here
*                ENDIF.
*                CONCATENATE  lv_msg lv_msg1 INTO lv_msg SEPARATED BY space.
*                CLEAR lv_msg1.
*              ENDLOOP.
*              LOOP AT gt_error ASSIGNING FIELD-SYMBOL(<fs_error>) WHERE ztran_id = ls_data-xblnr.
*                <fs_error>-comments = lv_msg.
*              ENDLOOP.
*              CLEAR lv_msg.
*            ELSE.
*              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*                EXPORTING
*                  wait = abap_true.
*              CLEAR lv_msg.
*              LOOP AT gt_ret INTO ls_ret WHERE type = 'S'.
*                CALL FUNCTION 'FORMAT_MESSAGE'
*                  EXPORTING
*                    id        = ls_ret-id
*                    lang      = sy-langu
*                    no        = ls_ret-number
*                    v1        = ls_ret-message_v1
*                    v2        = ls_ret-message_v2
*                    v3        = ls_ret-message_v3
*                    v4        = ls_ret-message_v4
*                  IMPORTING
*                    msg       = lv_msg1
*                  EXCEPTIONS
*                    not_found = 1
*                    OTHERS    = 2.
*                IF sy-subrc <> 0.
** Implement suitable error handling here
*                ENDIF.
*                CONCATENATE  lv_msg lv_msg1 INTO lv_msg SEPARATED BY space.
*                CLEAR lv_msg1.
*              ENDLOOP.
*              LOOP AT gt_error ASSIGNING <fs_error> WHERE ztran_id = ls_data-xblnr.
*                <fs_error>-comments = lv_msg.
*              ENDLOOP.
*
*            ENDIF.
*            LOOP AT gt_ret INTO ls_ret WHERE type = 'E' OR type = 'S' .
*              CLEAR gs_ret.
*              gs_ret = CORRESPONDING #( ls_ret ).
*              APPEND gs_ret TO it_ret2.
*            ENDLOOP.
*    ENDLOOP.
            CLEAR : lv_chk, lv_item, gs_docheader, lv_prctr.
            REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr, gt_charfld.
          ENDAT.
*        ELSE.
**          CONCATENATE 'Invalid G/L account ' ls_data-saknr INTO gs_ret-message.
**          gs_ret-type = 'E'.
**          LOOP AT gt_error ASSIGNING <fs_error> WHERE ztran_id = ls_data-xblnr.
**            <fs_error>-comments = gs_ret-message.
**          ENDLOOP.
**          APPEND gs_ret TO it_ret2.
**          CLEAR gs_ret.
*        ENDIF.
*      ELSE.
**        CONCATENATE 'No company code found for profit center ' ls_data-prctr INTO gs_ret-message.
**        gs_ret-type = 'E'.
**        LOOP AT gt_error ASSIGNING <fs_error> WHERE ztran_id = ls_data-xblnr.
**          <fs_error>-comments = gs_ret-message.
**        ENDLOOP.
**        APPEND gs_ret TO it_ret2.
**        CLEAR gs_ret.

*      ENDIF.
    ENDLOOP.
*    DATA(lr_mail) = NEW zcl_wc_s4_tenant_refund_int( ).
*
*    CALL METHOD lr_mail->send_mail
*      EXPORTING
*        gt_data = gt_data
**       ev_dl   =
*        gt_file = gt_error.

  ENDMETHOD.


  METHOD send_mail.
    TYPES : BEGIN OF ty_file,
              ztran_id(9)         TYPE c,
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
              comments(1024)      TYPE c,
            END OF ty_file.

    DATA : gt_send TYPE TABLE OF ty_file,
           gs_send TYPE ty_file.
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
    gt_send = CORRESPONDING #( gt_file[] ).

    mailto = 'ndasharth@publicstorage.com'.
    CREATE OBJECT document.
    LOOP AT gt_send ASSIGNING FIELD-SYMBOL(<fs_scs>).
      CONCATENATE l_text
  <fs_scs>-ztran_id gc_tab
  <fs_scs>-tot_refund gc_tab
  <fs_scs>-zsiteno gc_tab
  <fs_scs>-zcontactid gc_tab
  <fs_scs>-zsuppl_no gc_tab
  <fs_scs>-zlob gc_tab
  <fs_scs>-refnd_line_amnt gc_tab
  <fs_scs>-custmr_unt gc_tab
  <fs_scs>-date gc_tab
    <fs_scs>-refnd_typ gc_tab
    <fs_scs>-wc_code gc_tab
    <fs_scs>-comments gc_crlf
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
*        MESSAGE e445(so).
    ENDTRY.
 TRY.
*     -------- create persistent send request ------------------------
    send_request = cl_bcs=>create_persistent( ).

*     -------- create and set document with attachment ---------------
*     create document object from internal table with text
    APPEND 'Webchamp to S4 Tenant refund postings' TO main_text. "#EC NOTEXT
    document = cl_document_bcs=>create_document(
      i_type    = 'RAW'
      i_text    = main_text
      i_subject = 'Webchamp to S4 postings status' ).       "#EC NOTEXT

*     add the spread sheet as attachment to document object
    document->add_attachment(
      i_attachment_type    = 'xls'                          "#EC NOTEXT
      i_attachment_subject = 'Status_file'                  "#EC NOTEXT
      i_attachment_size    = size
      i_att_content_hex    = binary_content ).
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

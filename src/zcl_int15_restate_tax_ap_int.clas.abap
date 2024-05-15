class ZCL_INT15_RESTATE_TAX_AP_INT definition
  public
  final
  create public .

public section.

  methods POST_DOCUMENT
    importing
      value(GT_DATA) type ZFIT_INT15_REST_TAX_AP
      value(GT_FILE) type ANY TABLE optional
      value(GV_BLART) type BLART optional
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
    exporting
      value(GT_RETURN) type BAPIRET2_T .
  methods SEND_MAIL
    importing
      value(GT_DATA) type ZFIT_INT15_REST_TAX_AP optional
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type ANY TABLE .
  methods SEND_MAIL_NEW
    importing
      value(GT_DATA) type ZFIT_INT15_REST_TAX_AP optional
      value(GV_DL) type SOOBJINFI1-OBJ_NAME optional
      value(GT_FILE) type ANY TABLE
    exceptions
      EO_BCS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INT15_RESTATE_TAX_AP_INT IMPLEMENTATION.


  METHOD post_document.
    TYPES : BEGIN OF ty_file,
              status(7)        TYPE c,
              message(1024)    TYPE c,
              idoc_no(16)      TYPE n,
              apchkrno(110)    TYPE c,
              exportno(40)     TYPE c,
              appmntmhd(20)    TYPE c,
              state(30)        TYPE c,
              jurisdict(80)    TYPE c,
              aptxbillid(90)   TYPE c,
              txbillglno(100)  TYPE c,
              taxyear(10)      TYPE c,
              apreqdate(10)    TYPE c,
              apinstlmntno(10) TYPE c,
              aptaxtyp(10)     TYPE c,
              appyeid(100)     TYPE c,
              adrsbkvndr(75)   TYPE c,
              apvndrnam(50)    TYPE c,
              prprtyid(225)    TYPE c,
              parcel(150)      TYPE c,
              apnetpyamnt(20)  TYPE c,
              gldate(10)       TYPE c,
              txbillno(80)     TYPE c,
              usecod11(10)     TYPE c,
            END OF ty_file.

    DATA : gt_statfile TYPE TABLE OF ty_file,
           gs_statfile TYPE ty_file.

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
           gt_charfld   TYPE TABLE OF bapiackec9,
           gs_charfld   TYPE bapiackec9,
           gt_withtx    TYPE TABLE OF bapiacwt09,
           gs_ret       TYPE bapiret2,
           lv_fyear     TYPE bapi0002_4-fiscal_year,
           lv_period    TYPE bapi0002_4-fiscal_period,
           lv_item      TYPE posnr_acc,
           lv_msg       TYPE string,
           lv_msg1      TYPE string,
           ls_data      TYPE zfi_int15_rest_tax_ap.
    DATA: lv_idocno TYPE edi_docnum.
    gt_statfile = CORRESPONDING #( gt_file ).
    LOOP AT gt_statfile ASSIGNING FIELD-SYMBOL(<fs_file>).
      CLEAR ls_data.
      CONCATENATE <fs_file>-apchkrno <fs_file>-exportno INTO ls_data-xblnr SEPARATED BY space.
      ls_data-zuonr = <fs_file>-appmntmhd.
      ls_data-saknr = <fs_file>-txbillglno.
      ls_data-saknr = |{ ls_data-saknr ALPHA = IN }|.
      DATA(lv_dd1) = <fs_file>-apreqdate+8(2).
      DATA(lv_mm1) = <fs_file>-apreqdate+5(2).
      DATA(lv_yy1) = <fs_file>-apreqdate+0(4).
      CONCATENATE lv_yy1 lv_mm1 lv_dd1 INTO ls_data-duedat.
*ls_data-DUEDAT = <fs_file>-apreqdate.
      ls_data-bktxt = <fs_file>-apinstlmntno.
      DATA(lv_dd) = <fs_file>-gldate+8(2).
      DATA(lv_mm) = <fs_file>-gldate+5(2).
      DATA(lv_yy) = <fs_file>-gldate+0(4).
      CONCATENATE lv_yy lv_mm lv_dd INTO ls_data-budat.
      CONCATENATE <fs_file>-aptaxtyp <fs_file>-parcel INTO ls_data-sgtxt.
      ls_data-lifnr = <fs_file>-adrsbkvndr.
*      ls_data-lifnr = |{ ls_data-lifnr ALPHA = IN }|.
      ls_data-prctr = <fs_file>-prprtyid.
      ls_data-wrbtr = <fs_file>-apnetpyamnt.
      ls_data-bldat = ls_data-budat.
      ls_data-blart = gv_blart.
*      CONCATENATE <fs_file>-taxtyp <fs_file>-gldate INTO
*lv_prctr = <fs_file>-prprtyid.
      ls_data-prctr = |{ ls_data-prctr ALPHA = IN }|.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO ls_data-bukrs WHERE prctr = ls_data-prctr.
*    APPEND ls_data TO gt_data.
*    CLEAR:  ls_data, <fs_file>.
*  ENDLOOP.
*    LOOP AT gt_data INTO DATA(ls_data).
*      IF ls_data-bukrs IS NOT INITIAL.
*        DATA(ls_lif) = |{ ls_data-saknr ALPHA = IN }|.
*        SELECT SINGLE saknr FROM ska1 INTO @DATA(ls_lif_tmp) WHERE saknr = @ls_lif.
*        IF sy-subrc EQ 0.
      gs_docheader-obj_type = 'BKPFF'.
      gs_docheader-bus_act = 'RFBU'.
      gs_docheader-doc_status = '3'.  ""Parked = 3
      gs_docheader-username = sy-uname.
      gs_docheader-comp_code = ls_data-bukrs.
      gs_docheader-doc_date = ls_data-bldat.
      gs_docheader-pstng_date = ls_data-budat.
      gs_docheader-doc_type =  ls_data-blart.
      gs_docheader-ref_doc_no  = ls_data-xblnr.
      gs_docheader-header_txt = ls_data-bktxt.
*      gs_docheader-duedate = ls_data-duedat.
      lv_item = '1'.
      CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
        EXPORTING
          companycodeid = ls_data-bukrs
          posting_date  = ls_data-budat
        IMPORTING
          fiscal_year   = lv_fyear
          fiscal_period = lv_period
*         RETURN        =
        .
      gs_docheader-fisc_year = lv_fyear.
      gs_docheader-fis_period = lv_period.

      gs_accntpay-itemno_acc  = lv_item.
*** Begin of change by Pavan for TR DS4K903541
*      SELECT SINGLE lifnr FROM lfb1 INTO gs_accntpay-vendor_no WHERE altkn = ls_data-lifnr
*                                                                AND bukrs = ls_data-bukrs.
      gs_accntpay-vendor_no = |{ ls_data-lifnr ALPHA = IN }|.
*** End of change by Pavan for TR DS4K903541
      gs_accntpay-bline_date = ls_data-duedat.
      gs_accntpay-item_text = ls_data-sgtxt.
      APPEND gs_accntpay TO gt_accntpay.
      CLEAR gs_accntpay.

      ""Currency amounts
      gs_curr-itemno_acc = lv_item.
      gs_curr-currency = 'USD'.
      gs_curr-amt_doccur = ls_data-wrbtr * -1.
      gs_curr-amt_base = ls_data-wrbtr * -1.
* gs_curr-TAX_AMT = ls_data-MWSTS.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.
      ""*ACCOUNTGL
      gs_accntgl-itemno_acc = lv_item + 1.
*** Begin of change by Pavan for TR DS4K903541
*      SELECT SINGLE saknr INTO gs_accntgl-gl_account FROM zfi_jde_gl_map WHERE zjde_gl = ls_data-saknr.
**                                                    AND   altkt = .
      gs_accntgl-gl_account = |{ ls_data-saknr ALPHA = IN }|.
*** End of change by Pavan for TR DS4K903541
      gs_accntgl-alloc_nmbr = ls_data-zuonr.
      gs_accntgl-item_text = ls_data-sgtxt.
      SELECT SINGLE kostl INTO @DATA(lv_kostl) FROM csks WHERE kokrs = 'PSCO' AND prctr = @ls_data-prctr.
*      gs_accntgl-costcenter = ls_data-prctr. " lv_kostl.
      gs_accntgl-profit_ctr  = ls_data-prctr.
      APPEND gs_accntgl TO gt_accntgl.
      SELECT SINGLE xbilk INTO @DATA(lv_xbilk) FROM ska1 WHERE saknr = @gs_accntgl-gl_account
                                                          AND  ktopl = 'PSUS'.
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
      gs_curr-amt_doccur = ls_data-wrbtr.
      gs_curr-amt_base =  ls_data-wrbtr .
*  AMT_BASE = ??
*      gs_curr-tax_amt = ls_data-mwsts.
      APPEND gs_curr TO gt_curr.
      CLEAR gs_curr.


      CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = gs_docheader
        IMPORTING
          ev_docnum      = lv_idocno
        TABLES
          accountgl      = gt_accntgl
*         ACCOUNTRECEIVABLE       =
          accountpayable = gt_accntpay
*         ACCOUNTTAX     =
          currencyamount = gt_curr
          criteria       = gt_charfld
*         VALUEFIELD     =
*         EXTENSION1     =
          return         = gt_ret
*         PAYMENTCARD    =
*         CONTRACTITEM   =
*         EXTENSION2     =
*         REALESTATE     =
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
      REFRESH : gt_accntgl, gt_accntpay, gt_accntax, gt_curr, gt_charfld, gt_ret.
      CLEAR : gs_docheader, lv_idocno.
    ENDLOOP.
    IF gt_statfile IS NOT INITIAL.
      DATA(lo_mail) = NEW zcl_int15_restate_tax_ap_int( ).
      CALL METHOD lo_mail->send_mail_new
        EXPORTING
*         gt_data =
          gv_dl   = gv_dl
          gt_file = gt_statfile.

    ENDIF.
  ENDMETHOD.


  METHOD send_mail.
    TYPES : BEGIN OF ty_file,
              apchkrno(110)    TYPE c,
              exportno(40)     TYPE c,
              appmntmhd(20)    TYPE c,
              state(30)        TYPE c,
              jurisdict(80)    TYPE c,
              aptxbillid(90)   TYPE c,
              txbillglno(100)  TYPE c,
              taxyear(10)      TYPE c,
              apreqdate(10)    TYPE c,
              apinstlmntno(10) TYPE c,
              aptaxtyp(10)     TYPE c,
              appyeid(100)     TYPE c,
              adrsbkvndr(75)   TYPE c,
              apvndrnam(50)    TYPE c,
              prprtyid(225)    TYPE c,
              parcel(150)      TYPE c,
              apnetpyamnt(20)  TYPE c,
              gldate(10)       TYPE c,
              txbillno(80)     TYPE c,
              usecod11(10)     TYPE c,
              comments         TYPE string,
            END OF ty_file.

    DATA : gt_mail TYPE TABLE OF ty_file,
           gs_mail TYPE ty_file.

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

* gt_mail[] = gt_file[].
*    LOOP AT gt_mail ASSIGNING FIELD-SYMBOL(<fs_scs>).
*      CONCATENATE l_text
*  <fs_scs>-apchkrno gc_tab
*  <fs_scs>-exportno gc_tab
*  <fs_scs>-appmntmhd gc_tab
*  <fs_scs>-state gc_tab
*  <fs_scs>-jurisdict gc_tab
*  <fs_scs>-aptxbillid gc_tab
*  <fs_scs>-txbillglno gc_tab
*  <fs_scs>-taxyear gc_tab
*  <fs_scs>-apreqdate gc_tab
*    <fs_scs>-apinstlmntno gc_tab
*    <fs_scs>-aptaxtyp gc_tab
*  <fs_scs>-aptaxtyp gc_tab
*  <fs_scs>-appyeid gc_tab
*  <fs_scs>-adrsbkvndr gc_tab
*  <fs_scs>-apvndrnam gc_tab
*  <fs_scs>-prprtyid gc_tab
*  <fs_scs>-parcel gc_tab
*  <fs_scs>-apnetpyamnt gc_tab
*    <fs_scs>-gldate gc_tab
*      <fs_scs>-txbillno gc_tab
*   <fs_scs>-usecod11 gc_tab
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
*        APPEND 'OneSource to S/4HANA Real Estate Tax AP Postings Status' TO main_text. "#EC NOTEXT
        CLEAR lv_date.
        DATA(lv_yy) = sy-datum+0(4).
        DATA(lv_mm) = sy-datum+4(2).
        DATA(lv_dd) = sy-datum+6(2).
        CONCATENATE lv_mm '-' lv_dd '-' lv_yy INTO lv_date.
        CONCATENATE 'INT0015 has been processed on   ' lv_date '/' sy-uzeit INTO  DATA(lv_text) SEPARATED BY space.
        APPEND lv_text TO main_text.
        document = cl_document_bcs=>create_document(
          i_type    = 'RAW'
          i_text    = main_text
          i_subject = 'INT0015 has been processed' ).       "#EC NOTEXT

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


  METHOD SEND_MAIL_NEW.
    TYPES : BEGIN OF ty_file,
              status(7)        TYPE c,
              message(1024)    TYPE c,
              idoc_no(16)      TYPE n,
              apchkrno(110)    TYPE c,
              exportno(40)     TYPE c,
              appmntmhd(20)    TYPE c,
              state(30)        TYPE c,
              jurisdict(80)    TYPE c,
              aptxbillid(90)   TYPE c,
              txbillglno(100)  TYPE c,
              taxyear(10)      TYPE c,
              apreqdate(10)    TYPE c,
              apinstlmntno(10) TYPE c,
              aptaxtyp(10)     TYPE c,
              appyeid(100)     TYPE c,
              adrsbkvndr(75)   TYPE c,
              apvndrnam(50)    TYPE c,
              prprtyid(225)    TYPE c,
              parcel(150)      TYPE c,
              apnetpyamnt(20)  TYPE c,
              gldate(10)       TYPE c,
              txbillno(80)     TYPE c,
              usecod11(10)     TYPE c,
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

      CONCATENATE l_text
        gc_qc <fs_scs>-status gc_qc gc_tab
        gc_qc <fs_scs>-message gc_qc gc_tab
        gc_qc <fs_scs>-idoc_no gc_qc gc_tab
        gc_qc <fs_scs>-apchkrno gc_qc gc_tab
        gc_qc <fs_scs>-exportno gc_qc gc_tab
        gc_qc <fs_scs>-appmntmhd gc_qc gc_tab
        gc_qc <fs_scs>-state gc_qc gc_tab
        gc_qc <fs_scs>-jurisdict gc_qc gc_tab
        gc_qc <fs_scs>-aptxbillid gc_qc gc_tab
        gc_qc <fs_scs>-txbillglno gc_qc gc_tab
        gc_qc <fs_scs>-taxyear gc_qc gc_tab
        gc_qc <fs_scs>-apreqdate gc_qc gc_tab
        gc_qc <fs_scs>-apinstlmntno gc_qc gc_tab
        gc_qc <fs_scs>-aptaxtyp gc_qc gc_tab
        gc_qc <fs_scs>-appyeid gc_qc gc_tab
        gc_qc <fs_scs>-adrsbkvndr gc_qc gc_tab
        gc_qc <fs_scs>-apvndrnam gc_qc gc_tab
        gc_qc <fs_scs>-prprtyid gc_qc gc_tab
        gc_qc <fs_scs>-parcel gc_qc gc_tab
        gc_qc <fs_scs>-apnetpyamnt gc_qc gc_tab
        gc_qc <fs_scs>-gldate gc_qc gc_tab
        gc_qc <fs_scs>-txbillno gc_qc gc_tab
        <fs_scs>-usecod11 gc_crlf
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
        CONCATENATE 'Real Estate Tax AP Postings - ' sy-datum+4(2) '/' sy-datum+6(2) '/'
         sy-datum+0(4) lv_view INTO lv_subject.

* Subject.
        lt_mailsubject-obj_name = 'Real Estate Tax AP Postings File'.
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

        CONCATENATE ls_mailtxt 'Here is the INT0015 Real Estate Tax AP Postings status with file attachment for your review and reprocess error records if required any.'
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

        lv_filename = 'Inbound Real Estate Tax to SAP File.csv'.
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

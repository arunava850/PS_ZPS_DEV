FUNCTION zfi_workday_payroll_alloc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ET_DATA) TYPE  ZFIT_WORKDAY_PAYROLL_ALLOC OPTIONAL
*"  EXPORTING
*"     VALUE(BAPIRET2) TYPE  BAPIRET2_T
*"----------------------------------------------------------------------


  DATA: lt_data            TYPE  zfit_workday_payroll_alloc,
        lt_data_2          TYPE  zfit_workday_payroll_alloc,

        lwa_data           TYPE  zfis_workday_payroll_alloc,
        gs_docheader       TYPE bapiache09,
        gt_ret             TYPE TABLE OF bapiret2,
        gt_accntgl         TYPE TABLE OF bapiacgl09,
        gs_accntgl         TYPE bapiacgl09,
        lt_accountwt       TYPE TABLE OF bapiacwt09,
        gt_accntpay        TYPE TABLE OF bapiacap09,
        gs_accntpay        TYPE bapiacap09,
        gt_curr            TYPE TABLE OF bapiaccr09,
        gs_curr            TYPE bapiaccr09,
        gt_accntax         TYPE TABLE OF bapiactx09,
        gs_accntax         TYPE bapiactx09,
        gt_withtx          TYPE TABLE OF bapiacwt09,
        gs_ret             TYPE bapiret2,
        lt_return          TYPE STANDARD TABLE OF  bapiret2,
        lv_fyear           TYPE bapi0002_4-fiscal_year,
        lv_item            TYPE posnr_acc,
        lv_amnt            TYPE p DECIMALS 2,
        lv_amnt_split_line TYPE p DECIMALS 2,
        gt_charfld         TYPE TABLE OF bapiackec9,
        gs_charfld         TYPE bapiackec9,
        lv_msg             TYPE string,
        lv_msg1            TYPE string,
        lv_prctr           TYPE prctr,
        lv_add             TYPE c,
        lv_docnum          TYPE edi_docnum,
        lv_max_lines       TYPE i VALUE 750,                            " 999, maximum no of lines.
        lv_item_no         TYPE i,
        lv_doc_no_dec      TYPE p LENGTH 3 DECIMALS 4,
        lv_doc_no          TYPE i,
        lt_accntgl         TYPE TABLE OF bapiacgl09,
        ls_accntgl         TYPE bapiacgl09,
        ls_accntgl1        TYPE bapiacgl09,
        lt_curr            TYPE TABLE OF bapiaccr09,
        ls_curr            TYPE bapiaccr09,
        ls_curr1           TYPE bapiaccr09.


  lt_data = et_data.

  CLEAR lv_add.
  SORT lt_data BY counter.

  "Document Split for lines more than 998: Modify the doc no
  LOOP AT lt_data INTO lwa_data.

    AT NEW counter.
      CLEAR:  lv_item_no, lv_doc_no,  lv_amnt_split_line.

      DATA(lt_data_count) = lt_data.
      DELETE lt_data_count WHERE counter <> lwa_data-counter.

      DESCRIBE TABLE lt_data_count LINES DATA(lv_line_count).
      IF lv_line_count > lv_max_lines.
        DATA(lv_split_ind) = 'X'.
        lv_doc_no = 1.
      ELSE.
        CLEAR lv_split_ind.
      ENDIF.


    ENDAT.
    lwa_data-doc_no = lv_doc_no.
    APPEND lwa_data TO lt_data_2.

    "fill next doc no. for split documents
    IF lv_split_ind = 'X'.
      lv_item_no = lv_item_no + 1.
*        lwa_data-doc_no =  lv_item_no  DIV lv_max_lines + 1.
      IF ( lv_item_no MOD (  lv_max_lines - 1 )  ) = 0.
        lv_doc_no = lv_doc_no + 1.
      ENDIF.
    ENDIF.


  ENDLOOP.
  IF lt_data_2 IS NOT INITIAL.
    REFRESH lt_data.
    lt_data = lt_data_2.
  ENDIF.



  "Get data from GL maping table
  SELECT * FROM zfi_zglmap_proll INTO TABLE @DATA(lt_zglmap) WHERE zid = 'INT0081'.

  IF sy-subrc = 0.
    SELECT ska1~saknr, skat~txt50 INTO TABLE @DATA(lt_ska1) FROM ska1 INNER JOIN skat AS skat
                                                  ON ska1~saknr = skat~saknr
                                   FOR ALL ENTRIES IN @lt_zglmap
                                   WHERE ska1~ktopl = 'PSUS'
                                   AND   ska1~saknr = @lt_zglmap-saknr
                                   AND   skat~spras = @sy-langu.
  ENDIF.

  SELECT kostl, bukrs, prctr INTO TABLE @DATA(lt_csks) FROM csks  FOR ALL ENTRIES IN @lt_data
                                WHERE kostl = @lt_data-kostl.

  SELECT SINGLE * FROM tvarvc INTO @DATA(ls_tvarvc_split_gl) WHERE name = 'INT0081_SPLIT_GL'.

  LOOP AT lt_data INTO DATA(ls_data1).
    DATA(ls_data) = ls_data1.
    lv_prctr = ls_data-prctr.

    AT NEW counter.
      CLEAR: lv_amnt_split_line.

      lv_item = '1'.
      gs_docheader-bus_act = 'RFBU'.
      gs_docheader-username = sy-uname.
*        ls_data-zpropid = to_upper( ls_data-zpropid ).
*      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_docheader-comp_code WHERE prctr = lv_prctr.
      gs_docheader-comp_code  = ls_data-bukrs.
      gs_docheader-doc_date   = ls_data-bldat.
      gs_docheader-pstng_date = ls_data-budat.
      gs_docheader-doc_type =  'ZA'.
      gs_docheader-header_txt = ls_data-bktxt.
      gs_docheader-ref_doc_no = ls_data-xblnr.
      gs_docheader-doc_status = 2.
    ENDAT.



    gs_accntgl-itemno_acc = lv_item.

    "---GL Account
    READ TABLE lt_zglmap INTO DATA(ls_zglmap) WITH KEY zigl = ls_data-hkont.
    IF sy-subrc = 0.
      gs_accntgl-gl_account = ls_zglmap-saknr.
    ENDIF.

    "Item text
    gs_accntgl-item_text  = ls_data-sgtxt.

    "cost center
    gs_accntgl-costcenter = ls_data-kostl.

    "Profit Center

    gs_accntgl-profit_ctr = ls_data-prctr.


    "I/C Company Code
    IF gs_accntgl-costcenter IS NOT INITIAL.
      READ TABLE lt_csks INTO DATA(ls_csks) WITH KEY kostl = ls_data-kostl.
      IF sy-subrc = 0.
        gs_accntgl-comp_code = ls_csks-bukrs.
      ENDIF.

    ELSEIF gs_accntgl-profit_ctr IS NOT INITIAL.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_accntgl-profit_ctr
        IMPORTING
          output = gs_accntgl-profit_ctr.
*        if ls_data-prctr is not initial.
      SELECT SINGLE bukrs FROM cepc_bukrs INTO gs_accntgl-comp_code WHERE prctr = gs_accntgl-profit_ctr.
*        endif.
    ENDIF.

    "Assignment
    gs_accntgl-alloc_nmbr = ls_data-zuonr.

    APPEND gs_accntgl TO gt_accntgl.
    CLEAR gs_accntgl.

    "---Currency amounts
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

    lv_amnt_split_line =  lv_amnt_split_line + lv_amnt.

    AT END OF counter.

      "---- create a new  'document splitting clearing line', when you have more than 1 doc for counter(doc_no = 2)
      READ TABLE lt_data TRANSPORTING NO FIELDS WITH KEY counter = ls_data-counter
                                                         doc_no  = 2.
      IF  sy-subrc = 0.
        "GL Acct
        gs_accntgl-itemno_acc = lv_item.
        gs_accntgl-gl_account = ls_tvarvc_split_gl-low.                     "GL for document split line
        gs_accntgl-item_text  = 'Document split clearing line'.
*        gs_accntgl-costcenter = '0000001000'.
        APPEND gs_accntgl TO gt_accntgl.
        CLEAR gs_accntgl.

        "Currency Amount
        gs_curr-itemno_acc = lv_item.
        gs_curr-currency = 'USD'.
        gs_curr-amt_doccur = lv_amnt_split_line * -1 .
        APPEND gs_curr TO gt_curr.
        CLEAR gs_curr.


      ENDIF.

      lt_accntgl = gt_accntgl.
      lt_curr = gt_curr.

      READ TABLE lt_accntgl ASSIGNING FIELD-SYMBOL(<lfs_accntgl>) WITH KEY comp_code = '1000'.
      IF  sy-subrc IS INITIAL.
        READ TABLE lt_accntgl ASSIGNING FIELD-SYMBOL(<lfs_accntgl1>) WITH KEY itemno_acc = 1.
        IF sy-subrc IS INITIAL.
          ls_accntgl-itemno_acc = <lfs_accntgl>-itemno_acc.
          ls_accntgl1-itemno_acc = <lfs_accntgl1>-itemno_acc.
          <lfs_accntgl>-itemno_acc = ls_accntgl1-itemno_acc.
          <lfs_accntgl1>-itemno_acc = ls_accntgl-itemno_acc.

          READ TABLE lt_curr ASSIGNING FIELD-SYMBOL(<lfs_curr>) WITH KEY itemno_acc = ls_accntgl-itemno_acc.
          IF sy-subrc IS INITIAL.
            READ TABLE lt_curr ASSIGNING FIELD-SYMBOL(<lfs_curr1>) WITH KEY itemno_acc = ls_accntgl1-itemno_acc.
            IF sy-subrc IS INITIAL.

              <lfs_curr>-itemno_acc = ls_accntgl1-itemno_acc.
              <lfs_curr1>-itemno_acc = ls_accntgl-itemno_acc.

            ENDIF.

          ENDIF.

          SORT lt_accntgl BY  itemno_acc.
          SORT lt_curr BY  itemno_acc.

          gt_accntgl = lt_accntgl.
          gt_curr = lt_curr.

        ENDIF.
      ENDIF.
      CLEAr: lt_accntgl, lt_curr, ls_accntgl, ls_accntgl1.


      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
        EXPORTING
          documentheader = gs_docheader
*         CUSTOMERCPD    =
*         CONTRACTHEADER =
* IMPORTING
*         OBJ_TYPE       =
*         OBJ_KEY        =
*         OBJ_SYS        =
        TABLES
          accountgl      = gt_accntgl
*         ACCOUNTRECEIVABLE       =
*         accountpayable = gt_accntpay
*         accounttax     = gt_accntax
          currencyamount = gt_curr
*         criteria       = gt_charfld
*         VALUEFIELD     =
*         EXTENSION1     =
          return         = gt_ret
*         PAYMENTCARD    =
*         CONTRACTITEM   =
*         EXTENSION2     =
*         REALESTATE     =
*         ACCOUNTWT      =
        .


      LOOP AT gt_ret INTO  DATA(ls_return)
          WHERE  type = 'E'
          OR     type = 'A'
          OR     type = 'X'.
        IF sy-tabix = 1.
          "Error Handling: Create Idoc when document is not posted
          CLEAR : lv_docnum.
          CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = gs_docheader
            IMPORTING
              ev_docnum      = lv_docnum
            TABLES
              accountgl      = gt_accntgl
*             accountpayable = lt_accountpayable
              currencyamount = gt_curr
              return         = lt_return
              accountwt      = lt_accountwt.


        ENDIF.

        gw_final-status   = 'Failed'.
        gw_final-counter  = ls_data-counter.
        gw_final-messg = ls_return-message.
        gw_final-docnum = lv_docnum.
        APPEND gw_final TO  gt_final. CLEAR gw_final.

      ENDLOOP.
      IF sy-subrc = 0.              " Errors occurred
      ELSE.
        LOOP AT gt_ret INTO  DATA(ls_ret) WHERE type = 'S'.
        ENDLOOP.
        gw_final-status   = 'Success'.
        gw_final-counter  = ls_data-counter.
        gw_final-messg = ls_ret-message.
        APPEND gw_final TO  gt_final. CLEAR gw_final.

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ENDIF.

      CLEAR : lv_item, gs_docheader.
      REFRESH : gt_accntgl, gt_curr, gt_ret, gt_charfld, lt_accountwt.
    ENDAT.

    CLEAR : lv_add, ls_data.
  ENDLOOP.

  PERFORM send_email USING  'Employee Payroll Allocation'.

ENDFUNCTION.

FORM send_email USING text.

  DATA: mail_data       LIKE sodocchgi1,
        note_object     LIKE thead-tdobject,
        node_it         LIKE thead-tdid,
        send_mail_ok(1),
        mail_note(1000) TYPE c,
        flag            LIKE sonv-flag,
        ls_table        TYPE ty_final,
        receivers       LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
        it_attach       TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE,
        attachment      LIKE solisti1 OCCURS 0 WITH HEADER LINE,
        packing_list    LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
        message         TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE,
        mail_content    LIKE solisti1 OCCURS 0 WITH HEADER LINE.

  DATA: ld_format         TYPE so_obj_tp,
        ld_attfilename    TYPE so_obj_des,
        ld_attdescription TYPE so_obj_nam.

  CONSTANTS: con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
             con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.

  SELECT * FROM tvarvc INTO TABLE @DATA(lt_tvarvc) WHERE name = 'INT0081_EMAIL'.
  CHECK sy-subrc = 0.

  "body of mail

  PERFORM build_body_of_mail USING: 'Hi','Please see the attached excel for payroll allocation interface data.',''.

  DATA:
    l_obj(11),
    l_type(5),
    l_date(15).

  CONCATENATE 'Status' 'Counter' 'Acc Doc. no.' 'Message' 'IDoc' INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.


  LOOP AT gt_final INTO DATA(ls_final) .

    CONCATENATE ls_final-status ls_final-counter ls_final-belnr ls_final-messg ls_final-docnum INTO it_attach SEPARATED BY con_tab.
    CONCATENATE con_cret it_attach INTO it_attach.


    APPEND it_attach.

  ENDLOOP.

  CLEAR: mail_data, mail_content, receivers.
  REFRESH: mail_content.


  READ TABLE it_attach INDEX gv_cnt.

  mail_data-doc_size = ( gv_cnt - 1 ) * 255 + strlen( attachment ) .
  mail_data-obj_name = 'SARPT'.
  mail_data-obj_descr = text.
  mail_data-obj_langu = sy-langu.
  mail_data-sensitivty = 'F'.

  REFRESH attachment.

  attachment[] = it_attach[].

  CLEAR : packing_list.
  REFRESH packing_list.
  "Describe the body of the message.
  packing_list-transf_bin = space.
  packing_list-head_start = 1.
  packing_list-head_num = 0.
  packing_list-body_start = 1.
  DESCRIBE TABLE gt_body_msg LINES packing_list-body_num.
  packing_list-doc_type = 'RAW'.
  APPEND packing_list.
  CLEAR : packing_list.

  "Create attachment notification
  packing_list-transf_bin = 'X'.
  packing_list-head_start = 1.
  packing_list-head_num = 1.
  packing_list-body_start = 1.

  DESCRIBE TABLE attachment LINES packing_list-body_num.

  ld_format = 'XLS'.
  ld_attfilename = text.
  ld_attdescription = 'Wordday Emp. payroll allocation'.

  packing_list-doc_type = ld_format.
  packing_list-obj_descr = ld_attfilename.
  packing_list-obj_name = ld_attfilename.
  packing_list-doc_size = packing_list-body_num * 255.
  packing_list-obj_langu = sy-langu.
  APPEND packing_list.

  " Receivers.
  LOOP AT lt_tvarvc INTO DATA(ls_tvarvc).
    receivers-rec_type = 'U'.
    receivers-com_type = 'INT'.
    receivers-notif_read = ' '.
    receivers-notif_del =  ' '.
    receivers-receiver = ls_tvarvc-low.
    APPEND receivers.
    CLEAR receivers.
  ENDLOOP.

  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = mail_data
*     PUT_IN_OUTBOX              = ' '
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = flag
*     NEW_OBJECT_ID              =
    TABLES
      packing_list               = packing_list
*     OBJECT_HEADER              =
      contents_bin               = attachment
      contents_txt               = gt_body_msg
*     CONTENTS_HEX               =
*     OBJECT_PARA                =
*     OBJECT_PARB                =
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM build_body_of_mail USING l_message.

  gw_body_msg = l_message.
  APPEND gw_body_msg TO gt_body_msg.
  CLEAR gw_body_msg.

ENDFORM.

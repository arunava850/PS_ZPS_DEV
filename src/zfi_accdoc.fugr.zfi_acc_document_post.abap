FUNCTION zfi_acc_document_post.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(DOCUMENTHEADER) LIKE  BAPIACHE09 STRUCTURE  BAPIACHE09
*"     VALUE(CUSTOMERCPD) LIKE  BAPIACPA09 STRUCTURE  BAPIACPA09
*"       OPTIONAL
*"     VALUE(CONTRACTHEADER) LIKE  BAPIACCAHD STRUCTURE  BAPIACCAHD
*"       OPTIONAL
*"  EXPORTING
*"     VALUE(OBJ_TYPE) LIKE  BAPIACHE09-OBJ_TYPE
*"     VALUE(OBJ_KEY) LIKE  BAPIACHE09-OBJ_KEY
*"     VALUE(OBJ_SYS) LIKE  BAPIACHE09-OBJ_SYS
*"     VALUE(EV_DOCNUM) TYPE  EDI_DOCNUM
*"  TABLES
*"      ACCOUNTGL STRUCTURE  BAPIACGL09 OPTIONAL
*"      ACCOUNTRECEIVABLE STRUCTURE  BAPIACAR09 OPTIONAL
*"      ACCOUNTPAYABLE STRUCTURE  BAPIACAP09 OPTIONAL
*"      ACCOUNTTAX STRUCTURE  BAPIACTX09 OPTIONAL
*"      CURRENCYAMOUNT STRUCTURE  BAPIACCR09
*"      CRITERIA STRUCTURE  BAPIACKEC9 OPTIONAL
*"      VALUEFIELD STRUCTURE  BAPIACKEV9 OPTIONAL
*"      EXTENSION1 STRUCTURE  BAPIACEXTC OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2
*"      PAYMENTCARD STRUCTURE  BAPIACPC09 OPTIONAL
*"      CONTRACTITEM STRUCTURE  BAPIACCAIT OPTIONAL
*"      EXTENSION2 STRUCTURE  BAPIPAREX OPTIONAL
*"      REALESTATE STRUCTURE  BAPIACRE09 OPTIONAL
*"      ACCOUNTWT STRUCTURE  BAPIACWT09
*"----------------------------------------------------------------------
  DATA: ls_cntrl_rec  LIKE edidc,
        ls_edids      LIKE edids,
        lt_edidd      LIKE edidd OCCURS 0 WITH HEADER LINE,
        lt_comm_idocs LIKE edidc OCCURS 0 WITH HEADER LINE.


  DATA: c_message_type LIKE edidc-mestyp VALUE 'XAMPLE'.

  DATA : lv_logsys      TYPE tbdls-logsys,
         ls_e1bpache09  TYPE e1bpache09  , " : Header
         ls_e1bpache091 TYPE e1bpache091 , ": Header
         ls_e1bpacpa09  TYPE e1bpacpa09  , ": Posting in accounting: Partner billing doc (load receivable)
         ls_e1bpaccahd  TYPE e1bpaccahd  , ": Add. Contract Accounts Recievable and Payable Header Line
         ls_e1bpacgl09  TYPE e1bpacgl09  , ": G/L account item
         ls_e1bpacgl091 TYPE e1bpacgl091 , ": G/L account item
         ls_e1bpacar09  TYPE e1bpacar09  , ": Customer Item
         ls_e1bpacap09  TYPE e1bpacap09  , ": Vendor Item
         ls_e1bpactx09  TYPE e1bpactx09  , ": Tax item
         ls_e1bpaccr09  TYPE e1bpaccr09  , ": Currency Items
         ls_e1bpackec9  TYPE e1bpackec9  , ": Posting in accounting: CO-PA acct assignment characteristics
         ls_e1bpackev9  TYPE e1bpackev9  , ": Posting in accounting: CO-PA acct assignment value fields
         ls_e1bpacextc  TYPE e1bpacextc  , ": Container for 'Customer Exit' Parameter
         ls_e1bpacpc09  TYPE e1bpacpc09  , " : Payment Card Information
         ls_e1bpaccait  TYPE e1bpaccait  , ": Add. Contract Accounts Rec. and Payable Document Line Item
         ls_e1bpparex   TYPE e1bpparex   , ": Ref. Structure for BAPI Parameter EXTENSIONIN/EXTENSIONOUT
         ls_e1bpacre09  TYPE e1bpacre09  , ": Real Estate Account Assignment Data
         ls_e1bpacwt09  TYPE e1bpacwt09  . ": Withholding Tax Information


********************Build Control Record******************************
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_logsys
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SELECT  SINGLE sndprt FROM edp21
                        INTO @DATA(lv_sndprt)
                       WHERE sndprn = @lv_logsys
                         AND mestyp = 'ACC_DOCUMENT'
                         AND mescod = ''
                         AND mesfct = ''.
  SELECT * FROM tvarvc INTO TABLE @DATA(lt_tvarvc)
                      WHERE name = 'ZFI_ACC_DOCUMENT_POST' .
  ls_cntrl_rec-mestyp = 'ACC_DOCUMENT' .
  ls_cntrl_rec-idoctp = 'ACC_DOCUMENT05' .
  ls_cntrl_rec-rcvprt = 'LS'.
  ls_cntrl_rec-rcvprn = lv_logsys.
  ls_cntrl_rec-sndprn = lv_logsys.
  READ TABLE lt_tvarvc ASSIGNING FIELD-SYMBOL(<fs_tvarvc>) WITH KEY low = 'SNDPOR'.
  IF sy-subrc = 0.
    ls_cntrl_rec-sndpor = <fs_tvarvc>-high. "'A000000005'.
  ENDIF.
  ls_cntrl_rec-sndprt = 'LS'.

  READ TABLE lt_tvarvc ASSIGNING <fs_tvarvc> WITH KEY low = 'RCVPOR'.
  IF sy-subrc = 0.
    ls_cntrl_rec-rcvpor = <fs_tvarvc>-high. "'SAPDS4'.
  ENDIF.
*  ls_cntrl_rec-rcvpor = 'SAPDS4'.
  ls_cntrl_rec-direct = '2' .
*  ls_cntrl_rec-status = '64' .


  APPEND INITIAL LINE TO lt_edidd ASSIGNING FIELD-SYMBOL(<fs_edidd>).
  <fs_edidd>-segnam = 'E1BPACHE09'.
  MOVE-CORRESPONDING documentheader TO ls_e1bpache09.
  <fs_edidd>-sdata = ls_e1bpache09.

  APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
  <fs_edidd>-segnam = 'E1BPACHE091'.
  MOVE-CORRESPONDING  documentheader TO ls_e1bpache091.
  <fs_edidd>-sdata = ls_e1bpache091.

  APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
  <fs_edidd>-segnam = 'E1BPACPA09'.
  MOVE-CORRESPONDING customercpd TO ls_e1bpacpa09.
  <fs_edidd>-sdata = ls_e1bpacpa09.

  APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
  <fs_edidd>-segnam = 'E1BPACCAHD'.
  MOVE-CORRESPONDING  contractheader TO  ls_e1bpaccahd .
  <fs_edidd>-sdata = ls_e1bpaccahd.


  LOOP AT accountgl ASSIGNING FIELD-SYMBOL(<fs_accountgl>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACGL09'.
    MOVE-CORRESPONDING <fs_accountgl> TO ls_e1bpacgl09 .
    <fs_edidd>-sdata = ls_e1bpacgl09.

    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACGL091'.
    MOVE-CORRESPONDING <fs_accountgl> TO ls_e1bpacgl091 .
    <fs_edidd>-sdata = ls_e1bpacgl091.
  ENDLOOP.

  LOOP AT accountreceivable ASSIGNING FIELD-SYMBOL(<fs_accountreceivable>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACAR09'.
    MOVE-CORRESPONDING <fs_accountreceivable> TO ls_e1bpacar09 .
    <fs_edidd>-sdata = ls_e1bpacar09.
  ENDLOOP.

  LOOP AT accountpayable ASSIGNING FIELD-SYMBOL(<fs_accountpayable>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACAP09'.
    MOVE-CORRESPONDING <fs_accountpayable> TO  ls_e1bpacap09.
    <fs_edidd>-sdata = ls_e1bpacap09.
  ENDLOOP.

  LOOP AT accounttax ASSIGNING FIELD-SYMBOL(<fs_accounttax>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACTX09'.
    MOVE-CORRESPONDING <fs_accounttax> TO ls_e1bpactx09 .
    <fs_edidd>-sdata = ls_e1bpactx09.
  ENDLOOP.

  LOOP AT currencyamount ASSIGNING FIELD-SYMBOL(<fs_currencyamount>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACCR09'.
    MOVE-CORRESPONDING <fs_currencyamount> TO ls_e1bpaccr09 .
    <fs_edidd>-sdata = ls_e1bpaccr09.
  ENDLOOP.

  LOOP AT criteria ASSIGNING FIELD-SYMBOL(<fs_criteria>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACKEC9'.
    MOVE-CORRESPONDING <fs_criteria> TO ls_e1bpackec9.
    <fs_edidd>-sdata = ls_e1bpackec9.
  ENDLOOP.

  LOOP AT valuefield ASSIGNING FIELD-SYMBOL(<fs_valuefield>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACKEV9'.
    MOVE-CORRESPONDING <fs_valuefield> TO ls_e1bpackev9  .
    <fs_edidd>-sdata = ls_e1bpackev9.
  ENDLOOP.

  LOOP AT extension1 ASSIGNING FIELD-SYMBOL(<fs_extension1>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACEXTC'.
    MOVE-CORRESPONDING <fs_extension1> TO ls_e1bpacextc  .
    <fs_edidd>-sdata = ls_e1bpacextc.
  ENDLOOP.

  LOOP AT paymentcard ASSIGNING FIELD-SYMBOL(<fs_paymentcard>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACPC09'.
    MOVE-CORRESPONDING <fs_paymentcard> TO ls_e1bpacpc09 .
    <fs_edidd>-sdata = ls_e1bpacpc09.
  ENDLOOP.

  LOOP AT contractitem ASSIGNING FIELD-SYMBOL(<fs_contractitem>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACCAIT'.
    MOVE-CORRESPONDING <fs_contractitem> TO ls_e1bpaccait .
    <fs_edidd>-sdata = ls_e1bpaccait .
  ENDLOOP.

  LOOP AT extension2 ASSIGNING FIELD-SYMBOL(<fs_extension2>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPPAREX'.
    MOVE-CORRESPONDING <fs_extension2> TO ls_e1bpparex.
    <fs_edidd>-sdata = ls_e1bpparex .
  ENDLOOP.


  LOOP AT realestate ASSIGNING FIELD-SYMBOL(<fs_realestate>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACRE09'.
    MOVE-CORRESPONDING <fs_realestate> TO ls_e1bpacre09 .
    <fs_edidd>-sdata = ls_e1bpacre09 .
  ENDLOOP.

  LOOP AT accountwt ASSIGNING FIELD-SYMBOL(<fs_accountwt>) .
    APPEND INITIAL LINE TO lt_edidd ASSIGNING <fs_edidd> .
    <fs_edidd>-segnam = 'E1BPACWT09'.
    MOVE-CORRESPONDING <fs_accountwt> TO ls_e1bpacwt09 .
    <fs_edidd>-sdata = ls_e1bpacwt09.
  ENDLOOP.

*  CALL FUNCTION 'MASTER_IDOC_DISTRIBUTE'
*    EXPORTING
*      master_idoc_control            = ls_cntrl_rec
**     OBJ_TYPE                       = ''
**     CHNUM                          = ''
*    TABLES
*      communication_idoc_control     = lt_comm_idocs
*      master_idoc_data               = lt_edidd
*    EXCEPTIONS
*      error_in_idoc_control          = 1
*      error_writing_idoc_status      = 2
*      error_in_idoc_data             = 3
*      sending_logical_system_unknown = 4
*      OTHERS                         = 5.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ELSE.
*    COMMIT WORK.
*  ENDIF.

*>> Begin comment KDURAI 22/11/2023
*  CALL FUNCTION 'IDOC_INBOUND_WRITE_TO_DB'
** EXPORTING
**   PI_STATUS_MESSAGE             =
**   PI_DO_HANDLE_ERROR            = 'X'
**   PI_NO_DEQUEUE                 = ' '
**   PI_RETURN_DATA_FLAG           = 'X'
**   PI_RFC_MULTI_CP               = '    '
*    IMPORTING
*      pe_idoc_number    = ev_docnum
**     PE_STATE_OF_PROCESSING        =
**     PE_INBOUND_PROCESS_DATA       =
*    TABLES
*      t_data_records    = lt_edidd
**     T_LINKED_OBJECTS  =
*    CHANGING
*      pc_control_record = ls_cntrl_rec
*    EXCEPTIONS
*      idoc_not_saved    = 1
*      OTHERS            = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ELSE.
*    COMMIT WORK.
*  ENDIF.
*<< End comment KDURAI 22/11/2023

*>> BOC KDURAI 22/11/2023
  CALL FUNCTION 'IDOC_WRITE_AND_START_INBOUND'
    EXPORTING
      i_edidc        = ls_cntrl_rec
      do_commit      = 'X'
    IMPORTING
      docnum         = ev_docnum
*     ERROR_BEFORE_CALL_APPLICATION       =
    TABLES
      i_edidd        = lt_edidd
    EXCEPTIONS
      idoc_not_saved = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*<< EOC KDURAI 22/11/2023


  IF ev_docnum IS NOT INITIAL.
    SELECT SINGLE * FROM edids INTO ls_edids WHERE docnum = ev_docnum
                                               AND status = '53'. "#EC CI_ALL_FIELDS_NEEDED
    IF sy-subrc = 0.
      obj_type = ls_edids-stapa1.
      obj_key  = ls_edids-stapa2.
      obj_sys  = ls_edids-stapa3.
    ENDIF.
  ENDIF.

ENDFUNCTION.

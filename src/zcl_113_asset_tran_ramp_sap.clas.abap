class ZCL_113_ASSET_TRAN_RAMP_SAP definition
  public
  final
  create public .

public section.

  methods POST
    importing
      value(GT_FILE) type ANY TABLE
    exporting
      value(GT_RETURN) type BAPIRET2_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_113_ASSET_TRAN_RAMP_SAP IMPLEMENTATION.


  METHOD post.

    TYPES : BEGIN OF ty_file,
              zpropertyid        TYPE prctr,
              zasset_refer(255)  TYPE c,
              zasset_no(18)      TYPE c,
              zretire_date       TYPE datum,
              zreason_retire(50) TYPE c,
            END OF ty_file.

    TYPES: BEGIN OF ty_data,
             zpropertyid        TYPE prctr,
             zasset_refer(255)  TYPE c,
             zasset_no(18)      TYPE c,
             zretire_date       TYPE datum,
             zreason_retire(50) TYPE c,
             bukrs              TYPE anla-bukrs,
             anln1              TYPE anla-anln1,
             anln2              TYPE anla-anln2,
             anlkl              TYPE anla-anlkl,
             sernr              TYPE anla-sernr,
             bdatu              TYPE anlz-bdatu,
             prctr              TYPE anlz-prctr,
             kokrs              TYPE cepc_bukrs-kokrs,
           END OF ty_data.

    DATA: gt_final TYPE TABLE OF ty_data,
          gs_final TYPE ty_data.

    DATA : gt_data TYPE TABLE OF ty_file,
           gs_data TYPE ty_file.

    DATA : ls_e1bpfapo_gen_info TYPE e1bpfapo_gen_info,
           ls_e1bpfapo_ret      TYPE e1bpfapo_ret,
           ls_e1bpfapo_doc_ref  TYPE e1bpfapo_doc_ref,
           ls_e1bpfapo_acc_ass  TYPE e1bpfapo_acc_ass,
           ls_e1bpfapo_add_info TYPE e1bpfapo_add_info,
           ls_edidc             TYPE edidc,
           lt_edidd             TYPE TABLE OF edidd,
           ls_edidd             TYPE edidd,
           ls_edids             TYPE edids,
           lv_logsys            TYPE tbdls-logsys,
           ev_docnum            TYPE edi_docnum,
           lr_sernr             TYPE RANGE OF am_sernr,
           ls_sernr             LIKE LINE OF lr_sernr,
           lt_idocstat          TYPE TABLE OF bdidocstat,
           ls_idocstat          TYPE bdidocstat.

    gt_data[] = CORRESPONDING #( gt_file ).

    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_logsys
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
    CLEAR ls_edidc.
    SELECT  SINGLE sndprt FROM edp21
                          INTO @DATA(lv_sndprt)
                         WHERE sndprn = @lv_logsys
                           AND mestyp = 'ASSET_RETIREMENT_POST'
                           AND mescod = ''
                           AND mesfct = ''.
    SELECT * FROM tvarvc INTO TABLE @DATA(lt_tvarvc)
                        WHERE name = 'ZFI_ACC_DOCUMENT_POST' .
    ls_edidc-mestyp = 'ASSET_RETIREMENT_POST' .
    ls_edidc-idoctp = 'ASSET_RETIREMENT_POST01' .
    ls_edidc-rcvprt = 'LS'.
    ls_edidc-rcvprn = lv_logsys.
    ls_edidc-sndprn = lv_logsys.
    READ TABLE lt_tvarvc ASSIGNING FIELD-SYMBOL(<fs_tvarvc>) WITH KEY low = 'SNDPOR'.
    IF sy-subrc = 0.
      ls_edidc-sndpor = <fs_tvarvc>-high. "'A000000005'.
    ENDIF.
    ls_edidc-sndprt = 'LS'.

    READ TABLE lt_tvarvc ASSIGNING <fs_tvarvc> WITH KEY low = 'RCVPOR'.
    IF sy-subrc = 0.
      ls_edidc-rcvpor = <fs_tvarvc>-high. "'SAPDS4'.
    ENDIF.
*  ls_edidc-rcvpor = 'SAPDS4'.
    ls_edidc-direct = '2' .
*  ls_edidc-status = '64' .
* refresh : lr_sernr.
* LOOP AT gt_data INTO DATA(ls_tmp).
*ls_sernr-sign = 'I'.
*ls_sernr-option = 'EQ'.
*ls_sernr-low = ls_tmp-zasset_no.
*APPEND ls_sernr to lr_sernr.
*CLEAR ls_sernr.
* ENDLOOP.
    IF gt_data IS NOT INITIAL.
      SELECT kokrs, prctr, bukrs FROM cepc_bukrs INTO TABLE @DATA(lt_cepc)
        FOR ALL ENTRIES IN @gt_data
        WHERE prctr = @gt_data-zpropertyid.

      SELECT bukrs,
      anln1,
      anln2,
      anlkl,
      sernr FROM anla INTO TABLE @DATA(lt_anla)
       FOR ALL ENTRIES IN @gt_data
        WHERE sernr = @gt_data-zasset_no.
      IF sy-subrc EQ 0.
        SELECT bukrs,
        anln1,
        anln2,
        bdatu,
        prctr FROM anlz INTO TABLE @DATA(lt_anlz)
          FOR ALL ENTRIES IN @gt_data
          WHERE prctr = @gt_data-zpropertyid.
      ENDIF.
    ENDIF.

*** Change for TR - DS4K903317
*** Fill Assets created for Ramp Asset No
    LOOP AT lt_anla INTO DATA(ls_anla).
      READ TABLE gt_data INTO gs_data WITH KEY zasset_no = ls_anla-sernr.
      IF sy-subrc EQ 0.
        gs_final-zpropertyid = gs_data-zpropertyid.
        gs_final-zasset_refer = gs_data-zasset_refer.
        gs_final-zasset_no = gs_data-zasset_no.
        gs_final-zretire_date = gs_data-zretire_date.
        gs_final-zreason_retire = gs_data-zreason_retire.
        gs_final-bukrs = ls_anla-bukrs.
        gs_final-anln1 = ls_anla-anln1.
        gs_final-anln2 = ls_anla-anln2.
        gs_final-anlkl = ls_anla-anlkl.
        gs_final-sernr = ls_anla-sernr.
        APPEND gs_final TO gt_final.
        CLEAR: gs_final.
      ENDIF.
    ENDLOOP.
**** Fill Bad Ramp Asset No#'s
    LOOP AT gt_data INTO gs_data.
      READ TABLE lt_anla INTO ls_anla WITH KEY sernr = gs_data-zasset_no.
      IF sy-subrc NE 0.
        gs_final-zpropertyid = gs_data-zpropertyid.
        gs_final-zasset_refer = gs_data-zasset_refer.
        gs_final-zasset_no = gs_data-zasset_no.
        gs_final-zretire_date = gs_data-zretire_date.
        gs_final-zreason_retire = gs_data-zreason_retire.
        APPEND gs_final TO gt_final.
        CLEAR: gs_final.
      ENDIF.
    ENDLOOP.

    LOOP AT gt_final INTO gs_final.
      IF gs_final-anln1 IS NOT INITIAL.
        ls_e1bpfapo_gen_info-comp_code = gs_final-bukrs.
        ls_e1bpfapo_gen_info-assetmaino = gs_final-anln1.
        ls_e1bpfapo_gen_info-assetsubno = gs_final-anln2.
        ls_e1bpfapo_gen_info-depr_area = space.

        ls_e1bpfapo_gen_info-doc_date = gs_final-zretire_date.
        ls_e1bpfapo_gen_info-pstng_date = gs_final-zretire_date.
        ls_e1bpfapo_gen_info-username = sy-uname.

        ls_edidd-segnam = 'E1BPFAPO_GEN_INFO'.
        ls_edidd-sdata = ls_e1bpfapo_gen_info.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.

        ls_e1bpfapo_ret-valuedate = gs_final-zretire_date.
        ls_edidd-segnam = 'E1BPFAPO_RET'.
        ls_edidd-sdata = ls_e1bpfapo_ret.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.

        ls_e1bpfapo_add_info-header_txt = gs_final-zreason_retire.
        ls_e1bpfapo_add_info-item_text = gs_final-zreason_retire.
        ls_edidd-segnam = 'E1BPFAPO_ADD_INFO'.
        ls_edidd-sdata = ls_e1bpfapo_add_info.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.
        CALL FUNCTION 'IDOC_WRITE_AND_START_INBOUND'
          EXPORTING
            i_edidc        = ls_edidc
            do_commit      = ' '
          IMPORTING
            docnum         = ev_docnum
*           ERROR_BEFORE_CALL_APPLICATION       =
          TABLES
            i_edidd        = lt_edidd
          EXCEPTIONS
            idoc_not_saved = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        IF ls_e1bpfapo_gen_info-comp_code IS INITIAL.
          CLEAR : ls_idocstat.
          REFRESH : lt_idocstat.
          ls_idocstat-docnum = ev_docnum.
          ls_idocstat-status = '51'.
          CONCATENATE 'No company code found for ' gs_final-zpropertyid INTO ls_idocstat-msgv1.
          APPEND ls_idocstat TO lt_idocstat.
          CLEAR ls_idocstat.
          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
            EXPORTING
              idoc_number               = ev_docnum
*             IDOC_OPENED_FLAG          = ' '
*             NO_DEQUEUE_FLAG           = 'X'
*         IMPORTING
*             IDOC_CONTROL              =
            TABLES
              idoc_status               = lt_idocstat
            EXCEPTIONS
              idoc_foreign_lock         = 1
              idoc_not_found            = 2
              idoc_status_records_empty = 3
              idoc_status_invalid       = 4
              db_error                  = 5
              OTHERS                    = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE lt_cepc INTO DATA(ls_cepc1) WITH KEY prctr = gs_final-zpropertyid.
        IF sy-subrc EQ 0.
          ls_e1bpfapo_gen_info-comp_code = ls_cepc1-bukrs.
        ELSE.
          ls_e1bpfapo_gen_info-comp_code = gs_final-zpropertyid.
        ENDIF.

        ls_e1bpfapo_gen_info-assetmaino = gs_final-zasset_no.
        ls_e1bpfapo_gen_info-assetsubno = gs_final-zasset_no.
        ls_e1bpfapo_gen_info-depr_area = space.

        ls_e1bpfapo_gen_info-doc_date = gs_final-zretire_date.
        ls_e1bpfapo_gen_info-pstng_date = gs_final-zretire_date.
        ls_e1bpfapo_gen_info-username = sy-uname.

        ls_edidd-segnam = 'E1BPFAPO_GEN_INFO'.
        ls_edidd-sdata = ls_e1bpfapo_gen_info.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.

        ls_e1bpfapo_ret-valuedate = gs_final-zretire_date.
        ls_edidd-segnam = 'E1BPFAPO_RET'.
        ls_edidd-sdata = ls_e1bpfapo_ret.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.

        ls_e1bpfapo_add_info-header_txt = gs_final-zreason_retire.
        ls_e1bpfapo_add_info-item_text = gs_final-zreason_retire.
        ls_edidd-segnam = 'E1BPFAPO_ADD_INFO'.
        ls_edidd-sdata = ls_e1bpfapo_add_info.
        APPEND ls_edidd TO lt_edidd.
        CLEAR ls_edidd.
        CALL FUNCTION 'IDOC_WRITE_AND_START_INBOUND'
          EXPORTING
            i_edidc        = ls_edidc
            do_commit      = ' '
          IMPORTING
            docnum         = ev_docnum
*           ERROR_BEFORE_CALL_APPLICATION       =
          TABLES
            i_edidd        = lt_edidd
          EXCEPTIONS
            idoc_not_saved = 1
            OTHERS         = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        IF gs_final-bukrs IS INITIAL.
          CLEAR : ls_idocstat.
          REFRESH : lt_idocstat.
          ls_idocstat-docnum = ev_docnum.
          ls_idocstat-status = '51'.
          CONCATENATE 'No company code found for ' gs_final-zpropertyid INTO ls_idocstat-msgv1.
          APPEND ls_idocstat TO lt_idocstat.
          CLEAR ls_idocstat.
          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
            EXPORTING
              idoc_number               = ev_docnum
*             IDOC_OPENED_FLAG          = ' '
*             NO_DEQUEUE_FLAG           = 'X'
*         IMPORTING
*             IDOC_CONTROL              =
            TABLES
              idoc_status               = lt_idocstat
            EXCEPTIONS
              idoc_foreign_lock         = 1
              idoc_not_found            = 2
              idoc_status_records_empty = 3
              idoc_status_invalid       = 4
              db_error                  = 5
              OTHERS                    = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ELSE.
          CLEAR : ls_idocstat.
          REFRESH : lt_idocstat.
          ls_idocstat-docnum = ev_docnum.
          ls_idocstat-status = '51'.
          CONCATENATE 'No asset found for  ' gs_final-zasset_no INTO ls_idocstat-msgv1.
          APPEND ls_idocstat TO lt_idocstat.
          CLEAR ls_idocstat.
          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
            EXPORTING
              idoc_number               = ev_docnum
*             IDOC_OPENED_FLAG          = ' '
*             NO_DEQUEUE_FLAG           = 'X'
*         IMPORTING
*             IDOC_CONTROL              =
            TABLES
              idoc_status               = lt_idocstat
            EXCEPTIONS
              idoc_foreign_lock         = 1
              idoc_not_found            = 2
              idoc_status_records_empty = 3
              idoc_status_invalid       = 4
              db_error                  = 5
              OTHERS                    = 6.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
      ENDIF.
*      endif.
      CLEAR : ls_e1bpfapo_add_info, ls_e1bpfapo_ret, ls_e1bpfapo_gen_info, gs_data, gs_final.
      REFRESH : lt_edidd.
    ENDLOOP.



***************************** Old Code Start*************************************************************
*    LOOP AT gt_data INTO gs_data.
*
*      READ TABLE lt_anla INTO DATA(ls_anla) WITH KEY sernr = gs_data-zasset_no.
*      IF sy-subrc EQ 0.
**        READ TABLE lt_anlz INTO DATA(ls_anlz) WITH KEY bukrs = ls_anla-bukrs
**                                                       anln1 = ls_anla-anln1
**                                                       prctr = gs_data-zpropertyid.
**        IF sy-subrc EQ 0.
**          "AND  = '100000000'.
***      if sy-subrc eq 0.
**          READ TABLE lt_cepc INTO DATA(ls_cepc) WITH KEY prctr = gs_data-zpropertyid.
**          IF sy-subrc EQ 0.
**            ls_e1bpfapo_gen_info-comp_code = ls_cepc-bukrs.
**          ELSE.
**            ls_e1bpfapo_gen_info-comp_code = ls_anla-bukrs.
**          ENDIF.
**        ELSE.
**          READ TABLE lt_cepc INTO ls_cepc WITH KEY prctr = gs_data-zpropertyid.
**          IF sy-subrc EQ 0.
**            ls_e1bpfapo_gen_info-comp_code = ls_cepc-bukrs.
**          ELSE.
**            ls_e1bpfapo_gen_info-comp_code = ls_anla-bukrs.
**          ENDIF.
**        ENDIF.
*
*        ls_e1bpfapo_gen_info-comp_code = ls_anla-bukrs.
*        ls_e1bpfapo_gen_info-assetmaino = ls_anla-anln1.
*        ls_e1bpfapo_gen_info-assetsubno = ls_anla-anln2.
*        ls_e1bpfapo_gen_info-depr_area = space.
*
*        ls_e1bpfapo_gen_info-doc_date = gs_data-zretire_date.
*        ls_e1bpfapo_gen_info-pstng_date = gs_data-zretire_date.
*        ls_e1bpfapo_gen_info-username = sy-uname.
*
*        ls_edidd-segnam = 'E1BPFAPO_GEN_INFO'.
*        ls_edidd-sdata = ls_e1bpfapo_gen_info.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*
*        ls_e1bpfapo_ret-valuedate = gs_data-zretire_date.
*        ls_edidd-segnam = 'E1BPFAPO_RET'.
*        ls_edidd-sdata = ls_e1bpfapo_ret.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*
*        ls_e1bpfapo_add_info-header_txt = gs_data-zreason_retire.
*        ls_e1bpfapo_add_info-item_text = gs_data-zreason_retire.
*        ls_edidd-segnam = 'E1BPFAPO_ADD_INFO'.
*        ls_edidd-sdata = ls_e1bpfapo_add_info.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*        CALL FUNCTION 'IDOC_WRITE_AND_START_INBOUND'
*          EXPORTING
*            i_edidc        = ls_edidc
*            do_commit      = ' '
*          IMPORTING
*            docnum         = ev_docnum
**           ERROR_BEFORE_CALL_APPLICATION       =
*          TABLES
*            i_edidd        = lt_edidd
*          EXCEPTIONS
*            idoc_not_saved = 1
*            OTHERS         = 2.
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.
*        IF ls_e1bpfapo_gen_info-comp_code IS INITIAL.
*          CLEAR : ls_idocstat.
*          REFRESH : lt_idocstat.
*          ls_idocstat-docnum = ev_docnum.
*          ls_idocstat-status = '51'.
*          CONCATENATE 'No company code found for ' gs_data-zpropertyid INTO ls_idocstat-msgv1.
*          APPEND ls_idocstat TO lt_idocstat.
*          CLEAR ls_idocstat.
*          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
*            EXPORTING
*              idoc_number               = ev_docnum
**             IDOC_OPENED_FLAG          = ' '
**             NO_DEQUEUE_FLAG           = 'X'
**         IMPORTING
**             IDOC_CONTROL              =
*            TABLES
*              idoc_status               = lt_idocstat
*            EXCEPTIONS
*              idoc_foreign_lock         = 1
*              idoc_not_found            = 2
*              idoc_status_records_empty = 3
*              idoc_status_invalid       = 4
*              db_error                  = 5
*              OTHERS                    = 6.
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.
*        ENDIF.
*
*      ELSE.
*        READ TABLE lt_cepc INTO DATA(ls_cepc1) WITH KEY prctr = gs_data-zpropertyid.
*        IF sy-subrc EQ 0.
*          ls_e1bpfapo_gen_info-comp_code = ls_cepc1-bukrs.
*        ELSE.
*          ls_e1bpfapo_gen_info-comp_code = gs_data-zpropertyid.
*        ENDIF.
*
*        ls_e1bpfapo_gen_info-assetmaino = gs_data-zasset_no.
*        ls_e1bpfapo_gen_info-assetsubno = gs_data-zasset_no.
*        ls_e1bpfapo_gen_info-depr_area = space.
*
*        ls_e1bpfapo_gen_info-doc_date = gs_data-zretire_date.
*        ls_e1bpfapo_gen_info-pstng_date = gs_data-zretire_date.
*        ls_e1bpfapo_gen_info-username = sy-uname.
*
*        ls_edidd-segnam = 'E1BPFAPO_GEN_INFO'.
*        ls_edidd-sdata = ls_e1bpfapo_gen_info.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*
*        ls_e1bpfapo_ret-valuedate = gs_data-zretire_date.
*        ls_edidd-segnam = 'E1BPFAPO_RET'.
*        ls_edidd-sdata = ls_e1bpfapo_ret.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*
*        ls_e1bpfapo_add_info-header_txt = gs_data-zreason_retire.
*        ls_e1bpfapo_add_info-item_text = gs_data-zreason_retire.
*        ls_edidd-segnam = 'E1BPFAPO_ADD_INFO'.
*        ls_edidd-sdata = ls_e1bpfapo_add_info.
*        APPEND ls_edidd TO lt_edidd.
*        CLEAR ls_edidd.
*        CALL FUNCTION 'IDOC_WRITE_AND_START_INBOUND'
*          EXPORTING
*            i_edidc        = ls_edidc
*            do_commit      = ' '
*          IMPORTING
*            docnum         = ev_docnum
**           ERROR_BEFORE_CALL_APPLICATION       =
*          TABLES
*            i_edidd        = lt_edidd
*          EXCEPTIONS
*            idoc_not_saved = 1
*            OTHERS         = 2.
*        IF sy-subrc <> 0.
** Implement suitable error handling here
*        ENDIF.
*        IF ls_cepc1-bukrs IS INITIAL.
*          CLEAR : ls_idocstat.
*          REFRESH : lt_idocstat.
*          ls_idocstat-docnum = ev_docnum.
*          ls_idocstat-status = '51'.
*          CONCATENATE 'No company code found for ' gs_data-zpropertyid INTO ls_idocstat-msgv1.
*          APPEND ls_idocstat TO lt_idocstat.
*          CLEAR ls_idocstat.
*          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
*            EXPORTING
*              idoc_number               = ev_docnum
**             IDOC_OPENED_FLAG          = ' '
**             NO_DEQUEUE_FLAG           = 'X'
**         IMPORTING
**             IDOC_CONTROL              =
*            TABLES
*              idoc_status               = lt_idocstat
*            EXCEPTIONS
*              idoc_foreign_lock         = 1
*              idoc_not_found            = 2
*              idoc_status_records_empty = 3
*              idoc_status_invalid       = 4
*              db_error                  = 5
*              OTHERS                    = 6.
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.
*        ELSE.
*          CLEAR : ls_idocstat.
*          REFRESH : lt_idocstat.
*          ls_idocstat-docnum = ev_docnum.
*          ls_idocstat-status = '51'.
*          CONCATENATE 'No asset found for  ' gs_data-zasset_no INTO ls_idocstat-msgv1.
*          APPEND ls_idocstat TO lt_idocstat.
*          CLEAR ls_idocstat.
*          CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
*            EXPORTING
*              idoc_number               = ev_docnum
**             IDOC_OPENED_FLAG          = ' '
**             NO_DEQUEUE_FLAG           = 'X'
**         IMPORTING
**             IDOC_CONTROL              =
*            TABLES
*              idoc_status               = lt_idocstat
*            EXCEPTIONS
*              idoc_foreign_lock         = 1
*              idoc_not_found            = 2
*              idoc_status_records_empty = 3
*              idoc_status_invalid       = 4
*              db_error                  = 5
*              OTHERS                    = 6.
*          IF sy-subrc <> 0.
** Implement suitable error handling here
*          ENDIF.
*        ENDIF.
*      ENDIF.
**      endif.
*      CLEAR : ls_e1bpfapo_add_info, ls_e1bpfapo_ret, ls_e1bpfapo_gen_info, gs_data.
*      REFRESH : lt_edidd.
*    ENDLOOP.
********************************** Old Code End************************************************
  ENDMETHOD.
ENDCLASS.

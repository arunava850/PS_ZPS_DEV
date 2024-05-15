CLASS zcl_zzfi_edw_s4_stat_rec_proxy DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zii_zzfi_edw_s4_stat_rec_proxy .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZZFI_EDW_S4_STAT_REC_PROXY IMPLEMENTATION.


  METHOD zii_zzfi_edw_s4_stat_rec_proxy~post_doc.
*


    DATA: gs_data  TYPE zfi_edw_s4_stat_post_typ,
          gt_data  TYPE STANDARD TABLE OF zfi_edw_s4_stat_post_typ,
          lv_prctr TYPE prctr.

    DATA: ls_header     TYPE bapifaglskf01,
          ls_linedata   TYPE bapifaglskf02,
          lt_linedata   TYPE STANDARD TABLE OF bapifaglskf02,
          lt_return     TYPE STANDARD TABLE OF bapiret2,
          lt_return_all TYPE STANDARD TABLE OF bapiret2,
          lt_extension  TYPE STANDARD TABLE OF bapifaglskf03.
    DATA: lt_enq        TYPE TABLE OF faglskf_enqueue,
          ls_enq        TYPE faglskf_enqueue,
          lv_enq        TYPE char1,
          lv_count      TYPE i,
          lv_lock_suc   TYPE char1,
          lv_lock_count TYPE i.


    DATA: lv_secs TYPE tzntstmpl.
    DATA lv_time_stamp TYPE timestamp.

    WHILE lv_lock_suc = abap_false AND lv_lock_count < 360.
      SELECT SINGLE mandt, zprocess, zstatus, zdate, ztime, ztimestamp
          FROM zfi_edw_s4
          WHERE zprocess = 'A'
          AND zstatus = 'R'
          INTO @DATA(ls_zfi_edw_s4).
      IF sy-subrc IS NOT INITIAL.
        CALL FUNCTION 'ENQUEUE_EZFI_EDW_S4'
          EXPORTING
*           MODE_ZFI_EDW_S4       = 'X'
*           MANDT          = SY-MANDT
            zprocess       = 'A'
*           X_ZPROCESS     = ' '
*           _SCOPE         = '2'
*           _WAIT          = ' '
*           _COLLECT       = ' '
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here

        ELSE.
          GET TIME STAMP FIELD lv_time_stamp.
          ls_zfi_edw_s4-mandt = sy-mandt.
          ls_zfi_edw_s4-zprocess = 'A'.
          ls_zfi_edw_s4-zstatus = 'R'.
          ls_zfi_edw_s4-zdate = sy-datum.
          ls_zfi_edw_s4-ztime = sy-uzeit.
          ls_zfi_edw_s4-ztimestamp = lv_time_stamp.

          MODIFY zfi_edw_s4 FROM ls_zfi_edw_s4.
          COMMIT WORK AND WAIT.

          CALL FUNCTION 'DEQUEUE_EZFI_EDW_S4'
            EXPORTING
*             MODE_ZFI_EDW_S4       = 'X'
*             MANDT    = SY-MANDT
              zprocess = 'A'
*             X_ZPROCESS            = ' '
*             _SCOPE   = '3'
*             _SYNCHRON             = ' '
*             _COLLECT = ' '
            .
          lv_lock_suc = abap_true.
        ENDIF.
      ELSE.

        GET TIME STAMP FIELD lv_time_stamp.

        CALL METHOD cl_abap_tstmp=>subtract
          EXPORTING
            tstmp1 = lv_time_stamp
            tstmp2 = ls_zfi_edw_s4-ztimestamp
          RECEIVING
            r_secs = lv_secs.

        IF lv_secs > 36000.
          ls_zfi_edw_s4-mandt = sy-mandt.
          ls_zfi_edw_s4-zprocess = 'A'.
          ls_zfi_edw_s4-zstatus = 'C'.
          ls_zfi_edw_s4-zdate = sy-datum.
          ls_zfi_edw_s4-ztime = sy-uzeit.
          ls_zfi_edw_s4-ztimestamp = lv_time_stamp.

          MODIFY zfi_edw_s4 FROM ls_zfi_edw_s4.
          COMMIT WORK AND WAIT.
        ENDIF.

      ENDIF.

      WAIT UP TO 10 SECONDS.
      lv_lock_count = lv_lock_count + 1.
    ENDWHILE.

    IF lv_lock_suc = abap_true AND lv_lock_count < 360.
      LOOP AT input-zfi_edw_s4_stat_post_typ-zedwdata INTO DATA(ls_data).
        gs_data = CORRESPONDING #( ls_data ).
        APPEND gs_data TO gt_data.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_data-profit_center
          IMPORTING
            output = lv_prctr.


        SELECT SINGLE bukrs
          FROM
              cepc_bukrs    "#EC CI_GENBUFF
          WHERE
              prctr = @lv_prctr
          INTO @DATA(lv_bukrs).

        ls_header-comp_code = lv_bukrs.

        "    ls_header-date_from = ls_data-report_date.

        CONCATENATE ls_data-report_date+4(4) ls_data-report_date+0(2) ls_data-report_date+2(2) INTO ls_header-date_from.




        ls_linedata-co_area = 'PSCO'.
        ls_linedata-statkeyfig = ls_data-stats_code.
        ls_linedata-costcenter = lv_prctr. "Updated cost center as communicated by Naresh
        ls_linedata-profit_ctr = lv_prctr.
        ls_linedata-quantity = ls_data-value.

        APPEND ls_linedata TO lt_linedata.


        REFRESH lt_enq.

        ls_enq-stagr = ls_data-stats_code.
        ls_enq-rbukrs = lv_bukrs.
        ls_enq-rrcty = 1.

        ls_enq-fieldname = 'PRCTR'.
        ls_enq-fieldvalue = lv_prctr.
        APPEND ls_enq TO lt_enq.

        ls_enq-fieldname = 'SEGMENT'.
        ls_enq-fieldvalue = 'PS_STORAGE'.
        APPEND ls_enq TO lt_enq.

        lv_enq = abap_true.
        CLEAR lv_count.
        LOOP AT lt_enq INTO ls_enq.
* generated function module to enqueue object EGFAGLSKFE

          IF lv_count < 100.
            lv_enq = abap_true.
            CLEAR lv_count.
            WHILE lv_enq = abap_true AND lv_count < 100.
              CALL FUNCTION 'ENQUEUE_EGFAGLSKFE'
                EXPORTING
                  stagr          = ls_enq-stagr
                  rbukrs         = ls_enq-rbukrs
                  rrcty          = ls_enq-rrcty
                  rvers          = ls_enq-rvers
                  fieldname      = ls_enq-fieldname
                  fieldvalue     = ls_enq-fieldvalue
                EXCEPTIONS
                  foreign_lock   = 1
                  system_failure = 2
                  OTHERS         = 3.
              IF sy-subrc <> 0.
                WAIT UP TO 2 SECONDS.
                lv_count = lv_count + 1.
              ELSE.
                lv_enq = abap_false.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.
        IF lv_count < 100.
          CALL FUNCTION 'BAPI_ACC_POST_STAT_KEYFIGURE'
            EXPORTING
              documentheader = ls_header
            TABLES
              linedata       = lt_linedata
              extension1     = lt_extension
              return         = lt_return.


          COMMIT WORK AND WAIT.

          APPEND LINES OF lt_return TO lt_return_all.

          CLEAR: lt_return, lv_prctr, gs_data, ls_header,lt_linedata, lv_bukrs, ls_data, lt_linedata.
        ENDIF.
      ENDLOOP.


      SELECT SINGLE zprocess, zstatus, zdate, ztime
          FROM zfi_edw_s4
          WHERE zprocess = 'A'
          AND zstatus = 'R'
          INTO @DATA(ls_zfi_edw_s41).
      IF sy-subrc IS NOT INITIAL.
        CALL FUNCTION 'ENQUEUE_EZFI_EDW_S4'
          EXPORTING
*           MODE_ZFI_EDW_S4       = 'X'
*           MANDT    = SY-MANDT
            zprocess = 'A'
*           X_ZPROCESS            = ' '
*           _SCOPE   = '2'
*           _WAIT    = ' '
*           _COLLECT = ' '
* EXCEPTIONS
*           FOREIGN_LOCK          = 1
*           SYSTEM_FAILURE        = 2
*           OTHERS   = 3
          .
        IF sy-subrc <> 0.
* Implement suitable error handling here

        ELSE.
          CALL FUNCTION 'DEQUEUE_EZFI_EDW_S4'
            EXPORTING
*             MODE_ZFI_EDW_S4       = 'X'
*             MANDT    = SY-MANDT
              zprocess = 'A'
*             X_ZPROCESS            = ' '
*             _SCOPE   = '3'
*             _SYNCHRON             = ' '
*             _COLLECT = ' '
            .

        ENDIF.


      ENDIF.

      GET TIME STAMP FIELD lv_time_stamp.

      ls_zfi_edw_s4-mandt = sy-mandt.
      ls_zfi_edw_s4-zprocess = 'A'.
      ls_zfi_edw_s4-zstatus = 'C'.
      ls_zfi_edw_s4-zdate = sy-datum.
      ls_zfi_edw_s4-ztime = sy-uzeit.
      ls_zfi_edw_s4-ztimestamp = lv_time_stamp.

      MODIFY zfi_edw_s4 FROM ls_zfi_edw_s4.
      COMMIT WORK AND WAIT.

    ENDIF.

** **** INSERT IMPLEMENTATION HERE **** ***
  ENDMETHOD.
ENDCLASS.

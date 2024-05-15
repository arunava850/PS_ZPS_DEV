*&---------------------------------------------------------------------*
*& Report ZFI_GL_MONTHLY_BAL_INT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_gl_monthly_bal_int.


DATA:lfis_bukrs             TYPE fis_bukrs,
     lfis_ryear_no_conv     TYPE bkpf-gjahr,
     lfins_ledger           TYPE fins_ledger,
     lfins_fiscalperiod     TYPE bkpf-monat,
     lfis_hwaer             TYPE bkpf-waers,
     lfis_racct             TYPE fis_racct,
     lv_figlcn_disalteracct TYPE figlcn_disalteracct,
     gs_out                 TYPE zfi_gl_monthly_bal_sp,
     gt_data                TYPE zfi_gl_monthly_bal_tt_tab,
     gs_data                LIKE LINE OF gt_data,
     ls_data                LIKE LINE OF gt_data,
     lt_data                TYPE zfi_gl_monthly_bal_tt_tab,
     lv_prctr               TYPE cepc-prctr,
     lt_zfi_pccenters       TYPE STANDARD TABLE OF zfi_pccenters,
     lv_fyear               TYPE bapi0002_4-fiscal_year,
     lv_period              TYPE bapi0002_4-fiscal_period.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECT-OPTIONS : s_ccode FOR lfis_bukrs OBLIGATORY,
                   s_ledger  FOR lfins_ledger OBLIGATORY.
  PARAMETERS:      p_fyear  TYPE fis_ryear_no_conv.
  SELECT-OPTIONS : s_fper  FOR lfins_fiscalperiod.
  PARAMETERS:      p_date  TYPE datum.
  PARAMETERS:      p_crole TYPE fac_crcyrole OBLIGATORY. "DEFAULT '10' OBLIGATORY.
  PARAMETERS: "p_dcur  TYPE bkpf-waers OBLIGATORY,
    p_glinf TYPE figlcn_disalteracct,
    p_norec TYPE int4 DEFAULT 20000.


SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  IF p_date IS NOT INITIAL.


    IF p_fyear IS NOT INITIAL OR s_fper  IS NOT INITIAL.
      MESSAGE i398(00) WITH 'Do not Provide both Date and (FY/Period)'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.

    IF p_fyear IS INITIAL OR s_fper IS INITIAL.

      MESSAGE i398(00) WITH 'Provide Date or (FY/Period)'.
      LEAVE LIST-PROCESSING.

    ENDIF.

  ENDIF.

  SELECT bukrs
  FROM t001
  INTO TABLE @DATA(lt_t001)
  WHERE bukrs IN @s_ccode.

  IF sy-subrc IS INITIAL.

    IF p_date IS NOT INITIAL.

      READ TABLE lt_t001 INTO DATA(ls_temp_cc)  INDEX 1.
      IF sy-subrc IS INITIAL.

        CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
          EXPORTING
            companycodeid = ls_temp_cc-bukrs
            posting_date  = p_date
          IMPORTING
            fiscal_year   = lv_fyear
            fiscal_period = lv_period
*           RETURN        =
          .

        IF lv_fyear IS NOT INITIAL.
          p_fyear = lv_fyear.
          s_fper-low = lv_period.
          s_fper-option = 'EQ'.
          s_fper-sign = 'I'.
          APPEND s_fper.
        ENDIF.

      ENDIF.

    ENDIF.

    SELECT rldnr
      FROM finsc_ledger
      INTO TABLE @DATA(lt_ledger)
      WHERE rldnr IN @s_ledger.

    IF sy-subrc IS INITIAL.

      LOOP AT lt_t001 INTO DATA(ls_t001).
        LOOP AT lt_ledger INTO DATA(ls_ledger).


          SELECT   companycode,
                   profitcenter,
                   glaccount,
                   fiscalyear,
                   fiscalperiod,
                   totaldebitamtindisplaycrcy,
                   totalcreditamtindisplaycrcy,
                   totalamountindisplaycrcy
           FROM cvcnglabalperd(
              p_companycode =   @ls_t001-bukrs,
              p_fiscalyear =  @p_fyear,
              p_ledger =      @ls_ledger-rldnr,
              p_currencyrole = @p_crole,
              p_displayaltvacct = @p_glinf )
           APPENDING TABLE @DATA(lt_final)
           WHERE fiscalperiod IN @s_fper.
*            AND  displaycurrency = @p_dcur.  "BY USING  SQL CDS VIEW NAME

        ENDLOOP.
      ENDLOOP.

    ENDIF.
  ENDIF.





  IF lt_final IS NOT INITIAL.

*  MOVE-CORRESPONDING lt_final to gt_data.

    SELECT ktopl, saknr, sakan, glaccount_type
    FROM ska1
    INTO TABLE @DATA(lt_ska1)
    FOR ALL ENTRIES IN @lt_final
    WHERE saknr = @lt_final-glaccount
    and KTOPL = 'PSUS'.

    IF sy-subrc IS INITIAL.

    ENDIF.

    LOOP AT lt_final INTO DATA(ls_final).
      MOVE-CORRESPONDING ls_final TO gs_data.
      gs_data-interface_name = 'INT0065'.
      gs_data-receiver_system = 'EDW'.
      lv_prctr = ls_final-profitcenter.
      IF lv_prctr IS NOT INITIAL.
        CALL FUNCTION 'ZCA_OUTPUT_PC'
          EXPORTING
            iv_pcenters = lv_prctr
            iv_pc_flag  = 'P'
*           IV_LIST     =
          TABLES
            et_output   = lt_zfi_pccenters.

        READ TABLE lt_zfi_pccenters INTO DATA(ls_zfi_pccenters) INDEX 1.
        IF sy-subrc IS INITIAL.
          lv_prctr = ls_zfi_pccenters-numbr.
        ENDIF.
        CLEAR: lt_zfi_pccenters, ls_zfi_pccenters.
        CONDENSE lv_prctr.
        gs_data-profitcenter = lv_prctr.
        READ TABLE lt_ska1 INTO DATA(ls_ska1) WITH KEY saknr = ls_final-glaccount.
        IF sy-subrc IS INITIAL AND ls_ska1-glaccount_type = 'P'.
          gs_data-costcenter = lv_prctr.
        ENDIF.
      ENDIF.
      CONDENSE:gs_data-profitcenter,
      gs_data-totaldebitamtindisplaycrcy,
      gs_data-totalcreditamtindisplaycrcy,
      gs_data-totalamountindisplaycrcy.
*      lv_prctr = | { ls_final-profitcenter ALPHA = IN } |.
      APPEND gs_data TO gt_data.
      CLEAR: ls_final , gs_data, lv_prctr.
    ENDLOOP.



*    gt_data = CORRESPONDING #( lt_final ).
*    gs_data-interface_name = 'INT0065'.
*    gs_data-receiver_system = 'EDW'.
*    MODIFY gt_data FROM gs_data  TRANSPORTING interface_name receiver_system  WHERE interface_name IS INITIAL.

  ENDIF.

  IF gt_data IS NOT INITIAL.
    TRY.
        DATA(lr_send) = NEW zco_zfi_gl_monthly_bal_proxy( ).

        IF p_norec IS INITIAL.
          gs_out-zfi_gl_monthly_bal_sp-zdatagl = gt_data[].

          CALL METHOD lr_send->send
            EXPORTING
              output = gs_out.
          COMMIT WORK.
        ELSE.
          LOOP AT gt_data INTO ls_data.
            APPEND ls_data TO lt_data.
            CHECK ( sy-tabix MOD p_norec EQ 0 ).
            gs_out-zfi_gl_monthly_bal_sp-zdatagl = lt_data[].

            CALL METHOD lr_send->send
              EXPORTING
                output = gs_out.
            COMMIT WORK.
            CLEAR: lt_data, gs_out-zfi_gl_monthly_bal_sp-zdatagl.
          ENDLOOP.
          IF lt_data[] IS NOT INITIAL.
            gs_out-zfi_gl_monthly_bal_sp-zdatagl = lt_data[].

            CALL METHOD lr_send->send
              EXPORTING
                output = gs_out.
            COMMIT WORK.
            CLEAR: lt_data, gs_out-zfi_gl_monthly_bal_sp-zdatagl.
          ENDIF.

        ENDIF.
      CATCH cx_ai_system_fault INTO DATA(ls_text).
    ENDTRY.
  ENDIF.
  MESSAGE 'Process Complete' TYPE 'S'.

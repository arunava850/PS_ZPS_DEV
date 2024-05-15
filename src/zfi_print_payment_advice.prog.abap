*&---------------------------------------------------------------------*
*& Report ZFI_PRINT_PAYMENT_ADVICE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_print_payment_advice.

DATA: ls_outputparams TYPE sfpoutputparams,
      lv_failed       TYPE c,
      cv_retcode      TYPE c,
      lv_chect        TYPE chect,
      lv_vblnr        TYPE vblnr,
      lv_bukrs        TYPE bkpf-bukrs.


DATA :ls_header1    TYPE  zfi_check_data,
      lt_items1     TYPE  zfi_payadv_item_tt,
      ls_items1     TYPE  zfi_payadv_item,
      ls_formoutput TYPE  fpformoutput,
      ls_docparams  TYPE  sfpdocparams,
      lr_docno      TYPE  vblnr,
      lr_check      TYPE  check,
      lv_fm_name    TYPE funcname.


SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS : p_check FOR  lv_chect NO-EXTENSION NO INTERVALS,
                   p_docno FOR  lv_vblnr NO-EXTENSION NO INTERVALS.
  " p_comp for lv_bukrs NO-EXTENSION NO INTERVALS.
  PARAMETERS       p_verb  TYPE zverbiage.
SELECTION-SCREEN : END OF BLOCK b1.

*ls_outputparams-getpdf  = abap_true.
*ls_outputparams-preview = abap_true.
*ls_outputparams-nodialog = abap_true.
ls_outputparams-dest = 'LP01'.
*ls_outputparams-pdfnorm = 'PBFORM'.
*ls_outputparams-COPIES = '1'.


START-OF-SELECTION.
  IF p_docno IS INITIAL AND p_check IS INITIAL.
    MESSAGE 'Please enter check number or Document Number to proceed' TYPE 'I' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
  IF p_docno IS NOT INITIAL.
    SELECT SINGLE * FROM payr INTO @DATA(ls_payr)
      WHERE vblnr IN @p_docno.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'Please enter a valid Document Number' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
  IF p_check IS NOT INITIAL.
    SELECT SINGLE * FROM payr INTO @ls_payr
      WHERE chect IN @p_check.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'Please enter a valid check number' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF p_docno IS NOT INITIAL AND p_check IS NOT INITIAL.

    SELECT SINGLE * FROM payr INTO @ls_payr
      WHERE vblnr IN @p_docno
      AND   chect IN @p_check.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE 'No data found for the combination of Check & Document Number' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.



*   Open the spool job
    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = ls_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.
    IF sy-subrc <> 0.
      cv_retcode = sy-subrc.
*     Error Handling
      RETURN.
    ENDIF.


  ENDIF.

* Get the name of the generated function module
  TRY.
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = 'ZFI_PAYM_ADVICE_FORM'
        IMPORTING
          e_funcname = lv_fm_name.

    CATCH cx_fp_api_repository
          cx_fp_api_usage
          cx_fp_api_internal.

      cv_retcode = 99.
*       Error Handling

      RETURN.
  ENDTRY.

*  IF p_docno IS INITIAL AND p_check IS INITIAL.
*    MESSAGE 'Please enter check number or Document Number to proceed' TYPE 'I' DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
*  SELECT SINGLE * FROM payr INTO @DATA(ls_payr)
*    WHERE vblnr IN @p_docno
*    AND   chect IN @p_check.
*  IF sy-subrc IS NOT INITIAL.
*    MESSAGE 'Please enter a valid check number or Document Number' TYPE 'I' DISPLAY LIKE 'E'.
*    LEAVE LIST-PROCESSING.
*  ENDIF.

  SELECT belnr FROM regup INTO TABLE @DATA(lt_regup) WHERE vblnr = @ls_payr-vblnr
                                                     AND   zbukr = @ls_payr-zbukr
                                                     AND   laufd = @ls_payr-laufd.
*                                                     gjahr = @ls_payr-gjahr.
  IF sy-subrc = 0.
    SELECT * FROM zfiap_ep_data INTO TABLE @DATA(lt_zfiap_ep_data)
                                FOR ALL ENTRIES IN @lt_regup
                                WHERE document_number = @lt_regup-belnr.
    IF lt_zfiap_ep_data IS NOT INITIAL.
      SELECT * FROM lfa1 INTO TABLE @DATA(lt_lfa1)
        FOR ALL ENTRIES IN @lt_zfiap_ep_data
        WHERE lifnr = @lt_zfiap_ep_data-tenant_number.
*        WHERE lifnr = @lt_zfiap_ep_data-payee_number.

      SELECT * FROM cepc  INTO TABLE @DATA(lt_cepc)
        FOR ALL ENTRIES IN @lt_zfiap_ep_data
        WHERE prctr = @lt_zfiap_ep_data-business_unit.
*      AND   spras = 'E'.
    ENDIF.

  ENDIF.

  LOOP AT lt_zfiap_ep_data INTO DATA(ls_zfiap_ep_data).

    ls_header1-amount = ls_header1-amount  + ls_zfiap_ep_data-amount.

    ls_items1-sales_date = ls_zfiap_ep_data-sales_date.
    ls_items1-amount     = ls_zfiap_ep_data-amount.
    ls_items1-waers      = ls_zfiap_ep_data-waers.
    ls_items1-payee_name = ls_zfiap_ep_data-tenant_name.
*    ls_items1-payee_name = ls_zfiap_ep_data-payee_name.
    READ TABLE lt_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_zfiap_ep_data-tenant_number.
*    READ TABLE lt_lfa1 INTO DATA(ls_lfa1) WITH KEY lifnr = ls_zfiap_ep_data-payee_number.

    IF sy-subrc IS INITIAL.
      ls_items1-address    = ls_lfa1-stras.
      ls_items1-city       = ls_lfa1-ort01.
      ls_items1-state      = ls_lfa1-regio.
      ls_items1-post_code  = ls_lfa1-pstlz.
    ENDIF.

    ls_items1-county     = ls_zfiap_ep_data-business_unit_country.

    READ TABLE lt_cepc INTO DATA(ls_cepc) WITH KEY prctr = ls_zfiap_ep_data-business_unit.
    IF sy-subrc IS INITIAL.
*      DATA(lv_unit) = |{ ls_zfiap_ep_data-business_unit ALPHA = OUT }|.
*      CONDENSE lv_unit.
*       CONCATENATE lv_unit  ls_cepct-ktext
*                  INTO ls_items1-sale_address SEPARATED BY space.
      ls_items1-sale_address = ls_cepc-stras.
    ENDIF.

    ls_items1-state_of_sale = ls_zfiap_ep_data-business_unit_state.

    APPEND ls_items1 TO lt_items1.
    CLEAR ls_items1.

  ENDLOOP.

  SELECT SINGLE adrnr, ktokk FROM lfa1 INTO @DATA(lv_adrnr)
    WHERE lifnr = @ls_payr-lifnr.

  SELECT SINGLE name1, name2, city1, street, region, post_code1, house_num1
    FROM adrc INTO @DATA(ls_lfa1_adrc)
    WHERE addrnumber = @lv_adrnr-adrnr.

  IF lv_adrnr-ktokk = 'Z003'.
    CONCATENATE ls_lfa1_adrc-name1 ls_lfa1_adrc-name2 INTO ls_header1-lifnr_name SEPARATED BY space.
    CLEAR ls_header1-lifnr_name2.
  ELSE.
    ls_header1-lifnr_name      = ls_lfa1_adrc-name1.
    ls_header1-lifnr_name2     = ls_lfa1_adrc-name2.
  ENDIF.

*  ls_header1-lifnr_name1     = ls_lfa1_adrc-name1.
*  ls_header1-lifnr_name2     = ls_lfa1_adrc-name2.
  ls_header1-lifnr_street    = ls_lfa1_adrc-street.
  ls_header1-lifnr_city2     = ls_lfa1_adrc-city1.

  CONCATENATE ls_lfa1_adrc-city1 ls_lfa1_adrc-region ls_lfa1_adrc-post_code1
              INTO ls_header1-lifnr_city_reg_pstlz SEPARATED BY space.

  CLEAR : ls_lfa1_adrc, lv_adrnr.
  SELECT SINGLE adrnr FROM t001 INTO @lv_adrnr
    WHERE bukrs = @ls_payr-zbukr.
  SELECT SINGLE name1, name2, city1, street, region, post_code1, house_num1
    FROM adrc INTO @ls_lfa1_adrc
    WHERE addrnumber = @lv_adrnr.

  ls_header1-bukrs_name1     = ls_lfa1_adrc-name1.
  CONCATENATE ls_lfa1_adrc-house_num1 ls_lfa1_adrc-street INTO ls_header1-bukrs_street SEPARATED BY space.

*  ls_header1-bukrs_street    = ls_lfa1_adrc-street.
  ls_header1-verbiage    = p_verb.

  CONCATENATE ls_lfa1_adrc-city1 ls_lfa1_adrc-region ls_lfa1_adrc-post_code1
              INTO ls_header1-bukrs_city_reg_pstlz SEPARATED BY space.

  CALL FUNCTION lv_fm_name      "/1BCDWB/SM00000019
    EXPORTING
      /1bcdwb/docparams  = ls_docparams
      ls_header1         = ls_header1
      lt_items1          = lt_items1
    IMPORTING
      /1bcdwb/formoutput = ls_formoutput
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      internal_error     = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF NOT sy-subrc IS INITIAL.
    cv_retcode = sy-subrc.
*   Error Handling
* Do not directly return but only after closing the spool job
    lv_failed = abap_true.
  ENDIF.

  DATA ls_joboutput TYPE  sfpjoboutput.
*   Close the spool job
  CALL FUNCTION 'FP_JOB_CLOSE'
    IMPORTING
      e_result       = ls_joboutput
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  IF sy-subrc <> 0.
    cv_retcode = sy-subrc.
*     Error Handling
    RETURN.
  ENDIF.

  IF NOT lv_failed IS INITIAL.
*     Now, leave processing if printing did fail
    RETURN.
  ENDIF.

*CLASS lcl_pay_advice DEFINITION.
*PUBLIC SECTION.
*  METHODS : validate_inputs.
*
*
*ENDCLASS.
*CLASS lcl_pay_advice IMPLEMENTATION.
*  METHOD validate_inputs.
*  ENDMETHOD.
*ENDCLASS.
*

*
*START-OF-SELECTION.
*
* DATA(O_REF) = NEW lcl_pay_advice( ) .

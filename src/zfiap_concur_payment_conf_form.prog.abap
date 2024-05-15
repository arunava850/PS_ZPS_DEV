*&---------------------------------------------------------------------*
*& Include          ZFIAP_CONCUR_PAYMENT_CONF_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form extract_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM extract_data .

  DATA: lv_worker TYPE char6.
  DATA: lt_mail_wd_temp TYPE TABLE OF ty_mail_wd_temp,
        ls_mail_wd_temp TYPE ty_mail_wd_temp.
  DATA: lt_final_wd_temp TYPE TABLE OF ty_final_wd_temp,
        ls_final_wd_temp TYPE ty_final_wd_temp.
*** Get Accounting header and item data

  SELECT  bukrs, belnr, gjahr,  bktxt, xref1_hd FROM bkpf INTO TABLE @DATA(lt_bkpf)
                                                   WHERE blart EQ 'YC'
                                                     AND cpudt IN @s_edate. "#EC CI_NOFIELD

  IF sy-subrc = 0.
    SORT lt_bkpf BY bukrs belnr gjahr.
*** Exclude unchecked pay groups from BKPF table
    DELETE lt_bkpf WHERE xref1_hd NOT IN r_tbl_xref.
    IF lt_bkpf IS NOT INITIAL.
      SELECT bukrs, belnr, gjahr, buzei, wrbtr, shkzg, sgtxt FROM bseg INTO TABLE @DATA(lt_bseg)
                                                      FOR ALL ENTRIES IN @lt_bkpf
                                                      WHERE bukrs = @lt_bkpf-bukrs
                                                        AND belnr = @lt_bkpf-belnr
                                                        AND gjahr = @lt_bkpf-gjahr
                                                        AND hkont = '0000205000'.
      IF sy-subrc EQ 0.
        SORT lt_bseg BY bukrs belnr gjahr buzei.
      ENDIF.
    ELSE.
      MESSAGE 'No data found' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
    MESSAGE 'No data found' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

*** Fill final internal table
  LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>).

    READ TABLE lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>) WITH KEY  bukrs = <fs_bseg>-bukrs
                                                            belnr = <fs_bseg>-belnr
                                                            gjahr = <fs_bseg>-gjahr.
    IF sy-subrc EQ 0.
      gs_final-rec_type = '600'.
      gs_final-wrbtr = <fs_bseg>-wrbtr.
      IF <fs_bseg>-shkzg = 'H'.
        gs_final-wrbtr = gs_final-wrbtr * -1.
      ENDIF.

      SPLIT <fs_bseg>-sgtxt AT '/' INTO <fs_bseg>-sgtxt gs_final-sgtxt.
      gs_final-pay_method = 'E'.
      gs_final-belnr = <fs_bseg>-belnr.
      gs_final-bktxt = <fs_bkpf>-bktxt.
      gs_final-pay_curr = 'USD'.
      gs_final-reserved1 = ''.
      gs_final-reserved2 = ''.
      gs_final-reserved3 = ''.
      gs_final-reserved4 = ''.
      gs_final-reserved5 = ''.
*** Fill the payment date using pay group ID
      IF <fs_bkpf>-xref1_hd EQ gc_hnz.
        gs_final-pay_date = p_hnz_dt.
*        gs_final_wd-batch_id = p_hnz_dt.
*        CONCATENATE p_hnz_dt+0(4) p_hnz_dt+4(2) p_hnz_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '-'.
*        gs_final_wd-start_date = p_hnz_ps.
*        gs_final_wd-End_date = p_hnz_pe.
        CONCATENATE p_hnz_dt+0(4) p_hnz_dt+4(2) p_hnz_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_hnz_ps+0(4) p_hnz_ps+4(2) p_hnz_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_hnz_pe+0(4) p_hnz_pe+4(2) p_hnz_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_hpa.
        gs_final-pay_date = p_hpa_dt.
*        gs_final_wd-batch_id = p_hpa_dt.
*        gs_final_wd-start_date = p_hpa_ps.
*        gs_final_wd-End_date = p_hpa_pe.
        CONCATENATE p_hpa_dt+0(4) p_hpa_dt+4(2) p_hpa_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_hpa_ps+0(4) p_hpa_ps+4(2) p_hpa_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_hpa_pe+0(4) p_hpa_pe+4(2) p_hpa_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_hpl.
        gs_final-pay_date = p_hpl_dt.
*        gs_final_wd-batch_id = p_hpl_dt.
*        gs_final_wd-start_date = p_hpl_ps.
*        gs_final_wd-End_date = p_hpl_pe.
        CONCATENATE p_hpl_dt+0(4) p_hpl_dt+4(2) p_hpl_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_hpl_ps+0(4) p_hpl_ps+4(2) p_hpl_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_hpl_pe+0(4) p_hpl_pe+4(2) p_hpl_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_hpw.
        gs_final-pay_date = p_hpw_dt.
*        gs_final_wd-batch_id = p_hpw_dt.
*        gs_final_wd-start_date = p_hpw_ps.
*        gs_final_wd-End_date = p_hpw_pe.
        CONCATENATE p_hpw_dt+0(4) p_hpw_dt+4(2) p_hpw_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_hpw_ps+0(4) p_hpw_ps+4(2) p_hpw_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_hpw_pe+0(4) p_hpw_pe+4(2) p_hpw_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_lfv.
        gs_final-pay_date = p_lfv_dt.
*        gs_final_wd-batch_id = p_lfv_dt.
*        gs_final_wd-start_date = p_lfv_ps.
*        gs_final_wd-End_date = p_lfv_pe.
        CONCATENATE p_lfv_dt+0(4) p_lfv_dt+4(2) p_lfv_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_lfv_ps+0(4) p_lfv_ps+4(2) p_lfv_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_lfv_pe+0(4) p_lfv_pe+4(2) p_lfv_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_v97.
        gs_final-pay_date = p_v97_dt.
*        gs_final_wd-batch_id = p_v97_dt..
*        gs_final_wd-start_date = p_v97_ps.
*        gs_final_wd-End_date = p_v97_pe.
        CONCATENATE p_v97_dt+0(4) p_v97_dt+4(2) p_v97_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_v97_ps+0(4) p_v97_ps+4(2) p_v97_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_v97_pe+0(4) p_v97_pe+4(2) p_v97_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_v98.
        gs_final-pay_date = p_v98_dt.
*        gs_final_wd-batch_id = p_v98_dt.
*        gs_final_wd-start_date = p_v98_ps.
*        gs_final_wd-End_date = p_v98_pe.
        CONCATENATE p_v98_dt+0(4) p_v98_dt+4(2) p_v98_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_v98_ps+0(4) p_v98_ps+4(2) p_v98_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_v98_pe+0(4) p_v98_pe+4(2) p_v98_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ELSEIF <fs_bkpf>-xref1_hd EQ gc_hpn.
        gs_final-pay_date = p_hpn_dt.
        CONCATENATE p_hpn_dt+0(4) p_hpn_dt+4(2) p_hpn_dt+6(2) INTO gs_final_wd-batch_id SEPARATED BY '.'.
        CONCATENATE 'Concur Exp' gs_final_wd-batch_id INTO gs_final_wd-batch_id SEPARATED BY space.
        CONCATENATE p_hpn_ps+0(4) p_hpn_ps+4(2) p_hpn_ps+6(2) INTO gs_final_wd-start_date SEPARATED BY '-'.
        CONCATENATE p_hpn_pe+0(4) p_hpn_pe+4(2) p_hpn_pe+6(2) INTO gs_final_wd-End_date SEPARATED BY '-'.
      ENDIF.
*** fill output internal table
      APPEND gs_final TO gt_final.
      CLEAR: gs_final.

**** Fill Workday data for Int 111
*    gs_final_wd-field = sy-tabix.    "j
      gs_final_wd-spreadsheet_key = sy-tabix.
      SHIFT gs_final_wd-spreadsheet_key LEFT DELETING LEADING space.
      gs_final_wd-row_id = 1. "sy-tabix.
      SHIFT gs_final_wd-row_id LEFT DELETING LEADING space.
      gs_final_wd-ongoing_input = 'N'.
      gs_final_wd-run_category = 'RC_REGULAR'.
      lv_worker =  <fs_bseg>-sgtxt.
      lv_worker = |{ lv_worker ALPHA = IN }|.
      gs_final_wd-worker = lv_worker.
      gs_final_wd-earning = ''.
      gs_final_wd-deduction = 'EXPNS'.
      gs_final_wd-amount = <fs_bseg>-wrbtr.
      IF <fs_bseg>-shkzg = 'H'.
*        CONCATENATE '-' gs_final_wd-amount into gs_final_wd-amount.
        gs_final_wd-amount = gs_final_wd-amount * -1.
      ENDIF.
      gs_final_wd-adjustment =''.
      gs_final_wd-cost_center = ''.
      gs_final_wd-custom_worktag01 = ''.
      gs_final_wd-rowid = ''.
      gs_final_wd-related_calculation = ''.
      gs_final_wd-input_value = ''.
      gs_final_wd-comments = ''.

      APPEND gs_final_wd TO gt_final_wd.
      CLEAR: gs_final_wd, lv_worker.
*      REFRESH : gt_final_wd.    "j
    ENDIF.
  ENDLOOP.
  DATA: lv_amount TYPE char8.

  IF cb_prxy EQ abap_true AND gt_final IS NOT INITIAL.
    LOOP AT gt_final INTO gs_final.
      MOVE-CORRESPONDING gs_final TO gs_output.
      lv_amount = gs_output-wrbtr.
      IF lv_amount LT 0.
        REPLACE ALL OCCURRENCES OF '.' IN lv_amount WITH space.
        lv_amount = lv_amount * -1.
        CONDENSE lv_amount NO-GAPS.
        SHIFT lv_amount RIGHT DELETING TRAILING space.
        lv_amount = |{ lv_amount ALPHA = IN }|.
        CONCATENATE '-' lv_amount INTO gs_output-wrbtr.
      ELSE.
        REPLACE ALL OCCURRENCES OF '.' IN lv_amount WITH space.
        CONDENSE lv_amount NO-GAPS.
        SHIFT lv_amount RIGHT DELETING TRAILING space.
        lv_amount = |{ lv_amount ALPHA = IN }|.
        gs_output-wrbtr = lv_amount.
      ENDIF.
*      OVERLAY lv_amount  WITH '00000000'.
      APPEND INITIAL LINE TO gt_proxy ASSIGNING FIELD-SYMBOL(<lfs_proxy>).
      <lfs_proxy> =  CORRESPONDING #( gs_output ).
      <lfs_proxy>-interface_name = 'INT0034'.
      <lfs_proxy>-receiver_system = 'CONC'.
    ENDLOOP.
  ENDIF.

  IF gt_final_wd IS NOT INITIAL.

    APPEND INITIAL LINE TO gt_mail_wd ASSIGNING FIELD-SYMBOL(<lfs_mail_wd>).
    <lfs_mail_wd>-field  =  'Submit On Cycle Payroll with Comment Input'.
    <lfs_mail_wd>-spreadsheet_key  =  ''.
    <lfs_mail_wd>-row_id  =  ''.
    <lfs_mail_wd>-batch_id  =  ''  .
    <lfs_mail_wd>-ongoing_input  =  ''  .
    <lfs_mail_wd>-start_date  =  ''  .
    <lfs_mail_wd>-end_date  =  ''  .
    <lfs_mail_wd>-run_category  =  ''  .
    <lfs_mail_wd>-worker  =  ''  .
    <lfs_mail_wd>-earning  =  ''  .
    <lfs_mail_wd>-deduction  =  ''  .
    <lfs_mail_wd>-amount  =  ''  .
    <lfs_mail_wd>-adjustment  =  ''  .
    <lfs_mail_wd>-cost_center  =  ''  .
    <lfs_mail_wd>-custom_worktag01  =  ''  .
    <lfs_mail_wd>-rowid  =  ''  .
    <lfs_mail_wd>-related_calculation  =  ''  .
    <lfs_mail_wd>-input_value  =  ''  .
    <lfs_mail_wd>-comments  =  ''   .

    APPEND INITIAL LINE TO gt_mail_wd ASSIGNING <lfs_mail_wd>.
    <lfs_mail_wd>-field  =  'Area'.
    <lfs_mail_wd>-spreadsheet_key  =  'All'.
    <lfs_mail_wd>-row_id  =  'Payroll Input Data+ (Submit Payroll Input Request)'.
    <lfs_mail_wd>-batch_id  =  ''  .
    <lfs_mail_wd>-ongoing_input  =  ''  .
    <lfs_mail_wd>-start_date  =  ''  .
    <lfs_mail_wd>-end_date  =  ''  .
    <lfs_mail_wd>-run_category  =  ''  .
    <lfs_mail_wd>-worker  =  ''  .
    <lfs_mail_wd>-earning  =  ''  .
    <lfs_mail_wd>-deduction  =  ''  .
    <lfs_mail_wd>-amount  =  ''  .
    <lfs_mail_wd>-adjustment  =  ''  .
    <lfs_mail_wd>-cost_center  =  'Worktag Data (Submit Payroll Input Request > Payroll Input Data+)'  .
    <lfs_mail_wd>-custom_worktag01  =  ''  .
    <lfs_mail_wd>-rowid  =  'Additional Input Details Data+ (Submit Payroll Input Request > Payroll Input Data+)'  .
    <lfs_mail_wd>-related_calculation  =  ''  .
    <lfs_mail_wd>-input_value  =  ''  .
    <lfs_mail_wd>-comments  =  'Payroll Input Data+ (Submit Payroll Input Request)'   .

    DO 3 TIMES.
      APPEND INITIAL LINE TO gt_mail_wd ASSIGNING <lfs_mail_wd>.
      <lfs_mail_wd>-field  =  'Fields'.
      <lfs_mail_wd>-spreadsheet_key  =  'Spreadsheet Key*'  .
      <lfs_mail_wd>-row_id  =  'Row ID**'  .
      <lfs_mail_wd>-batch_id  =  'Batch ID'  .
      <lfs_mail_wd>-ongoing_input  =  'Ongoing Input'  .
      <lfs_mail_wd>-start_date  =  'Start Date*'  .
      <lfs_mail_wd>-end_date  =  'End Date'  .
      <lfs_mail_wd>-run_category  =  'Run_Category_ID'  .
      <lfs_mail_wd>-worker  =  'Employee_ID'  .
      <lfs_mail_wd>-earning  =  'Earning*'  .
      <lfs_mail_wd>-deduction  =  'Deduction_Code'  .
      <lfs_mail_wd>-amount  =  'Amount'  .
      <lfs_mail_wd>-adjustment  =  'Adjustment'  .
      <lfs_mail_wd>-cost_center  =  'Cost Center'  .
      <lfs_mail_wd>-custom_worktag01  =  'Custom Worktag 01'  .
      <lfs_mail_wd>-rowid  =  'Row ID*'  .
      <lfs_mail_wd>-related_calculation  =  'Related Calculation'  .
      <lfs_mail_wd>-input_value  =  'Input Value'  .
      <lfs_mail_wd>-comments  =  'Comment'   .

    ENDDO.

    LOOP AT gt_final_wd INTO gs_final_wd.
      MOVE-CORRESPONDING gs_final_wd TO gs_mail_wd.

      IF gs_final_wd-amount LT 0.
        gs_mail_wd-amount = gs_mail_wd-amount * -1.
        CONCATENATE '-' gs_mail_wd-amount INTO gs_mail_wd-amount.
      ENDIF.
      MOVE-CORRESPONDING gs_mail_wd TO ls_mail_wd_temp.
      APPEND ls_mail_wd_temp TO lt_mail_wd_temp.
*      APPEND gs_mail_wd TO gt_mail_wd.
      CLEAR: gs_mail_wd, ls_mail_wd_temp.
*      APPEND INITIAL LINE TO gt_proxy_wd ASSIGNING <lfs_proxy_wd>.
*      <lfs_proxy_wd> =  CORRESPONDING #( gs_mail_wd ).
*      <lfs_proxy_wd>-interface_name = 'INT0111'.
*      <lfs_proxy_wd>-receiver_system = 'WD'.
    ENDLOOP.

    DATA: lv_spreadkey TYPE string,
          lv_rowid     TYPE string.
    lv_spreadkey = 1.

    REFRESH: gt_final_wd.
*** Get spreadsheet key and key ID for send mail
    SORT lt_mail_wd_temp BY worker ASCENDING.
    LOOP AT lt_mail_wd_temp INTO ls_mail_wd_temp.
      MOVE-CORRESPONDING ls_mail_wd_temp TO gs_mail_wd.
      MOVE-CORRESPONDING ls_mail_wd_temp TO gs_final_wd.   "j
      gs_mail_wd-spreadsheet_key = lv_spreadkey.
      gs_final_wd-spreadsheet_key = lv_spreadkey.
      lv_rowid = lv_rowid + 1.
      gs_mail_wd-row_id = lv_rowid.
      gs_final_wd-row_id = lv_rowid.
      AT END OF worker.
        lv_spreadkey = lv_spreadkey + 1.
        CLEAR: lv_rowid.
      ENDAT.
      APPEND gs_mail_wd TO gt_mail_wd.
      APPEND gs_final_wd TO gt_final_wd.   "j
    ENDLOOP.


  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form screen_validations
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM screen_validations .

*** Check if atleast one pay group is selected
  IF p_hnz EQ abap_false
  AND p_hpa EQ abap_false
  AND p_hpl EQ abap_false
  AND p_hpw EQ abap_false
  AND p_lfv EQ abap_false
  AND p_v97 EQ abap_false
  AND p_v98 EQ abap_false
  AND p_hpn EQ abap_false.
    MESSAGE TEXT-015 TYPE 'E'.
  ENDIF.

*** Check the payment date entry for each pay group selection
  IF p_hnz EQ abap_true AND ( p_hnz_dt IS INITIAL OR p_hnz_ps IS INITIAL OR p_hnz_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_hpa EQ abap_true AND ( p_hpa_dt IS INITIAL OR p_hpa_ps IS INITIAL OR p_hpa_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_hpl EQ abap_true AND ( p_hpl_dt IS INITIAL OR p_hpl_ps IS INITIAL OR p_hpl_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_hpw EQ abap_true AND ( p_hpw_dt IS INITIAL OR p_hpw_ps IS INITIAL OR p_hpw_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_lfv EQ abap_true AND ( p_lfv_dt IS INITIAL OR p_lfv_ps IS INITIAL OR p_lfv_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_v97 EQ abap_true AND ( p_v97_dt IS INITIAL OR p_v97_ps IS INITIAL OR p_v97_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_v98 EQ abap_true AND ( p_v98_dt IS INITIAL OR p_v98_ps IS INITIAL OR p_v98_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ELSEIF  p_hpn EQ abap_true AND ( p_hpn_dt IS INITIAL OR p_hpn_ps IS INITIAL OR p_hpn_pe IS INITIAL ).
    MESSAGE TEXT-016 TYPE 'E'.
  ENDIF.

*** ALV Display restrictions
  IF cb_int34 EQ abap_true AND cb_it111 EQ abap_true AND cb_alv EQ abap_true.
    MESSAGE TEXT-019 TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_xref_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_xref_data .

*** Fill range table to validate pay group with XREF1 field from BKPF
  IF p_hnz EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'HNZ'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_hpa EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'HPA'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_hPL EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'HPL'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_hpw EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'HPW'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_lfv EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'LFV'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_v97 EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'V97'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_v98 EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'V98'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
  IF p_hpn EQ abap_true.
    wa_xref-sign = 'I'.
    wa_xref-option = 'EQ'.
    wa_xref-low = 'HPN'.
    APPEND wa_xref TO r_tbl_xref.
    CLEAR: wa_xref.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
  DATA: lc_msg TYPE REF TO cx_salv_msg.

  TRY.
      "Instantiation
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = DATA(lo_alv)
        CHANGING
          t_table      = gt_final ).
    CATCH cx_salv_msg INTO lc_msg .
      gv_msg = lc_msg->get_text( ).
      MESSAGE gv_msg TYPE 'I'.
  ENDTRY.
  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Set column headings
  lo_alv->get_columns( )->set_optimize( abap_true ).
  TRY.
      lo_alv->get_columns( )->get_column( 'REC_TYPE')->set_medium_text( 'Record Type' ).
      lo_alv->get_columns( )->get_column( 'WRBTR')->set_medium_text( 'Payment Amount' ).
      lo_alv->get_columns( )->get_column( 'PAY_DATE')->set_medium_text( 'Payment Date' ).
      lo_alv->get_columns( )->get_column( 'SGTXT')->set_medium_text( 'Payee' ).
      lo_alv->get_columns( )->get_column( 'PAY_METHOD')->set_medium_text( 'Payment Method' ).
      lo_alv->get_columns( )->get_column( 'BELNR')->set_medium_text( 'Transaction Number' ).
      lo_alv->get_columns( )->get_column( 'BKTXT')->set_medium_text( 'Report ID' ).
      lo_alv->get_columns( )->get_column( 'PAY_CURR')->set_medium_text( 'Payment Currency' ).
      lo_alv->get_columns( )->get_column( 'RESERVED1')->set_medium_text( 'Reserved 1' ).
      lo_alv->get_columns( )->get_column( 'RESERVED2')->set_medium_text( 'Reserved 2' ).
      lo_alv->get_columns( )->get_column( 'RESERVED3')->set_medium_text( 'Reserved 3' ).
      lo_alv->get_columns( )->get_column( 'RESERVED4')->set_medium_text( 'Reserved 4' ).
      lo_alv->get_columns( )->get_column( 'RESERVED5')->set_medium_text( 'Reserved 5' ).
    CATCH cx_salv_not_found INTO gt_salv_not_found.
      gv_msg = gt_salv_not_found->get_text( ).
      MESSAGE gv_msg TYPE gc_error.
  ENDTRY.
  "Display the ALV Grid
  lo_alv->display( ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_send_to_proxy
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send_to_proxy .

  DATA:ls_output_proxy TYPE zmt_ob_msgtyp_concurpaymt.

  IF gt_proxy[] IS NOT INITIAL AND cb_prxy IS NOT INITIAL.
    TRY.
        DATA(lo_obj_proxy) = NEW zco_fi_s4_to_concurpaymnt( ).
        IF lo_obj_proxy IS BOUND.
          ls_output_proxy-zmt_ob_msgtyp_concurpaymt-it_data[] = gt_proxy[].
          lo_obj_proxy->send_data( output = ls_output_proxy ).
          COMMIT WORK AND WAIT.
          MESSAGE 'The data send to CPI is initiated.' TYPE 'S'.
        ENDIF.
      CATCH cx_ai_system_fault INTO DATA(lo_fault).

        DATA(lv_error) = lo_fault->errortext.
        IF lv_error IS NOT INITIAL.
          MESSAGE lv_error TYPE 'I'.
        ENDIF.
        MESSAGE 'Exception occurred while transferring proxy data.' TYPE 'E'.

    ENDTRY.
  ELSE.
    MESSAGE 'No data found' TYPE 'E'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_send_email
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send_email .
*tables: adr6.
  DATA :
    ls_attachment_string   TYPE string,                   " New Output
    ls_attachment_string_2 TYPE string,                 " New Output
    lt_contents_hex        TYPE TABLE OF solix,           " New Output
    ls_contents_hex        TYPE solix,                    " New Output
    lt_output_attachment   TYPE TABLE OF solix,           " New Output
    lv_contents_line       TYPE xstring,
    lv_content             TYPE string.



  DATA: lv_size TYPE so_obj_len,
        eo_bcs  TYPE REF TO cx_bcs.

  IF gt_mail_wd  IS NOT INITIAL.
**** Append headings
    CONCATENATE 'Field' 'Spreadsheet Key' 'Row ID' 'Batch ID' 'Ongoing Input' 'Start Date' 'Pay Period End Date' 'Run_Category_ID'   "j
  'Employee_ID' 'Earning' 'Deduction_Code' 'Pay Amount' 'Adjustment' 'Cost Center' 'Custom Worktag 01' 'Row ID'
  'Related Calculation' 'Input Value' 'Comment' INTO ls_attachment_string SEPARATED BY gc_tab.
    CONCATENATE ls_attachment_string gc_crlf INTO ls_attachment_string.

*** Fill interal table data
    LOOP AT gt_mail_wd INTO gs_mail_wd.
      IF sy-tabix GT 5.
        CONCATENATE  gs_mail_wd-field      gc_tab   "j
             gs_mail_wd-spreadsheet_key     gc_tab
            gs_mail_wd-row_id              gc_tab
            gs_mail_wd-batch_id            gc_tab
            gs_mail_wd-ongoing_input       gc_tab
            gs_mail_wd-start_date          gc_tab
            gs_mail_wd-end_date            gc_tab
            gs_mail_wd-run_category        gc_tab
            gs_mail_wd-worker              gc_tab
            gs_mail_wd-earning             gc_tab
            gs_mail_wd-deduction           gc_tab
            gs_mail_wd-amount              gc_tab
           gs_mail_wd-adjustment          gc_tab
*     gs_mail_wd-owner_city          gc_tab
            gs_mail_wd-cost_center         gc_tab
            gs_mail_wd-custom_worktag01    gc_tab
            gs_mail_wd-rowid               gc_tab
            gs_mail_wd-related_calculation gc_tab
            gs_mail_wd-input_value         gc_tab
           gs_mail_wd-comments            gc_crlf   INTO ls_attachment_string_2.
*     gs_output-prop_init_amount  gc_crlf   INTO lv_content.

        CONCATENATE ls_attachment_string ls_attachment_string_2 INTO ls_attachment_string.
      ENDIF.
    ENDLOOP.
    TRY.
        cl_bcs_convert=>string_to_solix(
            EXPORTING
                 iv_string = ls_attachment_string   " your delimited string
                 iv_codepage = '4103' " for MS Excel
                 iv_add_bom = 'X'
            IMPORTING
                 et_solix = lt_output_attachment        " the binary, XLS file
                   ev_size = lv_size ).
      CATCH cx_bcs INTO eo_bcs.
        RAISE eo_bcs.
    ENDTRY.

    PERFORM f_send_mail TABLES lt_output_attachment
                      USING  lv_size.
  ELSE.
    MESSAGE TEXT-020 TYPE 'E'.
  ENDIF.
ENDFORM.
FORM f_send_mail TABLES i_attachment
               USING  i_size.

* Data Declarations
  DATA: lt_mailsubject     TYPE sodocchgi1.
  DATA: lt_mailrecipients  TYPE STANDARD TABLE OF somlrec90
        WITH HEADER LINE.
  DATA: lt_mailtxt TYPE TABLE OF soli, "TYPE STANDARD TABLE OF SOLI
        "WITH HEADER LINE.
        ls_mailtxt TYPE string. "SOLI.
  DATA: lv_subject      TYPE so_obj_des."STRING.
  DATA: ls_document_data     TYPE  sodocchgi1,
        lt_document_data     TYPE STANDARD TABLE OF sodocchgi1,
        lt_attachment        TYPE STANDARD TABLE OF solisti1,
        ls_packing_list      TYPE  sopcklsti1,
        lt_packing_list      TYPE STANDARD TABLE OF sopcklsti1,
        ls_receivers         TYPE  somlreci1,
        lt_receivers         TYPE STANDARD TABLE OF somlreci1,
        lv_date              TYPE string,
        lv_str               TYPE string,
        lv_tbl1              TYPE string,
        lv_tbl2              TYPE string,
        g_tab_lines          TYPE i,
        g_sent_to_all        TYPE sonv-flag,
        gt_body_msg          TYPE STANDARD TABLE OF solisti1,
        gs_body_msg          TYPE solisti1,
        lt_output_attachment TYPE TABLE OF solix,           " New Output
        lv_view              TYPE string.

  lt_output_attachment[] = i_attachment[].


  lv_view = 'Concur Data'.


***   To Convert the valid from and to date
  CONCATENATE 'Concur reimbursement to workday - ' sy-datum+6(2)'.'sy-datum+4(2)'.'
   sy-datum+0(4) '-' lv_view INTO lv_subject.

* Subject.
  lt_mailsubject-obj_name = 'Concur reimbursement to workday'.
  lt_mailsubject-obj_langu = sy-langu.
  lt_mailsubject-obj_descr = lv_subject.


********send emails***************************************************
  DATA: message      TYPE REF TO cl_bcs,      " envelope
        document     TYPE REF TO cl_document_bcs,   " letter
        mailto       TYPE ad_smtpadr,
        lo_recipient TYPE REF TO cl_cam_address_bcs,
        lo_sender    TYPE REF TO cl_cam_address_bcs.


  CONCATENATE 'Hi Team,'
     '<html></br></htm>' INTO ls_mailtxt "LT_MAILTXT
  RESPECTING BLANKS.


  CONCATENATE ls_mailtxt 'Attached is Concure reimbursement file interface from s4 to workday '
        sy-datum+6(2)'.'sy-datum+4(2)'.'
      sy-datum+0(4) '  ' sy-timlo ' ' sy-zonlo INTO ls_mailtxt
  RESPECTING BLANKS.


  DATA: lv_size_mailtxt      TYPE so_obj_len,
        lt_output_mailtxt    TYPE TABLE OF solix,
        lt_attachment_header TYPE TABLE OF soli,
        ls_attachment_header TYPE soli,
        lv_filename          TYPE string.

  lv_filename = 'Concure reimbursement to workday.xlsx'.
  CONCATENATE '&SO_FILENAME='lv_filename INTO ls_attachment_header.
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

  DATA: lv_i_type TYPE soodk-objtp VALUE 'XLS'.
* now you are going to attach your spreadsheet to the letter
  DATA eo_document_bcs  TYPE REF TO cx_document_bcs.

  TRY.
      document->add_attachment(
       i_attachment_type    = lv_i_type
       i_attachment_subject = 'Concur reimbursement to workday'  " Your file name
       i_attachment_size    = i_size
       i_att_content_hex    = lt_output_attachment
*   I_ATTACHMENT_HEADER  = LT_ATTACHMENT_HEADER
        ).
    CATCH cx_document_bcs INTO eo_document_bcs.
      RAISE eo_document_bcs.
  ENDTRY.
* next, put the letter in the envelope
  DATA eo_send_req_bcs TYPE REF TO cx_send_req_bcs.

  TRY .
      message->set_document( document ).
    CATCH cx_send_req_bcs INTO eo_send_req_bcs.
      RAISE eo_send_req_bcs.

  ENDTRY.

  PERFORM receivers_list.

  DATA: ls_receivers2  TYPE somlreci1,
        eo_address_bcs TYPE REF TO cx_address_bcs.

  LOOP AT gt_receivers INTO ls_receivers2 WHERE receiver IS NOT INITIAL.
    mailto = ls_receivers2-receiver.
    TRY.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( mailto ).
      CATCH cx_address_bcs INTO eo_address_bcs.
        RAISE eo_address_bcs.
    ENDTRY.

    TRY.
        message->add_recipient( lo_recipient ).
      CATCH cx_send_req_bcs INTO   eo_send_req_bcs.
        RAISE eo_send_req_bcs.
    ENDTRY.
    CLEAR ls_receivers2.
  ENDLOOP.

* finally, send the envelope on its way
  DATA: lv_sent_to_all TYPE os_boolean.

  TRY.
      lv_sent_to_all = message->send( i_with_error_screen = 'X').
    CATCH cx_send_req_bcs INTO   eo_send_req_bcs.
      RAISE eo_send_req_bcs.
  ENDTRY.

  COMMIT WORK.

  IF sy-subrc = 0 .
    MESSAGE s303(me) WITH 'Mail has been Successfully Sent.'.
  ELSE.
    WAIT UP TO 2 SECONDS.
    "This program starts the SAPconnect send process.
    SUBMIT rsconn01 WITH mode = 'INT'
    WITH output = 'X'
    AND RETURN.
  ENDIF.

ENDFORM.

FORM receivers_list.

  DATA ls_receivers TYPE somlreci1.

  ls_receivers-rec_type   = 'U'.  "Internet address
  ls_receivers-receiver   = p_email.
  ls_receivers-com_type   = 'INT'.
  ls_receivers-notif_del  = 'X'.
  ls_receivers-notif_ndel = 'X'.
  APPEND ls_receivers TO gt_receivers .
  CLEAR:ls_receivers .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_workday_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_workday_alv .

  DATA: lc_msg TYPE REF TO cx_salv_msg.

  TRY.
      "Instantiation
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = DATA(lo_alv)
        CHANGING
          t_table      =  gt_final_wd ).
    CATCH cx_salv_msg INTO lc_msg .
      gv_msg = lc_msg->get_text( ).
      MESSAGE gv_msg TYPE 'I'.
  ENDTRY.
  "Enable default ALV toolbar functions
  lo_alv->get_functions( )->set_default( abap_true ).
  "Set column headings
  lo_alv->get_columns( )->set_optimize( abap_true ).
  TRY.
      lo_alv->get_columns( )->get_column( 'FIELD')->set_medium_text( 'field' ).
      lo_alv->get_columns( )->get_column( 'SPREADSHEET_KEY')->set_medium_text( 'Spreadsheet Key' ).
      lo_alv->get_columns( )->get_column( 'ROW_ID')->set_medium_text( 'Row ID' ).
      lo_alv->get_columns( )->get_column( 'BATCH_ID')->set_medium_text( 'Batch ID' ).
      lo_alv->get_columns( )->get_column( 'ONGOING_INPUT')->set_medium_text( 'Ongoing Input' ).
      lo_alv->get_columns( )->get_column( 'START_DATE')->set_medium_text( 'Start Date' ).
      lo_alv->get_columns( )->get_column( 'END_DATE')->set_medium_text( 'Pay Period End Date' ).
      lo_alv->get_columns( )->get_column( 'RUN_CATEGORY')->set_medium_text( 'Run_Category_ID').
      lo_alv->get_columns( )->get_column( 'WORKER')->set_medium_text( 'Employee_ID').
      lo_alv->get_columns( )->get_column( 'EARNING')->set_medium_text( 'Earning' ).
      lo_alv->get_columns( )->get_column( 'DEDUCTION')->set_medium_text( 'Deduction_Code').
      lo_alv->get_columns( )->get_column( 'AMOUNT')->set_medium_text( 'Pay Amount' ).
      lo_alv->get_columns( )->get_column( 'ADJUSTMENT')->set_medium_text( 'Adjustment' ).
      lo_alv->get_columns( )->get_column( 'COST_CENTER')->set_medium_text( 'Cost Center' ).
      lo_alv->get_columns( )->get_column( 'CUSTOM_WORKTAG01')->set_medium_text( 'Custom Worktag 01' ).
      lo_alv->get_columns( )->get_column( 'ROWID')->set_medium_text( 'Row ID' ).
      lo_alv->get_columns( )->get_column( 'RELATED_CALCULATION')->set_medium_text( 'Related Calculation' ).
      lo_alv->get_columns( )->get_column( 'INPUT_VALUE')->set_medium_text( 'Input Value' ).
      lo_alv->get_columns( )->get_column( 'COMMENTS')->set_medium_text( 'Comment' ).
    CATCH cx_salv_not_found INTO gt_salv_not_found.
      gv_msg = gt_salv_not_found->get_text( ).
      MESSAGE gv_msg TYPE gc_error.
  ENDTRY.
  "Display the ALV Grid
  lo_alv->display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_send_to_proxy_workday
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send_to_proxy_workday .

  DATA:ls_output_proxy TYPE zmt_ob_msgtyp_con_workday.

  IF gt_proxy_wd[] IS NOT INITIAL AND cb_prxy IS NOT INITIAL.
    TRY.
        DATA(lo_obj_proxy) = NEW zco_fi_s4_to_workday( ).
        IF lo_obj_proxy IS BOUND.
          ls_output_proxy-zmt_ob_msgtyp_con_workday-it_data[] = gt_proxy_wd[].
          lo_obj_proxy->send_data( output = ls_output_proxy ).
          COMMIT WORK AND WAIT.
          MESSAGE 'The data send to CPI is initiated.' TYPE 'S'.
        ENDIF.
      CATCH cx_ai_system_fault INTO DATA(lo_fault).

        DATA(lv_error) = lo_fault->errortext.
        IF lv_error IS NOT INITIAL.
          MESSAGE lv_error TYPE 'I'.
        ENDIF.
        MESSAGE 'Exception occurred while transferring proxy data.' TYPE 'E'.
    ENDTRY.
  ELSE.
    MESSAGE 'No data found' TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_send_to_al11
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_send_to_al11 .
  DATA: lv_int111 TYPE char01.
  DATA: rv_xstring TYPE xstring.
  FIELD-SYMBOLS: <fs_data> TYPE ANY TABLE.

  DATA lo_data_ref TYPE REF TO data.
  GET REFERENCE OF gt_mail_wd INTO lo_data_ref.

  DATA: lv_s_layout TYPE lvc_s_layo.
  DATA: lo_columns TYPE REF TO cl_salv_columns_list.
*  DATA: lt_fcat TYPE lvc_t_fcat.
*    CLEAR rv_xstring.
*    ASSIGN gs_mail_wd->* TO <fs_data>.
  lv_int111 = 'X'.
  EXPORT lv_int111 FROM lv_int111 TO MEMORY ID 'LV_INT111'.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_table)
        CHANGING  t_table      = gt_mail_wd ).

      DATA(lt_fcat) =
        cl_salv_controller_metadata=>get_lvc_fieldcatalog(
          r_columns      = lo_table->get_columns( )
          r_aggregations = lo_table->get_aggregations( ) ).

      CALL METHOD cl_salv_controller_metadata=>get_lvc_layout(
        EXPORTING
          r_columns = lo_table->get_columns( )
        CHANGING
          s_layout  = lv_s_layout ).
      lv_s_layout-no_headers = 'X'.

      CALL METHOD cl_salv_controller_metadata=>set_lvc_layout(
        EXPORTING
          r_columns = lo_table->get_columns( )
          s_layout  = lv_s_layout ).
      DATA(lo_result) =
        cl_salv_ex_util=>factory_result_data_table(
          r_data         = lo_data_ref
          s_layout       = lv_s_layout
          t_fieldcatalog = lt_fcat ).

      zpsu_cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform(
        EXPORTING
          xml_type      = if_salv_bs_xml=>c_type_xlsx
          xml_version   = cl_salv_bs_a_xml_base=>get_version( )
          r_result_data = lo_result
          xml_flavour   = if_salv_bs_c_tt=>c_tt_xml_flavour_export
          gui_type      = if_salv_bs_xml=>c_gui_type_gui
        IMPORTING
          xml           = rv_xstring ).
    CATCH cx_root.



*        CLEAR rv_xstring.
  ENDTRY.

  cl_bcs_convert=>xstring_to_string(
      EXPORTING
        iv_xstr   = rv_xstring
        iv_cp     =  1100                " SAP character set identification
      RECEIVING
        rv_string = DATA(lv_string)
    ).
  IF sy-subrc = 0.
  ENDIF.

  IF rv_xstring IS NOT INITIAL.
    OPEN DATASET p_path FOR OUTPUT IN BINARY MODE.
    IF sy-subrc EQ 0.
      TRANSFER rv_xstring TO p_path.
      CLOSE DATASET p_path.
      MESSAGE 'File uploaded successfully' TYPE 'S'.
    ELSE.
      MESSAGE 'Unable to find file path' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.

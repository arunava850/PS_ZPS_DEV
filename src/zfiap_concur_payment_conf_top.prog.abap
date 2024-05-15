*&---------------------------------------------------------------------*
*& Include          ZFIAP_CONCUR_PAYMENT_CONF_TOP
*&---------------------------------------------------------------------*




TYPES:r_typ_xref TYPE RANGE OF xref1_hd.

types:  BEGIN OF ty_mail_wd_temp,
               worker              TYPE zfis_output_concur_rem_workday-worker,
        FIELD               TYPE zfis_output_concur_rem_workday-field,
        spreadsheet_key     TYPE zfis_output_concur_rem_workday-spreadsheet_key,
        row_id              TYPE zfis_output_concur_rem_workday-row_id,
        batch_id            TYPE zfis_output_concur_rem_workday-batch_id,
        ongoing_input       TYPE zfis_output_concur_rem_workday-ongoing_input,
        start_date          TYPE zfis_output_concur_rem_workday-start_date,
        end_date            TYPE zfis_output_concur_rem_workday-end_date,
        run_category        TYPE zfis_output_concur_rem_workday-run_category,
        earning             TYPE zfis_output_concur_rem_workday-earning,
        deduction           TYPE zfis_output_concur_rem_workday-deduction,
        amount              TYPE zfis_output_concur_rem_workday-amount,
        adjustment          TYPE zfis_output_concur_rem_workday-adjustment,
        cost_center         TYPE zfis_output_concur_rem_workday-cost_center,
        custom_worktag01    TYPE zfis_output_concur_rem_workday-custom_worktag01,
        rowid               TYPE zfis_output_concur_rem_workday-rowid,
        related_calculation TYPE zfis_output_concur_rem_workday-related_calculation,
        input_value         TYPE zfis_output_concur_rem_workday-input_value,
        comments            TYPE zfis_output_concur_rem_workday-comments,
      END OF   ty_mail_wd_temp.

types:  BEGIN OF ty_final_wd_temp,
               worker              TYPE zfi_concur_reimburs_to_workday-worker,
        FIELD               TYPE zfis_output_concur_rem_workday-field,
        spreadsheet_key     TYPE zfi_concur_reimburs_to_workday-spreadsheet_key,
        row_id              TYPE zfi_concur_reimburs_to_workday-row_id,
        batch_id            TYPE zfi_concur_reimburs_to_workday-batch_id,
        ongoing_input       TYPE zfi_concur_reimburs_to_workday-ongoing_input,
        start_date          TYPE zfi_concur_reimburs_to_workday-start_date,
        end_date            TYPE zfi_concur_reimburs_to_workday-end_date,
        run_category        TYPE zfi_concur_reimburs_to_workday-run_category,
        earning             TYPE zfi_concur_reimburs_to_workday-earning,
        deduction           TYPE zfi_concur_reimburs_to_workday-deduction,
        amount              TYPE zfi_concur_reimburs_to_workday-amount,
        adjustment          TYPE zfi_concur_reimburs_to_workday-adjustment,
        cost_center         TYPE zfi_concur_reimburs_to_workday-cost_center,
        custom_worktag01    TYPE zfi_concur_reimburs_to_workday-custom_worktag01,
        rowid               TYPE zfi_concur_reimburs_to_workday-rowid,
        related_calculation TYPE zfi_concur_reimburs_to_workday-related_calculation,
        input_value         TYPE zfi_concur_reimburs_to_workday-input_value,
        comments            TYPE zfi_concur_reimburs_to_workday-comments,
      END OF   ty_final_wd_temp.


DATA: r_tbl_xref TYPE r_typ_xref,
      wa_xref    TYPE LINE OF r_typ_xref.
DATA: gv_edate TYPE cpudt.

DATA: gs_final          TYPE zfis_concur_payment_conf,
      gt_final          TYPE TABLE OF zfis_concur_payment_conf,
      gt_output         TYPE TABLE OF zfis_output_concur_payment_con,
      gs_output         TYPE zfis_output_concur_payment_con,
      gt_mail_wd        TYPE TABLE OF zfis_output_concur_rem_workday,
      gs_mail_wd        TYPE zfis_output_concur_rem_workday,
      gt_final_wd       TYPE TABLE OF zfi_concur_reimburs_to_workday,
      gs_final_wd       TYPE zfi_concur_reimburs_to_workday,
      gt_proxy          TYPE zdt_ob_input_concurpaymt_tab,
      gt_proxy_wd       TYPE  ZDT_OB_CONCUR_REIMBUR_WORK_TAB,
      gt_salv_not_found TYPE REF TO cx_salv_not_found.
DATA: gv_msg  TYPE string.
DATA: gt_receivers           TYPE STANDARD TABLE OF somlreci1.
**************************Constants************************************
CONSTANTS: gc_hnz TYPE xref1_hd VALUE 'HNZ',
           gc_hpa TYPE xref1_hd VALUE 'HPA',
           gc_hpl TYPE xref1_hd VALUE 'HPL',
           gc_hpw TYPE xref1_hd VALUE 'HPW',
           gc_lfv TYPE xref1_hd VALUE 'LFV',
           gc_v97 TYPE xref1_hd VALUE 'V97',
           gc_v98 TYPE xref1_hd VALUE 'V98',
           gc_hpn TYPE xref1_hd VALUE 'HPN'.  "+p
CONSTANTS:
        gc_error            TYPE symsgty VALUE 'E'.

CONSTANTS:
  gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
  gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.

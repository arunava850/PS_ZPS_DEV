*&---------------------------------------------------------------------*
*& Include          ZFI_CREATE_REPETITIVE_CODE_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_file,
         rpcode  TYPE fibl_rpcode-rpcode,
         bukrs   TYPE fibl_rpcode-bukrs,
         hbkid   TYPE fibl_rpcode-hbkid,
         hktid   TYPE fibl_rpcode-hktid,
         tbukr   TYPE fibl_rpcode-bukrs,
         thbki   TYPE fibl_rpcode-hbkid,
         tHKTI   TYPE fibl_rpcode-hktid,
         zlsch   TYPE fibl_rpcode-zlsch,
         waers   TYPE fibl_rpcode-waers,
         rp_text TYPE fibl_rpcode_tdef-rp_text,
       END OF ty_file.

TYPES: BEGIN OF ty_output,
         rpcode  TYPE fibl_rpcode-rpcode,
         bukrs   TYPE fibl_rpcode-bukrs,
         hbkid   TYPE fibl_rpcode-hbkid,
         hktid   TYPE fibl_rpcode-hktid,
         tbukr   TYPE fibl_rpcode-bukrs,
         thbki   TYPE fibl_rpcode-hbkid,
         tHKTI   TYPE fibl_rpcode-hktid,
         zlsch   TYPE fibl_rpcode-zlsch,
         waers   TYPE fibl_rpcode-waers,
         rp_text TYPE fibl_rpcode_tdef-rp_text,
         msgtyp  TYPE bdcmsgcoll-msgtyp,
         msgv1   TYPE bdcmsgcoll-msgv1,
       END OF ty_output.

DATA: gt_excel          TYPE TABLE OF ty_file,
      gs_excel          TYPE ty_file,
      gt_output         TYPE TABLE OF ty_output,
      gs_output         TYPE ty_output,
      gt_file           TYPE filetable,
      gs_file           LIKE LINE OF gt_file,
      gv_rc             TYPE i,
      gt_bdcdata        TYPE TABLE OF bdcdata,
      gs_bdcdata        TYPE bdcdata,
      gt_bdcmsg         TYPE TABLE OF bdcmsgcoll,
      gl_alv            TYPE REF TO cl_salv_table,
      gt_salv_not_found TYPE REF TO cx_salv_not_found.

FIELD-SYMBOLS : <gt_data> TYPE STANDARD TABLE .

CONSTANTS: c_s                TYPE c VALUE 'S',
           c_e                TYPE c VALUE 'E',
           true(1)            VALUE 'X',
           type_cbp(2)        VALUE '01',
           type_bank(2)       VALUE '03',
           type_vend(2)       VALUE '11',
           false(1)           VALUE ' ',
           gd_auth_pq_show(2) VALUE '03',
           gd_origin_bank     LIKE tfiblorigin-origin VALUE 'TR-CM-BT',
           gd_origin_cbp      LIKE tfiblorigin-origin VALUE 'FI-BL'.

DATA:  BEGIN OF it_rpcode OCCURS 10.
         INCLUDE STRUCTURE frft_bank_rep.
DATA:    partnr TYPE bp_partnr,
         bkvid  TYPE bu_bkvid,
         status.
DATA  END   OF it_rpcode.
DATA: size_it_rpcode    LIKE sy-loopc,
      gd_ptype          LIKE fibl_rpcode-ptype,
      flg_sel,
      gd_anz_sel_rpcode TYPE sy-tfill,
      g_log_handle      TYPE balloghndl,
      gd_origin         LIKE tfiblorigin-origin,
      gd_check_payrq    TYPE sy-subrc,
      flg_changed,
      kurst_prq         TYPE reguv-kurst,
      gs_t001           LIKE t001,
      gs_bnka           LIKE bnka,
      gs_t012           LIKE t012,
      gv_xinitial TYPE xfeld,
      gv_kurst_tcurv TYPE kurst_curr,
      gv_error type c.

DATA:  BEGIN OF sel_rpcode OCCURS 10.
         INCLUDE STRUCTURE fibl_rpcode_i.
DATA  END   OF sel_rpcode.
DATA:  BEGIN OF it_pay_req OCCURS 1.
         INCLUDE STRUCTURE frft_payrq.
DATA:  END   OF it_pay_req.
DATA  size_it_pay_req LIKE sy-loopc.

* Types for PAYRQ
TYPES:
  yt_address_data TYPE STANDARD TABLE OF bapi2021_address,
  yt_bank_data    TYPE STANDARD TABLE OF bapi2021_bank
                  WITH KEY account_role,
  yt_reftxt       TYPE STANDARD TABLE OF bapi2021_reftext,
  yt_extension    TYPE STANDARD TABLE OF bapiparex,
  yt_ftpost       TYPE STANDARD TABLE OF ftpost.

* ranges for selection of repetitives
RANGES gt_rng_grp FOR fibl_rpcode_grou-rpgroup.
RANGES gt_rng_buk FOR fibl_rpcode-bukrs.
RANGES gt_rng_hbk FOR fibl_rpcode-hbkid.
RANGES gt_rng_par FOR fibl_rpcode-partn.
* save ranges
RANGES gt_save_rng_grp FOR fibl_rpcode_grou-rpgroup.
RANGES gt_save_rng_buk FOR fibl_rpcode-bukrs.
RANGES gt_save_rng_hbk FOR fibl_rpcode-hbkid.
RANGES gt_save_rng_par FOR fibl_rpcode-partn.
RANGES gt_rng_rpcode FOR fibl_rpcode-rpcode.
RANGES gt_rng_pbukr FOR fibl_rpcode-pbukr.

TABLES:frft_bank_rep, reguh,fibl_mainpay_101,fibl_rpcode_grou,fibl_rpcode,
  t001, bnka.

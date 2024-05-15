*&---------------------------------------------------------------------*
*& Include          ZFI_RAMP_INBOUND_ACNT_TOP
*&---------------------------------------------------------------------*
TABLES: anla.

TYPES : BEGIN OF ty_file,
          zusr_id(10)         TYPE c,
          zbatch(15)          TYPE c,
          ztran_no(22)        TYPE c,
          zline_no(7)         TYPE c,
          zsp                 TYPE c,
          zco(10)             TYPE c,
          zdescriptn(30)      TYPE c,
          zdescriptn2(30)     TYPE c,
          znew                TYPE c,
          zremark(30)         TYPE c,
          zremark2(30)        TYPE c,
          zasset_co_obj(6)    TYPE c,
          zsset_co_sub(8)     TYPE c,
          zacc_cls(3)         TYPE c,
          zst(3)              TYPE c,
          zafe_no(12)         TYPE c,
          zuniqueid(15)       TYPE c,
          zadrs_no(8)         TYPE c,
          zinvoice(25)        TYPE c,
          zinv_date(10)       TYPE c,
          zgross_amnt(15)     TYPE c,
          ztax(15)            TYPE c,
          ztax2(15)           TYPE c,
          zdat_acq(10)        TYPE c,
          zasset_no(18)       TYPE c,
          zusr_code(3)        TYPE c,
          zusr_date(10)       TYPE c,
          zusr_amount(15)     TYPE c,
          zusr_no(8)          TYPE c,
          zusr_ref(15)        TYPE c,
          zusrid(10)          TYPE c,
          zprog(10)           TYPE c,
          zwork_stn(10)       TYPE c,
          zdate_upd(10)       TYPE c,
          ztime_upd(6)        TYPE c,
          zopex_capex_code(5) TYPE c,
          zord43(4)           TYPE c,
        END OF ty_file.

TYPES : BEGIN OF ty_file_mail,
          zusr_id(10)         TYPE c,
          zbatch(15)          TYPE c,
          ztran_no(22)        TYPE c,
          zline_no(7)         TYPE c,
          zsp(1)              TYPE c,
          zco(10)             TYPE c,
          zdescriptn(30)      TYPE c,
          zdescriptn2(30)     TYPE c,
          znew(1)             TYPE c,
          zremark(30)         TYPE c,
          zremark2(30)        TYPE c,
          zasset_co_obj(6)    TYPE c,
          zsset_co_sub(8)     TYPE c,
          zacc_cls(3)         TYPE c,
          zst(3)              TYPE c,
          zafe_no(12)         TYPE c,
          zuniqueid(15)       TYPE c,
          zadrs_no(8)         TYPE c,
          zinvoice(25)        TYPE c,
          zinv_date(10)       TYPE c,
          zgross_amnt(15)     TYPE c,
          ztax(15)            TYPE c,
          ztax2(15)           TYPE c,
          zdat_acq(10)        TYPE c,
          zasset_no(18)       TYPE c,
          zusr_code(3)        TYPE c,
          zusr_date(10)       TYPE c,
          zusr_amount(15)     TYPE c,
          zusr_no(8)          TYPE c,
          zusr_ref(15)        TYPE c,
          zusrid(10)          TYPE c,
          zprog(10)           TYPE c,
          zwork_stn(10)       TYPE c,
          zdate_upd(10)       TYPE c,
          ztime_upd(6)        TYPE c,
          zopex_capex_code(5) TYPE c,
          zord43(4)           TYPE c,
          status(7)           TYPE c,
          message(1024)       TYPE c,
        END OF ty_file_mail.

DATA : gt_file       TYPE TABLE OF ty_file,
       gs_file       TYPE ty_file,
       gt_file_mail  TYPE TABLE OF ty_file_mail,
       gs_file_mail  TYPE ty_file_mail,
       gs_data       TYPE zfis_ramp_acc_pay,
       gt_data       TYPE zfitt_ramp_acc_pay,
       gt_capex      TYPE zfitt_ramp_acc_pay,
       gt_opex       TYPE zfitt_ramp_acc_pay,
       gt_bapiret2   TYPE TABLE OF bapiret2,
       gt_alv_output TYPE TABLE OF zfis_ramp_acc_pay_alv,
       gs_alv_output TYPE zfis_ramp_acc_pay_alv.
*       gt_bapiret2_alv type table of BAPIRET2_ALV_OUTPUT.

DATA: gt_salv_not_found TYPE REF TO cx_salv_not_found.
DATA: gv_msg  TYPE string.

CONSTANTS:
        gc_error            TYPE symsgty VALUE 'E'.

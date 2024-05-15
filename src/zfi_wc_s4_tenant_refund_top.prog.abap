*&---------------------------------------------------------------------*
*& Include          ZFI_WC_S4_TENANT_REFUND_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_file,
          ztran_id(9)         TYPE c,
          tot_refund(17)      TYPE c,
          zsiteno(10)         TYPE c,
*          zcsrtyp(3)          TYPE c,
          zcontactid(9)       TYPE c,
*          zbpmstrwckey(20)    TYPE c,
          zsuppl_no(10)       TYPE c,
          zlob(1)             TYPE c,
          refnd_line_amnt(17) TYPE c,
          custmr_unt(25)      TYPE c,
          date(20)            TYPE c,
          refnd_typ(30)       TYPE c,
          wc_code(10)         TYPE c,
        END OF ty_file.

DATA : gt_file TYPE TABLE OF ty_file,
       gs_file TYPE ty_file,
       gt_data TYPE zfit_wc_s4_tenant_refund_int,
       gs_data TYPE zfis_wc_s4_tenant_refund_int,
       gt_ret2 TYPE bapiret2_t.

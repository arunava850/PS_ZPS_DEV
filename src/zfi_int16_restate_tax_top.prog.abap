*&---------------------------------------------------------------------*
*& Include          ZFI_INT16_RESTATE_TAX_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_file,
          prcl_year(6)       TYPE c,
          tax_typ(4)         TYPE c,
          tax_billid(50)     TYPE c,
          prcel(20)          TYPE c,
          exprt_no(16)       TYPE c,
          allc_dbtgl(15)     TYPE c,
          proprty_id(10)     TYPE c,
          period_end(10)     TYPE c,
          period_accural(30) TYPE c,
          prcl_text(60)      TYPE c,
          txbill_no(10)      TYPE c,
          paymnt_mthd(10)    TYPE c,
          clint_fyr(4)       TYPE c,
          clint_fpr(2)       TYPE c,
        END OF ty_file.

DATA : gt_file     TYPE TABLE OF ty_file,
       gs_file     TYPE ty_file,
       gv_budat    TYPE bkpf-budat,
       gv_file     TYPE rlgrap-filename,
       gv_filename TYPE rlgrap-filename,
       gv_filepath TYPE rlgrap-filename.

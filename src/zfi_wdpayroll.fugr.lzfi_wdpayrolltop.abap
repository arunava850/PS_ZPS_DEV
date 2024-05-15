FUNCTION-POOL ZFI_WDPAYROLL.                "MESSAGE-ID ..

* INCLUDE LZFI_WDPAYROLLD...                 " Local class definition


TYPES: BEGIN OF ty_final,
         Status   TYPE char10,
         counter TYPE char10,
         belnr  TYPE belnr,
         messg  TYPE char100,
         docnum   TYPE edi_docnum,
       END OF   ty_final,
     t_body_msg TYPE solisti1.

DATA: gt_final    TYPE TABLE OF ty_final,
      gw_final    TYPE ty_final,
      gt_body_msg TYPE STANDARD TABLE OF t_body_msg,
      gw_body_msg TYPE t_body_msg,
      gs_tvarv   TYPE tvarv.

DATA: gv_cnt   TYPE i.

class ZCL_ZFI_INT33_CONCUR_TO_SAP_EM definition
  public
  create public .

public section.

  interfaces ZII_ZFI_INT33_CONCUR_TO_SAP_EM .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_INT33_CONCUR_TO_SAP_EM IMPLEMENTATION.


  METHOD zii_zfi_int33_concur_to_sap_em~post.
*** **** INSERT IMPLEMENTATION HERE **** ***
    TYPES : BEGIN OF ty_file,
              zempid(20)         TYPE c,
              zlast_name(50)     TYPE c,
              zfirst_name(50)    TYPE c,
              zreportid(20)      TYPE c,
              zreport_key(30)    TYPE c,
              zrep_submt_dt(10)  TYPE c,
              zrept_name(30)     TYPE c,
              zrep_org_unit1(20) TYPE c,
              zrep_custom(30)    TYPE c,
              zexpense_typ(10)   TYPE c,
              zacnt_code(20)     TYPE c,
              zdrcr(10)          TYPE c,
              zamount(30)        TYPE c,
              zallocation(30)    TYPE c,
            END OF ty_file.

    DATA : gt_file TYPE TABLE OF ty_file,
           gs_file TYPE ty_file.

    LOOP AT input-zfi_int33_concur_to_sap_dt-zdata INTO DATA(ls_data).
      gs_file = CORRESPONDING #( ls_data ).
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.

    DATA(lr_process) = NEW zcl_int33_concur_to_sap_emp( ).

    CALL METHOD lr_process->post_doc
      EXPORTING
        gt_file   = gt_file
      IMPORTING
        gt_return = DATA(gt_bapiret2).


  ENDMETHOD.
ENDCLASS.

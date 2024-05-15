class ZCL_ZFI_113_ASSET_TRAN_RAMP_SA definition
  public
  create public .

public section.

  interfaces ZII_ZFI_113_ASSET_TRAN_RAMP_SA .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_113_ASSET_TRAN_RAMP_SA IMPLEMENTATION.


  METHOD zii_zfi_113_asset_tran_ramp_sa~post.
*** **** INSERT IMPLEMENTATION HERE **** ***

    ""BAPI_ASSET_RETIREMENT_POST

    TYPES : BEGIN OF ty_file,
              zpropertyid     TYPE prctr,
              zasset_refer(255)  TYPE c,
              zasset_no(18)       TYPE c,
              zretire_date   TYPE datum,
              zreason_retire(50) TYPE c,
            END OF ty_file.

    DATA : gt_file TYPE TABLE OF ty_file,
           gs_file TYPE ty_file.

    LOOP AT input-zfi_113_asset_tran_ramp_mt-zdata INTO DATA(ls_data).
      gs_file = CORRESPONDING #( ls_data ).
      gs_file-zpropertyid = |{ ls_data-zpropertyid ALPHA = IN }|.
      gs_file-zretire_date = ls_data-zretire_date.
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.

    DATA(lr_proc) = NEW zcl_113_asset_tran_ramp_sap( ).

    CALL METHOD lr_proc->post
      EXPORTING
        gt_file   = gt_file
      IMPORTING
        gt_return = DATA(gt_bapiret2).

  ENDMETHOD.
ENDCLASS.

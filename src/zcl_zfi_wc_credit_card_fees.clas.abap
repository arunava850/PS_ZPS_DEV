class ZCL_ZFI_WC_CREDIT_CARD_FEES definition
  public
  create public .

public section.

  interfaces ZII_ZFI_WC_CREDIT_CARD_FEES .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_WC_CREDIT_CARD_FEES IMPLEMENTATION.


  METHOD zii_zfi_wc_credit_card_fees~post_doc.
*** **** INSERT IMPLEMENTATION HERE **** ***
                                                            ""INT0107
    TYPES : BEGIN OF ty_file,
              zsiteno(10)       TYPE c,
              zrecord_dt(10)    TYPE c,
              zfintycode(8)     TYPE c,
              zfintyscode(8)    TYPE c,
              zfindetyp(25)     TYPE c,
              zfindetsubtyp(25) TYPE c,
              zduetofrom(10)    TYPE c,
              zcustypcode(10)   TYPE c,
              zcustyp(20)       TYPE c,
              ztaxtypcode(4)    TYPE c,
              ztaxtypname(20)   TYPE c,
              zamount(10)       TYPE c,
              zdatatyp(15)      TYPE c,
            END OF ty_file.
    DATA : gt_file TYPE TABLE OF ty_file,
           gs_file TYPE ty_file.

    LOOP AT input-zfi_wc_credit_card_fees_rmt-zdatar INTO DATA(ls_data).
      gs_file = CORRESPONDING #( ls_data ).
      APPEND gs_file TO gt_file.
      CLEAR gs_file.
    ENDLOOP.

    DATA(lr_process) = NEW zcl_int107_credit_card_fees( ).

    CALL METHOD lr_process->post_doc
      EXPORTING
        gt_file   = gt_file
      IMPORTING
        gt_return = DATA(gt_bapiret2).



  ENDMETHOD.
ENDCLASS.

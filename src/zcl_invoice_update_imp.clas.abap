class ZCL_INVOICE_UPDATE_IMP definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_INVOICE_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INVOICE_UPDATE_IMP IMPLEMENTATION.


  method IF_EX_INVOICE_UPDATE~CHANGE_AT_SAVE.
  endmethod.


  method IF_EX_INVOICE_UPDATE~CHANGE_BEFORE_UPDATE.


data:lv_test type i.

lv_test = 1.

  endmethod.


  method IF_EX_INVOICE_UPDATE~CHANGE_IN_UPDATE.
  endmethod.
ENDCLASS.

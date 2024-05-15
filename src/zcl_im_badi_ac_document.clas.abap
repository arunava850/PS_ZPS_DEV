class ZCL_IM_BADI_AC_DOCUMENT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_AC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_AC_DOCUMENT IMPLEMENTATION.


  method IF_EX_AC_DOCUMENT~CHANGE_AFTER_CHECK.

  data lv type char1.
  lv = abap_true.
  endmethod.


  method IF_EX_AC_DOCUMENT~CHANGE_INITIAL.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_ACCTIT_RELEVANT.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_COMPRESSION_REQUIRED.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_SUPPRESSED_ACCT.
  endmethod.
ENDCLASS.

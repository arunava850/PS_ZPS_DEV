class ZCL_GLT0_ASSIGNMENT_CONTROL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_GLT0_ASSIGNMENT_CONTROL .
protected section.
private section.
ENDCLASS.



CLASS ZCL_GLT0_ASSIGNMENT_CONTROL IMPLEMENTATION.


  method IF_GLT0_ASSIGNMENT_CONTROL~CHANGE_ASSIGNMENT.
data lv type char1.
lv = abap_true.
  endmethod.


  method IF_GLT0_ASSIGNMENT_CONTROL~GET_ASGNMT_MODE.

  endmethod.
ENDCLASS.

class ZCL_MM_BADI_IMPL_INV_WF_COND definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SWF_FLEX_IFS_CONDITION_DEF .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MM_BADI_IMPL_INV_WF_COND IMPLEMENTATION.


  method IF_SWF_FLEX_IFS_CONDITION_DEF~GET_CONDITIONS.
    DATA: ls_parameter LIKE LINE OF ct_parameter.
* condition id - value to be changed
    CONSTANTS: co_id TYPE if_swf_flex_ifs_condition_def=>ty_condition_id VALUE 'LEVEL_ID' ##NO_TEXT.

    APPEND LINES OF VALUE if_swf_flex_ifs_condition_def=>tt_condition(
     ( id = co_id subject = 'Enter the level of the approver position' type = if_swf_flex_ifs_condition_def=>cs_condtype-start_step )
     ) TO ct_condition.


    ls_parameter = VALUE #( id = co_id name = 'Level (ex. L1 or L2..)' xsd_type = if_swf_flex_ifs_condition_def=>cs_xstype-string
    mandatory = abap_true ).
    APPEND ls_parameter TO ct_parameter.
  endmethod.
ENDCLASS.

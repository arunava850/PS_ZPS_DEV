class ZCL_MM_BADI_IMPL_INV_WF_AGNT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_MRM_WORKFLOW_AGENTS .
protected section.
private section.
ENDCLASS.



CLASS ZCL_MM_BADI_IMPL_INV_WF_AGNT IMPLEMENTATION.


  METHOD if_mrm_workflow_agents~get_approvers.

    DATA: lv_step TYPE numc2.
*          r_uname TYPE RANGE OF syuname.

    SELECT supplierinvoice,fiscalyear,supplierinvoiceitem,costcenter,supplierinvoiceitemamount
      FROM i_suplrinvoiceitemglacctapi01 INTO TABLE @DATA(lt_inv_item)
      WHERE supplierinvoice = @supplierinvoice
        AND fiscalyear = @fiscalyear.
    IF sy-subrc IS INITIAL.
*      DELETE lt_ekpo WHERE loekz IS NOT INITIAL.
      SORT lt_inv_item BY supplierinvoice fiscalyear supplierinvoiceitem.
      READ TABLE lt_inv_item INTO DATA(ls_inv_item) INDEX 1.
    ENDIF.

    IF ls_inv_item-costcenter IS NOT INITIAL.
      SELECT SINGLE verak_user FROM csks INTO @DATA(lv_cost_user)
        WHERE kokrs = 'PSCO'
          AND kostl = @ls_inv_item-costcenter.
      IF sy-subrc IS INITIAL.
        lv_step = stepinfo-current_step.
        IF lv_step = '01'.
          APPEND INITIAL LINE TO approverlist ASSIGNING FIELD-SYMBOL(<lfs_approver>).
          <lfs_approver> = lv_cost_user.
        ELSE.
          READ TABLE zcl_mm_badi_impl_inv_wf_eval=>gt_cc_hier_levels INTO DATA(ls_cc_hier)
             WITH KEY cc_user = lv_cost_user
                      persk   = lv_step.
          IF sy-subrc IS INITIAL.
            APPEND INITIAL LINE TO approverlist ASSIGNING <lfs_approver>.
            <lfs_approver> = ls_cc_hier-approver.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*// Add substitutes for approvers
    APPEND LINES OF zcl_ps_utility_tools=>get_substitutes( it_approverlist = approverlist[] )
             TO approverlist[].

  ENDMETHOD.
ENDCLASS.

class ZCL_FI_ENH_INVOICE_CHECK definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MRM_CHECK_INVOICE_CLOUD .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FI_ENH_INVOICE_CHECK IMPLEMENTATION.


  METHOD IF_EX_MRM_CHECK_INVOICE_CLOUD~CHECK_INVOICE.

    " Constants for all possible invoice states can be found in the following list
    "
    " Parked: if_ex_mrm_check_invoice_cloud=>c_Status_Parked
    " Parked and Held: if_ex_mrm_check_invoice_cloud=>c_Status_Parked_And_Held
    " Entered and Held: if_ex_mrm_check_invoice_cloud=>c_Status_Entered_And_Held
    " Saved as completed: if_ex_mrm_check_invoice_cloud=>c_Status_Saved_As_Completed
    " Posted: if_ex_mrm_check_invoice_cloud=>c_Status_Posted
    " Deleted: if_ex_mrm_check_invoice_cloud=>c_Status_Deleted
    " With Errors: if_ex_mrm_check_invoice_cloud=>c_Status_With_Errors
    " Defined for Background: if_ex_mrm_check_invoice_cloud=>c_Status_Def_For_Background
    "
    " Please note that when checking the status it is always referring to the current status of the document
    " If you are in the process of initially entering the document the status will be initial.

    " Constants for all possible message types can be found in the following list
    "
    " Error: if_ex_mrm_check_invoice_cloud=>c_MessageType_Error
    " Information: if_ex_mrm_check_invoice_cloud=>c_MessageType_Info
    " Warning: if_ex_mrm_check_invoice_cloud=>c_MessageType_Warning
    " Success: if_ex_mrm_check_invoice_cloud=>c_MessageType_Success
    "
    " Any other message type will automatically be converted to type error.

    " Constants for all possible values of parameter ACTION can be found in the following list
    "
    " Post: if_ex_mrm_check_invoice_cloud=>c_Action_Post
    " Park: if_ex_mrm_check_invoice_cloud=>c_Action_Park
    " Hold: if_ex_mrm_check_invoice_cloud=>c_Action_Hold
    " Save as Completed: if_ex_mrm_check_invoice_cloud=>c_Action_Save_As_Completed
    " Check: if_ex_mrm_check_invoice_cloud=> c_Action_Check
    " Delete: if_ex_mrm_check_invoice_cloud=>c_Action_Delete
    " Simulate: if_ex_mrm_check_invoice_cloud=>c_Action_Simulate

    " Example 1: Check if the the IBAN Field is filed during the check action.
    " Add a system message of type error to the Log otherwise.
    " This will prevent any invoice from being posted or being saved as completed as long as the IBAN field is empty
    " Hold, Park and Delete actions are still possible
*    IF action = if_ex_mrm_check_invoice_cloud=>c_action_check.
*      IF headerdata-iban IS INITIAL.
*        APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_error
*                        messageid = 'MRM_BADI_CLOUD'
*                        messagenumber = '001'
*                        messagevariable1 = 'Please Fill the IBAN field.' ) TO messages.
*      ENDIF.
*    ENDIF.

    " Example 2: Check that an invoice has a minimum of 4 GL Account items for all actions
    " The message shall only prevent posting of invoices but not other actions.
    " Therefore it is issued as a warning for all actions except post where it is an error
*    DATA(lv_min_gl) = 4.
*    IF lines( GLACCOUNTITEMS ) < lv_min_gl.
*      IF action = if_ex_mrm_check_invoice_cloud=>c_action_post.
*        APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_error
*                        messageid = 'MRM_BADI_CLOUD'
*                        messagenumber = '001'
*                        messagevariable1 = 'The invoice has '
*                        messagevariable2 = lines( GLACCOUNTITEMS )
*                        messagevariable3 = ' GL items but requires a minimum of '
*                        messagevariable4 = lv_min_gl ) TO messages.
*      ELSE.
*        APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_warning
*                        messageid = 'MRM_BADI_CLOUD'
*                        messagenumber = '001'
*                        messagevariable1 = 'The invoice has '
*                        messagevariable2 = lines( GLACCOUNTITEMS )
*                        messagevariable3 = ' GL items but requires a minimum of '
*                        messagevariable4 = lv_min_gl ) TO messages.
*      ENDIF.
*    ENDIF.

    " Example 3: Issue an information message
    " Only issue the message if documentheadertext is not filled
    " and the invoice is currently in the parked status
    " This message will not prevent any actions, however it will be displayed to the user
    " Please note that warning, success and information messages will only be displayed during the check action
*    IF headerdata-documentheadertext IS INITIAL AND
*       headerdata-supplierinvoicestatus = if_ex_mrm_check_invoice_cloud=>c_status_parked AND
*        action = if_ex_mrm_check_invoice_cloud=>c_action_check..
*      APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_info
*                     messageid = 'MRM_BADI_CLOUD'
*                     messagenumber = '001'
*                     messagevariable1 = 'Header text is not filled.'  ) TO messages.
*
*    ENDIF.

    " Example 4: Issue an warning message
    " Only issue the message if businessplace is not filled
    " This message will not prevent any actions, however it will be displayed to the user
    " Please note that warning, success and information messages will only be displayed during the check action
*    IF headerdata-businessplace IS INITIAL AND
*       action = if_ex_mrm_check_invoice_cloud=>c_action_check.
*      APPEND VALUE #( messagetype = if_ex_mrm_check_invoice_cloud=>c_messagetype_warning
*                     messageid = 'MRM_BADI_CLOUD'
*                     messagenumber = '001'
*                     messagevariable1 = 'Business place is not filled.'  ) TO messages.
*
*    ENDIF.

  ENDMETHOD.
ENDCLASS.

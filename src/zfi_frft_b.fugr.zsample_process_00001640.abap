FUNCTION zsample_process_00001640.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REGUH) LIKE  REGUH STRUCTURE  REGUH OPTIONAL
*"  TABLES
*"      T_REGUP STRUCTURE  REGUP
*"      T_HEADER STRUCTURE  FNAMEVALUE OPTIONAL
*"      T_ITEM_BANK STRUCTURE  FNAMEVALUE OPTIONAL
*"      T_ITEM_CLEARING STRUCTURE  FNAMEVALUE OPTIONAL
*"----------------------------------------------------------------------

  DATA: lv_prctr TYPE cepc-prctr.

  IF i_reguh-dorigin EQ 'TR-CM-BT'.
    SPLIT i_reguh-rfttrn AT '_' INTO DATA(lv_data1) lv_prctr.
    lv_prctr = |{ lv_prctr ALPHA = IN }|.
    SELECT SINGLE prctr
      FROM cepc
      INTO @DATA(lv_prt)
     WHERE prctr EQ @lv_prctr.
    t_item_clearing-fieldname  = 'ZUONR'.
    t_item_clearing-fieldvalue = i_reguh-rfttrn.
    APPEND t_item_clearing.

    t_item_bank-fieldname  = 'ZUONR'.
    t_item_bank-fieldvalue = i_reguh-rfttrn.
    APPEND t_item_bank.

    t_item_clearing-fieldname  = 'SGTXT'.
    t_item_clearing-fieldvalue = i_reguh-rfttrn.
    APPEND t_item_clearing.

    t_item_bank-fieldname  = 'SGTXT'.
    t_item_bank-fieldvalue = i_reguh-rfttrn.
    APPEND t_item_bank.
  ENDIF.

ENDFUNCTION.

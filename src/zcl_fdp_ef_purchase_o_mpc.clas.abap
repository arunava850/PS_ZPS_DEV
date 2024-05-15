class ZCL_FDP_EF_PURCHASE_O_MPC definition
  public
  inheriting from /IWBEP/CL_MGW_PUSH_ABS_MODEL
  create public .

public section.

  types:
     TS_HIERITEMPRICINGCONDITIONNOD type MMPUR_S_FDP_ITEM_PRICING_COND .
  types:
TT_HIERITEMPRICINGCONDITIONNOD type standard table of TS_HIERITEMPRICINGCONDITIONNOD .
  types:
   begin of ts_text_element,
      artifact_name  type c length 40,       " technical name
      artifact_type  type c length 4,
      parent_artifact_name type c length 40, " technical name
      parent_artifact_type type c length 4,
      text_symbol    type textpoolky,
   end of ts_text_element .
  types:
         tt_text_elements type standard table of ts_text_element with key text_symbol .
  types:
     TS_ITEMPRICINGCONDITIONNODE type MMPUR_S_FDP_ITEM_PRICING_COND .
  types:
TT_ITEMPRICINGCONDITIONNODE type standard table of TS_ITEMPRICINGCONDITIONNODE .
  types:
  begin of TS_ORDERINGADDRESS,
     LIFN2 type C length 10,
     NAME1 type C length 40,
     ADDRESS_LINE_1 type C length 80,
     ADDRESS_LINE_2 type C length 80,
     ADDRESS_LINE_3 type C length 80,
     ADDRESS_LINE_4 type C length 80,
     ADDRESS_LINE_5 type C length 80,
     ADDRESS_LINE_6 type C length 80,
     ADDRESS_LINE_7 type C length 80,
     ADDRESS_LINE_8 type C length 80,
     TEL_NUMBER type C length 30,
     TELFX type C length 30,
     SMTP_ADDR type C length 241,
  end of TS_ORDERINGADDRESS .
  types:
TT_ORDERINGADDRESS type standard table of TS_ORDERINGADDRESS .
  types:
     TS_POCONFIGURATIONHIERITEMNODE type TDS_ME_PO_ITEM_CONFIG .
  types:
TT_POCONFIGURATIONHIERITEMNODE type standard table of TS_POCONFIGURATIONHIERITEMNODE .
  types:
     TS_POCONFIGURATIONITEMNODE type TDS_ME_PO_ITEM_CONFIG .
  types:
TT_POCONFIGURATIONITEMNODE type standard table of TS_POCONFIGURATIONITEMNODE .
  types:
     TS_POHIERSUBCONTRACTINGCOMPONE type TDS_ME_PO_ITEM_COMPONENT_BATCH .
  types:
TT_POHIERSUBCONTRACTINGCOMPONE type standard table of TS_POHIERSUBCONTRACTINGCOMPONE .
  types:
     TS_POHIERSUBCONTRACTINGCOMPON type TDS_ME_PO_ITEM_COMPONENTS .
  types:
TT_POHIERSUBCONTRACTINGCOMPON type standard table of TS_POHIERSUBCONTRACTINGCOMPON .
  types:
  begin of TS_POHIERSUBCONTRACTINGCOMPO,
     EBELN type C length 10,
     EBELP type C length 5,
     ETENR type C length 4,
     RESERVATIONITEM type C length 4,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_POHIERSUBCONTRACTINGCOMPO .
  types:
TT_POHIERSUBCONTRACTINGCOMPO type standard table of TS_POHIERSUBCONTRACTINGCOMPO .
  types:
     TS_POSUBCONTRACTINGCOMPONENTSB type TDS_ME_PO_ITEM_COMPONENT_BATCH .
  types:
TT_POSUBCONTRACTINGCOMPONENTSB type standard table of TS_POSUBCONTRACTINGCOMPONENTSB .
  types:
     TS_POSUBCONTRACTINGCOMPONENTSN type TDS_ME_PO_ITEM_COMPONENTS .
  types:
TT_POSUBCONTRACTINGCOMPONENTSN type standard table of TS_POSUBCONTRACTINGCOMPONENTSN .
  types:
  begin of TS_POSUBCONTRACTINGCOMPONENTST,
     EBELN type C length 10,
     EBELP type C length 5,
     ETENR type C length 4,
     RESERVATIONITEM type C length 4,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_POSUBCONTRACTINGCOMPONENTST .
  types:
TT_POSUBCONTRACTINGCOMPONENTST type standard table of TS_POSUBCONTRACTINGCOMPONENTST .
  types:
  begin of TS_PURCHASEORDERCHANGESNODE,
     EBELN type C length 10,
     CHTXT type C length 30,
  end of TS_PURCHASEORDERCHANGESNODE .
  types:
TT_PURCHASEORDERCHANGESNODE type standard table of TS_PURCHASEORDERCHANGESNODE .
  types:
  begin of TS_PURCHASEORDERHEADERSTTEXTS,
     EBELN type C length 10,
     DRUVO type C length 1,
     ESART type C length 4,
     TDOBJECT type C length 10,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     DRFLG type C length 2,
     TDOBNAME type C length 70,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERHEADERSTTEXTS .
  types:
TT_PURCHASEORDERHEADERSTTEXTS type standard table of TS_PURCHASEORDERHEADERSTTEXTS .
  types:
  begin of TS_PURCHASEORDERHEADERTEXTS,
     EBELN type C length 10,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERHEADERTEXTS .
  types:
TT_PURCHASEORDERHEADERTEXTS type standard table of TS_PURCHASEORDERHEADERTEXTS .
  types:
     TS_PURCHASEORDERHIERITEMBATCHN type TDS_ME_PO_ITEM_BATCH .
  types:
TT_PURCHASEORDERHIERITEMBATCHN type standard table of TS_PURCHASEORDERHIERITEMBATCHN .
  types:
  begin of TS_PURCHASEORDERHIERITEMCHANGE,
     EBELN type C length 10,
     EBELP type C length 5,
     CHTXT type C length 30,
  end of TS_PURCHASEORDERHIERITEMCHANGE .
  types:
TT_PURCHASEORDERHIERITEMCHANGE type standard table of TS_PURCHASEORDERHIERITEMCHANGE .
  types:
     TS_PURCHASEORDERHIERITEMNODE type TDS_ME_PO_ITEM .
  types:
TT_PURCHASEORDERHIERITEMNODE type standard table of TS_PURCHASEORDERHIERITEMNODE .
  types:
  begin of TS_PURCHASEORDERHIERITEMSTTEXT,
     EBELN type C length 10,
     EBELP type C length 5,
     DRUVO type C length 1,
     ESART type C length 4,
     PSTYP type C length 1,
     TDOBJECT type C length 10,
     LANGUAGE type C length 2,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     DRFLG type C length 2,
     DRPRI type C length 1,
     TDOBNAME type C length 70,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERHIERITEMSTTEXT .
  types:
TT_PURCHASEORDERHIERITEMSTTEXT type standard table of TS_PURCHASEORDERHIERITEMSTTEXT .
  types:
  begin of TS_PURCHASEORDERHIERITEMTEXTS,
     EBELN type C length 10,
     EBELP type C length 5,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERHIERITEMTEXTS .
  types:
TT_PURCHASEORDERHIERITEMTEXTS type standard table of TS_PURCHASEORDERHIERITEMTEXTS .
  types:
     TS_PURCHASEORDERHIERSCHEDULELI type TDS_ME_PO_SCHEDULELINE .
  types:
TT_PURCHASEORDERHIERSCHEDULELI type standard table of TS_PURCHASEORDERHIERSCHEDULELI .
  types:
     TS_PURCHASEORDERITEMBATCHNODE type TDS_ME_PO_ITEM_BATCH .
  types:
TT_PURCHASEORDERITEMBATCHNODE type standard table of TS_PURCHASEORDERITEMBATCHNODE .
  types:
  begin of TS_PURCHASEORDERITEMCHANGESNOD,
     EBELN type C length 10,
     EBELP type C length 5,
     CHTXT type C length 30,
  end of TS_PURCHASEORDERITEMCHANGESNOD .
  types:
TT_PURCHASEORDERITEMCHANGESNOD type standard table of TS_PURCHASEORDERITEMCHANGESNOD .
  types:
     TS_PURCHASEORDERITEMNODE type TDS_ME_PO_ITEM .
  types:
TT_PURCHASEORDERITEMNODE type standard table of TS_PURCHASEORDERITEMNODE .
  types:
  begin of TS_PURCHASEORDERITEMSTTEXTS,
     EBELN type C length 10,
     EBELP type C length 5,
     DRUVO type C length 1,
     ESART type C length 4,
     PSTYP type C length 1,
     TDOBJECT type C length 10,
     LANGUAGE type C length 2,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     DRFLG type C length 2,
     DRPRI type C length 1,
     TDOBNAME type C length 70,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERITEMSTTEXTS .
  types:
TT_PURCHASEORDERITEMSTTEXTS type standard table of TS_PURCHASEORDERITEMSTTEXTS .
  types:
  begin of TS_PURCHASEORDERITEMTEXTS,
     EBELN type C length 10,
     EBELP type C length 5,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERITEMTEXTS .
  types:
TT_PURCHASEORDERITEMTEXTS type standard table of TS_PURCHASEORDERITEMTEXTS .
  types:
  begin of TS_PURCHASEORDERLIMITITEMCHANG,
     EBELN type C length 10,
     EBELP type C length 5,
     CHTXT type C length 30,
  end of TS_PURCHASEORDERLIMITITEMCHANG .
  types:
TT_PURCHASEORDERLIMITITEMCHANG type standard table of TS_PURCHASEORDERLIMITITEMCHANG .
  types:
  begin of TS_PURCHASEORDERLIMITITEMNODE,
     EBELN type C length 10,
     EBELP type C length 5,
     PSTYP type C length 1,
     TXZ01 type C length 40,
     MATKL type C length 9,
     WERKS type C length 4,
     EXPECTED_VALUE type P length 8 decimals 3,
     NETPR type P length 7 decimals 3,
     NETWR type P length 9 decimals 3,
     WAERS type C length 5,
     MMPUR_SERVPROC_PERIOD_START type TIMESTAMP,
     MMPUR_SERVPROC_PERIOD_END type TIMESTAMP,
     ADRNR type C length 10,
     ADDRESS_LINE_1 type C length 80,
     ADDRESS_LINE_2 type C length 80,
     ADDRESS_LINE_3 type C length 80,
     ADDRESS_LINE_4 type C length 80,
     ADDRESS_LINE_5 type C length 80,
     ADDRESS_LINE_6 type C length 80,
     ADDRESS_LINE_7 type C length 80,
     ADDRESS_LINE_8 type C length 80,
     SERVICEPERFORMER type C length 10,
     SERVICEPERFORMERNAME type C length 80,
     PRODUCTTYPE type C length 2,
     PEINH type P length 3 decimals 0,
     PRSDR type C length 1,
     LOEKZ type C length 1,
     RETPO type C length 1,
     ELIKZ type C length 1,
  end of TS_PURCHASEORDERLIMITITEMNODE .
  types:
TT_PURCHASEORDERLIMITITEMNODE type standard table of TS_PURCHASEORDERLIMITITEMNODE .
  types:
  begin of TS_PURCHASEORDERLIMITITEMSTTEX,
     EBELN type C length 10,
     EBELP type C length 5,
     DRUVO type C length 1,
     ESART type C length 4,
     PSTYP type C length 1,
     TDOBJECT type C length 10,
     LANGUAGE type C length 2,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     DRFLG type C length 2,
     DRPRI type C length 1,
     TDOBNAME type C length 70,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERLIMITITEMSTTEX .
  types:
TT_PURCHASEORDERLIMITITEMSTTEX type standard table of TS_PURCHASEORDERLIMITITEMSTTEX .
  types:
  begin of TS_PURCHASEORDERLIMITITEMTEXTS,
     EBELN type C length 10,
     EBELP type C length 5,
     TEXT_ID type C length 4,
     TEXT_ID_DESCR type C length 30,
     LANGUAGE type C length 2,
     TEXT_CONTENT type string,
  end of TS_PURCHASEORDERLIMITITEMTEXTS .
  types:
TT_PURCHASEORDERLIMITITEMTEXTS type standard table of TS_PURCHASEORDERLIMITITEMTEXTS .
  types:
     TS_PURCHASEORDERNODE type TDS_ME_PO_HEADER .
  types:
TT_PURCHASEORDERNODE type standard table of TS_PURCHASEORDERNODE .
  types:
     TS_PURCHASEORDERSCHEDULELINENO type TDS_ME_PO_SCHEDULELINE .
  types:
TT_PURCHASEORDERSCHEDULELINENO type standard table of TS_PURCHASEORDERSCHEDULELINENO .
  types:
  begin of TS_PURCHASINGGROUPNODE,
     EKGRP type C length 3,
     EKNAM type C length 18,
     TEL_NUMBER type C length 30,
     TELFX type C length 31,
     SMTP_ADDR type C length 241,
  end of TS_PURCHASINGGROUPNODE .
  types:
TT_PURCHASINGGROUPNODE type standard table of TS_PURCHASINGGROUPNODE .
  types:
  begin of TS_QUERYNODE,
     EBELN type C length 10,
     LAND1 type C length 3,
     LANGU type C length 1,
     CHANGE_FLAG type C length 1,
     LIFN2 type C length 10,
  end of TS_QUERYNODE .
  types:
TT_QUERYNODE type standard table of TS_QUERYNODE .
  types:
  begin of TS_SHIPTOPARTYNODE,
     ADRNR type C length 10,
     ADDRESS_LINE_1 type C length 80,
     ADDRESS_LINE_2 type C length 80,
     ADDRESS_LINE_3 type C length 80,
     ADDRESS_LINE_4 type C length 80,
     ADDRESS_LINE_5 type C length 80,
     ADDRESS_LINE_6 type C length 80,
     ADDRESS_LINE_7 type C length 80,
     ADDRESS_LINE_8 type C length 80,
  end of TS_SHIPTOPARTYNODE .
  types:
TT_SHIPTOPARTYNODE type standard table of TS_SHIPTOPARTYNODE .
  types:
  begin of TS_SUPPLIERNODE,
     LIFNR type C length 10,
     NAME1 type C length 35,
     ADRNR type C length 10,
     SMTP_ADDR type C length 241,
     ADDRESS_LINE_1 type C length 80,
     ADDRESS_LINE_2 type C length 80,
     ADDRESS_LINE_3 type C length 80,
     ADDRESS_LINE_4 type C length 80,
     ADDRESS_LINE_5 type C length 80,
     ADDRESS_LINE_6 type C length 80,
     ADDRESS_LINE_7 type C length 80,
     ADDRESS_LINE_8 type C length 80,
     STCEG type C length 20,
  end of TS_SUPPLIERNODE .
  types:
TT_SUPPLIERNODE type standard table of TS_SUPPLIERNODE .
  types:
     TS_POCUSTOMHDR type ZST_PO_HEADER .
  types:
TT_POCUSTOMHDR type standard table of TS_POCUSTOMHDR .

  constants GC_SUPPLIERNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'SupplierNode' ##NO_TEXT.
  constants GC_SHIPTOPARTYNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ShipToPartyNode' ##NO_TEXT.
  constants GC_QUERYNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'QueryNode' ##NO_TEXT.
  constants GC_PURCHASINGGROUPNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchasingGroupNode' ##NO_TEXT.
  constants GC_PURCHASEORDERSCHEDULELINENO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderScheduleLineNode' ##NO_TEXT.
  constants GC_PURCHASEORDERNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderNode' ##NO_TEXT.
  constants GC_PURCHASEORDERLIMITITEMTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderLimitItemTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERLIMITITEMSTTEX type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderLimitItemSTTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERLIMITITEMNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderLimitItemNode' ##NO_TEXT.
  constants GC_PURCHASEORDERLIMITITEMCHANG type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderLimitItemChangesNode' ##NO_TEXT.
  constants GC_PURCHASEORDERITEMTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderItemTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERITEMSTTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderItemSTTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERITEMNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderItemNode' ##NO_TEXT.
  constants GC_PURCHASEORDERITEMCHANGESNOD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderItemChangesNode' ##NO_TEXT.
  constants GC_PURCHASEORDERITEMBATCHNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderItemBatchNode' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERSCHEDULELI type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierScheduleLineNode' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERITEMTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierItemTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERITEMSTTEXT type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierItemSTTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERITEMNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierItemNode' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERITEMCHANGE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierItemChangesNode' ##NO_TEXT.
  constants GC_PURCHASEORDERHIERITEMBATCHN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHierItemBatchNode' ##NO_TEXT.
  constants GC_PURCHASEORDERHEADERTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHeaderTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERHEADERSTTEXTS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderHeaderSTTexts' ##NO_TEXT.
  constants GC_PURCHASEORDERCHANGESNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'PurchaseOrderChangesNode' ##NO_TEXT.
  constants GC_POSUBCONTRACTINGCOMPONENTST type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POSubcontractingComponentsTexts' ##NO_TEXT.
  constants GC_POSUBCONTRACTINGCOMPONENTSN type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POSubcontractingComponentsNode' ##NO_TEXT.
  constants GC_POSUBCONTRACTINGCOMPONENTSB type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POSubcontractingComponentsBatchNode' ##NO_TEXT.
  constants GC_POHIERSUBCONTRACTINGCOMPONE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POHierSubcontractingComponentsBatchNode' ##NO_TEXT.
  constants GC_POHIERSUBCONTRACTINGCOMPON type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POHierSubcontractingComponentsNode' ##NO_TEXT.
  constants GC_POHIERSUBCONTRACTINGCOMPO type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POHierSubcontractingComponentsTexts' ##NO_TEXT.
  constants GC_POCUSTOMHDR type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POCustomHdr' ##NO_TEXT.
  constants GC_POCONFIGURATIONITEMNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POConfigurationItemNode' ##NO_TEXT.
  constants GC_POCONFIGURATIONHIERITEMNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'POConfigurationHierItemNode' ##NO_TEXT.
  constants GC_ORDERINGADDRESS type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'OrderingAddress' ##NO_TEXT.
  constants GC_ITEMPRICINGCONDITIONNODE type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'ItemPricingConditionNode' ##NO_TEXT.
  constants GC_HIERITEMPRICINGCONDITIONNOD type /IWBEP/IF_MGW_MED_ODATA_TYPES=>TY_E_MED_ENTITY_NAME value 'HierItemPricingConditionNode' ##NO_TEXT.

  methods GET_EXTENDED_MODEL
  final
    exporting
      !EV_EXTENDED_SERVICE type /IWBEP/MED_GRP_TECHNICAL_NAME
      !EV_EXT_SERVICE_VERSION type /IWBEP/MED_GRP_VERSION
      !EV_EXTENDED_MODEL type /IWBEP/MED_MDL_TECHNICAL_NAME
      !EV_EXT_MODEL_VERSION type /IWBEP/MED_MDL_VERSION
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
  methods LOAD_TEXT_ELEMENTS
  final
    returning
      value(RT_TEXT_ELEMENTS) type TT_TEXT_ELEMENTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .

  methods DEFINE
    redefinition .
  methods GET_LAST_MODIFIED
    redefinition .
protected section.
private section.

  constants GC_INCL_NAME type STRING value 'ZCL_FDP_EF_PURCHASE_O_MPC=====CP' ##NO_TEXT.

  methods CREATE_NEW_ARTIFACTS
    raising
      /IWBEP/CX_MGW_MED_EXCEPTION .
ENDCLASS.



CLASS ZCL_FDP_EF_PURCHASE_O_MPC IMPLEMENTATION.


  method CREATE_NEW_ARTIFACTS.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


DATA:
  lo_entity_type    TYPE REF TO /iwbep/if_mgw_odata_entity_typ,                      "#EC NEEDED
  lo_complex_type   TYPE REF TO /iwbep/if_mgw_odata_cmplx_type,                      "#EC NEEDED
  lo_property       TYPE REF TO /iwbep/if_mgw_odata_property,                        "#EC NEEDED
  lo_association    TYPE REF TO /iwbep/if_mgw_odata_assoc,                           "#EC NEEDED
  lo_assoc_set      TYPE REF TO /iwbep/if_mgw_odata_assoc_set,                       "#EC NEEDED
  lo_ref_constraint TYPE REF TO /iwbep/if_mgw_odata_ref_constr,                      "#EC NEEDED
  lo_nav_property   TYPE REF TO /iwbep/if_mgw_odata_nav_prop,                        "#EC NEEDED
  lo_action         TYPE REF TO /iwbep/if_mgw_odata_action,                          "#EC NEEDED
  lo_parameter      TYPE REF TO /iwbep/if_mgw_odata_property,                        "#EC NEEDED
  lo_entity_set     TYPE REF TO /iwbep/if_mgw_odata_entity_set.                      "#EC NEEDED


***********************************************************************************************************************************
*   ENTITY - POCustomHdr
***********************************************************************************************************************************
lo_entity_type = model->create_entity_type( iv_entity_type_name = 'POCustomHdr' iv_def_entity_set = abap_false ). "#EC NOTEXT

***********************************************************************************************************************************
*Properties
***********************************************************************************************************************************

lo_property = lo_entity_type->create_property( iv_property_name = 'PurchaseOrder' iv_abap_fieldname = 'PURCHASE_ORDER' ). "#EC NOTEXT
lo_property->set_is_key( ).
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 10 ).
lo_property->set_conversion_exit( 'ALPHA' ). "#EC NOTEXT
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).
lo_property = lo_entity_type->create_property( iv_property_name = 'Adr1' iv_abap_fieldname = 'ADR1' ). "#EC NOTEXT
lo_property->set_label_from_text_element( iv_text_element_symbol = '002' iv_text_element_container = gc_incl_name ). "#EC NOTEXT
lo_property->set_type_edm_string( ).
lo_property->set_maxlength( iv_max_length = 255 ).
lo_property->set_creatable( abap_false ).
lo_property->set_updatable( abap_false ).
lo_property->set_sortable( abap_false ).
lo_property->set_nullable( abap_false ).
lo_property->set_filterable( abap_false ).

lo_entity_type->bind_structure( iv_structure_name   = 'ZST_PO_HEADER'
                                iv_bind_conversions = 'X' ). "#EC NOTEXT


***********************************************************************************************************************************
*   ENTITY SETS
***********************************************************************************************************************************
lo_entity_type = model->get_entity_type( iv_entity_name = 'POCustomHdr' ). "#EC NOTEXT
lo_entity_set = lo_entity_type->create_entity_set( 'POCustomHdrSet' ). "#EC NOTEXT

lo_entity_set->set_creatable( abap_false ).
lo_entity_set->set_updatable( abap_false ).
lo_entity_set->set_deletable( abap_false ).

lo_entity_set->set_pageable( abap_false ).
lo_entity_set->set_addressable( abap_true ).
lo_entity_set->set_has_ftxt_search( abap_false ).
lo_entity_set->set_subscribable( abap_false ).
lo_entity_set->set_filter_required( abap_false ).


***********************************************************************************************************************************
*   new_associations
***********************************************************************************************************************************

 lo_association = model->create_association(
                            iv_association_name = 'POHeader_POCustomHdr' "#EC NOTEXT
                            iv_left_type        = 'PurchaseOrderNode' "#EC NOTEXT
                            iv_right_type       = 'POCustomHdr' "#EC NOTEXT
                            iv_right_card       = '0' "#EC NOTEXT
                            iv_left_card        = '1' ). "#EC NOTEXT
* Referential constraint for association - POHeader_POCustomHdr
lo_ref_constraint = lo_association->create_ref_constraint( ).
lo_ref_constraint->add_property( iv_principal_property = 'PurchaseOrder'   iv_dependent_property = 'PurchaseOrder' )."#EC NOTEXT
* Association Sets for association - POHeader_POCustomHdr
lo_assoc_set = lo_association->create_assoc_set( iv_assoc_set_name = 'POHeader_POCustomHdrSet' ). "#EC NOTEXT


* Navigation Properties for entity - POCustomHdr
lo_entity_type = model->get_entity_type( iv_entity_name = 'POCustomHdr' ). "#EC NOTEXT
lo_nav_property = lo_entity_type->create_navigation_property( iv_property_name  = 'PurchaseOrderNode' "#EC NOTEXT
                                                          iv_association_name = 'POHeader_POCustomHdr' ). "#EC NOTEXT


   lo_entity_type = model->get_entity_type( iv_entity_name = 'PurchaseOrderNode' ). "#EC NOTEXT
   lo_nav_property = lo_entity_type->create_navigation_property( iv_property_name  = 'POCustomHdr' "#EC NOTEXT
                                                          iv_association_name = 'POHeader_POCustomHdr' ). "#EC NOTEXT
  endmethod.


  method DEFINE.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


data:
  lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ, "#EC NEEDED
  lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type, "#EC NEEDED
  lo_property       type ref to /iwbep/if_mgw_odata_property, "#EC NEEDED
  lo_association    type ref to /iwbep/if_mgw_odata_assoc,  "#EC NEEDED
  lo_assoc_set      type ref to /iwbep/if_mgw_odata_assoc_set, "#EC NEEDED
  lo_ref_constraint type ref to /iwbep/if_mgw_odata_ref_constr, "#EC NEEDED
  lo_nav_property   type ref to /iwbep/if_mgw_odata_nav_prop, "#EC NEEDED
  lo_action         type ref to /iwbep/if_mgw_odata_action, "#EC NEEDED
  lo_parameter      type ref to /iwbep/if_mgw_odata_property, "#EC NEEDED
  lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set, "#EC NEEDED
  lo_complex_prop   type ref to /iwbep/if_mgw_odata_cmplx_prop. "#EC NEEDED

* Extend the model
model->extend_model( iv_model_name = 'FDP_EF_PURCHASE_ORDER_MDL' iv_model_version = '0001' ). "#EC NOTEXT

model->set_schema_namespace( 'FDP_EF_PURCHASE_ORDER_SRV' ).
* New artifacts have been created in the service builder after the redefinition of service
create_new_artifacts( ).
  endmethod.


  method GET_EXTENDED_MODEL.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*



ev_extended_service  = 'FDP_EF_PURCHASE_ORDER_SRV'.                "#EC NOTEXT
ev_ext_service_version = '0001'.               "#EC NOTEXT
ev_extended_model    = 'FDP_EF_PURCHASE_ORDER_MDL'.                    "#EC NOTEXT
ev_ext_model_version = '0001'.                   "#EC NOTEXT
  endmethod.


  method GET_LAST_MODIFIED.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


  constants: lc_gen_date_time type timestamp value '20230519071543'. "#EC NOTEXT
rv_last_modified = super->get_last_modified( ).
IF rv_last_modified LT lc_gen_date_time.
  rv_last_modified = lc_gen_date_time.
ENDIF.
  endmethod.


  method LOAD_TEXT_ELEMENTS.
*&---------------------------------------------------------------------*
*&           Generated code for the MODEL PROVIDER BASE CLASS          &*
*&                                                                     &*
*&  !!!NEVER MODIFY THIS CLASS. IN CASE YOU WANT TO CHANGE THE MODEL   &*
*&        DO THIS IN THE MODEL PROVIDER SUBCLASS!!!                    &*
*&                                                                     &*
*&---------------------------------------------------------------------*


data:
  lo_entity_type    type ref to /iwbep/if_mgw_odata_entity_typ,           "#EC NEEDED
  lo_complex_type   type ref to /iwbep/if_mgw_odata_cmplx_type,           "#EC NEEDED
  lo_property       type ref to /iwbep/if_mgw_odata_property,             "#EC NEEDED
  lo_association    type ref to /iwbep/if_mgw_odata_assoc,                "#EC NEEDED
  lo_assoc_set      type ref to /iwbep/if_mgw_odata_assoc_set,            "#EC NEEDED
  lo_ref_constraint type ref to /iwbep/if_mgw_odata_ref_constr,           "#EC NEEDED
  lo_nav_property   type ref to /iwbep/if_mgw_odata_nav_prop,             "#EC NEEDED
  lo_action         type ref to /iwbep/if_mgw_odata_action,               "#EC NEEDED
  lo_parameter      type ref to /iwbep/if_mgw_odata_property,             "#EC NEEDED
  lo_entity_set     type ref to /iwbep/if_mgw_odata_entity_set.           "#EC NEEDED


DATA:
     ls_text_element TYPE ts_text_element.                   "#EC NEEDED


clear ls_text_element.
ls_text_element-artifact_name          = 'Adr1'.      "#EC NOTEXT
ls_text_element-artifact_type          = 'PROP'.                       "#EC NOTEXT
ls_text_element-parent_artifact_name   = 'POCUSTOMHDR'.     "#EC NOTEXT
ls_text_element-parent_artifact_type   = 'ETYP'.                             "#EC NOTEXT
ls_text_element-text_symbol            = '002'.         "#EC NOTEXT
APPEND ls_text_element TO rt_text_elements.
  endmethod.
ENDCLASS.

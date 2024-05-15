class ZCL_FDP_EF_PURCHASE_O_DPC_EXT definition
  public
  inheriting from ZCL_FDP_EF_PURCHASE_O_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_ENTITY
    redefinition .
protected section.

  methods POCUSTOMHDR_GET_ENTITY
    importing
      !IV_ENTITY_NAME type STRING
      !IV_ENTITY_SET_NAME type STRING
      !IV_SOURCE_NAME type STRING
      !IT_KEY_TAB type /IWBEP/T_MGW_NAME_VALUE_PAIR
      !IO_REQUEST_OBJECT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IO_TECH_REQUEST_CONTEXT type ref to /IWBEP/IF_MGW_REQ_ENTITY optional
      !IT_NAVIGATION_PATH type /IWBEP/T_MGW_NAVIGATION_PATH
    exporting
      !ER_ENTITY type ZCL_FDP_EF_PURCHASE_O_MPC=>TS_POCUSTOMHDR
      !ES_RESPONSE_CONTEXT type /IWBEP/IF_MGW_APPL_SRV_RUNTIME=>TY_S_MGW_RESPONSE_ENTITY_CNTXT
    raising
      /IWBEP/CX_MGW_BUSI_EXCEPTION
      /IWBEP/CX_MGW_TECH_EXCEPTION .
private section.
ENDCLASS.



CLASS ZCL_FDP_EF_PURCHASE_O_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_entity.

    TRY.
        CALL METHOD super->/iwbep/if_mgw_appl_srv_runtime~get_entity
          EXPORTING
            iv_entity_name          = iv_entity_name
            iv_entity_set_name      = iv_entity_set_name
            iv_source_name          = iv_source_name
            it_key_tab              = it_key_tab
            it_navigation_path      = it_navigation_path
            io_tech_request_context = io_tech_request_context
          IMPORTING
            er_entity               = er_entity
            es_response_context     = es_response_context.
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.

    TRY.
        IF er_entity IS NOT BOUND.
          IF iv_entity_set_name EQ 'POCustomHdrSet'.
*     Call the entity set generated method
            purchaseorders_get_entity(
                 EXPORTING iv_entity_name     = iv_entity_name
                           iv_entity_set_name = iv_entity_set_name
                           iv_source_name     = iv_source_name
                           it_key_tab         = it_key_tab
                           it_navigation_path = it_navigation_path
                           io_tech_request_context = io_tech_request_context
               	 IMPORTING er_entity          = DATA(pocustomhdr_get_entity)
                           es_response_context = es_response_context
            ).

            IF pocustomhdr_get_entity IS NOT INITIAL.
*     Send specific entity data to the caller interface
              copy_data_to_ref(
                EXPORTING
                  is_data = pocustomhdr_get_entity
                CHANGING
                  cr_data = er_entity
              ).
            ELSE.
*         In case of initial values - unbind the entity reference
*          er_entity = lr_entity.
            ENDIF.
          ENDIF.
        ENDIF.
      CATCH /iwbep/cx_mgw_busi_exception.
      CATCH /iwbep/cx_mgw_tech_exception.
    ENDTRY.

  ENDMETHOD.


  method POCUSTOMHDR_GET_ENTITY.
  RAISE EXCEPTION TYPE /iwbep/cx_mgw_not_impl_exc
    EXPORTING
      textid = /iwbep/cx_mgw_not_impl_exc=>method_not_implemented
      method = 'POSUBCONTRACTI02_GET_ENTITY'.
  endmethod.
ENDCLASS.

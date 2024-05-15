class ZCO_FI_S4_TO_WORKDAY definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods SEND_DATA
    importing
      !OUTPUT type ZMT_OB_MSGTYP_CON_WORKDAY
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_FI_S4_TO_WORKDAY IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_FI_S4_TO_WORKDAY'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method SEND_DATA.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'OUTPUT' kind = '0' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SEND_DATA'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.

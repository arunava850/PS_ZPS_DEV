class YARDICO_ZFI_YARDI_S4_GLPOST_PR definition
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
  methods ZFI_YARDI_S4GLPOST_PROXY
    importing
      !INPUT type YARDIZFI_YARDI_S4GLPOST_PROXY
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS YARDICO_ZFI_YARDI_S4_GLPOST_PR IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'YARDICO_ZFI_YARDI_S4_GLPOST_PR'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method ZFI_YARDI_S4GLPOST_PROXY.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'ZFI_YARDI_S4GLPOST_PROXY'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.

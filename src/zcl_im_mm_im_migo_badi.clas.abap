class ZCL_IM_MM_IM_MIGO_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_MIGO_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_MM_IM_MIGO_BADI IMPLEMENTATION.


  method IF_EX_MB_MIGO_BADI~CHECK_HEADER.
  endmethod.


  method IF_EX_MB_MIGO_BADI~CHECK_ITEM.
  endmethod.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_DELETE.
  endmethod.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_LOAD.
  endmethod.


  method IF_EX_MB_MIGO_BADI~HOLD_DATA_SAVE.
  endmethod.


  method IF_EX_MB_MIGO_BADI~INIT.
  endmethod.


  method IF_EX_MB_MIGO_BADI~LINE_DELETE.
  endmethod.


  METHOD if_ex_mb_migo_badi~line_modify.
*    IF sy-tcode EQ 'MIGO'.
*      SELECT SINGLE kokrs,
*             prctr,
*             bukrs
*        INTO @DATA(ls_bukrs)
*        FROM cepc_bukrs
*       WHERE prctr EQ @cs_goitem-prctr.
*      IF ls_bukrs-bukrs NE cs_goitem-bukrs_for_stock.
*        cs_goitem-prctr = 'PS_CORP'.
*      ENDIF.
*    ENDIF.
  ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~MAA_LINE_ID_ADJUST.
  endmethod.


  method IF_EX_MB_MIGO_BADI~MODE_SET.
  endmethod.


  METHOD if_ex_mb_migo_badi~pai_detail.
*    e_force_change = abap_true.
  ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~PAI_HEADER.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PBO_DETAIL.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PBO_HEADER.
  endmethod.


  METHOD if_ex_mb_migo_badi~post_document.
*    BREAK-POINT 'VCHANNA'.
*    IF sy-tcode EQ 'MIGO'.
*      SELECT kokrs,
*             prctr,
*             bukrs
*        INTO TABLE @DATA(lt_bukrs)
*        FROM cepc_bukrs
*         FOR ALL ENTRIES IN @it_mseg
*       WHERE prctr EQ @it_mseg-prctr.
*      LOOP AT it_mseg ASSIGNING FIELD-SYMBOL(<fs_mseg>).
*        READ TABLE lt_bukrs
*         INTO DATA(ls_bukrs)
*          WITH KEY prctr = <fs_mseg>-prctr.
*        IF ls_bukrs-bukrs NE <fs_mseg>-bukrs.
*          <fs_mseg>-prctr = 'PS_CORP'.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
  ENDMETHOD.


  method IF_EX_MB_MIGO_BADI~PROPOSE_SERIALNUMBERS.
  endmethod.


  method IF_EX_MB_MIGO_BADI~PUBLISH_MATERIAL_ITEM.
  endmethod.


  method IF_EX_MB_MIGO_BADI~RESET.
  endmethod.


  method IF_EX_MB_MIGO_BADI~STATUS_AND_HEADER.
  endmethod.
ENDCLASS.

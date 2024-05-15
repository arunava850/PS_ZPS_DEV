class ZCL_IM_FI_RAMP_ASSET_POST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ACC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_RAMP_ASSET_POST IMPLEMENTATION.


  METHOD if_ex_acc_document~change.
    LOOP AT c_accit ASSIGNING FIELD-SYMBOL(<fs_accit>) WHERE koart = 'A'.
      <fs_accit>-anbwa = '100'.
    ENDLOOP.

    READ TABLE c_extension2 ASSIGNING FIELD-SYMBOL(<fs_extn2>) WITH KEY structure = 'EXTENSION2'.
    IF sy-subrc EQ 0.
      LOOP AT c_accit ASSIGNING <fs_accit>.
        <fs_accit>-xref1_hd = <fs_extn2>-valuepart2.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_acc_document~fill_accit.
    ""For posting asset acquisitions ACCIT-ANBWA has to be filled for the asset line.
    IF c_accit-koart = 'A'.
      c_accit-anbwa = '100'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

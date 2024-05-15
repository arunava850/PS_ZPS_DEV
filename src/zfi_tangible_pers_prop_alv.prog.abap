*&---------------------------------------------------------------------*
*& Report ZFI_TANGIBLE_PERS_PROP_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_tangible_pers_prop_alv.
TABLES: acdoca.

TYPES: BEGIN OF ty_acdoca,
        rldnr   TYPE    acdoca-rldnr,
        rbukrs  TYPE      acdoca-rbukrs,
        gjahr   TYPE acdoca-gjahr,
        belnr   TYPE acdoca-belnr,
        docln   TYPE acdoca-docln,
        anlkl   TYPE     acdoca-anlkl,

        anln1   TYPE acdoca-anln1,
        bzdat   TYPE acdoca-bzdat,
        anbwa   TYPE acdoca-anbwa,
        bwatxt  TYPE tabwt-bwatxt,
*        belnr   TYPE acdoca-belnr,
        blart   TYPE acdoca-blart,
        ktansw  TYPE t095-ktansw,
        prctr   TYPE acdoca-prctr,
        bttype  TYPE  acdoca-bttype,
        bttype_txt     TYPE  FINSC_BTTYPE_T-txt,
        cbttype TYPE  acdoca-cbttype,
        RHCUR   TYPE    ACDOCA-RHCUR,
        HSL     TYPE    ACDOCA-HSL ,
        DRCRK   TYPE    ACDOCA-DRCRK ,
        BUDAT   TYPE    ACDOCA-BUDAT ,
        BSCHL   TYPE    ACDOCA-BSCHL ,
        ZUONR   TYPE    ACDOCA-ZUONR ,
        SGTXT   TYPE    ACDOCA-SGTXT ,
        LIFNR   TYPE    ACDOCA-LIFNR ,
      END OF ty_acdoca.

DATA: gt_acdoca TYPE table of ty_acdoca.


PARAMETERS:     p_bukrs TYPE acdoca-rbukrs OBLIGATORY.
SELECT-OPTIONS  s_anlkl FOR acdoca-anlkl NO INTERVALS .
PARAMETERS:     p_gjahr  TYPE acdoca-gjahr OBLIGATORY,
                p_RLDNR  type acdoca-RLDNR OBLIGATORY.


START-OF-SELECTION.

  PERFORM get_data.


END-OF-SELECTION.
  PERFORM display_alv.


FORM get_data.

SELECT  rldnr
        rbukrs
        gjahr
        belnr
        docln
        acdoca~anlkl

        anln1
        bzdat
        anbwa
        bwatxt
        belnr
        blart
        ktansw
        prctr
        acdoca~bttype
        FINSC_BTTYPE_T~txt as bttype_txt
        cbttype
        RHCUR
        HSL
        DRCRK
        BUDAT
        BSCHL
        ZUONR
        SGTXT
        acdoca~LIFNR
        from acdoca
        inner join tabwt
        on  tabwt~BWASL = acdoca~anbwa
        and tabwt~spras = 'E'
        inner join anka
        on  anka~anlkl = acdoca~anlkl
        inner join t095
        on  t095~ktopl = 'PSUS'
        and t095~ktogr = anka~ktogr
        and t095~afabe  = '90'                  "WIP - ask FE for confirmation, need to pass prrimary key to avoid dupicates
        inner join FINSC_BTTYPE_T
        on  FINSC_BTTYPE_T~langu = 'E'
        and FINSC_BTTYPE_T~bttype  = acdoca~BTTYPE
        into CORRESPONDING FIELDS OF TABLE gt_acdoca
        WHERE RLDNR = p_RLDNR
        AND   RBUKRS = p_BUKRS
        AND   GJAHR  = p_GJAHR
        AND   acdoca~anlkl  in s_anlkl


        .

ENDFORM.

FORM display_alv.
TRY.
        cl_salv_table=>factory(
            IMPORTING !r_salv_table = DATA(go_alv_grid)
            changing  !t_table      = gt_acdoca ).

        "activate toolbar
        data(go_functions) = go_alv_grid->get_functions( ).
        go_functions->set_all( if_salv_c_bool_sap=>true ).



        "Display ALV
         go_alv_grid->display( ).

CATCH
      cx_salv_msg
      cx_salv_not_found
      cx_salv_data_error
      cx_salv_existing into data(lo_x).

      message lo_x type 'E'.
ENDTRY..

ENDFORM.

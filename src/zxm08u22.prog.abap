*&---------------------------------------------------------------------*
*& Include          ZXM08U22
*&---------------------------------------------------------------------*


*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_LIFNR) LIKE  RBKP-LIFNR
*"     VALUE(I_BUKRS) LIKE  RBKP-BUKRS
*"     VALUE(I_IDOC_CONTRL) LIKE  EDIDC STRUCTURE  EDIDC
*"  EXPORTING
*"     VALUE(E_LIFNR) LIKE  RBKP-LIFNR
*"     VALUE(E_BUKRS) LIKE  RBKP-BUKRS
*"     VALUE(E_CHANGE) TYPE  C
*"  TABLES
*"      T_IDOC_DATA STRUCTURE  EDIDD
*"  EXCEPTIONS
*"      ERROR_MESSAGE

DATA:
  lc_segnam_e1edka1 LIKE edidd-segnam VALUE 'E1EDKA1',
  lc_segnam_e1edp01 LIKE edidd-segnam VALUE 'E1EDP01',
  lc_segnam_e1edp05 LIKE edidd-segnam VALUE 'E1EDP05',
  lc_segnam_e1edpa1 LIKE edidd-segnam VALUE 'E1EDPA1',
  lc_segnam_e1edp02 LIKE edidd-segnam VALUE 'E1EDP02',
  lc_segnam_e1edk02 LIKE edidd-segnam VALUE 'E1EDK02',
  lc_segnum_initial LIKE edidd-segnum.


DATA: lv_test    TYPE c,
      ls_e1edka1 TYPE e1edka1,
      ls_e1edp01 TYPE e1edp01,
      ls_e1edpa1 TYPE e1edpa1,
      ls_e1edp05 TYPE e1edp05,
      ls_e1edp02 TYPE e1edp02,
      ls_e1edk02 TYPE e1edk02,
      ls_edidd   TYPE edidd,
      lv_matnr   TYPE matnr.
CLEAR lv_test.

READ TABLE t_idoc_data INTO DATA(ls_inv_ref) WITH KEY segnam = lc_segnam_e1edk02.
IF sy-subrc IS INITIAL.
  ls_e1edk02 = ls_inv_ref-sdata.
ENDIF.

READ TABLE t_idoc_data INTO DATA(ls_po) WITH KEY segnam = lc_segnam_e1edp02.
IF sy-subrc IS INITIAL.
  ls_e1edp02 = ls_po-sdata.

  SELECT SINGLE ebeln, bukrs, lifnr, waers
  INTO @DATA(ls_ekko)
  FROM ekko
  WHERE ebeln = @ls_e1edp02-belnr.

  IF sy-subrc IS INITIAL.

*    SELECT b~belnr, b~gjahr, b~buzei, a~xblnr, b~ebeln, b~ebelp
*    FROM rbkp AS a
*    LEFT JOIN rseg AS b ON a~belnr = b~belnr
*    INTO TABLE @DATA(lt_miro_inv_ref)
*    WHERE a~xblnr = @ls_E1EDK02-belnr
*    AND b~ebeln = @ls_ekko-ebeln.

    SELECT ebeln, ebelp, werks, umren, umrez, menge, meins, bprme, lmein, ko_prctr
    FROM ekpo
    INTO TABLE @DATA(lt_ekpo)
    WHERE ebeln = @ls_ekko-ebeln.

    IF sy-subrc IS INITIAL.

      LOOP AT t_idoc_data ASSIGNING  FIELD-SYMBOL(<lfs_edidd>).

        CASE <lfs_edidd>-segnam.
          WHEN  lc_segnam_e1edka1.
            ls_e1edka1 = <lfs_edidd>-sdata.

            IF ls_e1edka1-parvw = 'RE'.
              ls_e1edka1-partn = ls_ekko-bukrs."'9950'.
              ls_e1edka1-lifnr = ls_ekko-bukrs."'9950'.
              e_bukrs = ls_ekko-bukrs."'9950'.
            ELSEIF ls_e1edka1-parvw = 'LF'.
              ls_e1edka1-partn = ls_ekko-lifnr."'0010000001'.
              ls_e1edka1-lifnr = ls_ekko-lifnr."'0010000001'.
              e_lifnr = ls_ekko-lifnr."'0010000001'.
            ENDIF.

            <lfs_edidd>-sdata = ls_e1edka1.

          WHEN  lc_segnam_e1edp01.
            ls_e1edp01 = <lfs_edidd>-sdata.
            READ TABLE lt_ekpo INTO DATA(ls_ekpo) WITH KEY ebelp = ls_e1edp01-posex.
            IF sy-subrc IS INITIAL.
              IF ls_ekpo-umrez GT 0.
*               ls_E1EDP01-menge = ls_E1EDP01-menge * ls_ekpo-umren / ls_ekpo-umrez.
                ls_ekpo-menge = ls_e1edp01-menge * ls_ekpo-umren / ls_ekpo-umrez.
                MOVE ls_ekpo-menge TO ls_e1edp01-menge.
                CONDENSE ls_e1edp01-menge.
                ls_e1edp01-menee = ls_ekpo-meins.
              ENDIF.

*              READ TABLE lt_miro_inv_ref INTO DATA(ls_miro_inv_ref) WITH KEY ebelp = ls_E1EDP01-posex.
*              IF sy-subrc IS INITIAL.
*                DATA(lv_dup_err) = abap_true.
*              ENDIF.

            ENDIF.


*      ls_E1EDP01-menge = 112.
*      ls_E1EDP01-menee = 'CV'.

            <lfs_edidd>-sdata = ls_e1edp01.

          WHEN  lc_segnam_e1edpa1.

            ls_e1edpa1 = <lfs_edidd>-sdata.

            IF ls_ekpo-werks IS NOT INITIAL.

              ls_e1edpa1-partn = ls_ekpo-werks."'W001'.

            ENDIF.

            <lfs_edidd>-sdata = ls_e1edpa1.


          WHEN  lc_segnam_e1edp05.

            ls_e1edp05 = <lfs_edidd>-sdata.

            IF ls_ekko-waers IS NOT INITIAL.

              ls_e1edp05-koein = ls_ekko-waers."'USD'.

            ENDIF.

            <lfs_edidd>-sdata = ls_e1edp05.


        ENDCASE.

      ENDLOOP.
      e_change = abap_true.
    ENDIF.
  ENDIF.

ENDIF.

*IF lv_dup_err = abap_true.
*  MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH 'Duplicate - Data already posted'.
*
*  RAISE error_message.
*ENDIF.

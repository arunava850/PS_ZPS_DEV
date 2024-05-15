*&---------------------------------------------------------------------*
*& Include          ZXM08U26
*&---------------------------------------------------------------------*

*"*"Lokale Schnittstelle:
*"  EXPORTING
*"     VALUE(E_CHANGE) TYPE  C
*"  TABLES
*"      T_FRSEG TYPE  MMCR_TFRSEG
*"      T_CO TYPE  MMCR_TCOBL_MRM
*"      T_MA TYPE  MMCR_TMA
*"  CHANGING
*"     VALUE(E_RBKPV) TYPE  MRM_RBKPV
*"  EXCEPTIONS
*"      ERROR_MESSAGE

DATA:
  lc_segnam_e1edka1 LIKE edidd-segnam VALUE 'E1EDKA1',
  lc_segnam_e1edp01 LIKE edidd-segnam VALUE 'E1EDP01',
  lc_segnam_e1edp05 LIKE edidd-segnam VALUE 'E1EDP05',
  lc_segnam_e1edpa1 LIKE edidd-segnam VALUE 'E1EDPA1',
  lc_segnam_E1EDP02 LIKE edidd-segnam VALUE 'E1EDP02',
  lc_segnam_E1EDK02 LIKE edidd-segnam VALUE 'E1EDK02',
  lc_segnum_initial LIKE edidd-segnum.

DATA: lv_test    TYPE c,
      ls_E1EDKA1 TYPE e1edka1,
      ls_E1EDP01 TYPE e1edp01,
      ls_E1EDPA1 TYPE e1edpa1,
      ls_E1EDP05 TYPE e1edp05,
      ls_E1EDP02 TYPE e1edp02,
      ls_E1EDK02 TYPE e1edk02,
      ls_EDIDD   TYPE edidd,
      lv_matnr   TYPE matnr.
CLEAR lv_test.

SELECT b~belnr, b~gjahr, b~buzei, a~xblnr, b~ebeln, b~ebelp
FROM rbkp AS a
LEFT JOIN rseg AS b ON a~belnr = b~belnr
INTO TABLE @DATA(lt_miro_inv_ref)
WHERE a~xblnr = @e_rbkpv-xblnr.

IF sy-subrc IS INITIAL.
  LOOP AT t_frseg INTO DATA(ls_T_FRSEG).
    READ TABLE lt_miro_inv_ref INTO DATA(ls_miro_inv_ref) WITH KEY ebeln = ls_T_FRSEG-ebeln ebelp = ls_T_FRSEG-ebelp.
    IF sy-subrc IS INITIAL.
      MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH 'Duplicate - Data already posted'.
      RAISE error_message.
    ENDIF.
  ENDLOOP.
ENDIF.

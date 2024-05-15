*&---------------------------------------------------------------------*
*& Include          ZFI_COST_ALLO_WRAPPER_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    p_fpath TYPE string,
    p_bpath TYPE rlgrap-filename DEFAULT '/interfaces/ENH0011/'.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_rldnr LIKE finsc_ledger-rldnr,
              p_gjahr LIKE acdoca-ryear,
              p_monat LIKE acdoca-poper.
  SELECT-OPTIONS: s_blart FOR acdoca-blart,
                  s_budat FOR acdoca-budat.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK c1 WITH FRAME TITLE TEXT-082.
  PARAMETERS: p_bl_ab LIKE acdoca-blart DEFAULT 'YA',
              p_budat LIKE acdoca-budat,
              p_bldat LIKE acdoca-bldat.
SELECTION-SCREEN END OF BLOCK c1.
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-088.
  PARAMETERS : p_fg RADIOBUTTON GROUP rg1 USER-COMMAND comm DEFAULT 'X',
               p_bg RADIOBUTTON GROUP rg1.
  SELECT-OPTIONS: p_email FOR adr6-smtp_addr.
SELECTION-SCREEN END OF BLOCK d1.

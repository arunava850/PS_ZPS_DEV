*&---------------------------------------------------------------------*
*& Include          ZMM_INF_ONHAND_MERCHANDISE_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_mtart FOR mara-mtart,
                  s_matnr FOR mara-matnr,
                  s_werks FOR t001w-werks.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: chk_cpi  AS CHECKBOX,
              chk_disp AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& Include          ZFI_INF_DRA_RECONNET_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_sname FOR setleaf-setname OBLIGATORY.
  PARAMETERS: p_sclass LIKE bapico_group-co_area OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: chk_cpi  AS CHECKBOX,
              chk_disp AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

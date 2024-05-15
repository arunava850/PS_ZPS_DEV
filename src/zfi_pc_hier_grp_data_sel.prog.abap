*&---------------------------------------------------------------------*
*& Include          ZFI_PC_HIER_GRP_DATA_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_class LIKE setleaf-setclass OBLIGATORY.
  SELECT-OPTIONS: s_sname FOR setleaf-setname OBLIGATORY.
  PARAMETERS: p_sclass LIKE bapico_group-co_area OBLIGATORY.
  PARAMETERS: rb_pc TYPE c RADIOBUTTON GROUP rd USER-COMMAND comm DEFAULT 'X',
              rb_cc TYPE c RADIOBUTTON GROUP rd.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: chk_cpi  AS CHECKBOX,
              chk_disp AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

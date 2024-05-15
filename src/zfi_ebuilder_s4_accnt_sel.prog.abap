*&---------------------------------------------------------------------*
*& Include          ZFI_EBUILDER_S4_ACCNT_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file TYPE rlgrap-filename,
               p_dir  TYPE rlgrap-filename,
               p_ascl TYPE anlkl,
               p_blart TYPE blart,
               p_dl   TYPE soobjinfi1-obj_name.
  PARAMETERS : p_rb1 RADIOBUTTON GROUP rg1,
               p_rb2 RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

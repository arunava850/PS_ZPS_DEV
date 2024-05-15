*&---------------------------------------------------------------------*
*& Include          ZFI_RAMP_INBOUND_ACNT_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_file   TYPE rlgrap-filename,
               p_dir    TYPE rlgrap-filename,
               p_dl     TYPE soobjinfi1-obj_name,
               p_docty  TYPE blart,
               p_capxgl TYPE hkont,
               p_opxgl  TYPE hkont,
*             p_taxgl TYPE hkont.
               p_thamnt TYPE dmbtr.
  SELECT-OPTIONS: s_asset FOR anla-anlkl.
  PARAMETERS : p_rb1 RADIOBUTTON GROUP rg1,
               p_rb2 RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_spfx TYPE char10,
               p_tpfx TYPE char10.
SELECTION-SCREEN END OF BLOCK b2.

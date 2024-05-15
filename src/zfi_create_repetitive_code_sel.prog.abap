*&---------------------------------------------------------------------*
*& Include          ZFI_CREATE_REPETITIVE_CODE_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-035.
  PARAMETERS : p_fr RADIOBUTTON GROUP rg1 USER-COMMAND comm DEFAULT 'X',
               p_ot RADIOBUTTON GROUP rg1.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK a2 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_fpath TYPE string.
SELECTION-SCREEN END OF BLOCK a2.

* Selection screen for bank
SELECTION-SCREEN BEGIN OF BLOCK a3 WITH FRAME TITLE TEXT-034.
  SELECT-OPTIONS: rng_grp FOR fibl_rpcode_grou-rpgroup.
  SELECT-OPTIONS: rng_buk FOR fibl_rpcode-bukrs MEMORY ID buk.
  SELECT-OPTIONS: rng_hbk FOR fibl_rpcode-hbkid MEMORY ID hbk.
  PARAMETERS: p_fy LIKE bkpf-gjahr.
SELECTION-SCREEN END OF BLOCK a3.

*&---------------------------------------------------------------------*
*& Include          ZFIAP_UNCLAIMED_CHECKS_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS: s_bukrs FOR gv_bukrs OBLIGATORY,
                  s_laufi FOR gv_laufi NO-EXTENSION,
                  s_vblnr FOR gv_vblnr .
  PARAMETERS: cb_prxy AS CHECKBOX,
              cb_mail AS CHECKBOX,
              cb_file AS CHECKBOX,
              p_file  TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& Include          ZMM_INF_SALES_MERCHANDISE_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_matnr FOR mara-matnr,
                  s_werks FOR t001w-werks,
                  s_xblnr FOR matdoc-xblnr,
                  s_bwart FOR matdoc-bwart,
                  s_CPUDT FOR matdoc-cpudt.
SELECTION-SCREEN END OF BLOCK a1.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS: chk_cpi  AS CHECKBOX,
              chk_disp AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

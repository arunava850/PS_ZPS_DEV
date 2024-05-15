*&---------------------------------------------------------------------*
*& Include          ZFI_PROP_DETAILS_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_class LIKE setleaf-setclass DEFAULT '106'." NO-DISPLAY.
  SELECT-OPTIONS: s_sname FOR setleaf-setname NO-DISPLAY.
  SELECT-OPTIONS: s_prop for zproperty-legacy_property_number.
  PARAMETERS: p_sclass LIKE bapico_group-co_area  DEFAULT 'PSCO' NO-DISPLAY.
  PARAMETERS: rb_pc TYPE c DEFAULT 'X' NO-DISPLAY,
              rb_cc TYPE c NO-DISPLAY.
  PARAMETERS: chk_cpi   NO-DISPLAY  ,
              chk_disp  DEFAULT abap_true NO-DISPLAY .
SELECTION-SCREEN END OF BLOCK a1.
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
*
*SELECTION-SCREEN END OF BLOCK b1.

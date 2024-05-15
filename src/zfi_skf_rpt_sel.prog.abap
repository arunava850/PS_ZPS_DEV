*&---------------------------------------------------------------------*
*& Include          ZFI_SKF_RPT_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Selection-Screen Parameters
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: s_stagr FOR faglskf_pn-stagr,
                  s_d_from FOR faglskf_pn-date_from,
                  s_docnr FOR faglskf_pn-docnr,
                  s_rbukrs FOR faglskf_pn-rbukrs,
                  s_rcntr FOR faglskf_pn-rcntr,
                  s_prctr FOR faglskf_pn-prctr,
                  s_rbusa FOR faglskf_pn-rbusa.
SELECTION-SCREEN END OF BLOCK a1.

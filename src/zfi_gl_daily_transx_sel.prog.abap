*&---------------------------------------------------------------------*
*& Include          ZFI_GL_DAILY_TRANSX_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS :  s_rldnr   FOR   acdoca-rldnr  ,
                    s_rbukrs  FOR   acdoca-rbukrs ,
                    s_prctr   FOR   acdoca-prctr  ,
                    s_cpudt   FOR   bkpf-cpudt    .
  PARAMETERS :      pv_count  TYPE  i DEFAULT '2000' .
SELECTION-SCREEN END OF BLOCK b1.

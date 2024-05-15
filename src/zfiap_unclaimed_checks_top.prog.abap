*&---------------------------------------------------------------------*
*& Include          ZFIAP_UNCLAIMED_CHECKS_TOP
*&---------------------------------------------------------------------*
DATA: gv_bukrs  TYPE bukrs,
      gv_laufi  TYPE dats,
      gv_mon    TYPE numc2,
      gv_year   TYPE numc4,
      gv_date   TYPE dats,
      gt_output TYPE TABLE OF zst_output_trackerpro,
      gs_output TYPE zst_output_trackerpro,
      gt_proxy  TYPE zdt_ob_input_trackerpro_tab,
      gv_value  TYPE char30,
      gv_vblnr  TYPE payr-vblnr.

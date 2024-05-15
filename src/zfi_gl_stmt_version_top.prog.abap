*&---------------------------------------------------------------------*
*& Include          ZFI_GL_DAILY_TRANSX_TOP
*&---------------------------------------------------------------------*

TABLES : fagl_011pc .

TYPES : BEGIN OF ty_parent,
          versn TYPE versn_011,
          id    TYPE seu_id,
          ergsl TYPE ergsl,
          txt45 TYPE txt45_011q,
          vonkt TYPE vonkt_011z,
          biskt TYPE biskt_011z,
        END OF ty_parent.

TYPES : BEGIN OF ty_inter,
          versn  TYPE versn_011,
          parent TYPE seu_id,
          ergsl  TYPE ergsl,
          txt45  TYPE txt45_011q,
          vonkt  TYPE vonkt_011z,
          biskt  TYPE biskt_011z,
        END OF ty_inter.

TYPES : BEGIN OF ty_node,
          versn TYPE versn_011,
          ergsl TYPE ergsl,
          txt45 TYPE txt45_011q,
          vonkt TYPE vonkt_011z,
          biskt TYPE biskt_011z,
        END OF ty_node.

DATA : gt_parent TYPE TABLE OF ty_parent,
       gt_inter  TYPE TABLE OF ty_inter,
       gt_node   TYPE TABLE OF ty_node,
       lv_date   TYPE sy-datum,
       gs_out    TYPE zfi_stmt_version_mt1,
       gt_data   TYPE zdata_fsv_tab,
       gs_data   LIKE LINE OF gt_data.

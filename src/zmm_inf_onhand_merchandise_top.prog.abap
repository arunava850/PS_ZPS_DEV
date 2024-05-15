*&---------------------------------------------------------------------*
*& Include          ZMM_INF_ONHAND_MERCHANDISE_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: mara, t001w.

*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_output,
         interface_name     TYPE zinterface_name,
         receiver_system    TYPE zreceiver_system,
         plant              TYPE t001w-werks,
         name2              TYPE t001w-name2,
         material           TYPE mara-matnr,
         unrestricted_stock TYPE char30,
         schedule_quantity  TYPE char30,
         delivered_quantity TYPE char30,
         open_po_quantity   TYPE char30,
         report_date        TYPE char10,
       END OF ty_output.

*&---------------------------------------------------------------------*
*& Global Data Declarations
*&---------------------------------------------------------------------*
DATA: gt_data   TYPE zzmm_merchand_tab,
      gs_data   LIKE LINE OF gt_data,
      gs_out    TYPE zmm_merchandise_onhand_mt,
      gt_output TYPE TABLE OF ty_output,
      gs_output TYPE ty_output,
      gl_alv    TYPE REF TO cl_salv_table.

CONSTANTS: c_s       TYPE c VALUE 'S',
           c_e       TYPE c VALUE 'E',
           c_sign_i  TYPE tvarvc-sign VALUE 'I',
           c_opti_eq TYPE tvarvc-opti VALUE 'EQ',
           c_mtart   TYPE mara-mtart VALUE 'ZRET'.

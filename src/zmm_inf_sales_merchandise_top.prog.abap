*&---------------------------------------------------------------------*
*& Include          ZMM_INF_SALES_MERCHANDISE_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: mara, t001w, matdoc.

*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_output,
         interface_name  TYPE zinterface_name,
         receiver_system TYPE zreceiver_system,
         Reference       TYPE matdoc-xblnr,
         Name2           TYPE t001w-name2,
         Material        TYPE matdoc-matnr,
         Quantity        TYPE char30,
         Amount_in_LC    TYPE matdoc-dmbtr,
         Item_Cost       TYPE matdoc-dmbtr,
         Movement_Type   TYPE matdoc-bwart,
         Posting_Date    TYPE char10,
         Plant           TYPE matdoc-werks,
       END OF ty_output.

*&---------------------------------------------------------------------*
*& Global Data Declarations
*&---------------------------------------------------------------------*
DATA: gt_data   TYPE zdata_mercsales_tab,
      gs_data   LIKE LINE OF gt_data,
      gs_out    TYPE zmm_merchandise_sales_mt,
      gt_output TYPE TABLE OF ty_output,
      gs_output TYPE ty_output,
      gl_alv    TYPE REF TO cl_salv_table.

CONSTANTS: c_s TYPE c VALUE 'S',
           c_e TYPE c VALUE 'E',
           c_tvar_name TYPE char25 VALUE 'ZMM_INF_SALES_TIMING',
           c_sign_i    TYPE tvarvc-sign VALUE 'I',
           c_opti_eq   TYPE tvarvc-opti VALUE 'EQ',
           c_opti_ne   TYPE tvarvc-opti VALUE 'NE'.

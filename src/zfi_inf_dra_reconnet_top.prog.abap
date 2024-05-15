*&---------------------------------------------------------------------*
*& Include          ZFI_INF_DRA_RECONNET_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: setleaf.

*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_output,
         interface_name  TYPE zinterface_name,
         receiver_system TYPE zreceiver_system,
         property_name   TYPE char50,
         property_number TYPE char7,
*BANK_ACCOUNT type
         blank1          TYPE char3,
         blank2          TYPE char3,
         blank3          TYPE char3,
         blank4          TYPE char3,
         district        TYPE char7,
         region          TYPE char5,
         division        TYPE char3,
         senior_district TYPE char7,
         senior_region   TYPE char5,
         blank5          TYPE char3,
         blank6          TYPE char3,
         blank7          TYPE char3,
         blank8          TYPE char3,
         blank9          TYPE char3,
       END OF ty_output.

*&---------------------------------------------------------------------*
*& Global Data Declarations
*&---------------------------------------------------------------------*
DATA: gt_data   TYPE zzdata_reconnet_tab,
      gs_data   LIKE LINE OF gt_data,
      gs_out    TYPE zfi_dra_to_reconnet_mt,
      gt_output TYPE TABLE OF ty_output,
      gs_output TYPE ty_output,
      gl_alv    TYPE REF TO cl_salv_table.

CONSTANTS: c_s       TYPE c VALUE 'S',
           c_e       TYPE c VALUE 'E',
           c_sign_i  TYPE tvarvc-sign VALUE 'I',
           c_opti_eq TYPE tvarvc-opti VALUE 'EQ',
           c_inf1    TYPE char10 VALUE 'INT0038',
           c_rec1    TYPE char10 VALUE 'RECONNET'.

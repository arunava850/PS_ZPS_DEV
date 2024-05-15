*&---------------------------------------------------------------------*
*& Include          ZFI_PC_HIER_GRP_DATA_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: setleaf,
        bapico_group.
*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_output,
         interface_name  TYPE zinterface_name,
         receiver_system TYPE zreceiver_system,
         pcgrphier       TYPE setleaf-setname,
         parentnode      TYPE zfi_ccpc_hierarchy_read-parentnode,
         childnode       TYPE zfi_ccpc_hierarchy_read-childnode,
         nodename        TYPE zfi_ccpc_hierarchy_read-nodename,
         ktext           TYPE zfi_ccpc_hierarchy_read-ktext,
         ltext           TYPE zfi_ccpc_hierarchy_read-ltext,
         verak           TYPE zfi_ccpc_hierarchy_read-verak,
         verak_user      TYPE zfi_ccpc_hierarchy_read-verak_user,
         bukrs           TYPE zfi_ccpc_hierarchy_read-bukrs,
         waers           TYPE zfi_ccpc_hierarchy_read-waers,
         txjcd           TYPE zfi_ccpc_hierarchy_read-txjcd,
         stras           TYPE zfi_ccpc_hierarchy_read-stras,
         ort01           TYPE zfi_ccpc_hierarchy_read-ort01,
         ort02           TYPE zfi_ccpc_hierarchy_read-ort02,
         pstlz           TYPE zfi_ccpc_hierarchy_read-pstlz,
         regio           TYPE zfi_ccpc_hierarchy_read-regio,
         land1           TYPE zfi_ccpc_hierarchy_read-land1,
         name1           TYPE zfi_ccpc_hierarchy_read-name1,
         name2           TYPE zfi_ccpc_hierarchy_read-name2,
         name3           TYPE zfi_ccpc_hierarchy_read-name3,
         name4           TYPE zfi_ccpc_hierarchy_read-name4,
         telf1           TYPE zfi_ccpc_hierarchy_read-telf1,
         telf2           TYPE zfi_ccpc_hierarchy_read-telf2,
         telfx           TYPE zfi_ccpc_hierarchy_read-telfx,
       END OF ty_output.
*&---------------------------------------------------------------------*
*& Global Data Declarations
*&---------------------------------------------------------------------*
DATA: gt_data   TYPE zfi_pc_hier_grp_data_dt_tab,
      gs_data   LIKE LINE OF gt_data,
      gs_out    TYPE zfi_pc_grp_data_mt1,
      gt_output TYPE TABLE OF ty_output,
      gs_output TYPE ty_output,
      gl_alv    TYPE REF TO cl_salv_table.

CONSTANTS: c_s TYPE c VALUE 'S',
           c_e TYPE c VALUE 'E',
           c_sign_i    TYPE tvarvc-sign VALUE 'I',
           c_opti_eq   TYPE tvarvc-opti VALUE 'EQ',
           c_inf1  type char10 value 'INT0050',
           c_inf2  type char10 value 'INT0051',
           c_rec1  type char10 value 'PCHI',
           c_rec2  type char10 value 'CCHI',
           c_cnt0  type c value '0',
           c_cnt1  type c value '1',
           c_cnt2  type c value '2',
           c_pc    type char4 VALUE '0106',
           c_cc    type char4 VALUE '0101'.

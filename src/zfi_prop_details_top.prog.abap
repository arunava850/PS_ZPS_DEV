*&---------------------------------------------------------------------*
*& Include          ZFI_PROP_DETAILS_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: setleaf,
        bapico_group,
        zproperty.
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

TYPES: BEGIN OF ty_rep_output,
*         interface_name  TYPE zinterface_name,
*         receiver_system TYPE zreceiver_system,
*         pcgrphier       TYPE setleaf-setname,
*         parentnode      TYPE zfi_ccpc_hierarchy_read-parentnode,
*         childnode       TYPE zfi_ccpc_hierarchy_read-childnode,
*         nodename        TYPE zfi_ccpc_hierarchy_read-nodename,
*         ktext           TYPE zfi_ccpc_hierarchy_read-ktext,

*         verak_user      TYPE zfi_ccpc_hierarchy_read-verak_user,
*         bukrs           TYPE zfi_ccpc_hierarchy_read-bukrs,
*         waers           TYPE zfi_ccpc_hierarchy_read-waers,
*         txjcd           TYPE zfi_ccpc_hierarchy_read-txjcd,

*         ort02           TYPE zfi_ccpc_hierarchy_read-ort02,

*         land1           TYPE zfi_ccpc_hierarchy_read-land1,
*         name1           TYPE zfi_ccpc_hierarchy_read-name1,
*         name2           TYPE zfi_ccpc_hierarchy_read-name2,
*         name3           TYPE zfi_ccpc_hierarchy_read-name3,
*         name4           TYPE zfi_ccpc_hierarchy_read-name4,

         legacy_property_number TYPE zproperty-legacy_property_number,
         description            TYPE zproperty-description,
         street                 TYPE zproperty-street,
         city                   TYPE zproperty-city,
         state                  TYPE zproperty-state,
         postal_code            TYPE zproperty-postal_code,
         county                 TYPE zproperty-county,
         direct_phone_no        TYPE zproperty-direct_phone_no,
         published_phone_no     TYPE zproperty-published_phone_no,
         fax_number             TYPE zproperty-fax_number,

*         ltext                  TYPE zfi_ccpc_hierarchy_read-ltext,
*         verak                  TYPE zfi_ccpc_hierarchy_read-verak,
*         stras                  TYPE zfi_ccpc_hierarchy_read-stras,
*         ort01                  TYPE zfi_ccpc_hierarchy_read-ort01,
*         pstlz                  TYPE zfi_ccpc_hierarchy_read-pstlz,
*         county                 TYPE zproperty-county,
*         regio                  TYPE zfi_ccpc_hierarchy_read-regio,
*         telf1                  TYPE zfi_ccpc_hierarchy_read-telf1,
*         telf2                  TYPE zfi_ccpc_hierarchy_read-telf2,
*         telfx                  TYPE zfi_ccpc_hierarchy_read-telfx,


         dist_prop              TYPE zfi_ccpc_hierarchy_read-childnode,
         dist_ltext             TYPE zfi_ccpc_hierarchy_read-ltext,
         dist_verak             TYPE zfi_ccpc_hierarchy_read-verak,

         dist_name1             TYPE zfi_ccpc_hierarchy_read-name1,
         dist_name4             TYPE zfi_ccpc_hierarchy_read-name4,
         dist_ast               TYPE zfi_ccpc_hierarchy_read-telf1,

         dist_telf1             TYPE zfi_ccpc_hierarchy_read-telf1,
         dist_telf2             TYPE zfi_ccpc_hierarchy_read-telf2,
         dist_telfx             TYPE zfi_ccpc_hierarchy_read-telfx,
         dist_stras             TYPE zfi_ccpc_hierarchy_read-stras,
         dist_ort01             TYPE zfi_ccpc_hierarchy_read-ort01,
         dist_regio             TYPE zfi_ccpc_hierarchy_read-regio,
         dist_pstlz             TYPE zfi_ccpc_hierarchy_read-pstlz,



         sr_dist_prop           TYPE zfi_ccpc_hierarchy_read-childnode,
         sr_ltext               TYPE zfi_ccpc_hierarchy_read-ltext,
         sr_verak               TYPE zfi_ccpc_hierarchy_read-verak,

         sr_name1               TYPE zfi_ccpc_hierarchy_read-name1,
         sr_name4               TYPE zfi_ccpc_hierarchy_read-name4,
         sr_ast                 TYPE zfi_ccpc_hierarchy_read-telf1,

         sr_telf1               TYPE zfi_ccpc_hierarchy_read-telf1,
         sr_telf2               TYPE zfi_ccpc_hierarchy_read-telf2,
         sr_telfx               TYPE zfi_ccpc_hierarchy_read-telfx,
         sr_stras               TYPE zfi_ccpc_hierarchy_read-stras,
         sr_ort01               TYPE zfi_ccpc_hierarchy_read-ort01,
         sr_regio               TYPE zfi_ccpc_hierarchy_read-regio,
         sr_pstlz               TYPE zfi_ccpc_hierarchy_read-pstlz,


         reg_prop               TYPE zfi_ccpc_hierarchy_read-childnode,
         reg_ltext              TYPE zfi_ccpc_hierarchy_read-ltext,
         reg_verak              TYPE zfi_ccpc_hierarchy_read-verak,

         reg_name1              TYPE zfi_ccpc_hierarchy_read-name1,
         reg_name4              TYPE zfi_ccpc_hierarchy_read-name4,
         reg_ast                TYPE zfi_ccpc_hierarchy_read-telf1,

         reg_telf1              TYPE zfi_ccpc_hierarchy_read-telf1,
         reg_telf2              TYPE zfi_ccpc_hierarchy_read-telf2,
         reg_telfx              TYPE zfi_ccpc_hierarchy_read-telfx,
         reg_stras              TYPE zfi_ccpc_hierarchy_read-stras,
         reg_ort01              TYPE zfi_ccpc_hierarchy_read-ort01,
         reg_regio              TYPE zfi_ccpc_hierarchy_read-regio,
         reg_pstlz              TYPE zfi_ccpc_hierarchy_read-pstlz,

         srm_prop               TYPE zfi_ccpc_hierarchy_read-childnode,
         srm_ltext              TYPE zfi_ccpc_hierarchy_read-ltext,
         srm_verak              TYPE zfi_ccpc_hierarchy_read-verak,

         srm_name1              TYPE zfi_ccpc_hierarchy_read-name1,
         srm_name4              TYPE zfi_ccpc_hierarchy_read-name4,
         srm_ast                TYPE zfi_ccpc_hierarchy_read-telf1,

         srm_telf1              TYPE zfi_ccpc_hierarchy_read-telf1,
         srm_telf2              TYPE zfi_ccpc_hierarchy_read-telf2,
         srm_telfx              TYPE zfi_ccpc_hierarchy_read-telfx,
         srm_stras              TYPE zfi_ccpc_hierarchy_read-stras,
         srm_ort01              TYPE zfi_ccpc_hierarchy_read-ort01,
         srm_regio              TYPE zfi_ccpc_hierarchy_read-regio,
         srm_pstlz              TYPE zfi_ccpc_hierarchy_read-pstlz,


         div_prop               TYPE zfi_ccpc_hierarchy_read-childnode,
         div_ltext              TYPE zfi_ccpc_hierarchy_read-ltext,
         div_verak              TYPE zfi_ccpc_hierarchy_read-verak,
         div_name1              TYPE zfi_ccpc_hierarchy_read-name1,
         div_name4              TYPE zfi_ccpc_hierarchy_read-name4,
         div_ast                TYPE zfi_ccpc_hierarchy_read-telf1,

         div_telf1              TYPE zfi_ccpc_hierarchy_read-telf1,
         div_telf2              TYPE zfi_ccpc_hierarchy_read-telf2,
         div_telfx              TYPE zfi_ccpc_hierarchy_read-telfx,
         div_stras              TYPE zfi_ccpc_hierarchy_read-stras,
         div_ort01              TYPE zfi_ccpc_hierarchy_read-ort01,

         div_regio              TYPE zfi_ccpc_hierarchy_read-regio,
         div_pstlz              TYPE zfi_ccpc_hierarchy_read-pstlz,


       END OF ty_rep_output.
*&---------------------------------------------------------------------*
*& Global Data Declarations
*&---------------------------------------------------------------------*
DATA: gt_data       TYPE zfi_pc_hier_grp_data_dt_tab,
      gs_data       LIKE LINE OF gt_data,
      gs_out        TYPE zfi_pc_grp_data_mt1,
      gt_output     TYPE TABLE OF ty_output,
      gs_output     TYPE ty_output,
      gt_rep_output TYPE TABLE OF ty_rep_output,
      gs_rep_output TYPE ty_rep_output,
      gl_alv        TYPE REF TO cl_salv_table.

CONSTANTS: c_s       TYPE c VALUE 'S',
           c_e       TYPE c VALUE 'E',
           c_sign_i  TYPE tvarvc-sign VALUE 'I',
           c_opti_eq TYPE tvarvc-opti VALUE 'EQ',
           c_inf1    TYPE char10 VALUE 'INT0050',
           c_inf2    TYPE char10 VALUE 'INT0051',
           c_rec1    TYPE char10 VALUE 'PCHI',
           c_rec2    TYPE char10 VALUE 'CCHI',
           c_cnt0    TYPE c VALUE '0',
           c_cnt1    TYPE c VALUE '1',
           c_cnt2    TYPE c VALUE '2',
           c_pc      TYPE char4 VALUE '0106',
           c_cc      TYPE char4 VALUE '0101'.

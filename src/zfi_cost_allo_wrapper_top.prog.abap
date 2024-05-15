*&---------------------------------------------------------------------*
*& Include          ZFI_COST_ALLO_WRAPPER_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: acdoca, adr6.
*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_exldata,
         descr  TYPE char40,
         skstar TYPE acdoca-racct,
         skstat TYPE acdoca-racct,
         skostl TYPE acdoca-rcntr,
         sndprt TYPE /sapce/iuru_bpos-benperc,
         sprctr TYPE cepc-prctr,
         ssegmt TYPE fb_segment,
         samnt  TYPE acdoca-hsl,
         rkstar TYPE coep-kstar,
         rccgrp TYPE char15,
         rkostl TYPE coep-kostl,
         rpcgrp TYPE char15,
         rprctr TYPE cepc-prctr,
         rcci   TYPE string,
         rccx   TYPE string,
         rsegmt TYPE fb_segment,
         recprt TYPE /sapce/iuru_bpos-benperc,
         nouni  TYPE char20,
         ramnt  TYPE acdoca-hsl,
         scena  TYPE char4,
         rrksta TYPE coep-kstar,
         stagr  TYPE faglskf_pn-stagr,
         factor TYPE char40,
       END OF ty_exldata.

TYPES: BEGIN OF ty_redirect,
         scena  TYPE zfi_costallored-scena,
         skostl TYPE zfi_costallored-skostl,
         rkostl TYPE zfi_costallored-rkostl,
       END OF ty_redirect.

TYPES: BEGIN OF ty_kostl_add,
         kostl TYPE csks-kostl,
       END OF ty_kostl_add.

TYPES: BEGIN OF ty_output,
         descr    TYPE char40,
         sgl      TYPE coep-kstar,
         scc      TYPE csks-kostl,
         sndprt   TYPE /sapce/iuru_bpos-benperc,
         sprctr   TYPE cepc-prctr,
         ssegmt   TYPE fb_segment,
         samnt    TYPE acdoca-hsl,
         rgl      TYPE coep-kstar,
         rccgrp   TYPE char15,
         rcc      TYPE coep-kostl,
         rpcgrp   TYPE char15,
         rprctr   TYPE cepc-prctr,
         rsegmt   TYPE fb_segment,
         recprt   TYPE /sapce/iuru_bpos-benperc,
         nouni    TYPE char4,
         ramnt    TYPE acdoca-hsl,
         redirect TYPE char4,
         stagr    TYPE faglskf_pn-stagr,
         factor   TYPE char40,
         gjahr    TYPE acdoca-ryear,
         monat    TYPE acdoca-poper,
         blart    TYPE acdoca-blart,
         rbukrs   TYPE acdoca-rbukrs,
         belnr    TYPE acdoca-belnr,
         bvorg    TYPE bkpf-bvorg,
         error    TYPE string,
         usnam    TYPE bkpf-usnam,
         cpudt    TYPE bkpf-cpudt,
         cputm    TYPE bkpf-cputm,
       END OF ty_output.

TYPES: BEGIN OF ty_ccbu,
         kostl TYPE csks-kostl,
         bukrs TYPE csks-bukrs,
         prctr TYPE csks-prctr,
         datbi TYPE csks-datbi,
         datab TYPE csks-datab,
       END OF ty_ccbu.

TYPES: BEGIN OF ty_pcsg,
         prctr   TYPE csks-prctr,
         segment TYPE cepc-segment,
       END OF ty_pcsg.

TYPES: BEGIN OF ty_bvorg,
         bvorg TYPE bkpf-bvorg,
       END OF ty_bvorg.

TYPES: BEGIN OF ty_acdoca,
         rldnr  TYPE acdoca-rldnr,
         rbukrs TYPE acdoca-rbukrs,
         gjahr  TYPE acdoca-gjahr,
         belnr  TYPE acdoca-belnr,
         docln  TYPE acdoca-docln,
         racct  TYPE acdoca-racct,
         rcntr  TYPE acdoca-rcntr,
         hsl    TYPE acdoca-hsl,
       END OF ty_acdoca.

DATA: gv_amt            TYPE acdoca-hsl,
      gv_err_msg        TYPE char100,
      gv_mode           TYPE char10,
      gv_nname          TYPE bapico_group-groupname,
      gs_output         TYPE ty_output,
      gt_output         TYPE TABLE OF ty_output,
      gt_bvorg          TYPE TABLE OF ty_bvorg,
      gs_bvorg          TYPE ty_bvorg,
      gt_output_tmp     TYPE TABLE OF ty_output,
      gl_alv            TYPE REF TO cl_salv_table,
      gt_ccbukrs        TYPE TABLE OF ty_ccbu,
      gs_ccbukrs        TYPE ty_ccbu,
      gt_pcsg           TYPE TABLE OF ty_pcsg,
      gs_pcsg           TYPE ty_pcsg,
      gt_kostl_i        TYPE TABLE OF ty_kostl_add,
      gt_kostl_x        TYPE TABLE OF ty_kostl_add,
      gs_kostl          TYPE ty_kostl_add,
      gs_header         TYPE bapiache09,
      gs_gl             TYPE bapiacgl09,
      gt_gl             TYPE TABLE OF bapiacgl09,
      gs_amt            TYPE bapiaccr09,
      gt_amt            TYPE TABLE OF bapiaccr09,
      gs_return         TYPE bapiret2,
      gt_return         TYPE TABLE OF bapiret2,
      gt_file           TYPE filetable,
      gs_file           LIKE LINE OF gt_file,
      gv_rc             TYPE i,
      gv_file           TYPE string,
      gt_data           TYPE TABLE OF ty_exldata,
      gs_data           TYPE ty_exldata,
      gt_redirect       TYPE TABLE OF ty_redirect,
      gs_redirect       TYPE ty_redirect,
      gt_salv_not_found TYPE REF TO cx_salv_not_found,
      gt_row            TYPE TABLE OF zfi_ccpc_hierarchy_read,
      gs_row            TYPE zfi_ccpc_hierarchy_read,
      gt_nodes          TYPE TABLE OF bapiset_hier,
      gt_data_doc       TYPE TABLE OF ty_acdoca,
      gs_data_doc       TYPE ty_acdoca,
      gr_racct          TYPE RANGE OF acdoca-racct,
      gr_racct_ska1     TYPE RANGE OF acdoca-racct,
      grs_racct         LIKE LINE OF gr_racct,
      gr_rcntr          TYPE RANGE OF acdoca-rcntr,
      grs_rcntr         LIKE LINE OF gr_rcntr,
      gv_data           TYPE c.

FIELD-SYMBOLS : <gt_data> TYPE STANDARD TABLE .

CONSTANTS: c_s       TYPE c VALUE 'S',
           c_e       TYPE c VALUE 'E',
           c_sign_i  TYPE tvarvc-sign VALUE 'I',
           c_opti_bt TYPE tvarvc-opti VALUE 'BT'.

*&---------------------------------------------------------------------*
*& Include          ZFI_SKF_RPT_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Tables Declarations
*&---------------------------------------------------------------------*
TABLES: faglskf_pn.
*&---------------------------------------------------------------------*
*& Types Declarations
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_fagl,
         stagr      TYPE  faglskf_pn-stagr,
         date_from  TYPE  faglskf_pn-date_from,
         docnr      TYPE  faglskf_pn-docnr,
         docln      TYPE  faglskf_pn-docln,
         date_to    TYPE  faglskf_pn-date_to,
         rbukrs     TYPE  faglskf_pn-rbukrs,
         rcntr      TYPE  faglskf_pn-rcntr,
         prctr      TYPE  faglskf_pn-prctr,
         rfarea     TYPE  faglskf_pn-rfarea,
         rbusa      TYPE  faglskf_pn-rbusa,
         kokrs      TYPE  faglskf_pn-kokrs,
         segment    TYPE  faglskf_pn-segment,
         activ      TYPE  faglskf_pn-activ,
         obart      TYPE  faglskf_pn-obart,
         runit      TYPE  faglskf_pn-runit,
         logsys     TYPE  faglskf_pn-logsys,
         rrcty      TYPE  faglskf_pn-rrcty,
         rvers      TYPE  faglskf_pn-rvers,
         msl        TYPE  faglskf_pn-msl,
         refdocnr   TYPE  faglskf_pn-refdocnr,
         canc_docnr TYPE  faglskf_pn-canc_docnr,
         usnam      TYPE  faglskf_pn-usnam,
         timestamp  TYPE  faglskf_pn-timestamp,
         delta_ind  TYPE  faglskf_pn-delta_ind,
       END OF ty_fagl.

DATA: gt_output TYPE TABLE OF ty_fagl,
      gs_output TYPE ty_fagl,
      gl_alv    TYPE REF TO cl_salv_table.

CONSTANTS: c_s TYPE c VALUE 'S',
           c_e TYPE c VALUE 'E'.

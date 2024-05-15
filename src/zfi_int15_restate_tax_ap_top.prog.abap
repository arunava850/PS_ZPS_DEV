*&---------------------------------------------------------------------*
*& Include          ZFI_INT15_RESTATE_TAX_AP_TOP
*&---------------------------------------------------------------------*
TYPES : BEGIN OF ty_file,
          apchkrno(110)    TYPE c,
          exportno(40)     TYPE c,
          appmntmhd(20)    TYPE c,
          state(30)        TYPE c,
          jurisdict(80)    TYPE c,
          aptxbillid(90)   TYPE c,
          txbillglno(100)  TYPE c,
          taxyear(10)      TYPE c,
          apreqdate(10)    TYPE c,
          apinstlmntno(10) TYPE c,
          aptaxtyp(10)     TYPE c,
          appyeid(100)     TYPE c,
          adrsbkvndr(75)   TYPE c,
          apvndrnam(50)    TYPE c,
          prprtyid(225)    TYPE c,
          parcel(150)      TYPE c,
          apnetpyamnt(20)  TYPE c,
          gldate(10)       TYPE c,
          txbillno(80)     TYPE c,
          usecod11(10)     TYPE c,
        END OF ty_file.

DATA : gt_file TYPE TABLE OF ty_file,
       gs_file TYPE ty_file,
       gt_data TYPE ZFIT_INT15_REST_TAX_AP,
       gs_data TYPE ZFI_INT15_REST_TAX_AP.

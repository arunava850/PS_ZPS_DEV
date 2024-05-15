*&---------------------------------------------------------------------*
*& Include          ZFI_GL_DAILY_TRANSX_TOP
*&---------------------------------------------------------------------*

TABLES : acdoca , bkpf , lfa1.

TYPES : BEGIN OF ty_final,
*          interface_name(10) TYPE c,
*          receiver_system(4) TYPE c,
          rldnr    TYPE fins_ledger,
          rbukrs   TYPE bukrs,
          gjahr    TYPE gjahr,
          belnr    TYPE belnr_d,
          prctr    TYPE prctr,
          rcntr    TYPE kostl,
          racct    TYPE racct,
          cpudt    TYPE datum,
          budat    TYPE datum,
          poper    TYPE poper,
          rhcur    TYPE fins_currh,
          drcrk    TYPE shkzg,
          hsl      TYPE fins_vhcur12,
          blart    TYPE blart,
          xblnr    TYPE xblnr1,
          bktxt    TYPE bktxt,
          sgtxt    TYPE sgtxt,
          zuonr    TYPE dzuonr,
          segment  TYPE fb_segment,
          lifnr    TYPE lifnr,
          anln1    TYPE anln1,
          anln2    TYPE anln2,
          anbwa    TYPE anbwa,
          bwasl_pn TYPE bwasl,
          bldat    TYPE bldat, "KDURAI 18/03/2024
          NAME1    TYPE NAME1_GP,
          AWREF    TYPE AWREF,
*        SGTXT    TYPE SGTXT,
          DOCLN    TYPE DOCLN6,
        END OF ty_final.

DATA : gt_final TYPE TABLE OF ty_final,
       gs_final TYPE ty_final,
       lv_date  TYPE sy-datum,
       gs_out   TYPE zco_fi_daily_transx_mt,
       gt_data  TYPE zco_st_data_tab,
       gs_data  LIKE LINE OF gt_data.


*CONSTANTS : lc_name TYPE rvari_vnam VALUE 'ZFI_PAYMENT_WC_UPDT'.

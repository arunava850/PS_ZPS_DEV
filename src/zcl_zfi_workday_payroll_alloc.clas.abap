class ZCL_ZFI_WORKDAY_PAYROLL_ALLOC definition
  public
  create public .

public section.

  interfaces ZII_ZFI_WORKDAY_PAYROLL_ALLOC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZFI_WORKDAY_PAYROLL_ALLOC IMPLEMENTATION.


  METHOD zii_zfi_workday_payroll_alloc~post.
*** **** INSERT IMPLEMENTATION HERE **** ***
    DATA: lt_data    TYPE zfit_workday_payroll_alloc,
          ls_data    TYPE zfis_workday_payroll_alloc,
          lt_BAPIRET TYPE bapiret2_t,
          ls_BAPIRET TYPE bapiret2.

    LOOP AT input-zfi_workday_payroll_alloc_mt-zdata_payroll INTO DATA(ls_data_payroll).

      ls_data-counter = ls_data_payroll-zcounter.
      ls_data-bukrs = ls_data_payroll-zbukrs .
      ls_data-bktxt = ls_data_payroll-zbktxt .
      ls_data-xblnr = ls_data_payroll-zxblnr .

      REPLACE ALL OCCURRENCES OF '-' IN ls_data_payroll-zbudat WITH space.
      CONDENSE ls_data_payroll-zbudat.
      ls_data-budat = ls_data_payroll-zbudat .

      REPLACE ALL OCCURRENCES OF '-' IN ls_data_payroll-zbldat WITH space.
      CONDENSE ls_data_payroll-zbldat.
      ls_data-bldat = ls_data_payroll-zbldat .

      ls_data-hkont = ls_data_payroll-zhkont .
      ls_data-dmbtr = ls_data_payroll-zdmbtr .
      ls_data-zuonr = ls_data_payroll-zzuonr .
*      ls_data-kostl = ls_data_payroll-zkostl .
      if ls_data_payroll-zkostl is not initial.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ls_data_payroll-zkostl
          IMPORTING
            output = ls_data-kostl
          .
      endif.
      ls_data-prctr = ls_data_payroll-zprctr .
      ls_data-sgtxt = ls_data_payroll-zsgtxt .

      APPEND ls_data TO lt_data.
      CLEAR ls_data.

    ENDLOOP.
    IF sy-subrc = 0.

      CALL FUNCTION 'ZFI_WORKDAY_PAYROLL_ALLOC'
        EXPORTING
          et_data  = lt_data
        IMPORTING
          bapiret2 = lt_BAPIRET.


    ENDIF.



  ENDMETHOD.
ENDCLASS.

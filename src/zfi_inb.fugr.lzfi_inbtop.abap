FUNCTION-POOL ZFI_INB.                      "MESSAGE-ID ..

* INCLUDE LZFI_INBD...                       " Local class definition



TYPES : BEGIN OF ty_file,
          zusr_id(10)      TYPE c,
          zbatch(15)       TYPE c,
          ztran_no(22)     TYPE c,
          zline_no(7)      TYPE c,
          zsp              TYPE c,
          zco(5)           TYPE c,
          zdescriptn(30)   TYPE c,
          zdescriptn2(30)  TYPE c,
          znew             TYPE c,
          zremark(30)      TYPE c,
          zremark2(30)     TYPE c,
          zasset_co_obj(6) TYPE c,
          zsset_co_sub(8)  TYPE c,
          zacc_cls(3)      TYPE c,
          zst(3)           TYPE c,
          zafe_no(12)      TYPE c,
          zuniqueid(15)    TYPE c,
          zadrs_no(8)      TYPE c,
          zinvoice(25)     TYPE c,
         zinv_date(10)     TYPE c,
          zgross_amnt(15)  TYPE c,
          ztax(15)         TYPE c,
          ztax2(15)        TYPE c,
          zdat_acq(10)     TYPE c,
          zasset_no(8)     TYPE c,
          zusr_code(3)     TYPE c,
          zusr_date(10)    TYPE c,
          zusr_amount(15)  TYPE c,
          zusr_no(8)       TYPE c,
          zusr_ref(15)     TYPE c,
          zusrid(10)       TYPE c,
          zprog(10)        TYPE c,
          zwork_stn(10)    TYPE c,
          zdate_upd(10)    TYPE c,
          ztime_upd(6)     TYPE c,
        END OF ty_file.

DATA : gs_data TYPE zfis_ramp_acc_pay,
       gt_data TYPE zfitt_ramp_acc_pay,
       gt_capex TYPE zfitt_ramp_acc_pay,
       gt_opex TYPE zfitt_ramp_acc_pay,
       gt_bapiret2 TYPE TABLE OF BAPIRET2.

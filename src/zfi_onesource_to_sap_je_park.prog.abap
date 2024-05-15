*&---------------------------------------------------------------------*
*& Report ZFI_ONESOURCE_TO_SAP_JE_PARK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_onesource_to_sap_je_park NO STANDARD PAGE HEADING
                                    LINE-COUNT 58(0)
                                    MESSAGE-ID zfi_msgs
                                    LINE-SIZE 225.

TYPE-POOLS:truxs, slis, <icon>.
TABLES : bseg.
TYPES : BEGIN OF ty_header,
          binder_id               TYPE char6,
          perno                   TYPE char2,
          pername                 TYPE char16,
          stateid                 TYPE char2,
          state_name              TYPE char30,
          return_name             TYPE c LENGTH 50,

          Gross_Sales             TYPE char15,               "Not used
          Exemptions              TYPE char15,               "Not used
          State_Taxable_Sales     TYPE char15,               "Not used
          State_Taxable_Purchases TYPE char15,               "Not used
          State_Sales_Tax         TYPE char15,               "Not used
          State_Use_Tax           TYPE char15,               "Not used
          State_Total_Tax         TYPE char15,               "Not used
          County_Sales_Tax        TYPE char15,               "Not used
          County_Use_Tax          TYPE char15,               "Not used
          County_Total_Tax        TYPE char15,               "Not used
          Local_Sales_Tax         TYPE char15,               "Not used
          Local_Use_Tax           TYPE char15,               "Not used
          Local_Total_Tax         TYPE char15,               "Not used
          Transit_Tax             TYPE char15,               "Not used
          Total_Sales_Tax         TYPE char15,               "Not used
          Total_Use_Tax           TYPE char15,               "Not used
          total_tax               TYPE char15,
          Total_Tax_Rentals       TYPE char15,               "Not used
          Total_Tax_Rental_All    TYPE char15,               "Not used
          Adjustments             TYPE char15,               "Not used
          Prepayments             TYPE char15,               "Not used
          discounts               TYPE char15,
          penalties               TYPE char15,
          interest                TYPE char15,
          net_tax_due             TYPE char15,
          Tax_Collected           TYPE char15,               "Not used
          amount_chk              TYPE char15,
          count                   TYPE i,
          variance_amount         TYPE dmbtr,
        END OF ty_header,

        BEGIN OF ty_item,
          bukrs        TYPE bukrs,
          binder_id    TYPE char05,
          tax          TYPE dmbtr,                     " bapidoccur,                  "        Use DMBTR to avoid rounding/matching vendor  and gl lines totals
          tax_location TYPE char10,
          col_level    TYPE char20,"char10, " KDURAI 05/02/2024
          city         TYPE char30,
          vendor_num   TYPE char02,
        END OF ty_item,

        BEGIN OF ty_acc_doc,                                         "acct. doc. details
          stateid      TYPE char2,
          return_name  TYPE c LENGTH 50,
          bukrs        TYPE bukrs,
          col_level    TYPE char20,"char10, " KDURAI 05/02/2024,      "Collecting Authority: STATE/CITY/COUNTY...
          city         TYPE char30,                                   "Name of STATE/CITY/COUNTY...
          vendor_num   TYPE char02,
          tax_location TYPE char10,                                   "Profit Center
*          vendor       TYPE elifn,
          tax          TYPE dmbtr, bapidoccur,                               " Amount in summary file
*          doc_amt      TYPE bapidoccur,                               " Amount in Detail file for each acct. doc.
        END OF ty_acc_doc,

        BEGIN OF ty_final,
          icon   TYPE char4,
          belnr  TYPE belnr_d,
          bukrs  TYPE bukrs,
          gjahr  TYPE gjahr,
*          inv  TYPE re_belnr,
          messg  TYPE char100,
          docnum TYPE edi_docnum,
        END OF ty_final.

DATA      : recordi(1000)       TYPE c,
            wa_record_hdr(1000) TYPE c,
            lv_string           TYPE string,
            wa_file_hdr         TYPE ty_header,
            wa_file_item        TYPE ty_item,
*            wa_file_item        TYPE  ty_acc_doc,
            wa_file_item_new    TYPE ty_item,
            it_header           TYPE STANDARD TABLE OF ty_header,
            it_acc_doc          TYPE STANDARD TABLE OF ty_acc_doc,
            wa_acc_doc          TYPE                   ty_acc_doc,
            gt_final            TYPE TABLE OF ty_final,
            gt_fcat             TYPE slis_t_fieldcat_alv,
            gw_fcat             TYPE slis_fieldcat_alv,
            gw_final            TYPE ty_final,
            it_item             TYPE STANDARD TABLE OF ty_item,
            wa_item             TYPE                   ty_item,
            it_item_2           TYPE STANDARD TABLE OF ty_item.

DATA: lv_city           TYPE ty_item-city.

CONSTANTS : htab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
            gc_x TYPE c VALUE 'X'.

*-------------------------  SELECTION-SCREEN  -------------------------*
SELECTION-SCREEN: SKIP 1.
SELECTION-SCREEN  BEGIN OF BLOCK zblk1 WITH FRAME.
  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS: p_file AS CHECKBOX.
    SELECTION-SCREEN COMMENT 3(29) TEXT-751 FOR FIELD p_filsum.
    PARAMETERS: p_filsum LIKE ifibl_aux_fields-allgunix.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS: p_fildet AS CHECKBOX.
    SELECTION-SCREEN COMMENT 3(29) TEXT-752 FOR FIELD p_fildet.
    PARAMETERS: p_fildet LIKE ifibl_aux_fields-allgunix.             "path of detail file
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN: BEGIN OF LINE.
    SELECTION-SCREEN: COMMENT 3(27) TEXT-910 FOR FIELD p_park.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: p_park AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN: END OF LINE.

  SELECTION-SCREEN: BEGIN OF LINE.
    SELECTION-SCREEN: COMMENT 3(29) TEXT-911 FOR FIELD p_archv.
    PARAMETERS: p_archv AS CHECKBOX DEFAULT ''.
  SELECTION-SCREEN: END OF LINE.

  SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN  END OF BLOCK zblk1.

SELECTION-SCREEN BEGIN OF BLOCK z1 WITH FRAME .
  PARAMETERS : gl_tax LIKE bseg-hkont.
  PARAMETERS : gl_disc LIKE bseg-hkont.
  PARAMETERS : gl_pen LIKE bseg-hkont.
  PARAMETERS : gl_int LIKE bseg-hkont.
*  PARAMETERS : cs_disc LIKE bseg-kostl.
*  PARAMETERS : pc_disc LIKE bseg-prctr.
  PARAMETERS : cs_disc LIKE bseg-kostl. " KDURAI 06/05/2024
  PARAMETERS : cs_pen LIKE bseg-kostl.
  PARAMETERS : cs_int LIKE bseg-kostl.
*  SELECT-OPTIONS: pc_disc FOR bseg-prctr,
*                  cs_pen FOR bseg-kostl,
*                  cs_int FOR bseg-kostl.
SELECTION-SCREEN END OF BLOCK z1.

*-------------------------  INITIALIZATION   --------------------------*
INITIALIZATION.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
         ID 'BUKRS' DUMMY
         ID 'ACTVT' FIELD '01'
         ID 'ACTVT' FIELD '02'.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE s010 DISPLAY LIKE 'E' RAISING authorization_missing.
    LEAVE PROGRAM.
  ENDIF.

  "F4 help for summary file

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filsum.
  PERFORM file_open_summ.

  "F4 help for detail file

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fildet.
  PERFORM file_open_detail.
*----------------------  AT SELECTION-SCREEN  -------------------------*
AT SELECTION-SCREEN.

  IF p_filsum EQ ' ' OR p_fildet EQ ' '.
    MESSAGE e022.
  ENDIF.


AT SELECTION-SCREEN OUTPUT.


START-OF-SELECTION.

  PERFORM b_upload_data.
  IF p_park IS NOT INITIAL.
    PERFORM b_load_park_doc.
    IF gt_final IS  NOT INITIAL .
      PERFORM b_display_alv.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
*       FORM B_UPLOAD_DATA                                            *
*---------------------------------------------------------------------*
FORM b_upload_data.
  DATA: lv_tax_file TYPE char20,
        lv_amount   TYPE bapidoccur.
  DATA: lv_archive TYPE rlgrap-filename,
        lv_str     TYPE string.
  DATA: wa_file_item TYPE  ty_item.

  IF  p_filsum IS NOT INITIAL.
*** Summary File
    OPEN DATASET p_filsum FOR INPUT IN TEXT MODE
           ENCODING DEFAULT WITH SMART LINEFEED.
    IF sy-subrc = 0.
      READ DATASET p_filsum INTO wa_record_hdr.
      WHILE sy-subrc EQ 0.
*           SPLIT recordi AT ctab INTO wa_file1-binder_id
        wa_file_hdr-binder_id = wa_record_hdr+0(6).
        wa_file_hdr-perno     = wa_record_hdr+6(2).
        wa_file_hdr-pername       = wa_record_hdr+8(16).
        wa_file_hdr-stateid       = wa_record_hdr+24(2).
        wa_file_hdr-state_name    = wa_record_hdr+26(30).
        wa_file_hdr-return_name   = wa_record_hdr+56(50).

        CLEAR lv_amount.
        wa_file_hdr-total_tax_rental_all     = wa_record_hdr+376(15).
        lv_amount = wa_file_hdr-total_tax_rental_all.
        lv_amount = lv_amount / 100.
        wa_file_hdr-total_tax_rental_all = lv_amount.
*        CONCATENATE wa_file_hdr-total_tax_rental_all+1(12) '.' wa_file_hdr-total_tax_rental_all+13(2) into wa_file_hdr-total_tax_rental_all.

        CLEAR lv_amount.
        wa_file_hdr-discounts     = wa_record_hdr+421(15).
        lv_amount = wa_file_hdr-discounts.
        lv_amount = lv_amount / 100.
        wa_file_hdr-discounts = lv_amount.
*        CONCATENATE wa_file_hdr-discounts+1(12) '.' wa_file_hdr-discounts+13(2) into wa_file_hdr-discounts.

        CLEAR lv_amount.
        wa_file_hdr-penalties     = wa_record_hdr+436(15).
        lv_amount = wa_file_hdr-penalties.
        lv_amount = lv_amount / 100.
        wa_file_hdr-penalties = lv_amount.
*        CONCATENATE wa_file_hdr-penalties+1(12) '.' wa_file_hdr-penalties+13(2) into wa_file_hdr-penalties.

        CLEAR lv_amount.
        wa_file_hdr-interest      = wa_record_hdr+451(15).
        lv_amount = wa_file_hdr-interest.
        lv_amount = lv_amount / 100.
        wa_file_hdr-interest = lv_amount.
*        CONCATENATE wa_file_hdr-interest+1(12) '.' wa_file_hdr-interest+13(2) into wa_file_hdr-interest.

        CLEAR lv_amount.
        wa_file_hdr-net_tax_due   = wa_record_hdr+466(15).
        lv_amount = wa_file_hdr-net_tax_due.
        lv_amount = lv_amount / 100.
        wa_file_hdr-net_tax_due = lv_amount.
*        CONCATENATE wa_file_hdr-net_tax_due+1(12) '.' wa_file_hdr-net_tax_due+13(2) into wa_file_hdr-net_tax_due.

        CLEAR lv_amount.
        wa_file_hdr-amount_chk    = wa_record_hdr+496(15).
        lv_amount = wa_file_hdr-amount_chk.
        lv_amount = lv_amount / 100.
        wa_file_hdr-amount_chk = lv_amount.
*        CONCATENATE wa_file_hdr-amount_chk+1(12) '.' wa_file_hdr-amount_chk+13(2) into wa_file_hdr-amount_chk.

        APPEND wa_file_hdr TO it_header.
        CLEAR:wa_file_hdr.
        READ DATASET p_filsum INTO wa_record_hdr.
      ENDWHILE.
      CLOSE DATASET p_filsum.
    ELSE.
      MESSAGE e002 WITH p_filsum.
    ENDIF.

*** Detail File
    OPEN DATASET p_fildet FOR INPUT IN TEXT MODE
       ENCODING DEFAULT WITH SMART LINEFEED.
    IF sy-subrc = 0.
      CLEAR : recordi,lv_string.
      READ DATASET p_fildet INTO recordi.
      WHILE sy-subrc EQ 0.
        CLEAR lv_tax_file.

        " If text commas within double quotes, then those commas should be removed
        IF recordi CP '*"*,*"*'.
          SPLIT recordi AT '"' INTO DATA(lv_str1) DATA(lv_str2) DATA(lv_str3).
          REPLACE  ALL OCCURRENCES OF ',' IN lv_str2 WITH space.
          CLEAR recordi.
          CONCATENATE lv_str1 lv_str2 lv_str3 into recordi.
        ENDIF.

        SPLIT recordi AT ',' INTO lv_string "Business Location
                                   lv_string "Tax Level
                                   lv_string "Tax Authority
                                   lv_string "Tax Type
                                   lv_string "Tax Desc
                                   lv_string "Cal Code
                                   lv_string "Invoice
                                   lv_string "Item
                                   lv_string "Gross
                                   lv_string "Total Exempt
                                   lv_string "Taxable
                                   lv_string "Rate
                                   lv_tax_file                 " wa_file1-tax  "Tax
                                   lv_string "Tax Collected
                                   wa_file_item-tax_location  "Tax location
                                   lv_string "Tax Area
                                   wa_file_item-col_level " Collectiong Level
                                   wa_file_item-city " Collecting Authority
                                   lv_string " Tax Code
                                   lv_string " Sourcing
                                   wa_file_item-binder_id " Department Code
                                   wa_file_item-vendor_num " Vendor Code
                                   lv_string "  Customer Number
                                   lv_string " Memo Desc
                                   lv_string. "Tax Area Code
        IF lv_tax_file CA '1234567890,'.
          wa_file_item-tax = lv_tax_file .
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_file_item-tax_location
          IMPORTING
            output = wa_file_item-tax_location.

        APPEND wa_file_item TO it_item.
        CLEAR:wa_file_item.
        READ DATASET p_fildet INTO recordi.
      ENDWHILE.
      CLOSE DATASET p_fildet.
    ELSE.
      MESSAGE e002 WITH p_fildet.
    ENDIF.
  ENDIF.

  "Archive File - Summary file
  IF  p_archv IS NOT INITIAL
  AND it_header IS NOT INITIAL.
    CLEAR : lv_archive.
    lv_archive = p_filsum.
    REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.

    OPEN DATASET p_filsum FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    OPEN DATASET lv_archive FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    DO.
      CLEAR lv_str.
      READ DATASET p_filsum INTO lv_str.
      IF sy-subrc EQ 0.
        TRANSFER lv_str TO lv_archive.
      ELSE.
        IF lv_str IS NOT INITIAL.
          TRANSFER lv_str TO lv_archive.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_filsum.
    CLOSE DATASET lv_archive.

    DELETE DATASET p_filsum.

  ENDIF.

  "Archive File - detail
  IF  p_archv IS NOT INITIAL
  AND it_item IS NOT INITIAL.
    CLEAR : lv_archive.
    lv_archive = p_fildet.
    REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.

    OPEN DATASET p_fildet FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    OPEN DATASET lv_archive FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    DO.
      CLEAR lv_str.
      READ DATASET p_fildet INTO lv_str.
      IF sy-subrc EQ 0.
        TRANSFER lv_str TO lv_archive.
      ELSE.
        IF lv_str IS NOT INITIAL.
          TRANSFER lv_str TO lv_archive.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_fildet.
    CLOSE DATASET lv_archive.

    DELETE DATASET p_fildet.

  ENDIF.

ENDFORM.                    "B_UPLOAD_DATA

*---------------------------------------------------------------------*
*       FORM B_VALIDATE_DATA.                                         *
*---------------------------------------------------------------------*
************************************************************************
*&---------------------------------------------------------------------*
*& Form B_LOAD_PARK_DOC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM b_load_park_doc .
  DATA : gs_documentheader         TYPE bapiache09,
         gs_documentheader_add_doc TYPE bapiache09,
         zitemno                   TYPE posnr_acc,
         zitemno_pay               TYPE posnr_acc,
         zitemno_currency          TYPE posnr_acc,
         lv_count                  TYPE i,
         lv_hdr_total              TYPE dmbtr,               " bapidoccur,
         lv_itm_total              TYPE dmbtr,               " bapidoccur,
         lv_itm_total_2            TYPE dmbtr,               " bapidoccur,
         lv_var_vend_line          TYPE dmbtr,
         lv_var_gl_line            TYPE dmbtr,
         lv_variance_amount        TYPE bapidoccur,
         lv_tax                    TYPE bapidoccur,
         lv_vend_amt               TYPE bapidoccur,
         lv_discount               TYPE bapidoccur,
         lv_interest               TYPE bapidoccur,
         lv_penalties              TYPE bapidoccur,
         lt_accountgl              TYPE STANDARD TABLE OF  bapiacgl09,
         lt_accountgl_add_doc      TYPE STANDARD TABLE OF  bapiacgl09,
         ls_accountgl              TYPE   bapiacgl09,
         lt_accountpayable         TYPE STANDARD TABLE OF  bapiacap09,
         lt_accountpayable_add_doc TYPE STANDARD TABLE OF  bapiacap09,
         ls_accountpayable         TYPE   bapiacap09,
         lt_currencyamt            TYPE STANDARD TABLE OF  bapiaccr09,
         lt_currencyamt_add_doc    TYPE STANDARD TABLE OF  bapiaccr09,
         ls_currencyamt            TYPE   bapiaccr09,
         lt_return                 TYPE STANDARD TABLE OF  bapiret2,
         lt_withtx                 TYPE TABLE OF bapiacwt09,
         lv_docnum                 TYPE edi_docnum,
         lv_hdr_amount             TYPE bapidoccur,
         lv_line_amount            TYPE bapidoccur,
         lv_error                  TYPE c,
*         lv_city           TYPE ty_item-city,
         lv_where_cond             TYPE string,
         lv_vendor_where_cond      TYPE string,
         lwa_header                TYPE ty_header,
         lv_flag_dis_pen_int       TYPE char1.                       "indicator for discount, penalty and interest

  IF it_header IS NOT INITIAL AND
    it_item IS NOT INITIAL.

    SELECT zcode,
           zsapcode
    FROM zfi_state_lookup
    INTO TABLE @DATA(it_state).
    SORT it_state BY zcode.

    SELECT  state,               "region,
            county,
            city1,
            pvt_agency,
            vendor
    FROM zfi_vendor_lukup
    INTO TABLE @DATA(it_vendor).
*    DELETE it_header INDEX 1.
    DELETE it_item INDEX 1.
    SORT it_header BY binder_id stateid.
    SORT it_item BY  vendor_num tax_location.

    "Fetch ProfitCenter/company code  data
    IF it_item IS NOT INITIAL.
      SELECT prctr, bukrs
             FROM cepc_bukrs
             INTO TABLE @DATA(lt_cepc_bukrs)
      FOR ALL ENTRIES IN @it_item
      WHERE prctr = @it_item-tax_location.
    ENDIF.
    SORT lt_cepc_bukrs BY prctr bukrs.
    DELETE ADJACENT DUPLICATES FROM lt_cepc_bukrs COMPARING ALL FIELDS.
    DATA(lt_bukrs) = lt_cepc_bukrs.
    SORT lt_bukrs BY bukrs.
    DELETE ADJACENT DUPLICATES FROM lt_bukrs COMPARING bukrs.

*>> BOC KDURAI 06/05/2024
    "discount comp code
*    SELECT SINGLE bukrs INTO @DATA(lv_disc_bukrs) FROM cepc_bukrs  WHERE prctr = @pc_disc.
    SELECT SINGLE bukrs INTO @DATA(lv_disc_bukrs) FROM csks  WHERE kostl = @cs_disc.
*<< EOC KDURAI 06/05/2024

*** update count for each state code
    CLEAR: lv_count, lv_hdr_total.
    LOOP AT it_header ASSIGNING FIELD-SYMBOL(<ls_header>).

      CLEAR : lv_count.
      LOOP AT it_header TRANSPORTING NO FIELDS
        WHERE binder_id = <ls_header>-binder_id
                        AND stateid = <ls_header>-stateid.
        lv_count = lv_count + 1.

      ENDLOOP.
      <ls_header>-count = lv_count.
      lv_hdr_total = lv_hdr_total +  <ls_header>-total_tax_rental_all.

    ENDLOOP.

***Update company code in item file
    CLEAR lv_itm_total.
    LOOP AT it_item INTO wa_file_item.
      READ TABLE lt_cepc_bukrs INTO DATA(ls_cepc_bukrs) WITH KEY prctr =  wa_file_item-tax_location.
      IF sy-subrc = 0.
        wa_file_item-bukrs = ls_cepc_bukrs-bukrs.
      ENDIF.

      MODIFY it_item  FROM wa_file_item TRANSPORTING bukrs.
      lv_itm_total = lv_itm_total + wa_file_item-tax.
    ENDLOOP.
    SORT it_item BY bukrs.

    "Collect the item data
    SORT it_item BY binder_id vendor_num col_level city bukrs tax_location tax.
    LOOP AT it_item INTO DATA(lw_item_2).
      COLLECT lw_item_2 INTO it_item_2.
    ENDLOOP.
    IF sy-subrc = 0.
      REFRESH it_item.
      it_item = it_item_2.
    ENDIF.
*
**** accounting document data
    LOOP AT it_header INTO lwa_header.
      CLEAR: lv_city, lv_where_cond.
      wa_acc_doc-stateid      = lwa_header-stateid.
      wa_acc_doc-return_name  = lwa_header-return_name.
      READ TABLE it_state INTO DATA(wa_state) WITH KEY zcode = lwa_header-stateid.
      IF sy-subrc <> 0.
        CLEAR wa_state.
      ENDIF.

      IF lwa_header-state_name CS 'LOCALS'.                               "CITY, COUNTY, PVT_AGENCY
        SPLIT lwa_header-return_name AT '-' INTO lv_city lv_string.
        TRANSLATE lv_city TO UPPER CASE.
        CONCATENATE 'binder_id  = lwa_header-binder_id'
                    'AND   vendor_num = wa_state-zsapcode'
                    'AND  city        = lv_city' INTO lv_where_cond SEPARATED BY space.
      ELSE.                                                                "STATE
        wa_acc_doc-col_level = 'STATE'.
        CONCATENATE 'binder_id  = lwa_header-binder_id'
                    'AND  col_level = ''STATE'' '
                    'AND   vendor_num = wa_state-zsapcode' INTO lv_where_cond SEPARATED BY space.
      ENDIF.

*      IF lwa_header-count = 1.                               "Collective Level is state
*        wa_acc_doc-col_level = 'STATE'.
*        CONCATENATE 'binder_id  = lwa_header-binder_id'
*                    'AND  col_level = ''STATE'' '
*                    'AND   vendor_num = wa_state-zsapcode' INTO lv_where_cond SEPARATED BY space.
*      ELSE.
*        SPLIT lwa_header-return_name AT '-' INTO lv_city lv_string.
*        TRANSLATE lv_city TO UPPER CASE.
*        CONCATENATE 'binder_id  = lwa_header-binder_id'
*                    'AND   vendor_num = wa_state-zsapcode'
*                    'AND  city        = lv_city' INTO lv_where_cond SEPARATED BY space.
*      ENDIF.

      LOOP AT it_item INTO wa_item WHERE (lv_where_cond).
        wa_acc_doc-col_level = wa_item-col_level.
        wa_acc_doc-city      = wa_item-city.
        wa_acc_doc-bukrs     = wa_item-bukrs.
        wa_acc_doc-vendor_num = wa_item-vendor_num.
        wa_acc_doc-tax_location       = wa_item-tax_location.
        wa_acc_doc-tax                = wa_item-tax.
        APPEND wa_acc_doc TO it_acc_doc.
      ENDLOOP.
    ENDLOOP.
    SORT it_acc_doc BY stateid return_name  bukrs col_level city vendor_num.


*** check variance amount for each state code : Header and Item's totals should match for each state code
    LOOP AT it_header INTO lwa_header.
      CLEAR: lv_hdr_total, lv_itm_total, lv_variance_amount.

      lv_hdr_total = lwa_header-total_tax_rental_all.

      LOOP AT it_acc_doc INTO wa_acc_doc WHERE  stateid = lwa_header-stateid
                                         AND    return_name = lwa_header-return_name .
        lv_itm_total = lv_itm_total + wa_acc_doc-tax.
      ENDLOOP.

      "Variance in Hdr to item amounts for Sate ID
      IF lv_hdr_total <> lv_itm_total.
        lv_variance_amount = lv_hdr_total - lv_itm_total.
        IF lv_variance_amount >= -2 AND  lv_variance_amount <= 2.
          lwa_header-variance_amount = lv_variance_amount.
          MODIFY it_header FROM lwa_header.
        ELSE.
          gw_final-icon   = icon_red_light.

          CONCATENATE lwa_header-binder_id '/' lwa_header-perno '/' lwa_header-pername '/'
                      lwa_header-stateid '/' lwa_header-return_name ':'   'Variance is more than 2 dollars' INTO  gw_final-messg.

          APPEND gw_final TO gt_final.
          CLEAR gw_final.
          " variance is more than 2 dollar, so ignore the record
          DELETE it_header WHERE stateid     = lwa_header-stateid
                           AND   return_name = lwa_header-return_name .      .
        ENDIF.
      ENDIF.

    ENDLOOP.


***_______________________________post accounting documents____________________________***
    CLEAR : lv_tax,zitemno,zitemno_currency, lv_vend_amt.
    LOOP AT it_header INTO wa_file_hdr.
      CLEAR : lv_city, lv_discount, lv_interest, lv_penalties, lv_vend_amt, lv_flag_dis_pen_int,
              lv_flag_dis_pen_int, lv_var_vend_line, lv_var_gl_line.

      "Variance -  will updated only once for vend and GL line
      IF wa_file_hdr-variance_amount IS NOT INITIAL.
        lv_var_vend_line  = wa_file_hdr-variance_amount.
        lv_var_gl_line = wa_file_hdr-variance_amount.
      ENDIF.

      SPLIT wa_file_hdr-return_name AT '-' INTO lv_city lv_string.
      TRANSLATE lv_city TO UPPER CASE.

      "Discount, interest, penalties
      lv_discount  = wa_file_hdr-discounts.
      lv_interest  = wa_file_hdr-interest.
      lv_penalties = wa_file_hdr-penalties.
      IF lv_discount  IS NOT INITIAL
      OR lv_interest  IS NOT INITIAL
      OR lv_penalties IS NOT INITIAL.
        lv_flag_dis_pen_int = 'X'.
      ENDIF.


      "every company code should have a separate document
*      LOOP AT lt_bukrs INTO DATA(ls_bukrs).
      LOOP AT it_acc_doc INTO wa_acc_doc WHERE  stateid = wa_file_hdr-stateid
                                         AND    return_name = wa_file_hdr-return_name .
        MOVE-CORRESPONDING  wa_acc_doc TO wa_file_item.
        AT NEW vendor_num.

          CLEAR:  gs_documentheader, gs_documentheader_add_doc, zitemno_currency, ls_currencyamt, lv_tax,
                  ls_accountpayable, ls_accountgl,     lv_hdr_amount , lv_line_amount,
                  zitemno, lv_where_cond, lv_vend_amt, lv_itm_total_2.
          REFRESH: lt_currencyamt, lt_currencyamt, lt_accountpayable,lt_accountgl, lt_return,
                   lt_currencyamt_add_doc, lt_currencyamt_add_doc, lt_accountpayable_add_doc,lt_accountgl_add_doc.

*      CONCATENATE wa_file_hdr-binder_id sy-datum+6(2) sy-datum+0(4)
*       INTO gs_documentheader-header_txt  . " Header Text
          SPLIT p_filsum AT space INTO lv_string gs_documentheader-header_txt.   " Header Text
          REPLACE '.txt' IN gs_documentheader-header_txt WITH space.

          gs_documentheader-comp_code   =  wa_acc_doc-bukrs.
          gs_documentheader-pstng_date  = sy-datum.
          gs_documentheader-doc_date    = sy-datum.
          gs_documentheader-doc_type    = 'YO'.
          gs_documentheader-bus_act     = 'RFBU'.
          gs_documentheader-username    = sy-uname.
          gs_documentheader-doc_status = 2.

          ADD 1 TO zitemno_currency.

          READ TABLE it_state INTO wa_state WITH KEY zcode = wa_file_hdr-stateid BINARY SEARCH.
          IF sy-subrc <> 0.
            DATA(lv_stateid) = wa_file_hdr-stateid.
            SHIFT lv_stateid LEFT DELETING LEADING '0'.
            CLEAR wa_state.
            READ TABLE it_state INTO wa_state WITH
                                           KEY zcode = lv_stateid BINARY SEARCH.
          ENDIF.
*        IF sy-subrc EQ 0.
          CONCATENATE wa_file_hdr-binder_id wa_state-zsapcode INTO gs_documentheader-ref_doc_no.

          "vendor determination"
          CLEAR lv_vendor_where_cond.
          IF  " wa_file_hdr-count = 1.                              "Only 1 hdr record per state id
               wa_file_item-col_level = 'STATE'. " KDURAI 05/02/2024
            READ TABLE it_vendor INTO DATA(lw_vendor) WITH  KEY state = wa_state-zsapcode
                                                                 city1 =  space
                                                                 county = space
                                                                 pvt_agency = space.
          ELSE.
            CASE wa_file_item-col_level.
              WHEN 'CITY'.
                lv_vendor_where_cond = 'CITY1'.
              WHEN 'COUNTY'.
                lv_vendor_where_cond = 'COUNTY'.
              WHEN 'PRIVATE AGENCY'. " KDURAI 05/02/2024
                lv_vendor_where_cond =   'PVT_AGENCY'.
              WHEN OTHERS.
            ENDCASE.
            READ TABLE it_vendor INTO lw_vendor WITH  KEY state = wa_state-zsapcode
                                                                   (lv_vendor_where_cond) = wa_file_item-city.
          ENDIF.
          IF sy-subrc EQ 0.
*              ADD 1 TO zitemno_pay.
*              ls_accountpayable-itemno_acc = zitemno_pay.
            ADD 1 TO zitemno.
            ls_accountpayable-itemno_acc = zitemno.
            ls_accountpayable-vendor_no = lw_vendor-vendor.
            APPEND ls_accountpayable TO lt_accountpayable.
            CLEAR:zitemno_pay, ls_accountpayable.
          ELSE.                                             " Vendor determination failed

            CONCATENATE wa_file_hdr-binder_id '/' wa_file_hdr-perno '/' wa_file_hdr-pername '/'
                        wa_file_hdr-stateid '/' wa_file_hdr-return_name ':'   'Vendor is not determined' INTO  gw_final-messg.

            APPEND gw_final TO gt_final.
            CLEAR gw_final.
            EXIT.
          ENDIF.

          CLEAR :wa_file_item_new,lv_tax.

        ENDAT.
*        IF wa_file_item-tax_location NE wa_file_item_new-tax_location.

        ADD 1 TO zitemno.
        ls_accountgl-itemno_acc = zitemno.
        ls_accountgl-gl_account = gl_tax.
        ls_accountgl-item_text = wa_file_hdr-return_name.
        ls_accountgl-alloc_nmbr = wa_file_hdr-state_name.
        ls_accountgl-profit_ctr = wa_file_item-tax_location.
        APPEND ls_accountgl TO lt_accountgl.
        CLEAR ls_accountgl.
        IF wa_file_item-tax IS NOT INITIAL.
          lv_tax = wa_file_item-tax.
          ADD 1 TO zitemno_currency.
          ls_currencyamt-itemno_acc  = zitemno_currency.
          ls_currencyamt-currency  = 'USD'.
          "adjust the variance amount for first GL line
          IF lv_var_gl_line IS NOT INITIAL.
            ls_currencyamt-amt_doccur  = lv_tax + lv_var_gl_line.
            CLEAR lv_var_gl_line.
          ELSE.
            ls_currencyamt-amt_doccur  = lv_tax.
          ENDIF.
          APPEND ls_currencyamt TO  lt_currencyamt.
          CLEAR : ls_currencyamt,lv_tax.
        ENDIF.
*          lv_tax = wa_file_item-tax.
        lv_itm_total_2 = lv_itm_total_2 + wa_file_item-tax.

        AT END OF vendor_num.
*        lv_tax = lv_itm_total_2.
          "currency amount - Vendor Line
          ls_currencyamt-itemno_acc  = 1.
          ls_currencyamt-currency       = 'USD'.

          ls_currencyamt-amt_doccur  =  lv_itm_total_2 * -1.
          IF lv_var_vend_line IS NOT INITIAL.
            ls_currencyamt-amt_doccur  = ( lv_itm_total_2 + lv_var_vend_line ) * -1.
            CLEAR lv_var_vend_line.
          ELSE.
            ls_currencyamt-amt_doccur  =  lv_itm_total_2 * -1.
          ENDIF.
          APPEND ls_currencyamt TO  lt_currencyamt.
          CLEAR: ls_currencyamt, wa_file_hdr-variance_amount.

          "___Discount, interest, penalties
          "Additional document for discount, penalty and interest
          IF lv_flag_dis_pen_int IS NOT INITIAL.

            gs_documentheader_add_doc           = gs_documentheader.
            gs_documentheader_add_doc-comp_code = lv_disc_bukrs.

            CLEAR: zitemno, zitemno_currency.
            IF lv_discount IS NOT INITIAL.

              "Vendor Line
              ADD 1 TO zitemno.
              ls_accountpayable-itemno_acc = zitemno.
              ls_accountpayable-vendor_no = lw_vendor-vendor.
              APPEND ls_accountpayable TO lt_accountpayable_add_doc.
              CLEAR:ls_accountpayable.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_discount .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

              "Discount Line
*              lv_discount = lv_discount * -1. " KDURAI 06/05/2024
              ADD 1 TO zitemno.
              ls_accountgl-itemno_acc = zitemno.
              ls_accountgl-gl_account = gl_disc.
              ls_accountgl-item_text  = 'Discount'.
              ls_accountgl-alloc_nmbr = wa_file_hdr-state_name.
*>> BOC KDURAI 06/05/2024
*              ls_accountgl-profit_ctr =  pc_disc.
              ls_accountgl-costcenter =  cs_disc.
*<< EOC KDURAI 06/05/2024
              APPEND ls_accountgl TO lt_accountgl_add_doc.
              CLEAR ls_accountgl.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_discount .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

            ENDIF.

            IF lv_interest IS NOT INITIAL.


              ADD 1 TO zitemno.
              ls_accountpayable-itemno_acc = zitemno.
              ls_accountpayable-vendor_no = lw_vendor-vendor.
              APPEND ls_accountpayable TO lt_accountpayable_add_doc.
              CLEAR:ls_accountpayable.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_interest * -1 .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

              ADD 1 TO zitemno.
              ls_accountgl-itemno_acc = zitemno.
              ls_accountgl-gl_account = gl_int.
              ls_accountgl-item_text  = 'Interest'.
              ls_accountgl-alloc_nmbr = wa_file_hdr-state_name.
              ls_accountgl-costcenter = cs_int.

              APPEND ls_accountgl TO lt_accountgl_add_doc.
              CLEAR ls_accountgl.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_interest .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

            ENDIF.

            IF lv_penalties IS NOT INITIAL.

              ADD 1 TO zitemno.
              ls_accountpayable-itemno_acc = zitemno.
              ls_accountpayable-vendor_no = lw_vendor-vendor.
              APPEND ls_accountpayable TO lt_accountpayable_add_doc.
              CLEAR:ls_accountpayable.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_penalties * -1 .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

              ADD 1 TO zitemno.
              ls_accountgl-itemno_acc = zitemno.
              ls_accountgl-gl_account = gl_pen.
              ls_accountgl-item_text  = 'Penalties'.
              ls_accountgl-alloc_nmbr = wa_file_hdr-state_name.
              ls_accountgl-costcenter = cs_pen.
              APPEND ls_accountgl TO lt_accountgl_add_doc.
              CLEAR ls_accountgl.

              ADD 1 TO zitemno_currency.
              ls_currencyamt-itemno_acc  = zitemno_currency.
              ls_currencyamt-currency  = 'USD'.
              ls_currencyamt-amt_doccur  = lv_penalties .
              APPEND ls_currencyamt TO  lt_currencyamt_add_doc.
              CLEAR : ls_currencyamt.

            ENDIF.

          ENDIF.

          CLEAR: lv_tax,wa_file_item_new,wa_file_item.

          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
            EXPORTING
              documentheader = gs_documentheader
            TABLES
              accountgl      = lt_accountgl
              accountpayable = lt_accountpayable
              currencyamount = lt_currencyamt
              return         = lt_return.
*   Check if there are some error/abort/dump mesg's in the return table:
*   If errors occurred, then create idoc for reprocessing.
          LOOP AT lt_return INTO  DATA(ls_po_return)
              WHERE  type = 'E'
              OR     type = 'A'
              OR     type = 'X'.
            IF sy-tabix = 1.
              "Error Handling: Create Idoc when document is not posted
              CLEAR : lv_docnum.
              CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
                EXPORTING
                  documentheader = gs_documentheader
                IMPORTING
                  ev_docnum      = lv_docnum
                TABLES
                  accountgl      = lt_accountgl
                  accountpayable = lt_accountpayable
                  currencyamount = lt_currencyamt
                  return         = lt_return
                  accountwt      = lt_withtx.

            ENDIF.
            gw_final-icon   = icon_red_light.
            gw_final-messg  = ls_po_return-message.
            gw_final-docnum = lv_docnum.
            APPEND gw_final TO gt_final.
            CLEAR gw_final.

          ENDLOOP.
          IF sy-subrc = 0.              " Errors occurred
          ELSE.
            LOOP AT lt_return INTO  DATA(ls_ret) WHERE type = 'S'.
            ENDLOOP.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
            gw_final-icon    = icon_green_light.
            gw_final-belnr = ls_ret-message_v2(10).
            gw_final-bukrs = ls_ret-message_v2+10(4). "company code
            gw_final-gjahr = ls_ret-message_v2+14(4). " gs_documentheader-fisc_year.
            APPEND gw_final TO gt_final.
            CLEAR gw_final.

***_______Post additional document for Discount , Penalties and Interest
            IF lv_flag_dis_pen_int IS NOT INITIAL.
              REFRESH: lt_return.
              CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
                EXPORTING
                  documentheader = gs_documentheader_add_doc
                TABLES
                  accountgl      = lt_accountgl_add_doc
                  accountpayable = lt_accountpayable_add_doc
                  currencyamount = lt_currencyamt_add_doc
                  return         = lt_return.

*   If errors occurred, then create idoc for reprocessing.
              LOOP AT lt_return INTO  ls_po_return
                  WHERE  type = 'E'
                  OR     type = 'A'
                  OR     type = 'X'.
                IF sy-tabix = 1.
                  "Error Handling: Create Idoc when document is not posted
                  CLEAR : lv_docnum.
                  CALL FUNCTION 'ZFI_ACC_DOCUMENT_POST'
                    EXPORTING
                      documentheader = gs_documentheader_add_doc
                    IMPORTING
                      ev_docnum      = lv_docnum
                    TABLES
                      accountgl      = lt_accountgl_add_doc
                      accountpayable = lt_accountpayable_add_doc
                      currencyamount = lt_currencyamt_add_doc
                      return         = lt_return
                      accountwt      = lt_withtx.

                ENDIF.
                gw_final-icon   = icon_red_light.
                gw_final-messg  = ls_po_return-message.
                gw_final-docnum = lv_docnum.
                APPEND gw_final TO gt_final.
                CLEAR gw_final.

              ENDLOOP.
              IF sy-subrc = 0.              " Errors occurred
              ELSE.
                LOOP AT lt_return INTO  ls_ret WHERE type = 'S'.
                ENDLOOP.
                CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
                gw_final-icon    = icon_green_light.
                gw_final-belnr = ls_ret-message_v2(10).
                gw_final-bukrs = ls_ret-message_v2+10(4). "company code
                gw_final-gjahr = ls_ret-message_v2+14(4). " gs_documentheader-fisc_year.
                APPEND gw_final TO gt_final.
                CLEAR gw_final.
              ENDIF.
              CLEAR lv_flag_dis_pen_int.
            ENDIF.                               "Post additional document for Discount , Penalties and Interest
          ENDIF.
*        ENDIF.
          CLEAR : lt_return,lt_accountgl, lt_accountpayable,ls_currencyamt,gs_documentheader.
        ENDAT.
      ENDLOOP.

    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form B_DISPLAY_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM b_display_alv .

  DATA : lv_count TYPE i.

  gw_fcat-fieldname = 'ICON'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 6.
  gw_fcat-seltext_l = 'Status'.
  gw_fcat-tabname = 'GT_FINAL'.
  gw_fcat-icon = gc_x.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'BELNR'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 12.
  gw_fcat-seltext_l = 'Documnet Number'.
  gw_fcat-key = gc_x.
  gw_fcat-tabname = 'GT_FINAL'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'BUKRS'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 10.
  gw_fcat-seltext_l = 'Comp Code'.
  gw_fcat-key = gc_x.
  gw_fcat-tabname = 'GT_FINAL'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'GJAHR'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 12.
  gw_fcat-seltext_l = 'Document Year'.
  gw_fcat-tabname = 'GT_FINAL'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'MESSG'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 60.
  gw_fcat-seltext_l = 'Remarks'.
  gw_fcat-tabname = 'GT_FINAL'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'DOCNUM'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 16.
  gw_fcat-seltext_l = 'IDoc Number'.
  gw_fcat-tabname = 'GT_FINAL'.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = gt_fcat
    TABLES
      t_outtab      = gt_final
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form file_open_summ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_open_summ .

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = '/interfaces/onesource/INT0036/summary/in/'
*     FILEMASK         = ' '
    IMPORTING
      serverfile       = p_filsum
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

FORM file_open_detail .

  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    EXPORTING
      directory        = '/interfaces/onesource/INT0036/detail/in/'
*     FILEMASK         = ' '
    IMPORTING
      serverfile       = p_fildet
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.

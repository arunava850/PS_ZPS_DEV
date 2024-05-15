class ZFI_CL_PAYMENT_PROPOSAL_WF definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_PAYMENT_PROPOSAL_WF .

  aliases CHECK_WF_ACTIVE
    for IF_EX_PAYMENT_PROPOSAL_WF~CHECK_WF_ACTIVE .
  aliases DELETE_WF_PACKAGES
    for IF_EX_PAYMENT_PROPOSAL_WF~DELETE_WF_PACKAGES .
  aliases GET_WF_PACKAGE_1
    for IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_1 .
  aliases GET_WF_PACKAGE_2
    for IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_2 .
  aliases GET_WF_PACKAGE_ACTORS
    for IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_ACTORS .
  aliases GET_WF_PACKAGE_DESCRIPTION
    for IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_DESCRIPTION .
  aliases START_WF_POSTPROCESSING
    for IF_EX_PAYMENT_PROPOSAL_WF~START_WF_POSTPROCESSING .

  constants C_FIELD_LIST type DDOBJNAME value 'F110_WF_FIELDS' ##NO_TEXT.
  constants C_DEFAULT_PACKAGE type FI_WF_PACKAGE value '9999999999' ##NO_TEXT.

  methods GET_DEFAULT_ACTORS
    exporting
      !ET_DEFAULT_ACTORS type F110_WF_PACKAGE_T .
  methods GET_WF_PACKAGE
    importing
      !IS_ACCOUNT type F110_WF_ACCOUNT
      !I_AMOUNT type DMSHB_X8 optional
      !IT_REGUH type FI_T_REGUH
      !IT_REGUP type FI_T_REGUP optional
    exporting
      !ES_REGUH_WFR type REGUH_WFR
    exceptions
      INFORMATION_INCOMPLETE .
  methods SAVE_WF_PACKAGE
    importing
      !IS_REGUH_WFR type REGUH_WFR .
  methods SET_JOB_DETAILS
    importing
      !I_XMITD type XMITD default 'X'
      !I_XMITL type XMITL default 'X'
      !I_BHOST type BHOST optional
      !I_STRTIMMED type BTCCHAR1 default 'X'
      !I_SDLSTRTDT type BTCSDATE optional
      !I_SDLSTRTTM type BTCSTIME optional
      !I_USER type UNAME optional .
protected section.
private section.

  types:
    ty_dd03p_t TYPE TABLE OF dd03p .
  types:
    BEGIN OF ty_selopt,
      sign(1)   TYPE c,
      option(2) TYPE c,
      low(60)   TYPE c,
      high(60)  TYPE c,
    END OF ty_selopt .
  types:
    ty_selopt_t TYPE TABLE OF ty_selopt .
  types:
    BEGIN OF ty_ccode_active,
      zbukr  TYPE dzbukr,
      absbu  TYPE absbu,
      active TYPE f110_wf_active,
    END OF ty_ccode_active .
  types:
    ty_ccode_active_t TYPE TABLE OF ty_ccode_active .
  types:
    ty_t042wfr_t TYPE TABLE OF t042wfr .
  types:
    ty_reguh_wfr_t TYPE TABLE OF reguh_wfr .

  data MT_DD03P type TY_DD03P_T .
  data MT_CCODE_ACTIVE type TY_CCODE_ACTIVE_T .
  data MT_T042WFR type TY_T042WFR_T .
  data MT_REGUH_WFR type TY_REGUH_WFR_T .
  data MV_XMITD type XMITD .
  data MV_XMITL type XMITL .
  data MV_BHOST type BHOST .
  data MV_STRTIMMED type BTCCHAR1 .
  data MV_SDLSTRTDT type BTCSDATE .
  data MV_SDLSTRTTM type BTCSTIME .
  data MV_USER type UNAME .

  methods FILL_RANGE
    importing
      !I_LOW type TEXT35
      !I_HIGH type TEXT35
    exporting
      !E_AMOUNT type BOOLE_D
      !E_STABLE type BOOLE_D
      !E_LOWERCASE type BOOLE_D
    changing
      !CH_FIELD type FELDN_1
      !CT_RANGE type TY_SELOPT_T .
ENDCLASS.



CLASS ZFI_CL_PAYMENT_PROPOSAL_WF IMPLEMENTATION.


METHOD FILL_RANGE.

  DATA:
    l_zwels     TYPE dzwels.
  FIELD-SYMBOLS:
    <ls_dd03p>  TYPE dd03p,
    <ls_selopt> TYPE ty_selopt.

  CLEAR:
    e_amount,
    e_stable,
    e_lowercase.

* initialize table with fields for rules (if not yet done)
  IF mt_dd03p[] IS INITIAL.
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name      = c_field_list
        langu     = sy-langu
      TABLES
        dd03p_tab = mt_dd03p.
  ENDIF.

* interpret payment method as payment method list (2nd call)   "n2788949
  IF ch_field EQ 'RZAWE' AND i_high IS INITIAL.
    ch_field = 'ZWELS'.
  ENDIF.

* analyze selection field
  READ TABLE mt_dd03p ASSIGNING <ls_dd03p>
    WITH KEY tabname   = c_field_list
             fieldname = ch_field.
  IF sy-subrc EQ 0 AND NOT <ls_dd03p>-lowercase IS INITIAL.
    e_lowercase = 'X'.
  ENDIF.

* analyze special fields
  CASE ch_field.

*   ... convert payment method list into range of payment methods
    WHEN 'ZWELS'.
      l_zwels = i_low.
      CONDENSE l_zwels NO-GAPS.
      DO 10 TIMES.
        APPEND INITIAL LINE TO ct_range ASSIGNING <ls_selopt>.
        <ls_selopt>-sign   = 'I'.
        <ls_selopt>-option = 'EQ'.
        <ls_selopt>-low    = l_zwels(1).
        IF l_zwels+1 IS INITIAL.
          EXIT.
        ELSE.
          SHIFT l_zwels BY 1 PLACES LEFT.
        ENDIF.
      ENDDO.
      SORT ct_range.
      DELETE ADJACENT DUPLICATES FROM ct_range.
      ch_field = 'RZAWE'.
      EXIT.

*   ... amount is to be compared for total account
    WHEN 'RBETR'.
      e_amount = 'X'.
      e_stable = 'X'.

*   ... stable attributes can already be compared during payment run
    WHEN 'LAUFD' OR 'LAUFI'             "run ID
      OR 'LIFNR' OR 'KUNNR' OR 'EMPFG'  "account number
      OR 'ADRNR' OR 'ANRED' OR 'NAME1'  "name and adress of account
      OR 'NAME2' OR 'NAME3' OR 'NAME4'
      OR 'PSTLZ' OR 'ORT01' OR 'STRAS'
      OR 'PFACH' OR 'LAND1' OR 'REGIO'
      OR 'ZADNR' OR 'ZANRE' OR 'ZNME1'  "name and address of payer/payee
      OR 'ZNME2' OR 'ZNME3' OR 'ZNME4'
      OR 'ZPSTL' OR 'ZPST2' OR 'ZORT1'
      OR 'ZORT2' OR 'ZPFOR' OR 'ZSTRA'
      OR 'ZPFAC' OR 'ZLAND' OR 'ZREGI'
      OR 'ZTLFX' OR 'ZTELF' OR 'ZTELX'  "telecomunication
      OR 'ZSPRA' OR 'BUSAB' OR 'EIKTO'  "language, contact, references
      OR 'ZSTC1' OR 'STCD1'.            "tax number
      e_stable = 'X'.
  ENDCASE.

* fill select option
  APPEND INITIAL LINE TO ct_range ASSIGNING <ls_selopt>.
  <ls_selopt>-sign     = 'I'.
  IF NOT i_high IS INITIAL.
    <ls_selopt>-option = 'BT'.
  ELSEIF i_low CA '*+'.
    <ls_selopt>-option = 'CP'.
  ELSE.
    <ls_selopt>-option = 'EQ'.
  ENDIF.
  <ls_selopt>-low      = i_low.
  <ls_selopt>-high     = i_high.
  IF NOT e_lowercase IS INITIAL.
    TRANSLATE <ls_selopt>-low  TO UPPER CASE.
    TRANSLATE <ls_selopt>-high TO UPPER CASE.
  ENDIF.

ENDMETHOD.


METHOD GET_DEFAULT_ACTORS.

  DATA:
    lt_actors    TYPE tswhactor.
  FIELD-SYMBOLS:
    <ls_wfr>     TYPE t042wfr,
    <ls_actor>   TYPE swhactor,
    <ls_ccode>   TYPE ty_ccode_active,
    <ls_default> TYPE f110_wf_package.

* collect all actors per company code
  LOOP AT mt_t042wfr ASSIGNING <ls_wfr>.

    CLEAR lt_actors[].

    IF NOT <ls_wfr>-actor1 IS INITIAL.
      APPEND INITIAL LINE TO lt_actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype1.
      <ls_actor>-objid = <ls_wfr>-actor1.
    ENDIF.
    IF NOT <ls_wfr>-actor2 IS INITIAL.
      APPEND INITIAL LINE TO lt_actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype2.
      <ls_actor>-objid = <ls_wfr>-actor2.
    ENDIF.
    IF NOT <ls_wfr>-actor3 IS INITIAL.
      APPEND INITIAL LINE TO lt_actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype3.
      <ls_actor>-objid = <ls_wfr>-actor3.
    ENDIF.
    IF NOT <ls_wfr>-actor4 IS INITIAL.
      APPEND INITIAL LINE TO lt_actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype4.
      <ls_actor>-objid = <ls_wfr>-actor4.
    ENDIF.
    IF NOT <ls_wfr>-actor5 IS INITIAL.
      APPEND INITIAL LINE TO lt_actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype5.
      <ls_actor>-objid = <ls_wfr>-actor5.
    ENDIF.

*   build collection for each company code activated for workflow
    LOOP AT mt_ccode_active ASSIGNING <ls_ccode>
      WHERE zbukr  EQ <ls_wfr>-zbukr
      AND   active EQ 'X'.

      CHECK <ls_wfr>-absbu EQ <ls_ccode>-absbu
         OR <ls_wfr>-absbu IS INITIAL.

      READ TABLE et_default_actors ASSIGNING <ls_default>
        WITH KEY zbukr = <ls_ccode>-zbukr
                 absbu = <ls_ccode>-absbu.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO et_default_actors ASSIGNING <ls_default>.
        <ls_default>-zbukr   = <ls_ccode>-zbukr.
        <ls_default>-absbu   = <ls_ccode>-absbu.
        <ls_default>-package = c_default_package.
      ENDIF.
      APPEND LINES OF lt_actors TO <ls_default>-actors.
      SORT <ls_default>-actors.
      DELETE ADJACENT DUPLICATES FROM <ls_default>-actors.

    ENDLOOP.

  ENDLOOP.

ENDMETHOD.


METHOD GET_WF_PACKAGE.

  DATA:
    l_dataref      TYPE REF TO data,
    l_lowercase1   TYPE boole_d,
    l_lowercase2   TYPE boole_d,
    l_amount1      TYPE boole_d,
    l_amount2      TYPE boole_d,
    l_stable1      TYPE boole_d,
    l_stable2      TYPE boole_d,
    l_acc_type_all TYPE xfeld,
    l_finish       TYPE boole_d,
    lt_range_1     TYPE ty_selopt_t,
    lt_range_2     TYPE ty_selopt_t,
    ls_t001        TYPE t001,
    ls_reguh       TYPE reguh,
    ls_t042wfr     TYPE t042wfr. "filled = condition met = package found
  FIELD-SYMBOLS:
    <ls_dd03p> TYPE dd03p,
    <ls_wfr>   TYPE t042wfr,
    <l_field1> TYPE any,
    <l_field2> TYPE any.

* initialization
  CLEAR ls_t042wfr.
  READ TABLE it_reguh INTO ls_reguh INDEX 1.
  IF sy-subrc NE 0.
    RAISE information_incomplete.
  ENDIF.
  IF it_regup[] IS INITIAL.
    CLEAR l_finish.
  ELSE.
    l_finish = 'X'.
  ENDIF.

* analyze rules for paying company code
  LOOP AT mt_t042wfr ASSIGNING <ls_wfr>
    WHERE zbukr EQ is_account-zbukr.

*   check sending company code if filled
    CHECK <ls_wfr>-absbu IS INITIAL
       OR <ls_wfr>-absbu EQ is_account-absbu.

*   check withholding tax settings of company code country
    CALL FUNCTION 'FI_COMPANY_CODE_DATA'
      EXPORTING
        i_bukrs = <ls_wfr>-zbukr
      IMPORTING
        e_t001  = ls_t001
      EXCEPTIONS
        OTHERS  = 4.
    IF sy-subrc EQ 0 AND NOT ls_t001-wt_newwt IS INITIAL.
*     Withholding tax, posting during payment, accumulation across
*     vendors and customers => in this situation FBZ0 does not allow
*     editing of the proposal on finer level than the company code
      CALL FUNCTION 'FI_WT_CHECK_EXTENDED_ACCUM'
        EXPORTING
          i_land1        = ls_t001-land1
        IMPORTING
          e_acc_type_all = l_acc_type_all.
      IF NOT l_acc_type_all IS INITIAL.
        IF NOT <ls_wfr>-cond1_field IS INITIAL
        OR NOT <ls_wfr>-cond2_field IS INITIAL.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.

*   no condition => actor found
    IF  <ls_wfr>-cond1_field IS INITIAL
    AND <ls_wfr>-cond2_field IS INITIAL.
      MOVE-CORRESPONDING <ls_wfr> TO ls_t042wfr.
      EXIT.
    ENDIF.

    CLEAR:
      lt_range_1[],
      lt_range_2[].

    IF NOT <ls_wfr>-cond1_field IS INITIAL.

*     fill first range with first condition
      CALL METHOD me->fill_range
        EXPORTING
          i_low       = <ls_wfr>-cond1_low
          i_high      = <ls_wfr>-cond1_high
        IMPORTING
          e_amount    = l_amount1
          e_stable    = l_stable1
          e_lowercase = l_lowercase1
        CHANGING
          ch_field    = <ls_wfr>-cond1_field
          ct_range    = lt_range_1.

      IF l_finish  IS INITIAL AND
       ( l_stable1 IS INITIAL OR NOT l_amount1 IS INITIAL ).
        RAISE information_incomplete.
      ENDIF.

    ENDIF.

    IF NOT <ls_wfr>-cond2_field IS INITIAL.

*     same field for second condition => add to first range (OR)
      IF <ls_wfr>-cond1_field EQ <ls_wfr>-cond2_field.
        CALL METHOD me->fill_range
          EXPORTING
            i_low    = <ls_wfr>-cond2_low
            i_high   = <ls_wfr>-cond2_high
          CHANGING
            ch_field = <ls_wfr>-cond2_field
            ct_range = lt_range_1.


*     different field for second condition => fill second range (AND)
      ELSE.
        CALL METHOD me->fill_range
          EXPORTING
            i_low       = <ls_wfr>-cond2_low
            i_high      = <ls_wfr>-cond2_high
          IMPORTING
            e_amount    = l_amount2
            e_stable    = l_stable2
            e_lowercase = l_lowercase2
          CHANGING
            ch_field    = <ls_wfr>-cond2_field
            ct_range    = lt_range_2.

      IF l_finish  IS INITIAL AND
       ( l_stable2 IS INITIAL OR NOT l_amount2 IS INITIAL ).
          RAISE information_incomplete.
        ENDIF.
      ENDIF.
    ENDIF.

*   check rule condition
*   - depending on customizing for one or two selection fields
*   - depending on stability of field content for one or all payments
    LOOP AT it_reguh INTO ls_reguh.

*     prepare field for comparison of first condition
      IF NOT l_amount1 IS INITIAL.
        ASSIGN ('I_AMOUNT') TO <l_field1>.
      ELSE.
        ASSIGN COMPONENT <ls_wfr>-cond1_field
          OF STRUCTURE ls_reguh
          TO <l_field1>.
      ENDIF.
      IF NOT <l_field1> IS ASSIGNED.
        EXIT.                 "field not in REGUH => next rule
      ELSEIF NOT l_lowercase1 IS INITIAL.
        TRANSLATE <l_field1> TO UPPER CASE.
      ENDIF.

*     check condition for first field only
      IF lt_range_2 IS INITIAL.
        IF <l_field1> IN lt_range_1.
          MOVE-CORRESPONDING <ls_wfr> TO ls_t042wfr.
          EXIT.               "condition fulfilled => return result
        ELSEIF NOT l_stable1 IS INITIAL.
          EXIT.               "field content stable => next rule
        ENDIF.
      ELSE.

*       prepare field for comparison of second condition
        IF NOT l_amount2 IS INITIAL.
          ASSIGN ('I_AMOUNT') TO <l_field2>.
        ELSE.
          ASSIGN COMPONENT <ls_wfr>-cond2_field
            OF STRUCTURE ls_reguh
            TO <l_field2>.
        ENDIF.
        IF NOT <l_field2> IS ASSIGNED.
          EXIT.               "field not in REGUH => next rule
        ELSEIF NOT l_lowercase2 IS INITIAL.
          TRANSLATE <l_field2> TO UPPER CASE.
        ENDIF.

*       check condition for first and second field
        IF  <l_field1> IN lt_range_1
        AND <l_field2> IN lt_range_2.
          MOVE-CORRESPONDING <ls_wfr> TO ls_t042wfr.
          EXIT.               "condition fulfilled => return result
        ELSEIF NOT l_stable1 IS INITIAL AND NOT l_stable2 IS INITIAL.
          EXIT.               "field content stable => next rule
        ENDIF.
      ENDIF.

    ENDLOOP.

    IF NOT ls_t042wfr IS INITIAL.
      EXIT.
    ENDIF.

  ENDLOOP.

* check result of comparison, take default if no rule applied
  IF NOT ls_t042wfr IS INITIAL.
    MOVE-CORRESPONDING ls_t042wfr TO es_reguh_wfr.
    es_reguh_wfr-wf_package  = ls_t042wfr-prio.
  ELSE.
    CLEAR es_reguh_wfr.
    es_reguh_wfr-wf_package  = c_default_package.
  ENDIF.


  es_reguh_wfr-laufd = ls_reguh-laufd.
  es_reguh_wfr-laufi = ls_reguh-laufi.
  es_reguh_wfr-zbukr = is_account-zbukr.
*  es_reguh_wfr-absbu = is_account-absbu.
*  es_reguh_wfr-absbu = is_account-zbukr .
ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~CHECK_WF_ACTIVE.

  DATA:
    ls_t042wf    TYPE t042wf,
    l_zwels_run  TYPE dzwels,
    l_zwels_ok   TYPE boole_d,
    l_length_run TYPE i,
    l_length_wf  TYPE i.

  FIELD-SYMBOLS:
    <ls_ccode> TYPE ty_ccode_active,
    <ls_wfr>   TYPE t042wfr.

* read from local memory
  READ TABLE mt_ccode_active
    ASSIGNING <ls_ccode>
    WITH KEY zbukr = i_zbukr
             absbu = i_absbu.

  IF sy-subrc EQ 0.
    e_wf_active = <ls_ccode>-active.
  ELSE.

*   read from customizing:
*   ... check activation of workflow for paying company code

    SELECT SINGLE * FROM t042wf
      INTO  ls_t042wf
      WHERE zbukr EQ i_zbukr.

    CLEAR e_wf_active.
    IF sy-subrc EQ 0 AND NOT ls_t042wf-active IS INITIAL.

*     ... check whether one of the relevant payment methods is selected
      CLEAR l_zwels_ok.
      IF i_zwels IS INITIAL OR ls_t042wf-zwels IS INITIAL.
        l_zwels_ok = 'X'.
      ELSE.
        l_zwels_run = i_zwels.
        CONDENSE l_zwels_run NO-GAPS.
        l_length_run = strlen( l_zwels_run ).

        CONDENSE ls_t042wf-zwels NO-GAPS.
        l_length_wf  = strlen( ls_t042wf-zwels ).

        IF ls_t042wf-zwels(l_length_wf) CA l_zwels_run(l_length_run).
          l_zwels_ok = 'X'.
        ENDIF.
      ENDIF.

*     ... check whether sending company code has actors
      IF NOT l_zwels_ok IS INITIAL.
        SELECT * FROM t042wfr
          APPENDING TABLE mt_t042wfr
          WHERE zbukr  EQ i_zbukr
          AND ( absbu  EQ i_absbu
             OR absbu  EQ space )
          AND ( actor1 NE space
             OR actor2 NE space
             OR actor3 NE space
             OR actor4 NE space
             OR actor5 NE space ).
        IF sy-subrc EQ 0.
          SORT mt_t042wfr.
          DELETE ADJACENT DUPLICATES FROM mt_t042wfr.
          LOOP AT mt_t042wfr ASSIGNING <ls_wfr>.
            IF NOT <ls_wfr>-cond2_field IS INITIAL  "clean up rules
               AND <ls_wfr>-cond1_field IS INITIAL.
              <ls_wfr>-cond1_field = <ls_wfr>-cond2_field.
              <ls_wfr>-cond1_low   = <ls_wfr>-cond2_low.
              <ls_wfr>-cond1_high  = <ls_wfr>-cond2_high.
              CLEAR:
                <ls_wfr>-cond2_field,
                <ls_wfr>-cond2_low,
                <ls_wfr>-cond2_high.
            ENDIF.
          ENDLOOP.
          e_wf_active = 'X'.
        ENDIF.
      ENDIF.

    ENDIF.

*   fill local memory with result of activation check
    APPEND INITIAL LINE TO mt_ccode_active ASSIGNING <ls_ccode>.
    <ls_ccode>-zbukr  = i_zbukr.
    <ls_ccode>-absbu  = i_absbu.
    <ls_ccode>-active = e_wf_active.

  ENDIF.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~DELETE_WF_PACKAGES.

* delete customizing snapshot (T042WFR) when proposal data is deleted
  DELETE FROM reguh_wfr
    WHERE laufd EQ i_laufd
    AND   laufi EQ i_laufi.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_1.

  DATA:
    lt_reguh     TYPE fi_t_reguh,
    ls_reguh_wfr TYPE reguh_wfr.

  APPEND is_reguh TO lt_reguh.

  CALL METHOD me->get_wf_package
    EXPORTING
      is_account             = is_account
      it_reguh               = lt_reguh
    IMPORTING
      es_reguh_wfr           = ls_reguh_wfr
    EXCEPTIONS
      information_incomplete = 4.

  IF sy-subrc EQ 0 AND NOT ls_reguh_wfr-wf_package EQ 0.
    CALL METHOD me->save_wf_package
      EXPORTING
        is_reguh_wfr = ls_reguh_wfr.
    e_wf_package = ls_reguh_wfr-wf_package.
  ELSE.
    CLEAR e_wf_package.
  ENDIF.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_2.

  DATA:
    ls_reguh_wfr TYPE reguh_wfr.

  CALL METHOD me->get_wf_package
    EXPORTING
      is_account   = is_account
      i_amount     = i_amount
      it_reguh     = it_reguh
      it_regup     = it_regup
    IMPORTING
      es_reguh_wfr = ls_reguh_wfr.

  IF NOT ls_reguh_wfr-wf_package EQ 0.
    CALL METHOD me->save_wf_package
      EXPORTING
        is_reguh_wfr = ls_reguh_wfr.
  ENDIF.
  e_wf_package = ls_reguh_wfr-wf_package.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_ACTORS.

  DATA:
    lt_default   TYPE f110_wf_package_t.
  FIELD-SYMBOLS:
    <ls_wfr>     TYPE reguh_wfr,
    <ls_package> TYPE f110_wf_package,
    <ls_default> TYPE f110_wf_package,
    <ls_actor>   TYPE swhactor.

* retrieve actors for the default package from customizing
  CALL METHOD me->get_default_actors
    IMPORTING
      et_default_actors = lt_default.

* read packages from database
  SELECT * FROM reguh_wfr
    INTO TABLE mt_reguh_wfr
    WHERE laufd EQ i_laufd
    AND   laufi EQ i_laufi
    ORDER BY PRIMARY KEY.
  CHECK sy-subrc EQ 0.

* fill communication structure to start workflow
  LOOP AT mt_reguh_wfr ASSIGNING <ls_wfr>.

    APPEND INITIAL LINE TO et_wf_package ASSIGNING <ls_package>.
    <ls_package>-zbukr   = <ls_wfr>-zbukr.
    <ls_package>-absbu   = <ls_wfr>-absbu.
    <ls_package>-package = <ls_wfr>-wf_package.
    IF NOT <ls_wfr>-actor1 IS INITIAL.
      APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype1.
      <ls_actor>-objid = <ls_wfr>-actor1.
    ENDIF.
    IF NOT <ls_wfr>-actor2 IS INITIAL.
      APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype2.
      <ls_actor>-objid = <ls_wfr>-actor2.
    ENDIF.
    IF NOT <ls_wfr>-actor3 IS INITIAL.
      APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype3.
      <ls_actor>-objid = <ls_wfr>-actor3.
    ENDIF.
    IF NOT <ls_wfr>-actor4 IS INITIAL.
      APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype4.
      <ls_actor>-objid = <ls_wfr>-actor4.
    ENDIF.
    IF NOT <ls_wfr>-actor5 IS INITIAL.
      APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
      <ls_actor>-otype = <ls_wfr>-otype5.
      <ls_actor>-objid = <ls_wfr>-actor5.
    ENDIF.

*   fill last entry with default actors (if not assigned in customizing)
    IF <ls_package>-actors[] IS INITIAL.
      READ TABLE lt_default ASSIGNING <ls_default>
        WITH KEY zbukr   = <ls_package>-zbukr
                 absbu   = <ls_package>-absbu
                 package = c_default_package.
      IF sy-subrc EQ 0.
        APPEND LINES OF <ls_default>-actors TO <ls_package>-actors.
      ELSE.
        APPEND INITIAL LINE TO <ls_package>-actors ASSIGNING <ls_actor>.
        <ls_actor>-otype = 'US'.
        <ls_actor>-objid = sy-uname.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~GET_WF_PACKAGE_DESCRIPTION.

  DATA:
    ls_t001    TYPE t001,
    l_text     TYPE f110_wf_package_desc, "field to build text fragments
    l_desc     TYPE f110_wf_package_desc, "result to be retured
    l_field    TYPE feldn_1,
    l_low      TYPE text35,
    l_high     TYPE text35,
    l_value    TYPE text35,
    lt_dd03p   TYPE ty_dd03p_t,
    lr_dataref TYPE REF TO data.
  FIELD-SYMBOLS:
    <ls_wfr>   TYPE reguh_wfr,
    <ls_dd03p> TYPE dd03p,
    <l_value>  TYPE any.

  CLEAR e_description.

* check whether current proposal run is in buffer, fill buffer if needed
  READ TABLE mt_reguh_wfr TRANSPORTING NO FIELDS
    WITH KEY laufd      = i_laufd
             laufi      = i_laufi
             zbukr      = i_zbukr
             absbu      = i_absbu
             wf_package = i_wf_package.
  IF sy-subrc NE 0.
    SELECT * FROM reguh_wfr
      INTO TABLE mt_reguh_wfr
      WHERE laufd EQ i_laufd
      AND   laufi EQ i_laufi.
  ENDIF.

* read company code currency
  CALL FUNCTION 'FI_COMPANY_CODE_DATA'
    EXPORTING
      i_bukrs = i_zbukr
    IMPORTING
      e_t001  = ls_t001
    EXCEPTIONS
      OTHERS  = 0.

* initialize table with fields for rules (if not yet done)
  IF mt_dd03p[] IS INITIAL.
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name      = c_field_list
        langu     = sy-langu
      TABLES
        dd03p_tab = mt_dd03p.
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name      = 'F110_WF_PACKAGE_ACCOUNTS'
        langu     = sy-langu
      TABLES
        dd03p_tab = lt_dd03p.
    APPEND LINES OF lt_dd03p TO mt_dd03p.
  ENDIF.

* build textual description from select option
  READ TABLE mt_reguh_wfr ASSIGNING <ls_wfr>
    WITH KEY laufd      = i_laufd
             laufi      = i_laufi
             zbukr      = i_zbukr
             absbu      = i_absbu
             wf_package = i_wf_package.
  CHECK sy-subrc EQ 0.
  CLEAR e_description.

* ensure that second condition is not filled without first
  IF <ls_wfr>-cond1_field IS INITIAL.
    IF NOT <ls_wfr>-cond2_field IS INITIAL.
      <ls_wfr>-cond1_field = <ls_wfr>-cond2_field.
      <ls_wfr>-cond1_low   = <ls_wfr>-cond2_low.
      <ls_wfr>-cond1_high  = <ls_wfr>-cond2_high.
      CLEAR <ls_wfr>-cond2_field.
      CLEAR <ls_wfr>-cond2_low.
      CLEAR <ls_wfr>-cond2_high.
    ENDIF.
  ENDIF.

  DO 5 TIMES.

*   initialize condition
    CASE sy-index.
      WHEN 1.
        l_field = 'WF_PACKAGE'.
        l_low   = i_wf_package.
        CLEAR l_high.
      WHEN 2.
        l_field = 'ZBUKR'.
        l_low   = i_zbukr.
        CLEAR l_high.
      WHEN 3.
        l_field = 'ABSBU'.
        l_low   = i_absbu.
        CLEAR l_high.
      WHEN 4.
        IF <ls_wfr>-cond1_field IS INITIAL.
          e_description = TEXT-004.
          CONTINUE.
        ENDIF.
        l_field = <ls_wfr>-cond1_field.
        l_low   = <ls_wfr>-cond1_low.
        l_high  = <ls_wfr>-cond1_high.
      WHEN 5.
        CHECK NOT <ls_wfr>-cond2_field IS INITIAL.
        l_field = <ls_wfr>-cond2_field.
        l_low   = <ls_wfr>-cond2_low.
        l_high  = <ls_wfr>-cond2_high.
    ENDCASE.
    IF l_field EQ 'RZAWE'.
      l_field = 'ZWELS'.
    ENDIF.
    READ TABLE mt_dd03p
      ASSIGNING <ls_dd03p>
      WITH KEY tabname   = c_field_list
               fieldname = l_field.
    IF sy-subrc NE 0.
      READ TABLE mt_dd03p
        ASSIGNING <ls_dd03p>
        WITH KEY tabname   = 'F110_WF_PACKAGE_ACCOUNTS'
                 fieldname = l_field.
    ENDIF.
    IF sy-subrc EQ 0.

*     connect first and second condition
      CASE sy-index.
        WHEN 1 OR 4.
          CLEAR l_desc.
        WHEN 2 OR 3.
          CONCATENATE l_desc ',' INTO l_desc.
        WHEN 5.
          IF <ls_wfr>-cond1_field EQ <ls_wfr>-cond2_field.
            CONCATENATE l_desc TEXT-001
              INTO l_desc
              SEPARATED BY space.
            CLEAR l_field.
          ELSE.
            CONCATENATE l_desc TEXT-002
              INTO l_desc
              SEPARATED BY space.
          ENDIF.
      ENDCASE.

*     get field description
      IF NOT <ls_dd03p>-scrtext_l IS INITIAL.
        l_text = <ls_dd03p>-scrtext_l.
      ELSE.
        l_text = <ls_dd03p>-ddtext.
      ENDIF.
      IF  <ls_dd03p>-reftable EQ 'T001'
      AND <ls_dd03p>-reffield EQ 'WAERS'.
        CONCATENATE l_text ls_t001-waers
          INTO l_text
          SEPARATED BY space.
      ENDIF.
      IF l_desc IS INITIAL.
        l_desc = l_text.
      ELSE.
        CONCATENATE l_desc l_text
          INTO l_desc
          SEPARATED BY space.
      ENDIF.

*     get condition description
      DO 2 TIMES.

        CASE sy-index.
          WHEN 1.
            l_value = l_low.
          WHEN 2.
            CHECK NOT l_high IS INITIAL.
            CONCATENATE l_desc TEXT-003
              INTO l_desc
              SEPARATED BY space.
            l_value = l_high.
        ENDCASE.

        CREATE DATA lr_dataref TYPE (<ls_dd03p>-rollname).
        ASSIGN lr_dataref->* TO <l_value>.
        <l_value> = l_value.

        IF <ls_dd03p>-datatype EQ 'CURR'.
          WRITE <l_value> TO l_text CURRENCY ls_t001-waers LEFT-JUSTIFIED.
        ELSE.
          WRITE <l_value> TO l_text LEFT-JUSTIFIED.
          IF <ls_dd03p>-datatype EQ 'NUMC'.
            SHIFT l_text LEFT DELETING LEADING '0'.
            IF l_text IS INITIAL.
              l_text = '0'.
            ENDIF.
          ENDIF.
        ENDIF.

        CONCATENATE l_desc l_text
          INTO l_desc
          SEPARATED BY space.

      ENDDO.

    ELSE.

*     use technical names as fallback, if field is not from REGUH
      CONCATENATE
        <ls_wfr>-cond1_field <ls_wfr>-cond1_low <ls_wfr>-cond1_high
        <ls_wfr>-cond2_field <ls_wfr>-cond2_low <ls_wfr>-cond2_high
        INTO e_description
        SEPARATED BY space.
      EXIT.

    ENDIF.

    CASE sy-index.
      WHEN 1 OR 2 OR 3.
        e_description_cc = l_desc.
        CONDENSE e_description_cc.
      WHEN 4 OR 5.
        e_description = l_desc.
        CONDENSE e_description.
    ENDCASE.

  ENDDO.

ENDMETHOD.


METHOD IF_EX_PAYMENT_PROPOSAL_WF~START_WF_POSTPROCESSING.

*  DATA:
*    l_jobname  TYPE btcjob,
*    l_jobcount TYPE btcjobcnt.
*
** schedule payment run immediately ...
*  IF NOT  mv_strtimmed IS INITIAL
*     OR   mv_sdlstrtdt LT sy-datum
*     OR ( mv_sdlstrtdt EQ sy-datum AND mv_sdlstrttm LT sy-uzeit ).
*
*    SUBMIT rff110s_wf_postprocessing AND RETURN
*      WITH p_laufd = i_laufd
*      WITH p_laufi = i_laufi
*      WITH p_xmitd = mv_xmitd
*      WITH p_xmitl = mv_xmitl
*      WITH p_bhost = mv_bhost.
*
** ... or later via job, depending on job details
*  ELSE.
*
*    IF i_laufi+5 IS INITIAL.
*      CONCATENATE 'F110_WF_POSTPROC' i_laufd i_laufi INTO l_jobname.
*    ELSE.
*      CONCATENATE 'F111_WF_POSTPROC' i_laufd i_laufi INTO l_jobname.
*    ENDIF.
*
*    CALL FUNCTION 'JOB_OPEN'
*      EXPORTING
*        jobname  = l_jobname
*      IMPORTING
*        jobcount = l_jobcount
*      EXCEPTIONS
*        OTHERS   = 4.
*
*    IF sy-subrc EQ 0.
*      SUBMIT rff110s_wf_postprocessing AND RETURN
*        USER mv_user VIA JOB l_jobname NUMBER l_jobcount       "n2486436
*        WITH p_laufd = i_laufd
*        WITH p_laufi = i_laufi
*        WITH p_xmitd = mv_xmitd
*        WITH p_xmitl = mv_xmitl
*        WITH p_bhost = mv_bhost.
*
*      CALL FUNCTION 'JOB_CLOSE'
*        EXPORTING
*          jobcount  = l_jobcount
*          jobname   = l_jobname
*          sdlstrtdt = mv_sdlstrtdt
*          sdlstrttm = mv_sdlstrttm
*        EXCEPTIONS
*          OTHERS    = 4.
*    ENDIF.
*
**   start immediately if scheduling of job was not successful
*    IF sy-subrc NE 0.
*      SUBMIT rff110s_wf_postprocessing AND RETURN
*        WITH p_laufd = i_laufd
*        WITH p_laufi = i_laufi
*        WITH p_xmitd = mv_xmitd
*        WITH p_xmitl = mv_xmitl
*        WITH p_bhost = mv_bhost.
*    ENDIF.
*
*  ENDIF.

ENDMETHOD.


METHOD save_wf_package.

  READ TABLE mt_reguh_wfr
    WITH KEY laufd      = is_reguh_wfr-laufd
             laufi      = is_reguh_wfr-laufi
             zbukr      = is_reguh_wfr-zbukr
             absbu      = is_reguh_wfr-absbu
             wf_package = is_reguh_wfr-wf_package
    TRANSPORTING NO FIELDS.

  IF sy-subrc NE 0.
    INSERT reguh_wfr FROM is_reguh_wfr.
    APPEND is_reguh_wfr TO mt_reguh_wfr.
    SORT mt_reguh_wfr.
*  ELSEIF is_reguh_wfr-wf_package = '9999999999'.
*
*    modify reguh_wfr FROM is_reguh_wfr TRANSPORTING wf_package .
*
  ENDIF.

ENDMETHOD.


METHOD SET_JOB_DETAILS.

  mv_xmitd     = i_xmitd.
  mv_xmitl     = i_xmitl.
  mv_bhost     = i_bhost.
  mv_strtimmed = i_strtimmed.
  mv_sdlstrtdt = i_sdlstrtdt.
  mv_sdlstrttm = i_sdlstrttm.
  mv_user      = i_user.                                       "n2486436

* schedule payment run with other user
  IF mv_user IS INITIAL.
    mv_user = sy-uname.
  ELSEIF mv_user NE sy-uname.
    IF NOT mv_strtimmed IS INITIAL.
      CLEAR mv_strtimmed.
      mv_sdlstrtdt = sy-datum.
      mv_sdlstrttm = sy-uzeit.
    ENDIF.
  ENDIF.

ENDMETHOD.
ENDCLASS.

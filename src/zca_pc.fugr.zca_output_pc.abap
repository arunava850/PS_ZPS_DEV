FUNCTION zca_output_pc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PCENTERS) TYPE  CHAR10 OPTIONAL
*"     VALUE(IV_PC_FLAG) TYPE  CHAR01
*"     VALUE(IV_LIST) TYPE  CHAR01 OPTIONAL
*"  TABLES
*"      ET_OUTPUT STRUCTURE  ZFI_PCCENTERS
*"----------------------------------------------------------------------

  DATA:
    lv_input  TYPE char15,
    lt_input  TYPE STANDARD TABLE OF  zfi_pccenters,
    lv_cnt    TYPE i,
    lv_var    TYPE c,
    lv_temp   TYPE char11,
    lv_match1 TYPE csks-kostl,
    lv_match2 TYPE csks-kostl,
    lv_actual TYPE char10,
    lv_strlen TYPE char11,
    lv_exit   TYPE c.

  FIELD-SYMBOLS <fs_items> LIKE LINE OF lt_input.

  IF iv_list = 'L'.
    IF iv_pc_flag = 'P'.
      SELECT prctr FROM cepc INTO TABLE @lt_input.
    ENDIF.
    IF iv_pc_flag = 'C'.
      SELECT kostl FROM csks INTO TABLE @lt_input.
    ENDIF.
  ELSE.
    IF  iv_pcenters NE abap_false.
      lv_actual = iv_pcenters.
      lv_actual = |{ lv_actual ALPHA = OUT }|.
      lv_input = |%{ lv_actual }%| .
      iv_pcenters = |{ iv_pcenters ALPHA = IN }|.
    ENDIF.
    IF iv_pc_flag = 'P'.
      SELECT prctr FROM cepc INTO TABLE @lt_input WHERE prctr LIKE @lv_input.
    ENDIF.
    IF iv_pc_flag = 'C'.
      SELECT kostl FROM csks INTO TABLE @lt_input WHERE kostl LIKE @lv_input.
    ENDIF.
  ENDIF.

  DATA(lt_input_tmp) = lt_input.
  IF iv_list NE 'L'.
    DELETE lt_input WHERE prctr NE iv_pcenters.
  ENDIF.
  LOOP AT lt_input INTO DATA(ls_input_l).
    CLEAR:lv_actual,lv_temp,iv_pcenters,lv_match1,lv_match2.
    IF ls_input_l-prctr CA sy-abcde.
      APPEND INITIAL LINE TO et_output ASSIGNING <fs_items>.
      <fs_items>-prctr    = ls_input_l-prctr.
      <fs_items>-numbr    = ls_input_l-prctr.
      <fs_items>-nlz_val = ls_input_l-prctr.
      <fs_items>-full_val = ls_input_l-prctr.
    ELSE.
      lv_actual = ls_input_l-prctr.
      lv_temp = ls_input_l-prctr.
      lv_temp = |{ lv_temp ALPHA = OUT }|.
      iv_pcenters = ls_input_l-prctr.
      sy-fdpos = 0.
      DO 26 TIMES.
        DATA(lv_index) = sy-index.
        lv_var = sy-abcde+sy-fdpos(1).
        lv_temp = |0*{ lv_temp }*{ lv_var }|.
        LOOP AT lt_input_tmp INTO DATA(ls_input_tmp) WHERE prctr CP lv_temp.
          CLEAR:lv_match1,lv_match2.
          lv_match2 = ls_input_tmp-prctr.
          REPLACE ALL OCCURRENCES OF
                REGEX '[A-Z]' IN lv_match2 ##REGEX_POSIX
                 WITH space.
          lv_match1 = |{ lv_match2 ALPHA = IN }|.
          IF lv_actual NE lv_match1.
            CONTINUE.
          ENDIF.
          IF ls_input_tmp-prctr CA sy-abcde.
            iv_pcenters = |{ iv_pcenters ALPHA = OUT }|.
            lv_strlen = strlen( ls_input_tmp-prctr ).
            DO lv_strlen TIMES.
              IF ls_input_tmp-prctr+lv_cnt(sy-index) EQ 0.
                CONCATENATE '0' iv_pcenters INTO iv_pcenters.
              ELSE.
                lv_exit = abap_true.
                EXIT.
              ENDIF.
            ENDDO.
          ENDIF.
          CLEAR:ls_input_tmp.
          IF lv_exit EQ abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
        IF lv_exit EQ abap_true.
          EXIT.
        ELSE.
          CLEAR:lv_temp.
          lv_temp = ls_input_l-prctr.
          lv_temp = |{ lv_temp ALPHA = OUT }|.
        ENDIF.
        sy-fdpos = lv_index .
      ENDDO.
      CLEAR:lv_index.
      IF lv_exit EQ abap_true.
        APPEND INITIAL LINE TO et_output ASSIGNING <fs_items> .
        <fs_items>-prctr    = lv_actual.
        <fs_items>-numbr    = iv_pcenters.
        lv_actual = |{ lv_actual ALPHA = OUT }|.
        <fs_items>-nlz_val = lv_actual.
        lv_actual = |{ lv_actual ALPHA = IN }|.
        <fs_items>-full_val = lv_actual.
        CLEAR:lv_exit.
      ELSE.
        APPEND INITIAL LINE TO et_output ASSIGNING <fs_items> .
        <fs_items>-prctr    = lv_actual.
        lv_actual = |{ lv_actual ALPHA = OUT }|.
        <fs_items>-numbr    = lv_actual.
        <fs_items>-nlz_val = lv_actual.
        lv_actual = |{ lv_actual ALPHA = IN }|.
        <fs_items>-full_val = lv_actual.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.

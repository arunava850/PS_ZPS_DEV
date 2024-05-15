*&---------------------------------------------------------------------*
*& Include          ZFI_GL_DAILY_TRANSX_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lt_RF011Z     TYPE TABLE OF rf011z,
        lt_RF011Z_tmp TYPE TABLE OF rf011z,
        lt_RF011Q_txt TYPE TABLE OF rf011q,
        lv_ver        TYPE hryid.

  LOOP AT s_rversn INTO DATA(ls_veri).
    IF ls_veri-option EQ 'EQ'.
      lv_ver = ls_veri-low.
      DATA(lo_uh_legacy) = NEW cl_fins_uh_hrrp_fsv_legacy( ).
      IF lo_uh_legacy IS NOT INITIAL.
        CALL METHOD lo_uh_legacy->if_fins_uh_hrrp_fsv_legacy~import_balance_sheet_pos(
          EXPORTING
            iv_version = lv_ver
          IMPORTING
            et_i011z   = lt_RF011Z[] ).
        CALL METHOD lo_uh_legacy->if_fins_uh_hrrp_fsv_legacy~import_balance_sheet_text(
          EXPORTING
            iv_version  = lv_ver
            iv_language = sy-langu
          IMPORTING
            et_x011q    = lt_RF011Q_txt[] ).
      ENDIF.
    ENDIF.

    SELECT *
      FROM hrrp_node
      INTO TABLE @DATA(lt_hrrp)
     WHERE hryid EQ @lv_ver
       AND hrytype EQ 'FSVN'.

    LOOP AT lt_RF011Z ASSIGNING FIELD-SYMBOL(<fs_node>) .
      gs_data-versn       = lv_ver.
      gs_data-ergsl_node  = <fs_node>-ergso.
      READ TABLE lt_RF011Q_txt
      INTO DATA(ls_RF011Q_txt)
      WITH KEY ergsl = <fs_node>-ergso.
      IF sy-subrc EQ 0.
        gs_data-txt45_node  = ls_RF011Q_txt-txt45.
      ENDIF.
      gs_data-vonkt       = <fs_node>-vonkt.
      gs_data-biskt       = <fs_node>-bilkt.
      READ TABLE lt_hrrp
      INTO DATA(ls_hrrp)
      WITH KEY nodevalue = <fs_node>-ergso.
      IF sy-subrc = 0 .
        READ TABLE lt_hrrp
        INTO DATA(ls_parent)
        WITH KEY hrynode = ls_hrrp-parnode.
        IF sy-subrc = 0.
          IF ls_parent-hrynode NA sy-abcde.
            SHIFT ls_parent-hrynode LEFT DELETING LEADING '0'.
          ENDIF.
          gs_data-ergsl_parent = ls_parent-hrynode.
          SHIFT gs_data-ergsl_parent LEFT DELETING LEADING '0'.
          READ TABLE lt_RF011Q_txt
          INTO ls_RF011Q_txt
          WITH KEY ergsl = ls_parent-nodevalue."ls_parent-hrynode.
          IF sy-subrc EQ 0.
            gs_data-txt45_parent  = ls_RF011Q_txt-txt45.
          ENDIF.
          gs_data-ergsl_parent = <fs_node>-ergso+0(1).
        ENDIF.
      ENDIF.
      gs_data-interface_name  = 'INT0076'.
      gs_data-receiver_system = 'CNSL'.
      IF gs_data-ergsl_parent EQ lv_ver.
        CLEAR:gs_data-ergsl_parent.
        gs_data-ergsl_node = 1.
      ENDIF.
      APPEND gs_data TO gt_data.
      CLEAR:gs_data.
    ENDLOOP.
    REFRESH:lt_hrrp, lt_RF011Z, lt_RF011Q_txt.
  ENDLOOP.
  SORT gt_data BY ergsl_node.
*  RANGES : r_id FOR fagl_011pc-id.
*  RANGES : r_parent FOR fagl_011pc-ergsl.
*
*  SELECT n~versn , n~ergsl , t~txt45 , n~vonkt , n~biskt
*        INTO TABLE @gt_node
*        FROM   fagl_011zc AS n INNER JOIN fagl_011qt AS t
*        ON     n~ergsl   =    t~ergsl
*        AND    n~versn   =    t~versn
*        WHERE  n~versn   IN   @s_rversn
*        AND    t~spras   =    @sy-langu
*        AND    t~txtyp   =    'K'  .
*
*  IF gt_node[] IS NOT INITIAL.
*    LOOP AT gt_node ASSIGNING FIELD-SYMBOL(<fs_node>) .
*      APPEND INITIAL LINE TO r_parent ASSIGNING FIELD-SYMBOL(<fs_parent>) .
*      <fs_parent>-sign    = 'I'.
*      <fs_parent>-option  = 'EQ'.
*      <fs_parent>-low     = <fs_node>-ergsl.
*    ENDLOOP.
*    DELETE ADJACENT DUPLICATES FROM r_parent.
*    SELECT n~versn , n~parent , n~ergsl , t~txt45
*          INTO TABLE @gt_inter
*          FROM   fagl_011pc AS n INNER JOIN fagl_011qt AS t
*          ON     n~ergsl   =    t~ergsl
*          AND    n~versn   =    t~versn
*          WHERE  n~versn   IN   @s_rversn
*          AND    n~ergsl   IN   @r_parent
*          AND    t~spras   =    @sy-langu
*          AND    t~txtyp   =    'K'  .
*  ENDIF.
*
*  IF gt_inter[] IS NOT INITIAL.
*
*    LOOP AT gt_inter ASSIGNING FIELD-SYMBOL(<fs_inter>) .
*      APPEND INITIAL LINE TO r_id ASSIGNING FIELD-SYMBOL(<fs_id>) .
*      <fs_id>-sign    = 'I'.
*      <fs_id>-option  = 'EQ'.
*      <fs_id>-low     = <fs_inter>-parent.
*    ENDLOOP.
*    DELETE ADJACENT DUPLICATES FROM r_id.
*    SELECT n~versn , n~id , n~ergsl , t~txt45
*          INTO TABLE @gt_parent
*          FROM fagl_011pc AS n INNER JOIN fagl_011qt AS t
*          ON     n~ergsl   =    t~ergsl
*          AND    n~versn   =    t~versn
*          WHERE  n~versn   IN   @s_rversn
*          AND    n~id      IN   @r_id
*          AND    t~spras   =    @sy-langu
*          AND    t~txtyp   =    'K'  .
*
*
*  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form Send_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM send_data .
  DATA: lv_count TYPE i .
  DATA(lr_send) = NEW zco_fi_stmt_version( ).

  DESCRIBE TABLE gt_data LINES lv_count.
  IF lv_count LE 2000. " Send data when records are less than or equal to 2000
    gs_out-fi_stmt_version_mt-zdata_sv = gt_data[].
    TRY.
        CALL METHOD lr_send->send_data
          EXPORTING
            output = gs_out.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data sent Successfully' TYPE 'S'.
      CATCH cx_ai_system_fault INTO DATA(ls_text).
    ENDTRY.
  ELSE.
    DATA(lt_data_tmp) = gt_data.
    DELETE lt_data_tmp FROM 2001 TO lv_count. " Send first 2000 records
    gs_out-fi_stmt_version_mt-zdata_sv = lt_data_tmp[].
    TRY.
        CALL METHOD lr_send->send_data
          EXPORTING
            output = gs_out.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data sent Successfully' TYPE 'S'.
      CATCH cx_ai_system_fault INTO ls_text.
    ENDTRY.

    REFRESH:lt_data_tmp.
    DELETE gt_data FROM 1 TO 2000. " Send remaining records of more than 2000 records
    gs_out-fi_stmt_version_mt-zdata_sv = gt_data[].
    TRY.
        CALL METHOD lr_send->send_data
          EXPORTING
            output = gs_out.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data sent Successfully' TYPE 'S'.
      CATCH cx_ai_system_fault INTO ls_text.
    ENDTRY.
  ENDIF.
*  LOOP AT gt_node ASSIGNING FIELD-SYMBOL(<fs_node>) .
*    IF lv_count = 2000.
*      gs_out-fi_stmt_version_mt-zdata_sv = gt_data[].
*      TRY.
*          CALL METHOD lr_send->send_data
*            EXPORTING
*              output = gs_out.
*          COMMIT WORK.
*        CATCH cx_ai_system_fault INTO DATA(ls_text).
*      ENDTRY.
*      CLEAR : lv_count , gt_data[] , gs_out-fi_stmt_version_mt-zdata_sv[] .
*    ENDIF.
*    lv_count = lv_count + 1 .
*    APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>) .
*    <fs_data>-versn       = <fs_node>-versn  .
*    <fs_data>-ergsl_node  = <fs_node>-ergsl  .
*    <fs_data>-txt45_node  = <fs_node>-txt45  .
*    <fs_data>-vonkt       = <fs_node>-vonkt  .
*    <fs_data>-biskt       = <fs_node>-biskt  .
*    READ TABLE gt_inter ASSIGNING FIELD-SYMBOL(<fs_inter>) WITH KEY ergsl = <fs_node>-ergsl.
*    IF sy-subrc = 0 .
*      READ TABLE gt_parent ASSIGNING FIELD-SYMBOL(<fs_parent>) WITH KEY id = <fs_inter>-parent.
*      IF sy-subrc = 0.
*        <fs_data>-ergsl_parent = <fs_parent>-ergsl  .
*        <fs_data>-txt45_parent = <fs_parent>-txt45  .
*      ENDIF.
*    ENDIF.
*
*    <fs_data>-interface_name  = 'INT0076'.
*    <fs_data>-receiver_system = 'CNSL'.
*  ENDLOOP.
*
*  IF gt_data[] IS NOT INITIAL.
*    gs_out-fi_stmt_version_mt-zdata_sv = gt_data[].
*    TRY.
*        CALL METHOD lr_send->send_data
*          EXPORTING
*            output = gs_out.
*        COMMIT WORK.
*      CATCH cx_ai_system_fault INTO ls_text.
*    ENDTRY.
*  ENDIF.
ENDFORM.

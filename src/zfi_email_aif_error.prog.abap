*&---------------------------------------------------------------------*
*& Report ZFI_EMAIL_AIF_ERROR
*&---------------------------------------------------------------------*
*& KAD4COB 13/09/2023
*&---------------------------------------------------------------------*
REPORT zfi_email_aif_error.

DATA:gv_intf     TYPE /aif/ifname,
     gv_success  TYPE char10,
     gv_error    TYPE char10,
     gt_body     TYPE bcsy_text,
     gv_date     TYPE /aif/create_date,
     gv_date_ext TYPE char10.

CONSTANTS: c_ns         TYPE /aif/ns     VALUE 'ZPSINF',
           c_if_e78     TYPE /aif/ifname   VALUE 'ZE78_S4_AP',
           c_if_engie   TYPE /aif/ifname   VALUE 'ZENG_S4_AP',
           c_if_counsel TYPE /aif/ifname VALUE 'ZCOU_S4_AP'.

PARAMETERS: p_ns TYPE /aif/ns DEFAULT c_ns OBLIGATORY.
SELECT-OPTIONS: s_intf FOR gv_intf NO INTERVALS OBLIGATORY,
                s_date FOR gv_date.

START-OF-SELECTION.

  SELECT ns,ifname,status FROM /aif/std_idx_tbl INTO TABLE @DATA(gt_aif_log) "#EC CI_NOFIELD
    WHERE ns     = @p_ns
      AND ifname IN @s_intf[]
      AND create_date IN @s_date.
  IF sy-subrc IS INITIAL.
    SORT gt_aif_log BY ns ifname.
  ENDIF.

  DATA(lt_aif_log) = gt_aif_log.

  DELETE ADJACENT DUPLICATES FROM lt_aif_log COMPARING ns ifname.

  gv_date_ext = sy-datum+4(2) && '/' && sy-datum+6(2) && '/' && sy-datum+0(4) .

  LOOP AT lt_aif_log INTO DATA(ls_aif_log).
    CLEAR: gv_success, gv_error,gt_body.
    IF line_exists( gt_aif_log[ ns     = ls_aif_log-ns
                                ifname = ls_aif_log-ifname ] ).
      gv_success  = REDUCE i( INIT x = 0 FOR ls_aif_log1 IN gt_aif_log
                                           WHERE ( ns = ls_aif_log-ns AND
                                                   ifname = ls_aif_log-ifname AND
                                                   status = 'S' )
                                              NEXT x = x + 1           ).

      gv_error  = REDUCE i( INIT x = 0 FOR ls_aif_log1 IN gt_aif_log
                                           WHERE ( ns = ls_aif_log-ns AND
                                                   ifname = ls_aif_log-ifname AND
                                                   status = 'E' )
                                              NEXT x = x + 1           ).
      CONDENSE:gv_success NO-GAPS,gv_error NO-GAPS.
    ENDIF.

    gt_body = VALUE #( ( line = 'Hello,' ) ( line = |Please find the below log details on { gv_date_ext }. |  )
                       ( )
                       ( line = |Number of successful records: { gv_success }| )
                       ( line = |Number of failed records: { gv_error }| )
                       ).

    CASE ls_aif_log-ifname.
      WHEN c_if_e78.
        CALL METHOD zcl_fi_e78_ap_trans_s4=>send_email
          EXPORTING
            it_body  = gt_body
          IMPORTING
            ex_subrc = DATA(lv_subrc).
        IF lv_subrc IS INITIAL.
          WRITE:/ 'Interface:',ls_aif_log-ifname,'executed successfully.'.
        ENDIF.
      WHEN c_if_engie.
        CALL METHOD zcl_fi_engie_ap_trans_s4=>send_email
          EXPORTING
            it_body  = gt_body
          IMPORTING
            ex_subrc = lv_subrc.
        IF lv_subrc IS INITIAL.
          WRITE:/ 'Interface:',ls_aif_log-ifname,'executed successfully.'.
        ENDIF.
      WHEN c_if_counsel.
        CALL METHOD zcl_fi_counsel_link_ap_tran_s4=>send_email
          EXPORTING
            it_body  = gt_body
          IMPORTING
            ex_subrc = lv_subrc.
        IF lv_subrc IS INITIAL.
          WRITE:/ 'Interface:',ls_aif_log-ifname,'executed successfully.'.
        ENDIF.
*   WHEN .
*   WHEN OTHERS.
    ENDCASE.

  ENDLOOP.

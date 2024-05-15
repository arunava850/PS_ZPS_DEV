class ZCL_IM_FI_UPDATE_CCENTER definition
  public
  final
  create public .

public section.

  interfaces IF_EX_AC_DOCUMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_FI_UPDATE_CCENTER IMPLEMENTATION.


  METHOD if_ex_ac_document~change_after_check.

    DATA: lv_header TYPE acchd.

    CLEAR lv_header.
    lv_header = im_document-header.
    ex_document-header-bktxt = lv_header-bktxt.

  ENDMETHOD.


  METHOD if_ex_ac_document~change_initial.
*------------------------------------------------------------------------*
* Developer ID  : VCHANNA
* Developer Name: Venkat Channa
* Creation Date : Feb 5th 2024
* Jira #        : https://storage.atlassian.net/browse/SAP-1508
* DESCRIPTION   :
*------------------------------------------------------------------------*
*** CHANGE HISTORY ***
*------------------------------------------------------------------------*
* CR#           DEVELOPER    DATE        TRANSPORT   DESCRIPTION
*------------------------------------------------------------------------*
    DATA:
      lt_items         TYPE accit_t,
      lt_export_items  LIKE ex_document-item,
      lt_export_header LIKE ex_document-header,
      lwa_export_items LIKE LINE OF lt_export_items,
      lv_header        TYPE acchd.

    FIELD-SYMBOLS <fs_items> LIKE LINE OF lt_items.

    MOVE im_document-header TO lt_export_header.
    MOVE im_document-item TO lt_items.
    LOOP AT lt_items ASSIGNING <fs_items>.
      IF syst-tcode EQ 'MIGO'.
        IF <fs_items>-blart EQ 'WE'
          AND <fs_items>-hkont EQ '0000200170'
          AND <fs_items>-bukrs EQ '1000'.
          SELECT SINGLE
                 kokrs,
                 kostl,
                 datbi,
                 datab,
                 bukrs
            FROM csks
            INTO @DATA(ls_csks)
           WHERE kostl EQ @<fs_items>-kostl.
          IF ls_csks-bukrs NE '1000'.
            SELECT SINGLE *
              FROM tvarvc
              INTO @DATA(ls_tvar)
             WHERE name = 'ZCL_IM_FI_UPDATE_CCENTER'
               AND type = 'P'.
            IF ls_tvar-low NE abap_false.
              <fs_items>-kostl = ls_tvar-low.
              CLEAR lwa_export_items.
              MOVE-CORRESPONDING <fs_items> TO lwa_export_items.
              APPEND lwa_export_items TO lt_export_items.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

      IF <fs_items>-blart EQ 'RE'
        AND <fs_items>-hkont EQ '0000200170'
        AND <fs_items>-bukrs EQ '1000'.
        SELECT SINGLE
               kokrs,
               kostl,
               datbi,
               datab,
               bukrs
          FROM csks
          INTO @ls_csks
         WHERE kostl EQ @<fs_items>-kostl.
        IF ls_csks-bukrs NE '1000'.
          SELECT SINGLE *
            FROM tvarvc
            INTO @ls_tvar
           WHERE name = 'ZCL_IM_FI_UPDATE_CCENTER'
             AND type = 'P'.
          IF ls_tvar-low NE abap_false.
            <fs_items>-kostl = ls_tvar-low.
            CLEAR lwa_export_items.
            MOVE-CORRESPONDING <fs_items> TO lwa_export_items.
            APPEND lwa_export_items TO lt_export_items.
          ENDIF.
        ENDIF.
      ENDIF.

*Start of change - SAPA-142
      IF <fs_items>-blart EQ 'RE'.
        IF <fs_items>-prctr IS INITIAL AND <fs_items>-ktosl = 'DIF'.
          LOOP AT lt_items INTO DATA(ls_temp_item) WHERE ktosl = 'WRX'.
            IF ls_temp_item-prctr IS NOT INITIAL.
              READ TABLE lt_export_items ASSIGNING FIELD-SYMBOL(<lfs_exp>) WITH KEY posnr = <fs_items>-posnr.
              IF sy-subrc IS INITIAL.
                <lfs_exp>-prctr = ls_temp_item-prctr.
              ELSE.
                MOVE-CORRESPONDING <fs_items> TO lwa_export_items.
                lwa_export_items-prctr = ls_temp_item-prctr.
                APPEND lwa_export_items TO lt_export_items.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.

*End of change - SAPA-142
      ENDIF.
    ENDLOOP.

    CLEAR lv_header.
    lv_header = im_document-header.
    ex_document-header-bktxt = lv_header-bktxt.

    IF lt_export_items[] IS NOT INITIAL.
      MOVE lt_export_items TO ex_document-item.
    ENDIF.

  ENDMETHOD.


  method IF_EX_AC_DOCUMENT~IS_ACCTIT_RELEVANT.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_COMPRESSION_REQUIRED.
  endmethod.


  method IF_EX_AC_DOCUMENT~IS_SUPPRESSED_ACCT.
  endmethod.
ENDCLASS.

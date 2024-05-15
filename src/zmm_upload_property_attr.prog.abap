*&---------------------------------------------------------------------*
*& Report ZMM_UPLOAD_PROPERTY_ATTR
*&---------------------------------------------------------------------*
*& KDURAI, 11/12/2023
*&---------------------------------------------------------------------*
REPORT zmm_upload_property_attr.

TYPES: BEGIN OF ty_output,
         plant       TYPE werks_d,
         property_no TYPE zpropno,
         status      TYPE char10,
         error_text  TYPE char100,
       END OF ty_output.

TYPES: BEGIN OF ty_pc_list,
         prctr TYPE prctr,
       END OF ty_pc_list,

       BEGIN OF ty_pc_type,
         name TYPE char40,
         type TYPE char1,
       END OF ty_pc_type,

       BEGIN OF ty_rcomp,
         rcomp TYPE char6,
       END OF ty_rcomp,

       BEGIN OF ty_bukrs,
         bukrs TYPE bukrs,
       END OF ty_bukrs.

TYPES: tyt_pc_list TYPE TABLE OF ty_pc_list WITH EMPTY KEY.

DATA: gt_zproperty  TYPE TABLE OF zproperty,
      gt_output     TYPE TABLE OF ty_output,
      gt_pc_list    TYPE TABLE OF ty_pc_list,
      gv_prctr      TYPE prctr,
      gt_pc_types   TYPE TABLE OF ty_pc_type,
      gt_rcomp      TYPE TABLE OF ty_rcomp,
      gt_tax_owner  TYPE TABLE OF ty_bukrs,
      gv_field_name TYPE char40,
      gv_rcomp      TYPE char6,
      gs_input      TYPE zproperty_input_s,
      gt_fcat       TYPE lvc_t_fcat.

DATA: gv_path TYPE string.

DATA: gt_data TYPE string_table,
      gs_data TYPE string.

DATA:" lt_fcat    TYPE lvc_t_fcat,
  gv_data    TYPE string,
  gv_char200 TYPE char200,
  gv_data1   TYPE string.

FIELD-SYMBOLS: <lfs_field> TYPE any.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS :p_cre RADIOBUTTON GROUP rb1,
              p_del RADIOBUTTON GROUP rb1.
  PARAMETERS : p_file TYPE string LOWER CASE,
               p_test AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN COMMENT /1(70) Text-t01.
SELECTION-SCREEN COMMENT /1(60) Text-t02.
SELECTION-SCREEN COMMENT /1(60) Text-t03.
SELECTION-SCREEN COMMENT /1(60) Text-t04.
SELECTION-SCREEN COMMENT /1(60) Text-t06.
SELECTION-SCREEN COMMENT /1(60) Text-t07.
SELECTION-SCREEN COMMENT /1(60) Text-t08.
SELECTION-SCREEN COMMENT /1(60) Text-t09.
SELECTION-SCREEN COMMENT /1(60) Text-t10.
*SELECTION-SCREEN COMMENT /1(60) Text-t01.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM file_selection_f4.

START-OF-SELECTION.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZPROPERTY_INPUT_S'
    CHANGING
      ct_fieldcat            = gt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*  DELETE lt_fcat WHERE fieldname EQ 'MANDT'.

  gv_path = p_file.

DATA: lt_data TYPE truxs_t_text_data.
*  IF <fs_dyn_table> IS ASSIGNED.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = gv_path
*     has_field_separator     = 'X'
    CHANGING
      data_tab                = lt_data
*     isscanperformed         = SPACE
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc IS INITIAL.

    DELETE lt_data INDEX 1.

    CALL METHOD cl_rsda_csv_converter=>create
      EXPORTING
        i_delimiter = '"' "c_default_delimiter
        i_separator = cl_abap_char_utilities=>horizontal_tab "c_default_separator
      RECEIVING
        r_r_conv    = DATA(lo_csv).

    LOOP AT lt_data INTO DATA(ls_data).
*      CONCATENATE cl_abap_char_utilities=>horizontal_tab ls_data INTO ls_data.
      APPEND INITIAL LINE TO gt_zproperty
       ASSIGNING FIELD-SYMBOL(<lfs_property>).
      CLEAR gs_input.
      TRY.
          CALL METHOD lo_csv->csv_to_structure
            EXPORTING
              i_data   = ls_data
            IMPORTING
              e_s_data = gs_input.
        CATCH cx_root INTO DATA(lx_root).
          DATA(lv_error_text) = lx_root->get_text( ).
*          IF lv_error_text IS INITIAL.
            lv_error_text = text-t05."'Error while reading the file. Please check the file data.'.
*          ENDIF.
          EXIT.
      ENDTRY.
      <lfs_property> =  CORRESPONDING #( gs_input ).
    ENDLOOP.
    IF lv_error_text IS NOT INITIAL.
      MESSAGE lv_error_text TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ELSE.
    MESSAGE 'Error: Unable to read the file' TYPE 'I' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
*  ENDIF.

  SELECT * FROM zproperty_help INTO TABLE @DATA(lt_zproperty_help) "#EC CI_NOFIELD
     WHERE keyfield NE @space
    ORDER BY PRIMARY KEY.
  IF sy-subrc IS NOT INITIAL.
* SORT
  ENDIF.

  SELECT * FROM tvarvc INTO TABLE @DATA(lt_custom_f4)
     WHERE name EQ 'ZPS_ENH0014_F4_FIELDS'
    ORDER BY PRIMARY KEY.
  IF sy-subrc IS INITIAL.
    SORT lt_custom_f4 BY low.
  ENDIF.

  DATA(lt_zproperty) = gt_zproperty.
  SORT lt_zproperty BY plant.
  DELETE ADJACENT DUPLICATES FROM lt_zproperty COMPARING plant.
  IF lt_zproperty IS NOT INITIAL.
    SELECT a~werks,
           b~name1,
           a~name2,
           a~name1 AS name1_t001w,
           a~stras,
           a~pstlz,
           a~ort01,
           a~land1,
           a~regio,
           b~city2 AS counc,
           a~adrnr,
           b~fax_number,
           b~tel_number,
*           CONCAT_WITH_SPACE( b~house_num1, b~street, 1 ) AS street, " KDURAI 24/03/2024
           b~street, " KDURAI 24/03/2024
           b~house_num1, " KDURAI 24/03/2024
           b~name2 AS name2_adrc, " KDURAI 24/03/2024
           b~time_zone,
           c~smtp_addr
      FROM t001w AS a LEFT OUTER JOIN adrc AS b "#EC CI_BUFFJOIN
      ON a~adrnr = b~addrnumber
       LEFT OUTER JOIN adr6 AS c "#EC CI_BUFFJOIN
      ON a~adrnr = c~addrnumber
*      INNER JOIN @lt_zproperty AS d
*       ON a~werks = d~plant
  FOR ALL ENTRIES IN @lt_zproperty
  WHERE werks = @lt_zproperty-plant
       INTO TABLE @DATA(lt_t001w_adrc).
    IF sy-subrc IS INITIAL.
      SORT lt_t001w_adrc BY werks.
      LOOP AT lt_t001w_adrc INTO DATA(ls_t001w_adrc).
        gv_prctr = ls_t001w_adrc-name2.
        APPEND LINES OF VALUE tyt_pc_list( ( prctr = |{ gv_prctr ALPHA = IN }| ) "Storage_cbt
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'A' }| ) " Retail
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'R' }| ) " Storage
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'T' }| ) " Tennant
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'C' }| ) " Communicat
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'M' }| ) " Management
                                 ( prctr = |{ ls_t001w_adrc-name2 && 'E' }| ) " Energy
                                 ) TO gt_pc_list.
*         gt_pc_list
      ENDLOOP.
      IF gt_pc_list[] IS NOT INITIAL.
        SELECT a~prctr,
               a~datbi,
               a~datab,
               a~name1,
               a~name2,
               a~segment,
               b~bukrs,
               c~ltext
               FROM cepc  AS a INNER JOIN
               cepc_bukrs AS b
               ON a~prctr = b~prctr
               LEFT OUTER JOIN cepct AS c "#EC CI_BUFFJOIN
               ON c~prctr = a~prctr
               INTO TABLE @DATA(lt_cepc)
              FOR ALL ENTRIES IN @gt_pc_list
               WHERE a~prctr = @gt_pc_list-prctr.
        IF sy-subrc IS INITIAL.
          SORT lt_cepc BY prctr.
        ENDIF.
      ENDIF.
    ENDIF.

    gt_pc_types = VALUE #( ( name = 'RETAIL_PC'      type = 'A' )
                           ( name = 'STORAGE_PC'     type = 'R' )
                           ( name = 'TENNENT_INS_PC' type = 'T' )
                           ( name = 'COMMERCIAL_PC'  type = 'C' )
                           ( name = 'MANAGMENT_PC'   type = 'M' )
                           ( name = 'SOLAR_ENERGY'   type = 'E' )
                           ( name = 'STORAGE_CBT_PC' type = ' ' )  ).
  ENDIF.

*  gt_tax_owner = CORRESPONDING #( gt_zproperty MAPPING bukrs = tax_owner ).
*  SORT gt_tax_owner BY bukrs.
*  DELETE ADJACENT DUPLICATES FROM gt_tax_owner COMPARING bukrs.
*  IF gt_tax_owner[] IS NOT INITIAL.
*    SELECT bukrs FROM t001 INTO TABLE @DATA(lt_t001)
*      FOR ALL ENTRIES IN @gt_tax_owner
*      WHERE bukrs = @gt_tax_owner-bukrs.
*    IF sy-subrc IS INITIAL.
*      SORT lt_t001 BY bukrs.
*    ENDIF.
*
*    SELECT bukrs,paval FROM t001z INTO TABLE @DATA(lt_t001z)
*      FOR ALL ENTRIES IN @gt_tax_owner
*      WHERE bukrs = @gt_tax_owner-bukrs
*        AND party = 'USFTIN'.
*    IF sy-subrc IS INITIAL.
*      SORT lt_t001z BY bukrs.
*    ENDIF.
*  ENDIF.
*
*  DATA(lt_zproperty_tmp) = gt_zproperty.
*  SORT lt_zproperty_tmp BY legal_owner.
*  DELETE ADJACENT DUPLICATES FROM lt_zproperty_tmp COMPARING legal_owner.
*  LOOP AT lt_zproperty_tmp ASSIGNING FIELD-SYMBOL(<lfs_cepc_tmp>).
*    APPEND INITIAL LINE TO gt_rcomp ASSIGNING FIELD-SYMBOL(<lfs_rcomp>).
*    <lfs_rcomp>-rcomp = <lfs_cepc_tmp>-legal_owner.
*    <lfs_rcomp>-rcomp = |{ <lfs_rcomp>-rcomp ALPHA = IN }|.
*  ENDLOOP.
*  SELECT rcomp,zlegal_own_fein
*    FROM t880 INTO TABLE @DATA(lt_t880)
*    FOR ALL ENTRIES IN @gt_rcomp
*    WHERE rcomp = @gt_rcomp-rcomp.
*  IF sy-subrc IS INITIAL.
*    SORT lt_t880 BY rcomp.
*  ENDIF.

  CLEAR: lt_zproperty.

  IF p_del IS NOT INITIAL.
    IF gt_zproperty[] IS NOT INITIAL.
      SELECT * FROM zproperty INTO TABLE @DATA(lt_zproperty_1)
        FOR ALL ENTRIES IN @gt_zproperty
        WHERE plant = @gt_zproperty-plant.
      IF sy-subrc IS INITIAL.
*        lt_zproperty = lt_zproperty_1.
      ELSE.
        CLEAR lt_zproperty.
      ENDIF.
    ENDIF.
  ENDIF.

  LOOP AT gt_zproperty INTO DATA(ls_zproperty).

    ASSIGN ls_zproperty TO FIELD-SYMBOL(<lfs_zproperty>).

    APPEND INITIAL LINE TO gt_output ASSIGNING FIELD-SYMBOL(<lfs_output>).
    <lfs_output>-plant = <lfs_zproperty>-plant.
    READ TABLE lt_t001w_adrc INTO ls_t001w_adrc WITH KEY werks = <lfs_zproperty>-plant
                                            BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_zproperty>-legacy_property_number = ls_t001w_adrc-name2.
      <lfs_output>-property_no = ls_t001w_adrc-name2.
      IF ls_t001w_adrc-name2 IS INITIAL.
       <lfs_output>-status = 'ERROR'.
       <lfs_output>-error_text = 'Property number does not exists in SAP'.
      ENDIF.
    ELSE.
      <lfs_output>-status = 'ERROR'.
      <lfs_output>-error_text = 'Plant is not exists in T001W'.
*      CONTINUE.
    ENDIF.
    IF p_del IS NOT INITIAL.
      IF NOT line_exists( lt_zproperty_1[ plant =  <lfs_zproperty>-plant ] ).
        <lfs_output>-status = 'ERROR'.
        <lfs_output>-error_text = 'Plant is not exists in table ZPROPERTY'.
      ELSE.
        <lfs_output>-status = 'SUCCESS'.
        CLEAR <lfs_output>-error_text.
      ENDIF.
      APPEND ls_zproperty TO lt_zproperty.
      CONTINUE.
    ENDIF.
    IF <lfs_output>-status IS INITIAL.
      CLEAR: gv_data.
      LOOP AT gt_fcat INTO DATA(ls_fcat) .
        DATA(gv_tabix) = sy-tabix.
        UNASSIGN <lfs_field>.
        ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
        IF <lfs_field> IS ASSIGNED.
          gv_data = CONV #( <lfs_field> ).
          gv_char200 = gv_data.
          gv_data = gv_char200.

          IF ls_fcat-datatype EQ 'DATS' AND <lfs_field> IS NOT INITIAL.
            CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
              EXPORTING
                date                      = <lfs_field>
              EXCEPTIONS
                plausibility_check_failed = 1
                OTHERS                    = 2.
            IF sy-subrc <> 0.
              <lfs_output>-status = 'ERROR'.
              <lfs_output>-error_text = 'Invalid date format.'.
              EXIT.
            ENDIF.
          ENDIF.

          IF ls_fcat-datatype EQ 'TIMS' AND <lfs_field> IS NOT INITIAL.
            CALL FUNCTION 'TIME_CHECK_PLAUSIBILITY'
              EXPORTING
                time                      = <lfs_field>
              EXCEPTIONS
                plausibility_check_failed = 1
                OTHERS                    = 2.
            IF sy-subrc <> 0.
              <lfs_output>-status = 'ERROR'.
              <lfs_output>-error_text = 'Invalid time format.'.
              EXIT.
            ENDIF.
          ENDIF.

          IF gv_data IS NOT INITIAL.
            READ TABLE lt_custom_f4 INTO DATA(ls_custom_f4)
                                    WITH KEY low = ls_fcat-fieldname.
            IF sy-subrc IS INITIAL.
              READ TABLE lt_zproperty_help INTO DATA(ls_zproperty_help)
                                      WITH KEY keyfield = ls_custom_f4-high
                                               code = gv_data
                                      BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                <lfs_field> = gv_data.
              ELSE.
                <lfs_output>-status = 'ERROR'.
                <lfs_output>-error_text = 'keycode is not defined in table ZPROPERTY_HELP'.
                CONCATENATE 'Field' ls_custom_f4-low <lfs_output>-error_text INTO <lfs_output>-error_text
                 SEPARATED BY space.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF <lfs_output>-status IS INITIAL.
*// Default fields to fill from SAP

      <lfs_zproperty>-legacy_property_number = ls_t001w_adrc-name2.
      <lfs_zproperty>-description            = ls_t001w_adrc-name2_adrc. " ls_t001w_adrc-name1_t001w.
      <lfs_zproperty>-mailing_name           = ls_t001w_adrc-name1.
      <lfs_zproperty>-street                 = |{ ls_t001w_adrc-house_num1 && | | && ls_t001w_adrc-street }|." ls_t001w_adrc-stras.
      <lfs_zproperty>-city                   = ls_t001w_adrc-ort01.
      <lfs_zproperty>-state                  = ls_t001w_adrc-regio.
      <lfs_zproperty>-postal_code            = ls_t001w_adrc-pstlz.
      <lfs_zproperty>-county                 = ls_t001w_adrc-counc.
      <lfs_zproperty>-country                = ls_t001w_adrc-land1.
      <lfs_zproperty>-property_email_address = ls_t001w_adrc-smtp_addr.
      <lfs_zproperty>-fax_number             = ls_t001w_adrc-fax_number.
      <lfs_zproperty>-direct_phone_no        = ls_t001w_adrc-tel_number.
      <lfs_zproperty>-time_zone              = ls_t001w_adrc-time_zone.

      IF <lfs_zproperty>-plant BETWEEN 'A001' AND 'V999'.
        <lfs_zproperty>-property_type = 'O'.
      ELSEIF <lfs_zproperty>-plant BETWEEN 'W001' AND 'Z999'.
        <lfs_zproperty>-property_type = 'T'.
      ENDIF.


*      gv_prctr = ls_t001w_adrc-name2.
*      gv_prctr = |{ gv_prctr ALPHA = IN }|.
*      READ TABLE lt_cepc INTO DATA(ls_cepc)
*                         WITH KEY prctr = gv_prctr
*                         BINARY SEARCH.
*      IF sy-subrc IS INITIAL.
*      IF line_exists( lt_t001z[ bukrs = <lfs_zproperty>-tax_owner ] ).
*        <lfs_zproperty>-tax_owner_fein = lt_t001z[ bukrs = <lfs_zproperty>-tax_owner ]-paval.
*      ENDIF.
*      IF NOT line_exists( lt_t001[ bukrs = <lfs_zproperty>-tax_owner ] ).
*        <lfs_output>-status = 'ERROR'.
*        <lfs_output>-error_text = 'Tax Owner does not exists in SAP'.
*        CONTINUE.
*      ENDIF.
*      gv_rcomp = <lfs_zproperty>-legal_owner.
*      gv_rcomp = |{ gv_rcomp ALPHA = IN }|.
*      IF line_exists( lt_t880[ rcomp = gv_rcomp ] ).
*        <lfs_zproperty>-legal_owner_fein = lt_t880[ rcomp = gv_rcomp ]-zlegal_own_fein.
*      ELSE.
*        <lfs_output>-status = 'ERROR'.
*        <lfs_output>-error_text = 'Legal Owner does not exists in SAP'.
*        CONTINUE.
*      ENDIF.
*      ENDIF.

*// Profit center related fields
      LOOP AT gt_pc_types INTO DATA(ls_pc_type).
        IF ls_pc_type-type IS INITIAL.
          gv_prctr = ls_t001w_adrc-name2.
          gv_prctr = |{ gv_prctr ALPHA = IN }|.
        ELSE.
          gv_prctr = ls_t001w_adrc-name2 && ls_pc_type-type.
        ENDIF.
        READ TABLE lt_cepc INTO DATA(ls_cepc)
                           WITH KEY prctr = gv_prctr
                           BINARY SEARCH.
        IF sy-subrc IS INITIAL.

*// PC
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = gv_prctr.
          ENDIF.
*// LTEXT
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name && '_LTEXT'.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = ls_cepc-ltext.
          ENDIF.
*// CC
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name && '_CC'.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = ls_cepc-bukrs.
          ENDIF.
*// FROM_DATE
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name && '_FROM_DATE'.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = ls_cepc-datab.
          ENDIF.
*// TO_DATE
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name && '_TO_DATE'.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = ls_cepc-datbi.
          ENDIF.
*// SEGMENT
          UNASSIGN <lfs_field>.
          gv_field_name = ls_pc_type-name && '_SEGMENT'.
          ASSIGN COMPONENT gv_field_name OF STRUCTURE <lfs_zproperty> TO <lfs_field>.
          IF <lfs_field> IS ASSIGNED.
            CLEAR: <lfs_field>.
            <lfs_field> = ls_cepc-segment.
          ENDIF.
        ENDIF.
      ENDLOOP.

      <lfs_zproperty>-changed_by = sy-uname.
      <lfs_zproperty>-changed_date = sy-datum.
      <lfs_zproperty>-changed_time = sy-uzeit.

    ENDIF.

    IF <lfs_output>-status IS INITIAL.
      <lfs_output>-status = 'SUCCESS'.
      APPEND ls_zproperty TO lt_zproperty.
    ENDIF.

  ENDLOOP.

  IF p_del IS NOT INITIAL.
    lt_zproperty = lt_zproperty_1.
  ENDIF.

  IF p_test IS INITIAL AND lt_zproperty[] IS NOT INITIAL.
    IF p_cre IS NOT INITIAL.
      MODIFY zproperty FROM TABLE lt_zproperty.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data has been processed' TYPE 'S'.
      ENDIF.
    ENDIF.
    IF p_del IS NOT INITIAL.
      DELETE zproperty FROM TABLE lt_zproperty.
      IF sy-subrc IS INITIAL.
        COMMIT WORK AND WAIT.
        MESSAGE 'Data has been deleted' TYPE 'S'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_output[] IS NOT INITIAL .
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_alv)
                                CHANGING  t_table   = gt_output ).
        IF lo_alv IS BOUND.

          DATA(lo_func) = lo_alv->get_functions( ).
          lo_func->set_all( abap_true ).

          DATA(lo_columns) = lo_alv->get_columns( ).
          lo_columns->set_optimize( abap_true ).
          DATA(lt_cols)    = lo_columns->get( ).

          DATA: gv_short  TYPE scrtext_s,
                gv_med    TYPE scrtext_m,
                gv_long   TYPE scrtext_l,
                lo_column TYPE REF TO  cl_salv_column_list.

          LOOP AT lt_cols INTO DATA(ls_cols).
            lo_column ?= ls_cols-r_column.    "Narrow casting

            gv_short = ls_cols-columnname.
            lo_column->set_short_text( gv_short ).

            gv_med = ls_cols-columnname.
            lo_column->set_medium_text( gv_med ).

            gv_long = ls_cols-columnname.
            lo_column->set_long_text( gv_long ).
          ENDLOOP.

          lo_alv->display( ).

        ENDIF.
      CATCH cx_salv_msg.
        MESSAGE 'ALV display error.' TYPE 'I'.
    ENDTRY.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form file_selection_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM file_selection_f4 .
  DATA: gt_filetab  TYPE filetable,
        gs_filetab  TYPE file_table,
        g_fo_title  TYPE string,
        g_fo_rc     TYPE i,
        g_fo_action TYPE i.

**
* DATA: lv_file TYPE IBIPPARMS-PATH.
*  CALL FUNCTION 'F4_FILENAME'
*    IMPORTING
*      file_name = lv_file.
***
  g_fo_title = TEXT-fo1.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = g_fo_title
*     file_filter             = '(*.csv*)' "#EC NOTEXT
    CHANGING
      file_table              = gt_filetab
      rc                      = g_fo_rc
      user_action             = g_fo_action
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc = 0 AND
     g_fo_action = cl_gui_frontend_services=>action_ok.
*   get file name
    READ TABLE gt_filetab INDEX 1 INTO gs_filetab.
    IF sy-subrc = 0.
      p_file  = gs_filetab-filename.
    ENDIF.
  ENDIF.
ENDFORM.

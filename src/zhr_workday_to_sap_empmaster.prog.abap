*&---------------------------------------------------------------------*
*& Report ZHR_WORKDAY_TO_SAP_EMPMASTER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhr_workday_to_sap_empmaster.

TYPES: BEGIN OF ty_file_data,
         wdeeid     TYPE char20,
         stat2      TYPE c,
         persk      TYPE char40,
         vorna      TYPE vorna,
         nachn      TYPE nachn,
         kostl      TYPE kostl,
         usrid_long TYPE char50,
         plans      TYPE plans,
         orgeh      TYPE orgeh,
         mgrid      TYPE plans,
         mgrpo      TYPE orgeh,
       END OF ty_file_data.

TYPES: BEGIN OF ty_final,
         icon   TYPE char4,
         wdeeid TYPE char20,
         pernr  TYPE p0001-pernr,
         messg  TYPE char100,
       END OF   ty_final.

TYPES: BEGIN OF ty_hr_new_hire,
         pernr TYPE p0001-pernr,
       END OF ty_hr_new_hire.

TYPES: BEGIN OF ty_csks,
         kostl TYPE csks-kostl,
         name2 TYPE csks-name2,
         stras TYPE csks-stras,
         ort01 TYPE csks-ort01,
         regio TYPE csks-regio,
         pstlz TYPE csks-pstlz,
         land1 TYPE csks-land1,
       END OF ty_csks,
       t_body_msg TYPE solisti1.

DATA: gt_csks TYPE TABLE OF ty_csks,
      gw_csks TYPE ty_csks.

DATA: it_file_data    TYPE STANDARD TABLE OF ty_file_data,
      wa_file_data    TYPE  ty_file_data,
      wa_record(1000) TYPE c,
      gt_output       TYPE TABLE OF ty_hr_new_hire WITH HEADER LINE.


DATA : li_proposed LIKE pprop OCCURS 0 WITH HEADER LINE,
       lw_rc       LIKE bapireturn,
       lw_rc1      LIKE bapireturn1,
       lw_hr       TYPE hrhrmm_msg.

DATA: gt_final    TYPE TABLE OF ty_final,
      gw_final    TYPE ty_final,
      gt_fcat     TYPE slis_t_fieldcat_alv,
      gw_fcat     TYPE slis_fieldcat_alv,
      gt_body_msg TYPE STANDARD TABLE OF t_body_msg,
      gw_body_msg TYPE t_body_msg..

DATA: gv_stext TYPE stext,
      gv_cnt   TYPE i.

CONSTANTS : gc_x TYPE c VALUE 'X'.

SELECTION-SCREEN BEGIN OF LINE.
*    PARAMETERS: p_fildet AS CHECKBOX.
  SELECTION-SCREEN COMMENT 3(29) TEXT-001 FOR FIELD p_flname.
  PARAMETERS: p_flname LIKE rlgrap-filename OBLIGATORY.             "path of detail file
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN: BEGIN OF LINE.
  SELECTION-SCREEN: COMMENT 3(29) TEXT-002 FOR FIELD p_archv.
  PARAMETERS: p_archv AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
  SELECTION-SCREEN COMMENT 3(29) TEXT-003 FOR FIELD p_rec.         "Email
  PARAMETERS: p_rec TYPE somlreci1-receiver.
SELECTION-SCREEN END OF LINE.
PARAMETERS: p_flpath LIKE rlgrap-filename NO-DISPLAY.             "path of detail file

INITIALIZATION.
  CONCATENATE 'WDEMP_INT79_' sy-datum+2(2) sy-datum+4(2) sy-datum+6(2)  '*'   INTO   p_flname.




START-OF-SELECTION.
  PERFORM upload_data.
  IF it_file_data IS NOT INITIAL.
    PERFORM load_emp_data.
  ENDIF.

  IF gt_final IS  NOT INITIAL .
    PERFORM display_alv.
    IF p_rec IS NOT INITIAL.
      PERFORM send_excel  USING 'Workday Employee Mini Master upload'.
    ENDIF.

  ENDIF.



END-OF-SELECTION.
*********************    FORMS     ************************************

*&---------------------------------------------------------------------*
*& Form upload_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM upload_data .
  DATA: lv_archive  TYPE rlgrap-filename,
        lv_str      TYPE string,
        lt_dir      TYPE TABLE OF epsfili,
        lv_dir      TYPE epsf-epsdirnam,
        lv_filename TYPE epsf-epsfilnam.

  "Fetch the file
  lv_dir = '/interfaces/workerstable/INT0079/in/'.
  lv_filename = p_flname.

  CLEAR  p_flpath.
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = lv_dir
      file_mask              = lv_filename
*   IMPORTING
*     DIR_NAME               =
*     FILE_COUNTER           =
*     ERROR_COUNTER          =
    TABLES
      dir_list               = lt_dir
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.
  IF sy-subrc <> 0.
    CLEAR  p_flpath.
  ELSE.
    READ TABLE lt_dir INTO DATA(ls_dir) INDEX 1.
    IF sy-subrc = 0.
      CONCATENATE lv_dir ls_dir-name INTO p_flpath.
    ELSE.
      CLEAR  p_flpath.
    ENDIF.
  ENDIF.





  IF  p_flpath IS NOT INITIAL.
    OPEN DATASET p_flpath FOR INPUT IN TEXT MODE
         ENCODING DEFAULT WITH SMART LINEFEED.
    IF sy-subrc = 0 .
      READ DATASET p_flpath INTO wa_record.
      WHILE sy-subrc EQ 0.

        SPLIT wa_record AT '|' INTO wa_file_data-wdeeid
                                    wa_file_data-stat2
                                    wa_file_data-persk
                                    wa_file_data-vorna
                                    wa_file_data-nachn
                                    wa_file_data-kostl
                                    wa_file_data-usrid_long
                                    wa_file_data-plans
                                    wa_file_data-orgeh
                                    wa_file_data-mgrid
                                    wa_file_data-mgrpo.

        APPEND wa_file_data TO it_file_data.
        CLEAR:wa_file_data.
        READ DATASET p_flpath INTO wa_record.
      ENDWHILE.
      CLOSE DATASET p_flpath.
    ENDIF.
  ENDIF.

  DELETE it_file_data INDEX 1.      "delete header texts

  "Archive File
  IF  p_archv IS NOT INITIAL
  AND it_file_data IS NOT INITIAL.
    CLEAR : lv_archive.
    lv_archive = p_flpath.
    REPLACE ALL OCCURRENCES OF '/in/' IN lv_archive WITH '/archive/'.

    OPEN DATASET p_flpath FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    OPEN DATASET lv_archive FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    DO.
      CLEAR lv_str.
      READ DATASET p_flpath INTO lv_str.
      IF sy-subrc EQ 0.
        TRANSFER lv_str TO lv_archive.
      ELSE.
        IF lv_str IS NOT INITIAL.
          TRANSFER lv_str TO lv_archive.
        ENDIF.
        EXIT.
      ENDIF.
    ENDDO.
    CLOSE DATASET p_flpath.
    CLOSE DATASET lv_archive.

    DELETE DATASET p_flpath.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_emp_data
*&---------------------------------------------------------------------*
FORM load_emp_data .

  DATA: lv_val         LIKE pprop-fval,
        lv_persk       LIKE p0001-persk,
        lv_position    TYPE hrobjid,
        lv_REALO       TYPE realo,
        lv_pnalt       TYPE pnalt,
        lv_cost_center TYPE pd_objid_r,
        ls_workday_emp TYPE zhr_workday_emp,
        lt_workday_emp TYPE TABLE OF zhr_workday_emp,
        ls_pa0032      TYPE pa0032,
        lt_pa0032      TYPE TABLE OF pa0032,
        ls_pa0001      TYPE pa0001,
        lt_pa0001      TYPE TABLE OF pa0001.



  " Fetch cost center details
  IF it_file_data IS NOT INITIAL.
    SELECT kostl name2 stras ort01 regio pstlz land1 FROM csks INTO TABLE gt_csks FOR ALL ENTRIES IN it_file_data
    WHERE kostl = it_file_data-kostl.
  ENDIF.

  IF it_file_data IS NOT INITIAL.
    SELECT * FROM zhr_workday_emp INTO TABLE lt_workday_emp FOR ALL ENTRIES IN it_file_data
    WHERE wdeeid = it_file_data-wdeeid+0(8).
    SELECT * FROM pa0032 INTO TABLE lt_pa0032 FOR ALL ENTRIES IN it_file_data
                                  WHERE endda >= sy-datum
                                  AND   begda <= sy-datum
    AND   pnalt = it_file_data-wdeeid+0(12).
    IF sy-subrc = 0.
      SELECT * FROM pa0001 INTO TABLE lt_pa0001 FOR ALL ENTRIES IN lt_pa0032
                                    WHERE pernr = lt_pa0032-pernr
                                    AND   endda >= sy-datum
      AND   begda <= sy-datum.
    ENDIF.
  ENDIF.


  LOOP AT it_file_data INTO wa_file_data.
    CLEAR: lv_persk, lv_val, lv_position, gv_stext, gw_final, lv_pnalt, lv_cost_center, gw_csks,
           lv_realo.
    REFRESH : li_proposed.

    "Check if sap employee exists for the weeid(workday emp id)
    "create employee if not already created
    READ TABLE lt_pa0032 INTO ls_pa0032 WITH KEY pnalt = wa_file_data-wdeeid.

    IF sy-subrc <> 0.

      "Create Position
      gv_stext = wa_file_data-persk+2(38).
      CALL FUNCTION 'RH_OBJECT_CREATE'
        EXPORTING
*         langu               = SY-LANGU
          plvar               = '01'
          otype               = 'S'
*         ext_number          = '00000000'
*         short               = ' '
          stext               = gv_stext
*         begda               = SY-DATUM
*         endda               = '99991231'
*         ostat               = '1'
*         vtask               = 'D'
*         guid                =
*         keep_lupd           = ' '
        IMPORTING
          objid               = lv_position
        EXCEPTIONS
          text_required       = 1
          invalid_otype       = 2
          invalid_date        = 3
          error_during_insert = 4
          error_ext_number    = 5
          undefined           = 6
          OTHERS              = 7.
      IF sy-subrc <> 0.
*     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      lv_val =  sy-datum.
      PERFORM fill TABLES li_proposed USING '0000'
      'P0000-BEGDA'
      lv_val.
      CLEAR lv_val.

      lv_val = 'ZA'.
      PERFORM fill TABLES li_proposed USING '0000'
      'P0000-MASSN'
      lv_val.
      CLEAR lv_val.

      lv_val = '01'.
      PERFORM fill TABLES li_proposed USING '0000'
      'P0000-MASSG'
      lv_val.
      CLEAR lv_val.

      lv_val = 'PSUS'.
      PERFORM fill TABLES li_proposed USING '0001'
      'P0001-BTRTL'                                              "Personnel sub area
      lv_val.
      CLEAR lv_val.

      lv_val = '1'.
      PERFORM fill TABLES li_proposed USING '0001'
      'P0001-PERSG'                                              "Employee Group
      lv_val.
      CLEAR lv_val.

*      CONCATENATE '0'  wa_file_data-persk+0(1) INTO lv_persk.
      lv_persk = wa_file_data-persk+0(2).
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_persk
        IMPORTING
          output = lv_persk.

      lv_val = lv_persk.
      PERFORM fill TABLES li_proposed USING '0001'              "Employee Sub Group
      'P0001-PERSK'
      lv_val.
      CLEAR lv_val.

      lv_val = wa_file_data-kostl.
      PERFORM fill TABLES li_proposed USING '0001'              "Org Unit
      'P0001-KOSTL'
      lv_val.
      CLEAR lv_val.

      lv_val = wa_file_data-vorna.                                 "First Name
      PERFORM fill TABLES li_proposed USING '0002'
      'P0002-VORNA'
      lv_val.

      lv_val = wa_file_data-nachn.                                    "Last name
      PERFORM fill TABLES li_proposed USING '0002'
      'P0002-NACHN'
      lv_val.

      lv_val = '20000101'.                         "Date of birth
      PERFORM fill TABLES li_proposed USING '0002'
      'P0002-GBDAT'
      lv_val.
      CLEAR lv_val.

      lv_val = 'US'.
      PERFORM fill TABLES li_proposed USING '0002'
      'P0002-NATIO'
      lv_val.
      CLEAR lv_val.

*    "P0006 - Address
      CLEAR : gw_csks.
      READ TABLE gt_csks INTO gw_csks WITH KEY wa_file_data-kostl.
      IF sy-subrc = 0.
        lv_val = sy-datum.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-BEGDA'
        lv_val.
        CLEAR lv_val.

        lv_val =  gw_csks-stras.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-STRAS'
        lv_val.
        CLEAR lv_val.

        lv_val =   gw_csks-ort01.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-ORT01'
        lv_val.
        CLEAR lv_val.

        lv_val =  gw_csks-regio.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-STATE'
        lv_val.
        CLEAR lv_val.

        lv_val =  gw_csks-pstlz.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-PSTLZ'
        lv_val.
        CLEAR lv_val.

        lv_val =  gw_csks-land1.
        PERFORM fill TABLES li_proposed USING '0006'
        'P0006-LAND1'
        lv_val.
        CLEAR lv_val.

      ENDIF.
*    "P0105 - Communications
      IF wa_file_data-usrid_long IS NOT INITIAL.
        lv_val =  wa_file_data-usrid_long.
      ELSE.
        lv_val =  '999@publicstorage.com'.
      ENDIF.

      PERFORM fill TABLES li_proposed USING '0105'
      'P0105-USRID_LONG'
      lv_val.
      CLEAR lv_val.

*    "P0032 - Internal Data
      lv_val =  wa_file_data-wdeeid.
      PERFORM fill TABLES li_proposed USING '0032'
      'P0032-PNALT'
      lv_val.
      CLEAR lv_val.

*lv_val.
      CLEAR: lw_rc, lw_rc1, lw_hr.
      CALL FUNCTION 'HR_MAINTAIN_MASTERDATA'
        EXPORTING
          pernr              = '00000000'
          massn              = 'ZA'                      "check the code wip
          actio              = 'INS'     "'01'
          tclas              = 'A'
          no_existence_check = 'X'
          dialog_mode        = '0'          "'0'                "'2'
          luw_mode           = '1'            " '2'
          no_enqueue         = 'X'
          begda              = '20231101'
          werks              = 'PSUS'
          persg              = '1'
          persk              = lv_persk
          plans              = lv_position          " wa_file_data-plans "test code -
        IMPORTING
          return             = lw_rc
          return1            = lw_rc1
          hr_return          = lw_hr
        TABLES
          proposed_values    = li_proposed.

      IF lw_rc-type NE 'E'.                           "Success

        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.

        gw_final-icon    = icon_green_light.
        gw_final-wdeeid = wa_file_data-wdeeid.
        GET PARAMETER ID 'PER' FIELD gw_final-pernr.
        gw_final-messg = |Employee { gw_final-pernr } is created. |.
        APPEND gw_final TO  gt_final.

        CLEAR ls_workday_emp.
        ls_workday_emp-pernr      = gw_final-pernr.
        ls_workday_emp-plans      = lv_position.
        ls_workday_emp-wdeeid     = wa_file_data-wdeeid.
        ls_workday_emp-wd_plans   = wa_file_data-plans .
        ls_workday_emp-wd_orgid   = wa_file_data-orgeh.
        INSERT zhr_workday_emp FROM ls_workday_emp.

        "Assign Employee to Position. Relation A008
        PERFORM create_relation
          USING
            lv_position
            gw_final-pernr
            '008'
            lv_realo.
        "Assign Emp. Position to Mgr. Position . Relation A002
        IF wa_file_data-mgrid IS NOT INITIAL.
          lv_pnalt = wa_file_data-mgrid.
          SELECT SINGLE plans INTO @DATA(lv_mgr_pos)
                              FROM pa0001 AS a INNER JOIN pa0032 AS b
                              ON a~pernr = b~pernr
          WHERE b~pnalt = @lv_pnalt.
          IF sy-subrc = 0.
            PERFORM create_relation
              USING
                lv_position
                lv_mgr_pos
                '002'
                lv_realo.
          ENDIF.
        ENDIF.

        "Assign Cost Center to Position
        IF gw_csks-kostl IS NOT INITIAL.                                    " wa_file_data-kostl IS NOT INITIAL.
          lv_cost_center =  gw_csks-kostl.                  " wa_file_data-kostl.
          CONCATENATE gw_csks-kostl 'PSCO' INTO  lv_realo.
*        lv_cost_center = ''
          PERFORM create_relation
            USING
              lv_position
              lv_cost_center
              '011'
              lv_realo.
        ENDIF.


      ELSE.
        gw_final-icon   = icon_red_light.
        gw_final-wdeeid = wa_file_data-wdeeid.
        gw_final-messg = lw_rc-message.
        APPEND gw_final TO  gt_final. CLEAR gw_final.
      ENDIF.

    ELSE.                                                      "Employee already created

      "Change employee When: 1. Emp.Sub-group is changed
      CLEAR lv_persk.
      lv_persk  =  wa_file_data-persk+0(2).
      lv_persk  = |{ lv_persk ALPHA  = IN }|.
      READ TABLE lt_pa0001 INTO ls_pa0001 WITH KEY pernr = ls_pa0032-pernr.
      IF sy-subrc = 0 AND
         lv_persk  <>  ls_pa0001-persk .

        lv_val =  sy-datum.
        PERFORM fill TABLES li_proposed USING '0000'
        'P0000-BEGDA'
        lv_val.
        CLEAR lv_val.

        lv_val = 'ZF'.
        PERFORM fill TABLES li_proposed USING '0000'
        'P0000-MASSN'
        lv_val.
        CLEAR lv_val.

        lv_val = '01'.
        PERFORM fill TABLES li_proposed USING '0000'
        'P0000-MASSG'
        lv_val.
        CLEAR lv_val.

        lv_val = lv_persk.
        PERFORM fill TABLES li_proposed USING '0001'              "Employee Sub Group
        'P0001-PERSK'
        lv_val.
        CLEAR lv_val.

        CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
          EXPORTING
            number = ls_pa0032-pernr
*         IMPORTING
*           RETURN =
*           LOCKING_USER       =
          .


        CLEAR: lw_rc, lw_rc1, lw_hr.
        CALL FUNCTION 'HR_MAINTAIN_MASTERDATA'
          EXPORTING
            pernr              = ls_pa0032-pernr
            massn              = 'ZF'                      "check the code wip
            actio              = 'COP'     "'01'
            tclas              = 'A'
            no_existence_check = 'X'
            dialog_mode        = '0'          "'0'                "'2'
            luw_mode           = '1'            " '2'
            no_enqueue         = 'X'
            begda              = sy-datum
            werks              = 'PSUS'
            persg              = '1'
            persk              = lv_persk
            plans              = lv_position          " wa_file_data-plans "test code -
          IMPORTING
            return             = lw_rc
            return1            = lw_rc1
            hr_return          = lw_hr
          TABLES
            proposed_values    = li_proposed.

        IF lw_rc-type NE 'E'.                           "Success

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

          gw_final-icon    = icon_green_light.
          gw_final-wdeeid = wa_file_data-wdeeid.
          gw_final-pernr  = ls_pa0032-pernr.
          gw_final-messg = |Employee { gw_final-pernr } is changed. |.
          APPEND gw_final TO  gt_final.
        ELSE.
          gw_final-icon   = icon_red_light.
          gw_final-wdeeid = wa_file_data-wdeeid.
          gw_final-messg = lw_rc-message.
          APPEND gw_final TO  gt_final. CLEAR gw_final.
        ENDIF.

      ELSE.
        READ TABLE lt_pa0001 INTO ls_pa0001 WITH KEY pernr = ls_pa0032-pernr.
        IF sy-subrc = 0.
          "Assign Emp. Position to Mgr. Position . Relation A002
          IF wa_file_data-mgrid IS NOT INITIAL.
            lv_pnalt = wa_file_data-mgrid.
            SELECT SINGLE plans INTO @lv_mgr_pos
                                FROM pa0001 AS a INNER JOIN pa0032 AS b
                                ON a~pernr = b~pernr
            WHERE b~pnalt = @lv_pnalt.
            IF sy-subrc = 0.
              PERFORM create_relation
                USING
                  ls_pa0001-plans
                  lv_mgr_pos
                  '002'
                  lv_realo.
              gw_final-icon   = icon_green_light.
              gw_final-wdeeid = wa_file_data-wdeeid.
              gw_final-pernr  = ls_pa0001-pernr.
              gw_final-messg = |Employee { gw_final-pernr } is Manager position { lv_mgr_pos } .  |.
              APPEND gw_final TO  gt_final.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form load_emp_data
*&---------------------------------------------------------------------*
FORM fill TABLES loc_proposed_values STRUCTURE pprop
USING infty LIKE pprop-infty
fname LIKE pprop-fname
fval LIKE pprop-fval.
* seqnr LIKE pprop-seqnr.

  DATA: wa_values LIKE pprop.

  wa_values-infty = infty.
  wa_values-fname = fname.
  wa_values-fval = fval.
* wa_values-seqnr = seqnr.
  APPEND wa_values TO loc_proposed_values.

ENDFORM. "fill
*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv .
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

  gw_fcat-fieldname = 'WDEEID'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 20.
  gw_fcat-seltext_l = 'Workday EMPID'.
  gw_fcat-tabname = 'GT_FINAL'.
  gw_fcat-icon = gc_x.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'PERNR'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 8.
  gw_fcat-seltext_l = 'Persn. No.'.
  gw_fcat-tabname = 'GT_FINAL'.
  gw_fcat-icon = gc_x.
  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-fieldname = 'MESSG'.
  lv_count = lv_count + 1.
  gw_fcat-col_pos  = lv_count.
  gw_fcat-outputlen = 100.
  gw_fcat-seltext_l = 'Message'.
  gw_fcat-tabname = 'GT_FINAL'.
  gw_fcat-icon = gc_x.
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

FORM create_relation USING lv_p_objid TYPE pd_objid_r                    "Parent Object
                           lv_c_objid TYPE pd_objid_r                    "Child Object
                           lv_relat   TYPE relat
                           lv_realo   TYPE realo.

  DATA: lv_orgeh TYPE pa0001-orgeh.
  DATA: ls_pobject TYPE objec,
        lt_cobject TYPE objec_t,
        ls_cobject LIKE LINE OF lt_cobject,
        lv_flag    TYPE  flag.

  REFRESH  lt_cobject.

*Fill parent object details (OBJID details)
  ls_pobject-plvar = '01'.
  ls_pobject-otype = 'S'.
  ls_pobject-objid = lv_p_objid.
  ls_pobject-begda = sy-datum.
  ls_pobject-endda = '99991231'.
  ls_pobject-istat = '1'.

*Fill child object details
  ls_cobject-plvar = '01'.
  IF lv_relat = '008'.
    ls_cobject-otype = 'P'.
  ELSEIF lv_relat = '002'.
    ls_cobject-otype = 'S'.
  ELSEIF lv_relat = '011'.
    ls_cobject-otype = 'K'.
    ls_cobject-realo = lv_realo.
  ENDIF.
  ls_cobject-objid = lv_c_objid.                            "Emp
  ls_cobject-begda = sy-datum.
  ls_cobject-endda = '99991231'.
  ls_cobject-istat = '1'.
  APPEND ls_cobject TO lt_cobject.

  CALL FUNCTION 'OM_CREATE_NEW_RELATIONS'
    EXPORTING
      parent_object    = ls_pobject
      child_objects    = lt_cobject
      vrsign           = 'A'
      vrelat           = lv_relat
      vbegda           = sy-datum
      vendda           = '99991231'
*     PERCENTAGE       =
*     ACTION_INFO      =
    IMPORTING
      relation_created = lv_flag
* TABLES
*     RELATIONS_TO_CUT =
    .

  CALL FUNCTION 'RHOM_WRITE_BUFFER_TO_DB'
*  EXPORTING
*    NO_COMMIT            =
*  EXCEPTIONS
*    DATABASE_ERROR       = 1
*    CORR_EXIT            = 2
*    OTHERS               = 3
    .
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

ENDFORM.

FORM send_excel USING  text.

  DATA: mail_data       LIKE sodocchgi1,
        note_object     LIKE thead-tdobject,
        node_it         LIKE thead-tdid,
        send_mail_ok(1),
        mail_note(1000) TYPE c,
        flag            LIKE sonv-flag,
        ls_table        TYPE ty_final,
        receivers       LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
        it_attach       TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE,
        attachment      LIKE solisti1 OCCURS 0 WITH HEADER LINE,
        packing_list    LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
        message         TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE,
        mail_content    LIKE solisti1 OCCURS 0 WITH HEADER LINE.

  DATA: ld_format         TYPE so_obj_tp,
        ld_attfilename    TYPE so_obj_des,
        ld_attdescription TYPE so_obj_nam.

  CONSTANTS: con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
             con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.



  "body of mail

  PERFORM build_body_of_mail USING: 'Hi','Please see the attached excel for employees created.',''.

  DATA:
    l_obj(11),
    l_type(5),
    l_date(15).

  CONCATENATE 'Status' 'WD Empid' 'SAP Empid' 'Message' INTO it_attach SEPARATED BY con_tab.
  CONCATENATE con_cret it_attach INTO it_attach.
  APPEND it_attach.


  LOOP AT gt_final INTO DATA(ls_final) .

    CONCATENATE ls_final-icon ls_final-wdeeid ls_final-pernr ls_final-messg INTO it_attach SEPARATED BY con_tab.
    CONCATENATE con_cret it_attach INTO it_attach.

    " turkish character problems
*    replace all OCCURRENCES OF 'Ş' in it_attach WITH 'S'.

    APPEND it_attach.

  ENDLOOP.

  CLEAR: mail_data, mail_content, receivers.
  REFRESH: mail_content.


  READ TABLE it_attach INDEX gv_cnt.

  mail_data-doc_size = ( gv_cnt - 1 ) * 255 + strlen( attachment ) .
  mail_data-obj_name = 'SARPT'.
  mail_data-obj_descr = text.
  mail_data-obj_langu = sy-langu.
  mail_data-sensitivty = 'F'.

  REFRESH attachment.

  attachment[] = it_attach[].

  CLEAR : packing_list.
  REFRESH packing_list.
  "Describe the body of the message.
  packing_list-transf_bin = space.
  packing_list-head_start = 1.
  packing_list-head_num = 0.
  packing_list-body_start = 1.
  DESCRIBE TABLE gt_body_msg LINES packing_list-body_num.
  packing_list-doc_type = 'RAW'.
  APPEND packing_list.
  CLEAR : packing_list.

  "Create attachment notification
  packing_list-transf_bin = 'X'.
  packing_list-head_start = 1.
  packing_list-head_num = 1.
  packing_list-body_start = 1.

  DESCRIBE TABLE attachment LINES packing_list-body_num.

  ld_format = 'XLSX'.
  ld_attfilename = text.
  ld_attdescription = 'Wordday Emp file'.

  packing_list-doc_type = ld_format.
  packing_list-obj_descr = ld_attfilename.
  packing_list-obj_name = ld_attfilename.
  packing_list-doc_size = packing_list-body_num * 255.
  packing_list-obj_langu = sy-langu.
  APPEND packing_list.

  " Receivers.
  receivers-rec_type = 'U'.
  receivers-com_type = 'INT'.
  receivers-notif_read = ' '.
  receivers-notif_del =  ' '.
  receivers-receiver = p_rec.
  APPEND receivers.
  CLEAR receivers.


  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = mail_data
*     PUT_IN_OUTBOX              = ' '
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = flag
*     NEW_OBJECT_ID              =
    TABLES
      packing_list               = packing_list
*     OBJECT_HEADER              =
      contents_bin               = attachment
      contents_txt               = gt_body_msg
*     CONTENTS_HEX               =
*     OBJECT_PARA                =
*     OBJECT_PARB                =
      receivers                  = receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.

FORM build_body_of_mail USING l_message.

  gw_body_msg = l_message.
  APPEND gw_body_msg TO gt_body_msg.
  CLEAR gw_body_msg.

ENDFORM.

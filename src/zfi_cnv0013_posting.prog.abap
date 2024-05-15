*&---------------------------------------------------------------------*
*& Report ZFI_CNV0013_POSTING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfi_cnv0013_posting.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS :p_period TYPE acdoca-fiscyearper,
              p_bukrs  TYPE acdoca-rbukrs,
              p_bukrs1 TYPE acdoca-rbukrs,
              p_rldnr  TYPE acdoca-rldnr.
  PARAMETERS :  p_fic LIKE rlgrap-filename  DEFAULT 'C:\Users\mrajs\Downloads\CNV0012_' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

DATA :
  w_fic(128),
  l_file TYPE string.

  DATA : lv_file  TYPE char100,
         lv_anln2 TYPE anla-anln2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fic.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = 'table.txt'
      def_path         = 'C:\'
      mask             = ',*.txt.'
      mode             = 'O'
    IMPORTING
      filename         = w_fic
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
  IF sy-subrc = 0.
    p_fic = w_fic.
  ENDIF.
**
**AT SELECTION-SCREEN.
***    IF P_TAB(1) <> 'Z'.
***      MESSAGE E398(00) WITH TEXT-001.
***    ELSE.
***endif.
  MOVE p_fic TO w_fic.
  SHIFT w_fic RIGHT DELETING TRAILING space.
  TRANSLATE w_fic TO UPPER CASE.
  IF ( w_fic+124 <> '.TXT' AND w_fic+124 <> '.CSV' ).
    MESSAGE e398(00) WITH 'Invalid file extension .TXT/CSV'.
  ENDIF.
**
**
*----------------------------------------------------------------------*
*                          TRAITEMENT                                  *
*----------------------------------------------------------------------*
START-OF-SELECTION.



  lv_file = p_fic.
  l_file = |{ LV_file }{ P_rldnr }_{ P_bukrs } to { P_bukrs1 }.txt | .
  SELECT
      acdoca~rldnr,"       TYPE acdoca-rldnr,
   acdoca~rbukrs,
   acdoca~gjahr,
   acdoca~belnr,
   acdoca~docln,
   acdoca~ryear,
   acdoca~zuonr,
   acdoca~rtcur,
   acdoca~racct,
   acdoca~rcntr,
   acdoca~prctr,
   acdoca~tsl,
   acdoca~ritem,
   acdoca~drcrk,
   acdoca~poper,
   acdoca~fiscyearper,
   acdoca~budat,
   acdoca~glaccount_type,
   acdoca~lokkt,
   acdoca~mig_source,
   bkpf~xblnr
FROM acdoca INNER JOIN bkpf
    ON acdoca~rbukrs = bkpf~bukrs
    AND acdoca~belnr = bkpf~belnr
    AND acdoca~gjahr = bkpf~gjahr
    INTO TABLE @DATA(t_data) WHERE acdoca~xreversing = ''  AND  acdoca~xreversed = '' AND
                      acdoca~mig_source EQ ' ' and acdoca~rbukrs = @P_BUKRS and
                      acdoca~fiscyearper = @p_period AND acdoca~rldnr = @p_rldnr .

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = l_file
      filetype                = 'ASC'
      write_field_separator   = '|'
    TABLES
      data_tab                = t_data
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.


END-OF-SELECTION.

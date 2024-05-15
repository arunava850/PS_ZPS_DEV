*&---------------------------------------------------------------------*
*& Report ZDM_CNV0014_PV_RPT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDM_CNV0014_PV_RPT.
*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
  PARAMETERS :p_period TYPE acdoca-fiscyearper,
              p_rldnr  TYPE acdoca-rldnr.
  PARAMETERS :  p_fic LIKE rlgrap-filename
  DEFAULT 'C:\Users\mrajs\Downloads\CNV0014_' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

DATA :
  w_fic(128),
  l_file TYPE string.


  DATA : lv_file  TYPE char100 .
TYPES: BEGIN OF ty_acdoca,
         rldnr          TYPE acdoca-rldnr,
         rbukrs         TYPE acdoca-rbukrs,
         gjahr          TYPE acdoca-gjahr,
         belnr          TYPE acdoca-belnr,
         docln          TYPE acdoca-docln,
         ryear          TYPE acdoca-ryear,
         zuonr type acdoca-zuonr,
         rtcur          TYPE acdoca-rtcur,
         racct          TYPE acdoca-racct,
         rcntr          TYPE acdoca-rcntr,
         prctr          TYPE acdoca-prctr,
         tsl            TYPE acdoca-tsl,
         ritem type     acdoca-ritem ,
         drcrk          TYPE acdoca-drcrk,
         poper          TYPE acdoca-poper,
         fiscyearper    TYPE acdoca-fiscyearper,
         budat          TYPE acdoca-budat,
         glaccount_type TYPE acdoca-glaccount_type,
         lokkt          TYPE acdoca-lokkt,
         mig_source     TYPE acdoca-mig_source,
         xblnr          TYPE bkpf-xblnr,
       END OF ty_acdoca.
DATA: t_data TYPE STANDARD TABLE OF Ty_acdoca .


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

START-OF-SELECTION.
  lv_file = p_fic.
  l_file = |{ LV_file }{ P_rldnr }_{ p_period }.txt | .
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
   acdoca~mig_source
FROM acdoca
    INTO TABLE
     @t_data WHERE acdoca~xreversing = ''  AND
    acdoca~xreversed = '' AND
    acdoca~mig_source EQ 'H' and
    acdoca~fiscyearper = @p_period AND
    acdoca~rldnr = @p_rldnr .

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

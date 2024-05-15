class ZPSU_CL_SALV_BS_OFFICE2007_BAS definition
  public
  abstract
  create public .

public section.

*"* public components of class ZPSU_CL_SALV_BS_OFFICE2007_BAS
*"* do not include other source files here!!!
  methods CONSTRUCTOR
    importing
      !R_RESULT_DATA type ref to CL_SALV_BS_RESULT_DATA_TABLE .
  methods TRANSFORM
    returning
      value(EXCEL_XML) type XSTRING .
protected section.

  types:
    "! Describes if for a column the leading spaces should be preserved
    begin of ys_preserve_space,
      column_id      type string,
      preserve_space type abap_bool,
    end of ys_preserve_space .
  types:
  "! list of columns describing if the leading spaces should be preserved
    yt_preserve_space type hashed table of ys_preserve_space
    with unique key column_id .

  data GUI_TYPE like IF_SALV_BS_C_TT=>C_TT .
  data MT_PRESERVE_SPACE type YT_PRESERVE_SPACE .

  methods GET_IMAGE_CONTENT
  abstract
    importing
      !IMAGE_VALUE type DATA
    exporting
      !VALUE type XSTRING .
  methods HAS_PRESERVE_SPACE
    importing
      !S_COLUMN type IF_SALV_BS_MODEL_COLUMNS=>S_TYPE_COLUMN
    returning
      value(PRESERVE_SPACE) type ABAP_BOOL .
private section.

  types:
    begin of ys_cell_struc,
      position       type string,
      value          type string,
      index          type i,
      style          type i,
      sharedstring   type string,
    end of ys_cell_struc .
  types:
    begin of ys_col_struc,
      min          type i,
      max          type i,
      bestFit      type i,
      width        type i,
    end of ys_col_struc .
  types:
    begin of ys_row_struc,
      spans        type string,
      position     type i,
      outlinelevel type i,
      hidden       type char1,
      height       type i,
      t_cells   type standard table of ys_cell_struc with non-unique key position initial size 1,
    end of ys_row_struc .
  types:
    begin of ys_hyperlink_struc,
      rel_id    type string,
      cell_id   type string,
    end of ys_hyperlink_struc .
  types:
    begin of ys_sheet_struc,
      dim           type string,
      outlinelevel  type i,
      summary_below type string,
      s_header_row  type ys_row_struc,
      t_rows        type standard table of ys_row_struc with non-unique key position initial size 1,
      t_cols        type standard table of ys_col_struc with non-unique key min initial size 1,
      t_hyperlinks  type standard table of ys_hyperlink_struc with non-unique key cell_id initial size 1,
      drawing_id    type string,
      rtl_id        type i,
    end of ys_sheet_struc .
  types:
    begin of ys_columninfo,
      columnid       type string,
      field          type string,
      width          type i,
      properties     type if_salv_bs_model_column=>s_type_uie_properties,
      attribute      type if_salv_bs_t_data=>s_type_attribute,
    end of ys_columninfo .
  types:
    yt_columninfo type hashed table of ys_columninfo with unique key columnid initial size 1 .
  types:
    begin of ys_sharedstring,
      value type string,
      pos type i,
      preserve_space type abap_bool,
    end of ys_sharedstring .
  types:
    yth_sharedstring type hashed table of ys_sharedstring
       with unique key value preserve_space initial size 1 .
  types:
    begin of ys_sharedstring_struc,
*      t_strings     type standard table of ys_sharedstring with key value initial size 1,
      t_strings     type yth_sharedstring,
      string_count  type i,
      string_ucount type i,
    end of ys_sharedstring_struc .
  types:
    begin of ys_style_numfmt,
      id     type i,
      code   type string,
    end of ys_style_numfmt .
  types:
    begin of ys_style_cellxf,
       index        type i,
       numfmtid     type i,
       fillid       type i,
       borderid     type i,
       is_string    type i,
       indent       type i,
       xfid         type i,
       wrap         type i,
       quote_prefix type i,
       key          type string,
    end of ys_style_cellxf .
  types:
    begin of YS_STYLE_STRUC,
      t_numFmts      type standard table of ys_style_numfmt with key id initial size 1,
      t_cellxfs      type standard table of ys_style_cellxf with key key indent xfid wrap initial size 1,
      numfmts_count  type i,
      cellxfs_count  type i,
    end of ys_style_struc .
  types:
    begin of ys_image,
       index       type i,
       col         type i,
       row         type i,
       name        type string,
       descr       type string,
       rel_id      type string,
       height      type i,
       width       type i,
    end of ys_image .
  types:
    begin of YS_image_struc,
      t_images    type standard table of ys_image with key name initial size 1,
    end of ys_image_struc .
  types:
    begin of ys_image_map,
       id          type string,
       rel_id      type string,
       height      type i,
       width       type i,
    end of ys_image_map .
  types:
    begin of ys_hyperlink_map,
       link        type string,
       rel_id      type string,
    end of ys_hyperlink_map .

  data EXCEL_XML type XSTRING .
  data DRAWINGPART type ref to CL_OXML_DRAWINGSPART .
  data:
    HYPERLINK_MAP type hashed table of YS_HYPERLINK_MAP with unique key link .
  constants C_TYPE_DATE type C value 'D' ##NO_TEXT.
  data:
    IMAGE_MAP type hashed table of ys_image_map with unique key id .
  constants C_TYPE_NUMERIC type C value 'N' ##NO_TEXT.
  data IMAGE_STRUCT type YS_IMAGE_STRUC .
  constants C_TYPE_STRING type C value 'C' ##NO_TEXT.
  data SHAREDSTRING_STRUCT type YS_SHAREDSTRING_STRUC .
  constants C_TYPE_TIME type C value 'T' ##NO_TEXT.
  constants C_TYPE_TIMESTAMP type C value 'Z' ##NO_TEXT.
  data STYLE_STRUCT type YS_STYLE_STRUC .
  constants C_ABC type CHAR26 value 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ##NO_TEXT.
  constants C_ROWSTYLE_SUBTOTAL type C value 'S' ##NO_TEXT.
  constants C_DECIMALS_FORMAT type CHAR26 value '0.00000000000000' ##NO_TEXT.
  constants C_ROWSTYLE_NORMAL type C value 'N' ##NO_TEXT.
  constants C_ROWSTYLE_TITLE type C value 'H' ##NO_TEXT.
  data R_RESULT_TABLE type ref to CL_SALV_BS_RESULT_DATA_TABLE .
  constants C_ROWSTYLE_TOTAL type C value 'T' ##NO_TEXT.
  constants C_1000_SEPARATOR type STRING value '#,##' ##NO_TEXT.
  data XLSX_DOCUMENT type ref to CL_XLSX_DOCUMENT .
  data SHEET_STRUCT type YS_SHEET_STRUC .
  data LAST_INSERT_POSITION type SYTABIX .
  data T_STRINGS type YTH_SHAREDSTRING .
  constants C_TYPE_HOUR type C value 'O' ##NO_TEXT.

  methods GENERATE_XML_AND_OPC .
  methods ADD_DRAWINGPART .
  methods ADD_HYPERLINK
    importing
      !I_LINK type STRING
      !I_CELL_ID type STRING .
  methods ADD_IMAGE
    importing
      !ID type STRING
      !ROW type I
      !COL type I
    changing
      !HEIGHT type I
      !WIDTH type I .
  methods CREATE_CELL
    importing
      !COLUMNID type STRING
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !S_DATA type ANY optional
      !S_RESULT type IF_SALV_BS_R_DATA_TABLE_TYPES=>S_TYPE_RESULT_DATA
      !COLUMNINFO type YS_COLUMNINFO
      !CELL_ID type STRING
      !T_VISIBLE_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !T_HIER_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN optional
    exporting
      !VALUE type STRING
      !DECIMALS type I
      !IMAGE_ID type STRING
      !INTTYPE type C
      !INDENT type I .
  methods CREATE_DATA_CELL
    importing
      !COLUMNID type STRING
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !S_DATA type ANY
      !S_RESULT type IF_SALV_BS_R_DATA_TABLE_TYPES=>S_TYPE_RESULT_DATA
      !COLUMNINFO type YS_COLUMNINFO
      !CELL_ID type STRING
    exporting
      !VALUE type STRING
      !DECIMALS type I
      !IMAGE_ID type STRING
      !INTTYPE type C .
  methods CREATE_HIER_CELL
    importing
      !COLUMNID type STRING
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !S_RESULT type IF_SALV_BS_R_DATA_TABLE_TYPES=>S_TYPE_RESULT_DATA
      !COLUMNINFO type YS_COLUMNINFO
    exporting
      !VALUE type STRING
      !DECIMALS type I
      !IMAGE_ID type STRING
      !INTTYPE type C .
  methods CREATE_TOTAL_CELL
    importing
      !COLUMNID type STRING
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !S_DATA type ANY
      !S_RESULT type IF_SALV_BS_R_DATA_TABLE_TYPES=>S_TYPE_RESULT_DATA
      !COLUMNINFO type YS_COLUMNINFO
      !T_VISIBLE_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !T_HIER_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
    exporting
      !VALUE type STRING
      !DECIMALS type I
      !IMAGE_ID type STRING
      !INTTYPE type C .
  methods GET_CELL_VALUE
    importing
      !I_REFERENCE type STRING optional
      !S_DATA type ANY
      !FIELDNAME type STRING
      !UIE_TYPE type STRING
      !IMAGE_TYPE type STRING
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !I_ROUND type STRING optional
      !I_IMAGE type STRING optional
      !I_DECIMALS type STRING optional
      !I_EXPONENT type STRING optional
      !I_TECH_FORM type STRING optional
    exporting
      !VALUE type DATA
      !DECIMALS type DATA
      !IMAGE_ID type STRING .
  methods ADD_SHAREDSTRING
    importing
      !I_SHAREDSTRING type STRING
      !I_PRESERVE_SPACE type ABAP_BOOL optional
    exporting
      !E_INDEX type I .
  methods ADD_STYLE
    importing
      !I_TYPE type C
      !I_DECIMALS type I default 0
      !I_ROWSTYLE type C default 'N'
      !I_INDENT type I default 0
      !I_HYPERLINK type I default 0
      !I_WRAP type I default 0
      !I_QUOTE type I default 0
    exporting
      !E_INDEX type I .
  methods CREATE_CELLS
    importing
      !ROW_INDEX type I
      !T_VISIBLE_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !T_HIER_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !ROWSTYLE type C
      !DATA_INDEX type I
      !R_DATA type ref to DATA
      !S_RESULT type IF_SALV_BS_R_DATA_TABLE_TYPES=>S_TYPE_RESULT_DATA
    changing
      !T_COLUMNINFO type YT_COLUMNINFO
      !S_ROW type YS_ROW_STRUC .
  methods CREATE_HEADER_ROW
    importing
      !T_VISIBLE_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !R_MODEL type ref to CL_SALV_BS_MODEL_TABLE
      !T_HIER_COLUMNS type IF_SALV_BS_MODEL_COLUMNS=>T_TYPE_COLUMN
      !STYLE_INDEX type I
    changing
      !S_ROW type YS_ROW_STRUC
      !T_COLUMNINFO type YT_COLUMNINFO .
  methods GET_CELLPOSITION
    importing
      !ROW type I
      !COL type I
    returning
      value(RESULT) type STRING .
  methods TRANSFORM_TO_OFF2007 .
  methods GET_CELL_IMAGE
    importing
      !S_DATA type ANY
      !IMAGE_FIELDNAME type STRING
      !IMAGE_VALUE type STRING
      !IMAGE_TYPE type STRING
    exporting
      !IMAGE_ID type STRING .
ENDCLASS.



CLASS ZPSU_CL_SALV_BS_OFFICE2007_BAS IMPLEMENTATION.


method ADD_DRAWINGPART.

  data: workbookpart type ref to cl_xlsx_workbookpart.
  data: worksheetparts type ref to cl_openxml_partcollection.
  data: part type ref to cl_openxml_part.
  data: worksheetpart type ref to cl_xlsx_worksheetpart.

* Get the workbook part of the document
  try.
    call method XLSX_DOCUMENT->get_workbookpart
    receiving
      rr_part = workbookpart.

*   Get the first worksheet part
    call method workbookpart->get_worksheetparts
      receiving
        rr_parts = worksheetparts.

    call method worksheetparts->get_part
      exporting
        iv_index = 0
      receiving
        rr_part  = part.

    worksheetpart ?= part.

*   Add the drawing part from the worksheet
    call method worksheetpart->add_drawingspart
      receiving
        rr_part = drawingpart.

    call method worksheetpart->get_id_for_part
      exporting
        ir_part = drawingpart
      receiving
        rv_id   = sheet_struct-drawing_id.

  catch cx_openxml_format.
  catch cx_openxml_not_found.
  catch cx_openxml_not_allowed.

  endtry.

endmethod.


method ADD_HYPERLINK.

    data: l_index type i,
          ls_hyperlink         type ys_hyperlink_struc,
          ls_hyperlink_map     type ys_hyperlink_map.

    data: workbookpart type ref to cl_xlsx_workbookpart.
    data: worksheetparts type ref to cl_openxml_partcollection.
    data: part type ref to cl_openxml_part.
    data: worksheetpart type ref to cl_xlsx_worksheetpart.
    data: id type string.

    read table hyperlink_map with key link = i_link into ls_hyperlink_map.
    if sy-subrc NE 0 and i_link is not initial.
      clear ls_hyperlink_map.

      try.

*       Get the workbook part of the document
      call method XLSX_DOCUMENT->get_workbookpart
        receiving
          rr_part = workbookpart.

*       Get the first worksheet part
      call method workbookpart->get_worksheetparts
        receiving
          rr_parts = worksheetparts.

      call method worksheetparts->get_part
        exporting
          iv_index = 0
        receiving
          rr_part  = part.

      worksheetpart ?= part.

        call method worksheetpart->add_external_relationship
        exporting
          iv_type      = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink'
          iv_targeturi = i_link
        receiving
          rv_id        = id.

        ls_hyperlink_map-link = i_link.
        ls_hyperlink_map-rel_id = id.
        insert ls_hyperlink_map into table hyperlink_map.

      catch cx_openxml_not_found.
      catch cx_openxml_format.
      catch cx_sy_ref_is_initial.
        "skip link
      endtry.
  endif.

  clear ls_hyperlink.
  ls_hyperlink-cell_id = i_cell_id.
  ls_hyperlink-rel_id = ls_hyperlink_map-rel_id.
  insert ls_hyperlink into table sheet_struct-t_hyperlinks.

endmethod.


method ADD_IMAGE.

  data: ls_image       type ys_image.
  data: ls_image_map   type ys_image_map.
  data: l_size         type i.
  data: l_width        type i.
  data: l_height       type i.
  data: l_content      type xstring.
  data: l_imagepart    type ref to cl_oxml_imagepart.
  data: l_imagetype    type oxa_opc_content_type.

  read table image_map into ls_image_map
      with table key id = id. " hash table access
  if sy-subrc <> 0.
    " image ID not yet read

    me->get_image_content(
        exporting image_value = id
        importing value = l_content ).
    if l_content is not initial.
      cl_salv_bs_lex_support=>get_image_info(
          exporting i_image_content = l_content
          importing e_width         = l_width
                    e_height        = l_height
                    e_mime_type     = l_imagetype ).

      " append the image to XLSX
      " if the image is not emtpy (size > 0)
      if l_width > 0
          and l_height > 0.
        try.
            if drawingpart is initial.
              me->add_drawingpart( ).
            endif.

            call method drawingpart->add_imagepart
            exporting
              iv_content_type = l_imagetype
            receiving
              rr_part         = l_imagepart.

            call method l_imagepart->feed_data
              exporting
                iv_data = l_content.

            call method drawingpart->get_id_for_part
              exporting
                ir_part = l_imagepart
              receiving
                rv_id   = ls_image_map-rel_id.

          catch cx_openxml_not_found.
          catch cx_openxml_not_allowed.
        endtry.
      endif. " known image type
    endif. " image not empty/initial

    " Remember image size and rel_id for this image ID
    " so that it is not read and analyzed again
    ls_image_map-id = id.
    ls_image_map-width = l_width.
    ls_image_map-height = l_height.
    insert ls_image_map into table image_map.

  endif.

  " don't add the image if the image is empty
  if ls_image_map-width <= 0
      or ls_image_map-height <= 0.
    return.
  endif.

  " create record for the image in a cell
  ls_image-col = col - 1.
  ls_image-row = row.

  describe table image_struct-t_images lines l_size.
  ls_image-index = l_size.

  ls_image-height = 9525 * ls_image_map-height.
  ls_image-width = 9525 * ls_image_map-width.
  concatenate 'Picture' id into ls_image-name. "#EC NOTEXT
  ls_image-descr = id.
  ls_image-rel_id = ls_image_map-rel_id.

  insert ls_image into table image_struct-t_images.

  if height < ls_image_map-height.   " ? PN: how this could be, integer overflow?
    height = ls_image_map-height.
  endif.

  width = ls_image_map-width.

endmethod.


method ADD_SHAREDSTRING.

    data: l_index type i,
          ls_sharedstring         type ys_sharedstring.

* Check: is the string already in our shared string table?
*    -> If yes, give me the position/index
*    -> In no, insert the string and give me then the position/index
    read table me->t_strings
      with key value = i_sharedstring preserve_space = i_preserve_space
      into ls_sharedstring.
    if sy-subrc eq 0.
*      nothing to do here
    else.
*      last_insert_position = last_insert_position + 1.
      add 1 to sharedstring_struct-string_ucount.
      clear ls_sharedstring.
      ls_sharedstring-value = i_sharedstring.
      ls_sharedstring-pos = sharedstring_struct-string_ucount.
      ls_sharedstring-preserve_space = i_preserve_space.
      insert ls_sharedstring into table me->t_strings.
    endif.

    add 1 to sharedstring_struct-string_count.
    e_index = ls_sharedstring-pos - 1.


*    read table me->sharedstring_struct-t_strings with key value = i_sharedstring into ls_sharedstring.
*    if sy-subrc eq 0.
**      nothing to do here
*    else.
**      last_insert_position = last_insert_position + 1.
*      add 1 to sharedstring_struct-string_ucount.
*      clear ls_sharedstring.
*      ls_sharedstring-value = i_sharedstring.
*      ls_sharedstring-pos = sharedstring_struct-string_ucount.
*      insert ls_sharedstring into table me->sharedstring_struct-t_strings.
*    endif.
*
*    add 1 to sharedstring_struct-string_count.
*    e_index = ls_sharedstring-pos - 1.


* OLD CODING: most likely not needed anymore
*    read table sharedstring_struct-t_strings with key value = i_sharedstring into ls_sharedstring.
*    if sy-subrc eq 0.
**      nothing to do here
*    else.
**      last_insert_position = last_insert_position + 1.
*      add 1 to sharedstring_struct-string_ucount.
*      clear ls_sharedstring.
*      ls_sharedstring-value = i_sharedstring.
*      ls_sharedstring-pos = sharedstring_struct-string_ucount.
*      insert ls_sharedstring into table sharedstring_struct-t_strings.
*    endif.
*
*    add 1 to sharedstring_struct-string_count.
*    e_index = ls_sharedstring-pos - 1.


* OLDEST
*    read table sharedstring_struct-t_strings with key value = i_sharedstring transporting no fields.
*    if sy-subrc NE 0.
*       clear ls_sharedstring.
*       ls_sharedstring-value = i_sharedstring.
*       insert ls_sharedstring into table sharedstring_struct-t_strings.
*       if sy-subrc eq 0.
*       endif.
*       add 1 to sharedstring_struct-string_ucount.
*       describe table sharedstring_struct-t_strings lines l_index.
*       l_index = l_index - 1.
*    else.
*       l_index = sy-tabix - 1.
*    endif.
*
*    add 1 to sharedstring_struct-string_count.
*    e_index = l_index.

endmethod.


method ADD_STYLE.

  data: ls_cellxf   type ys_style_cellxf,
        ls_cellxf2  type ys_style_cellxf,
        ls_numfmt   type ys_style_numfmt,
        l_index     type i,
        l_key       type string.

  describe table style_struct-t_cellxfs lines l_index.
  e_index = l_index.

  clear ls_cellxf.
  ls_cellxf-index = l_index.
  if i_rowstyle EQ C_ROWSTYLE_TITLE.
     ls_cellxf-fillId = 2.
     ls_cellxf-borderid = 1.
  elseif i_rowstyle EQ C_ROWSTYLE_TOTAL.
     ls_cellxf-fillid = 3.
     ls_cellxf-borderid = 1.
  elseif i_rowstyle EQ C_ROWSTYLE_SUBTOTAL.
     ls_cellxf-fillid = 4.
     ls_cellxf-borderid = 1.
  endif.

  data l_quote type c length 1.

  l_quote = i_quote.

  case i_type.
    when c_type_string.
      concatenate i_type i_rowstyle l_quote into l_key.

      read table style_struct-t_cellxfs with table key
           key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
      if sy-subrc NE 0.
        ls_cellxf-numfmtid = 0.
        ls_cellxf-key = l_key.
        ls_cellxf-indent = i_indent.
        ls_cellxf-xfid = i_hyperlink.
        ls_cellxf-wrap = i_wrap.
        ls_cellxf-quote_prefix = i_quote.
        insert ls_cellxf into table style_struct-t_cellxfs.
        add 1 to style_struct-cellxfs_count.
      else.
        e_index = ls_cellxf2-index.
      endif.

    when c_type_date.
      concatenate i_type i_rowstyle into l_key.

      read table style_struct-t_cellxfs with table key
           key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
      if sy-subrc NE 0.
        ls_cellxf-numfmtid = 14.
        ls_cellxf-is_string = 1.
        ls_cellxf-key = l_key.
        ls_cellxf-indent = i_indent.
        ls_cellxf-xfid = i_hyperlink.
        ls_cellxf-wrap = i_wrap.
        insert ls_cellxf into table style_struct-t_cellxfs.
        add 1 to style_struct-cellxfs_count.
      else.
        e_index = ls_cellxf2-index.
      endif.

    when c_type_timestamp.
      concatenate i_type i_rowstyle into l_key.

      read table style_struct-t_cellxfs with table key
           key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
      if sy-subrc NE 0.
        ls_cellxf-numfmtid = 22.
        ls_cellxf-is_string = 1.
        ls_cellxf-key = l_key.
        ls_cellxf-indent = i_indent.
        ls_cellxf-xfid = i_hyperlink.
        ls_cellxf-wrap = i_wrap.
        insert ls_cellxf into table style_struct-t_cellxfs.
        add 1 to style_struct-cellxfs_count.
      else.
        e_index = ls_cellxf2-index.
      endif.

    when c_type_numeric.
      if i_decimals EQ 0.
        concatenate i_type i_rowstyle '0' into l_key.

        read table style_struct-t_cellxfs with table key
             key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
        if sy-subrc NE 0.
          ls_cellxf-numfmtid = 3.   "3 = Microsoft default Numfmtid for #,##0
          ls_cellxf-is_string = 1.
          ls_cellxf-key = l_key.
          ls_cellxf-indent = i_indent.
          ls_cellxf-xfid = i_hyperlink.
          ls_cellxf-wrap = i_wrap.
          insert ls_cellxf into table style_struct-t_cellxfs.
          add 1 to style_struct-cellxfs_count.
        else.
          e_index = ls_cellxf2-index.
        endif.

      elseif i_decimals EQ 2.
        concatenate i_type i_rowstyle '2' into l_key.

        read table style_struct-t_cellxfs with table key
             key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
        if sy-subrc NE 0.
          ls_cellxf-numfmtid = 4.   "4 = Microsoft default Numfmtid for #,##0.00
          ls_cellxf-is_string = 1.
          ls_cellxf-key = l_key.
          ls_cellxf-indent = i_indent.
          ls_cellxf-xfid = i_hyperlink.
          ls_cellxf-wrap = i_wrap.
          insert ls_cellxf into table style_struct-t_cellxfs.
          add 1 to style_struct-cellxfs_count.
        else.
          e_index = ls_cellxf2-index.
        endif.

      elseif i_decimals <= 14.

        data: l_no_numfmts type i,
              l_decimals   type string.

        l_decimals = |{ i_decimals }|.
        concatenate i_type i_rowstyle l_decimals into l_key.

        read table style_struct-t_cellxfs with table key
             key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
        if sy-subrc NE 0.
          describe table style_struct-t_numfmts lines l_no_numfmts.
          l_no_numfmts = l_no_numfmts + 169.
          l_decimals = i_decimals + 2.

          ls_cellxf-numfmtid = l_no_numfmts.    "custom number format, format code defined below
          ls_cellxf-is_string = 1.
          ls_cellxf-key = l_key.
          ls_cellxf-indent = i_indent.
          ls_cellxf-xfid = i_hyperlink.
          ls_cellxf-wrap = i_wrap.
          insert ls_cellxf into table style_struct-t_cellxfs.
          add 1 to style_struct-cellxfs_count.

          clear ls_numfmt.
          ls_numfmt-id = l_no_numfmts.
          "custom number format for given amount of decimal places: #,##0.0 /  #,##0.000 / ...
          ls_numfmt-code = c_1000_separator && c_decimals_format(l_decimals).
          insert ls_numfmt into table style_struct-t_numfmts.
          add 1 to style_struct-numfmts_count.
        else.
          e_index = ls_cellxf2-index.
        endif.
      else.
        concatenate i_type i_rowstyle 'E' into l_key.

        read table style_struct-t_cellxfs with table key
             key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
        if sy-subrc NE 0.
          describe table style_struct-t_numfmts lines l_no_numfmts.
          l_no_numfmts = l_no_numfmts + 169.
          l_decimals = i_decimals + 2.

          ls_cellxf-numfmtid = l_no_numfmts.
          ls_cellxf-is_string = 1.
          ls_cellxf-key = l_key.
          ls_cellxf-indent = i_indent.
          ls_cellxf-xfid = i_hyperlink.
          ls_cellxf-wrap = i_wrap.
          insert ls_cellxf into table style_struct-t_cellxfs.
          add 1 to style_struct-cellxfs_count.

          clear ls_numfmt.
          ls_numfmt-id = l_no_numfmts.
          ls_numfmt-code = '0.00000000000000E+00'. "note 2234051
          insert ls_numfmt into table style_struct-t_numfmts.
          add 1 to style_struct-numfmts_count.
        else.
          e_index = ls_cellxf2-index.
        endif.

      endif.

    when c_type_time.
      concatenate i_type i_rowstyle into l_key.

      read table style_struct-t_cellxfs with table key
           key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
      if sy-subrc NE 0.
        ls_cellxf-numfmtid = 168.
        ls_cellxf-is_string = 1.
        ls_cellxf-key = l_key.
        ls_cellxf-indent = i_indent.
        ls_cellxf-xfid = i_hyperlink.
        ls_cellxf-wrap = i_wrap.
        insert ls_cellxf into table style_struct-t_cellxfs.
        add 1 to style_struct-cellxfs_count.

        clear ls_numfmt.
        ls_numfmt-id = 168.
        ls_numfmt-code = '[$-F400]h:mm:ss\ AM/PM'. "#EC NOTEXT
        insert ls_numfmt into table style_struct-t_numfmts.
        add 1 to style_struct-numfmts_count.
      else.
        e_index = ls_cellxf2-index.
      endif.

      "// 'd\/m\/yy\\ h\:mm\;\@'.

   when c_type_hour.
*...  special handling for 24:00:00
      concatenate i_type i_rowstyle into l_key.

      read table style_struct-t_cellxfs with table key
           key = l_key indent = i_indent xfid = i_hyperlink wrap = i_wrap into ls_cellxf2.
      if sy-subrc NE 0.
        ls_cellxf-numfmtid = 46.
        ls_cellxf-is_string = 1.
        ls_cellxf-key = l_key.
        ls_cellxf-indent = i_indent.
        ls_cellxf-xfid = i_hyperlink.
        ls_cellxf-wrap = i_wrap.
        insert ls_cellxf into table style_struct-t_cellxfs.
        add 1 to style_struct-cellxfs_count.
      else.
        e_index = ls_cellxf2-index.
      endif.

   endcase.

endmethod.


method CONSTRUCTOR.

  super->constructor( ).

  me->R_RESULT_TABLE = r_result_data.


  case r_result_data->result_data.
    when if_salv_bs_c_result_data=>result_data or
         if_salv_bs_c_result_data=>result_data_table or
         if_salv_bs_c_result_data=>result_data_table_ex.
      me->gui_type = if_salv_bs_c_tt=>c_tt_result_table_ex.

    when if_salv_bs_c_result_data=>result_data_table_wd.
      me->gui_type = if_salv_bs_c_tt=>c_tt_result_table_wd.
    when others.
      me->gui_type = if_salv_bs_c_tt=>c_tt_result_table_ex.
  endcase.


endmethod.


method CREATE_CELL.

  data:
    ls_attribute          type if_salv_bs_t_data=>s_type_attribute,
    ls_uie_properties     type if_salv_bs_model_column=>s_type_uie_properties.

  data:
    l_field        type string,
    l_reference    type string,
    l_attribute01  type string,
    l_uie_type     type string,
    l_image_type   type string.

  data:
    l_do_data type abap_bool,
    l_do_aggr type abap_bool,
    l_do_hier type abap_bool.

  field-symbols:
    <l_cell_int>         type any.


  if s_result-type eq cl_salv_bs_result_data_table=>c_type_data and columnid ne 'HIERCOL'.
    l_do_data = abap_true.
  endif.
  if s_result-type eq cl_salv_bs_result_data_table=>c_type_aggregation or
     s_result-s_aggr-is_aggr_line eq abap_true and columnid ne 'HIERCOL'.
    l_do_aggr = abap_true.
  endif.
  if s_result-type eq cl_salv_bs_result_data_table=>c_type_hierarchy or
     s_result-s_hierarchy-is_hierarchy_line eq abap_true.
    l_do_hier = abap_true.
  endif.

  if l_do_data eq abap_false and
     l_do_aggr eq abap_false and
     l_do_hier eq abap_false.
    exit.
  endif.

  clear value.
  clear decimals.
  clear inttype.
  clear image_id.
  clear indent.

  if l_do_data eq abap_true.

   call method me->create_data_cell
     exporting
       columninfo   = columninfo
       columnid     = columnid
       r_model      = r_model
       s_data       = s_data
       s_result     = s_result
       cell_id      = cell_id
     importing
       value        = value
       decimals     = decimals
       image_id     = image_id
       inttype      = inttype.

  elseif l_do_aggr eq abap_true.

    call method me->create_total_cell
     exporting
       columninfo        = columninfo
       columnid          = columnid
       r_model           = r_model
       s_data            = s_data
       s_result          = s_result
       t_visible_columns = t_visible_columns
       t_hier_columns    = t_hier_columns
     importing
       value        = value
       decimals     = decimals
       image_id     = image_id
       inttype      = inttype.

  elseif l_do_hier eq abap_true.

    if columnid EQ 'HIERCOL'.

      call method me->create_hier_cell
       exporting
         columninfo   = columninfo
         columnid     = columnid
         r_model      = r_model
         s_result     = s_result
       importing
         value        = value
         decimals     = decimals
         image_id     = image_id
         inttype      = inttype.

      indent = s_result-s_hierarchy-level.

   endif.
  endif.

endmethod.


method CREATE_CELLS.

  data:
    ls_attribute          type if_salv_bs_t_data=>s_type_attribute,
    ls_column             type if_salv_bs_model_columns=>s_type_column.

  data:
    ls_cell  type ys_cell_struc.

  data:
    l_col_index    type i,
    l_field        type string,
    l_inttype      type c,
    l_value        type string,
    l_decimals     type i,
    l_imageid      type string,
    l_reference    type string,
    l_uie_type     type string,
    l_image_type   type string,
    l_indent       type i,
    l_width        type i,
    l_wrap         type i,
    l_hyperlink    type i,
    tmp_i          type i,
    l_img_height   type i,
    l_img_width    type i,
    ls_columninfo  type ys_columninfo.

  data:
    l_zero_fltp_dot   type string value '0.0000000000000000E+00',
    l_zero_fltp_comma type string value '0,0000000000000000E+00'.

  data: l_row_index type i.

  data:
    l_min_height   type i value 12,
    l_max_height   type i.

  data:
    l_quote_prefix type i,
    lv_is_quote_prefix_enabled type abap_bool.

  field-symbols:
     <l_data>  type any,
     <ls_data> type any,
     <lt_data> type standard table.

  assign r_data->* to <lt_data>.
  unassign <ls_data>.

  read table <lt_data> assigning <ls_data> index data_index.
  "if sy-subrc ne 0.
  " exit.
  "endif.
  "assert sy-subrc eq 0.

  l_col_index = 0.
  clear l_max_height.

* hierarchy column - GUI ALV does not support hierarchy, WD ABAP ALV only
  if r_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    l_col_index = l_col_index + 1.

    clear ls_cell.
    clear ls_columninfo.

    read table t_columninfo into ls_columninfo with key columnid = 'HIERCOL'.

    call method me->get_cellposition
      exporting
        row    = row_index
        col    = l_col_index
      receiving
        result = ls_cell-position.

    if <ls_data> is assigned.
      call method me->create_cell
        exporting
          columninfo        = ls_columninfo
          columnid          = 'HIERCOL'
          r_model           = r_model
          s_data            = <ls_data>
          s_result          = s_result
          cell_id           = ls_cell-position
          t_visible_columns = t_visible_columns
        importing
          value        = l_value
          decimals     = l_decimals
          image_id     = l_imageid
          inttype      = l_inttype
          indent       = l_indent.
   else.
      call method me->create_cell
        exporting
          columninfo        = ls_columninfo
          columnid          = 'HIERCOL'
          r_model           = r_model
          s_result          = s_result
          cell_id           = ls_cell-position
          t_visible_columns = t_visible_columns
        importing
          value        = l_value
          decimals     = l_decimals
          image_id     = l_imageid
          inttype      = l_inttype
          indent       = l_indent.
   endif.

*   add image on cell
    if l_imageid is not initial.

      l_row_index = row_index - 1.

      l_img_height = 0.
      l_img_width = 0.

      call method me->add_image
        exporting
          id      = l_imageid
          col     = l_col_index
          row     = l_row_index
        changing
          height  = l_img_height
          width   = l_img_width.

      if l_img_height > l_max_height.
        l_max_height = l_img_height.
      endif.

    endif.

    if l_inttype eq 'P' and
      ( ls_attribute-s_dfies-convexit eq 'TSTMP' or ls_attribute-s_dfies-domname(8) eq 'TZNTSTMP' ).

      ls_cell-value = l_value.

      call method me->add_style
        exporting
          i_type     = c_type_timestamp
          i_rowstyle = rowstyle
          i_indent   = l_indent
        importing
          e_index    = ls_cell-style.

      l_width = 15.

   elseif ( l_inttype ca if_salv_bs_log_exp_operand=>c_numeric and
            ls_attribute-s_dfies-convexit is initial )
          or
          ( l_inttype = cl_abap_typedescr=>typekind_packed and    " AFLE #2887221
            ( ls_attribute-reference_field is not initial or
              ls_attribute-reference_value is not initial ) and
            ls_attribute-convexit_afle = abap_true ).

      ls_cell-value = l_value.

      call method me->add_style
        exporting
          i_type     = c_type_numeric
          i_rowstyle = rowstyle
          i_decimals = l_decimals
          i_indent   = l_indent
        importing
          e_index    = ls_cell-style.

      l_width = strlen( l_value ).

   elseif l_inttype EQ cl_abap_typedescr=>typekind_date.

      ls_cell-value = l_value.

      call method me->add_style
        exporting
          i_type     = c_type_date
          i_rowstyle = rowstyle
          i_indent   = l_indent
        importing
          e_index    = ls_cell-style.

      l_width = 11.

   elseif l_inttype EQ cl_abap_typedescr=>typekind_time.

      ls_cell-value = l_value.

      if ls_cell-value eq '1.00000000000000'.
*...     special handling for 24:00:00
         call method me->add_style
           exporting
             i_type      = c_type_hour
             i_rowstyle  = rowstyle
             i_indent    = l_indent
         importing
           e_index     = ls_cell-style.

      else.
*...    time values unless 24:00:00
        call method me->add_style
          exporting
            i_type      = c_type_time
            i_rowstyle  = rowstyle
            i_indent    = l_indent
          importing
            e_index     = ls_cell-style.

      endif.

      l_width = 11.

   else.

      "includes everything that is exported as text:
      " - fields with conversion exit
      " - strings, characters, ...
      " - UTCLONG in ISO format

      ls_cell-sharedstring = 's'.

      if l_imageid is not initial.
        tmp_i = 1 + l_img_width div 12.
        if l_indent < tmp_i.
          l_indent = tmp_i.
        endif.
      endif.

      lv_is_quote_prefix_enabled =
           cl_salv_wd_export_util=>is_content_sanitization_needed( l_value ).

      if lv_is_quote_prefix_enabled eq abap_true.
        l_quote_prefix = 1.
      else.
        l_quote_prefix = 0.
      endif.

      call method me->add_style
        exporting
          i_type     = c_type_string
          i_rowstyle = rowstyle
          i_indent   = l_indent
          i_quote    = l_quote_prefix
        importing
          e_index    = ls_cell-style.

      call method me->add_sharedstring
        exporting
          i_sharedstring = cl_salv_wd_export_util=>escape_basic_string( l_value )
        importing
          e_index        = ls_cell-index.

      l_width = strlen( l_value ).
    endif.

    " adjust column width
    l_width = l_width + l_img_width div 7 + l_indent div 2.
    " one indent ~ 12 pixel
    " ls_columninfo-width = 100 ~ 714 pixel

    if l_width > ls_columninfo-width.
      ls_columninfo-width = l_width.
      modify table t_columninfo from ls_columninfo.
    endif.

    insert ls_cell into table s_row-t_cells.
  endif.

* all other columns
  loop at t_visible_columns into ls_column.

      l_col_index = l_col_index + 1.

      clear ls_cell.
      clear l_imageid.
      clear l_img_width.
      clear l_value.
      clear l_inttype.
      clear l_decimals.
      clear l_indent.
      clear l_hyperlink.

      read table t_columninfo into ls_columninfo with key columnid = ls_column-id.
      ls_attribute = ls_columninfo-attribute.
      l_uie_type = ls_columninfo-properties-uie.

      call method me->get_cellposition
        exporting
          row    = row_index
          col    = l_col_index
        receiving
          result = ls_cell-position.

      if <ls_data> is assigned.
        call method me->create_cell
          exporting
            columninfo        = ls_columninfo
            columnid          = ls_column-id
            r_model           = r_model
            s_data            = <ls_data>
            s_result          = s_result
            cell_id           = ls_cell-position
            t_visible_columns = t_visible_columns
          t_hier_columns    = t_hier_columns
          importing
            value        = l_value
            decimals     = l_decimals
            image_id     = l_imageid
            inttype      = l_inttype
            indent       = l_indent.
      else.
        call method me->create_cell
          exporting
            columninfo        = ls_columninfo
            columnid          = ls_column-id
            r_model           = r_model
            s_result          = s_result
            cell_id           = ls_cell-position
            t_visible_columns = t_visible_columns
          t_hier_columns    = t_hier_columns
          importing
            value        = l_value
            decimals     = l_decimals
            image_id     = l_imageid
            inttype      = l_inttype
            indent       = l_indent.
      endif.

*     add image on cell
      if l_imageid is not initial.

        l_row_index = row_index - 1.

        l_img_height = 0.
        l_img_width = 0.

        call method me->add_image
          exporting
            id      = l_imageid
            col     = l_col_index
            row     = l_row_index
          changing
            height  = l_img_height
            width   = l_img_width.

        if l_img_height > l_max_height.
          l_max_height = l_img_height.
        endif.

      endif.

      if l_uie_type eq if_salv_bs_model_column=>uie_link_to_url
      or l_uie_type eq if_salv_bs_model_column=>uie_link_to_url_gui.
        if l_value is not initial.
           l_hyperlink = 1.
        endif.
      endif.

      if l_inttype eq 'P' and
         ( ls_attribute-s_dfies-convexit eq 'TSTMP' or ls_attribute-s_dfies-domname(8) eq 'TZNTSTMP' ).

        ls_cell-value = l_value.

        call method me->add_style
          exporting
            i_type      = c_type_timestamp
            i_rowstyle  = rowstyle
            i_hyperlink = l_hyperlink
            i_wrap      = l_wrap
          importing
            e_index     = ls_cell-style.

        l_width = 15.

      elseif  l_uie_type ne if_salv_bs_model_column=>uie_dropdown_by_idx
        and ( l_inttype  ca if_salv_bs_log_exp_operand=>c_numeric and
              ls_attribute-s_dfies-convexit is initial )
        or  ( l_inttype = cl_abap_typedescr=>typekind_packed and   " AFLE #2887221
              ( ls_attribute-reference_field is not initial or
                ls_attribute-reference_value is not initial ) and
              ls_attribute-convexit_afle = abap_true ).

        ls_cell-value = l_value.

        "workaround for Microsoft bug: cannot handle initial value with 14 decimals or more
        "error occurs: Excel found unreadable content
        "will be removed once bug is fixed by Microsoft
        if l_value = '0.00000000000000' or l_value = '0,00000000000000' or
           l_value = l_zero_fltp_dot or l_value = l_zero_fltp_comma.  " note #2234051
          ls_cell-value = '0'.
        endif.


        call method me->add_style
          exporting
            i_type      = c_type_numeric
            i_rowstyle  = rowstyle
            i_decimals  = l_decimals
            i_hyperlink = l_hyperlink
            i_wrap      = l_wrap
            i_indent    = l_indent
          importing
            e_index     = ls_cell-style.

        l_width = strlen( l_value ).

      elseif l_inttype EQ cl_abap_typedescr=>typekind_date.

        ls_cell-value = l_value.

        call method me->add_style
          exporting
            i_type      = c_type_date
            i_rowstyle  = rowstyle
            i_hyperlink = l_hyperlink
            i_wrap      = l_wrap
            i_indent    = l_indent
          importing
            e_index     = ls_cell-style.

        l_width = 11.

      elseif l_inttype EQ cl_abap_typedescr=>typekind_time.

        ls_cell-value = l_value.

        if ls_cell-value eq '1.00000000000000'.
*...      special handling for 24:00:00
          call method me->add_style
            exporting
              i_type      = c_type_hour
              i_rowstyle  = rowstyle
              i_hyperlink = l_hyperlink
              i_wrap      = l_wrap
              i_indent    = l_indent
          importing
            e_index     = ls_cell-style.

        else.
*...      time values unless 24:00:00
          call method me->add_style
            exporting
              i_type      = c_type_time
              i_rowstyle  = rowstyle
              i_hyperlink = l_hyperlink
              i_wrap      = l_wrap
              i_indent    = l_indent
            importing
              e_index     = ls_cell-style.

        endif.

        l_width = 11.

      else.
        "includes everything that is exported as text:
        " - fields with conversion exit
        " - strings, characters, ...
        " - UTCLONG in ISO format

        ls_cell-sharedstring = 's'.

        if l_imageid is not initial.

          tmp_i = 1 + l_img_width div 12.
          if l_indent < tmp_i.
            l_indent = tmp_i.
          endif.
        endif.

        lv_is_quote_prefix_enabled =
          cl_salv_wd_export_util=>is_content_sanitization_needed( l_value ).

        if lv_is_quote_prefix_enabled eq abap_true.
          l_quote_prefix = 1.
        else.
          l_quote_prefix = 0.
        endif.

        call method me->add_style
          exporting
            i_type      = c_type_string
            i_rowstyle  = rowstyle
            i_hyperlink = l_hyperlink
            i_wrap      = l_wrap
            i_indent    = l_indent
            i_quote     = l_quote_prefix
          importing
            e_index     = ls_cell-style.

        data(l_preserve_space) = me->has_preserve_space( s_column = ls_column ).

        call method me->add_sharedstring
          exporting
            i_sharedstring   = cl_salv_wd_export_util=>escape_basic_string( l_value )
            i_preserve_space = l_preserve_space
          importing
            e_index        = ls_cell-index.

        l_width = strlen( l_value ).

      endif.

      " adjust column width
      l_width = l_width + l_img_width div 7 + l_indent div 2.
      " one indent ~ 12 pixel
      " ls_columninfo-width = 100 ~ 714 pixel

       if l_width > ls_columninfo-width.
         ls_columninfo-width = l_width.
         modify table t_columninfo from ls_columninfo.
     endif.

     insert ls_cell into table s_row-t_cells.
   endloop.

   if l_max_height > l_min_height.
     s_row-height = l_max_height.
   endif.

endmethod.


method CREATE_DATA_CELL.

  clear:
    value,
    decimals,
    image_id,
    inttype.

  data:
    ls_attribute          type if_salv_bs_t_data=>s_type_attribute,
    ls_uie_properties     type if_salv_bs_model_column=>s_type_uie_properties.

  data:
    l_field        type string,
    l_reference    type string,
    l_uie_type     type string,
    l_image_type   type string,
    l_tech_form    type string,
    l_decimals     type string,
    l_round        type string,
    l_exponent     type string,
    l_image        type string.

  field-symbols:
    <l_reffieldvalue>  type any.

  l_field = columninfo-field.
  ls_attribute = columninfo-attribute.
  ls_uie_properties = columninfo-properties.

  " Get TECH_FORM (GUI ALV specific)
  if ls_uie_properties-s_tech_form is not initial.
    l_tech_form = ls_uie_properties-s_tech_form.
    condense l_tech_form.
  endif.

  " Get DECIMALS
  if ls_uie_properties-s_decimals-fieldname is not initial.
    assign component ls_uie_properties-s_decimals-fieldname of STRUCTURE s_data to <l_reffieldvalue>.
    if <l_reffieldvalue> is not initial.
      l_decimals = <l_reffieldvalue>.
    endif.
  else.
    if ls_uie_properties-s_decimals-value is not initial.
      l_decimals = ls_uie_properties-s_decimals-value.
    endif.
  endif.

  " Get ROUNDING
  if ls_uie_properties-s_round-fieldname is not initial.
    assign component ls_uie_properties-s_round-fieldname of STRUCTURE s_data to <l_reffieldvalue>.
    if <l_reffieldvalue> is not initial.
      l_round = <l_reffieldvalue>.
    endif.
  else.
    if ls_uie_properties-s_round-value is not initial.
      l_round = ls_uie_properties-s_round-value.
    endif.
  endif.

  " Get EXPONENT
  if ls_uie_properties-s_exponent-fieldname is not initial.
    assign component ls_uie_properties-s_exponent-fieldname of STRUCTURE s_data to <l_reffieldvalue>.
    if <l_reffieldvalue> is not initial.
      l_exponent = <l_reffieldvalue>.
    endif.
  else.
    if ls_uie_properties-s_exponent-value is not initial.
      l_exponent = ls_uie_properties-s_exponent-value.
    endif.
  endif.

  "get CELL IMAGE
  if ls_uie_properties-s_image-fieldname is not initial or ls_uie_properties-s_image-value is not initial.
    me->get_cell_image(
      exporting
        s_data = s_data
        image_fieldname = ls_uie_properties-s_image-fieldname
        image_value     = ls_uie_properties-s_image-value
        image_type      = ls_uie_properties-image_type
      importing
        image_id        = image_id ).
  endif.


* get CELL VALUE
  l_uie_type = ls_uie_properties-uie.
  inttype    = ls_attribute-s_dfies-inttype.

  "if not l_field is initial.
  "get only text or value ... the image information is already retrieved above.
  "ignore any additional image information retruned by the method
  if not ls_uie_properties-s_value-fieldname is initial or not ls_uie_properties-s_text-fieldname is initial.

    me->get_cell_value(
      exporting
        s_data      = s_data
        fieldname   = l_field
        i_reference = l_reference
        i_decimals  = l_decimals
        i_round     = l_round
        i_exponent  = l_exponent
        i_tech_form = l_tech_form
        r_model     = r_model
        uie_type    = l_uie_type
        image_type  = l_image_type
      importing
        value       = value
        decimals    = decimals ).

    if inttype eq cl_abap_typedescr=>typekind_date and value cp '*-*-*'.
     "U1YK005337 if the date is less than 01.01.1900 the
     "content should be exported as string type (yyyy-mm-dd)
      inttype = cl_abap_typedescr=>typekind_string.
    endif.
  else.
    "if no l_field available, it means that the cell editor does not
    "have a fieldname assigned for its primary and secondary (if available) attribute.
    "in that case it needs to be cehcked if a static text/value has been provided in the cell editor
    if ls_uie_properties-s_text-value is not initial.
      value = ls_uie_properties-s_text-value.
    elseif ls_uie_properties-s_value-value is not initial.
      value = ls_uie_properties-s_value-value.
    endif.
  endif.


  if l_uie_type eq if_salv_bs_model_column=>uie_link_to_url.
    if columninfo-properties-s_hyperlink-value is not initial.
      call method me->add_hyperlink
        exporting
          i_link    = columninfo-properties-s_hyperlink-value
          i_cell_id = cell_id.

    elseif columninfo-properties-s_hyperlink-fieldname is not initial.
      field-symbols: <ls_hyp_field> type any.
      assign component columninfo-properties-s_hyperlink-fieldname of structure s_data to <ls_hyp_field>.
      if <ls_hyp_field> is not initial.
        data l_link type string.
        l_link = <ls_hyp_field>.
        call method me->add_hyperlink
          exporting
            i_link    = l_link
            i_cell_id = cell_id.
      endif.
    endif.

  elseif l_uie_type eq if_salv_bs_model_column=>uie_link_to_url_gui. "GUI ALV hyper link
    if columninfo-properties-s_hyperlink-value is not initial.
      call method me->add_hyperlink
        exporting
          i_link    = columninfo-properties-s_hyperlink-value
          i_cell_id = cell_id.

    elseif columninfo-properties-s_hyperlink-fieldname is not initial.
      "s_hyperlink_fieldname points to a field in the ALV data -> s_data
      " this field holds a pointer to table T_HYPE, which is then providing the actual URL
      field-symbols: <l_hyp_value> type any.
      assign component columninfo-properties-s_hyperlink-fieldname of structure s_data to <l_hyp_value>.
      if <l_hyp_value> is not initial.
        data ls_hype type lvc_s_hype.
        data lr_model type ref to cl_salv_ex_cm.

        lr_model ?= r_model->r_model.

        read table lr_model->t_hype into ls_hype with key handle = <l_hyp_value>.
        if sy-subrc eq 0.
          l_link = ls_hype-href.

          call method me->add_hyperlink
            exporting
              i_link    = l_link
              i_cell_id = cell_id.
        endif.
      endif.
    endif.
  endif.

endmethod.


method CREATE_HEADER_ROW.

  data:
    ls_cell         type ys_cell_struc,
    l_col_index     type i,
    l_width         type i,
    l_wrapped_lines type i,
    ls_columninfo   type ys_columninfo,
    ls_column       type if_salv_bs_model_columns=>s_type_column,
    l_header_text   type string,
    l_header_text2  type string,
    ls_hier_column  type if_salv_bs_model_columns=>s_type_column.

  data:
    l_quote_prefix type i,
    lv_is_quote_prefix_enabled type abap_bool.

  l_col_index = 0.

* hierarchy column
  if r_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    l_col_index = l_col_index + 1.

    clear ls_cell.
    clear l_header_text.
    read table t_columninfo into ls_columninfo with key columnid = 'HIERCOL'.

    "get hierarchy header text
    loop at t_hier_columns into ls_hier_column.
      try.
        l_header_text2 = r_model->if_salv_bs_model_column~get_header_text( ls_hier_column-id ).
      catch cx_salv_bs_sc_object_not_found.               "#EC NO_HANDLER
      endtry.

      if l_header_text is initial.
        l_header_text = l_header_text2.
      else.
        if l_header_text2 is not initial.
          concatenate l_header_text l_header_text2 into l_header_text separated by '/'.
        endif.
      endif.
    endloop.

    call method me->get_cellposition
      exporting
        row    = 1
        col    = l_col_index
      receiving
        result = ls_cell-position.

    ls_cell-style = style_index.
    ls_cell-sharedstring = 's'.

    lv_is_quote_prefix_enabled =
      cl_salv_wd_export_util=>is_content_sanitization_needed( l_header_text ).

    if lv_is_quote_prefix_enabled eq abap_true.
      l_quote_prefix = 1.
      call method me->add_style
        exporting
          i_type     = c_type_string
          i_rowstyle = c_rowstyle_title
          i_quote    = l_quote_prefix
        importing
          e_index    = ls_cell-style.
    else.
      l_quote_prefix = 0.
    endif.

    call method me->add_sharedstring
      exporting
        i_sharedstring = cl_salv_wd_export_util=>escape_basic_string( l_header_text )
      importing
        e_index        = ls_cell-index.

    insert ls_cell into table s_row-t_cells.

    l_width = strlen( l_header_text ).
    if l_width > ls_columninfo-width.
       ls_columninfo-width = l_width.
       modify table t_columninfo from ls_columninfo.
    endif.
  endif.

* loop over the header cells
  loop at t_visible_columns into ls_column.

    l_col_index = l_col_index + 1.
    read table t_columninfo into ls_columninfo with key columnid = ls_column-id.

    try.
      l_header_text = r_model->if_salv_bs_model_column~get_header_text( ls_column-id ).
    catch cx_salv_bs_sc_object_not_found.               "#EC NO_HANDLER
    endtry.

    clear ls_cell.

    call method me->get_cellposition
      exporting
        row    = 1
        col    = l_col_index
      receiving
        result = ls_cell-position.

    ls_cell-style = style_index.
    ls_cell-sharedstring = 's'.

    lv_is_quote_prefix_enabled =
      cl_salv_wd_export_util=>is_content_sanitization_needed( l_header_text ).

    if lv_is_quote_prefix_enabled eq abap_true.
      l_quote_prefix = 1.
      call method me->add_style
        exporting
          i_type     = c_type_string
          i_rowstyle = c_rowstyle_title
          i_quote    = l_quote_prefix
        importing
          e_index    = ls_cell-style.
    else.
      l_quote_prefix = 0.
    endif.

    call method me->add_sharedstring
      exporting
        i_sharedstring = cl_salv_wd_export_util=>escape_basic_string( l_header_text )
      importing
        e_index        = ls_cell-index.

    l_width = strlen( l_header_text ).
    if ls_columninfo-width > 0.
      if l_width > ls_columninfo-width and ls_columninfo-width + 10 > l_width.
        ls_columninfo-width = l_width.
        modify table t_columninfo from ls_columninfo.
      elseif l_width > ls_columninfo-width.

        l_wrapped_lines = l_width div ls_columninfo-width.
        if l_wrapped_lines > 4.
           ls_columninfo-width = ( ls_columninfo-width + l_width ) / 2.
           modify table t_columninfo from ls_columninfo.
        endif.

        call method me->add_style
          exporting
            i_type     = c_type_string
            i_rowstyle = c_rowstyle_title
            i_wrap     = 1
            i_quote    = l_quote_prefix
          importing
            e_index    = ls_cell-style.
      endif.
    else.
      if l_width <= 0.
         l_width = 4.
      endif.
      ls_columninfo-width = l_width.
      modify table t_columninfo from ls_columninfo.
    endif.

    insert ls_cell into table s_row-t_cells.
  endloop.

endmethod.


method CREATE_HIER_CELL.

  data:
    ls_attribute          type if_salv_bs_t_data=>s_type_attribute,
    lr_result_data        type ref to cl_salv_bs_result_data_table,
    l_hier_value          type if_salv_bs_t_data=>s_type_value.

  lr_result_data ?= me->r_result_table.

***  "retrieve hierarchy field
***  data(l_hier_field) = lr_result_data->if_salv_bs_r_data_hierarchy~get_text_field( s_result-s_hierarchy-index ).
***
***  data lr_data_table type ref to cl_salv_bs_data_table.
***  lr_data_table ?= r_model->r_data.
***
***  if lr_data_table->attributes_supplied eq abap_false.
***    lr_data_table->get_attributes( ).
***  endif.
***  read table lr_data_table->t_attribute into ls_attribute with key name = l_hier_field.
***
***  if ls_attribute is not initial.
***    inttype = ls_attribute-s_dfies-inttype.
******  ls_attribute = columninfo-attribute.
***  endif.


  clear image_id.
  clear value.
  clear decimals.

  l_hier_value = lr_result_data->if_salv_bs_r_data_hierarchy~get_text_value( s_result-s_hierarchy-index ).
  value = l_hier_value-value_external.

  l_hier_value = lr_result_data->if_salv_bs_r_data_hierarchy~get_image_value( s_result-s_hierarchy-index ).
  image_id = l_hier_value-value_external.

* add Aggregation Info to Hierarchy Column Text U1YK008708
  data:
    ls_hierarchy       type if_salv_bs_r_data_hierarchy=>s_type_hierarchy,
    ls_aggr_line_descr type if_salv_bs_r_data_table_aggr=>s_type_aggr_line_descr,
    ls_char_descr      type if_salv_bs_r_data_table_aggr=>s_type_characteristic_descr.

  ls_aggr_line_descr = me->R_RESULT_TABLE->if_salv_bs_r_data_table_aggr~get_aggr_line_data(
                         s_result_data = s_result ).

  read table lr_result_data->if_salv_bs_r_data_hierarchy~t_hierarchy into ls_hierarchy
    index s_result-s_hierarchy-index.
  if sy-subrc eq 0.
    loop at ls_aggr_line_descr-t_characteristic into ls_char_descr.
      if ls_hierarchy-s_group_info-field eq ls_char_descr-characteristic or
         ls_char_descr-characteristic is initial.
        if image_id is initial.
          value = ls_char_descr-value_external.
        else.
          value = ls_char_descr-value_count.
        endif.
      endif.
    endloop.
  endif.

endmethod.


method CREATE_TOTAL_CELL.

  data:
    ls_attribute             type if_salv_bs_t_data=>s_type_attribute,
    ls_uie_properties        type if_salv_bs_model_column=>s_type_uie_properties,
    ls_first_visible_column  type if_salv_bs_model_columns=>s_type_column.

  data:
    l_field        type string,
    l_reference    type string,
    l_attribute01  type string,
    l_uie_type     type string,
    l_image_type   type string.

  field-symbols:
    <l_cell_int>         type any.

*... get aggregation data
  data:
    ls_aggr_line_descr type if_salv_bs_r_data_table_aggr=>s_type_aggr_line_descr.

  ls_aggr_line_descr = me->R_RESULT_TABLE->if_salv_bs_r_data_table_aggr~get_aggr_line_data(
                         s_result_data = s_result ).

  data:
    ls_char_descr        type if_salv_bs_r_data_table_aggr=>s_type_characteristic_descr,
    ls_first_char_descr  type if_salv_bs_r_data_table_aggr=>s_type_characteristic_descr,
    ls_keyf_descr        type if_salv_bs_r_data_table_aggr=>s_type_keyfigure_descr.

  data:
    l_round     type string,
    l_decimals  type string,
    l_exponent  type string,
    l_tech_form type string,
    l_fieldname type string,
    l_value     type string.

  data:
    l_too_many_units type abap_bool.

  l_too_many_units = abap_false.

  data:
    lr_service_manager type ref to cl_salv_bs_service_mngr_table.

  lr_service_manager ?= me->R_RESULT_TABLE->r_service_manager.

  field-symbols:
    <ls_keyfigure_tree> type salv_bs_s_keyfigure_tree.


  ls_uie_properties = columninfo-properties.

  " provide inttype to ensure date format for subtotals #1928882
  inttype = columninfo-attribute-s_dfies-inttype.

  " Get TECH_FORM (GUI ALV specific)
  if ls_uie_properties-s_tech_form is not initial.
    l_tech_form = ls_uie_properties-s_tech_form.
    condense l_tech_form.
  endif.

  " Get DECIMALS
  if ls_uie_properties-s_decimals-value is not initial.
    l_decimals = ls_uie_properties-s_decimals-value.
  endif.

  " Get ROUNDING
  if ls_uie_properties-s_round-value is not initial.
    l_round = ls_uie_properties-s_round-value.
  endif.

  " Get EXPONENT
  if ls_uie_properties-s_exponent-value is not initial.
    l_exponent = ls_uie_properties-s_exponent-value.
  endif.

*... ... get keyfigure value
  if l_value is initial.
    read table ls_aggr_line_descr-t_keyfigure into ls_keyf_descr
      with key s_keyfigure-column = columnid.
    if sy-subrc eq 0.
      l_fieldname  = ls_keyf_descr-s_keyfigure-s_attribute-name.
      l_value      = ls_keyf_descr-s_keyfigure-value_internal.
      l_reference  = ls_keyf_descr-s_unit-value_internal.
      assign ls_keyf_descr-s_keyfigure-r_value_internal->* to <l_cell_int>.

      inttype = columninfo-attribute-s_dfies-inttype.

*... ... ... remove value if different units in sum in the hierarchy case
      if s_result-type eq cl_salv_bs_result_data_table=>c_type_hierarchy.
        read table lr_service_manager->t_keyfigure_tree assigning <ls_keyfigure_tree>
          index s_result-s_aggr-index.
        if sy-subrc eq 0.
*... ... ... ... aggregation on hierarchy
          loop at lr_service_manager->t_measure transporting no fields
            where nodekey    eq <ls_keyfigure_tree>-nodekey
              and name       eq ls_keyf_descr-s_keyfigure-s_attribute-name
              and line_index gt 1.
            exit.
          endloop.
          if sy-subrc eq 0.
            l_too_many_units = abap_true.
          endif.
        endif.
      endif.
    endif.
  endif.

*... ... get unit value
  if l_value is initial.
    read table ls_aggr_line_descr-t_keyfigure into ls_keyf_descr
      with key s_unit-column = columnid.
    if sy-subrc eq 0.
      l_fieldname = ls_keyf_descr-s_unit-s_attribute-name.
      l_value     = ls_keyf_descr-s_unit-value_internal.
      assign l_value to <l_cell_int>. "units are always of char type

*... ... ... remove value if different units in sum in the hierarchy case
      if s_result-type eq cl_salv_bs_result_data_table=>c_type_hierarchy.
        read table lr_service_manager->t_keyfigure_tree assigning <ls_keyfigure_tree>
          index s_result-s_aggr-index.
        if sy-subrc eq 0.
*... ... ... ... aggregation on hierarchy
          loop at lr_service_manager->t_measure transporting no fields
            where nodekey    eq <ls_keyfigure_tree>-nodekey
              and name       eq ls_keyf_descr-s_keyfigure-s_attribute-name
              and line_index gt 1.
            exit.
          endloop.
          if sy-subrc eq 0.
            l_too_many_units = abap_true.
          endif.
        endif.
      endif.
    endif.
  endif.

**... ... get characteristic value
  if l_value is initial and s_result-s_aggr-line_index <= 1.
    read table ls_aggr_line_descr-t_characteristic into ls_char_descr
      with key column = columnid.
    if sy-subrc eq 0.

*     check whether first aggregation is visible or not
      read table ls_aggr_line_descr-t_characteristic into ls_first_char_descr index 1.
      if sy-subrc eq 0.
         read table t_visible_columns with key id = ls_first_char_descr-column transporting no fields.
         if sy-subrc ne 0.
           ls_char_descr = ls_first_char_descr.
           inttype = ls_first_char_descr-s_attribute-s_dfies-inttype.
         endif.
      endif.

      l_fieldname = ls_char_descr-s_attribute-name.

      if lines( ls_char_descr-t_value ) gt 1.
        l_value = ls_char_descr-value_external.
        unassign <l_cell_int>.
        value = l_value.
      else.
        l_value = ls_char_descr-value_internal.
        assign ls_char_descr-r_value_internal->* to <l_cell_int>.
      endif.
    else.
      read table t_visible_columns into ls_first_visible_column index 1.

*     check whether current column is the first visible column
      if sy-subrc eq 0 and ls_first_visible_column-id EQ columnid.

*       check whether first aggregation is visible or not
        read table ls_aggr_line_descr-t_characteristic into ls_first_char_descr index 1.
        if sy-subrc eq 0.
           read table t_visible_columns with key id = ls_first_char_descr-column transporting no fields.
           if sy-subrc ne 0.
             read table t_hier_columns with key id = ls_first_char_descr-column transporting no fields.
             if sy-subrc ne 0.
               ls_char_descr = ls_first_char_descr.
             inttype = ls_first_char_descr-s_attribute-s_dfies-inttype.

             l_fieldname = ls_char_descr-s_attribute-name.

             if lines( ls_char_descr-t_value ) gt 1.
               l_value = ls_char_descr-value_external.
               unassign <l_cell_int>.
               value = l_value.
             else.
               l_value = ls_char_descr-value_internal.
               assign ls_char_descr-r_value_internal->* to <l_cell_int>.
             endif.
             endif.
           endif.
        endif.

      endif.
    endif.
* maintain image settings for icons in subtotal criteria SAPGUI ALV
    l_image_type = LS_UIE_PROPERTIES-IMAGE_TYPE.   "U1YK140759
  endif.

  if <l_cell_int> is assigned and l_too_many_units eq abap_false ." and not <l_cell_int> is initial.

    if l_image_type is initial.
      me->get_cell_value(
        exporting
          s_data      = <l_cell_int>
          fieldname   = l_fieldname
          i_reference = l_reference
          r_model     = r_model
          uie_type    = l_uie_type
          image_type  = l_image_type
          i_round     = l_round
          i_decimals  = l_decimals
          i_exponent  = l_exponent
          i_tech_form = l_tech_form
        importing
          value       = value
          decimals    = decimals ) .
    else.  "U1YK140759 SAPGUI ALV
  "get CELL IMAGE including exceptions, icons, overwrites subtotal criterion by next data row
        if ls_uie_properties-s_image-fieldname is not initial or ls_uie_properties-s_image-value is not initial.
         me->get_cell_image(
           exporting
             s_data = s_data
             image_fieldname = ls_uie_properties-s_image-fieldname
             image_value     = l_value                     "ls_uie_properties-s_image-value
             image_type      = l_image_type                "ls_uie_properties-image_type
           importing
             image_id        = image_id ).
      endif.
    endif.
  endif.

endmethod.


method GENERATE_XML_AND_OPC.

  data: workbookpart type ref to CL_XLSX_WORKBOOKPART.
  data: worksheetparts type ref to cl_openxml_partcollection.
  data: part type ref to cl_openxml_part.
  data: worksheetpart type ref to cl_xlsx_worksheetpart.
  data: stylespart type ref to cl_xlsx_stylespart.
  data: sharedstringspart type ref to cl_xlsx_sharedstringspart.
  data: drawingpart type ref to cl_oxml_drawingspart.

  data: l_sheetxml type xstring,
        l_shared_xml type xstring,
        l_styles_xml type xstring,
        l_drawing_xml type xstring,
        l_output type xstring.

  " we need to use a string_writer when calling the transformation.
  " Reason is the parameter "ignore_conversion_errors" which makes the
  " transformation more robust in case of conversion errors
  " especially with Japanese DoubleByte Characters in a non-unicode system
  " => prevents dump CONVT_CODEPAGE / CX_SY_CONVERSION_CODEPAGE

  data: lr_xml_string_writer type REF TO cl_sxml_string_writer.

  try.

*   Transformation for the sheet part
    lr_xml_string_writer = cl_sxml_string_writer=>create( ignore_conversion_errors = abap_true ).

    call transformation SALV_BS_XML_OFF2007_SHEET
       source param = sheet_struct
       result xml lr_xml_string_writer.

    l_sheetxml = lr_xml_string_writer->get_output( abap_true ).

    sharedstring_struct-t_strings = me->t_strings.

*   Transformation for the shared strings part
    lr_xml_string_writer = cl_sxml_string_writer=>create( ignore_conversion_errors = abap_true ).

    call transformation SALV_BS_XML_OFF2007_SHARED
       source param = sharedstring_struct
       result xml lr_xml_string_writer.

    l_shared_xml = lr_xml_string_writer->get_output( abap_true ).

*   Transformation for the styles part
    lr_xml_string_writer = cl_sxml_string_writer=>create( ignore_conversion_errors = abap_true ).

    call transformation SALV_BS_XML_OFF2007_STYLE
      source param = style_struct
      result xml lr_xml_string_writer.

    l_styles_xml = lr_xml_string_writer->get_output( abap_true ).

*   Transformation for the drawing part
    if image_struct is not initial.
      lr_xml_string_writer = cl_sxml_string_writer=>create( ignore_conversion_errors = abap_true ).

      call transformation SALV_BS_XML_OFF2007_DRAWING
        source param = image_struct
        result xml lr_xml_string_writer.

      l_drawing_xml = lr_xml_string_writer->get_output( abap_true ).
    endif.

    catch cx_xslt_abap_call_error.                      "#EC NO_HANDLER
    catch cx_xslt_deserialization_error.                "#EC NO_HANDLER
    catch cx_xslt_format_error.                         "#EC NO_HANDLER
    catch cx_xslt_runtime_error.                        "#EC NO_HANDLER
    catch cx_xslt_serialization_error.                  "#EC NO_HANDLER
  endtry.

* Get the workbook part of the document
  try.
    call method XLSX_DOCUMENT->get_workbookpart
      receiving
        rr_part = workbookpart.

*   Get the first worksheet part
    call method workbookpart->get_worksheetparts
      receiving
        rr_parts = worksheetparts.

    call method worksheetparts->get_part
      exporting
        iv_index = 0
      receiving
        rr_part  = part.

    worksheetpart ?= part.

*   Fill first worksheet part with the XML data
    call method worksheetpart->feed_data
      exporting
        iv_data = l_sheetxml.

*   Get the style part from the workbook part
    call method workbookpart->add_stylespart
      receiving
        rr_part = stylespart.

*   Set the style data into style part
    call method stylespart->feed_data
      exporting
        iv_data = l_styles_xml.

*   Get the shared strings part from the workbook
    call method workbookpart->add_sharedstringspart
      receiving
        rr_part = sharedstringspart.

*   Set the sharedstrings XML to the part
    call method sharedstringspart->feed_data
      exporting
        iv_data = l_shared_xml.

    if image_struct is not initial.
*     Get the drawing part from the worksheet
      call method worksheetpart->get_drawingspart
        receiving
          rr_part = drawingpart.

*     Set the drawing XML to the part
      call method drawingpart->feed_data
        exporting
          iv_data = l_drawing_xml.
    endif.

*   Package OPC and get the output binary string
    call method XLSX_DOCUMENT->get_package_data
      receiving
        rv_data = l_output.

  catch cx_openxml_format.
  catch cx_openxml_not_found.
  catch cx_openxml_not_allowed.

  endtry.

  me->excel_xml = l_output.

endmethod.


method GET_CELLPOSITION.
  data l_remainder type i.
  data l_fraction type i.

  result = |{ row }|.

  l_fraction = col.
  while l_fraction > 0.
    l_remainder = ( l_fraction - 1 ) mod 26.
    l_fraction  = ( l_fraction - 1 ) div 26.
    concatenate c_abc+l_remainder(1) result into result.
  endwhile.
endmethod.


  method GET_CELL_IMAGE.

    field-symbols: <l_image_id> type any.

    data: l_image_id   type string,
          l_image_type type string.

    if image_fieldname is not initial and
       image_value is initial.    " U1YK140759 SAPGUI ALV
      assign component image_fieldname of structure s_data to <l_image_id>.
      if <l_image_id> is assigned.
        l_image_id = <l_image_id>.
      endif.
    elseif image_value is not initial.
      l_image_id = image_value.
    endif.

    "validate provided image_type
    if not image_type is initial.
      l_image_type = image_type.
      case l_image_type.
        when if_salv_bs_model_column=>uie_image or
             if_salv_bs_model_column=>uie_image_icon or
             if_salv_bs_model_column=>uie_image_symbol or
             if_salv_bs_model_column=>uie_image_exception_light or
             if_salv_bs_model_column=>uie_image_exception_led or
             if_salv_bs_model_column=>uie_image_exception_status or
             if_salv_bs_model_column=>uie_image_exception_message or
             if_salv_bs_model_column=>uie_image_exception_trend or
             if_salv_bs_model_column=>uie_image_exception_alert or
             if_salv_bs_model_column=>uie_image_exception_failure.
        when others.
          l_image_type = if_salv_bs_model_column=>uie_image.
      endcase.
    endif.

    "set the image_id dependent on the uie_type
    if l_image_type eq if_salv_bs_model_column=>uie_image or
       l_image_type eq if_salv_bs_model_column=>uie_image_icon or
       l_image_type eq if_salv_bs_model_column=>uie_image_symbol.

      image_id = l_image_id.

    elseif l_image_type eq if_salv_bs_model_column=>uie_image_exception_light or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_led or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_trend or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_message or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_alert or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_status or
           l_image_type eq if_salv_bs_model_column=>uie_image_exception_failure.

      data: l_exception_group type char01,
            l_output          type char04.

      case l_image_type.
        when if_salv_bs_model_column=>uie_image_exception_light.
          l_exception_group = '1'.
        when if_salv_bs_model_column=>uie_image_exception_led.
          l_exception_group = '2'.
        when if_salv_bs_model_column=>uie_image_exception_status.
          l_exception_group = '3'.
        when if_salv_bs_model_column=>uie_image_exception_trend.
          l_exception_group = '4'.
        when if_salv_bs_model_column=>uie_image_exception_message.
          l_exception_group = '5'.
        when if_salv_bs_model_column=>uie_image_exception_alert.
          l_exception_group = '6'.
        when if_salv_bs_model_column=>uie_image_exception_failure.
          l_exception_group = '7'.
      endcase.

      call method cl_alv_a_lvc=>int_2_ext_exception
        exporting
          exception_group = l_exception_group
          i_int_value     = l_image_id
        importing
          e_ext_value     = l_output.

      image_id = l_output.

    endif.

  endmethod.


method GET_CELL_VALUE.

" image value is retrieved in method get_cell_image()

  check fieldname is not initial.

  field-symbols:
    <l_data> type any.

  unassign <l_data>.
  assign component fieldname of structure s_data to <l_data>.
  if <l_data> is not assigned.
    assign s_data to <l_data>.
  endif.
  assert <l_data> is assigned.

  data:
    lr_data_table type ref to cl_salv_bs_data_table.

  lr_data_table ?= r_model->r_data.

*... get attribute
  data:
    ls_attribute type if_salv_bs_t_data=>s_type_attribute.

  if lr_data_table->attributes_supplied eq abap_false.
    lr_data_table->get_attributes( ).
  endif.
  read table lr_data_table->t_attribute into ls_attribute with key name = fieldname.

  check ls_attribute is not initial.

  field-symbols:
    <l_reference> type any.

  data:
    l_split1   type string,                                 "#EC NEEDED
    l_split2   type string.                                 "#EC NEEDED

  data:
    l_isovalue     type string,
    l_iso_decimals type i.

  if i_reference is initial.
    if ls_attribute-s_dfies-reference_field_type is not initial.
      if ls_attribute-s_dfies-reference_field is not initial.
        assign component ls_attribute-s_dfies-reference_field of structure s_data to <l_reference>.
      endif.
      if not <l_reference> is assigned.
        if ls_attribute-reference_value is not initial.
          assign ls_attribute-reference_value to <l_reference>.
        endif.
      endif.
      if not <l_reference> is assigned.
        if i_reference is supplied.
          assign i_reference to <l_reference>.
        endif.
      endif.
    endif.
  else.
    assign i_reference to <l_reference>.
  endif.

  if <l_reference> is not assigned.
    assign space to <l_reference>.
  endif.

  if uie_type eq if_salv_bs_model_column=>uie_checkbox.
    try.
        value = lr_data_table->get_external_value(
                   input         = <l_data>
                   attribute     = ls_attribute-name
                   reffieldvalue = <l_reference> ).
        if value is initial and <l_data> = abap_true.
*       short description is not maintained in DDIC
           value = abap_true.
        endif.
        value = cl_salv_bs_conv_tool=>to_string_boolean( value ).
      catch cx_salv_bs_tools_conv_error.                "#EC NO_HANDLER
    endtry.

  else.
    if ls_attribute-s_dfies-inttype eq cl_abap_typedescr=>typekind_date. "Date
      data:
        l_date type d,
        l_tmp type string.

      " check whether there is a date or just an initial string or blanks
      l_tmp = <l_data>.
      condense l_tmp.

      if l_tmp is initial or <l_data> is initial.
        value = ''.
      elseif l_tmp < '19000101'.
       "U1YK005337 if the date is less than 01.01.1900 the
       "content should be exported as string type (yyyy-mm-dd)
        value = cl_alv_xslt_transform=>get_isodate_from_intdate( l_tmp ).
      else.
        l_date = <l_data>.
*  ... ... fill attribute01 with days since 01.01.1900
        call method cl_alv_xslt_transform=>get_days_since_1900
          exporting
            i_date = l_date
          receiving
            e_num  = value.

        if value < 0.
          value = 0 - value.
          concatenate '-' value into value.
        endif.
      endif.

    elseif ls_attribute-s_dfies-inttype eq cl_abap_typedescr=>typekind_time. "Time
      data:
        l_time type t.

      l_time = <l_data>.

*... fill attribute01 with percent value of actual day
      if l_time ne 0 and l_time is not initial.
        call method cl_alv_xslt_transform=>get_percent_of_act_day
          exporting
            i_time = l_time
          receiving
            e_num  = value.
      else.
        value = 0.
      endif.

    elseif ls_attribute-s_dfies-inttype eq 'P' and
           ( ls_attribute-s_dfies-convexit eq 'TSTMP' or ls_attribute-s_dfies-domname(8) eq 'TZNTSTMP' ).

      "... fill attribute01 with days since 01.01.1900
      call method cl_alv_xslt_transform=>get_days_1900_and_percent
        exporting
          i_timestamp = <l_data>
        receiving
          e_num       = value.

    elseif ls_attribute-s_dfies-inttype eq cl_wdr_conversion_utils=>co_type_utclong.  "#EC CI_UTCL_OK.
      "retrieve UTCL in ISO format
      try.
          value = cl_salv_bs_conv_tool=>to_iso( input = <l_data> ).
        catch cx_salv_bs_tools_conv_error.  "#EC NO_HANDLER
          clear value.
      endtry.

    elseif  uie_type ne if_salv_bs_model_column=>uie_dropdown_by_idx
      and ( ls_attribute-s_dfies-inttype ca if_salv_bs_log_exp_operand=>c_numeric and
            ls_attribute-s_dfies-convexit is initial )
      or  ( ls_attribute-s_dfies-inttype = cl_abap_typedescr=>typekind_packed and  " AFLE #2887221
            ( ls_attribute-reference_field is not initial or
              ls_attribute-reference_value is not initial ) and
            ls_attribute-convexit_afle = abap_true ).

      case ls_attribute-s_dfies-reference_field_type.
        when if_salv_bs_c_data=>reffieldtype_curr.
         "... get iso value for currency value
         call method cl_alv_xslt_transform=>get_isonum_from_intnum
            exporting
              i_value          = <l_data>
              i_currency       = <l_reference>
              i_decimals       = i_decimals  " out_decimals of fcat, NOT the dec. as  num type p decimals 3
              i_round          = i_round " round of fcat
              i_gui_type       = me->gui_type
              i_decimals_dfies = ls_attribute-s_dfies-decimals" decimals as specified in dfies (e.g. -> type p DECIMALS 3)
              i_tech_form      = i_tech_form
            importing
              e_value          = l_isovalue
            .

        when if_salv_bs_c_data=>reffieldtype_quan.
          "... get iso value for quantity value
          call method cl_alv_xslt_transform=>get_isonum_from_intnum
            exporting
              i_value    = <l_data>
              i_unit     = <l_reference>
              i_decimals       = i_decimals  " out_decimals of fcat, NOT the dec. as  num type p decimals 3
              i_round          = i_round  " round of fcat
              i_gui_type       = me->gui_type
              i_decimals_dfies = ls_attribute-s_dfies-decimals" decimals as specified in dfies (e.g. -> type p DECIMALS 3)
              i_tech_form      = i_tech_form
            importing
              e_value          = l_isovalue
            .

        when others.
          "... get iso value for value
          if ls_attribute-s_dfies-is_ddic_type = abap_true.
            call method cl_alv_xslt_transform=>get_isonum_from_intnum
              exporting
                i_value          = <l_data>
                i_decimals       = i_decimals  " out_decimals of fcat, NOT the dec. as  num type p decimals 3
                i_round          = i_round " round of fcat
                i_gui_type       = me->gui_type
                i_decimals_dfies = ls_attribute-s_dfies-decimals" decimals as specified in dfies (e.g. -> type p DECIMALS 3)
                i_type_kind      = ls_attribute-s_dfies-inttype
                i_exponent       = i_exponent
                i_dec_style      = ls_attribute-s_dfies-decimals
                i_tech_form      = i_tech_form
              importing
                e_value          = l_isovalue.
          else.
            "get_isonum_from_intnum checks if i_decimals_dfies is supplied - "IM 1874370 2011
            call method cl_alv_xslt_transform=>get_isonum_from_intnum
              exporting
                i_value          = <l_data>
                i_decimals       = i_decimals  " out_decimals of fcat, NOT the dec. as  num type p decimals 3
                i_round          = i_round " round of fcat
                i_gui_type       = me->gui_type
                "i_decimals_dfies = ls_attribute-s_dfies-decimals
                i_type_kind      = ls_attribute-s_dfies-inttype
                i_exponent       = i_exponent
                i_dec_style      = ls_attribute-s_dfies-decimals
                i_tech_form      = i_tech_form
              importing
                e_value          = l_isovalue.
          endif.
      endcase.

      value = l_isovalue.

      "... check for decimals whether different from column decimals
      split l_isovalue at '.' into: l_split1 l_split2.

      l_iso_decimals = strlen( l_split2 ).
      if l_iso_decimals ne i_decimals.
        decimals = l_iso_decimals.
      else.
        decimals = i_decimals.
      endif.

      if decimals is initial.
        decimals = 0.
      endif.

    elseif ( ls_attribute-value_set_field is not initial
             or ls_attribute-value_set is not initial ) and
           ( uie_type eq if_salv_bs_model_column=>uie_dropdown_by_idx
             or uie_type eq if_salv_bs_model_column=>uie_dropdown_by_key ).
        " we have a valueset - either direct of by field binding
        " and we have a dropdown UI element
        " that means that we want to resolve valueset
        " otherwise we do not want to resolve valueset => ignore_valueset = abap_true
          field-symbols:  <lt_valueset> type any.

      if ls_attribute-value_set_field is not initial.
        assign component ls_attribute-value_set_field of structure s_data to <lt_valueset>.
          else.
            assign ls_attribute-value_set to <lt_valueset>.
          endif.

          value = lr_data_table->get_external_value(
                  input         = <l_data>
                  attribute     = ls_attribute-name
                  reffieldvalue = <l_reference>
                  valueset      = <lt_valueset> ).

    else.
      " we have a text view or an input field
      " we possibly need to do conversionexit
      " we don't want to resolve valueset (only for dropdowns)

      data:
        l_conv_str type string.
        " we need to convert ls_attribute-s_dfies-convexit from c(5)
        " to string, as lr_data_table->get_external_value needs a
        " string
      concatenate ls_attribute-s_dfies-convexit '' into l_conv_str.

      " in this case we have e.g. chars and strings and numerical chars
      value = lr_data_table->get_external_value(
              input           = <l_data>
              attribute       = ls_attribute-name
              convexit        = l_conv_str
              reffieldvalue   = <l_reference>
              ignore_valueset = abap_true ).


    endif.
  endif.
endmethod.


  method HAS_PRESERVE_SPACE.

    " only SAP Gui ALV has implemented to preserve the leading spaces in Excel
    preserve_space = abap_false.

  endmethod.


method TRANSFORM.

   call method me->transform_to_off2007.

   excel_xml = me->excel_xml.

endmethod.


method TRANSFORM_TO_OFF2007.

  data:
    lr_model              type ref to cl_salv_bs_model_table,
    lt_result_data        type IF_SALV_BS_R_DATA_TABLE_TYPES=>T_TYPE_RESULT_DATA,
    lr_data_table         type ref to cl_salv_bs_data_table,
    ls_column             type if_salv_bs_model_columns=>s_type_column,
    lt_columns            type if_salv_bs_model_columns=>t_type_column,
    lt_visible_columns    type if_salv_bs_model_columns=>t_type_column,
    lt_visible_columns_l  type if_salv_bs_model_columns=>t_type_column,
    lt_visible_columns_r  type if_salv_bs_model_columns=>t_type_column,
    lt_hier_columns       type if_salv_bs_model_columns=>t_type_column,
    ls_result             type if_salv_bs_r_data_table_types=>s_type_result_data.

  data:
    ls_row   type ys_row_struc,
    ls_col   type ys_col_struc.

  data:
    l_no_columns   type i,
    l_no_rows      type i,
    l_dim          type string,
    l_spans        type string,
    l_no_images    type i,
    l_col_index    type i.

  data:
    ls_attribute type if_salv_bs_t_data=>s_type_attribute,
    lt_attributes type if_salv_bs_t_data=>t_type_attribute.

  data:
    lr_data type ref to data.

  lt_result_data = me->R_RESULT_TABLE->t_result_data.
  lr_model ?= me->R_RESULT_TABLE->r_model.
  lr_model->update_data_from_cm( ).
  lr_data_table ?= lr_model->r_data.
  lt_attributes = lr_data_table->get_attributes( ).

* Create OPC document
  call method cl_xlsx_document=>create_document
     receiving
       rr_doc   = XLSX_DOCUMENT.

* determine visible columns
* >>>>
  lt_columns = lr_model->if_salv_bs_model_columns~get_columns( ).
  sort lt_columns stable by position ascending.

  loop at lt_columns into ls_column.
    "BRAUNMI: Columns containig CellVariants can not be processed
    try.
        if lr_model->if_salv_bs_model_column~is_cell_dependant_uie_defined( ls_column-id ) eq abap_true.
          continue.
        endif.
      catch cx_salv_bs_sc_object_not_found.
        continue.
    endtry.

    " Check, whether we have a "One Click Action Column" i.e. a column with multicelleditors.
    " => ignore those columns; accoring to UX it does not make sense to export them.
    try.
      if lr_model->if_salv_bs_model_column~is_one_click_action_column( ls_column-id ) eq abap_true.
        continue.
      endif.
      catch cx_salv_bs_sc_object_not_found.
          continue.
    endtry.


*   do not use invisible columns
    try.
       if lr_model->if_salv_bs_model_column~is_visible( ls_column-id ) ne abap_true.
         continue.
       endif.
    catch cx_salv_bs_sc_object_not_found.
       continue.
    endtry.

*   do not show parts of hierarchy as columns
    try.
        if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
          if lr_model->if_salv_bs_model_column~is_hierarchy_column( ls_column-id ) eq abap_true.
            append ls_column to lt_hier_columns.
            continue.
          endif.
        endif.
      catch cx_salv_bs_sc_object_not_found.             "#EC NO_HANDLER
    endtry.


    "get fixed_position information
    data:
      l_fixed_position like if_salv_bs_c_column=>fixed_column_mode.

    try.
        l_fixed_position = lr_model->if_salv_bs_model_column~get_fixed_position( ls_column-id ).
      catch cx_salv_bs_sc_object_not_found.
    endtry.

    case l_fixed_position.
      when if_salv_bs_c_column=>fixed_column_mode_not_fixed.
        append ls_column to lt_visible_columns.
      when if_salv_bs_c_column=>fixed_column_mode_left.
        append ls_column to lt_visible_columns_l.
      when if_salv_bs_c_column=>fixed_column_mode_right.
        append ls_column to lt_visible_columns_r.
      when others.
        append ls_column to lt_visible_columns.
    endcase.

  endloop.

  "reorganize the columns which were separated by fixed column mode
  if not lt_visible_columns_l is initial.
    insert lines of lt_visible_columns_l into lt_visible_columns index 1.
  endif.

  if not lt_visible_columns_r is initial.
    append lines of lt_visible_columns_r to lt_visible_columns.
  endif.


* Determine positions of start cell and end cell of table content
  describe table lt_visible_columns lines l_no_columns.
  describe table lt_result_data lines l_no_rows.

  if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    l_no_columns = l_no_columns + 1.
  endif.

  call method me->get_cellposition
    exporting
      row    = ( l_no_rows + 1 )
      col    = l_no_columns
    receiving
      result = l_dim.

  concatenate 'A1:' l_dim into sheet_struct-dim.
  l_spans = |{ l_no_columns }|.
  concatenate '1:' l_spans into l_spans.

* below summary
  if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    sheet_struct-summary_below = '0'.
  endif.

  if lr_model->if_salv_bs_model_fields~is_aggr_before_items( ) eq abap_true.
    sheet_struct-summary_below = '0'.
  endif.

* determine sheet direction
  data l_application type ref to if_wd_application.
  if wdr_task=>application is bound.
    l_application  = wdr_task=>application->get_api( ).
    data(l_is_rtl) = l_application->get_is_rtl( ).
  endif.

  if sy-langu ca cl_i18n_bidi=>rtl_languages or l_is_rtl eq abap_true.
    sheet_struct-rtl_id = 1.
  endif.

*  styles
* >>>>>
  data l_style_index type i.

* add style for normal cell (must be at position 0)
  call method me->add_style
    exporting
      i_type        = c_type_string
      i_rowstyle    = c_rowstyle_normal.

* add style for header cell (to position 1)
  call method me->add_style
    exporting
      i_type     = c_type_string
      i_rowstyle = c_rowstyle_title
    importing
      e_index    = l_style_index.


* Maxlevel
* >>>>>>>>
  data: l_maxlevel   type i.

  loop at lt_result_data into ls_result.
    if ls_result-type EQ cl_salv_bs_result_data_table=>c_type_aggregation.
      if l_maxlevel < ls_result-s_aggr-level.
        l_maxlevel = ls_result-s_aggr-level.
      endif.
    endif.
  endloop.

  if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    loop at lt_result_data into ls_result.
      if ls_result-type EQ cl_salv_bs_result_data_table=>c_type_data.
        if l_maxlevel < ls_result-s_hierarchy-level.
          l_maxlevel = ls_result-s_hierarchy-level.
        endif.
      endif.
    endloop.
  endif.

  if l_maxlevel NE 0.
    add 1 to l_maxlevel .
  endif.

  sheet_struct-outlinelevel = l_maxlevel.


** Column info
* >>>>>>>
  data:
    ls_columninfo type ys_columninfo,
    lt_columninfo type yt_columninfo.

  loop at lt_visible_columns into ls_column.
    clear ls_columninfo.
    ls_columninfo-columnid = ls_column-id.

    try.
      ls_columninfo-field = lr_model->if_salv_bs_model_column~get_field( ls_column-id ).
    catch cx_salv_bs_sc_object_not_found.               "#EC NO_HANDLER
    endtry.

    try.
      ls_columninfo-properties = lr_model->if_salv_bs_model_column~get_uie_properties( ls_column-id ).
    catch cx_salv_bs_sc_object_not_found.
      return.
    endtry.

    read table lt_attributes into ls_columninfo-attribute with key name = ls_columninfo-field.

    insert ls_columninfo into table lt_columninfo.
  endloop.

  clear ls_columninfo.
  ls_columninfo-columnid = 'HIERCOL'.

  insert ls_columninfo into table lt_columninfo.


*  Data
* >>>>>>>>
  data: l_row_index          type i,
        l_data_index         type i,
        l_rowstyle           type c,
        l_sumlevel           type i.

  l_row_index = 0.
  l_data_index = 0.

  lr_data = lr_data_table->get_table_ref( ).

  loop at lt_result_data into ls_result.

    l_row_index = l_row_index + 1.
    l_data_index = l_data_index + 1.

    if ls_result-type EQ cl_salv_bs_result_data_table=>c_type_data.
      if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
        l_sumlevel = ls_result-s_hierarchy-level.
      else.
        if l_maxlevel gt 1.
          l_sumlevel = l_maxlevel.
        endif.
      endif.
    elseif ls_result-type EQ cl_salv_bs_result_data_table=>c_type_aggregation.
      l_sumlevel = ls_result-s_aggr-level.
    elseif ls_result-type EQ cl_salv_bs_result_data_table=>c_type_hierarchy.
      l_sumlevel = ls_result-s_hierarchy-level.
    endif.

    l_rowstyle = c_rowstyle_normal.
    if ls_result-type EQ cl_salv_bs_result_data_table=>c_type_aggregation.
      if l_sumlevel = 0.
         l_rowstyle = c_rowstyle_total.
      else.
         l_rowstyle = c_rowstyle_subtotal.
      endif.
    endif.

    clear ls_row.
    ls_row-spans = l_spans.
    ls_row-position = l_row_index.
    ls_row-outlinelevel = l_sumlevel.

    if ls_result-no_display EQ 'X'.
      ls_row-hidden = '1'.
    endif.

    call method me->create_cells
      exporting
        data_index        = ls_result-index
        r_data            = lr_data
        row_index         = l_row_index
        t_visible_columns = lt_visible_columns
        t_hier_columns    = lt_hier_columns
        r_model           = lr_model
        rowstyle          = l_rowstyle
        s_result          = ls_result
      changing
        s_row             = ls_row
        t_columninfo      = lt_columninfo.

    insert ls_row into table sheet_struct-t_rows.
  endloop.

*  header row
* >>>>>>
*  clear ls_row.
*  ls_row-spans = l_spans.
*  ls_row-position = 1.

* YI2K122249 initialize header row position and span
  sheet_struct-s_header_row-position = 1.
  sheet_struct-s_header_row-spans    = l_spans.

* loop over the header cells
  call method me->create_header_row
    exporting
      t_visible_columns = lt_visible_columns
      t_hier_columns    = lt_hier_columns
      r_model           = lr_model
      style_index       = l_style_index
    changing
      t_columninfo      = lt_columninfo
      s_row             = sheet_struct-s_header_row.


*  Columns
* >>>>>>>>

  l_col_index = 1.

  if lr_model->if_salv_bs_model_table_setting~is_display_as_hierarchy( ) eq abap_true.
    read table lt_columninfo into ls_columninfo with key columnid = 'HIERCOL'.

    clear ls_col.
    ls_col-min = l_col_index.
    ls_col-max = l_col_index.
    ls_col-bestFit = 1.
    ls_col-width = ls_columninfo-width + 2.

    insert ls_col into table sheet_struct-t_cols.

    add 1 to l_col_index.
  endif.


  loop at lt_visible_columns into ls_column.

    read table lt_columninfo into ls_columninfo with key columnid = ls_column-id.

    clear ls_col.
    ls_col-min = l_col_index.
    ls_col-max = l_col_index.
    ls_col-bestFit = 1.
    ls_col-width = ls_columninfo-width + 2.

    insert ls_col into table sheet_struct-t_cols.
    add 1 to l_col_index.
  endloop.

* do the rest
  call method me->generate_xml_and_opc.

endmethod.
ENDCLASS.

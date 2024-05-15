class ZPSU_CL_SALV_BS_EX_OFFICE2007 definition
  public
  inheriting from ZPSU_CL_SALV_BS_OFFICE2007_BAS
  final
  create public .

public section.
*"* public components of class ZPSU_CL_SALV_BS_EX_OFFICE2007
*"* do not include other source files here!!!
protected section.

*"* protected components of class CL_SALV_BS_EX_OFFICE2007
*"* do not include other source files here!!!
  methods GET_IMAGE_CONTENT
    redefinition .
  methods HAS_PRESERVE_SPACE
    redefinition .
private section.
*"* private components of class ZPSU_CL_SALV_BS_EX_OFFICE2007
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZPSU_CL_SALV_BS_EX_OFFICE2007 IMPLEMENTATION.


method GET_IMAGE_CONTENT.
  data l_image_code type string.

  l_image_code = image_value.
  cl_salv_wd_export_util=>get_gui_image_content(
      exporting i_image_code   = l_image_code
      importing e_content      = value ).

" OLD VERSION:
**  clear value.
**
**  data:
**    lr_mr_api type ref to if_mr_api,
**    l_value   type string,
**    l_url     type string.
**
**  l_value = image_value.
**
**  if strlen( l_value ) ge 4.
**    if l_value+3(1) = '\'.
**      concatenate l_value+0(3) '@' into l_value.
**    endif.
**  endif.
**
**  "Support of Icon Mirroring for RTL languages
**  if sy-langu ca cl_i18n_bidi=>rtl_languages.
**    l_url = cl_bsp_mimes=>sap_icon( id = l_value is_rtl = abap_true ).
**  else.
**    l_url = cl_bsp_mimes=>sap_icon( id = l_value is_rtl = abap_false ).
**  endif.
**
**  lr_mr_api = cl_mime_repository_api=>if_mr_api~get_api( ).
**
**  call method lr_mr_api->get
**    exporting
**      i_url     = l_url
**      i_check_authority = abap_false
**    importing
**      e_content = value
**    exceptions
**      others    = 5.

endmethod.


  method HAS_PRESERVE_SPACE.

    " only SAP Gui ALV has implemented to preserve the leading spaces in Excel
    " Excel removes the leading spaces by default except you define: xml:space="preserve"

    read table me->mt_preserve_space
      with table key
        column_id = s_column-id
      assigning field-symbol(<ls_preserve_space>).

    if sy-subrc = 0.
      preserve_space = <ls_preserve_space>-preserve_space.

    else.
      data(lr_column) = cast cl_salv_ex_object( s_column-r_column ).
      field-symbols <ls_fcat> type lvc_s_fcat.
      assign lr_column->r_data->* to <ls_fcat>.
      preserve_space = <ls_fcat>-parameter0.

      data(ls_preserve_space) = value ys_preserve_space(
        column_id      = s_column-id
        preserve_space = preserve_space ).

      insert ls_preserve_space into table me->mt_preserve_space.

    endif.

  endmethod.
ENDCLASS.

class ZPSU_CL_SALV_BS_WD_OFFICE2007 definition
  public
  inheriting from ZPSU_CL_SALV_BS_OFFICE2007_BAS
  final
  create public .

public section.
protected section.

  methods GET_IMAGE_CONTENT
    redefinition .
private section.
ENDCLASS.



CLASS ZPSU_CL_SALV_BS_WD_OFFICE2007 IMPLEMENTATION.


  method GET_IMAGE_CONTENT.
  data l_image_code type string.
  l_image_code = image_value.
  cl_salv_wd_export_util=>get_image_content(
    exporting i_image_code                   = image_value
              i_use_http_download            = abap_true
*              i_use_http_downld_for_rfc_dest = abap_true
    importing e_content                     = value ).
  endmethod.
ENDCLASS.

class ZPSU_CL_SALV_BS_TT_UTIL definition
  public
  final
  create public .

public section.

*"* public components of class ZPSU_CL_SALV_BS_TT_UTIL
*"* do not include other source files here!!!
  interfaces IF_SALV_BS_TT_UTIL .
protected section.
*"* protected components of class ZPSU_CL_SALV_BS_TT_UTIL
*"* do not include other source files here!!!
private section.

*"* private components of class ZPSU_CL_SALV_BS_TT_UTIL
*"* do not include other source files here!!!
  class-data R_LOG type ref to IF_SALV_CSQ_LOG .
  class-data R_LOG_PROVIDER type ref to IF_SALV_CSQ_LOG_PROVIDER .

  class-methods GET_LOGGER
    returning
      value(ER_LOG) type ref to IF_SALV_CSQ_LOG .
  class-methods GET_LOG_PROVIDER
    returning
      value(ER_LOG_PROVIDER) type ref to IF_SALV_CSQ_LOG_PROVIDER .
ENDCLASS.



CLASS ZPSU_CL_SALV_BS_TT_UTIL IMPLEMENTATION.


method GET_LOGGER.
  data:
    lr_log_provider type ref to if_salv_csq_log_provider.

  lr_log_provider = get_log_provider( ).

  if r_log is initial.
     r_log = r_log_provider->create_logger( 'SALV_BS_EXPORT' ).
  endif.
  er_log = r_log.

endmethod.


method GET_LOG_PROVIDER.
  if r_log_provider is initial.
     r_log_provider = cl_salv_csq_log=>get_session_log( ).
  endif.
  er_log_provider = r_log_provider.
endmethod.


method IF_SALV_BS_TT_UTIL~TRANSFORM.

  clear:
    xml,
    filename,
    mimetype,
    t_msg.

  if xml_type eq if_salv_bs_xml=>c_type_xlsx.
      DATA: lr_excel2007 type ref to zpsu_cl_salv_bs_office2007_bas.

      CASE r_result_data->result_data.
        WHEN if_salv_bs_c_result_data=>result_data_table_ex.
          CREATE OBJECT lr_excel2007 TYPE ZPSU_CL_SALV_BS_EX_OFFICE2007
            EXPORTING
              r_result_data = r_result_data.

        WHEN if_salv_bs_c_result_data=>result_data_table_wd.
          CREATE OBJECT lr_excel2007 TYPE ZPSU_CL_SALV_BS_WD_OFFICE2007
            EXPORTING
              r_result_data = r_result_data.

      ENDCASE.

      if lr_excel2007 is not initial.
        call method lr_excel2007->transform
          receiving
            excel_xml = xml.

      "unique filename note 2337397
      concatenate 'export_' sy-datlo sy-timlo '.xlsx' into filename.
      mimetype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'. "#EC NOTEXT
    endif.

    return.
  endif.

  data:
    l_xml_flavour like if_salv_bs_c_tt=>c_tt_xml_flavour_full.

  l_xml_flavour = xml_flavour.

  case xml_version.
    when if_salv_bs_xml=>version_22.
*... generate xml for export :
      data:
        lr_result_data_table_wd type ref to cl_salv_wd_result_data_table.

      try.
          lr_result_data_table_wd ?= r_result_data.
        catch cx_root.                                   "#EC CATCH_ALL
          return.
      endtry.

      data:
        ls_choice type if_salv_bs_xml=>s_type_xml_choice,
        lt_choice type if_salv_bs_xml=>t_type_xml_choice.

    ls_choice-version  = if_salv_bs_xml=>c_version_20.
    ls_choice-gui_type = if_salv_bs_xml=>c_gui_type_wd.
    ls_choice-xml_type = xml_type.
      append ls_choice to lt_choice.

      data:
        lr_c8r_wd type ref to cl_salv_wd_export_c8r.

    create object lr_c8r_wd
      exporting
        t_choice = lt_choice.

      lr_c8r_wd->execute(
        exporting
          r_result_data = lr_result_data_table_wd
                    importing
                      e_xml         = xml
                      e_mimetype    = mimetype
          e_filename    = filename ).

    when others.
      data:
        lr_result_table_tt type ref to cl_salv_bs_tt_result_table.

      case r_result_data->result_data.
        when if_salv_bs_c_result_data=>result_data_table_ex.
          create object lr_result_table_tt type cl_salv_ex_tt_result_table
            exporting
              r_result_data = r_result_data
              xml_flavour   = l_xml_flavour.

        when if_salv_bs_c_result_data=>result_data_table_wd.
          create object lr_result_table_tt type cl_salv_wd_tt_result_table
            exporting
              r_result_data = r_result_data
              xml_flavour   = l_xml_flavour.

        when others.
          create object lr_result_table_tt
            exporting
              r_result_data = r_result_data
              xml_flavour   = l_xml_flavour.
      endcase.

      data:
        lr_file_tt type ref to cl_salv_bs_tt_file.

      case xml_type.
        when if_salv_bs_xml=>c_type_mhtml or if_salv_bs_xml=>c_type_mhtml_2000.

          create object lr_file_tt type cl_salv_bs_tt_mhtml.

          data:
            lc_method type seomtdname value 'SET_OUTPUT_FORMAT'.

          call method lr_file_tt->(lc_method)
            exporting
              value = xml_type.

          " in case we have MHTML2000 format, don't collect image
          " information
          if xml_type eq if_salv_bs_xml=>c_type_mhtml_2000.
            lr_result_table_tt->if_salv_bs_tt~xml_flavour =
              if_salv_bs_c_tt=>c_tt_xml_flavour_export_no_img.
          endif.
          " in case we have MHTML format, escaping_required is abap_true
          lr_result_table_tt->set_escaping_required( abap_true ).

        when if_salv_bs_xml=>c_type_excel_xml.
          create object lr_file_tt type cl_salv_bs_tt_office2003.
          " in case we have office2003 format, escaping_required is abap_true
          lr_result_table_tt->set_escaping_required( abap_true ).

        when if_salv_bs_xml=>c_type_so_xml.
          create object lr_file_tt type cl_salv_bs_tt_so.
          " in case we have XML SAP internal format, escaping_required is abap_false
          lr_result_table_tt->set_escaping_required( abap_false ).

        when if_salv_bs_xml=>c_type_ods_xml.
          create object lr_file_tt type cl_salv_bs_tt_ods.
          " in case we have ODS (OD-spreadsheet), escaping_required is abap_true
          lr_result_table_tt->set_escaping_required( abap_true ).

        when if_salv_bs_xml=>c_type_odt_xml.
          create object lr_file_tt type cl_salv_bs_tt_odt.
          " in case we have ODT (OD-text), escaping_required is abap_true
          lr_result_table_tt->set_escaping_required( abap_true ).

        when if_salv_bs_xml=>c_type_alv_xml.
          create object lr_file_tt type cl_salv_bs_tt_alvxml
            exporting
              xml_flavour = l_xml_flavour.
          " in case we have alv xml format, escaping_required is abap_false
          lr_result_table_tt->set_escaping_required( abap_false ).

        when others.
          return.
      endcase.


      lr_file_tt->transform_tt( lr_result_table_tt ).

      filename = lr_file_tt->if_salv_bs_tt_file~filename.
      xml      = lr_file_tt->if_salv_bs_tt_file~file.
      mimetype = lr_file_tt->if_salv_bs_tt_file~mimetype.
      t_msg    = lr_file_tt->if_salv_bs_tt~t_msg.

  endcase.

endmethod.
ENDCLASS.

*"* use this source file for your ABAP unit test classes
class lcl_salv_bs_office2007_base definition deferred.
class zpsu_cl_salv_bs_office2007_bas definition local friends lcl_salv_bs_office2007_base.

class lcl_salv_bs_office2007_base definition inheriting from zpsu_cl_salv_bs_office2007_bas.
  public section.
  protected section.
    methods get_image_content redefinition.
*    CONSTRUCTOR,
*    TRANSFORM,
*    GET_IMAGE_CONTENT
*GENERATE_XML_AND_OPC
*GET_IMAGE_SIZE
*ADD_DRAWINGPART
*ADD_HYPERLINK
*ADD_IMAGE
*CREATE_CELL
*CREATE_DATA_CELL
*CREATE_HIER_CELL
*CREATE_TOTAL_CELL
*GET_CELL_VALUE
*ADD_SHAREDSTRING
*ADD_STYLE
*CREATE_CELLS
*CREATE_HEADER_ROW
*GET_CELLPOSITION
*TRANSFORM_TO_OFF2007
endclass.

class lcl_salv_bs_office2007_base implementation.
  method get_image_content.
  endmethod.
endclass.

class ltc_office2007 definition
  for testing risk level harmless duration short.
    private section.
      data: cut_office2007 type ref to lcl_salv_bs_office2007_base.
      data: cut_office2007_base type ref to zpsu_cl_salv_bs_office2007_bas.
    methods:
      setup,
      check_cellposition importing row type i col type i cell_address_expected type string,
      get_cellposition for testing.

endclass.

class zpsu_cl_salv_bs_office2007_bas definition local friends ltc_office2007.

class ltc_office2007 implementation.
  method setup.
    data: lr_dummy_model type ref to cl_salv_bs_model_table.
    data: lr_dummy_service type ref to CL_SALV_BS_SERVICE_MNGR.
    data: lr_dummy_result_data type ref to cl_salv_bs_result_data_table.
    create object LR_DUMMY_RESULT_DATA
      exporting
*        ID                =
        R_MODEL           =  lr_dummy_model   " ModelController
        R_SERVICE_MANAGER =  lr_dummy_service
*        R_TOP_OF_LIST     =     " Set and Get Design Object Content
*        R_END_OF_LIST     =     " Set and Get Design Object Content
      .
    create object cut_office2007 exporting r_result_data = lr_dummy_result_data.
    CUT_OFFICE2007_BASE = CUT_OFFICE2007.
  endmethod.
  method check_cellposition.
    data: l_cell_address_actual type string.
    l_cell_address_actual = CUT_OFFICE2007_BASE->GET_CELLPOSITION( ROW = row  COL = col ).
    cl_abap_unit_assert=>assert_equals( act = l_cell_address_actual
                                        exp = cell_address_expected ).
  endmethod.
  method get_cellposition.
    CHECK_CELLPOSITION( row = 1   col = 1   cell_address_expected = 'A1' ).    "              1
    CHECK_CELLPOSITION( row = 100 col = 26  cell_address_expected = 'Z100' ).  "              26
    CHECK_CELLPOSITION( row = 123 col = 27  cell_address_expected = 'AA123' ). "         1*26+1
    CHECK_CELLPOSITION( row = 123 col = 676 cell_address_expected = 'YZ123' ). "        25*26+26
    CHECK_CELLPOSITION( row = 123 col = 702 cell_address_expected = 'ZZ123' ). "        26*26+26
    CHECK_CELLPOSITION( row = 123 col = 703 cell_address_expected = 'AAA123' )." 1*26*26+1*26+1
    CHECK_CELLPOSITION( row = 123 col = 1379 cell_address_expected = 'BAA123' )." 2*26*26+1*26+1
    CHECK_CELLPOSITION( row = 123 col = 1432 cell_address_expected = 'BCB123' )." 2*26*26+3*26+2
  endmethod.
endclass.

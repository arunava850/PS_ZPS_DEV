"Name: \TY:CL_XLSX_WORKBOOKPART\ME:GET_INITIAL_CONTENT\SE:END\EI
ENHANCEMENT 0 ZPSU_EXCEL_SHEETNAME_CHANGE.
DATA: lv_int111 TYPE char01.
*** Import parameter is from program - ZFIAP_CONCUR_PAYMENT_CONF to change the sheet name
IMPORT lv_int111 TO lv_int111 FROM MEMORY ID 'LV_INT111'.
FREE MEMORY ID 'LV_INT111'.
IF lv_int111 EQ 'X'.
  CLEAR: str, rv_content.
  CONCATENATE
  '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
  '  <bookViews>'
  '    <workbookView xWindow="0" yWindow="0" windowWidth="21855" windowHeight="14940"/>'
  '  </bookViews>'
  '  <sheets>'
  '    <sheet name="Submit On Cycle Payroll with Co" sheetId="1" r:id="rId1"/>'
  '  </sheets>'
  '</workbook>'

  INTO str RESPECTING BLANKS.

  rv_content = cl_openxml_helper=>string_to_xstring( str ).
ENDIF.
ENDENHANCEMENT.

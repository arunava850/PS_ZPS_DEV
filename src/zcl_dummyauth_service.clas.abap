class ZCL_DUMMYAUTH_SERVICE definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_DUMMYAUTH_SERVICE IMPLEMENTATION.


  method IF_HTTP_EXTENSION~HANDLE_REQUEST.
    DATA:
          html_content TYPE string.

    html_content = '<html><script type="text/javascript">window.close();</script></html>'.
    server->response->set_header_field( name = 'Cache-Control' value = 'no-cache,no-store').
    server->response->set_cdata( data = html_content ).
  endmethod.
ENDCLASS.

FUNCTION-POOL zca_pc.                       "MESSAGE-ID ..

* INCLUDE LZCA_PCD...                        " Local class definition
TYPES : BEGIN OF typ_input,
          prctr   TYPE char10,
          numbr   TYPE char10,
          nlz_val TYPE char10,
        END OF  typ_input .

DATA :  lt_output TYPE STANDARD TABLE OF typ_input .

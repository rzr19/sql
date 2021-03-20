FORM update-supervisor-0470 USING ipernr.

  data: i_return TYPE sy-subrc,
        f_return type bapireturn1,
        itab0470 TYPE TABLE OF p0470,
        ln0470 LIKE LINE OF p0470,
        new0470 LIKE p0470 OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr = ipernr
      infty ='0470'
    IMPORTING
      subrc = i_return
    TABLES
      infty_tab = itab0470
    EXCEPTIONS
      INFTY_NOT_FOUND = 1
      OTHERS = 2.

    new0470-profil = 'CONCUR'.
    APPEND new0470.
    sort itab0470 by endda descending.
    read table itab0470 into ln0470 index 1.
    if ln0470-endda < extrdate OR i_return ne 0.
    CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
      EXPORTING
        number = ipernr
      IMPORTING
        return = f_return.
    if f_return is initial.
      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty = '0470'
          number = ipernr
          record = new0470
          operation ='INS'
          validityend = '99991231'
          validitybegin = extrdate
        IMPORTING
          return = f_return
        EXCEPTIONS
          others = 1.
        CALL FUNCTION 'HR_EMPLOYEE_DEQUEUE'
          EXPORTING
            number = ipernr
          IMPORTING
            return = f_return.
        clear new0470.
        clear ln0470.
        clear itab0470.
   endif.
 endif.

ENDFORM.

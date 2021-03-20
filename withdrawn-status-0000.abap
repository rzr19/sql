  if ( p0000-massn EQ 'WZ' AND p0000-massg EQ 'RT' ) OR
      "Withdrawn Discharged
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'AB' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'CP' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'CT' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'HR' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'IN' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'PA' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'QS' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'SA' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'TP' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'UP' ) OR
    ( p0000-massn EQ 'WX' AND p0000-massg EQ 'VP' ) OR
   "Withdrawn Other
    ( p0000-massn EQ 'WO' AND p0000-massg EQ 'LO' ) OR
    ( p0000-massn EQ 'WO' AND p0000-massg EQ 'MA' ) OR
    ( p0000-massn EQ 'WO' AND p0000-massg EQ 'OS' ) OR
    ( p0000-massn EQ 'WO' AND p0000-massg EQ 'SA' ) OR
    ( p0000-massn EQ 'WO' AND p0000-massg EQ 'WS' ) OR
   "Withdrawn Voluntary
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'CE' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'ED' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'HM' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'MV' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'NR' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'OB' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'OE' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'OP' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'OV' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'QT' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'RR' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'ST' ) OR
    ( p0000-massn EQ 'WV' AND p0000-massg EQ 'SV' ).
    if prf-age >= 65. "65 years rule
        prf-term_but_elig = 'Y'.
    else.
      reject.
    endif.
    " All eligible combinations
  elseif ( p0000-massn eq 'WZ' and p0000-massg eq 'EM' ) or
    ( p0000-massn eq 'WD' and p0000-massg eq 'DB' ) or
    ( p0000-massn eq 'WO' and p0000-massg eq 'HR' ) or
    ( p0000-massn eq 'WO' and p0000-massg eq 'JE' ) or
    ( p0000-massn eq 'WR' and p0000-massg eq 'CP' ) or
    ( p0000-massn eq 'WR' and p0000-massg eq 'DB' ) or
    ( p0000-massn eq 'WR' and p0000-massg eq 'OQ' ) or
    ( p0000-massn eq 'WR' and p0000-massg eq 'SB' ) or
    ( p0000-massn eq 'WR' and p0000-massg eq 'SR' ).
    if withdrawn_date_test+0(4) =< pyendda+0(4).
      prf-term_but_elig = 'Y'.
    else.
      reject. "reject if termed last year and outside of scoping interval.
    endif.
  endif.
  clear withdrawn_date_test.
"STC007

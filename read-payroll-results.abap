FORM READ_PAYROLL_174  USING    P_PERNR prf-ps_dol prf-term_but_elig prf-is_was_intern_coop prf-st_date prf-entry_date prf-one_more_seqnr
                           CHANGING P_V_TESTCOMP_174_TOT.   


  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      persnr   = P_PERNR
    TABLES
      in_rgdir = it_rgdir.

  clear P_V_TESTCOMP_174_TOT.                                   

  if prf-st_date is not initial.

    CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      DATE_EXTERNAL                  = prf-st_date
*   ACCEPT_INITIAL_DATE            =
   IMPORTING
     DATE_INTERNAL                  = withdrawn_date
* EXCEPTIONS
*   DATE_EXTERNAL_IS_INVALID       = 1
*   OTHERS                         = 2
            .

      CALL FUNCTION 'MONTH_PLUS_DETERMINE'
        EXPORTING
          MONTHS  = 2
          OLDDATE = withdrawn_date
        IMPORTING
          NEWDATE = withdrawn_plus.  "withdrawn date + 2 months

      CALL FUNCTION 'MONTH_PLUS_DETERMINE'
        EXPORTING
          MONTHS  = 1
          OLDDATE = withdrawn_plus
        IMPORTING
          NEWDATE = withdrawn_plus_next.  "withdrawn date + 1 month

** finding the no of days in the next month
      CALL FUNCTION 'RE_LAST_DAY_OF_MONTH'
        EXPORTING
          I_DATUM  = withdrawn_plus_next
        IMPORTING
*         E_KZ_ULT =
          E_TT     = no_days_month.
** splitting that by 2
      no_days_month_half = no_days_month / 2.

      write no_days_month_half to no_days_month_half1.

** adding the resulting no of days to withdrawn_plus
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          DATE      = withdrawn_plus
          DAYS      = no_days_month_half1
          MONTHS    = 0
          SIGNUM    = '+'
          YEARS     = 0
        IMPORTING
          CALC_DATE = withdrawn_plus.

      pyendda1 = withdrawn_plus.

      IF pyendda1 < pybegda.
**********        not_eligible = 'X'.
        clear V_TESTCOMP_195_TOT. clear V_TESTCOMP_174_TOT.           
      ENDIF.

    ENDIF.

    IF withdrawn_date > pybegda and withdrawn_date < pyendda.
      pyendda1 = pyendda.
    ENDIF.

******  endif.

  if prf-st_date is initial.
    pyendda1 = pyendda.
  ENDIF.

  if prf-is_was_intern_coop eq 'A' or prf-is_was_intern_coop eq 'B'. "intern check for eligiblity meet late in year.
    if prf-entry_date+0(4) = pybegda+0(4).
"      if prf-entry_date+4(4) = '0901' or prf-entry_date+4(4) = '0301'.
        pybegda1 = prf-entry_date.
 "     endif.
    else.
      pybegda1 = pybegda.
    endif.
  endif.

    if prf-is_was_intern_coop eq 'A' or prf-is_was_intern_coop eq 'B'. "switch payroll read to interns/coops logic.

    LOOP at it_rgdir where srtza eq 'A'
      and void is initial and reversal is initial
      and paydt ge pybegda1
      and paydt le pyendda.

      v_seqnr = it_rgdir-seqnr.

      CALL FUNCTION 'PYXX_GET_RELID_FROM_PERNR'
        EXPORTING
          EMPLOYEE                    = P_PERNR
        IMPORTING
          RELID                       = rel_id
*         MOLGA                       = v_molga
        EXCEPTIONS
          ERROR_READING_INFOTYPE_0001 = 1
          ERROR_READING_MOLGA         = 2
          ERROR_READING_RELID         = 3
          OTHERS                      = 4.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      write P_PERNR to ee_number.

      CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
        EXPORTING
          CLUSTERID                    = rel_id
          EMPLOYEENUMBER               = ee_number
          SEQUENCENUMBER               = V_SEQNR
          READ_ONLY_INTERNATIONAL      = 'X'
        CHANGING
          PAYROLL_RESULT               = RESULT
        EXCEPTIONS
          ILLEGAL_ISOCODE_OR_CLUSTERID = 1
          ERROR_GENERATING_IMPORT      = 2
          IMPORT_MISMATCH_ERROR        = 3
          SUBPOOL_DIR_FULL             = 4
          NO_READ_AUTHORITY            = 5
          NO_RECORD_FOUND              = 6
          VERSIONS_DO_NOT_MATCH        = 7
          OTHERS                       = 8.

      LOOP AT RESULT-INTER-RT INTO rt_line.
        if prf-is_was_intern_coop eq 'A'. "get interns PS from wt 9220 in /174 total to not break logic.
          if rt_line-lgart = '9220'.
            v_testcomp_174 = rt_line-BETRG.
            v_testcomp_174_tot = v_testcomp_174_tot + v_testcomp_174.
            clear rt_line-BETRG.
          endif.
        elseif prf-is_was_intern_coop eq 'B'.
          if rt_line-lgart = '9220' or rt_line-lgart in ps_dol.
            v_testcomp_174 = rt_line-betrg.
            v_testcomp_174_tot = v_testcomp_174_tot + v_testcomp_174.
            clear rt_line-betrg.
          endif.
        endif.
        ENDLOOP.
      ENDLOOP.

    elseif prf-term_but_elig = 'Y'.

    data: term_table_index type p value 0.

    LOOP AT it_rgdir WHERE srtza EQ 'A'
                     AND void IS INITIAL
                     AND reversal IS INITIAL
                     AND ( ( fpbeg GE pybegda and fpend LE pyendda1 ) OR
                           ( fpbeg LE pybegda and fpend GE pybegda and fpend LE pyendda1 ) ).

      term_table_index = term_table_index + 1.
      v_seqnr = it_rgdir-seqnr.

      if term_table_index = 1.
        prf-one_more_seqnr = v_seqnr - 1.
      endif.

      CALL FUNCTION 'PYXX_GET_RELID_FROM_PERNR'
        EXPORTING
          EMPLOYEE                    = P_PERNR
        IMPORTING
          RELID                       = rel_id
*         MOLGA                       = v_molga
        EXCEPTIONS
          ERROR_READING_INFOTYPE_0001 = 1
          ERROR_READING_MOLGA         = 2
          ERROR_READING_RELID         = 3
          OTHERS                      = 4.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      write P_PERNR to ee_number.

      CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
        EXPORTING
          CLUSTERID                    = rel_id
          EMPLOYEENUMBER               = ee_number
          SEQUENCENUMBER               = V_SEQNR
          READ_ONLY_INTERNATIONAL      = 'X'
        CHANGING
          PAYROLL_RESULT               = RESULT
        EXCEPTIONS
          ILLEGAL_ISOCODE_OR_CLUSTERID = 1
          ERROR_GENERATING_IMPORT      = 2
          IMPORT_MISMATCH_ERROR        = 3
          SUBPOOL_DIR_FULL             = 4
          NO_READ_AUTHORITY            = 5
          NO_RECORD_FOUND              = 6
          VERSIONS_DO_NOT_MATCH        = 7
          OTHERS                       = 8.

      LOOP AT RESULT-INTER-RT INTO rt_line.
        if pyendda1 = pyendda.                        
            v_testcomp_174_tot = PRF-PS_DOL.
            exit.
        elseif pyendda1 = withdrawn_plus.
          if rt_line-lgart = '/174'.
            v_testcomp_174 = rt_line-BETRG.
            v_testcomp_174_tot = v_testcomp_174_tot + v_testcomp_174.
            clear rt_line-BETRG.
          endif.
        ENDIF.
      ENDLOOP.


    ENDLOOP.
    clear term_table_index.
    endif.

    if prf-term_but_elig = 'Y' and pyendda1 = withdrawn_plus.
      perform read_term_but_elig_102 using rel_id ee_number prf-one_more_seqnr changing v_testcomp_174_tot.
    endif.
    
    if v_testcomp_174_tot > max and prf-term_but_elig <> 'Y'.
      v_testcomp_174_tot = max.
    endif.

ENDFORM.

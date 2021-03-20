FORM get_job_locr.

  SELECT hrp1000~objid hrp1000~short hrp1028~strs2 hrp1028~adrnr hrp1028~cname hrp1028~cname hrp1028~ort01 hrp1028~regio hrp1028~pstlz t005t~landx FROM hrp1000
  JOIN hrp1028 ON hrp1000~objid = hrp1028~objid
  JOIN t005t ON hrp1028~land1 = t005t~land1
  INTO CORRESPONDING FIELDS OF TABLE it_job_locr
    WHERE hrp1000~plvar = '01'
    AND hrp1000~otype = '15'
    AND hrp1000~endda = '99991231'
    AND t005t~spras = 'EN'.

  SORT it_job_locr ASCENDING BY objid.
  DELETE ADJACENT DUPLICATES FROM it_job_locr COMPARING objid.

  loop at it_job_locr into wa_job_locr.
    if wa_job_locr-regio is initial.
      wa_job_locr-regio = 'N/A'.                                            " Default 'N/A' to allow locations without states
    endif.
    modify it_job_locr from wa_job_locr.
  endloop.

  LOOP AT it_job_locr INTO wa_job_locr.
    SELECT SINGLE * FROM zhr_av_joblocr INTO wa_zhr_av_job_locr
      WHERE objid = wa_job_locr-objid.

    IF sy-subrc <> 0
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-short <> wa_job_locr-short )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-strs2 <> wa_job_locr-strs2 )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-adrnr <> wa_job_locr-adrnr )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-cname <> wa_job_locr-cname )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-ort01 <> wa_job_locr-ort01 )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-regio <> wa_job_locr-regio )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-pstlz <> wa_job_locr-pstlz )
      OR ( sy-subrc = 0 AND wa_zhr_av_job_locr-landx <> wa_job_locr-landx ).
      wa_job_locr-status = 'A'.
      MOVE-CORRESPONDING wa_job_locr TO it_job_locr_final.
      APPEND it_job_locr_final.
    ENDIF.
  ENDLOOP.

  SELECT * FROM zhr_av_joblocr INTO TABLE it_zhr_av_job_locr.
  MODIFY zhr_av_joblocr FROM TABLE it_job_locr.
  FIELD-SYMBOLS: <wa_obs_job_locr> TYPE zhr_av_joblocr.

  LOOP AT it_zhr_av_job_locr ASSIGNING <wa_obs_job_locr>.
    READ TABLE it_job_locr WITH KEY objid = <wa_obs_job_locr>-objid TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      <wa_obs_job_locr>-status = 'I'.
      DELETE zhr_av_joblocr FROM <wa_obs_job_locr>.
      APPEND <wa_obs_job_locr> TO it_job_locr_final.
    ENDIF.
  ENDLOOP.

ENDFORM.

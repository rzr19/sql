  " vgheorgh try to generate 305_file in fname
  IF 305_file EQ 'X'.
    which_file = '305'.
    LOOP AT ipa0470 WHERE pernr = pernr-pernr.
      CLEAR: travel_profile, z_bukrs.
      PERFORM c000-write-travel305-file.
      TRANSFER pack_travel_file TO fname.
      CLEAR pack_travel_file.
      emp_count = emp_count + 1.
    ENDLOOP.
  ENDIF.
  " vgheorgh to generate 350_file in fname2
  IF 350_file EQ 'X'.
    which_file2 = '350'.
    LOOP AT ipa0470 WHERE pernr = pernr-pernr.
      CLEAR: travel_profile_350, z_bukrs.
      PERFORM c000-write-travel350-file.
      TRANSFER pack_travel320_file TO fname2.
      CLEAR pack_travel320_file.
      emp_count2 = emp_count2 + 1.
    ENDLOOP.
  ENDIF.
   " vgheorgh try to generate Concur/CWT files in fname
   IF 300_file EQ 'X' OR carlson EQ 'X'.
    LOOP AT ipa0470 WHERE pernr = pernr-pernr.
      CLEAR: travel_profile, z_bukrs.
      PERFORM c000-write-travel-file.
      TRANSFER pack_travel_file TO fname.
      CLEAR pack_travel_file.
      emp_count = emp_count + 1.
    ENDLOOP.
  ENDIF.
  " vgheorgh try to generate 320 profile in fname2
  IF 320_updt EQ 'X'.
    which_file2 = '350'.
    LOOP AT ipa0470 WHERE pernr = pernr-pernr.
      CLEAR: travel_profile_320.
      PERFORM c000-write-travel320-file.
      TRANSFER pack_travel320_file TO fname2.
      CLEAR pack_travel320_file.
      emp_count2 = emp_count2 + 1.
    ENDLOOP.
  ENDIF.

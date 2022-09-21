SELECT    a.student_id,
          a1.academic_year_code AS cohort,
          'All' AS population,

          -- METRICS
          COALESCE(a.is_returned_next_spring, FALSE) AS spring_returned,
          COALESCE(a.is_returned_next_fall, FALSE) AS second_fall_returned,
          COALESCE(a.is_returned_fall_3, FALSE) AS third_fall_returned,
          COALESCE(a.is_returned_fall_4, FALSE) AS fourth_fall_returned,
          COALESCE(a.is_returned_fall_5, FALSE) AS fifth_fall_returned,
          COALESCE(a.is_returned_fall_6, FALSE) AS sixth_fall_returned,

          -- GROUPS
          d.college_abbrv AS college,
          d.department_desc AS department,
          d.program_desc AS program,
          b.gender_code AS gender,
          b.ipeds_race_ethnicity,
          -- TODO: formulate gpu_bands with case statement
          '' AS gpa_band,

          -- TODO: this is named strangely in accordance to what it is used for in the app
          'third week' AS metric

     FROM export.student_term_cohort a
LEFT JOIN export.term a1
       ON a1.term_id = a.cohort_start_term_id
LEFT JOIN export.student b
       ON b.sis_system_id = a.sis_system_id
LEFT JOIN export.student_term_level_version c
       ON c.sis_system_id = a.sis_system_id
      AND c.term_id  = a.cohort_start_term_id
      AND c.is_primary_level
      AND c.version_desc = 'Census'
LEFT JOIN export.academic_programs d
       ON d.program_id = c.primary_program_id
    WHERE a.cohort_start_term_id::INTEGER >= 201640
      AND a.cohort_desc != 'Student Success';
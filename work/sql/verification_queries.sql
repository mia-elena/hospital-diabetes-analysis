-- Assignment 1 Part 7. MySQL.
-- Each count query should match the numbers printed by Step 6.5.
-- Each duplicate-key query and each orphan query should return no rows, or a count of 0.
USE hospital;

SELECT COUNT(*) AS patient_rows FROM patient;
SELECT COUNT(*) AS encounter_rows FROM encounter;
SELECT COUNT(*) AS encounter_diagnosis_rows FROM encounter_diagnosis;
SELECT COUNT(*) AS diagnosis_rows FROM diagnosis;
SELECT COUNT(*) AS admission_type_rows FROM admission_type;
SELECT COUNT(*) AS discharge_disposition_rows FROM discharge_disposition;
SELECT COUNT(*) AS admission_source_rows FROM admission_source;

SELECT encounter_id, COUNT(*) c FROM encounter GROUP BY encounter_id HAVING c > 1;
SELECT patient_nbr, COUNT(*) c FROM patient GROUP BY patient_nbr HAVING c > 1;
SELECT icd9_code, COUNT(*) c FROM diagnosis GROUP BY icd9_code HAVING c > 1;
SELECT encounter_id, diag_position, COUNT(*) c FROM encounter_diagnosis GROUP BY encounter_id, diag_position HAVING c > 1;

SELECT COUNT(*) FROM encounter e LEFT JOIN patient p ON e.patient_nbr = p.patient_nbr WHERE p.patient_nbr IS NULL;
SELECT COUNT(*) FROM encounter e LEFT JOIN admission_type t ON e.admission_type_id = t.admission_type_id WHERE t.admission_type_id IS NULL;
SELECT COUNT(*) FROM encounter e LEFT JOIN discharge_disposition d ON e.discharge_disposition_id = d.discharge_disposition_id WHERE d.discharge_disposition_id IS NULL;
SELECT COUNT(*) FROM encounter e LEFT JOIN admission_source s ON e.admission_source_id = s.admission_source_id WHERE s.admission_source_id IS NULL;
SELECT COUNT(*) FROM encounter_diagnosis ed LEFT JOIN encounter e ON ed.encounter_id = e.encounter_id WHERE e.encounter_id IS NULL;
SELECT COUNT(*) FROM encounter_diagnosis ed LEFT JOIN diagnosis g ON ed.icd9_code = g.icd9_code WHERE g.icd9_code IS NULL;

SELECT e.encounter_id, e.race, e.gender, e.age, e.time_in_hospital,
       ed.diag_position, ed.icd9_code, e.readmitted
FROM encounter e
LEFT JOIN encounter_diagnosis ed ON ed.encounter_id = e.encounter_id
WHERE e.encounter_id = 2278392
ORDER BY ed.diag_position;

SELECT COUNT(*) AS readmitted_within_30_days FROM encounter WHERE readmitted = '<30>';

SELECT e.gender,
            ROUND(AVG(e.time_in_hospital), 2) AS avg_days,
            COUNT(*) AS stays
     FROM encounter AS e
     GROUP BY e.gender
     ORDER BY e.gender;

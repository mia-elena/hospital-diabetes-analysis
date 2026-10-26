
-- CSCI 49376 Assignment 1 — Part 7
USE hospital;


-- check row counts for each table
SELECT COUNT(*) AS patient_count FROM patient;

SELECT COUNT(*) AS encounter_count FROM encounter;

SELECT COUNT(*) AS encounter_diagnosis_count FROM encounter_diagnosis;

SELECT COUNT(*) AS diagnosis_count FROM diagnosis;

SELECT COUNT(*) AS admission_type_count FROM admission_type;

SELECT COUNT(*) AS discharge_disposition_count FROM discharge_disposition;

SELECT COUNT(*) AS admission_source_count FROM admission_source;


-- check for duplicate primary keys (should return no rows)
SELECT patient_nbr
FROM patient
GROUP BY patient_nbr
HAVING COUNT(*) > 1;

SELECT encounter_id
FROM encounter
GROUP BY encounter_id
HAVING COUNT(*) > 1;

SELECT encounter_id, diag_position
FROM encounter_diagnosis
GROUP BY encounter_id, diag_position
HAVING COUNT(*) > 1;

SELECT icd9_code
FROM diagnosis
GROUP BY icd9_code
HAVING COUNT(*) > 1;

-- check foreign keys (should be 0)
SELECT COUNT(*) AS missing_patients
FROM encounter
WHERE patient_nbr NOT IN (SELECT patient_nbr FROM patient);

SELECT COUNT(*) AS missing_admission_types
FROM encounter
WHERE admission_type_id NOT IN (SELECT admission_type_id FROM admission_type);

SELECT COUNT(*) AS missing_discharge_dispositions
FROM encounter
WHERE discharge_disposition_id NOT IN (SELECT discharge_disposition_id FROM discharge_disposition);

SELECT COUNT(*) AS missing_admission_sources
FROM encounter
WHERE admission_source_id NOT IN (SELECT admission_source_id FROM admission_source);

SELECT COUNT(*) AS missing_encounters
FROM encounter_diagnosis
WHERE encounter_id NOT IN (SELECT encounter_id FROM encounter);

SELECT COUNT(*) AS missing_diagnosis_codes
FROM encounter_diagnosis
WHERE icd9_code NOT IN (SELECT icd9_code FROM diagnosis);

-- count diagnoses in the original data
SELECT COUNT(*) AS diag_1_count
FROM staging_diabetes
WHERE diag_1 IS NOT NULL AND diag_1 != '' AND diag_1 != '?';

SELECT COUNT(*) AS diag_2_count
FROM staging_diabetes
WHERE diag_2 IS NOT NULL AND diag_2 != '' AND diag_2 != '?';

SELECT COUNT(*) AS diag_3_count
FROM staging_diabetes
WHERE diag_3 IS NOT NULL AND diag_3 != '' AND diag_3 != '?';

SELECT COUNT(*) AS normalized_diagnosis_count
FROM encounter_diagnosis;

-- view a sample encounter and its diagnoses
SELECT *
FROM encounter
WHERE encounter_id = 2278392;

SELECT *
FROM encounter_diagnosis
WHERE encounter_id = 2278392
ORDER BY diag_position;


-- check for missing encounter and patient IDs
SELECT COUNT(*) AS missing_encounter_ids
FROM staging_diabetes
WHERE encounter_id IS NULL OR encounter_id = '' OR encounter_id = '?';

SELECT COUNT(*) AS missing_patient_ids
FROM staging_diabetes
WHERE patient_nbr IS NULL OR patient_nbr = '' OR patient_nbr = '?';

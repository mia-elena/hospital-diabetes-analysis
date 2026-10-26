-- CSCI 49376 Assignment 1 — Part 6
-- This staging table contains only the 26 columns retained by the assignment.
-- Prerequisite: MySQL must permit LOAD DATA LOCAL INFILE
-- on both the server and client.
-- Update the CSV path below to match the local machine.

USE hospital;

DROP TABLE IF EXISTS staging_diabetes;
CREATE TABLE staging_diabetes (
    encounter_id VARCHAR(30),
    patient_nbr VARCHAR(30),
    race VARCHAR(30),
    gender VARCHAR(30),
    age VARCHAR(20),
    weight VARCHAR(20),
    admission_type_id VARCHAR(30),
    discharge_disposition_id VARCHAR(30),
    admission_source_id VARCHAR(30),
    time_in_hospital VARCHAR(30),
    payer_code VARCHAR(30),
    medical_specialty VARCHAR(100),
    num_lab_procedures VARCHAR(30),
    num_procedures VARCHAR(30),
    num_medications VARCHAR(30),
    number_outpatient VARCHAR(30),
    number_emergency VARCHAR(30),
    number_inpatient VARCHAR(30),
    diag_1 VARCHAR(30),
    diag_2 VARCHAR(30),
    diag_3 VARCHAR(30),
    number_diagnoses VARCHAR(30),
    max_glu_serum VARCHAR(30),
    A1Cresult VARCHAR(30),
    diabetesMed VARCHAR(30),
    readmitted VARCHAR(30)
);

-- SET GLOBAL local_infile = 1;
SELECT COUNT(*) AS staging_rows FROM hospital.staging_diabetes;
LOAD DATA LOCAL INFILE '/Users/jasveen/Downloads/diabetic_data.csv'
INTO TABLE staging_diabetes
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    encounter_id,
    patient_nbr,
    race,
    gender,
    age,
    weight,
    admission_type_id,
    discharge_disposition_id,
    admission_source_id,
    time_in_hospital,
    payer_code,
    medical_specialty,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_outpatient,
    number_emergency,
    number_inpatient,
    diag_1,
    diag_2,
    diag_3,
    number_diagnoses,
    max_glu_serum,
    A1Cresult,
    @metformin,
    @repaglinide,
    @nateglinide,
    @chlorpropamide,
    @glimepiride,
    @acetohexamide,
    @glipizide,
    @glyburide,
    @tolbutamide,
    @pioglitazone,
    @rosiglitazone,
    @acarbose,
    @miglitol,
    @troglitazone,
    @tolazamide,
    @examide,
    @citoglipton,
    @insulin,
    @glyburide_metformin,
    @glipizide_metformin,
    @glimepiride_pioglitazone,
    @metformin_rosiglitazone,
    @metformin_pioglitazone,
    @change,
    diabetesMed,
    readmitted
);

-- should return 101766 for the official CSV
SELECT COUNT(*) AS staging_row_count FROM staging_diabetes;

INSERT INTO admission_type (admission_type_id, description)
SELECT DISTINCT
       CAST(admission_type_id AS UNSIGNED),
       CONCAT('Admission type code ', admission_type_id)
FROM staging_diabetes
WHERE NULLIF(admission_type_id, '?') IS NOT NULL
  AND admission_type_id <> '';

INSERT INTO discharge_disposition (discharge_disposition_id, description)
SELECT DISTINCT CAST(discharge_disposition_id AS UNSIGNED),
       CONCAT('Discharge disposition code ', discharge_disposition_id)
FROM staging_diabetes
WHERE NULLIF(discharge_disposition_id, '?') IS NOT NULL
  AND discharge_disposition_id <> '';

INSERT INTO admission_source (admission_source_id, description)
SELECT DISTINCT CAST(admission_source_id AS UNSIGNED),
       CONCAT('Admission source code ', admission_source_id)
FROM staging_diabetes
WHERE NULLIF(admission_source_id, '?') IS NOT NULL
  AND admission_source_id <> '';

INSERT INTO patient (patient_nbr, race, gender) -- most recently recorded 
SELECT patient_nbr, NULLIF(race, '?'), NULLIF(gender, '?') 
FROM (
    SELECT
        CAST(patient_nbr AS UNSIGNED) AS patient_nbr,
        race,
        gender,
        ROW_NUMBER() OVER (
            PARTITION BY patient_nbr
            ORDER BY CAST(encounter_id AS UNSIGNED) DESC
        ) AS rn
    FROM staging_diabetes
    WHERE patient_nbr IS NOT NULL AND patient_nbr <> '' AND patient_nbr <> '?'
) AS ranked_patients
WHERE rn = 1;

INSERT INTO diagnosis (icd9_code)
SELECT diag_code
FROM (
    SELECT NULLIF(diag_1, '?') AS diag_code FROM staging_diabetes
    UNION
    SELECT NULLIF(diag_2, '?') AS diag_code FROM staging_diabetes
    UNION
    SELECT NULLIF(diag_3, '?') AS diag_code FROM staging_diabetes
) AS all_codes
WHERE diag_code IS NOT NULL AND diag_code <> '';

INSERT INTO encounter (
    encounter_id, patient_nbr, admission_type_id, discharge_disposition_id,
    admission_source_id, age, weight, payer_code, medical_specialty,
    time_in_hospital, num_lab_procedures, num_procedures, num_medications,
    number_outpatient, number_emergency, number_inpatient, number_diagnoses,
    max_glu_serum, A1Cresult, diabetesMed, readmitted
)
SELECT
    CAST(s.encounter_id AS UNSIGNED),
    CAST(s.patient_nbr AS UNSIGNED),
    CAST(s.admission_type_id AS UNSIGNED),
    CAST(s.discharge_disposition_id AS UNSIGNED),
    CAST(s.admission_source_id AS UNSIGNED),
    s.age,
    NULLIF(s.weight, '?'),
    NULLIF(s.payer_code, '?'),
    NULLIF(s.medical_specialty, '?'),
    CAST(s.time_in_hospital AS UNSIGNED),
    CAST(s.num_lab_procedures AS UNSIGNED),
    CAST(s.num_procedures AS UNSIGNED),
    CAST(s.num_medications AS UNSIGNED),
    CAST(s.number_outpatient AS UNSIGNED),
    CAST(s.number_emergency AS UNSIGNED),
    CAST(s.number_inpatient AS UNSIGNED),
    CAST(s.number_diagnoses AS UNSIGNED),
    NULLIF(NULLIF(s.max_glu_serum, '?'), 'None'),
    NULLIF(NULLIF(s.A1Cresult, '?'), 'None'),
    s.diabetesMed,
    s.readmitted
FROM staging_diabetes AS s;

INSERT INTO encounter_diagnosis (encounter_id, diag_position, icd9_code)
SELECT CAST(encounter_id AS UNSIGNED), 1, diag_1
FROM staging_diabetes
WHERE diag_1 IS NOT NULL AND diag_1 <> '' AND diag_1 <> '?'
UNION ALL
SELECT CAST(encounter_id AS UNSIGNED), 2, diag_2
FROM staging_diabetes
WHERE diag_2 IS NOT NULL AND diag_2 <> '' AND diag_2 <> '?'
UNION ALL
SELECT CAST(encounter_id AS UNSIGNED), 3, diag_3
FROM staging_diabetes
WHERE diag_3 IS NOT NULL AND diag_3 <> '' AND diag_3 <> '?';

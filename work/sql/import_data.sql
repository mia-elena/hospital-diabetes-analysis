-- Assignment 1 Part 6. MySQL.
-- CSV -> staging -> normalized tables.
-- If LOAD DATA is refused: SET GLOBAL local_infile = 1; and connect with --local-infile=1.

USE hospital;

DROP TABLE IF EXISTS staging;
CREATE TABLE staging (
    `encounter_id` INT,
    `patient_nbr` INT,
    `race` VARCHAR(20),
    `gender` VARCHAR(20),
    `age` VARCHAR(10),
    `weight` VARCHAR(10),
    `admission_type_id` INT,
    `discharge_disposition_id` INT,
    `admission_source_id` INT,
    `time_in_hospital` INT,
    `payer_code` VARCHAR(10),
    `medical_specialty` VARCHAR(40),
    `num_lab_procedures` INT,
    `num_procedures` INT,
    `num_medications` INT,
    `number_outpatient` INT,
    `number_emergency` INT,
    `number_inpatient` INT,
    `diag_1` VARCHAR(10),
    `diag_2` VARCHAR(10),
    `diag_3` VARCHAR(10),
    `number_diagnoses` INT,
    `max_glu_serum` VARCHAR(10),
    `A1Cresult` VARCHAR(10),
    `metformin` VARCHAR(10),
    `repaglinide` VARCHAR(10),
    `nateglinide` VARCHAR(10),
    `chlorpropamide` VARCHAR(10),
    `glimepiride` VARCHAR(10),
    `acetohexamide` VARCHAR(10),
    `glipizide` VARCHAR(10),
    `glyburide` VARCHAR(10),
    `tolbutamide` VARCHAR(10),
    `pioglitazone` VARCHAR(10),
    `rosiglitazone` VARCHAR(10),
    `acarbose` VARCHAR(10),
    `miglitol` VARCHAR(10),
    `troglitazone` VARCHAR(10),
    `tolazamide` VARCHAR(10),
    `examide` VARCHAR(10),
    `citoglipton` VARCHAR(10),
    `insulin` VARCHAR(10),
    `glyburide-metformin` VARCHAR(10),
    `glipizide-metformin` VARCHAR(10),
    `glimepiride-pioglitazone` VARCHAR(10),
    `metformin-rosiglitazone` VARCHAR(10),
    `metformin-pioglitazone` VARCHAR(10),
    `change` VARCHAR(10),
    `diabetesMed` VARCHAR(10),
    `readmitted` VARCHAR(10)
);

LOAD DATA LOCAL INFILE '/Users/miaelena/Desktop/mia/HunterCS/49376/assignments/assignment1/hospital-readmissions/data/diabetic_data.csv'
INTO TABLE staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Parents first. Descriptions are the published IDS_mapping labels for codes that appear in the CSV.
-- PATIENT is the patient id only. Race and gender stay on the encounter.
-- '?' and the gender value Unknown/Invalid become NULL. 'None' on the two lab columns becomes NULL.

INSERT INTO admission_type (admission_type_id, description) VALUES
    (1, 'Emergency'),
    (2, 'Urgent'),
    (3, 'Elective'),
    (4, 'Newborn'),
    (5, 'Not Available'),
    (6, NULL),
    (7, 'Trauma Center'),
    (8, 'Not Mapped');
INSERT INTO discharge_disposition (discharge_disposition_id, description) VALUES
    (1, 'Discharged to home'),
    (2, 'Discharged/transferred to another short term hospital'),
    (3, 'Discharged/transferred to SNF'),
    (4, 'Discharged/transferred to ICF'),
    (5, 'Discharged/transferred to another type of inpatient care institution'),
    (6, 'Discharged/transferred to home with home health service'),
    (7, 'Left AMA'),
    (8, 'Discharged/transferred to home under care of Home IV provider'),
    (9, 'Admitted as an inpatient to this hospital'),
    (10, 'Neonate discharged to another hospital for neonatal aftercare'),
    (11, 'Expired'),
    (12, 'Still patient or expected to return for outpatient services'),
    (13, 'Hospice / home'),
    (14, 'Hospice / medical facility'),
    (15, 'Discharged/transferred within this institution to Medicare approved swing bed'),
    (16, 'Discharged/transferred/referred another institution for outpatient services'),
    (17, 'Discharged/transferred/referred to this institution for outpatient services'),
    (18, NULL),
    (19, 'Expired at home. Medicaid only, hospice.'),
    (20, 'Expired in a medical facility. Medicaid only, hospice.'),
    (22, 'Discharged/transferred to another rehab fac including rehab units of a hospital .'),
    (23, 'Discharged/transferred to a long term care hospital.'),
    (24, 'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare.'),
    (25, 'Not Mapped'),
    (27, 'Discharged/transferred to a federal health care facility.'),
    (28, 'Discharged/transferred/referred to a psychiatric hospital of psychiatric distinct part unit of a hospital');
INSERT INTO admission_source (admission_source_id, description) VALUES
    (1, 'Physician Referral'),
    (2, 'Clinic Referral'),
    (3, 'HMO Referral'),
    (4, 'Transfer from a hospital'),
    (5, 'Transfer from a Skilled Nursing Facility (SNF)'),
    (6, 'Transfer from another health care facility'),
    (7, 'Emergency Room'),
    (8, 'Court/Law Enforcement'),
    (9, 'Not Available'),
    (10, 'Transfer from critial access hospital'),
    (11, 'Normal Delivery'),
    (13, 'Sick Baby'),
    (14, 'Extramural Birth'),
    (17, NULL),
    (20, 'Not Mapped'),
    (22, 'Transfer from hospital inpt/same fac reslt in a sep claim'),
    (25, 'Transfer from Ambulatory Surgery Center');
INSERT INTO patient (patient_nbr)
SELECT DISTINCT patient_nbr
FROM staging;
INSERT INTO diagnosis (icd9_code)
SELECT diag_1 FROM staging WHERE diag_1 <> '?'
UNION
SELECT diag_2 FROM staging WHERE diag_2 <> '?'
UNION
SELECT diag_3 FROM staging WHERE diag_3 <> '?';
INSERT INTO encounter (
    encounter_id, patient_nbr, race, gender, admission_type_id, discharge_disposition_id,
    admission_source_id, age, weight, payer_code, medical_specialty,
    time_in_hospital, num_lab_procedures, num_procedures, num_medications,
    number_outpatient, number_emergency, number_inpatient, number_diagnoses,
    max_glu_serum, A1Cresult, diabetesMed, readmitted
)
SELECT
    encounter_id,
    patient_nbr,
    NULLIF(race, '?'),
    CASE WHEN gender = 'Unknown/Invalid' THEN NULL ELSE gender END,
    admission_type_id,
    discharge_disposition_id,
    admission_source_id,
    age,
    NULLIF(weight, '?'),
    NULLIF(payer_code, '?'),
    NULLIF(medical_specialty, '?'),
    time_in_hospital,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_outpatient,
    number_emergency,
    number_inpatient,
    number_diagnoses,
    NULLIF(max_glu_serum, 'None'),
    NULLIF(A1Cresult, 'None'),
    diabetesMed,
    readmitted
FROM staging;
INSERT INTO encounter_diagnosis (encounter_id, diag_position, icd9_code)
SELECT encounter_id, 1, diag_1 FROM staging WHERE diag_1 <> '?'
UNION ALL
SELECT encounter_id, 2, diag_2 FROM staging WHERE diag_2 <> '?'
UNION ALL
SELECT encounter_id, 3, diag_3 FROM staging WHERE diag_3 <> '?';

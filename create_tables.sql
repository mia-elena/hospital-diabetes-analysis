-- CSCI 49376 Assignment 1 — Part 5

DROP DATABASE IF EXISTS hospital;
CREATE DATABASE hospital;
USE hospital;

CREATE TABLE patient (
    patient_nbr INT PRIMARY KEY,
    race VARCHAR(30), -- allows null 
    gender VARCHAR(20)
);

CREATE TABLE admission_type (
    admission_type_id INT PRIMARY KEY,
    description VARCHAR(160)
);

CREATE TABLE discharge_disposition (
    discharge_disposition_id INT PRIMARY KEY,
    description VARCHAR(160)
);

CREATE TABLE admission_source (
    admission_source_id INT PRIMARY KEY,
    description VARCHAR(160)
);

CREATE TABLE diagnosis (
    icd9_code VARCHAR(10) PRIMARY KEY
);

CREATE TABLE encounter (
    encounter_id INT PRIMARY KEY,
    patient_nbr INT NOT NULL,
    admission_type_id INT NOT NULL,
    discharge_disposition_id INT NOT NULL,
    admission_source_id INT NOT NULL,
    age VARCHAR(10) NOT NULL,
    weight VARCHAR(10), -- kept here because they may change btwn encounters; not static! 
    payer_code VARCHAR(10),
    medical_specialty VARCHAR(60),
    time_in_hospital INT NOT NULL,
    num_lab_procedures INT NOT NULL,
    num_procedures INT NOT NULL,
    num_medications INT NOT NULL,
    number_outpatient INT NOT NULL,
    number_emergency INT NOT NULL,
    number_inpatient INT NOT NULL,
    number_diagnoses INT NOT NULL,
    max_glu_serum VARCHAR(10),
    A1Cresult VARCHAR(10),
    diabetesMed VARCHAR(10) NOT NULL,
    readmitted VARCHAR(10) NOT NULL,
    CONSTRAINT fk_patient
        FOREIGN KEY (patient_nbr) REFERENCES patient(patient_nbr),
    CONSTRAINT fk_admission_type
        FOREIGN KEY (admission_type_id) REFERENCES admission_type(admission_type_id),
    CONSTRAINT fk_discharge_disposition
        FOREIGN KEY (discharge_disposition_id) REFERENCES discharge_disposition(discharge_disposition_id),
    CONSTRAINT fk_admission_source
        FOREIGN KEY (admission_source_id) REFERENCES admission_source(admission_source_id),
    CONSTRAINT chk_time_in_hospital CHECK (time_in_hospital BETWEEN 1 AND 14)
);

CREATE TABLE encounter_diagnosis (
    encounter_id INT NOT NULL,
    diag_position INT NOT NULL, -- replaces diag 1-3
    icd9_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (encounter_id, diag_position),
    CONSTRAINT chk_diag_position CHECK (diag_position IN (1, 2, 3)),
    CONSTRAINT fk_diagencounter
        FOREIGN KEY (encounter_id) REFERENCES encounter(encounter_id),
    CONSTRAINT fk_diagdiagnosis
        FOREIGN KEY (icd9_code) REFERENCES diagnosis(icd9_code)
);

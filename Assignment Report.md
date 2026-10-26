# CSCI 49376 Assignment 1 Report

Mia Yábar  · Jas 
Big Data Technology · Prof. Alex Liew 

## Part 1. Select and Examine the Original Dataset

1. Dataset selected: Diabetes 130-US Hospitals for Years 1999-2008 (Kaggle: brandao/diabetes)
2. CSV file used: `diabetic_data.csv`
3. Total rows: 101,766
4. Total columns: 50 (24 ignored, 26 used)
5. Attributes:
	1. encounter_id
	2. patient_nbr
	3. race
	4. gender
	5. age
	6. weight
	7. admission_type_id
	8. discharge_disposition_id
	9. admission_source_id
	10. time_in_hospital
	11. payer_code
	12. medical_specialty
	13. num_lab_procedures
	14. num_procedures
	15. num_medications
	16. number_outpatient
	17. number_emergency
	18. number_inpatient
	19. diag_1
	20. diag_2
	21. diag_3
	22. number_diagnoses
	23. max_glu_serum
	24. A1Cresult
	25. diabetesMed
	26. readmitted
7. Possible identifiers or keys:
	1. encounter_id
	2. patient_nbr
	3. admission_type_id, discharge_disposition_id, admission_source_id
	4. diag_1, diag_2, diag_3: diagnosis codes
8. Missing, unknown or incomplete values:
	1. weight (`?`)
	2. max_glu_serum: None (not measured)
	
Inconsistencies: 123 patients have two different race values and 3 have two genders across stays 

## Part 2. Normalize the Dataset

1NF puts each diagnosis on its own row. 2NF moves the stay columns to ENCOUNTER, so each stay is stored once.

Example used: stay 149190 (patient 55629189).
**Stay columns** = the columns that describe one hospital visit: race, gender, age, weight, admission_type_id, discharge_disposition_id, admission_source_id, time_in_hospital, payer_code, medical_specialty, num_lab_procedures, num_procedures, num_medications, number_outpatient, number_emergency, number_inpatient, number_diagnoses, max_glu_serum, A1Cresult, diabetesMed, readmitted. Race and gender are stay columns. They can differ across a patient's stays.

### Original relation

1. Structure: DIABETIC_DATA, one table, one row per stay (101,766 rows). diag_1, diag_2 and diag_3 are on that row.
2. Key: encounter_id.
3. Functional dependencies: encounter_id.
4. Problem: diag_1, diag_2 and diag_3 are a repeating group. Three columns, same kind of value.
5. Change: one row per diagnosis. Add diag_position, 1, 2 or 3.
6. Form: 1NF. One value per cell.

| encounter_id | patient_nbr | race | gender | age | time_in_hospital | diag_1 | diag_2 | diag_3 | readmitted |
|---|---|---|---|---|---|---|---|---|---|
| 149190 | 55629189 | Caucasian | Female | [10-20) | 3 | 276 | 250.01 | 255 | >30 |

### 1NF relation

1. Structure: one row per diagnosis. diag_1, diag_2 and diag_3 become icd9_code, plus diag_position. Stay columns still repeat on each row.
2. Key: (encounter_id, diag_position)
3. Functional dependencies: (encounter_id, diag_position).
4. Problem: partial dependency.
5. Change: move the stay columns to ENCOUNTER. Diagnoses stay in ENCOUNTER_DIAGNOSIS.
6. Form: 2NF. Every non-key column depends on the whole key.

| encounter_id | diag_position | icd9_code | patient_nbr | race      | time_in_hospital | readmitted |
| ------------ | ------------- | --------- | ----------- | --------- | ---------------- | ---------- |
| 149190       | 1             | 276       | 55629189    | Caucasian | 3                | >30        |
| 149190       | 2             | 250.01    | 55629189    | Caucasian | 3                | >30        |
| 149190       | 3             | 255       | 55629189    | Caucasian | 3                | >30        |

### 2NF relations

1. Structure: ENCOUNTER(encounter_id, patient_nbr, stay columns) and ENCOUNTER_DIAGNOSIS(encounter_id, diag_position, icd9_code). No partial dependencies.
2. Keys: ENCOUNTER: encounter_id. ENCOUNTER_DIAGNOSIS: (encounter_id, diag_position). encounter_id points to ENCOUNTER.
3. Functional dependencies: encounter_id → the stay columns, in ENCOUNTER. (encounter_id, diag_position) → icd9_code, in ENCOUNTER_DIAGNOSIS.
4. Problem: none.
5. Change: none.
6. Form: 2NF. Every non-key column depends on the whole key.

ENCOUNTER

| encounter_id | patient_nbr | race | gender | admission_type_id | age | time_in_hospital | readmitted |
|---|---|---|---|---|---|---|---|
| 149190 | 55629189 | Caucasian | Female | 1 | [10-20) | 3 | >30 |

ENCOUNTER_DIAGNOSIS

| encounter_id | diag_position | icd9_code |
|---|---|---|
| 149190 | 1 | 276 |
| 149190 | 2 | 250.01 |
| 149190 | 3 | 255 |

### Final tables

ENCOUNTER and ENCOUNTER_DIAGNOSIS are the 2NF tables. PATIENT is the patient id. DIAGNOSIS stores each code once. The three code tables store each id and its description.

| Table | Attributes | Primary key | Foreign key(s) |
|---|---|---|---|
| PATIENT | patient_nbr | patient_nbr | — |
| ENCOUNTER | encounter_id, patient_nbr, race, gender, admission_type_id, discharge_disposition_id, admission_source_id, age, weight, time_in_hospital, payer_code, medical_specialty, num_lab_procedures, num_procedures, num_medications, number_outpatient, number_emergency, number_inpatient, number_diagnoses, max_glu_serum, A1Cresult, diabetesMed, readmitted | encounter_id | patient_nbr, admission_type_id, discharge_disposition_id, admission_source_id |
| ENCOUNTER_DIAGNOSIS | encounter_id, diag_position, icd9_code | (encounter_id, diag_position) | encounter_id, icd9_code |
| DIAGNOSIS | icd9_code | icd9_code | — |
| ADMISSION_TYPE | admission_type_id, description | admission_type_id | — |
| DISCHARGE_DISPOSITION | discharge_disposition_id, description | discharge_disposition_id | — |
| ADMISSION_SOURCE | admission_source_id, description | admission_source_id | — |




## Part 3. Construct an ER Diagram

```mermaid
erDiagram
    PATIENT ||--|{ ENCOUNTER : "has (1:N)"
    ADMISSION_TYPE ||--|{ ENCOUNTER : "classifies (1:N)"
    DISCHARGE_DISPOSITION ||--|{ ENCOUNTER : "ends with (1:N)"
    ADMISSION_SOURCE ||--|{ ENCOUNTER : "admitted from (1:N)"
    ENCOUNTER ||--o{ ENCOUNTER_DIAGNOSIS : "diagnosed with (1:N)"
    DIAGNOSIS ||--|{ ENCOUNTER_DIAGNOSIS : "appears in (1:N)"

    PATIENT {
        int patient_nbr PK
    }
    ENCOUNTER {
        int encounter_id PK
        int patient_nbr FK
        varchar race
        varchar gender
        int admission_type_id FK
        int discharge_disposition_id FK
        int admission_source_id FK
        varchar age
        varchar weight
        int time_in_hospital
        varchar payer_code
        varchar medical_specialty
        int num_lab_procedures
        int num_procedures
        int num_medications
        int number_outpatient
        int number_emergency
        int number_inpatient
        int number_diagnoses
        varchar max_glu_serum
        varchar A1Cresult
        varchar diabetesMed
        varchar readmitted
    }
    ENCOUNTER_DIAGNOSIS {
        int encounter_id PK, FK
        int diag_position PK
        varchar icd9_code FK
    }
    DIAGNOSIS {
        varchar icd9_code PK
    }
    ADMISSION_TYPE {
        int admission_type_id PK
        varchar description
    }
    DISCHARGE_DISPOSITION {
        int discharge_disposition_id PK
        varchar description
    }
    ADMISSION_SOURCE {
        int admission_source_id PK
        varchar description
    }
```


| Relationship   | Between                           | Type | Why                                                                                                                                                           | Participation                                                             |
| -------------- | --------------------------------- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| has            | PATIENT – ENCOUNTER               | 1:N  | A patient has many stays; a stay has one patient.                                                                                                             | Total on both sides                                                       |
| classifies     | ADMISSION_TYPE – ENCOUNTER        | 1:N  | A type covers many stays; a stay has one type.                                                                                                                | Total on both sides                                                        |
| ends with      | DISCHARGE_DISPOSITION – ENCOUNTER | 1:N  | A disposition covers many stays; a stay has one disposition.                                                                                                  | Total on both sides                                                        |
| admitted from  | ADMISSION_SOURCE – ENCOUNTER      | 1:N  | A source covers many stays; a stay has one source.                                                                                                            | Total on both sides                                                        |
| diagnosed with | ENCOUNTER – DIAGNOSIS             | M:N  | A stay has up to 3 diagnoses; a diagnosis appears in many stays. Drawn as two 1:N relationships through ENCOUNTER_DIAGNOSIS, which also stores diag_position. | Partial for ENCOUNTER (some stays have no diagnosis), total for DIAGNOSIS |


## Part 4. Convert the ER Diagram into Relational Tables

| Relation | Attributes | Primary key | Foreign key(s) |
|---|---|---|---|
| PATIENT | patient_nbr | patient_nbr | — |
| ADMISSION_TYPE | admission_type_id, description | admission_type_id | — |
| DISCHARGE_DISPOSITION | discharge_disposition_id, description | discharge_disposition_id | — |
| ADMISSION_SOURCE | admission_source_id, description | admission_source_id | — |
| DIAGNOSIS | icd9_code | icd9_code | — |
| ENCOUNTER | encounter_id, patient_nbr, race, gender, admission_type_id, discharge_disposition_id, admission_source_id, age, weight, time_in_hospital, payer_code, medical_specialty, num_lab_procedures, num_procedures, num_medications, number_outpatient, number_emergency, number_inpatient, number_diagnoses, max_glu_serum, A1Cresult, diabetesMed, readmitted | encounter_id | patient_nbr, admission_type_id, discharge_disposition_id, admission_source_id |
| ENCOUNTER_DIAGNOSIS | encounter_id, diag_position, icd9_code | (encounter_id, diag_position) | encounter_id, icd9_code |

## Cardinalities

| ER relationship | Type | Represented as |
|---|---|---|
| PATIENT has ENCOUNTER | 1:N | Foreign key ENCOUNTER.patient_nbr → PATIENT (on the N side, NOT NULL) |
| ADMISSION_TYPE classifies ENCOUNTER | 1:N | Foreign key ENCOUNTER.admission_type_id → ADMISSION_TYPE (on the N side, NOT NULL) |
| DISCHARGE_DISPOSITION ends with ENCOUNTER | 1:N | Foreign key ENCOUNTER.discharge_disposition_id → DISCHARGE_DISPOSITION (on the N side, NOT NULL) |
| ADMISSION_SOURCE admitted from ENCOUNTER | 1:N | Foreign key ENCOUNTER.admission_source_id → ADMISSION_SOURCE (on the N side, NOT NULL) |
| ENCOUNTER diagnosed with DIAGNOSIS | M:N | Its own table, ENCOUNTER_DIAGNOSIS: a foreign key to each side plus diag_position |

Table creation order: PATIENT, ADMISSION_TYPE, DISCHARGE_DISPOSITION, ADMISSION_SOURCE, DIAGNOSIS → ENCOUNTER → ENCOUNTER_DIAGNOSIS.


## Part 5. Implement the Database Using SQL 

Jas. MySQL script: `work/sql/create_tables.sql`. 
Note: AI generated feel free to apply your own implementation 
```sql
-- Assignment 1 Part 5. MySQL.
-- Generated by work/factcheck.ipynb from diabetic_data.csv.
-- Parents are created before the tables that reference them.

DROP DATABASE IF EXISTS hospital;
CREATE DATABASE hospital;
USE hospital;

CREATE TABLE patient (
    patient_nbr INT PRIMARY KEY
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
    race VARCHAR(20),
    gender VARCHAR(20),
    admission_type_id INT NOT NULL,
    discharge_disposition_id INT NOT NULL,
    admission_source_id INT NOT NULL,
    age VARCHAR(10) NOT NULL,
    weight VARCHAR(10),
    payer_code VARCHAR(10),
    medical_specialty VARCHAR(40),
    time_in_hospital INT NOT NULL CHECK (time_in_hospital BETWEEN 1 AND 14),
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
    CONSTRAINT fk_enc_patient_nbr FOREIGN KEY (patient_nbr) REFERENCES patient (patient_nbr),
    CONSTRAINT fk_enc_admission_type_id FOREIGN KEY (admission_type_id) REFERENCES admission_type (admission_type_id),
    CONSTRAINT fk_enc_discharge_disposition_id FOREIGN KEY (discharge_disposition_id) REFERENCES discharge_disposition (discharge_disposition_id),
    CONSTRAINT fk_enc_admission_source_id FOREIGN KEY (admission_source_id) REFERENCES admission_source (admission_source_id)
);

CREATE TABLE encounter_diagnosis (
    encounter_id INT NOT NULL,
    diag_position INT NOT NULL CHECK (diag_position IN (1, 2, 3)),
    icd9_code VARCHAR(10) NOT NULL,
    PRIMARY KEY (encounter_id, diag_position),
    FOREIGN KEY (encounter_id) REFERENCES encounter (encounter_id),
    FOREIGN KEY (icd9_code) REFERENCES diagnosis (icd9_code)
);
```

## Part 6. Import the CSV Data

Jas. MySQL script: `work/sql/import_data.sql`. No row is typed by hand. The path is CSV, then staging, then the seven tables.

## Part 7. Verify the Database Using SQL

Jas. MySQL script: `work/sql/verification_queries.sql`. These are the results of the same statements run against the loaded database.

1. Tables contain the expected rows.
	1. patient: 71,518
	2. encounter: 101,766
	3. encounter_diagnosis: 303,496
	4. diagnosis: 915
	5. admission_type: 8
	6. discharge_disposition: 26
	7. admission_source: 17
2. Primary keys do not repeat. Each duplicate query returns no rows.
3. Foreign keys point at a real parent. Each orphan query returns 0.
4. The join rebuilds a stay. Encounter 2278392, the first row of the CSV, comes back as Caucasian, Female, age [0-10), 1 day, diagnosis position 1 = 250.83, readmitted NO. diag_2 and diag_3 were `?`, so they have no diagnosis rows.
5. The ENCOUNTER columns match the CSV on every row. Race and gender are on the stay. `?` and Unknown/Invalid are NULL.


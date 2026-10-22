# Hospital Readmissions Database

Relational database design for **101,766 diabetic inpatient encounters** across 130 U.S. hospitals (1999–2008), the [Diabetes 130-US Hospitals](https://www.kaggle.com/datasets/brandao/diabetes) dataset (Strack et al., 2014).

CSCI 49376 Big Data Technology, Hunter College, Assignment 1. This repo holds **Partner A's work: deliverables 1–10** (dataset, attributes, normalization, functional dependencies, keys, ER diagram, relational schema). The SQL scripts and screenshots (deliverables 11–13) are Partner B's and are not included here.

## Report

[CSCI 49376 Assignment 1 Report](https://docs.google.com/document/d/1-cNh-NuGfREmi5sbFYx5jiEWIVyzA_Bz6OedEvMbPFE/edit).


## Design summary

### Table diagram

```mermaid
erDiagram
    PATIENT {
        int patient_nbr PK
        varchar race "NULL if unknown"
        varchar gender
    }

    ENCOUNTER {
        int encounter_id PK
        int patient_nbr FK
        tinyint admission_type_id FK
        tinyint discharge_disposition_id FK
        tinyint admission_source_id FK
        varchar age "10-year band, e.g. [70-80)"
        tinyint time_in_hospital "days, 1-14"
        smallint num_lab_procedures
        tinyint num_medications
        tinyint number_inpatient "visits in prior year"
        varchar A1Cresult "NULL = not measured"
        varchar max_glu_serum "NULL = not measured"
        varchar readmitted "NO, >30, <30"
    }

    ENCOUNTER_DIAGNOSIS {
        int encounter_id PK, FK
        tinyint diag_position PK "1 primary, 2 secondary, 3 additional"
        varchar icd9_code FK
    }

    DIAGNOSIS {
        varchar icd9_code PK "ICD-9, e.g. 250.83"
    }

    ADMISSION_TYPE {
        tinyint admission_type_id PK
        varchar description "Emergency, Urgent, Elective..."
    }

    DISCHARGE_DISPOSITION {
        tinyint discharge_disposition_id PK
        varchar description "Home, Transferred, Expired..."
    }

    ADMISSION_SOURCE {
        tinyint admission_source_id PK
        varchar description "Physician Referral, ER..."
    }

    PATIENT ||--|{ ENCOUNTER : "has"
    ADMISSION_TYPE ||--o{ ENCOUNTER : "classifies"
    DISCHARGE_DISPOSITION ||--o{ ENCOUNTER : "ends_with"
    ADMISSION_SOURCE ||--o{ ENCOUNTER : "admitted_from"
    ENCOUNTER ||--o{ ENCOUNTER_DIAGNOSIS : "diagnosed_with"
    DIAGNOSIS ||--|{ ENCOUNTER_DIAGNOSIS : "appears_in"
```

`||--|{` one to one-or-many · `||--o{` one to zero-or-many. The M:N between encounters and diagnoses is the `ENCOUNTER_DIAGNOSIS` table. Only the most important `ENCOUNTER` columns are shown; all 21 are in item 7 of the report. Source: [`work/table_diagram.mmd`](work/table_diagram.mmd). The Chen ER diagram (deliverable 9) is in `CSCI49376_Assignment1_Yabar/ER_Diagram.pdf`.


The flat 50-column CSV (26 columns in scope) is normalized into 7 tables:

| Table | Rows | Primary key |
|---|---|---|
| `encounter` | 101,766 | `encounter_id` |
| `patient` | 71,518 | `patient_nbr` |
| `encounter_diagnosis` | 303,496 | (`encounter_id`, `diag_position`) |
| `diagnosis` | 915 | `icd9_code` |
| `admission_type` / `discharge_disposition` / `admission_source` | 8 / 26 / 17 | `*_id` |

- **1NF:** the repeating `diag_1`–`diag_3` columns become one row per diagnosis, keyed by (`encounter_id`, `diag_position`).
- **2NF:** attributes that depend only on `encounter_id` (a partial dependency) move to `encounter`.
- **Beyond 2NF:** patient demographics and code descriptions get their own tables, removing 30,000+ redundant copies of patient data.

Data quality findings from profiling: `weight` is missing for 96.9% of encounters, HbA1c was measured in only 16.7%, 123 patients have conflicting race values across visits, and 5,492 encounters repeat a diagnosis code in two slots.

## Reproduce the profile

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
kaggle datasets download -d brandao/diabetes -p data --unzip   # needs ~/.kaggle/kaggle.json
python3 work/profile_csv.py data/diabetic_data.csv              # writes work/profile.md
```

The data is not committed. `IDs_mapping.csv` (descriptions for the admission, discharge and source codes) comes from the UCI Machine Learning Repository, dataset 296; put it in `data/` too.

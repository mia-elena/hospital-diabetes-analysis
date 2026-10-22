# Profile of `diabetic_data.csv`

- Rows: **101,766**
- Columns: **50** (26 after dropping the 24 columns the assignment says to ignore)

| # | Column | Looks like | Distinct | Missing/unknown | Examples |
|---|---|---|---|---|---|
| 1 | `encounter_id` | number | 101,766 | 0 | 2278392, 149190, 64410 |
| 2 | `patient_nbr` | number | 71,518 | 0 | 8222157, 55629189, 86047875 |
| 3 | `race` | text | 6 | 2,273 (2.2%) | Caucasian, AfricanAmerican, Other |
| 4 | `gender` | text | 3 | 3 (0.0%) | Female, Male |
| 5 | `age` | text | 10 | 0 | [0-10), [10-20), [20-30) |
| 6 | `weight` | text | 10 | 98,569 (96.9%) | [75-100), [50-75), [0-25) |
| 7 | `admission_type_id` | number | 8 | 0 | 6, 1, 2 |
| 8 | `discharge_disposition_id` | number | 26 | 0 | 25, 1, 3 |
| 9 | `admission_source_id` | number | 17 | 0 | 1, 7, 2 |
| 10 | `time_in_hospital` | number | 14 | 0 | 1, 3, 2 |
| 11 | `payer_code` | text | 18 | 40,256 (39.6%) | MC, MD, HM |
| 12 | `medical_specialty` | text | 73 | 49,949 (49.1%) | Pediatrics-Endocrinology, InternalMedicine, Family/GeneralPractice |
| 13 | `num_lab_procedures` | number | 118 | 0 | 41, 59, 11 |
| 14 | `num_procedures` | number | 7 | 0 | 0, 5, 1 |
| 15 | `num_medications` | number | 75 | 0 | 1, 18, 13 |
| 16 | `number_outpatient` | number | 39 | 0 | 0, 2, 1 |
| 17 | `number_emergency` | number | 33 | 0 | 0, 1, 2 |
| 18 | `number_inpatient` | number | 21 | 0 | 0, 1, 2 |
| 19 | `diag_1` | text | 717 | 21 (0.0%) | 250.83, 276, 648 |
| 20 | `diag_2` | text | 749 | 358 (0.4%) | 250.01, 250, 250.43 |
| 21 | `diag_3` | text | 790 | 1,423 (1.4%) | 255, V27, 403 |
| 22 | `number_diagnoses` | number | 16 | 0 | 1, 9, 6 |
| 23 | `max_glu_serum` | text | 4 | 96,420 (94.7%) | >300, Norm, >200 |
| 24 | `A1Cresult` | text | 4 | 84,748 (83.3%) | >7, >8, Norm |
| 25 | `metformin` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 26 | `repaglinide` *(ignored)* | text | 4 | 0 | No, Up, Steady |
| 27 | `nateglinide` *(ignored)* | text | 4 | 0 | No, Steady, Down |
| 28 | `chlorpropamide` *(ignored)* | text | 4 | 0 | No, Steady, Down |
| 29 | `glimepiride` *(ignored)* | text | 4 | 0 | No, Steady, Down |
| 30 | `acetohexamide` *(ignored)* | text | 2 | 0 | No, Steady |
| 31 | `glipizide` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 32 | `glyburide` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 33 | `tolbutamide` *(ignored)* | text | 2 | 0 | No, Steady |
| 34 | `pioglitazone` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 35 | `rosiglitazone` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 36 | `acarbose` *(ignored)* | text | 4 | 0 | No, Steady, Up |
| 37 | `miglitol` *(ignored)* | text | 4 | 0 | No, Steady, Down |
| 38 | `troglitazone` *(ignored)* | text | 2 | 0 | No, Steady |
| 39 | `tolazamide` *(ignored)* | text | 3 | 0 | No, Steady, Up |
| 40 | `examide` *(ignored)* | text | 1 | 0 | No |
| 41 | `citoglipton` *(ignored)* | text | 1 | 0 | No |
| 42 | `insulin` *(ignored)* | text | 4 | 0 | No, Up, Steady |
| 43 | `glyburide-metformin` *(ignored)* | text | 4 | 0 | No, Steady, Down |
| 44 | `glipizide-metformin` *(ignored)* | text | 2 | 0 | No, Steady |
| 45 | `glimepiride-pioglitazone` *(ignored)* | text | 2 | 0 | No, Steady |
| 46 | `metformin-rosiglitazone` *(ignored)* | text | 2 | 0 | No, Steady |
| 47 | `metformin-pioglitazone` *(ignored)* | text | 2 | 0 | No, Steady |
| 48 | `change` *(ignored)* | text | 2 | 0 | No, Ch |
| 49 | `diabetesMed` | text | 2 | 0 | No, Yes |
| 50 | `readmitted` | text | 3 | 0 | NO, >30, <30 |

## Possible keys

- `encounter_id` is unique on every row, so it can be a primary key.
- `patient_nbr` has 71,518 distinct values across 101,766 rows, so it repeats: an identifier for another entity (foreign key candidate).
- `admission_type_id` has 8 distinct values across 101,766 rows, so it repeats: an identifier for another entity (foreign key candidate).
- `discharge_disposition_id` has 26 distinct values across 101,766 rows, so it repeats: an identifier for another entity (foreign key candidate).
- `admission_source_id` has 17 distinct values across 101,766 rows, so it repeats: an identifier for another entity (foreign key candidate).

## Columns with missing or unknown values

- `race`: 2,273 rows (2.2%), written as '?'
- `gender`: 3 rows (0.0%), written as 'Unknown/Invalid'
- `weight`: 98,569 rows (96.9%), written as '?'
- `payer_code`: 40,256 rows (39.6%), written as '?'
- `medical_specialty`: 49,949 rows (49.1%), written as '?'
- `diag_1`: 21 rows (0.0%), written as '?'
- `diag_2`: 358 rows (0.4%), written as '?'
- `diag_3`: 1,423 rows (1.4%), written as '?'
- `max_glu_serum`: 96,420 rows (94.7%), written as 'None'
- `A1Cresult`: 84,748 rows (83.3%), written as 'None'

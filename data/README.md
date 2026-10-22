# Data

Not committed. Download into this folder:

```bash
pip install kaggle
# put your API token at ~/.kaggle/kaggle.json (Kaggle → Settings → API → Create New Token)
kaggle datasets download -d brandao/diabetes -p data --unzip
```

Also download `IDs_mapping.csv` (descriptions for the admission type, discharge disposition and admission source codes) from the UCI Machine Learning Repository, dataset 296 ("Diabetes 130-US Hospitals for Years 1999–2008"), and put it here.

| File | Rows | Source |
|---|---|---|
| `diabetic_data.csv` | 101,766 encounters × 50 columns | Kaggle `brandao/diabetes` / UCI |
| `IDs_mapping.csv` | code → description lists | UCI |
| `description.pdf` | Strack et al. (2014), the paper the data comes from | Kaggle |

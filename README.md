# Titanic — MLDS 400 HW3 (Dockerized: Python + R)

This repo provides two minimal, reproducible Docker pipelines (Python and base R) that:
- Load the Titanic training data,
- Perform simple feature engineering,
- Fit a logistic regression,
- Print all changes (Q14–Q18),
- Save predictions for the test set to `outputs/`.

> **Important:** Dataset files are **not included** in this repo. You must download them and place them locally as described below.

---

## 1) Prerequisites

- **Docker Desktop** installed and running  
  - macOS: Install from docker.com and start Docker Desktop before running.
- **Git** (to clone) and a terminal (macOS Terminal or VS Code Terminal).

---

## 2) Clone the repository

**Option A (Terminal):**
```bash
git clone git@github.com:ZikunZheng1129/titanic-disaster-2025fallmlds400hw3.git
cd titanic-disaster-2025fallmlds400hw3
```

**Option B (HTTPS):**
```bash
git clone https://github.com/ZikunZheng1129/titanic-disaster-2025fallmlds400hw3.git
cd titanic-disaster-2025fallmlds400hw3
```

## 3) Download the data (do not commit it)

1. Go to Kaggle -> Titanic - Machine Learning from Disaster -> Download:
* train.csv
* test.csv

2. Place the files locally inside your cloned repo at:
```bash
<repo-root>/src/data/train.csv
<repo-root>/src/data/test.csv
```
Example (macOS full path):
```bash
/Users/zhengzikun/Desktop/MLDS400/homework3/github dir/titanic-disaster-2025fallmlds400hw3/src/data/train.csv
/Users/zhengzikun/Desktop/MLDS400/homework3/github dir/titanic-disaster-2025fallmlds400hw3/src/data/test.csv
```

3. src/data/ is already in .gitignore. Do not add the CSVs to Git.

## 4) Project layout (what to expect)
```bash
titanic-disaster-2025fallmlds400hw3/
├─ .github/
├─ .dockerignore
├─ .gitignore
├─ Dockerfile                 # Python Dockerfile
├─ README.md
├─ requirements.txt           # pinned Python versions
├─ outputs/                   # predictions go here (created at runtime)
└─ src/
   ├─ app/
   │  └─ main.py              # Python script (Q13–Q18 prints)
   ├─ data/                   # put train.csv/test.csv here (local only)
   └─ rapp/
      ├─ Dockerfile           # R Dockerfile (base R)
      ├─ install_packages.R   # kept for requirement (no-op)
      └─ main.R               # R script (Q13–Q18 prints, just redo in R)

```

## 5) Run the Python Docker pipeline


Run these from the repo root (same folder as Dockerfile and requirements.txt).

**Build the image:**:
```bash
docker build -t myfirstapp .

```

**Run the container (mount data + outputs):**:
```bash
docker run --rm \
  -v "$PWD/src/data:/app/src/data" \
  -v "$PWD/outputs:/app/outputs" \
  myfirstapp


```

### What you’ll see in the terminal (Q13–Q18 prints):
* Q13: confirms path to train.csv and prints head().
* Q14: adds FamilySize, IsAlone, fills Age(median) + Embarked(mode), encodes Sex_bin.
* Q15: fits logistic regression on Pclass, Sex_bin, Age, Fare, FamilySize, IsAlone.
* Q16: prints training accuracy.
* Q17: applies same transforms to test.csv; fills missing Fare with train median.
* Q18: saves predictions to outputs/predictions.csv.

**Resulting file**:
```bash
outputs/predictions.csv

```

## 6) Run the R Docker pipeline (base R only)

Run these from the repo root.

**Build the image**:

```bash
docker build -t myfirstapp-r -f src/rapp/Dockerfile .


```

**Run the container (mount data + outputs)**:
```bash
docker run --rm \
  -v "$PWD/src/data:/app/src/data" \
  -v "$PWD/outputs:/app/outputs" \
  myfirstapp-r


```

### What you’ll see (mirrors Python, Q13–Q18):
* Q13: confirms path to train.csv and prints first rows.
* Q14: creates FamilySize, IsAlone, fills Age(median) + Embarked(mode), encodes Sex_bin.
* Q15: runs glm (logistic) on the same feature set.
* Q16: prints training accuracy.
* Q17: applies same transforms to test.csv; fills Fare with train median.
* Q18: saves predictions to outputs/predictions_r.csv.

**Resulting file**:

```bash
outputs/predictions_r.csv

```

Note: install_packages.R is intentionally minimal (no packages installed) because there's no additional package required to satisfy the assignment requirement.

## Optional R packages (tidyverse, glmnet)

This assignment does not require additional R packages, but the repo includes a standard way to add them if desired.

- The file `src/rapp/install_packages.R` contains a commented installer for:
  - `tidyverse`
  - `glmnet`

- The file `src/rapp/main.R` contains commented `library()` lines for the same packages.

They are **commented out by default** to keep the Docker image small and the build fast. If you want to enable them:

1) Edit `src/rapp/install_packages.R` and uncomment:
   ```r
   packages <- c("tidyverse", "glmnet")
   for (pkg in packages) {
     if (!requireNamespace(pkg, quietly = TRUE)) {
       install.packages(pkg, repos = "https://cloud.r-project.org")
     }
   }
   ```
2) Edit src/rapp/main.R and uncomment:
   ```r
   library(tidyverse)
   library(glmnet)
   ```
3) Rebuild and run the R image:
  ```bash
  docker build -t myfirstapp-r -f src/rapp/Dockerfile .
  docker run --rm \
    -v "$PWD/src/data:/app/src/data" \
    -v "$PWD/outputs:/app/outputs" \
    myfirstapp-r

  ```




### Quick grader checklist (few steps)
1. Clone repo and cd into it.
2. Put train.csv and test.csv into src/data/.
3. Python run:
```bash
docker build -t myfirstapp .
docker run --rm -v "$PWD/src/data:/app/src/data" -v "$PWD/outputs:/app/outputs" myfirstapp

```
4. R run:
```bash
docker build -t myfirstapp-r -f src/rapp/Dockerfile .
docker run --rm -v "$PWD/src/data:/app/src/data" -v "$PWD/outputs:/app/outputs" myfirstapp-r

```

Python's output is saved outputs/predictions.csv, and R's output is saved outputs/predictions_r.csv

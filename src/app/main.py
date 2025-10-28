print("Titanic HW3 Docker run OK.")

from pathlib import Path
import pandas as pd


# Q13

# cd "/Users/zhengzikun/Desktop/MLDS400/homework3/github dir/titanic-disaster-2025fallmlds400hw3"
# source .venv/bin/activate
# cp "/Users/zhengzikun/Desktop/MLDS400/homework3/titanic/train.csv" src/data/train.csv
# cp "/Users/zhengzikun/Desktop/MLDS400/homework3/titanic/test.csv"  src/data/test.csv

# .../src/app
HERE = Path(__file__).resolve().parent
# .../src/data
DATA_DIR = HERE.parent / "data"
train_path = DATA_DIR / "train.csv"
test_path = DATA_DIR / "test.csv"

print(train_path)
df = pd.read_csv(train_path)
# browse the first few lines
print(df.head())



# Q14

# check missing values
missing = df.isna().sum().sort_values(ascending=False)
print(missing[missing > 0])

# check quick stats
print("Q14 quick stats", df[["Survived","Pclass","Sex","Age","SibSp","Parch","Fare","Embarked"]].describe(include="all"))

# since there're SibSp and Parch columns, I decide to combine them and get a new column called FamilySize for later use
df["FamilySize"] = df["SibSp"] + df["Parch"] + 1
print("Q14: added FamilySize; sample:", df["FamilySize"].head(5).tolist())

# since being alone can be a factor for survival, I decide to make those whose FamilySize==1 as a new column
df["IsAlone"] = (df["FamilySize"] == 1).astype(int)
print("Q14: added IsAlone; value_counts:", df["IsAlone"].value_counts().to_dict())

# since we're having 177 missing values for Age, 2 missing values for Embarked
# for Age, we fill with median value
# for Embark, we fill with mode
age_med = df["Age"].median()
emb_mode = df["Embarked"].mode().iloc[0]
df["Age"] = df["Age"].fillna(age_med)
df["Embarked"] = df["Embarked"].fillna(emb_mode)
print(f"Q14: filled Age with median={age_med:.2f}, Embarked with mode={emb_mode}")

# then we convert Sex to binary (female=1, male=0)
df["Sex_bin"] = (df["Sex"] == "female").astype(int)
# print(df[['Sex_bin', 'Sex']].head())
print("Q14: encoded Sex -> Sex_bin; head:", df[["Sex","Sex_bin"]].head(5).to_dict(orient="list"))



# Q15
import numpy as np 
np.random.seed(42)
feats = ["Pclass", "Sex_bin", "Age", "Fare", "FamilySize", "IsAlone"]
target = "Survived"
print("Q15: features:", feats, "| target:", target)

# check number of missing values
print(df[feats].isna().sum())

from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

X_train = df[feats]
y_train = df[target]
print("Q15: NaNs in X_train by column:", X_train.isna().sum().to_dict())

model = LogisticRegression(random_state=42)

model.fit(X_train, y_train)
print("Q15: model fit done")



# Q16
y_pred_tr = model.predict(X_train)
train_acc = accuracy_score(y_train, y_pred_tr)
print("Q16 accuracy on training set:", train_acc)



# Q17
test = pd.read_csv(test_path)
test["FamilySize"] = test["SibSp"] + test["Parch"] + 1

# from Q14
test["IsAlone"] = (test["FamilySize"] == 1).astype(int)
print("Q17: test FamilySize/IsAlone added; sample:", test[["FamilySize","IsAlone"]].head(5).to_dict(orient="list"))

test["Age"] = test["Age"].fillna(age_med)
test["Sex_bin"] = (test["Sex"] == "female").astype(int)
print("Q17: encoded test Sex->Sex_bin; head:", test[["Sex","Sex_bin"]].head(5).to_dict(orient="list"))

# print(test['Fare'].isna().sum())
fare_med = df["Fare"].median()
test["Fare"] = test["Fare"].fillna(fare_med)

print(f"Q17: filled test Age with train median={age_med:.2f} and test Fare with train median={fare_med:.2f}")

X_test = test[feats]
# test_pred = model.predict(X_test)
print("Q17: NaNs in X_test by column:", X_test.isna().sum().to_dict())


# # Q18
# test_acc = accuracy_score(test["Survived"], test_pred)
# print("accuracy on testing set:", test_acc)

# based on the instruction, I will just save output (prediction)
test_pred = model.predict(X_test)
OUT_DIR = (HERE.parent.parent / "outputs")
OUT_DIR.mkdir(exist_ok=True)
pred_path = OUT_DIR / "predictions.csv"
out_df = pd.DataFrame({"PassengerId": test["PassengerId"], "Survived": test_pred})
out_df.to_csv(pred_path, index=False)
print(f"Q18: saved predictions to: {pred_path}")


























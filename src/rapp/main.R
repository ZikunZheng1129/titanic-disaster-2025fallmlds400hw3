# src/rapp/main.R
cat("Titanic HW3 Docker (R) run OK.\n")

# Optional imports (not required for this assignment run).
# Uncomment if you want to use these packages.
# library(tidyverse)
# library(glmnet)

set.seed(42)

# Q13
here_app <- "/app"
data_dir <- file.path(here_app, "src", "data")
train_path <- file.path(data_dir, "train.csv")
test_path <- file.path(data_dir, "test.csv")

cat(train_path, "\n")
df <- read.csv(train_path, stringsAsFactors = FALSE)
print(head(df))

# Q14

# check missing values
na_counts <- sapply(df, function(x) sum(is.na(x)))
na_counts <- sort(na_counts, decreasing = TRUE)
print(na_counts[na_counts > 0])

# check quick stats
cat("Q14 quick stats ")
sel <- c("Survived","Pclass","Sex","Age","SibSp","Parch","Fare","Embarked")
print(summary(df[, sel]))

# FamilySize
df$FamilySize <- df$SibSp + df$Parch + 1
cat("Q14: added FamilySize; sample:", paste(head(df$FamilySize, 5), collapse = ", "), "\n")

# IsAlone
df$IsAlone <- as.integer(df$FamilySize == 1)
tab_isalone <- table(df$IsAlone)
cat("Q14: added IsAlone; value_counts:", paste(names(tab_isalone), as.integer(tab_isalone)), "\n")

# fill Age (median) and Embarked (mode)
age_med <- median(df$Age, na.rm = TRUE)
emb_mode <- names(which.max(table(df$Embarked)))
df$Age[is.na(df$Age)] <- age_med
df$Embarked[is.na(df$Embarked)] <- emb_mode
cat(sprintf("Q14: filled Age with median=%.2f, Embarked with mode=%s\n", age_med, emb_mode))

# Sex_bin
df$Sex_bin <- as.integer(df$Sex == "female")
cat("Q14: encoded Sex -> Sex_bin; head:\n")
print(head(df[, c("Sex","Sex_bin")], 5))

# Q15
feats <- c("Pclass", "Sex_bin", "Age", "Fare", "FamilySize", "IsAlone")
target <- "Survived"
cat("Q15: features:", paste(feats, collapse = ", "), "| target:", target, "\n")

# show NA by column in features
na_feats <- sapply(df[, feats, drop = FALSE], function(x) sum(is.na(x)))
print(na_feats)

# ensure Fare has no NA in train (should already be fine)
if (any(is.na(df$Fare))) {
    fare_med_train <- median(df$Fare, na.rm = TRUE)
    df$Fare[is.na(df$Fare)] <- fare_med_train
    }

# glm logistic regression
form <- as.formula(paste("Survived ~", paste(feats, collapse = " + ")))
model <- glm(form, data = df, family = binomial())
cat("Q15: model fit done\n")

# Q16
prob_tr <- predict(model, newdata = df, type = "response")
y_pred_tr <- as.integer(prob_tr >= 0.5)
train_acc <- mean(y_pred_tr == df$Survived)
cat("Q16 accuracy on training set:", train_acc, "\n")

# Q17
test <- read.csv(test_path, stringsAsFactors = FALSE)

test$FamilySize <- test$SibSp + test$Parch + 1
test$IsAlone <- as.integer(test$FamilySize == 1)
cat("Q17: test FamilySize/IsAlone added; sample:\n")
print(head(test[, c("FamilySize","IsAlone")], 5))

test$Age[is.na(test$Age)] <- age_med
test$Sex_bin <- as.integer(test$Sex == "female")
cat("Q17: encoded test Sex->Sex_bin; head:\n")
print(head(test[, c("Sex","Sex_bin")], 5))

fare_med <- median(df$Fare, na.rm = TRUE)
test$Fare[is.na(test$Fare)] <- fare_med
cat(sprintf("Q17: filled test Age with train median=%.2f and test Fare with train median=%.2f\n", age_med, fare_med))

X_test <- test[, feats, drop = FALSE]
na_xtest <- sapply(X_test, function(x) sum(is.na(x)))
cat("Q17: NaNs in X_test by column:", paste(names(na_xtest), na_xtest), "\n")

# Q18 (save predictions)
prob_te <- predict(model, newdata = test, type = "response")
test_pred <- as.integer(prob_te >= 0.5)

out_dir <- file.path(here_app, "outputs")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)
pred_path <- file.path(out_dir, "predictions_r.csv")
out_df <- data.frame(PassengerId = test$PassengerId, Survived = test_pred)
write.csv(out_df, pred_path, row.names = FALSE)
cat(sprintf("Q18: saved predictions to: %s\n", pred_path))
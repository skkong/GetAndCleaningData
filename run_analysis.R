#
# features: column names
# y_test.txt: row names = activity name
# read X data and y data, and then merge them
#

library(dplyr)
############################################################################
## Step 1: Merges the training and the test sets to create one data set.
##
x_train <- read.table("train//X_train.txt", header=FALSE)   # no: 7352, read training set
y_train <- read.table("train//y_train.txt", header=FALSE)   # no: 7352, read training labels (= activity)

x_test <- read.table("test/X_test.txt", header=FALSE)       # no: 2947, read test set
y_test <- read.table("test/y_test.txt", header=FALSE)       # no: 2947, read test lables (= activity)

subject_train <- read.table("train/subject_train.txt")      # no: 7352, read An identifier of the subject who carried out the train
subject_test <- read.table("test/subject_test.txt")         # no: 2947, read An identifier of the subject who carried out the test

x_train$subject <- subject_train$V1
x_test$subject <- subject_test$V1

x_train$activity <- y_train$V1
x_test$activity <- y_test$V1

all_ds <- rbind(x_train, x_test)                            # merge two data set

############################################################################
## Step 2: Extracts only the measurements on the mean and standard deviation for each measurement. 
##
# features.V2 is column name. grep and consider ignore case.
features <- read.table("features.txt")
features.order <- grep ("(mean|std)", features$V2, ignore.case = TRUE)
all_ds.mean_std <- all_ds[,features.order]

# add subject and activity column to all_ds.mean_std
all_ds.mean_std$subject <- all_ds$subject
all_ds.mean_std$activity <- all_ds$activity

############################################################################
## Step 3: Uses descriptive activity names to name the activities in the data set
##
# activity.lables$V2 is activity label.
activity.labels <- read.table("activity_labels.txt")
all_ds.mean_std$activity <- activity.labels[all_ds.mean_std$activity, ]$V2

############################################################################
## Step 4: Appropriately labels the data set with descriptive variable names. 
##
colnames(all_ds.mean_std) <- features[features.order,]$V2    # assign descriptive column name to data set

count_columns <- length(colnames(all_ds.mean_std))
names(all_ds.mean_std)[count_columns - 1] <- c("subject")       # assign activity tag to column
names(all_ds.mean_std)[count_columns] <- c("activity")      # assign activity tag to column
############################################################################
## Step 5: From the data set in step 4, creates a second, independent tidy data set 
##      with the average of each variable for each activity and each subject.
##
# using dplyr package and chaining call
all_ds_2nd <- all_ds.mean_std 
    %>% group_by(subject, activity) 
    %>% summarise_each(funs(mean))

write.table(all_ds_2nd, file="output.txt", row.names = FALSE)       # save output as file


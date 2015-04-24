#
# features.txt: column names
# y_test.txt: activity name
# read X data and y data, and then merge them
# ex) source('run_analysis.R')

# include as following to make tidy data sets
library(dplyr)
library(tidyr)

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
# In my opinion, all lower cases of variables are not readable. 
# So, I have replaced special characters like as -, (, ) with dot(.)
# and fBodyBody... with fBody... to make more descriptive variable names.
# Additionally, t means Time and f means Fft(Fast Fourier Transformation)

more_descriptive <- features[features.order,]$V2

more_descriptive <- gsub("-", ".", more_descriptive)
more_descriptive <- gsub(",", ".", more_descriptive)
more_descriptive <- gsub("\\(\\)", "", more_descriptive)
more_descriptive <- gsub("\\(", ".", more_descriptive)
more_descriptive <- gsub("\\)", "", more_descriptive)
more_descriptive <- gsub("^fBodyBody", "fBody", more_descriptive)   # correct fBodyBody... as fBody
more_descriptive <- gsub("^t", "Time", more_descriptive)            # t means Time
more_descriptive <- gsub("^f", "Fft", more_descriptive)             # f means Fft

colnames(all_ds.mean_std) <- c(more_descriptive, "subject", "activity")   # assign descriptive column name to data set

############################################################################
## Step 5: From the data set in step 4, creates a second, independent tidy data set 
##      with the average of each variable for each activity and each subject.
##
# using dplyr, tidyr package and chaining call to make tidy data set
all_ds_2nd <- all_ds.mean_std %>% 
  group_by(subject, activity) %>% 
  summarise_each(funs(mean)) %>% 
  gather(vFeature, vMean, -c(subject, activity))

write.table(all_ds_2nd, file="output.txt", row.names = FALSE)       # save output as file
# read file: output <- read.table('output.txt', header=TRUE)

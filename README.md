The dataset includes the following files
============================================
* features.txt: It has column names of features
* x_train.txt and y_train.txt: trainging and test data sets
* y_train.txt and y_test.txt: row names = activity name
* train/subject_train.txt and test/subject_test.txt: An identifier of the subject who carried out the train or test

* CodeBook.md: The explanation of the variables of output.txt file.
* run_analysis.R: It does tidying data sets.
* output.txt: tidy data set.

R variables List
====================
* x_train			.Read training data set
* y_train 		.Read training labels which is activity
* x_test			.Read test data set
* y_test			.Read test labels which is activity
* subject_train	.Read an identifier of the subject who carried out the train
* subject_test	.Read an identifier of the subject who carried out the test

* all_ds			.Intermediate data set to tidy data set.
* all_ds.mean_std	.Intermediate data set which has mean and standard variable.


Include as following packages to make tidy data sets
========================================================
library(dplyr)
library(tidyr)

### Step 1: Merges the training and the test sets to create one data set.

1. Read training, test data sets, labels and subject text files using read.table

ex) x_train <- read.table("train//X_train.txt", header=FALSE)   # no: 7352, read training set

2. And then, add column subject to train and test data set

ex) x_train$subject <- subject_train$V1

3. Add column activity to train and test data set

ex) x_train$activity <- y_train$V1

4. Make all_ds using rbind to have train and test data sets.

ex) all_ds <- rbind(x_train, x_test)                            # merge two data set

### Step 2: Extracts only the measurements on the mean and standard deviation for each measurement. 

features.V2 is column name. grep and consider ignore case.

1. Using grep(), find the columns' position which have mean or std.

ex) features.order <- grep ("(mean|std)", features$V2, ignore.case = TRUE)

2. Using vector calculation, make all_ds.mean_std that is a intermediate file to tidy data set.

ex) all_ds.mean_std <- all_ds[,features.order]

3. add subject and activity column to all_ds.mean_std

ex) all_ds.mean_std$subject <- all_ds$subject

### Step 3: Uses descriptive activity names to name the activities in the data set

activity.lables$V2 is activity label.

1. Using activity_labels.txt, replace the activity number with its label.

ex) all_ds.mean_std$activity <- activity.labels[all_ds.mean_std$activity, ]$V2


### Step 4: Appropriately labels the data set with descriptive variable names. 

In my opinion, all lower cases of variables are not readable. 
So, I have replaced special characters like as -, (, ) with dot(.)
and fBodyBody... with fBody... to make more descriptive variable names.
Additionally, t means Time and f means Fft(Fast Fourier Transformation)

* more_descriptive <- gsub("-", ".", more_descriptive)
* more_descriptive <- gsub(",", ".", more_descriptive)
* more_descriptive <- gsub("\\(\\)", "", more_descriptive)
* more_descriptive <- gsub("\\(", ".", more_descriptive)
* more_descriptive <- gsub("\\)", "", more_descriptive)
* more_descriptive <- gsub("^fBodyBody", "fBody", more_descriptive)   # correct fBodyBody... as fBody
* more_descriptive <- gsub("^t", "Time", more_descriptive)            # t means Time
* more_descriptive <- gsub("^f", "Fft", more_descriptive)				# f means Fft


### Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

With dplyr and tidyr package, I have calling the chain functions to make tidy data set.
Firstly, I make grouping by with subject, activity variables and then summarize each columns without subject and activity vairables and lastly melting them to make long data set.
I think either wide or long form is acceptable for tidy data set.
But wide form has 60+ columns name and long form has just 4 columns.
I decided to make long form of data set for simplifying CodeBook.md.

all_ds_2nd <- all_ds.mean_std %>% 
  group_by(subject, activity) %>% 
  summarise_each(funs(mean)) %>% 
  gather(vFeature, vMean, -c(subject, activity))


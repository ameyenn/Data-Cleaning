# Data-Cleaning
Data cleaning of experimental data set collected from the accelerometers from the Samsung Galaxy S smartphone.
The data set is available at https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Detailed information can be obtained from in: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

In summary, The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.( ref: website above)

The assignment tasked asked the following processing to be performed on the dataset.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Outline of how the script addresses the above objectives.

There are 30 volunteers labled 1 to 30. Each takes a number of activities, which are labled 1 to 6.
The result of the tests conducted are stored in files testX, trainX. These files list the results as columns labled V1, V2 and so on.
There is also a subject file for both Test and Train data. The number of rows matches the number of rows in each of testX and trainX, testX contins 70% and trainX 30%. 

The files testy and trainy list the activities related to each row of testX and trainX.

Thus a structure such as: subject, activities, v1, v2, ........ allows the data file to be merged and processing to be done via grouping on subject and/or activities.


1. Reading and Merging

There are a number files and these are grouped in two groups.
Group 1: includes four files - testX, testy, trainX and trainy. testX and trainX list the results 
Each file was read and checked.

testX <-read.table("./test/X_test.txt", header=FALSE)
ifelse (sum(is.na(testX)==0), print("file OK"), print("check file"))
testy <-read.table("./test/y_test.txt", header=FALSE)
ifelse (sum(is.na(testy)==0), print("file OK"), print("check file"))
trainX <-read.table("./train/X_train.txt", header=FALSE)
ifelse (sum(is.na(trainX)==0), print("file OK"), print("check file"))
trainy <-read.table("./train/y_train.txt", header=FALSE)
ifelse (sum(is.na(trainX)==0), print("file OK"), print("check file"))

Group 2: there are three files in this group: features, activity_labels, subject
The files were read and the column names tidied to meaningful names at the same time, this process
helped me understand the underlying structure.

variableNames<-read.table("features.txt")  
colnames(trainX) <- variableNames[,2]                                           
colnames(testX) <- variableNames[,2]
actLables<-read.table("activity_labels.txt")  
colnames(actLables) <- c('activityID','activityName')
subjectTrain <-read.table("./train/subject_train.txt", header=FALSE)
subjectTest = read.table("./test/subject_test.txt",header = FALSE)
nrow(subjectTrain) #matches dimension of trainX at 7352 - links with trainX
nrow(subjectTest)  #matches dimesion of testX at 2947 - links with testX

2. Question 1: Merging

The merging was in stages. In both stages the first two columns were configured to have meaningfull names,
again this assisted in my seeing the structure clearly.
Finally the files was order on activity and volunteerID (subject) and the complete merge done


X<-merge(data.frame(trainy, row.names=NULL), data.frame(trainX, row.names=NULL), by = 0, all = TRUE)[-1]
X<-merge(data.frame(subjectTrain, row.names=NULL), data.frame(X, row.names=NULL), by = 0, all = TRUE)[-1] 
X<-X[order(X$V1.x, X$V1.y),] 

names(X)[1] <- "VolunteerID" 
names(X)[2] <- "activityID" 

#Merge testing sets, merage and order

Y<-merge(data.frame(testy, row.names=NULL), data.frame(testX, row.names=NULL), by = 0, all = TRUE)[-1]
Y<-merge(data.frame(subjectTest, row.names=NULL), data.frame(Y, row.names=NULL), by = 0, all = TRUE)[-1]

names(Y)[1] <- "VolunteerID"
names(Y)[2] <- "activityID"

#order
Y<-Y[order(Y$VolunteerID, Y$activityID),]

#Mearge two data sets.

XandY <- rbind(X, Y) #create the fully merged dataset holding both the test ad training data

3. Question 2 asked for a subset of the data set to be created by including only those variable names that 
included mean or std in the label name. And, to renames the resulting columns in the subset.

Firstly the variableNames (from activity list) were searched usiing grep to return the desired subset.
Secondly the subset of names were applied to the subsetted data set to be meaningful also.

meanStdSet<-variableNames[grep( "mean|std", variableNames[,2]), ]    
XandYSubSet<- XandY[,meanStdSet[,1]] 

4. Question 3 & 4 was achieved in the preceeding stages.

5. Question 5 average each variable and write new file

I reseasrched this topic with the view to using sapply and split. However, I could not get this to function.
Using a method found at these sites enabled the processing to be completed/
reference from https://stackoverflow.com/questions/30035592/taking-column-mean-over-a-list-of-data-frames-in-r using pipes
reference for summaris(z)e_each - which is hugely useful here. http://www.milanor.net/blog/aggregation-dplyr-summarise-summarise_each/

library(dplyr)
means<-XandYSubSet %>% 
  group_by(activityID, VolunteerID) %>% 
                                 summarise_each(funs(mean))
library(data.table)
write.table(means, "means.txr", row.names = FALSE) #fastest write function

FINISH

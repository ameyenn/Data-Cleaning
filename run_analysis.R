#Project week 4 Cleaning Data

#Written by Dr Andrew Meyenn, Date: 3/6/2020
#Purpose: Complition of Data Cleaning Course
#Program is divided in sections.

###SECTION A: download the Zip and unpack, set path and working Directory

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file( url, destfile = "dataFile.zip" )
unzip("dataFile.zip")
path<-"C:/Users/ameye/OneDrive/R/Coursera/Data Cleaning/Data/UCI HAR Dataset"
setwd(path)

#####SECTION B: read data files, check for missing data and inspect structure
#70% are Training data and 30% Testing data
#files are Test and Training sets for two groups: X and Y
#testX and testy are files contining results on numerious activities but each vounteer (1 to 30)
##the training and testing y list are the activities done (1 to 6), links with subject list ( 1 to 30)

testX <-read.table("./test/X_test.txt", header=FALSE)
ifelse (sum(is.na(testX)==0), print("file OK"), print("check file"))

testy <-read.table("./test/y_test.txt", header=FALSE)
ifelse (sum(is.na(testy)==0), print("file OK"), print("check file"))

trainX <-read.table("./train/X_train.txt", header=FALSE)
ifelse (sum(is.na(trainX)==0), print("file OK"), print("check file"))

trainy <-read.table("./train/y_train.txt", header=FALSE)
ifelse (sum(is.na(trainX)==0), print("file OK"), print("check file"))

####SECTION B: download and configure additional files as described in the Readme fil

###DOWNLOAD features.txt, this file holds the variable names of the various measurements, list as V1, V2 ..... in TextX and testX

variableNames<-read.table("features.txt")  
#check anything missing
ifelse (sum(is.na(variableNames)==0), print("file OK"), print("check file"))
#check structure
str(variableNames) #two dimesions, int and factor, factor is the names

####Configure the trainX and testX V1.... to meaningful variables names from variableNames[,2] ****QUESTION $*****

colnames(trainX) <- variableNames[,2] #set the V1, V2 .......col names to matching factor names
str(trainX) #col names are now meaningful                                                             
colnames(testX) <- variableNames[,2]

####DOWNLOAD and configure activities.txt file
#the activiaties are shown as ID = 1 Activity Name = WALKING etc there are 6 separate activities

actLables<-read.table("activity_labels.txt") #  #V1 (1,2,3,4,5,6) V2 Walking .. 6 different labels
ifelse (sum(is.na(actLables)==0), print("file OK"), print("check file"))

#### Configure the colnames to be meaningful, change the col names to activityID and activityName
colnames(actLables) <- c('activityID','activityName')

####DOWNLOAD the subject files

#subject files are avaliable for Test and Train data, both list sets of integer values 1 to 30, which correspond to the 30 volunteers (I assume).
#each contans 301 values eg for each 1, 2, 3 ...28,29,30 there are 301 values.
#It tunrs out this is just a list showing vol IDs 1 to 30
subjectTrain <-read.table("./train/subject_train.txt", header=FALSE)
subjectTest = read.table("./test/subject_test.txt",header = FALSE)

nrow(subjectTrain) #matches dimension of trainX at 7352 - links with trainX
nrow(subjectTest)  #matches dimesion of testX at 2947 - links with testX

####SECTION C Merge the full data set and configure columns 1 and 2. ****QUESTION 1****

####Merge training sets and merge and order

X<-merge(data.frame(trainy, row.names=NULL), data.frame(trainX, row.names=NULL), by = 0, all = TRUE)[-1]
X<-merge(data.frame(subjectTrain, row.names=NULL), data.frame(X, row.names=NULL), by = 0, all = TRUE)[-1] #add the volunteer index at the front
X<-X[order(X$V1.x, X$V1.y),] #sort by sample volunteer and then activity.

#### Configure frst two columns to facilitate names linking

names(X)[1] <- "VolunteerID" #change the name of first column to link to volunteers 1 to 30
names(X)[2] <- "activityID" #change the name of second column to link to activity

####Merge testing sets, merage and order

Y<-merge(data.frame(testy, row.names=NULL), data.frame(testX, row.names=NULL), by = 0, all = TRUE)[-1]
Y<-merge(data.frame(subjectTest, row.names=NULL), data.frame(Y, row.names=NULL), by = 0, all = TRUE)[-1]
####Confugre first two columns to facilitate names linking
names(Y)[1] <- "VolunteerID"
names(Y)[2] <- "activityID"

Y<-Y[order(Y$VolunteerID, Y$activityID),]


###Mearge two data sets.

XandY <- rbind(X, Y) #create the fully merged dataset holding both the test ad training data

#FINISH Question 1 ########

####SECTION D extract only column data that contians mean OR std and create a subset of the main data set  ****Quesiotn 2*****

meanStdSet<-variableNames[grep( "mean|std", variableNames[,2]), ]    #get the list of names with mean or std in them

XandYSubSet<- XandY[,meanStdSet[,1]] #also answers Q4 descriptive variable col names such as they are!

#FINISHED Q2######

####SECTION E Configure the index to reference the activity name and change to that name in column 2 of XandYSubSet data set 

#prototype  XandYSubset[, 2] <- index (actLables[,index])

XandYSubSet[,2]<-actLables[XandYSubSet[,2],]$activityName #seems to work!!

#####End Q3

####SECTION F *****NOTE**** Question 4 has already been completed above as indicated

####SECTION G 

#From the data set in step 4, create a second, independent tidy data set with the 
#average of each variable for each activity and each subject. Subjects do multiple activites of the same activity.
#so, group VolSubject, by ActivityID and Calculate the Mean for each. Split on subject, activity SApply ....., mean
#I did research on this aspect see references below.

#reference from https://stackoverflow.com/questions/30035592/taking-column-mean-over-a-list-of-data-frames-in-r using pipes
#reference for summaris(z)e_each - which is hugely useful here. http://www.milanor.net/blog/aggregation-dplyr-summarise-summarise_each/

library(dplyr)
means<-XandYSubSet %>% 
  group_by(activityID, VolunteerID) %>% 
                                 summarise_each(funs(mean))
library(data.table)
write.table(means, "means.txr", row.names = FALSE) #fastest write function

####END Q5#######


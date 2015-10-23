## This R file is created for the Getting and cleaning data cousera project.
## This file will download the file from the provided Link if the file does not exist in local repository and merges the Training and Test Data Set
## Requirement is to select only the mean and Standard deviation columns. So to select only the required columns feature vector is constructed and passed on
## while loading the data using read Table function.

## We will be using Library Reshape2 for preparing the tidy data so loading the library
library(reshape2)

filename <- "getdata_projectfiles_UCI HAR Dataset.zip"

## Download and unzip the dataset:
## Load the data only when the zip file does not exist in local directory. file will be downloaded in the working directory of Users desktop/laptop
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, filename)
} else{ print("File already exists")}

## if file does not exists in local machine, unzip the file
if (!file.exists("UCI HAR Dataset")) { 
    unzip(filename) 
}

# from the extracted zip file, load the Activity lables and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
## From the features loaded above using grep function select only all the mean and Std deviation features. 
## also construct proper feature names by using gsub function
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Load the training dataset from the file. use the featureswanted vector as an argument to select only the required fields from the file. 
# i.e. mean and standard deviation fiels
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test dataset from the file. use the featureswanted vector as an argument to select only the required fields from the file. 
# i.e. mean and standard deviation fiedls
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels. Since the Test and training data is identical we can easily merge the data using row bind operation instead of using Merge
# command
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
## Since the requirement is to group the data by Subject and Activity create factors with appropriate labels for further processing
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

## USe Melt and dcast functions to rearrange the data for taking mean of each of the required features grouped by Subject and Activity
allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

## Write the tidy data set in flat file by collecting only the column names and marking row names as FALSE
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE,sep=',')
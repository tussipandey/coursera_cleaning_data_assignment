library(curl)
library(reshape2)

if (!file.exists("getdata_dataset.zip")){
download.file(url='https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
              destfile='getdata_dataset.zip', method='curl')
}

if (!file.exists("UCI HAR Dataset")) { 
unzip("getdata_dataset.zip")
}
activity <-read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
features <-read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

reqfeatures <- grep(".*std.*|.*mean.*",features[,2])
reqfeatures.names <- features[reqfeatures,2]
reqfeatures.names <- gsub('[-()]','',reqfeatures.names)

training <- read.table("UCI HAR Dataset/train/X_train.txt")[reqfeatures]
act_training <- read.table("UCI HAR Dataset/train/y_train.txt")
sub_training <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(sub_training,act_training,training)

testing <- read.table("UCI HAR Dataset/test/X_test.txt")[reqfeatures]
act_testing <- read.table("UCI HAR Dataset/test/y_test.txt")
sub_testing <- read.table("UCI HAR Dataset/test/subject_test.txt")
testing <- cbind(sub_testing,act_testing,testing)

finaldata <- rbind(training,testing)
colnames(finaldata) <- c("Subject","Activity",reqfeatures.names)

finaldata$Activity <- factor(finaldata$Activity,levels =activity[,1],labels = activity[,2])
finaldata$Subject <- as.factor(finaldata$Subject)

finaldata.melted <- melt(finaldata,id = c("Subject", "Activity"))
finaldata.mean <- dcast(finaldata.melted,Subject + Activity ~ variable, mean)

write.table(finaldata.mean,"tidy.txt",row.names = FALSE,quote = FALSE)
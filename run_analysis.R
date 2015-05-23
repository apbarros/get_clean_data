#load necessary libraries
library(dplyr)


#first step is to load the variables to be used from the
#data files in a data frame with the column number and label

vartxt <-
"1 tBodyAccmeanX
2 tBodyAccmeanY
3 tBodyAccmeanZ
4 tBodyAccstdX
5 tBodyAccstdY
6 tBodyAccstdZ
41 tGravityAccmeanX
42 tGravityAccmeanY
43 tGravityAccmeanZ
44 tGravityAccstdX
45 tGravityAccstdY
46 tGravityAccstdZ
81 tBodyAccJerkmeanX
82 tBodyAccJerkmeanY
83 tBodyAccJerkmeanZ
84 tBodyAccJerkstdX
85 tBodyAccJerkstdY
86 tBodyAccJerkstdZ
121 tBodyGyromeanX
122 tBodyGyromeanY
123 tBodyGyromeanZ
124 tBodyGyrostdX
125 tBodyGyrostdY
126 tBodyGyrostdZ
161 tBodyGyroJerkmeanX
162 tBodyGyroJerkmeanY
163 tBodyGyroJerkmeanZ
164 tBodyGyroJerkstdX
165 tBodyGyroJerkstdY
166 tBodyGyroJerkstdZ
201 tBodyAccMagmean
202 tBodyAccMagstd
214 tGravityAccMagmean
215 tGravityAccMagstd
227 tBodyAccJerkMagmean
228 tBodyAccJerkMagstd
240 tBodyGyroMagmean
241 tBodyGyroMagstd
253 tBodyGyroJerkMagmean
254 tBodyGyroJerkMagstd
266 fBodyAccmeanX
267 fBodyAccmeanY
268 fBodyAccmeanZ
269 fBodyAccstdX
270 fBodyAccstdY
271 fBodyAccstdZ
345 fBodyAccJerkmeanX
346 fBodyAccJerkmeanY
347 fBodyAccJerkmeanZ
348 fBodyAccJerkstdX
349 fBodyAccJerkstdY
350 fBodyAccJerkstdZ
424 fBodyGyromeanX
425 fBodyGyromeanY
426 fBodyGyromeanZ
427 fBodyGyrostdX
428 fBodyGyrostdY
429 fBodyGyrostdZ
503 fBodyAccMagmean
504 fBodyAccMagstd
516 fBodyBodyAccJerkMagmean
517 fBodyBodyAccJerkMagstd
529 fBodyBodyGyroMagmean
530 fBodyBodyGyroMagstd
542 fBodyBodyGyroJerkMagmean
543 fBodyBodyGyroJerkMagstd"
#write the content above in a tempfile and read it in a data frame
tf <- tempfile()
writeLines(vartxt, tf)
variables <- read.csv(tf, sep=" ", header = FALSE)

# variables now have the column numbers and the variable names

# now, read the data sets, labels and subjects of the records

testset <- read.table(".\\test\\X_test.txt", header = FALSE, quote = "\"")
testlabels <- read.csv(".\\test\\Y_test.txt", header = FALSE)
testsbj <- read.csv(".\\test\\subject_test.txt", header = FALSE)

trainset <- read.table(".\\train\\X_train.txt", header = FALSE, quote = "\"")
trainlabels <- read.csv(".\\train\\Y_train.txt", header = FALSE)
trainsbj <- read.csv(".\\train\\subject_train.txt", header = FALSE)

## now iterate through the data sets to create a subset with the right column names
vnumbers <- variables[[1]]
vnames <- variables[[2]]
cleantestset <- select(testset, vnumbers)
cleantrainset <- select (trainset, vnumbers)
colnames(cleantestset) <- vnames
colnames(cleantrainset) <- vnames

#append subjects and activity labels
cleantestset$subject <- testsbj[[1]]
cleantrainset$subject <- trainsbj[[1]]

cleantestset$activity <- testlabels[[1]]
cleantrainset$activity <- trainlabels[[1]]

#replace the numeric labels by activity labels

actlabels <- read.csv(".\\activity_labels.txt", sep=" ", header=FALSE)
labelvector <- actlabels[[2]]
cleantestset <- mutate(cleantestset, activitylabel = labelvector[activity])

#ok, now merge the two data sets, less the activity numeric column

completedataset <- rbind_list(select(cleantestset, -activity), select(cleantrainset, -activity))

##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
## will use dplyr for this

newdset <- group_by(completedataset, subject, activitylabel)
finalset <- summarise_each(newdset, funs(mean))

write.table(finalset, file="output.txt", row.names=FALSE)

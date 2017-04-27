library(randomForest)
library(randomForestSRC)
library(caret)
library(rpart)
library(rattle)
library(rpart.plot)
library("Metrics")
setwd("~/Desktop/Proj5")
data<-read.csv("HR_comma_sep.csv",header = T)
#add level to ppl left  1 means ppl left 0 means ppl stay

data$left[data$left == 1] <- "Left" ;data$left[data$left == 0] <- "Remain"
data$left <- as.factor(data$left)
#ordered the salary
data$salary <- ordered(data$salary, c("low", "medium", "high"))


per_train <- 0.75 # percentage of training data
smp_size <- floor(per_train * nrow(data)) # size of the sample
set.seed(111) #set seed
index <- sample(seq_len(nrow(data)), size = smp_size) # train index for red wine

#split the data into train and test
data.train<-data[index,]
data.test<-data[-index,]

#col index for ppl left
which(colnames(data.train)=="left")

Y.train<-data.train$left
X.train<-data.train[,-which(colnames(data.train)=="left")]
Y.test<-data.test$left
X.test<-data.test[,-which(colnames(data.train)=="left")]

# decisionTreeModel <- train(left~.,method="rpart",data=data.train) 
# fancyRpartPlot(decisionTreeModel$finalModel)
# pred_tree <- predict(decisionTreeModel,X.test)
# mean(pred_tree == Y.test)

tree.model <- rpart(left ~ ., data = data.train)
tree.predict <- predict(tree.model, data.test)
#accuracy
auc(as.numeric(Y.test) - 1, tree.predict[, 2])
# ?auc
# pred<-as.numeric(round(tree.predict)[,2])
# mean(as.numeric(Y.test) - 1 == pred)

rpart.plot(tree.model, type = 2, fallen.leaves = F, cex = 0.8, extra = 2)


####random forest###
randomforest.Model <- randomForest(left~ .,data.train,ntree=30)
randomforest.predict <- predict(randomforest.Model,data.test)
mean(randomforest.predict == Y.test)

head(data.test)

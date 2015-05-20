
standardize<-function(data){
  #standardize the data
  data.new<-data[,-12]
  col.mean<-colMeans(data.new)
  for (colm in 1:length(col.mean)){
    for (i in 1:length(data[,1])){
      data.new[i, colm] <- (data.new[i, colm] - col.mean[colm]) / sd(data.new[,colm]) 
    }
  }
  Quality <-data$Quality
  data.new<-cbind(data.new, Quality)
  
  test<-rep(NA, 3)
  data.all<-data.frame(test)
  for (i in 1:(length(colnames(data.new))-1)){
    k=aggregate(data.new[,i]~Quality, data.new, mean)
    data.all<-data.frame(data.all, k[,2])
  }
  data.all<-data.all[,-1]
  data.all<-data.frame(data.all, k[,1])
  colnames(data.all)<-colnames(data.new)

  return (data.all)}
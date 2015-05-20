#Author: Yi He
#Data Visualization Project Prototype Server.R

library(ggplot2)
library(shiny)
library(scales)
library(grid)
library(GGally)
library(randomForest)
library(gridExtra)
library(MASS)
library(klaR)
library(cluster)

#setwd('C:/Users/yh/Desktop/DataVisualization/Project')

loadData <- function(){
  white.wine<-read.csv('winequality-white.csv',sep=";",header=TRUE)
  quality.type <- rep(NA, nrow(white.wine))
  quality <- white.wine$quality
  quality.type[which(quality ==3)] = "Low"
  quality.type[which(quality ==4)] = "Low"
  quality.type[which(quality ==5)] = "Medium"
  quality.type[which(quality ==6)] = "Medium"
  quality.type[which(quality ==7)] = "Medium"
  quality.type[which(quality ==8)] = "High"
  quality.type[which(quality ==9)] = "High"
  white.wine$quality <- as.factor(quality.type)
  white.wine <- white.wine[rowSums(is.na(white.wine)) != ncol(white.wine),]
  white.col <- colnames(white.wine)
  data.low<-white.wine[ sample( which( white.wine$quality == "Low" ) , 180 ) , ]
  data.med<-white.wine[ sample( which( white.wine$quality == "Medium" ) , 180 ) , ]
  data.high<-white.wine[ sample( which( white.wine$quality == "High" ) , 180 ) , ]
  white.wine <- data.frame(rbind(data.low, data.med, data.high))
  colnames(white.wine) <- white.col
  return (white.wine)
}

bublePlot <- function(data, xVar, yVar, xlim, ylim, highl, fitYes, sizeDot, alphaS){
  
  if (xVar == yVar){
    anontateText<-paste("Please Pick Different Variables for X-axis and Y-axis")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=13, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
    
  }
  
  data<-as.data.frame(data[ , which(names(data) %in% c(xVar,yVar, 'Quality'))])
  colnames(data) <-c('One', 'Two', 'Quality')
  #change data into quantile
  data<-data[data$One>quantile(data$One, xlim[1]),]
  data<-data[data$One<quantile(data$One, xlim[2]),]
  data<-data[data$Two>quantile(data$Two, ylim[1]),]
  data<-data[data$Two<quantile(data$Two, ylim[2]),]
  
  p.b <- ggplot(data,aes(x = One,y = Two,color = Quality))
  p.b <- p.b  + geom_point (alpha=alphaS, position = 'jitter', size=sizeDot)   
  p.b <- p.b + labs(color='Wine Quality')+ labs(size='Wine Quality')
  p.b <- p.b + scale_y_continuous(limits=c(min(data$Two)-0.2*min(data$Two), max(data$Two)+.2*max(data$Two)),expand=c(0,0))
  p.b <- p.b + scale_x_continuous(limits=c(min(data$One)-0.2*min(data$One), max(data$One)+.2*max(data$One)),expand=c(0,0))
  p.b <- p.b + xlab(xVar)
  p.b <- p.b + ylab(yVar)
  p.b <- p.b + theme(panel.background = element_rect(fill = NA))
  p.b <- p.b + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.b <- p.b + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  title <- paste(xVar, 'vs.', yVar)
  p.b <- p.b + ggtitle(title)
  
  palette <- brewer_pal(type='qual', palette='Set1')(3)
  qualities <- levels(data$Quality)
  palette[which(!qualities %in% highl)] <- "#EEEEEE"
  p.b <- p.b + scale_color_manual(values=palette)
  
  p.b <- p.b + theme(text=element_text(size=16, color='black'))
  if (fitYes==TRUE){
    p.b<-p.b+geom_smooth(aes(x=One, y=Two), method=lm, linetype=1,size = 1, colour = "black", se = TRUE, stat = "smooth")
  }
  
  return (p.b)
}

histPlot <- function(data, xVar, yVar, xlim, ylim, highl){
  if (xVar == yVar){
    anontateText<-paste("Please Pick Different Variables for X-axis and Y-axis")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=13, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
    
  }
  data<-as.data.frame(data[ , which(names(data) %in% c(xVar,yVar, 'Quality'))])
  colnames(data) <-c('One', 'Two', 'Quality')
  #change data into quantile
  data<-data[data$One>quantile(data$One, xlim[1]),]
  data<-data[data$One<quantile(data$One, xlim[2]),]
  data<-data[data$Two>quantile(data$Two, ylim[1]),]
  data<-data[data$Two<quantile(data$Two, ylim[2]),]
  
  p1 <- ggplot(data, aes(One, fill=Quality))
  p1 <- p1+geom_density(alpha=0.2)
  p1 <- p1 + theme(panel.background = element_rect(fill = NA))
  p1 <- p1 + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p1 <- p1 + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  p1 <- p1 + scale_x_continuous(name = xVar)
  p1 <- p1 + guides(fill=guide_legend(title="Wine Quality"))
  palette <- brewer_pal(type='qual', palette='Set1')(3)
  qualities <- levels(data$Quality)
  palette[which(!qualities %in% highl)] <- "#EEEEEE"
  p1 <- p1 + scale_fill_manual(values=palette)
  p1 <- p1 + theme(text=element_text(size=18, color='black'))
  
  p2 <- ggplot(data, aes(Two, fill=Quality))
  p2 <- p2 + geom_density(alpha=0.2)
  p2 <- p2 + theme(panel.background = element_rect(fill = NA))
  p2 <- p2 + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p2 <- p2 + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  p2 <- p2 + scale_x_continuous(name = yVar)
  p2 <- p2 + guides(fill=guide_legend(title="Wine Quality"))
  palette <- brewer_pal(type='qual', palette='Set1')(3)
  qualities <- levels(data$Quality)
  palette[which(!qualities %in% highl)] <- "#EEEEEE"
  p2 <- p2 + scale_fill_manual(values=palette)
  p2 <- p2 + theme(text=element_text(size=18, color='black'))
  
  p<-grid.arrange(p1, p2, ncol=2, sub = textGrob("Quality Histogram", gp=gpar(fontsize=30)))

  return (p)
}

heatPlot <- function(data,includeLow, includeMedium, includeHigh,typeVec, colorS){
  
  if (includeLow ==FALSE){data.n<-subset(data, data$Quality!='Low')}
  else if (includeLow==TRUE){data.n <- data}
  
  if (includeMedium ==FALSE){data.ne<-subset(data.n, data.n$Quality!='Medium')}
  else if (includeMedium==TRUE) {data.ne <- data.n}
  
  if (includeHigh ==FALSE){data.new<-subset(data.ne, data.ne$Quality!='High')}
  else if (includeHigh==TRUE) {data.new <- data.ne}
  
  if (includeHigh ==FALSE & includeLow ==FALSE & includeHigh ==FALSE){
    anontateText<-paste("Please pick more than 1 Type of Wine")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
  
  typeVec.new <-as.numeric(typeVec)
  typeNames <-c('FixedAcidity','VolatileAcidity','CitricAcid','ResidualSugar','Chlorides','FreeSulfurDioxide','TotalSulfurDioxide',
                'Density','pH', 'Sulphates','Alcohol')
  colnames<-cbind(typeNames[typeVec.new], 'Quality')
  data.new <- data.new[, colnames(data.new)%in%colnames]
    if (length(colnames(data.new))==0){
    anontateText<-paste("Please pick more than 1 Type")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
  col.names<-colnames(data.new)
  data.new.scale<-scale(data.new[,1:(length(data.new)-1)])
  data.new.melt<-data.frame(data.new.scale, Quality=data.new$Quality)
  colnames(data.new.melt) <- col.names
  molten <- melt(data.new.melt, id=c('Quality'))
  p.heat <- ggplot(subset(molten),aes(x=variable, y=Quality)) 
  p.heat <- p.heat + geom_tile(aes(fill = value), colour = "white") 
  p.heat <- p.heat + scale_x_discrete(name = "Wine Quality",expand = c(0, 0))
  p.heat <- p.heat + scale_y_discrete(expand = c(0, 0))
  p.heat <- p.heat +  theme(axis.text.y = element_text(angle = 90,hjust = 0.5),
                            axis.ticks = element_blank(),
                            axis.title = element_blank(),
                            legend.direction = "vertical",
                            legend.position = "right",
                            panel.background = element_blank())
  p.heat <- p.heat + coord_fixed(ratio = 1)
  p.heat <- p.heat + scale_fill_gradientn(colours = brewer_pal(type = "div", palette = colorS)(5),name = "Gradient")
  p.heat <- p.heat + theme(axis.text.y=element_text(size=16, color='black', angle=0))
  p.heat <- p.heat + theme(axis.text.x=element_text(size=16, color='black', angle=90))
  p.heat <- p.heat + ggtitle('Wine Quality vs. Wine Features')
  return(p.heat)
}

paraPlot <- function(data,includeLow, includeMedium, includeHigh,typeVec, colorS){
  
  if (includeLow ==FALSE | includeMedium == FALSE | includeHigh == FALSE){
    anontateText<-paste("Please pick all 3 Types of Wine \n
                         for Parallel Coordinate Plot")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)  
  }
  
  if (includeHigh ==FALSE & includeLow ==FALSE & includeHigh ==FALSE){
    anontateText<-paste("Please pick more than 1 Type of Wine")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
    
  data.new<-data
  typeVec.new <-as.numeric(typeVec)
  typeNames <-c('FixedAcidity','VolatileAcidity','CitricAcid','ResidualSugar','Chlorides','FreeSulfurDioxide','TotalSulfurDioxide',
                'Density','pH', 'Sulphates','Alcohol')
  colnames<-cbind(typeNames[typeVec.new], 'Quality')
  data.new <- data.new[, colnames(data.new)%in%colnames]
    
  if (length(colnames(data.new))==0 | length(colnames(data.new))==2){
    anontateText<-paste("Please pick more than 2 Type")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }  
  p.plot <- ggparcoord(data =data.new,                 
                   columns = 1:(length(colnames(data.new))-1),groupColumn = length(colnames(data.new)),                 
                   order = "anyClass",showPoints = TRUE,alphaLines = 0.6,shadeBox = NULL,               
                   scale = "uniminmax" )
  p.plot <- p.plot + theme_minimal()
  p.plot <- p.plot + scale_y_continuous(expand = c(0.02, 0.02))
  p.plot <- p.plot + scale_x_discrete(expand = c(0.02, 0.02))
  p.plot <- p.plot + theme(axis.ticks = element_blank())
  p.plot <- p.plot + theme(axis.title = element_blank())
  p.plot <- p.plot + theme(axis.text.y = element_blank())
  p.plot <- p.plot + theme(panel.grid.minor = element_blank())
  p.plot <- p.plot + theme(panel.grid.major.y = element_blank())
  p.plot <- p.plot + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))
  p.plot <- p.plot + theme(legend.position = "bottom")
  p.plot <- p.plot + theme(text=element_text(size=16, color='black'))
  palette<-brewer_pal(type="qual",palette=colorS)(3)
  p.plot <-p.plot + scale_color_manual(values=palette)
  p.plot <- p.plot + ggtitle('Quality of Wine through Features')
  
  return(p.plot)
  
}

modelPlot <- function(data, include, sampleSize, node, ntree){

  if (include ==FALSE){data.new<-droplevels(subset(data, data$Quality=='High' | data$Quality=='Low'))
                       types <-c('High', 'Low')}
  else {data.new <- droplevels(data)
        types <-c('High', 'Low', 'Medium')}
  model <- randomForest(Quality ~., samplesize=sampleSize, nodesize=node, ntree=ntree,data=data.new, importance=TRUE) 
  index <- names(varImpPlot(model)[,1])
  variable<-as.data.frame(varImpPlot(model))
  data.var<-data.frame(Feature=index, Importance=variable[,1])
  data.var<-data.var[with(data.var, order(Importance)),]
  p.var<-ggplot(data.var)
  p.var<-p.var+geom_bar(aes(x=Feature, y=Importance), stat='identity', fill='blue', color='red')
  p.var<-p.var+coord_flip()+scale_fill_brewer()
  p.var <- p.var + theme(panel.background = element_rect(fill = NA))
  p.var <- p.var + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.var <- p.var + scale_y_continuous(expand=c(0,0))
  p.var <- p.var + ggtitle('Variable Importance')
  p.var <- p.var + theme(text=element_text(size=18, color='black'))
  
  data.err<-data.frame(model$confusion)
  
  data.err<-data.frame(Type=types, Error = unlist(lapply(data.err$class.error, function(x) 1-x)))
  p.err <- ggplot(data.err)
  p.err <- p.err+geom_bar(aes(x=Type, y=Error), stat='identity', fill='red', color='blue')
  p.err <- p.err + theme(panel.background = element_rect(fill = NA))
  p.err <- p.err + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.err <- p.err + scale_y_continuous(expand=c(0,0), limits=c(0,1))
  p.err <- p.err + ggtitle('Accuracy')
  p.err <- p.err + theme(text=element_text(size=18, color='black'))
  p.err <- p.err + ylab('Accuracy')
  p.err <- p.err + xlab('Quality')
  
  p<-grid.arrange(p.err, p.var, ncol=2, sub = textGrob("Accuracy Model", gp=gpar(fontsize=30)))
  return(p)
  
  
}

##principal component and factor analysis plots

pcaText<-function(data, includeLow, includeMedium, includeHigh){  
  if (includeLow ==FALSE){data.n<-subset(data, data$Quality!='Low')}
  else if (includeLow==TRUE){data.n <- data}
  
  if (includeMedium ==FALSE){data.ne<-subset(data.n, data.n$Quality!='Medium')}
  else if (includeMedium==TRUE) {data.ne <- data.n}
  
  if (includeHigh ==FALSE){data.new<-subset(data.ne, data.ne$Quality!='High')}
  else if (includeHigh==TRUE) {data.new <- data.ne}
  
  if (length(data.new[,1])==0){
    x=paste('Please Select At Least One Quality of Wine')
    p<-data.frame(x)
    return(p)
  }
  fit.pc<-princomp(data.new[,1:11], data=data.new)
  pc.out<-data.frame(Loading1<-fit.pc$loadings[,1], Loading2<-fit.pc$loadings[,2], Loading3<-fit.pc$loadings[,3],
                     Loading4<-fit.pc$loadings[,4], Loading5<-fit.pc$loadings[,5], Loading6<-fit.pc$loadings[,6],
                     Loading7<-fit.pc$loadings[,7], Loading8<-fit.pc$loadings[,8], Loading9<-fit.pc$loadings[,9],
                     Loading10<-fit.pc$loadings[,10],Loading11<-fit.pc$loadings[,11])
  colnames(pc.out)<-c('Loading 1','Loading 2','Loading 3','Loading 4','Loading 5','Loading 6','Loading 7','Loading 8',
                      'Loading 9','Loading 10','Loading 11')
  return(pc.out)
}

pcaPlot<-function(data, xVar, yVar, includeLow, includeMedium, includeHigh, sizeD, alphaL){

  if (includeLow ==FALSE){data.n<-subset(data, data$Quality!='Low')}
  else if (includeLow==TRUE){data.n <- data}
  
  if (includeMedium ==FALSE){data.ne<-subset(data.n, data.n$Quality!='Medium')}
  else if (includeMedium==TRUE) {data.ne <- data.n}

  if (includeHigh ==FALSE){data.new<-subset(data.ne, data.ne$Quality!='High')}
  else if (includeHigh==TRUE) {data.new <- data.ne}
  
  if (length(data.new[,1])==0){
    anontateText<-paste("Please pick more than 1 Quality Type")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
  
  fit.pc<-princomp(data.new[,1:11], data=data.new)
  
  if(xVar=='Score1'){x=1} else if(xVar=='Score2'){x=2}else if(xVar=='Score3'){x=3}else if(xVar=='Score4'){x=4}else if(xVar=='Score5'){x=5}
  else if(xVar=='Score6'){x=6}else if(xVar=='Score7'){x=7}else if(xVar=='Score8'){x=8}else if(xVar=='Score9'){x=9}else if(xVar=='Score10'){x=10}
  else if(xVar=='Score11'){x=11}
  
  if(yVar=='Score1'){y=1}else if(yVar=='Score2'){y=2}else if(yVar=='Score3'){y=3}else if(yVar=='Score4'){y=4}else if(yVar=='Score5'){y=5}
  else if(yVar=='Score6'){y=6}else if(yVar=='Score7'){y=7}else if(yVar=='Score8'){y=8}else if(yVar=='Score9'){y=9}else if(yVar=='Score10'){y=10}
  else if(yVar=='Score11'){y=11}
  
  fit.pc<-princomp(data.new[,1:11], data=data.new)
  pc.out<-capture.output(fit.pc$loadings)
  pc.df<-data.frame(scoreX=fit.pc$scores[,x], scoreY=fit.pc$scores[,y],as.factor(data.new$Quality))
  colnames(pc.df) <- c('scoreX', 'scoreY', 'Quality')
  pc.plot <- ggplot(pc.df, aes(x=scoreX, y=scoreY, color=Quality))
  pc.plot <- pc.plot + geom_point(alpha=alphaL, position = 'jitter', size=sizeD)
  pc.plot <- pc.plot + labs(color='Quality')
  pc.plot <- pc.plot + theme(panel.background = element_rect(fill = NA))
  pc.plot <- pc.plot + theme(panel.grid.major = element_line(color='grey', linetype=1))
  pc.plot <- pc.plot + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  pc.plot <- pc.plot + xlab(xVar) + ylab(yVar) + ggtitle ('Principal Component Analysis')
  pc.plot <- pc.plot + theme(text=element_text(size=20, color='black'))
  
  pc.load.df <- data.frame(Load1=abs(fit.pc$loadings[,x]), Load2 = abs(fit.pc$loadings[,y]), Names=rownames(fit.pc$loadings))
  pc.molten <- melt(pc.load.df, id=c('Names'))
  colnames(pc.molten) <- c('Names', 'Loading', 'values')
  pc.load.plot <- ggplot(pc.molten)
  pc.load.plot <- pc.load.plot+geom_bar(aes(x=Names, y=values, fill=Loading),stat='identity', position='dodge')
  pc.load.plot <- pc.load.plot +  coord_flip()
  pc.load.plot <- pc.load.plot + xlab('Feature Names') + ylab('Loading Values') + ggtitle ('Principal Component Loading Weights')
  pc.load.plot <- pc.load.plot + theme(panel.background = element_rect(fill = NA))
  pc.load.plot <- pc.load.plot + theme(panel.grid.major = element_line(color='grey', linetype=1))
  pc.load.plot <- pc.load.plot + theme(panel.grid.minor = element_line(color='grey', linetype=2)) 
  pc.load.plot <- pc.load.plot + theme(text=element_text(size=20, color='black'))
  pc<-grid.arrange(pc.plot, pc.load.plot, ncol=2, sub = textGrob("Principal Component Analysis", gp=gpar(fontsize=30)))
  return(pc)  
  
}

faText<-function(data, includeLow, includeMedium, includeHigh){
  if (includeLow ==FALSE){data.n<-subset(data, data$Quality!='Low')}
  else if (includeLow==TRUE){data.n <- data}
  
  if (includeMedium ==FALSE){data.ne<-subset(data.n, data.n$Quality!='Medium')}
  else if (includeMedium==TRUE) {data.ne <- data.n}
  
  if (includeHigh ==FALSE){data.new<-subset(data.ne, data.ne$Quality!='High')}
  else if (includeHigh==TRUE) {data.new <- data.ne}
  
  if (length(data.new[,1])==0){
    x=paste('Please Select At Least One Quality of Wine')
    p<-data.frame(x)
    return(p)
  }
  
  fit.fact<-factanal(data.new[,1:11],factors=6, data=data.new, scores=c('regression'), rotation='varimax')
  
  fact.out<-data.frame(Loading1<-fit.fact$loadings[,1], Loading2<-fit.fact$loadings[,2], Loading3<-fit.fact$loadings[,3],
                     Loading4<-fit.fact$loadings[,4], Loading5<-fit.fact$loadings[,5], Loading6<-fit.fact$loadings[,6])
  colnames(fact.out)<-c('Loading 1','Loading 2','Loading 3','Loading 4','Loading 5','Loading 6')
  return(fact.out)
  
}

faPlot<-function(data, xVar, yVar, includeLow, includeMedium, includeHigh,sizeD, textSize, alphaL){
  
  if (includeLow ==FALSE){data.n<-subset(data, data$Quality!='Low')}
  else if (includeLow==TRUE){data.n <- data}
  
  if (includeMedium ==FALSE){data.ne<-subset(data.n, data.n$Quality!='Medium')}
  else if (includeMedium==TRUE) {data.ne <- data.n}
  
  if (includeHigh ==FALSE){data.new<-subset(data.ne, data.ne$Quality!='High')}
  else if (includeHigh==TRUE) {data.new <- data.ne}
  
  if (length(data.new[,1])==0){
    anontateText<-paste("Please pick more than 1 Quality Type")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
  
  if (xVar=='Score7'| xVar=='Score8'| xVar=='Score9'|xVar=='Score10'|xVar=='Score11'|
      yVar=='Score7'| yVar=='Score8'| yVar=='Score9'|yVar=='Score10'|yVar=='Score11'){
    anontateText<-paste("Factor Analysis Only Allow 6 Factors \n
                         Please Pick Between Score 1 to Score 6")
    data.new <- data.frame()
    p <- ggplot(data.new) + geom_point() + xlim(0,10) + ylim(0,10)
    p <- p + annotate('text', x=5, y=5, color='black', size=15, label=anontateText)
    p <- p + theme(panel.background = element_rect(fill = NA))
    p <- p + theme(line = element_blank(),text = element_blank(),line = element_blank(),
                   title = element_blank())
    return(p)
  }
    
  if(xVar=='Score1'){x=1} else if(xVar=='Score2'){x=2}else if(xVar=='Score3'){x=3}else if(xVar=='Score4'){x=4}else if(xVar=='Score5'){x=5}
  else if(xVar=='Score6'){x=6}else if(xVar=='Score7')
        
  if(yVar=='Score2'){print('this is working')}
    
  if(yVar=='Score1'){y=1}else if(yVar=='Score2'){y=2}else if(yVar=='Score3'){y=3}else if(yVar=='Score4'){y=4}else if(yVar=='Score5'){y=5}
  else if(yVar=='Score6'){y=6}
  
  fit.fact<-factanal(data.new[,1:11],factors=6, data=data.new, scores=c('regression'), rotation='varimax')
  fact.df=data.frame(Score1=fit.fact$score[,x], Score2=fit.fact$score[,y], Quality=data.new$Quality)
  fact.plot <- ggplot(fact.df, aes(x=Score1, y=Score2, color=Quality))
  fact.plot <- fact.plot + geom_point(alpha=alphaL, position = 'jitter', size=sizeD)
  fact.plot <- fact.plot + xlab(xVar) + ylab(yVar) + ggtitle ('Factor Analysis')
  fact.plot <- fact.plot + theme(panel.background = element_rect(fill = NA))
  fact.plot <- fact.plot + theme(panel.grid.major = element_line(color='grey', linetype=1))
  fact.plot <- fact.plot + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  fact.plot <- fact.plot + labs(color='Quality')
  fact.plot <- fact.plot + theme(text=element_text(size=20, color='black'))
    
  fact.factors.df <- data.frame(Factor1 = fit.fact$loadings[,x], Factor2=fit.fact$loadings[,y])  
  fact.factors <- ggplot(fact.factors.df, aes(x=Factor1, y=Factor2))
  fact.factors <- fact.factors + geom_point(alpha=0.6, position = 'jitter', size=1)
  fact.factors <- fact.factors + xlab(xVar) + ylab(yVar) + ggtitle ('Factor Analysis - Features')
  print(rownames(fact.factors.df))
  fact.factors <- fact.factors + geom_text(aes(label=c("FixedAcidity","VolatileAcidity","CitricAcid","ResidualSugar","Chlorides","FreeSulfurDioxide","TotalSulfurDioxide",
                                                       "Density", "pH"   ,"Sulphates" ,"Alcohol" )), size=textSize, color='black')
  fact.factors <- fact.factors + theme(text=element_text(size=20, color='black'))
  fact.factors <- fact.factors + theme(panel.background = element_rect(fill = NA))
  fact.factors <- fact.factors + scale_x_continuous (limits=c(min(fact.factors.df$Factor1)-0.5*min(fact.factors.df$Factor1)
                                                              ,max(fact.factors.df$Factor1)+0.5*max(fact.factors.df$Factor1)), expand=c(0,0))
  fact.factors <- fact.factors + scale_y_continuous (limits=c(min(fact.factors.df$Factor2)-0.5*min(fact.factors.df$Factor2)
                                                             ,max(fact.factors.df$Factor2)+0.5*max(fact.factors.df$Factor2)), expand=c(0,0))
  
  fa<-grid.arrange(fact.plot, fact.factors, ncol=2, sub=textGrob('Factor Analysis', gp=gpar(fontsize=30)))
  return(fa)
  
}


globalData<-loadData()

shinyServer(function(input, output){
  
  cat("Press \"ESC\" to exit...\n")
  globalData
  data <- reactive({
    colnames(globalData) <-c('FixedAcidity', 'VolatileAcidity','CitricAcid', 'ResidualSugar','Chlorides', 'FreeSulfurDioxide',
                       'TotalSulfurDioxide', 'Density','pH', 'Sulphates', 'Alcohol', 'Quality')
    return(globalData)})
  
  
  output$bubPlot <- renderPlot({
    bubPlot <- bublePlot(
      data=data(), xVar=input$xUI, yVar=input$yUI, xlim=input$xlimUI, ylim=input$ylimUI, highl=input$highlightUI, fitYes=input$fitUI,
      sizeDot=input$sizeUI, alphaS = input$alphaSUI
    )
    print(bubPlot)
  }, width=1000,height=700)
    
  
  output$histPlot <- renderPlot({
    histPlot <- histPlot(data=data(), xVar=input$xUI, yVar=input$yUI, xlim=input$xlimUI, ylim=input$ylimUI, highl=input$highlightUI
    )
    print(histPlot)
  }, width=1000, height=700)
  
  output$heatPlot <- renderPlot({
    heatPlot <- heatPlot(data=data(), typeVec=input$typeUI,includeLow = input$dLowUI, includeMedium = input$dMediumUI, includeHigh = input$dHighUI,
                         colorS=input$colorUI
    )
    print(heatPlot)
  }, width=1000, height=800)
  
  output$paraPlot <-renderPlot({
    paraPlot <- paraPlot(data=data(), typeVec=input$typeUI,includeLow = input$dLowUI, includeMedium = input$dMediumUI, includeHigh = input$dHighUI,
                         colorS = input$colorUI)
    print(paraPlot)
  }, width=1000, height=800)
  
  output$modelPlot <- renderPlot({
    modelPlot <- modelPlot(data=data(), include = input$rMediumUI, 
                           sampleSize=input$sampleUI, node=input$nodeUI, ntree=input$treeUI
    )
    print(modelPlot)
  }, width=1000, height=500)
  
  output$pcaTable <- renderTable({
    pcaTable<- pcaText(data=data(), includeLow = input$pLowUI, includeMedium = input$pMediumUI, includeHigh = input$pHighUI)
    print(pcaTable)
  }, width=1500, height=500)
  
  output$pcaPlot <- renderPlot({
    pcaPlot<- pcaPlot(data=data(), xVar=input$xpcaUI, yVar=input$ypcaUI,
                      includeLow = input$pLowUI, includeMedium = input$pMediumUI, includeHigh = input$pHighUI,
                      sizeD=input$sizePCAUI, alphaL=input$alphaUI)
    print(pcaPlot)
  }, width=1500, height=1000)
  
  output$faPlot <- renderPlot({
    faPlot<- faPlot(data=data(), xVar=input$xpcaUI, yVar=input$ypcaUI,
                      includeLow = input$pLowUI, includeMedium = input$pMediumUI, includeHigh = input$pHighUI,
                      sizeD=input$sizePCAUI, textSize = input$sizeFAUI, alphaL=input$alphaUI)
    print(faPlot)
  }, width=1500, height=1000)
  
  output$faTable <-renderTable({
    faTable<- faText(data=data(), includeLow = input$pLowUI, includeMedium = input$pMediumUI, includeHigh = input$pHighUI)
    print(faTable)
  }, width=1500, height=500)
  
  
  
  
})
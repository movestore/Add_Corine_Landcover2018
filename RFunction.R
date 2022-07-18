library('move')
library('raster')
library('foreign')

rFunction <- function(data,stats=FALSE)
{
  Sys.setenv(tz="UTC")
  
  #GDALinfo("CLC2018_CLC2018_V2018_20.tif")
  corineT <- raster("CLC2018_CLC2018_V2018_20.tif")
  #summary(corine,maxsamp=100)
  #crs(corine)
  
  dataT <- spTransform(data,CRSobj=crs(corineT))
  corineTC <- crop(corineT, extent(dataT))
  corine <- projectRaster(corineTC,crs=crs(data),method="ngb")
  
  data <- extract(corine,data,method="simple",sp=TRUE)
  
  corineClasses <- read.dbf("CLC2018_CLC2018_V2018_20.tif.vat.dbf",as.is=TRUE)
  corine.landcover <- character(length(data))
  uclasses <- unique(data@data$CLC2018_CLC2018_V2018_20)
  for (i in seq(along=uclasses))
  {
    if (is.na(uclasses[i])) corine.landcover[which(is.na(data@data$CLC2018_CLC2018_V2018_20))] <- NA else
    {
      corine.landcover[which(data@data$CLC2018_CLC2018_V2018_20==uclasses[i])] <- corineClasses$LABEL3[corineClasses$Value==uclasses[i]]
    }
  }
  data@data$corine.landcover <- corine.landcover

  data.split <- move::split(data)
  
  pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Corine_Landcover_Barplots.pdf"))
  lapply(data.split, function(datai)
    {
    par(mar=c(15,6,4,2))
    barplot(table(datai@data$corine.landcover),col="blue",las=2,main=namesIndiv(datai),ylab="frequency")
  })
  barplot(table(data@data$corine.landcover),col="red",las=2,main="all tracks",ylab="frequency")
  dev.off()  
  
  pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Corine_Landcover_Maps.pdf"))
  lapply(data.split, function(datai)
  {
    corinei <- crop(corine,extent(datai))
    plot(corinei,axes=FALSE,legend=FALSE,main=namesIndiv(datai))
    lines(coordinates(datai),col="darkgray")
    points(coordinates(datai),col="blue",pch=20)
  })
  dev.off()
  
  if(stats==TRUE)
  {
    corine_table <- data.frame("trackId"=character(),"corine.landcover"=character(),"n.pts"=numeric(),"prop.pts"=numeric(),"prop.dur"=numeric())
    
    corine_table_list <- lapply(data.split, function(datai)
    {
      tabi <- table(datai$corine.landcover)
      ni <- as.numeric(tabi)
      LCi <- names(tabi)
      
      propptsi <- ni/sum(ni,na.rm=TRUE)
      propduri <- apply(matrix(LCi),1,function(x) sum(datai@data$timelag[datai@data$corine.landcover==x],na.rm=TRUE)/sum(datai@data$timelag,na.rm=TRUE))
      data.frame("trackId"=namesIndiv(datai),"corine.landcover"=LCi,"n.pts"=ni,"prop.pts"=propptsi,"prop.dur"=propduri)
    })
    corine_table <- do.call("rbind", corine_table_list)
    
    uLC <- sort(unique(data@data$corine.landcover))
    nLC <- length(uLC)
    n.all <- avg.pt <- avg.dur <- sd.pt <- sd.dur <- numeric(nLC)
    for (i in seq(along=uLC))
    {
      n.all[i] <- length(which(corine_table$corine.landcover==uLC[i]))
      avg.pt[i] <- mean(corine_table$prop.pts[corine_table$corine.landcover==uLC[i]],na.rm=TRUE)    
      sd.pt[i] <- sd(corine_table$prop.pts[corine_table$corine.landcover==uLC[i]],na.rm=TRUE) 
      avg.dur[i] <- mean(corine_table$prop.dur[corine_table$corine.landcover==uLC[i]],na.rm=TRUE)    
      sd.dur[i] <- sd(corine_table$prop.dur[corine_table$corine.landcover==uLC[i]],na.rm=TRUE) 
    }
    corine_table <- rbind(corine_table,data.frame("trackId"=c(rep("mean",nLC),rep("sd",nLC)),"corine.landcover"=c(uLC,uLC),"n.pts"=rep(n.all,2),"prop.pts"=c(avg.pt,sd.pt),"prop.dur"=c(avg.dur,sd.dur)))
    
    write.csv(corine_table,file=paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"),"Corine_Landcover_UseStats.csv"),row.names=FALSE)
  } else logger.info("You have NOT selected to receive use statistics of the corine landcover classes by individual and overall.")

  result <- data #return full data set with additional attribute
  return(result)
}

  
  
  
  
  

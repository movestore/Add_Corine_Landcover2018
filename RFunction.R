library('move2')
library('terra')
library('foreign')
library('sf')

rFunction <- function(data,stats=FALSE)
{
  Sys.setenv(tz="UTC")
  
  #GDALinfo("CLC2018_CLC2018_V2018_20.tif")
  
  #fileName_clc_tif <- getAuxiliaryFilePath("clc_tif")
  #corineT <- rast(fileName_clc_tif)
  corineT <- rast("CLC2018_CLC2018_V2018_20.tif")
  #summary(corine,maxsamp=100)
  #crs(corine)
  
  dataT <- st_transform(data,crs=crs(corineT))
  corineTC <- crop(corineT, ext(dataT))
  corine <- project(corineTC,crs(data),method="near")
  
  data$clc <- as.numeric(as.character(extract(corine,data,method="simple")[,2]))
  
  #fileName_clc_dbf <- getAuxiliaryFilePath("clc_dbf")
  #corineClasses <- read.dbf(fileName_clc_dbf,as.is=TRUE)
  corineClasses <- read.dbf("CLC2018_CLC2018_V2018_20.tif.vat.dbf",as.is=TRUE)
  corine.landcover <- character(length(data$clc))
  uclasses <- unique(data$clc)
  for (i in seq(along=uclasses))
  {
    if (is.na(uclasses[i])) corine.landcover[which(is.na(data$clc))] <- NA else
    {
      corine.landcover[which(data$clc==uclasses[i])] <- corineClasses$LABEL3[corineClasses$Value==uclasses[i]]
    }
  }
  data$corine.landcover <- corine.landcover

  data.split <- split(data,mt_track_id(data))
  
  pdf(appArtifactPath("Corine_Landcover_Barplots.pdf"))
  lapply(data.split, function(datai)
    {
    par(mar=c(15,6,4,2))
    barplot(table(datai$corine.landcover),col="blue",las=2,main=unique(mt_track_id(datai))[1],ylab="frequency")
  })
  barplot(table(data$corine.landcover),col="red",las=2,main="all tracks",ylab="frequency")
  dev.off()  
  
  pdf(appArtifactPath("Corine_Landcover_Maps.pdf"))
  lapply(data.split, function(datai)
  {
    corinei <- crop(corine,ext(datai))
    plot(corinei,axes=FALSE,legend=FALSE,main=unique(mt_track_id(datai))[1])
    lines(st_coordinates(datai),col="darkgray")
    points(st_coordinates(datai),col="blue",pch=20)
  })
  dev.off()
  
  if(stats==TRUE)
  {
    corine_table <- data.frame("track"=character(),"corine.landcover"=character(),"n.pts"=numeric(),"prop.pts"=numeric(),"prop.dur"=numeric())
    
    corine_table_list <- lapply(data.split, function(datai)
    {
      tabi <- table(datai$corine.landcover)
      ni <- as.numeric(tabi)
      LCi <- names(tabi)
      if (!any(names(datai)=="timelag"))
      {
        datai$timelag <- mt_time_lags(data, "hours")
        logger.info("Appended timelag to track i with unit hours.")
      }
      
      propptsi <- ni/sum(ni,na.rm=TRUE)
      propduri <- apply(matrix(LCi),1,function(x) sum(datai$timelag[datai$corine.landcover==x],na.rm=TRUE)/sum(datai$timelag,na.rm=TRUE))
      data.frame("track"=unique(mt_track_id(datai))[1],"corine.landcover"=LCi,"n.pts"=ni,"prop.pts"=propptsi,"prop.dur"=propduri)
    })
    corine_table <- do.call("rbind", corine_table_list)
    
    uLC <- sort(unique(data$corine.landcover))
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
    corine_table <- rbind(corine_table,data.frame("track"=c(rep("mean",nLC),rep("sd",nLC)),"corine.landcover"=c(uLC,uLC),"n.pts"=rep(n.all,2),"prop.pts"=c(avg.pt,sd.pt),"prop.dur"=c(avg.dur,sd.dur)))
    
    write.csv(corine_table,file=appArtifactPath("Corine_Landcover_UseStats.csv"),row.names=FALSE)
  } else logger.info("You have NOT selected to receive use statistics of the corine landcover classes by individual and overall.")

  result <- data #return full data set with additional attribute
  return(result)
}

  
  
  
  
  

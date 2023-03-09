# Add Corine Landcover2018

MoveApps

Github repository: *github.com/movestore/Add_Corine_Landcover2018*

## Description
Annotates your data with Corine Landcover Classes (version 2018) and (if selected) provides usage proportions (need timelag attribute). Note that this only works for tracks in Europe, as Corine landcover is only available there.

## Documentation
This App uses the Corine Landcover 2018 100m resolution gif and annotates it to all locations of the data set. The Corine raster is clipped to the tracks first and then projected to longitude/latitude. For each location the landcover class of the one grid cell that is lies in, is appended. For more details on the data see: https://land.copernicus.eu/pan-european/corine-land-cover/clc2018. A barplot and map is provided for each track and overall.

If selecting the optional `stats`, the App calculates usage statistics of each track and overall of all used landcover classes and returns them as .csv file.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`Corine_Landcover_Barplots.pdf`: barplots for each track and overall indicating which landcover class is used how much (based on location proportions).

`Corine_Landcover_Maps.pdf`: maps of landcover classes (background) with tracks and location on top, one for each track.

`Corine_Landcover_UseStats.csv`: table providing proportions of use of each landcover class by track in terms of points and durations. For each landcover class an average and standard deviation usage is provided for location and duration proportions.

### Settings
**Generate Landcover usage statistics (`stats`)**: Select this if the useage statistics shall be performed and provided as .csv file. Default FALSE.

### Null or error handling:
**Setting `Generate Landcover usage statistics`:** Both TRUE and FALSE are valid options, none else possible.

**Data:** The full data set with additional attribues is returned.

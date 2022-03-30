# Daphne Virlar-Knight
# March 18, 2022

# Timothy Pasch Ticket 21919: https://support.nceas.ucsb.edu/rt/Ticket/Display.html?id=21919
# Dataset 1: https://arcticdata.io/catalog/view/urn%3Auuid%3Aa4c39b6f-ea30-4c9a-a53e-7394a8ac7a82
## --------------------- ## 


## -- load libraries -- ##
library(dataone)
library(datapack)
library(uuid)
library(arcticdatautils)
library(EML)


## -- read in data -- ##
# Set nodes
d1c <- dataone::D1Client("PROD", "urn:node:ARCTIC")


# Get the package
packageId <- "resource_map_urn:uuid:7c131bc1-38a4-4e8a-b95e-db0ea11369bc"
dp  <- getDataPackage(d1c, identifier = packageId, lazyLoad=TRUE, quiet=FALSE)


# Get the metadata id
xml <- selectMember(dp, name = "sysmeta@fileName", value = ".xml")
xml


# Read in the metadata
doc <- read_eml(getObject(d1c@mn, xml))


## -- Fix NSF Awards Section -- ##
awards <- c("1758781", "1758814")
proj <- eml_nsf_to_project(awards, eml_version = "2.2.0")

doc$dataset$project <- proj
eml_validate(doc)


## -- add discipline categorization -- ## 
doc <- eml_categorize_dataset(doc, c("Sociology", "Economics"))



## -- publish/update package -- ##
eml_path <- "~/Scratch/Remote_Region_Interior_Alaska_Community_Survey.xml"
write_eml(doc, eml_path)


# change access rules
myAccessRules <- data.frame(subject="CN=arctic-data-admins,DC=dataone,DC=org",
                            permission="changePermission")


# publish
dp <- replaceMember(dp, xml, replacement=eml_path)
PackageId <- uploadDataPackage(d1c, dp, public=FALSE, quiet=FALSE)

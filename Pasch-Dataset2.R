# Daphne Virlar-Knight
# March 18, 2022

# Timothy Pasch Ticket 21919: https://support.nceas.ucsb.edu/rt/Ticket/Display.html?id=21919
# Dataset 2: https://arcticdata.io/catalog/view/urn%3Auuid%3Affef2721-30c3-4fb6-8e99-3a0fe2649911
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
packageId <- "resource_map_urn:uuid:2315adc0-01a2-4f6b-b5be-014f3aaa5bce"
dp  <- getDataPackage(d1c, identifier = packageId, lazyLoad=TRUE, quiet=FALSE)


# Get the metadata id
xml <- selectMember(dp, name = "sysmeta@fileName", value = ".xml")
xml


# Read in the metadata
doc <- read_eml(getObject(d1c@mn, xml))



## -- Add Physicals to Entitys -- ##
pdf_pid <- selectMember(dp, name = "sysmeta@fileName", value = ".pdf")
pdf_phys <- pid_to_eml_physical(d1c@mn, pdf_pid)

doc$dataset$otherEntity$physical <- pdf_phys


## -- Add Fair Practices -- ##
doc <- eml_add_publisher(doc)
doc <- eml_add_entity_system(doc)


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


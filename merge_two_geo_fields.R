library(tidyverse)
library(janitor)
library(vroom)

# ABOUT -------------------------------------------------------------------

# A visual examination of the batch metadata file showed two geospatial fields: Geographical information, which is the new geospatial field introduced by Figshare in 2025 (works with geojson), and Geographic location, which is a field used by the Urban Graphic Archive - I think! 

# This script is to clean the Geographic location and move it to the Geographical information field.


# SCRIPT START ------------------------------------------------------------

data <- vroom("batch_download_20251120.csv") %>% # This file was downloaded on 2025-11-20, and includes all items, public and private
  clean_names()

filtered_data <- data %>% 
  filter(!is.na(geographic_location) & geographic_location != "")

user_data <- read_csv("user_data_20251121.csv") %>% 
  clean_names()

merged_data <- filtered_data %>% 
  left_join(user_data %>% select(account_id, author_name, account_status),
            by = "account_id")

output_data <- merged_data %>% 
  select(group_id, article_id, account_status, author_name, title, doi, geographic_location) %>% 
  mutate(doi_url = ifelse(!is.na(doi) & doi != "",
                          paste0("https://doi.org/", doi), NA))

write_csv(output_data, "old_geo_field_20251121.csv")

# Check which group it is:

group_data <- output_data %>% 
  distinct(group_id)

print(group_data) # Result: they are all in 6492 - which is the Loughborough Urban Graphic Archive

# Get a set of distinct geographic_location data

geo_location_data <- output_data %>% 
  distinct(geographic_location)

write_csv(geo_location_data, "geo_location_data_20251121.csv")


# CHECK USE OF GEOGRAPHICAL INFORMATION FIELD -----------------------------

names(data)

distinct_geo_info <- data %>% 
  distinct(geographical_information)

filtered_data2 <- data %>% 
  filter(!is.na(geographical_information))

merged_data2 <- filtered_data2 %>% 
  left_join(user_data %>% select(account_id, author_name, account_status),
            by = "account_id")

output_data2 <- merged_data2 %>% 
  select(group_id, article_id, account_status, author_name, title, doi, handle, geographical_information)

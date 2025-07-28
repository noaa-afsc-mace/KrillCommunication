# this script provides a simple example of:
# 1. Opening up all the EBS krill time series files at various resolutions

# - Survey data are available in three resolutions:
#   - Survey total (recommended for researchers interested in ecosystem-scale patterns)
# - Vertically integrated 0.5 nmi horizontal resolution (recommended for researchers interested in spatial distributions and don't require a vertical component) 
# 	- 0.5 nmi horizontal X 20 m vertical resolution (recommended for researchers that are interested in both horizontal and vertical distribution of krill)

#2. Making some preliminary maps

# 3. Computing krill density and biomass measures (if, for example, you wanted to 
# use a different set of parameters in the conversion than we've chosen here).

# clear out old stuff
rm(list = ls())

# load some libraries
library(tidyverse)
library(sf)

##################################
# 1. Opening up all the EBS krill time series files at various resolutions

# this function will open all the files for each survey resolution
open_files <- function(folder_loc){
  
  # identify the files
  files_tmp <- list.files(folder_loc, pattern = "*.csv", full.names = TRUE)
  
  all_files <- c()
  # open them all up
  for (i in 1:length(files_tmp)){
    tmp_file <- read_csv(files_tmp[i])
    all_files <- bind_rows(all_files, tmp_file)
  }
  
  return(all_files)
  
}

# now apply the function to open all the files
layer_results <- open_files(folder_loc = '../survey_results/summer_EBS/layer_results/')
edsu_results <- open_files(folder_loc = '../survey_results/summer_EBS/edsu_results/')
survey_results <- open_files(folder_loc = '../survey_results/summer_EBS/survey_results/')

##############################################
# I only care about the survey totals. Show me!

# reshape to plot 
summary_dat <- survey_results %>%
  pivot_longer(cols = -c(survey, year, survey_area_nm2), names_to = 'unit', values_to = 'value')

# plot the time series summary
ggplot(summary_dat, aes(x = year, y = value, group = unit)) +
  geom_point() +
  geom_line() +
  facet_wrap(~unit, ncol = 1, scales = 'free_y', strip.position = 'left') +
  theme_bw() 

##############################################
# I am interested in the spatial distribution of krill. Show me distribution patterns for each 
# survey year as the abundance at each 0.5 nmi EDSU.

# get the ESDU-level data as an sf spatial data frame in Albers AK
edsu_plot_dat <- st_as_sf(edsu_results, coords = c("start_longitude", "start_latitude"),
                          crs = 4326, remove = FALSE)
edsu_plot_dat <- st_transform(edsu_plot_dat, crs = 3338)

# get a basemap for plotting 
ak_land <- st_read('resources/alaska_land_EPSG3338.gpkg')

# plot 120 kHz backscatter for each year (log10 transformed)
ggplot() +
  geom_sf(data = ak_land, color = 'grey80') +
  geom_sf(data = edsu_plot_dat, aes(color = log10(krill_sA + 1))) +
  scale_color_viridis_c() + 
  facet_wrap(~year) +
  # set plot limits
  coord_sf(xlim = c(min(st_coordinates(edsu_plot_dat)[,1]), max(st_coordinates(edsu_plot_dat)[,1])), ylim = c(min(st_coordinates(edsu_plot_dat)[,2]), max(st_coordinates(edsu_plot_dat)[,2])), expand = FALSE) +
  theme_bw()

# plot krill/m2 for each year (log10 transformed)
ggplot() +
  geom_sf(data = ak_land, color = 'grey80') +
  geom_sf(data = edsu_plot_dat, aes(color = log10(krill_ww_g_m2 + 1))) +
  scale_color_viridis_c() + 
  facet_wrap(~year) +
  # set plot limits
  coord_sf(xlim = c(min(st_coordinates(edsu_plot_dat)[,1]), max(st_coordinates(edsu_plot_dat)[,1])), ylim = c(min(st_coordinates(edsu_plot_dat)[,2]), max(st_coordinates(edsu_plot_dat)[,2])), expand = FALSE) +
  theme_bw()

###################################################
# I am interested in the vertical distribution of krill in each year. Show me the mean depth (weighted by krill backscatter)
mwd <- layer_results %>%
  # define depth as the center of 20 m bins
  mutate(depth = layer_depth_max_m - 10) %>%
  group_by(year) %>%
  # get the mean krill depth for each year
  summarize(mwd_krill_m = sum(krill_sA * depth, na.rm = TRUE)/ sum(krill_sA, na.rm = TRUE)) 

###################################################
 # I want to convert krill backscatter to abundance
# (For example, you may want to do this if you feel there's a better way use krill lengths -
# a key parameter in converting from backscatter to abundance/biomass- or want to use a different # target strength relationship) 

# note that the example that follows here does NOT modify the approach used in the time series (it will produce equivalent results to the time series and is presented simply as an example of the calculations for those looking to insert alternative scaling information)

###############
# step 1: create a 'backscatter-only' per-layer dataframe by removing the abundance/biomass values for use in the example
recalc_layers <- layer_results %>%
  select(-c(krill_m3, krill_m2, krill_g_m2))

##############
# step 2: load raw catch data to get krill lengths; This represents all of MACE's s processed krill catch data as of 07/2025
krill_catch_data <- read_csv('../survey_results/summer_EBS/target_strength/MACE_krill_catch_data_2004_to_2022.csv')

#############
# step 3: load the Lucca 2023 TS-length lookup table; This represents the mean target strength (and it's linear equivalent, sigmaBS) for EBS krill on a per-cm basis. It also contains the length- wet weight values
Lucca_2021_TS_lookup <- read_csv('../survey_results/summer_EBS/target_strength/Lucca_2021_EBS_krill_120_kHz_TS_length_lookup_table.csv')

################
# step 4: Get the per-year conversion values from the catch data
conversion_values <- krill_catch_data %>%
  # get the proportion at length for each year
  group_by(year, length_bin) %>%
  summarize(count = n()) %>%
  mutate(prop_at_length = count/sum(count)) %>%
  # add the sigmaBS values at each length class
  left_join(Lucca_2021_TS_lookup, by = c('length_bin' = 'poland_length_mm')) %>%
  # compute mean length, sigmaBShat, wet weight from the prop at length
  group_by(year) %>%
  summarize(mean_length = sum(length_bin * prop_at_length),
            mean_sigmaBS = sum(sigmaBS * prop_at_length),
            mean_ww_mg = sum(wet_wt_mg * prop_at_length))

# add two special cases:

# for 2020 (Saildrone acoustic-only sampling, no krill trawl lengths) we use the 2018 catch data
row_2020 <- c(2020, 
              conversion_values$mean_length[conversion_values$year == 2018],
              conversion_values$mean_sigmaBS[conversion_values$year == 2018],
              conversion_values$mean_ww_mg[conversion_values$year == 2018])

conversion_values <- rbind(conversion_values, row_2020)

# for 2024, we don't (yet) have krill length data- these take a while to get
row_2024 <- c(2024, 
              conversion_values$mean_length[conversion_values$year == 2022],
              conversion_values$mean_sigmaBS[conversion_values$year == 2022],
              conversion_values$mean_ww_mg[conversion_values$year == 2022])

conversion_values <- rbind(conversion_values, row_2024)

# now add the conversion factors we need to the cells data
recalc_layers <- left_join(recalc_layers, conversion_values, by = c('year'))

################
# step 5: calculate abundance/biomass

# compute sa (area backscattering coefficient; m2 m-2) from sA (m2 nmi-2) 
recalc_layers$krill_sa = recalc_layers$krill_sA/(4 * pi * 1852^2)

# compute krill/m3 as sv (m-1)/sigmabs (m^2) 
recalc_layers$krill_m3 <- recalc_layers$krill_sv / recalc_layers$mean_sigmaBS

# compute krill/m2 as sa(ABC, m^2 m-2)/sigmabs (m^2)
recalc_layers$krill_m2 <- recalc_layers$krill_sa / recalc_layers$mean_sigmaBS

# compute mg/m2 as krill/m2 * wet weight per krill; express as grams/m2
recalc_layers$g_m2 <- (recalc_layers$krill_m2 * recalc_layers$mean_ww_mg)/1e3

#########################
# step 6: sum it up

# Sum by 0.5 nmi EDSU: compute average density (# per m2/ per EDSU) and total wet weight (mg/m2 per EDSU)
recalc_edsu <- recalc_layers %>%
  group_by(ship, survey, year, transect, edsu, interval_width_nmi) %>%
  # sum areal measures, mean density measures (respects units!)
  summarize(krill_sA = sum(krill_sA, na.rm = TRUE),
            krill_m3 =  mean(krill_m3, na.rm = TRUE),
            krill_m2 = sum(krill_m2, na.rm = TRUE),
            krill_ww_g_m2 = sum(g_m2, na.rm = TRUE)) 

# sum by survey: 
recalc_survey <- recalc_edsu %>%
  group_by(year) %>%
  summarize(krill_sA = sum(krill_sA * interval_width_nmi)/sum(interval_width_nmi),
            krill_m3 =  sum(krill_m3 * interval_width_nmi)/sum(interval_width_nmi),
            krill_m2 = sum(krill_m2 * interval_width_nmi)/ sum(interval_width_nmi),
            krill_ww_g_m2 = sum(krill_ww_g_m2 *interval_width_nmi)/sum(interval_width_nmi))

# tests to see if survey results and recalculated results are equivalent
all.equal(survey_results$krill_sA, recalc_survey$krill_sA)
all.equal(survey_results$krill_m3, recalc_survey$krill_m3)
all.equal(survey_results$krill_m2, recalc_survey$krill_m2)
all.equal(survey_results$krill_ww_g_m2, recalc_survey$krill_ww_g_m2)

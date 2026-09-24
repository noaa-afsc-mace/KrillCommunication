# KrillCommunication
MACE multifrequency krill abundance and distribution data

## Eastern Bering Sea summer acoustic-trawl survey: background
- MACE has been producing estimates of krill (primarily *Thysanoessa raschii* and *T. inermis*) abundance and distribution dating back to 2004.
- Estimates are based on multifrequency acoustic identification techniques: krill backscatter gets stronger at higher frequencies, while fish backscatter does not. 
- We use this principle to identify krill acoustically. We then convert krill backscatter into krill abundance and biomass terms using information about our krill catch 
and the acoustic properties of krill (see De Robertis et al. 2010, Ressler 2012 for details).
- We've recently updated our time series to:
	- make minor improvements to acoustic identification methods
	- use our long-term krill catch records and an updated model of krill acoustic properties (i.e. target strength) 
	to scale backscatter into abundance and biomass more appropriately 
	- Share this data at a finer spatial scale 
	- Incorporate estimates from a uncrewed surface vehicle survey in 2020 when ship-based data was not available (Levine and De Robertis, 2025)
- These updates are described in detail in a NOAA Technical Memorandum (Levine et al. 2026)

## Eastern Bering Sea summer acoustic-trawl survey: data products
- Survey data are available in three resolutions:
	- Survey total (recommended for researchers interested in ecosystem-scale patterns)
	- Vertically integrated 0.5 nmi horizontal resolution (recommended for researchers interested in spatial distributions who don't require a vertical component) 
	- 0.5 nmi horizontal X 20 m vertical resolution (recommended for researchers that are interested in both horizontal and vertical distribution of krill)

- Survey data are available in 4 units:
	- Krill backscatter (m<sup>2</sup> nmi<sup>-2</sup>): This represents the amount of krill acoustic backscatter at 120 kHz. This unit does not require any
	conversions based on krill catch data or target strength estimates, and therefore requires fewer assumptions than other units.
	- Krill areal density (indiviudals m<sup>-2</sup>): This unit also scales krill backscatter into areal density integrated over the entire water column based on estimates of the average krill size within each survey year. Most users should use areal density as it accounts for the depth of the water column at the sample location.
	- Krill areal density in units of wet weight (g m<sup>-2</sup>): This unit converts krill density (m<sup>2</sup>) into units of biomass based on a krill length:wet weight relationship. 
	- Krill volumetric density (individuals m<sup>-3</sup>): This unit scales krill backscatter into abundance per unit volume based on estimates of the average krill size within each survey year. 
	It is provided for consistency with previously supplied values, but total abundance is difficult to interpret without knowledge of the depth of the water column at the sample location. 
	
## Data access:

The easiest way to get the data is to clone this repository. Once you've got it, you'll find:
  - Results are in the 'survey_results' folder. Please see the file 'EBS_results_metadata.xslx' for column definitions on all datasets. 
  - Within the 'survey_results' folder, you'll find subfolders with annual data at each resolution ('edsu_results', 'layer_results', 'survey_results').
  - The 'survey_results' folder also contains a subfolder entitled 'target_strength', which contains raw catch data and a target strength-length lookup table used to convert krill backscatter to units of abundance and biomass. 
  
We additionally provide a small R project in the folder 'KrillCommunication_R_scripts' that demonstrates how to compile and explore the EBS krill time series. Simply load the R project, and then open the script 'compile_EBS_timeseries.R'.

## Current version:
The data here are PUBLISHED for 2004-2024 (Levine et al. 2026) and PRELIMINARY for 2026! 2026 estimates will change when krill catch and length data is available.
	
### Further reading:
Levine, M., De Robertis, A., Ressler, P., Lucca, B. 2026. A revised time series of euphausiid density and distribution from acoustic-trawl surveys of the Eastern Bering Sea shelf. U.S. Department of Commerce, NOAA Technical Memorandum NMFS-AFSC-525, 86 p. STILL IN PRESS

[De Robertis, A., McKelvey, D.R., Ressler, P.H. 2010. Development and application of an empirical multifrequency method for backscatter classification.
Can.J. Fish. Aquat. Sci. 67, 1459 –1474.](https://cdnsciencepub.com/doi/10.1139/F10-075)

[Ressler, P.H., A.DeRobertis, J.D.Warren, J.N.Smith, and S.Kotwicki. 2012. Developing an acoustic survey of euphausiids to understand trophic interactions in the Bering Sea ecosystem.
Deep-Sea Research PartII 65 –70:184–195.](https://doi.org/10.1016/j.dsr2.2012.02.015)

[Levine, M., and De Robertis, A. 2025. Making do with less: Extending an acoustic-based time series of euphausiid abundance using an uncrewed surface vehicle with fewer frequencies. 
Fisheries Research, 282: 107270.](https://www.sciencedirect.com/science/article/pii/S0165783625000074)

	
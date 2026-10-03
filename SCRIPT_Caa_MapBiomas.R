# rm(list = ls(envir = globalenv()), envir = globalenv())
# gc()

# Load packages -----------------------------------------------------------
library(groundhog)

list_of_packages <- c("terra", "sf", "dplyr", "tidyr", "ggplot2", "readxl", "here")
groundhog::groundhog.library(list_of_packages, "2026-09-30")

#' If you do not want to load the package versions when the script was built,
#' ignore the groundhog code above and run the code below
# lapply(list_of_packages, library, character.only = TRUE)

options(scipen = 999)


# Load data ---------------------------------------------------------------
#' MAPBIOMAS LAND USE COVERAGE GEOTIFF:
#' Raster from MapBiomas inside Brazil has 10 m resolution and a large size (~4.3 GB each year).
#' Therefore, we provide them already cropped to a 5 km buffer around the voucher coordinates.
#' Rasters for Argentina have 30 m resolution (~271 Mb each year) and were also cropped to a 5 km buffer

path_datafile <- here('data/Piovesani_etal_NJB_data.RData')
load(path_datafile)

#' Spatial objects (`SpatRaster` class) in the `terra` package consist of C++ memory pointers.
#' These pointers cannot be safely saved to disk via saveRDS() or sent 
#' across parallel computer clusters on their own. 
#' Therefore, we packed them using wrap function. This step simply unpack the rasters.
r_misiones_tr_1985 <- unwrap(r_misiones_tr_1985)
r_misiones_tr_2025 <- unwrap(r_misiones_tr_2025)
r_corrientes_1985 <- unwrap(r_corrientes_1985)
r_corrientes_2025 <- unwrap(r_corrientes_2025)
r_misiones_ca_1985 <- unwrap(r_misiones_ca_1985)
r_misiones_ca_2025 <- unwrap(r_misiones_ca_2025)
r_lajeado_2017 <- unwrap(r_lajeado_2017)
r_lajeado_2025 <- unwrap(r_lajeado_2025)


# Inspecting data ---------------------------------------------------------
# Misiones - Tres Reservas
plot(r_misiones_tr_1985)
plot(r_misiones_tr_2025)

# Misiones - Campiñas de Américo
plot(r_misiones_ca_1985)
plot(r_misiones_ca_2025)

# Corrientes
plot(r_corrientes_1985)
plot(r_corrientes_2025)

# Lajeado
plot(r_lajeado_2017)
plot(r_lajeado_2017)


# Load voucher coordinates and converting points to sf (WGS84) ---------------

misiones_tr <- c(-54.26206, -26.66206) # voucher coordinates
misiones_tr_sf <- st_point(misiones_tr) %>% # conversion to spatial point
  st_sfc(crs = 4326) # indicating CRS

misiones_ca <- c(-53.714222, -26.273639)
misiones_ca_sf <- st_point(misiones_ca) %>%
  st_sfc(crs = 4326)

corrientes <- c(-56.2131944466094, -28.4344064698476)
corrientes_sf <- st_point(corrientes) %>%
  st_sfc(crs = 4326)

lajeado <- c(-51.95410, -29.44000)
lajeado_sf <- st_point(lajeado) %>%
  st_sfc(crs = 4326)



# If the complete (large file size) MapBiomas raster is loaded,
# it must be cropped at each voucher point radius buffer
# with the code below:

# Generate the 5 km buffer (dist = 5000) and convert it to a SpatVector

# radius_misiones_tr <- st_buffer(misiones_tr_sf, dist = 5000)
# radius_misiones_tr_vect <- vect(radius_misiones_tr)
# 
# radius_misiones_ca <- st_buffer(misiones_ca_sf, dist = 5000)
# radius_misiones_ca_vect <- vect(radius_misiones_ca)
#  
# radius_corrientes <- st_buffer(corrientes_sf, dist = 5000)
# radius_corrientes_vect <- vect(radius_corrientes)
#  
# radius_lajeado <- st_buffer(lajeado_sf, dist = 5000)
# radius_lajeado_vect <- vect(radius_lajeado)


# Crop each voucher at its 5 km radius buffer

# # Misiones - Tres Reservas
# r_misiones_tr_1985 <- crop(r_arg_85, radius_misiones_tr_vect, mask = TRUE)
# plot(r_misiones_tr_1985)
# r_misiones_tr_2025 <- crop(r_arg_25, radius_misiones_tr_vect, mask = TRUE)
# plot(r_misiones_tr_2025)
# 
# # Misiones - Campiñas de Américo
# r_misiones_ca_1985 <- crop(r_arg_85, radius_misiones_ca_vect, mask = TRUE)
# plot(r_misiones_ca_1985)
# r_misiones_ca_2025 <- crop(r_arg_25, radius_misiones_ca_vect, mask = TRUE)
# plot(r_misiones_ca_2025)
# 
# # Corrientes
# r_corrientes_1985 <- crop(r_arg_85, radius_corrientes_vect, mask = TRUE)
# plot(r_corrientes_1985)
# r_corrientes_2025 <- crop(r_arg_25, radius_corrientes_vect, mask = TRUE)
# plot(r_corrientes_2025)
# 
# # Lajeado
# r_lajeado_2017 <- crop(r_br_17, radius_lajeado_vect, mask = TRUE)
# plot(r_lajeado_2017)
# r_lajeado_2025 <- crop(r_br_25, radius_lajeado_vect, mask = TRUE)
# plot(r_lajeado_2017)

# Adjusting cover classes names ------------------------------------
#' Here we obtain and assign names to land use 
#' and cover class codes and create a color palette.
#' 
#' For MapBiomas legend codes see the site below
#' https://brasil.mapbiomas.org/downloads/codigos-de-legenda/


unique(values(r_lajeado_2017)) # visualize raster code classes
unique(values(r_lajeado_2025)) # visualize raster code classes

names_classes <- data.frame(
  id = c(3, 9, 11, 12, 15, 19, 21, 24, 25, 31, 33, 36),
  Classe = c(
    "Forest Formation",
    "Forest Plantation",
    "Wetland",
    "Grassland",
    "Pasture",
    "Temporary Crop",
    "Mosaic of Uses",
    "Urban Area",
    "Other non Vegetated Areas",
    "Aquaculture",
    "Water Bodies",
    "Perennial Crop"))

levels(r_misiones_tr_1985) <- names_classes
levels(r_misiones_tr_2025) <- names_classes
levels(r_misiones_ca_1985) <- names_classes
levels(r_misiones_ca_2025) <- names_classes
levels(r_corrientes_1985) <- names_classes
levels(r_corrientes_2025) <- names_classes
levels(r_lajeado_2017) <- names_classes
levels(r_lajeado_2017)
levels(r_lajeado_2025) <- names_classes
levels(r_lajeado_2025)

#
# Create a color palette matching with official MapBiomas classes -------------

colors_misiones_tr_85 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#d082de"  # 36 - Perennial Crop (Lavouras Perenes)
)

colors_misiones_tr_25 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4", # 33 - Water Bodies (Corpos d'Água)
  "#d082de"  # 36 - Perennial Crop (Lavouras Perenes)
)

colors_misiones_ca_85 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#d4271e", # 24 - Urban Area (Área Urbanizada)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4", # 33 - Water Bodies (Corpos d'Água)
  "#d082de"  # 36 - Perennial Crop (Lavouras Perenes)
)

colors_misiones_ca_25 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#d4271e", # 24 - Urban Area (Área Urbanizada)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4", # 33 - Water Bodies (Corpos d'Água)
  "#d082de"  # 36 - Perennial Crop (Lavouras Perenes)
)

colors_corrientes_85 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#519799", # 11 - Wetland
  "#d6bc74", # 12 - Grassland (Formação Campestre)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4", # 33 - Water Bodies (Corpos d'Água)
  "#d082de"  # 36 - Perennial Crop (Lavouras Perenes)
)

colors_corrientes_25 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#519799", # 11 - Wetland
  "#d6bc74", # 12 - Grassland (Formação Campestre)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4",  # 33 - Water Bodies (Corpos d'Água)
  "#d082de"   # 36 - Perennial Crop (Lavouras Perenes)
)

colors_lajeado_17 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#d6bc74", # 12 - Grassland (Formação Campestre)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#ffefc3", # 21 - Mosaic of Uses (Mosaico de Usos)
  "#d4271e", # 24 - Urban Area (Área Urbanizada)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#2532e4"  # 33 - Water Bodies (Corpos d'Água)
)

colors_lajeado_25 <- c(
  "#1f8d49", # 3  - Forest Formation (Formação Florestal)
  "#7a5900", # 9  - Forest Plantation (Silvicultura)
  "#d6bc74", # 12 - Grassland (Formação Campestre)
  "#edde8e", # 15 - Pasture (Pastagem)
  "#C27BA0", # 19 - Temporary Crop (Lavouras Temporárias)
  "#ffefc3", # 21 - Mosaic of Uses (Mosaico de Usos)
  "#d4271e", # 24 - Urban Area (Área Urbanizada)
  "#db4d4f", # 25 - Other non Vegetated Areas (Outras Áreas não Vegetadas)
  "#091077", # 31 - Aquaculture (Aquicultura)
  "#2532e4"  # 33 - Water Bodies (Corpos d'Água)
)

#
# Plotting individual maps -------------------------------------------------------

plot(
  r_misiones_tr_1985, 
  col = colors_misiones_tr_85, 
  main = "Land Use and Land Cover – Misiones, Tres Reservas (30 m, 1985)",
  fun = function() {
    plot(st_geometry(misiones_tr_sf), pch = 21, col = "black", bg = "yellow",
         cex = 1.5, add = TRUE)
  }
)

plot(
  r_misiones_tr_2025, 
  col = colors_misiones_tr_25, 
  main = "Land Use and Land Cover – Misiones, Tres Reservas (30 m, 2025)",
  fun = function() {
    plot(st_geometry(misiones_tr_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_misiones_ca_1985, 
  col = colors_misiones_ca_85, 
  main = "Land Use and Land Cover – Misiones, Campiñas de Américo (30 m, 1985)",
  fun = function() {
    plot(st_geometry(misiones_ca_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_misiones_ca_2025, 
  col = colors_misiones_ca_25, 
  main = "Land Use and Land Cover – Misiones, Campiñas de Américo (30 m, 2025)",
  fun = function() {
    plot(st_geometry(misiones_ca_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_corrientes_1985, 
  col = colors_corrientes_85, 
  main = "Land Use and Land Cover – Corrientes, Monte Mberity (30 m, 1985)",
  fun = function() {
    plot(st_geometry(corrientes_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_corrientes_2025, 
  col = colors_corrientes_25, 
  main = "Land Use and Land Cover – Corrientes, Monte Mberity (30 m, 2025)",
  fun = function() {
    plot(st_geometry(corrientes_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_lajeado_2017, 
  col = colors_lajeado_17, 
  main = "Land Use and Land Cover – Rio Grande do Sul state, Lajeado (10 m, 2017)",
  fun = function() {
    plot(st_geometry(lajeado_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

plot(
  r_lajeado_2025, 
  col = colors_lajeado_25, 
  main = "Land Use and Land Cover – Rio Grande do Sul state, Lajeado (10 m, 2025)",
  fun = function() {
    plot(st_geometry(lajeado_sf), pch = 21, col = "black", bg = "yellow", cex = 1.5, add = TRUE)
  }
)

#
# Plot the maps comparison and export -----------------------------------------------

#' This function will plot maps of 2017 and 2025 side-by-side
plot_dual_panel <- function(r1, colors1, tit1,
                            r2, colors2, tit2,
                            point_sf) {
  
  # Identify the classes present in the recent map (r2)
  table_r2 <- cats(r2)[[1]]
  vals2    <- unique(r2)[[1]]
  
  if (is.character(vals2) || is.factor(vals2)) {
    classes2 <- as.character(vals2[!is.na(vals2)])
  } else {
    classes2 <- table_r2$Classe[match(vals2, table_r2$id)]
    classes2 <- classes2[!is.na(classes2)]
  }
  
  # Store current graphical parameters and ensure restoration upon function exit
  old_par <- par(no.readonly = TRUE)
  on.exit(par(old_par))
  
  # Divide into 3 proportional columns: Map 1, Map 2, and Legend Column
  layout(matrix(c(1, 2, 3), nrow = 1), widths = c(4.3, 4.3, 1.8))
  
  # PANEL 1 - Historical Map (2017)
  par(mar = c(3.5, 3.8, 3.0, 1.0))
  plot(
    r1,
    col = colors1,
    main = tit1,
    legend = FALSE,
    axes = TRUE,
    mar = c(3.5, 3.8, 3.0, 1.0),
    cex.main = 1.1,
    pax = list(cex.axis = 0.8),
    reset = FALSE
  )
  plot(st_geometry(point_sf), pch = 21, col = "black", bg = "yellow", cex = 1.3, add = TRUE)
  
  # PANEL 2 - Current Map (2025)
  par(mar = c(3.5, 3.8, 3.0, 1.0))
  plot(
    r2,
    col = colors2,
    main = tit2,
    legend = FALSE,
    axes = TRUE,
    mar = c(3.5, 3.8, 3.0, 1.0),
    cex.main = 1.1,
    pax = list(cex.axis = 0.8),
    reset = FALSE
  )
  plot(st_geometry(point_sf), pch = 21, col = "black", bg = "yellow", cex = 1.3, add = TRUE)
  
  # PANEL 3 - Exclusive Column for the Legend
  par(mar = c(0, 0, 0, 0))
  plot.new() # Creates a blank canvas dedicated to the legend
  
  legend(
    x = "left",
    legend = classes2,
    fill = colors2,
    border = "gray40",
    title = "Classes",
    title.font = 2,
    cex = 0.80, 
    bty = "n",
    y.intersp = 1.35,
    title.adj = .05
  )
  
  # Capture the current base R plot as an object and return it
  p_obj <- recordPlot()
  return(p_obj)
}

#' Create panel objects and export .jpg files to /figs folder
#' Misiones - Tres Reservas
panel_misiones_tr <- plot_dual_panel(
  r1 = r_misiones_tr_1985, 
  colors1 = colors_misiones_tr_85, 
  tit1 = "Misiones - Tres Reservas (30 m, 1985)",
  r2 = r_misiones_tr_2025, 
  colors2 = colors_misiones_tr_25, 
  tit2 = "Misiones - Tres Reservas (30 m, 2025)",
  point_sf = misiones_tr_sf
)

jpeg(
  filename = here::here('figs/panel_misiones_tr.jpg'),
  width = 19,
  height = 9.5,
  units = "cm",
  res = 300
)

replayPlot(panel_misiones_tr)
dev.off()


#' Misiones - Campiñas de Américo
panel_misiones_ca <- plot_dual_panel(
  r1 = r_misiones_ca_1985, 
  colors1 = colors_misiones_ca_85, 
  tit1 = "Misiones - Campiñas de Américo (30 m, 1985)",
  r2 = r_misiones_ca_2025, 
  colors2 = colors_misiones_ca_25, 
  tit2 = "Misiones - Campiñas de Américo (30 m, 2025)",
  point_sf = misiones_ca_sf
)

jpeg(
  filename = here::here('figs/panel_misiones_ca.jpg'),
  width = 19,
  height = 9.5,
  units = "cm",
  res = 300
)

replayPlot(panel_misiones_ca)
dev.off()


#' Corrientes - Monte Mberity
panel_corrientes <- plot_dual_panel(
  r1 = r_corrientes_1985, 
  colors1 = colors_corrientes_85, 
  tit1 = "Corrientes - Monte Mberity (30 m, 1985)",
  r2 = r_corrientes_2025, 
  colors2 = colors_corrientes_25, 
  tit2 = "Corrientes - Monte Mberity (30 m, 2025)",
  point_sf = corrientes_sf
)

jpeg(
  filename = here::here('figs/panel_corrientes.jpg'),
  width = 19,
  height = 9.5,
  units = "cm",
  res = 300
)

replayPlot(panel_corrientes)
dev.off()


#' Lajeado
panel_lajeado <- plot_dual_panel(
  r1 = r_lajeado_2017, 
  colors1 = colors_lajeado_17, 
  tit1 = "Rio Grande do Sul state - Lajeado (10 m, 2017)",
  r2 = r_lajeado_2025, 
  colors2 = colors_lajeado_25, 
  tit2 = "Rio Grande do Sul state - Lajeado (10 m, 2025)",
  point_sf = lajeado_sf
)

jpeg(
  filename = here::here('figs/panel_lajeado.jpg'),
  width = 19,
  height = 9.5,
  units = "cm",
  res = 300
)

replayPlot(panel_lajeado)
dev.off()



# Calculate and compare 2017-2025 MapBiomas coverage --------------------------
#' Now we will measure: a) area; b) % of class coverage; and c) number of patches.
#
## Lajeado --------------------------------------------------------------------

# Calculates the actual area of each pixel in square meters (m²)
area_pixel_lajeado <- cellSize(r_lajeado_2025, unit = "m")

# Extracts the actual summed area per class in hectares (divides m² by 10,000)
results_lajeado_2025 <- zonal(area_pixel_lajeado, r_lajeado_2025, fun = "sum")
results_lajeado_2025$hectares <- results_lajeado_2025$area / 10000
results_lajeado_2025$percentage <- (results_lajeado_2025$hectares / sum(results_lajeado_2025$hectares))*100
print(results_lajeado_2025)

results_lajeado_2017 <- zonal(area_pixel_lajeado, r_lajeado_2017, fun = "sum")
results_lajeado_2017$hectares <- results_lajeado_2017$area / 10000
results_lajeado_2017$percentage <- (results_lajeado_2017$hectares / sum(results_lajeado_2017$hectares))*100
print(results_lajeado_2017)

# Standardizes and selects data for 2025
df_lajeado_25 <- results_lajeado_2025 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_2025 = hectares, 
    percentage_2025 = percentage
  )

# Standardizes and selects data for 2017
df_lajeado_17 <- results_lajeado_2017 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_2017 = hectares, 
    percentage_2017 = percentage
  )

# Unite tables
table_lajeado <- df_lajeado_17 |> 
  dplyr::full_join(df_lajeado_25, by = "class") |> 
  # Converts NAs to 0 for classes that exist in only one of the two years
  dplyr::mutate(
    dplyr::across(
      c(hectares_2017, percentage_2017, hectares_2025, percentage_2025), 
      ~ tidyr::replace_na(.x, 0)
    )
  ) |> 
  # Performs calculations without NA contamination
  dplyr::mutate(
    dif_hectares = round(hectares_2025 - hectares_2017, 2),
    dif_percentage = round(percentage_2025 - percentage_2017, 2),
    # If the area in 2017 was 0, set it to NA (or 100% new record) to avoid generating Inf
    rel_dif_percentage = round( # Relative area loss
      ifelse(
        hectares_2017 > 0, 
        ((hectares_2025 - hectares_2017) / hectares_2017) * 100, NA_real_), 2))


# Calculate number of patches for both years
lsm_lajeado_17 <- landscapemetrics::calculate_lsm(landscape = r_lajeado_2017, what = "lsm_c_np")
lsm_lajeado_25 <- landscapemetrics::calculate_lsm(landscape = r_lajeado_2025, what = "lsm_c_np")

# extract values and associate numeric IDs with class names
df_np_17 <- lsm_lajeado_17 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2017 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

df_np_25 <- lsm_lajeado_25 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2025 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

# Join number of patches data with table_lajeado object
table_lajeado <- table_lajeado |>
  dplyr::left_join(df_np_17, by = c("class" = "name_classe")) |>
  dplyr::left_join(df_np_25, by = c("class" = "name_classe")) |>
  dplyr::mutate(
    # Replace NAs for 0 in absent classes when necessary
    dplyr::across(c(np_2017, np_2025), ~ tidyr::replace_na(.x, 0)),
    # Measure the absolute difference in patch number
    dif_np = np_2025 - np_2017,
    # Measure the relative difference in patch number, i.e., relative loss from 
    # 2017 to 2025
    rel_dif_np = round(
      ifelse(
        np_2017 > 0, 
        ((np_2025 - np_2017) / np_2017) * 100, NA_real_ # Relative number of patches loss
      ), 2)
  )

print(table_lajeado)


## Misiones - Tres Reservas -------------------------------------------------

area_pixel_tr <- cellSize(r_misiones_tr_2025, unit = "m")

results_misiones_tr_25 <- zonal(area_pixel_tr, r_misiones_tr_2025, fun = "sum")
results_misiones_tr_25$hectares <- results_misiones_tr_25$area / 10000
results_misiones_tr_25$percentage <- (results_misiones_tr_25$hectares / sum(results_misiones_tr_25$hectares))*100
print(results_misiones_tr_25)

results_misiones_tr_85 <- zonal(area_pixel_tr, r_misiones_tr_1985, fun = "sum")
results_misiones_tr_85$hectares <- results_misiones_tr_85$area / 10000
results_misiones_tr_85$percentage <- (results_misiones_tr_85$hectares / sum(results_misiones_tr_85$hectares))*100
print(results_misiones_tr_85)

df_misiones_tr_25 <- results_misiones_tr_25 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_2025 = hectares, 
    percentage_2025 = percentage
  )

df_misiones_tr_85 <- results_misiones_tr_85 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_1985 = hectares, 
    percentage_1985 = percentage
  )

table_misiones_tr <- df_misiones_tr_85 |> 
  dplyr::full_join(df_misiones_tr_25, by = "class") |> 
  dplyr::mutate(
    dplyr::across(
      c(hectares_1985, percentage_1985, hectares_2025, percentage_2025), 
      ~ tidyr::replace_na(.x, 0)
    )
  ) |> 
  dplyr::mutate(
    dif_hectares = round(hectares_2025 - hectares_1985, 2),
    dif_percentage = round(percentage_2025 - percentage_1985, 2),
    rel_dif_percentage = round(
      ifelse(
        hectares_1985 > 0, 
        ((hectares_2025 - hectares_1985) / hectares_1985) * 100, NA_real_), 2))


# Calculate number of patches for both years
lsm_misiones_tr_85 <- landscapemetrics::calculate_lsm(landscape = r_misiones_tr_1985, what = "lsm_c_np")
lsm_misiones_tr_25 <- landscapemetrics::calculate_lsm(landscape = r_misiones_tr_2025, what = "lsm_c_np")

# extract values and associate numeric IDs with class names
df_np_17 <- lsm_misiones_tr_85 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2017 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

df_np_25 <- lsm_misiones_tr_25 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2025 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

# Join number of patches data with table_lajeado object
table_misiones_tr <- table_misiones_tr |>
  dplyr::left_join(df_np_17, by = c("class" = "name_classe")) |>
  dplyr::left_join(df_np_25, by = c("class" = "name_classe")) |>
  dplyr::mutate(
    # Replace NAs for 0 in absent classes when necessary
    dplyr::across(c(np_2017, np_2025), ~ tidyr::replace_na(.x, 0)),
    # Measure the absolute difference in patch number
    dif_np = np_2025 - np_2017,
    # Measure the relative difference in patch number, i.e., relative loss from 
    # 2017 to 2025
    rel_dif_np = round(
      ifelse(
        np_2017 > 0, 
        ((np_2025 - np_2017) / np_2017) * 100, NA_real_
      ), 2)
  )

print(table_misiones_tr)



## Misiones - Campiñas de Américo  -------------------------------------------

area_pixel_ca <- cellSize(r_misiones_ca_2025, unit = "m")

results_misiones_ca_25 <- zonal(area_pixel_ca, r_misiones_ca_2025, fun = "sum")
results_misiones_ca_25$hectares <- results_misiones_ca_25$area / 10000
results_misiones_ca_25$percentage <- (results_misiones_ca_25$hectares / sum(results_misiones_ca_25$hectares))*100
print(results_misiones_ca_25)

results_misiones_ca_85 <- zonal(area_pixel_ca, r_misiones_ca_1985, fun = "sum")
results_misiones_ca_85$hectares <- results_misiones_ca_85$area / 10000
results_misiones_ca_85$percentage <- (results_misiones_ca_85$hectares / sum(results_misiones_ca_85$hectares))*100
print(results_misiones_ca_85)

df_misiones_ca_25 <- results_misiones_ca_25 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_2025 = hectares, 
    percentage_2025 = percentage
  )

df_misiones_ca_85 <- results_misiones_ca_85 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_1985 = hectares, 
    percentage_1985 = percentage
  )

table_misiones_ca <- df_misiones_ca_85 |> 
  dplyr::full_join(df_misiones_ca_25, by = "class") |> 
  dplyr::mutate(
    dplyr::across(
      c(hectares_1985, percentage_1985, hectares_2025, percentage_2025), 
      ~ tidyr::replace_na(.x, 0)
    )
  ) |> 
  dplyr::mutate(
    dif_hectares = round(hectares_2025 - hectares_1985, 2),
    dif_percentage = round(percentage_2025 - percentage_1985, 2),
    rel_dif_percentage = round(
      ifelse(
        hectares_1985 > 0, 
        ((hectares_2025 - hectares_1985) / hectares_1985) * 100, NA_real_), 2))

# Calculate number of patches for both years
lsm_misiones_ca_85 <- landscapemetrics::calculate_lsm(landscape = r_misiones_ca_1985, what = "lsm_c_np")
lsm_misiones_ca_25 <- landscapemetrics::calculate_lsm(landscape = r_misiones_ca_2025, what = "lsm_c_np")

# extract values and associate numeric IDs with class names
df_np_17 <- lsm_misiones_ca_85 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2017 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

df_np_25 <- lsm_misiones_ca_25 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2025 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

# Join number of patches data with table_lajeado object
table_misiones_ca <- table_misiones_ca |>
  dplyr::left_join(df_np_17, by = c("class" = "name_classe")) |>
  dplyr::left_join(df_np_25, by = c("class" = "name_classe")) |>
  dplyr::mutate(
    # Replace NAs for 0 in absent classes when necessary
    dplyr::across(c(np_2017, np_2025), ~ tidyr::replace_na(.x, 0)),
    # Measure the absolute difference in patch number
    dif_np = np_2025 - np_2017,
    # Measure the relative difference in patch number, i.e., relative loss from 
    # 2017 to 2025
    rel_dif_np = round(
      ifelse(
        np_2017 > 0, 
        ((np_2025 - np_2017) / np_2017) * 100, NA_real_
      ), 2)
  )

print(table_misiones_ca)



## Corrientes ----------------------------------------------------------------

area_pixel_cor <- cellSize(r_corrientes_2025, unit = "m")

results_cor_25 <- zonal(area_pixel_cor, r_corrientes_2025, fun = "sum")
results_cor_25$hectares <- results_cor_25$area / 10000
results_cor_25$percentage <- (results_cor_25$hectares / sum(results_cor_25$hectares))*100
print(results_cor_25)

results_cor_85 <- zonal(area_pixel_cor, r_corrientes_1985, fun = "sum")
results_cor_85$hectares <- results_cor_85$area / 10000
results_cor_85$percentage <- (results_cor_85$hectares / sum(results_cor_85$hectares))*100
print(results_cor_85)

df_cor_25 <- results_cor_25 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_2025 = hectares, 
    percentage_2025 = percentage
  )

df_cor_85 <- results_cor_85 |> 
  as.data.frame() |> 
  dplyr::rename(Classe = 1) |> 
  dplyr::mutate(Classe = as.character(Classe)) |> 
  dplyr::select(
    class = Classe, 
    hectares_1985 = hectares, 
    percentage_1985 = percentage
  )

table_cor <- df_cor_85 |> 
  dplyr::full_join(df_cor_25, by = "class") |> 
  dplyr::mutate(
    dplyr::across(
      c(hectares_1985, percentage_1985, hectares_2025, percentage_2025), 
      ~ tidyr::replace_na(.x, 0)
    )
  ) |> 
  dplyr::mutate(
    dif_hectares = round(hectares_2025 - hectares_1985, 2),
    dif_percentage = round(percentage_2025 - percentage_1985, 2),
    rel_dif_percentage = round(
      ifelse(
        hectares_1985 > 0, 
        ((hectares_2025 - hectares_1985) / hectares_1985) * 100, NA_real_), 2))

# Calculate number of patches for both years
lsm_corrientes_85 <- landscapemetrics::calculate_lsm(landscape = r_corrientes_1985, what = "lsm_c_np")
lsm_corrientes_25 <- landscapemetrics::calculate_lsm(landscape = r_corrientes_2025, what = "lsm_c_np")

# extract values and associate numeric IDs with class names
df_np_17 <- lsm_corrientes_85 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2017 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

df_np_25 <- lsm_corrientes_25 |>
  dplyr::left_join(names_classes, by = c("class" = "id")) |>
  dplyr::select(name_classe = Classe, np_2025 = value) |>
  dplyr::mutate(name_classe = as.character(name_classe))

# Join number of patches data with table_lajeado object
table_cor <- table_cor |>
  dplyr::left_join(df_np_17, by = c("class" = "name_classe")) |>
  dplyr::left_join(df_np_25, by = c("class" = "name_classe")) |>
  dplyr::mutate(
    # Replace NAs for 0 in absent classes when necessary
    dplyr::across(c(np_2017, np_2025), ~ tidyr::replace_na(.x, 0)),
    # Measure the absolute difference in patch number
    dif_np = np_2025 - np_2017,
    # Measure the relative difference in patch number, i.e., relative loss from 
    # 2017 to 2025
    rel_dif_np = round(
      ifelse(
        np_2017 > 0, 
        ((np_2025 - np_2017) / np_2017) * 100, NA_real_
      ), 2)
  )

print(table_cor)


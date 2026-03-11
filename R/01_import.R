# ==============================================================================
# 01_import.R
# Load raw source data: ECHA/EU chemical substance lists
# ==============================================================================

library(readxl)
library(dplyr)
library(here)

src <- here("data", "source")

# ------------------------------------------------------------------------------
# Obligation lists (chem.echa.europa.eu/obligation-lists)
# ------------------------------------------------------------------------------

restriction_list    <- read_excel(file.path(src, "restriction_list_full.xlsx"),    sheet = "List_results") |> mutate(source = "restriction_list")
candidate_list      <- read_excel(file.path(src, "candidate_list_full.xlsx"),      sheet = "List_results") |> mutate(source = "candidate_list")
authorisation_list  <- read_excel(file.path(src, "authorisation_list_full.xlsx"),  sheet = "List_results") |> mutate(source = "authorisation_list")
pops_list           <- read_excel(file.path(src, "pops_list_full.xlsx"),           sheet = "List_results") |> mutate(source = "pops_list")
eu_positive_list    <- read_excel(file.path(src, "eu_positive_list_full.xlsx"),    sheet = "List_results") |> mutate(source = "eu_positive_list")
harmonised_list     <- read_excel(file.path(src, "Harmonised_List.xlsx"),          sheet = "List_results") |> mutate(source = "harmonised_list")

# ------------------------------------------------------------------------------
# Activity lists (chem.echa.europa.eu/activity-lists)
# ------------------------------------------------------------------------------

restriction_process    <- read_excel(file.path(src, "restriction_process_full.xlsx"),    sheet = "List_results") |> mutate(source = "restriction_process")
svhc_identification    <- read_excel(file.path(src, "svhc_identification_full.xlsx"),    sheet = "List_results") |> mutate(source = "svhc_identification")
authorisation_process  <- read_excel(file.path(src, "authorisation_process_full.xlsx"),  sheet = "List_results") |> mutate(source = "authorisation_process")
dossier_evaluation     <- read_excel(file.path(src, "dossier_evaluation_full.xlsx"),     sheet = "List_results") |> mutate(source = "dossier_evaluation")
clh_process            <- read_excel(file.path(src, "clh_process_full.xlsx"),            sheet = "List_results") |> mutate(source = "clh_process")
substance_evaluation   <- read_excel(file.path(src, "substance_evaluation_full.xlsx"),   sheet = "List_results") |> mutate(source = "substance_evaluation")
pops_process           <- read_excel(file.path(src, "pops_process_full.xlsx"),           sheet = "List_results") |> mutate(source = "pops_process")
pbt_assessment         <- read_excel(file.path(src, "pbt_assessment.xlsx"),              sheet = "List_results") |> mutate(source = "pbt_assessment")
ed_assessment          <- read_excel(file.path(src, "ed_assessment.xlsx"),               sheet = "List_results") |> mutate(source = "ed_assessment")

# ------------------------------------------------------------------------------
# REACH registrations (chem.echa.europa.eu)
# ------------------------------------------------------------------------------

reach_registrations <- read_excel(file.path(src, "reach_registrations.xlsx"), sheet = "Substances list") |> mutate(source = "reach_registrations")

# ------------------------------------------------------------------------------
# EU Pesticides Database — Active Substances
# Row 1-2: title/metadata; row 3: column headers; data from row 4 onward
# ------------------------------------------------------------------------------

pesticides <- read_excel(
  file.path(src, "Pesticides_ActiveSubstanceExport.xlsx"),
  sheet = "Active Substance Search export",
  skip  = 2
) |> mutate(source = "pesticides")

# ------------------------------------------------------------------------------
# Gecombineerde dataframe (alle bronnen samengevoegd)
# Kolommen die niet in een bron voorkomen worden gevuld met NA
# ------------------------------------------------------------------------------

all_substances <- bind_rows(
  restriction_list,
  candidate_list,
  authorisation_list,
  pops_list,
  eu_positive_list,
  harmonised_list,
  restriction_process,
  svhc_identification,
  authorisation_process,
  dossier_evaluation,
  clh_process,
  substance_evaluation,
  pops_process,
  pbt_assessment,
  ed_assessment,
  reach_registrations,
  pesticides
)

# ------------------------------------------------------------------------------
# Unieke stoffen op basis van CAS- en EC-nummer
# Bronnen gebruiken wisselende kolomnamen; coalesce tot één waarde per rij
# ------------------------------------------------------------------------------

unique_substances <- all_substances |>
  transmute(
    substance_name = coalesce(`Substance name`, Name, Substance),
    ec_number      = coalesce(`EC number`, `EC Number`),
    cas_number     = coalesce(`CAS number`, `CAS Number`)
  ) |>
  distinct(ec_number, cas_number, .keep_all = TRUE) |>
  arrange(substance_name)

message("01_import.R completed")

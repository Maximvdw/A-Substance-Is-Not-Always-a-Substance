# ==============================================================================
# 01_import.R
# Inladen van ruwe data: lijsten met chemische stoffen en bijbehorende requesten
# ==============================================================================

library(readxl)
library(readr)
library(here)

# ------------------------------------------------------------------------------
# Configuratie
# ------------------------------------------------------------------------------

DATA_RAW <- here("data", "raw")

# ------------------------------------------------------------------------------
# Inladen stoffenlijsten
# ------------------------------------------------------------------------------

# Pas bestandsnamen aan naar de werkelijke bestanden
substances_raw <- read_csv(
  file.path(DATA_RAW, "substances.csv"),
  col_types = cols(.default = "c")
)

# Inladen requesten (aanvragen waarbij stoffen voorkomen)
requests_raw <- read_csv(
  file.path(DATA_RAW, "requests.csv"),
  col_types = cols(.default = "c")
)

# Optioneel: referentielijst (bv. REACH, SVHCs, gevaarlijke stoffen)
reference_lists_raw <- read_excel(
  file.path(DATA_RAW, "reference_lists.xlsx")
)

# ------------------------------------------------------------------------------
# Opslaan als tussenliggende data
# ------------------------------------------------------------------------------

saveRDS(substances_raw,      file = here("data", "processed", "substances_raw.rds"))
saveRDS(requests_raw,        file = here("data", "processed", "requests_raw.rds"))
saveRDS(reference_lists_raw, file = here("data", "processed", "reference_lists_raw.rds"))

message("01_import.R voltooid")

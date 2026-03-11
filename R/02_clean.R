# ==============================================================================
# 02_clean.R
# Opschonen en harmoniseren van stoffenlijsten en requesten
# ==============================================================================

library(dplyr)
library(tidyr)
library(stringr)
library(here)

# ------------------------------------------------------------------------------
# Inladen ruwe data
# ------------------------------------------------------------------------------

substances_raw      <- readRDS(here("data", "processed", "substances_raw.rds"))
requests_raw        <- readRDS(here("data", "processed", "requests_raw.rds"))
reference_lists_raw <- readRDS(here("data", "processed", "reference_lists_raw.rds"))

# ------------------------------------------------------------------------------
# Stoffen opschonen
# ------------------------------------------------------------------------------

substances <- substances_raw |>
  rename_with(str_to_lower) |>
  mutate(
    cas_number = str_trim(cas_number),
    name       = str_trim(name),
    # Normaliseer CAS-nummers naar formaat XXXXXX-XX-X
    cas_number = str_replace_all(cas_number, "\\s+", "")
  ) |>
  filter(!is.na(cas_number), cas_number != "") |>
  distinct(cas_number, .keep_all = TRUE)

# ------------------------------------------------------------------------------
# Requesten opschonen
# ------------------------------------------------------------------------------

requests <- requests_raw |>
  rename_with(str_to_lower) |>
  mutate(
    request_id = str_trim(request_id),
    date       = as.Date(date),
    cas_number = str_trim(cas_number)
  ) |>
  filter(!is.na(request_id))

# ------------------------------------------------------------------------------
# Referentielijsten opschonen
# ------------------------------------------------------------------------------

reference_lists <- reference_lists_raw |>
  rename_with(str_to_lower) |>
  mutate(
    cas_number = str_trim(cas_number),
    list_name  = str_trim(list_name)
  ) |>
  filter(!is.na(cas_number))

# ------------------------------------------------------------------------------
# Koppeling stoffen aan referentielijsten
# ------------------------------------------------------------------------------

substances_annotated <- substances |>
  left_join(
    reference_lists |> select(cas_number, list_name) |> distinct(),
    by = "cas_number",
    relationship = "many-to-many"
  )

# ------------------------------------------------------------------------------
# Koppeling requesten aan stoffen
# ------------------------------------------------------------------------------

requests_substances <- requests |>
  left_join(substances_annotated, by = "cas_number")

# ------------------------------------------------------------------------------
# Opslaan
# ------------------------------------------------------------------------------

saveRDS(substances,            here("data", "processed", "substances.rds"))
saveRDS(requests,              here("data", "processed", "requests.rds"))
saveRDS(reference_lists,       here("data", "processed", "reference_lists.rds"))
saveRDS(substances_annotated,  here("data", "processed", "substances_annotated.rds"))
saveRDS(requests_substances,   here("data", "processed", "requests_substances.rds"))

message("02_clean.R voltooid")

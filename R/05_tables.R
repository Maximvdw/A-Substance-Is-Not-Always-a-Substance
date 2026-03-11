# ==============================================================================
# 05_tables.R
# LaTeX-tabellen genereren vanuit analyseresultaten
# ==============================================================================

library(dplyr)
library(knitr)
library(kableExtra)
library(here)

TABLES <- here("output", "tables")

# ------------------------------------------------------------------------------
# Inladen
# ------------------------------------------------------------------------------

combined                <- readRDS(here("data", "processed", "combined.rds"))
substance_list_presence <- readRDS(here("data", "processed", "substance_list_presence.rds"))

# ------------------------------------------------------------------------------
# Tabel 1: Top-20 stoffen met requestfrequentie en lijstaanwezigheid
# ------------------------------------------------------------------------------

tbl1 <- combined |>
  slice_max(n_requests, n = 20) |>
  select(cas_number, name, n_requests, n_lists, lists) |>
  mutate(lists = if_else(is.na(lists), "—", lists))

kbl(
  tbl1,
  format    = "latex",
  booktabs  = TRUE,
  longtable = FALSE,
  caption   = "Top-20 meest aangevraagde stoffen en aanwezigheid op referentielijsten.",
  label     = "tab:top_substances",
  col.names = c("CAS-nummer", "Naam", "Requesten", "Lijsten (n)", "Lijsten"),
  align     = c("l", "l", "r", "r", "l")
) |>
  kable_styling(latex_options = c("hold_position", "scale_down")) |>
  save_kable(file.path(TABLES, "tab1_top_substances.tex"))

# ------------------------------------------------------------------------------
# Tabel 2: Samenvatting per referentielijst
# ------------------------------------------------------------------------------

tbl2 <- substance_list_presence |>
  tidyr::separate_rows(lists, sep = "; ") |>
  count(lists, name = "n_substances", sort = TRUE)

kbl(
  tbl2,
  format    = "latex",
  booktabs  = TRUE,
  caption   = "Aantal stoffen per referentielijst.",
  label     = "tab:ref_lists",
  col.names = c("Referentielijst", "Aantal stoffen"),
  align     = c("l", "r")
) |>
  kable_styling(latex_options = "hold_position") |>
  save_kable(file.path(TABLES, "tab2_reference_lists.tex"))

message("05_tables.R voltooid — tabellen opgeslagen in ", TABLES)

# ==============================================================================
# 04_visualize.R
# Figuren voor het LaTeX-paper
# ==============================================================================

library(ggplot2)
library(dplyr)
library(here)

FIGURES <- here("output", "figures")

# ------------------------------------------------------------------------------
# Thema
# ------------------------------------------------------------------------------

theme_paper <- theme_classic(base_size = 11) +
  theme(
    plot.title   = element_text(face = "bold"),
    axis.title   = element_text(size = 10),
    legend.position = "bottom"
  )

# ------------------------------------------------------------------------------
# Inladen analyseresultaten
# ------------------------------------------------------------------------------

substance_freq          <- readRDS(here("data", "processed", "substance_freq.rds"))
substance_list_presence <- readRDS(here("data", "processed", "substance_list_presence.rds"))
combined                <- readRDS(here("data", "processed", "combined.rds"))
requests_over_time      <- readRDS(here("data", "processed", "requests_over_time.rds"))

# ------------------------------------------------------------------------------
# Figuur 1: Top-N meest aangevraagde stoffen
# ------------------------------------------------------------------------------

top_n <- 20

p1 <- substance_freq |>
  slice_max(n_requests, n = top_n) |>
  mutate(name = reorder(name, n_requests)) |>
  ggplot(aes(x = n_requests, y = name)) +
  geom_col(fill = "steelblue") +
  labs(
    title = paste0("Top ", top_n, " meest aangevraagde stoffen"),
    x     = "Aantal requesten",
    y     = NULL
  ) +
  theme_paper

ggsave(file.path(FIGURES, "fig1_top_substances.pdf"), p1,
       width = 16, height = 10, units = "cm")

# ------------------------------------------------------------------------------
# Figuur 2: Aantal stoffen per referentielijst
# ------------------------------------------------------------------------------

p2 <- substance_list_presence |>
  tidyr::separate_rows(lists, sep = "; ") |>
  count(lists, sort = TRUE) |>
  mutate(lists = reorder(lists, n)) |>
  ggplot(aes(x = n, y = lists)) +
  geom_col(fill = "darkorange") +
  labs(
    title = "Aantal stoffen per referentielijst",
    x     = "Aantal stoffen",
    y     = NULL
  ) +
  theme_paper

ggsave(file.path(FIGURES, "fig2_reference_lists.pdf"), p2,
       width = 16, height = 10, units = "cm")

# ------------------------------------------------------------------------------
# Figuur 3: Requesten over tijd
# ------------------------------------------------------------------------------

p3 <- requests_over_time |>
  ggplot(aes(x = year, y = n_requests, group = 1)) +
  geom_line(color = "steelblue") +
  geom_point(color = "steelblue") +
  labs(
    title = "Aantal requesten per jaar",
    x     = "Jaar",
    y     = "Aantal requesten"
  ) +
  theme_paper

ggsave(file.path(FIGURES, "fig3_requests_over_time.pdf"), p3,
       width = 16, height = 8, units = "cm")

message("04_visualize.R voltooid — figuren opgeslagen in ", FIGURES)

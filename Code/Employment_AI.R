install.packages("ipumsr")

library(ipumsr)
library(dplyr)
library(ggplot2)
library(scales)


ddi <- read_ipums_ddi("cps_00001.xml")
data <- read_ipums_micro(ddi)

## Clean Code

data <- data %>%
  mutate(
    AGE_num        = zap_labels(AGE),
    EMPSTAT_num    = zap_labels(EMPSTAT),
    LABFORCE_num   = zap_labels(LABFORCE),
    OCC2010_num    = zap_labels(OCC2010),
    ASECFLAG_num   = zap_labels(ASECFLAG),
    UHRSWORKLY_num = zap_labels(UHRSWORKLY)
  ) %>%
  filter(ASECFLAG_num == 1)   # keep true ASEC-supplement respondents only

## Define Flags
#   0110 Computer and Information Systems Managers
#   1005 Computer and information research scientists
#   1006 Computer Systems Analysts
#   1010 Computer Programmers
#   1020 Software Developers, Applications and Systems Software
#   1030 Web Developers
#   1050 Computer Support Specialists
#   1060 Database Administrators
#   1105 Network and Computer Systems Administrators
#   1106 Computer network architects
#   1107 Computer occupations, all other
#   1400 Computer Hardware Engineers

tech_codes <- c(110, 1005, 1006, 1010, 1020, 1030, 1050, 1060, 1105, 1106, 1107, 1400)

data <- data %>%
  mutate(
    in_labor_force = LABFORCE_num == 2,               # 2 = Yes, in the labor force
    is_employed    = EMPSTAT_num %in% c(10, 12),       # At work / has job, not at work
    is_unemployed  = EMPSTAT_num %in% c(20, 21, 22),   # Unemployed (all subtypes)
    tech_occ       = OCC2010_num %in% tech_codes,
    occ_group      = ifelse(tech_occ, "Tech/computer occupations", "All other occupations")
  )

year_range <- range(data$YEAR)

## Base Analytic Sample

data_base <- data %>% filter(AGE_num >= 16, AGE_num <= 75)

## Visualization 1 

viz1_data <- data_base %>%
  filter(AGE_num >= 22, AGE_num <= 29, in_labor_force) %>%
  group_by(YEAR, occ_group) %>%
  summarise(
    unemp_rate = sum(ASECWT[is_unemployed]) / sum(ASECWT),
    .groups = "drop"
  )

p1 <- ggplot(viz1_data, aes(x = YEAR, y = unemp_rate, color = occ_group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.2) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = seq(year_range[1], year_range[2], 1)) +
  labs(
    title = "Unemployment Rate Among Young Workers in the U.S. (Ages 22-29)",
    subtitle = paste("Tech/computer occupations vs. all other occupations,", year_range[1], "-", year_range[2]),
    x = NULL, y = "Unemployment rate (weighted)", color = NULL,
    caption = "Source: IPUMS CPS ASEC. Estimates weighted using ASECWT."
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")

ggsave("\viz1_unemployment_young_tech.png", p1, width = 8, height = 5, dpi = 300)

## Visualization 2

viz2_data <- data_base %>%
  filter(is_employed) %>%
  group_by(YEAR) %>%
  summarise(
    tech_share = sum(ASECWT[tech_occ]) / sum(ASECWT),
    .groups = "drop"
  ) %>%
  mutate(YEAR = factor(YEAR))

p2 <- ggplot(viz2_data, aes(x = YEAR, y = tech_share, fill = YEAR)) +
  geom_col(width = 0.65, show.legend = FALSE) +
  geom_col(fill = "#2c7fb8", width = 0.65) +
  geom_text(aes(label = percent(tech_share, accuracy = 0.1)),
            vjust = -0.5, size = 3.6) +
  scale_y_continuous(labels = percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Tech/Computer Occupations as a Share of Total Employment",
    subtitle = paste("Every year,", year_range[1], "-", year_range[2]),
    x = NULL, y = "Share of employed workers (weighted)",
    caption = "Source: IPUMS CPS ASEC. Estimates weighted using ASECWT."
  ) +
  theme_minimal(base_size = 12)

ggsave("\viz2_tech_employment_share.png", p2, width = 7, height = 5, dpi = 300)

## Visualization 3

viz3_data <- data_base %>%
  filter(AGE_num >= 22, AGE_num <= 29) %>%
  group_by(YEAR) %>%
  summarise(
    lfp_rate = sum(ASECWT[in_labor_force]) / sum(ASECWT),
    .groups = "drop"
  )

p4 <- ggplot(viz3_data, aes(x = YEAR, y = lfp_rate)) +
  geom_line(linewidth = 1.1, color = "#2c7fb8") +
  geom_point(size = 2.5, color = "#2c7fb8") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = seq(year_range[1], year_range[2], 1)) +
  labs(
    title = "Labor Force Participation Rate, Ages 22-29",
    subtitle = paste("All occupations combined,", year_range[1], "-", year_range[2]),
    x = NULL, y = "Labor force participation rate (weighted)",
    caption = "Source: IPUMS CPS ASEC. Estimates weighted using ASECWT."
  ) +
  theme_minimal(base_size = 12)

ggsave("\viz3_lfp_young_workers.png", p4, width = 7, height = 5, dpi = 300)

## Visualization 4

viz4_data <- data_base %>%
  filter(AGE_num >= 30, in_labor_force) %>%
  group_by(YEAR, occ_group) %>%
  summarise(
    unemp_rate = sum(ASECWT[is_unemployed]) / sum(ASECWT),
    .groups = "drop"
  )

p5 <- ggplot(viz4_data, aes(x = YEAR, y = unemp_rate, color = occ_group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.2) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = seq(year_range[1], year_range[2], 1)) +
  labs(
    title = "Unemployment Rate Among Workers Aged 30+",
    subtitle = paste("Tech/computer occupations vs. all other occupations,", year_range[1], "-", year_range[2]),
    x = NULL, y = "Unemployment rate (weighted)", color = NULL,
    caption = "Source: IPUMS CPS ASEC. Estimates weighted using ASECWT."
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "top")

ggsave("\viz4_unemployment_30plus_tech.png", p5, width = 8, height = 5, dpi = 300)
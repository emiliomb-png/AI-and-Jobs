# AI and the U.S. Labor Market: A CPS-Based Look at Tech Occupations (2019–2025)

This project investigates whether U.S. labor market outcomes for tech/computer occupations
have shifted since generative AI tools (e.g., ChatGPT) went mainstream in late 2022, using
microdata from the IPUMS Current Population Survey (CPS) Annual Social and Economic Supplement
(ASEC).

## Research question

Using CPS ASEC data from 2019–2025, can we observe any pattern consistent with AI having
affected employment or unemployment outcomes for tech/computer occupations, relative to the
rest of the labor market?

## Data source

- **Survey:** IPUMS CPS ASEC (Annual Social and Economic Supplement), 2019–2025
- **Access:** [https://cps.ipums.org](https://cps.ipums.org)
- **Extract files:** `cps_00001.xml` (DDI codebook) and `cps_00001_dat.gz` (fixed-width data). These files were not included in this repo due to IPUMS data redistribution terms. Regenerate your own
  extract at the link above using the variable list below.

### Variables used

| Variable | Description |
|---|---|
| `YEAR` | Survey year |
| `AGE` | Age |
| `EMPSTAT` | Employment status |
| `LABFORCE` | Labor force status |
| `OCC2010` | Occupation, harmonized to 2010 Census classification |
| `EDUC` | Educational attainment |
| `WKSWORK1` | Weeks worked last year |
| `UHRSWORKLY` | Usual hours worked per week, last year |
| `ASECFLAG` | Identifies true ASEC-supplement respondents (see Methodology) |
| `ASECWT` | ASEC person weight — applied to every statistic reported |

## Methodology

1. **Sample restriction:** Filtered to `ASECFLAG == 1` to isolate true ASEC-supplement
   respondents. This extract mixed full monthly CPS samples (2022–2026) with ASEC-only
   samples (2019–2021). Filtering on `ASECFLAG` standardizes every year to a comparable
   ASEC cross-section.
2. **Tech occupation definition:** Workers were flagged as being in a "tech/computer
   occupation" based on the following `OCC2010` codes (Census "Computer Occupations" cluster):

   | Code | Occupation |
   |---|---|
   | 0110 | Computer and Information Systems Managers |
   | 1005 | Computer and information research scientists |
   | 1006 | Computer Systems Analysts |
   | 1010 | Computer Programmers |
   | 1020 | Software Developers, Applications and Systems Software |
   | 1030 | Web Developers |
   | 1050 | Computer Support Specialists |
   | 1060 | Database Administrators |
   | 1105 | Network and Computer Systems Administrators |
   | 1106 | Computer network architects |
   | 1107 | Computer occupations, all other |
   | 1400 | Computer Hardware Engineers |

3. **Weighting:** All means, rates, and shares are calculated using `ASECWT`, the CPS ASEC
   person weight, so estimates describe the U.S. population rather than the raw sample.
4. **Visuals:** Built in R with `ipumsr`, `dplyr`, and `ggplot2`.

## Visuals

| File | Description |
|---|---|
| `viz1_unemployment_young_tech.png` | Unemployment rate, ages 22–29, tech vs. all other occupations, 2019–2025 |
| `viz2_tech_employment_share.png` | Tech/computer occupations as a share of total employment, every year 2019–2025 |
| `viz5_unemployment_30plus_tech.png` | Unemployment rate, ages 30+, tech vs. all other occupations, 2019–2025 |
| `viz4_lfp_young_workers.png` | Labor force participation rate, ages 22–29, all occupations combined |

## Key findings

- Tech unemployment (both ages 22–29 and 30+) rises steadily starting in 2022, while
  unemployment in other occupations moves in the opposite direction (falling from its
  pandemic-era peak).
- Tech's share of total employment stays roughly flat (3.5–4.2%) across the period. This
  looks like rising unemployment risk within tech, not tech jobs disappearing.
- Overall youth labor force participation rises and holds steady over the same period, ruling out
  a broad "young people leaving the workforce" explanation.

## Limitations

- **Correlation, not causation.** The 2022 Federal Reserve rate-hiking cycle and the
  well-documented unwinding of pandemic-era tech overhiring (large-scale layoffs at Meta,
  Amazon, Google, and others in 2022–2023) could produce the same pattern with no AI
  involvement whatsoever. This dataset does not separate these explanations from an AI-driven
  effect.

## Requirements

```r
install.packages(c("ipumsr", "dplyr", "ggplot2", "scales"))
```

## How to run

1. Register at [cps.ipums.org](https://cps.ipums.org) and build an extract with the
   variables listed above, for ASEC samples 2019–2025.
2. Download the `.xml` (DDI) and `.dat.gz` files into the project directory.
3. Update the file path in `analysis_script.R` if needed.
4. Run the script in RStudio. Plots save to an `outputs/` subfolder.

## Citation

Data from IPUMS CPS:
Sarah Flood, Miriam King, Renae Rodgers, Steven Ruggles, J. Robert Warren, Daniel Backman,
Annie Chen, Grace Cooper, Stephanie Richards, Megan Schouweiler, and Michael Westberry.
*IPUMS CPS: Version 12.0* [dataset]. Minneapolis, MN: IPUMS, 2024.
https://doi.org/10.18128/D030.V12.0

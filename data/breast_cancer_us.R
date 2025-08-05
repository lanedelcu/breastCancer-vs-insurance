# Load libraries
library(dplyr)
library(readxl)
library(ggplot2)
library(ggrepel)
library(sf)
library(leaflet)
library(tidyr)
library(htmlwidgets)
library(maps)
library(mapdata)
library(viridis)
library(knitr)
library(kableExtra)
library(scales)

### --- Data Loading and Preparation ---

# Breast Cancer Data
br_cancer_data <- read.csv("breast_cancer_2022_data.csv")
br_cancer <- br_cancer_data %>%
  filter(YEAR == 2022, SEX == "Female", RACE == "All Races", SITE == "Female Breast") %>%
  select(State = AREA, Breast_Cancer_Incidence_Rate = AGE_ADJUSTED_RATE)

# Insurance Data
insurance_data <- read_excel("health_insurance_2022_data.xlsx", sheet = "hi05_acs", skip = 5) %>%
  filter(!is.na(`Nation/State`), Characteristic == "19 - 64 years") %>%
  filter(!`Nation/State` %in% c("United States", "Puerto Rico"))

un_insured <- insurance_data %>%
  select(State = `Nation/State`, Uninsured_Rate = `...55`) %>%
  mutate(Uninsured_Rate = as.numeric(gsub("[^0-9.]", "", Uninsured_Rate)))

insured <- insurance_data %>%
  select(State = `Nation/State`, Insured_Rate = `...7`) %>%
  mutate(Insured_Rate = as.numeric(gsub("[^0-9.]", "", Insured_Rate)))

# Education Data
h_school_data <- read.csv("high_school_data.csv") %>%
  filter(NAME != "Geographic Area Name") %>%
  select(State = NAME, HS_or_higher = S1501_C02_014E) %>%
  mutate(HS_or_higher = as.numeric(HS_or_higher))

bachelor_data <- read.csv("bachelor_data.csv") %>%
  filter(NAME != "Geographic Area Name") %>%
  select(State = NAME, BA_or_higher = S1502_C02_014E) %>%
  mutate(BA_or_higher = as.numeric(BA_or_higher))

education <- left_join(h_school_data, bachelor_data, by = "State")

# Median Income Data
m_income <- read.csv("median_income_data.csv", skip = 1) %>%
  select(State = Geographic.Area.Name, 
         Median_Income = `Estimate..Median.income..dollars...HOUSEHOLD.INCOME.BY.RACE.AND.HISPANIC.OR.LATINO.ORIGIN.OF.HOUSEHOLDER..Households`) %>%
  mutate(Median_Income = as.numeric(Median_Income)) %>%
  filter(!State %in% c("United States", "Puerto Rico"))

# Merge all data
merged_data <- br_cancer %>%
  left_join(un_insured, by = "State") %>%
  left_join(insured, by = "State") %>%
  left_join(education, by = "State") %>%
  left_join(m_income, by = "State") %>%
  mutate(Combined_Education = round((HS_or_higher + BA_or_higher) / 2, 1))

### --- Visualizations and Analysis ---

# A. Scatter: Breast Cancer vs Uninsured Rate
merged_bc_insurance <- br_cancer %>%
  left_join(insured, by = "State") %>%
  left_join(un_insured, by = "State")

median_un_insured <- median(merged_bc_insurance$Uninsured_Rate, na.rm = TRUE)
median_incidence <- median(merged_bc_insurance$Breast_Cancer_Incidence_Rate, na.rm = TRUE)

merged_bc_insurance <- merged_bc_insurance %>%
  mutate(
    HighRisk = ifelse(
      Uninsured_Rate > median_un_insured & Breast_Cancer_Incidence_Rate > median_incidence,
      "High Uninsured & High Incidence",
      "Other"
    )
  )


#START USING THE DATASETS TO VISUALIZATIONS 
#######################################################################################################################
##### A.BREAST CANCER INCIDENCE VS. % UNINSURED WOMEN (19-64) -SCATTER PLOTS #############################
## !! use second scatter plot as if provides a better visualization of the states grouped by risk

ggplot(merged_bc_insurance, aes(x = Uninsured_Rate, y = Breast_Cancer_Incidence_Rate, label = State)) +
  geom_point(color = "darkred", size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue", linetype = "dashed") +
  geom_text_repel(size = 3.5, max.overlaps = 50) +
  theme_minimal(base_size = 14)

# B. Breast Cancer vs Insured Rate
ggplot(merged_bc_insurance, aes(x = Insured_Rate, y = Breast_Cancer_Incidence_Rate, label = State)) +
  geom_point(color = "darkred", size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue", linetype = "dashed") +
  geom_text_repel(size = 3.5, max.overlaps = 50) +
  theme_minimal(base_size = 14)

# C. Breast Cancer by Race
ggplot(br_cancer_data, aes(x = RACE, y = AGE_ADJUSTED_RATE, fill = RACE)) +
  geom_boxplot() +
  theme_minimal(base_size = 14)




# D. Geospatial Visualization
library(sf)
geo <- st_read("cb_2018_us_state_500k.shp")
geo$State <- geo$NAME

spacial_object <- geo %>%
  left_join(merged_bc_insurance, by = "State") %>%
  filter(!NAME %in% c("Hawaii", "Alaska", "Puerto Rico"))

library(leaflet)
pal <- colorNumeric("Reds", domain = spacial_object$Breast_Cancer_Incidence_Rate, na.color = "lightgray")

state_centroids <- st_centroid(spacial_object)

bcancer_insurance_map <- leaflet(spacial_object) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(fillColor = ~pal(Breast_Cancer_Incidence_Rate),
              fillOpacity = 0.7,
              color = "white",
              weight = 1) %>%
  addCircles(data = state_centroids,
             lng = ~st_coordinates(geometry)[, 1],
             lat = ~st_coordinates(geometry)[, 2],
             radius = ~Uninsured_Rate * 15000,
             fillColor = "blue",
             stroke = FALSE,
             fillOpacity = 0.4) %>%
  setView(lng = -96, lat = 37.8, zoom = 4)

library(htmlwidgets)
saveWidget(bcancer_insurance_map, file = "index.html", selfcontained = TRUE)

# E. Pie Chart
insured_pie_chart <- insurance_data %>%
  select(State = `Nation/State`, Total_Pop = 3, Insured_Pop = 5, Uninsured_Pop = 53) %>%
  mutate(across(c(Total_Pop, Insured_Pop, Uninsured_Pop), as.numeric))

us_totals <- insured_pie_chart %>%
  summarize(Insured = sum(Insured_Pop, na.rm = TRUE),
            Uninsured = sum(Uninsured_Pop, na.rm = TRUE)) %>%
  pivot_longer(cols = everything(), names_to = "Insurance_Status", values_to = "Cases") %>%
  mutate(Percent = round(100 * Cases / sum(Cases), 1),
         Label = paste0(Insurance_Status, "\n", format(Cases, big.mark = ","), "\n", Percent, "%"))

ggplot(us_totals, aes(x = "", y = Cases, fill = Insurance_Status)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5), color = "white", size = 5) +
  theme_void(base_size = 14) +
  scale_fill_manual(values = c("Insured" = "salmon1", "Uninsured" = "mediumpurple2"))




library(ggplot2)
library(ggrepel)
library(scales)

ggplot(merged_data, aes(x = reorder(State, Breast_Cancer_Incidence_Rate), 
                        y = Breast_Cancer_Incidence_Rate)) +
  geom_bar(stat = "identity", fill = "steelblue", width = 0.7) +
  geom_text(aes(label = dollar(Median_Income)), 
            hjust = -0.1, size = 3.5, color = "black") +
  coord_flip() +
  labs(
    title = "Breast Cancer Incidence Rate by State (2022)",
    subtitle = "Median Income per State is Displayed Above Each Bar",
    x = "State",
    y = "Breast Cancer Incidence Rate (per 100,000 women)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    panel.grid.minor = element_blank()
  ) +
  ylim(0, max(merged_data$Breast_Cancer_Incidence_Rate) * 1.15)  # Add space for labels




library(ggplot2)
ggplot(merged_data, aes(x = reorder(State, Breast_Cancer_Incidence_Rate), 
                        y = Breast_Cancer_Incidence_Rate)) +
  geom_col(fill = "orange") +
  geom_text(aes(label = round(Combined_Education, 1)), 
            vjust = -0.5, size = 3.5, color = "black") +
  labs(
    title = "State-wise Breast Cancer Incidence Rates in 2022 with Combined Education",
    subtitle = "Bar height = Breast Cancer Incidence Rate per 100,000 women | Label = Combined Education (%)",
    x = "U.S. States (sorted by Breast Cancer Incidence Rate, lowest to highest)",
    y = "Breast Cancer Incidence Rate (per 100,000 women)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10), hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Uninsured Rate vs Combined Education Rate bar graph
library(ggplot2)
ggplot(merged_data, aes(x = reorder(State, Uninsured_Rate), 
                        y = Uninsured_Rate)) +
  geom_col(fill = "orange") +
  geom_text(aes(label = round(Combined_Education, 1)), 
            vjust = -0.5, size = 3.5, color = "black") +
  labs(
    title = "State-wise Uninsured Rates (Ages 19-64) in 2022 with Education Context",
    subtitle = "Bar height = Uninsured Rate (%) | Label = Combined Education (%)",
    x = "U.S. States (sorted by Uninsured Rate, lowest to highest)",
    y = "Uninsured Rate (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10), hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )


# Insured Rate vs Combined Education Rate bar graph
ggplot(merged_data, aes(x = reorder(State, Insured_Rate), 
                        y = Insured_Rate)) +
  geom_col(fill = "darkorange") +
  geom_text(aes(label = round(Combined_Education, 1)), 
            vjust = 1.2, size = 3.5, color = "white", fontface = "bold") +
  labs(
    title = "State-wise Insured Rates (Ages 19-64) in 2022 with Education Context",
    subtitle = "Bar height = Insured Rate (%) | Label inside bar = Combined Education (%)",
    x = "U.S. States (sorted by Insured Rate, lowest to highest)",
    y = "Insured Rate (%)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, margin = margin(b = 10), hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )



# Breast Cancer vs Uninsured Rate and Combined Education Rate
plot_data <- merged_data %>%
  select(State, 
         `Breast Cancer Incidence Rate` = Breast_Cancer_Incidence_Rate,
         `Uninsured Rate (%)` = Uninsured_Rate,
         `Combined Education (%)` = Combined_Education) %>%
  pivot_longer(
    cols = -State,
    names_to = "Metric",
    values_to = "Value"
  )

# Step 3: Plot grouped bar chart

ggplot(plot_data, aes(x = State, y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c(
    "Breast Cancer Incidence Rate" = "#FF8C00",    # Dark orange
    "Uninsured Rate (%)" = "#DC143C",             # Crimson red
    "Combined Education (%)" = "#1E90FF"          # Dodger blue
  )) +
  labs(
    title = "State-wise Comparison: Breast Cancer, Education, and Uninsured Rate (2022)",
    x = "U.S. States",
    y = "Value (per 100k or %)",
    fill = "Metric"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 8),
    legend.position = "top"
  )

#Table of all metrics values

library(knitr)
library(kableExtra)
library(scales)

comparison_table <- merged_data %>%
  mutate(Combined_Education = round((HS_or_higher + BA_or_higher) / 2, 1)) %>%
  select(
    State,
    `Breast Cancer Incidence Rate (per 100k)` = Breast_Cancer_Incidence_Rate,
    `Uninsured Rate (%)` = Uninsured_Rate,
    `Combined Education (%)` = Combined_Education,
    `Median Income ($)` = Median_Income
  )

comparison_table %>%
  arrange(`Breast Cancer Incidence Rate (per 100k)`) %>%   # ascending order
  kable("html", digits = 1, align = "c",
        caption = "State-wise Comparison of Breast Cancer, Insurance, Education, and Income (2022) — Sorted by Breast Cancer Incidence Rate") %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"),
                full_width = FALSE, position = "center") %>%
  column_spec(2, color = "black", bold = TRUE) %>%  
  column_spec(3, color = "red") %>%                  
  column_spec(4, color = "blue") %>%                 
  column_spec(5, color = "darkgreen", background = "lightgrey")


#Bar graph with all metrics
library(tidyverse)
library(scales)

max_income <- max(merged_data$Median_Income, na.rm = TRUE)
merged_data <- merged_data %>%
  mutate(Normalized_Income = (Median_Income / max_income) * 100)

# Prepare long format data
plot_data <- merged_data %>%
  select(State,
         `Breast Cancer Incidence` = Breast_Cancer_Incidence_Rate,
         `Uninsured Rate (%)` = Uninsured_Rate,
         `Combined Education (%)` = Combined_Education,
         `Median Income (Normalized %)` = Normalized_Income) %>%
  pivot_longer(-State, names_to = "Metric", values_to = "Value")

# Plot
ggplot(plot_data, aes(x = reorder(State, Value), y = Value, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Comparison of Health and Socioeconomic Metrics by State (2022)",
    subtitle = "Includes Breast Cancer Incidence, Uninsured Rate, Education, and Income (normalized)",
    x = "States",
    y = "Value (per 100k or %)",
    fill = "Metric"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 90, vjust = 0.5, size = 8)
  )







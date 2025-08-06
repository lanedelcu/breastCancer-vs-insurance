
# 📊 Does Insurance Status Impact Breast Cancer Incidence?

### A 2022 Data Analysis by Insurance and Socioeconomic Status - using R language


---

##  Background & Motivation

Breast cancer is the most common cancer among women in the U.S. While medical advances have improved outcomes, early detection remains crucial. However, access to preventive care—like mammograms—is often tied to health insurance status.

This project began with a critical public health question:

> **Do uninsured women across U.S. states face greater barriers to early cancer detection?**

Although insurance doesn’t prevent cancer, it can facilitate earlier diagnosis and timely treatment—key elements in reducing mortality.  

🌐 Interactive Map  
👉 [Click here to explore the interactive Leaflet map](https://lanedelcu.github.io/breastCancer-vs-insurance/)  
*This map visualizes breast cancer incidence across U.S. states in 2022.* (Click on states for results)

---

##  Research Questions

1. **Do states with higher uninsured rates among women show different breast cancer incidence rates?**
2. **Could differences in reported incidence reflect access issues, like delayed diagnosis?**
3. **How do socioeconomic factors (e.g., income, education, race, rurality) intersect with insurance and outcomes?**

> *Note:* Higher reported cancer rates in insured states likely reflect better detection, not more disease.

---

##  Why These Questions Matter

* Health disparities stem from systemic inequities—not just biology.
* If uninsured women are being diagnosed later, this exposes a preventable gap in healthcare.
* Insights from this analysis can guide resource allocation, outreach efforts, and policy reform.

---

## 📊 Key Visual Findings

### 1. **Scatter Plot: Breast Cancer Incidence vs. Insured Rate (2022)**

* **Correlation:** Positive
* **Insight:** States with more insured women report more cases—likely due to improved screening access.

### 2. **Scatter Plot: Breast Cancer Incidence vs. Uninsured Rate (2022)**

* **Correlation:** Negative
* **Insight:** Higher uninsured rates = fewer diagnoses. This doesn’t imply less cancer—it may reflect underdiagnosis.
* **Red Flag:** States like Alabama, Alaska, and North Carolina have both high uninsured rates *and* high incidence—indicating delayed diagnosis or unequal care access.

### 3. **Geospatial Map: Regional Patterns**

* **Northeast (e.g., NY, MA, VT):** High insurance, high incidence → likely effective screening.
* **South/Southeast (e.g., GA, TX, MS):** Low insurance, low incidence → possible underdiagnosis.
* **Double Burden States:** Montana, Idaho, South Dakota, Kansas, Alabama, Georgia → high incidence *and* high uninsured rates.

### 4. **Pie Chart: Estimated Breast Cancer Cases by Insurance Status**

* Most diagnosed cases come from insured populations—not due to higher risk, but better detection.
* Limitation: Insurance data includes all genders; breast cancer data is female-only (ages 19–64).

---

##  Regional Insights

###  High-Risk Clusters

* **Georgia, Alabama, Montana, South Dakota, Kansas**:

  * High uninsured rates
  * Elevated breast cancer incidence
  * Limited Medicaid expansion, rural barriers, and underfunded detection programs

###  CDC NBCCEDP Funding Comparison

* **Low Funding (\~\$750K):** AL, MT, ID, SD
* **Moderate Funding (\~\$1.5M–\$2.5M):** KS, GA
* **High Funding (\~\$4M+):** NY, MI, IL

> Funding and Medicaid expansion status appear linked to screening success.

---

##  The Chain of Impact

**Education → Income → Insurance → Screening → Detection**

### Educated/Insured States:

* **Examples:** Massachusetts, Colorado, New York
* **Traits:** Higher detection, lower uninsured, stronger outcomes

### Less-Educated/Uninsured States:

* **Examples:** Mississippi, Arkansas, West Virginia
* **Traits:** Fewer screenings, lower incidence (possibly underdiagnosed), higher late-stage presentation

---

##  Methods & Data

### 🔹 Primary Data Source:

* U.S. Cancer Statistics (2022)

### 🔹 Supplementary Data:

* U.S. Census (Health Insurance Coverage, Education)
* Federal NBCCEDP Funding Data (CDC)
* Shapefiles for U.S. states (geospatial analysis)

### 🔹 Age Group Focus:

* **Women aged 19–64** (non-Medicare population)

### 🔹 Analysis Techniques:

* Data cleaning and standardization
* Scatter plots with trendlines and labels
* Boxplots by race
* Geospatial visualization using Leaflet and shapefiles
* Multiple regression (adjusting for region, income, education)

---

##  Key Conclusions

* **Insurance significantly impacts detection:** States with high insurance report more cases, likely due to better screening.
* **Underdiagnosis is a concern:** States with low incidence and low insurance may simply not be catching cases.
* **Double-burden states** face critical challenges—high cancer burden with inadequate insurance and access.
* **Socioeconomic factors drive detection:** Income, education, and policy environment all matter.

---

##  Future Work

To build on this analysis:

* Include **mortality** and **stage-at-diagnosis** data
* Consider **urban vs. rural** healthcare availability
* Examine **insurance type** (public vs. private)
* Factor in **Medicaid expansion** status and timeline
* Explore **racial disparities** across regions

These layers will help target cancer prevention and early detection strategies in the most vulnerable communities.

---

## 📁 Repository Contents


```bash
├── 📂data/                 # All datasets (CSV, Excel, Shapefile)
├── 📂scripts/              # R scripts 
├── 📂output/               # Visualizations, 
├── index.html            # Leaflet interactive map (GitHub Pages)
├── README.md             # this file
```

---

## ✍️ Authors

**Lavinia Nedelcu, Hamdam Aynazarov, Dr. Haima Kazi**
Summer 2025 Data Camp, NEIU

---


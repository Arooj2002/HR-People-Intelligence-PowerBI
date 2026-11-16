# People Intelligence: HR Analytics Dashboard (Power BI)

An end-to-end HR analytics report built in Power BI. It brings together four data sources in a star-schema model and turns them into insights on headcount, attrition, pay fairness and flight risk, with drill-through down to individual employees.

![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=powerbi&logoColor=black)
![DAX](https://img.shields.io/badge/DAX-1F3A5F?style=flat)
![Power Query](https://img.shields.io/badge/Power%20Query%20(M)-0F9D8A?style=flat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)

![Executive Summary](Screenshots/01_executive_summary.png)

📄 **[View the full report as PDF](HR_Dashboard.pdf)**

---

## Business questions answered

- How is headcount trending, and is attrition above or below the 12% target?
- Which departments and cities lose the most people, and what does it cost?
- Are employees paid fairly compared with the market (compa-ratio)?
- Which active employees are at high risk of leaving, and how much payroll is at stake?
- What does an individual employee's history look like: pay, performance, absence and job changes?

---

## Key insights

- **Sales, Karachi** is paid about 14% below market (compa-ratio 0.86) and has the highest attrition. "Better compensation" is the top exit reason.
- **Engineering, Lahore** waits about 40 months for a promotion, compared with about 29 months elsewhere.
- **89 active employees** are high flight risk, representing about **$1.6M** in annual payroll.
- **Agency hires** have the lowest 12-month retention of any hiring source.
- **Late arrivals double during Ramadan**, from about 6% to 12%.

---

## Report pages

| Page | What it shows |
|---|---|
| **Executive Summary** | KPI cards (headcount, rolling 12M attrition, cost of attrition, eNPS), attrition vs target bar, pay-vs-market gauge, flight-risk distribution and a KPI trend switched by a field parameter |
| **Attrition & People** | Department attrition ranking, compa-ratio vs attrition scatter with play axis, hire-cohort retention heatmap and workforce breakdowns |
| **Employee 360** *(drill-through)* | Profile, flight-risk gauge, absence and Bradford factor, pay vs market over time, performance by cycle and job history |
| **Department tooltip** *(hidden)* | Hover card with headcount, attrition, pay ratio and trend for any department |

| Attrition & People | Employee 360 |
|---|---|
| ![](Screenshots/02_attrition_people.png) | ![](Screenshots/03_employee_360.png) |

| Department tooltip | Mobile layout |
|---|---|
| ![](Screenshots/04_tooltip.png) | ![](Screenshots/05_mobile.png) |

---

## Data sources

| Source | Data |
|---|---|
| **PostgreSQL** | Employees, departments, locations, job history, separations, monthly payroll, daily attendance |
| **Excel** | Compensation bands and grades, performance reviews (5 review cycles appended) |
| **CSV** | Recruitment (ATS) and training (LMS) system exports |
| **Google Sheets** | Pulse survey responses, HR configuration (attrition cost, flight-risk weights) |

All data is synthetic and generated for this project. It covers January 2024 to October 2026 for about 1,200 employees.

---

## Data model

![Data model](Screenshots/06_data_model.png)

- **Star schema** with 8 fact tables and 7 dimensions
- **Role-playing dimension**: Manager, built from the Employee table
- **Inactive relationships** on hire, join and completion dates, used through `USERELATIONSHIP`
- **Composite model**: daily attendance in DirectQuery, all other tables in Import, plus a pre-aggregated absence table
- **Date table** built in Power Query with a July–June fiscal year

---

## Technical features

**Power Query (M)**
- Custom function to clean column names across all sources
- Staging queries, merge and append, query folding kept intact for the database tables

**DAX**
- Time intelligence: rolling 12-month attrition, YoY change, fiscal year-to-date cost
- `CALCULATE`, `USERELATIONSHIP`, `TREATAS`, `CROSSFILTER`, `RANKX`, `LOOKUPVALUE`
- Hire-cohort retention, Blau diversity index, compa-ratio against market bands
- Weighted flight-risk score with dynamic segmentation (Low / Medium / High)
- Animated SVG measures for the attrition bar and compa-ratio gauge
- Dynamic title that reacts to slicer selections

**Report design and interactivity**
- Custom theme (JSON) with a consistent colour palette
- Icon-based page navigation and a reset button using bookmarks
- Report-page tooltip, drill-through with a Back button, synced slicers
- Field parameter to switch the KPI shown on the trend chart
- Conditional formatting with rules, gradients and field values
- Mobile layout and PDF export

---

## Repository structure

```
├── HR_Dashboard.pbix      Power BI report
├── HR_Dashboard.pdf       PDF export of the report
├── Data/                  Source data for all four sources
├── Model/                 Relationship script (TMDL)
├── Theme/                 Custom report theme (JSON)
└── Screenshots/           Images used in this README
```

---

## How to run

1. Create a PostgreSQL database and load the data:
   ```
   psql -U postgres -c "CREATE DATABASE hr_analytics"
   psql -U postgres -d hr_analytics -f Data/1_PostgreSQL/HR_full_load.sql
   ```
   Optionally run `03_validation_checks.sql`. Every check should return 0.
2. Upload the two files in `Data/4_Google_Sheets` to Google Drive and save each one as a Google Sheet.
3. Open `HR_Dashboard.pbix` in Power BI Desktop.
4. Go to **Transform data → Data source settings** and update the database server, file paths and Google Sheet URLs.
5. Click **Refresh**.

---

*All names, IDs and figures are fictional and were generated for this portfolio project.*

# Pharma Batch Quality Monitoring Dashboard

**Tool:** Microsoft Power BI  
**Dataset:** Simulated GMP batch manufacturing records (600 batches, 4 sites, Jan 2024 – Jun 2026)  
**Regulatory framework:** ICH Q7, ICH Q10, 21 CFR Part 11  
**Author:** Ramya Sri Jayashanker Chithra  
**Status:** In progress — dashboard build active

---

## Purpose

This project simulates a pharmaceutical batch quality monitoring system 
modelled on GMP manufacturing operations across multiple Irish pharma sites 
(Ballydine, Carlow, Dunboyne, Brinny). It was built to develop practical 
understanding of how data flows from the production floor through quality 
decision-making systems in a regulated manufacturing environment.

---

## What It Monitors

- **Critical Quality Attributes (CQAs):** Assay %, Dissolution %, pH, Moisture %
- **Batch yield** across four simulated manufacturing sites
- **Out-of-Specification (OoS) rate** benchmarked against a 5% quality threshold
- **Deviations and CAPAs** by site, product, and operator
- **Statistical Process Control (SPC):** Shewhart control charts with 3-sigma 
  UCL/LCL, spec limits, and mean reference lines

---

## Simulation Design

Dataset generated in R using `dplyr` and `lubridate` with the following parameters:

| Parameter | Value | Rationale |
|---|---|---|
| Total batches | 600 | Sufficient for monthly trend analysis across 30 months |
| OoS rate | ~5% | Consistent with ICH Q7 commercial manufacturing benchmarks |
| Assay spec | 97.0 – 101.0% | Typical finished product release specification |
| Dissolution spec | >= 80% at 45 min | Standard USP dissolution acceptance criterion |
| pH spec | 6.8 – 7.4 | Physiologically relevant parenteral product range |
| Moisture spec | <= 0.5% | Stability-critical limit for solid dosage forms |
| Sites | Ballydine, Carlow, Dunboyne, Brinny | Modelled on MSD Ireland's manufacturing network |

---

## Dashboard Pages

1. **Executive Overview** — KPI cards (600 batches, 95% pass rate, 64 deviations), 
   monthly pass rate trend, batch status distribution
2. **SPC Control Charts** — Shewhart control charts for Assay, Dissolution, pH, 
   and Moisture with UCL/LCL and spec limits
3. **OoS Deep Dive** — Failure mode analysis by product and site *(in progress)*
4. **Operator and Site Performance** — Cross-site yield trends *(in progress)*
5. **Deviation and CAPA Tracker** — Audit trail view *(in progress)*

---

## Regulatory Context

In a GMP manufacturing environment, batch quality data is governed by 
21 CFR Part 11 (electronic records and signatures) and ICH Q10 
(pharmaceutical quality system). This dashboard simulates the analytical 
layer between raw production data and quality release decisions — the layer 
managed by digital manufacturing operations teams in modern Irish pharma facilities.

The distinction between control limits and specification limits is central 
to this dashboard: spec limits are the regulatory boundary; control limits 
are the statistical early warning system. SPC exists to detect process drift 
before it reaches the spec limit — enabling right-first-time manufacturing.

---

## Tools

- R 4.x (dplyr, lubridate) — dataset simulation
- Microsoft Power BI Desktop — dashboard development  
- DAX — calculated measures for SPC control limits and KPIs
- GitHub — version control and portfolio hosting

---

## Files

| File | Description |
|---|---|
| `pharma_batch_simulator.R` | R script to generate the simulated dataset |
| `pharma_batch_data.csv` | Simulated dataset (600 batch records, 20 variables) |
| `PharmaQualityDashboard.pbix` | Power BI dashboard file |

---

## Screenshot

*Dashboard screenshots to be added on completion.*

---

*Built as a portfolio project to demonstrate pharmaceutical manufacturing 
data literacy and digital operations knowledge ahead of MSD Ireland's 
2027 Graduate Programme application.*

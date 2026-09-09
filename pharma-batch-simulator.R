#pharma batch simulator
#Simulates GMP pharmaceutica batch manufacturing records for a quality monitoring
#Power BI dashboard project.
#Author: Ramya Sri Jayashanker Chithra
#Reference framework: ICH Q7 (GMP for Active Pharmaceutical INgredients),
#                     ICH Q10 (Pharmaceutical Quality System)

library(dplyr)
library(lubridate)

set.seed(24)

#CONFIFIGURATION

N_BATCHES <- 600

sites <- c("Ballydine", "Carlow", "Dunboyne", "Brinny")

products <- data.frame(
  product_name = c("Keytruda-API", "Gardasil-Fill",
                   "Biologics-DS-A", "Biologics-DS-B",
                   "Oncology-BioTx_01", "HepC-API"),
  sites = c("Ballydine", "Carlow",
            "Dunboyne", "Dunboyne",
            "Brinny", "Ballydine"),
  target_assay = c(99.0, 98.5, 97.5, 98.0, 98.8, 99.2),
  target_yield = c(88.0, 91.0, 85.0, 86.0, 87.0, 89.0),
  stringsAsFactors = FALSE
)

operators <- paste0("OP-", sprintf("%03d", 1:20))

#Oos rate approximately 4%
OOS_RATE <- 0.04

#DATE RANGE

start_date <- as.Date("2024-01-01")
end_date <- as.Date("2026-06-30")
date_range_days <- as.numeric(end_date - start_date)

#GENERATE BATCHES
records <- vector("list", N_BATCHES)

for (i in seq_len(N_BATCHES)) {
  
  #Sample product and retrieve its site and targets
  prod_row <- products[sample(nrow(products) ,1), ]
  product_name <- prod_row$product_name
  site <- prod_row$site
  target_assay <- prod_row$target_assay
  target_yeild <- prod_row$target_yield
  
  #Manufacturing date -- beta-weighted toward recent months
  days_offset <- round(rbeta(1, 2, 1.5) * date_range_days)
  manufacture_date <- start_date + days_offset
  release_date <- manufacture_date + sample(5:18, 1)
  
  #Batch number
  batch_no <- paste0(
    "BN-", toupper(substr(site, 1, 3)), "-",
    format(manufacture_date, "%Y%m"), "-",
    sprintf("%04d", i)
  )
  
  #Operator
  operator <- sample(operators, 1)
  
  #Oos FLAG
  is_oos <- runif(1) < OOS_RATE
  
  #ASSAY % -- spec: 97.0 to 101.0
  if (is_oos) {
    direction <- sample(c("low", "high"), 1)
    assay <- if (direction == "low") round(runif(1, 94.0, 96.9), 2) else
                                    round(runif(1, 101.1, 103.0), 2)
  } else {
    assay <- round(pmin(pmax(rnorm(1, target_assay, 0.6), 97.0), 101.0), 2)
  }
  
  #DISSOLUTION % -- spec: >= 80 at 45 min
  dissolution <- round(rnorm(1, 88.0, 3.5), 2)
  if (is_oos) dissolution <- round(runif(1, 70.0, 79.9), 2)
  dissolution <- max(dissolution, 60.0)
  
  #pH -- spec: 6.8 to 7.4
  pH <- round(rnorm(1, 7.1, 0.12), 2)
  if (is_oos && runif(1) > 0.5) {
    pH <- round(
      ifelse(runif(1) > 0.5,
             runif(1, 6.3, 6.79),
             runif(1, 7.41, 7.8)),
    2)
  }
  
  #MOISTURE % -- spec: <= 0.5
  moisture <- round (rnorm(1, 0.28, 0.07), 3)
  if (is_oos && runif(1) > 0.6) {
    moisture <- round(runif(1, 0.51, 0.75), 3)
  }
  moisture <- max(moisture ,0.05)
  
  #YIELD %
  yield_pct <- round(rnorm(1, target_yeild, 2.5), 2)
  if (is_oos) yield_pct <- round(runif(1, 72.0, 82.0), 2)
  yield_pct <- pmin(pmax(yield_pct, 65.0), 99.5)
  
  #BATCH SIZE
  batch_size_kg <- round(
    sample(c(50, 100, 200, 250), 1) + runif(1, -5, 5), 1
  )
  
  #PASS / FAIL
  assay_fail <- !(assay >= 97.0 & assay <= 101.0)
  dissolution_fail <- dissolution < 80.0
  pH_fail <- !(pH >= 6.8 & pH <= 7.4)
  moisture_fail <- moisture > 0.5
  
  any_fail <- any(c(assay_fail, dissolution_fail, pH_fail, moisture_fail))
  result <- if (any_fail) "Fail" else "Pass"
  
  #Batch status
  status <- if (any_fail) {
    sample(c("Under Review", "Rejected"), 1)
  } else {
    "Released"
  }
  
  #Deviation raised
  deviation_raised <- if (any_fail) "Yes" else
    if (runif(1) < 0.05) "Yes" else "No"
  capa_required <- if (deviation_raised == "Yes") "Yes" else "No"
  
  #STORE RECORD
  records[[i]] <- data.frame(
    Batch_No = batch_no,
    Product = product_name,
    Site = site,
    Manufacture_Date = manufacture_date,
    Release_Date = release_date,
    Operator_ID = operator,
    Batch_Size_kg = batch_size_kg,
    Assay_pct = assay,
    Dissolution_pct = dissolution,
    pH = pH,
    Moisture_pct = moisture,
    Yield_pct = yield_pct,
    Assay_Fail = if (assay_fail) "Yes" else "No",
    Dissolution_Fail = if (dissolution_fail) "Yes" else "No",
    pH_Fail = if (pH_fail) "Yes" else "No",
    Moisture_Fail = if(moisture_fail) "Yes" else "No",
    Result = result,
    Batch_Status = status,
    Deviation_Raised = deviation_raised,
    CAPA_Required = capa_required,
    stringsAsFactors = FALSE
  )
} 

#COMBINE AND SORT
df <- bind_rows(records) %>%
  arrange(as.Date(Manufacture_Date)) %>%
  mutate(Manufacture_Date = as.character(Manufacture_Date))

#EXPORT
write.csv(df, "D:/Documents/Project-Portfolio/Pharma-Batch-Quality-Monitoring/pharma_batch_data.csv", row.names = FALSE)

#SUMMARY
cat("Dataset generated:", nrow(df), "batches\n")
cat("Oos / Fail batches:",
    sum(df$Result == "Fail"),
    paste0("(", round(mean(df$Result == "Fail") * 100, 1), "%)\n"))
cat("Sites:\n")
print(table(df$Site))
cat("Products:", length(unique(df$Product)), "unique\n")
cat("Date range:",
    min(df$Manufacture_Date), "to", max(df$Manufacture_Date), "\n")
cat("\nFirst 3 rows:\n")
print(head(df,3))

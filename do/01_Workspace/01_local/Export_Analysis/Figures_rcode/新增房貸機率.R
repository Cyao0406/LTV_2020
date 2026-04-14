# ---- 套件 ----
library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(purrr)

# ---- 1) 讀取並整理 Stata 輸出表 ----
# 這份表的特色：每個變數有兩列：第一列是係數，下一列括號()是標準誤
path <- "C:/Users/user/OneDrive/桌面/114/RA with Tzu-Ting/houseloan/result/Dynamic_DID_results.xlsx"

# 讀第一個工作表、全部欄位先以文字讀入，避免 "0.003***" 被吃掉
raw <- read_excel(path, sheet = 1, col_types = "text")

# 只取 A~F 欄（A: 變數名；B~F: (1)~(5)）
tab <- raw %>%
  select(1:6) %>%
  setNames(c("term","m1","m2","m3","m4","m5"))

# 長表化
long <- tab %>%
  pivot_longer(m1:m5, names_to = "model", values_to = "value") %>%
  # 兩列一組：係數列（非括號開頭）與 SE 列（括號開頭）
  mutate(is_se = str_detect(value %||% "", "^\\("),
         # 有些 SE 會像 "(0.000123)"，把括號等符號清掉成數字
         num = suppressWarnings(as.numeric(str_replace_all(value %||% "", "[^0-9eE+\\.-]", "")))) %>%
  # 讓第二列(標準誤)承接上一列的 term
  fill(term, .direction = "down") %>%
  group_by(term, model) %>%
  summarise(
    estimate = num[!is_se][1],   # 第一列（非括號）的數值
    se       = num[is_se][1],    # 下一列（括號）的數值
    .groups = "drop"
  )

# ---- 2) 抽出 event-time 係數（pre_event_k / post_event_k），轉成時間軸 ----
did <- long %>%
  filter(str_detect(term, "^pre_event_|^post_event_")) %>%
  mutate(event_time = case_when(
    str_starts(term, "pre_event_")  ~ -as.integer(str_extract(term, "\\d+")),
    str_starts(term, "post_event_") ~  as.integer(str_extract(term, "\\d+"))
  )) %>%
  arrange(model, event_time) %>%
  mutate(
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se,
    model = recode(model, m1="(1)", m2="(2)", m3="(3)", m4="(4)", m5="(5)")
  )


#（可選）給每個模型一個固定顏色
pal <- c("(1)"="#0066FF","(2)"="#0066FF","(3)"="#0066FF",
         "(4)"="#0066FF","(5)"="#0066FF")

# 確保輸出資料夾存在
outdir <- "fig_dynamic_did"
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

# 定義：畫單一模型的圖
plot_one_model <- function(m) {
  dat <- did %>% filter(model == m) %>% arrange(event_time)
  
  p <- ggplot(dat, aes(event_time, estimate, ymin = ci_lo, ymax = ci_hi)) +
    geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.3, color = "grey60") +
    geom_vline(xintercept = 0, linetype = "dotted", linewidth = 0.3, color = "grey60") +
    geom_ribbon(fill = pal[m], alpha = 0.18, linewidth = 0) +
    geom_line(color = pal[m], linewidth = 0.9) +
    geom_point(color = pal[m], size = 1.8) +
    labs(title = paste0("Dynamic DID Trend — ", m),
         x = "Event time (0 = treatment period)", y = "Coefficient (95% CI)") +
    theme_minimal(base_size = 12)
  
  # 檔名：dynamic_did_01.png、02...（從 model 提取數字補零）
  idx <- str_pad(str_extract(m, "\\d+"), width = 2, side = "left", pad = "0")
  file <- file.path(outdir, paste0("dynamic_did_", idx, ".png"))
  
  ggsave(filename = file, plot = p, width = 6.5, height = 4.2, dpi = 300,bg = "white")
  message("Saved: ", file)
  invisible(p)
}

# 逐一輸出 (1)~(5)
unique_models <- did %>% pull(model) %>% unique()
walk(unique_models, plot_one_model)
#FLIM_EEG Data Analysis - Escitalopram and Neuroplasticity Project, Zsido & Molloy et al.
#Code by Eoin N Molloy
###############################################################################################################################################
#0 Load necessary packages
library(magrittr)
library(dplyr)
library(lme4)
library(car)
library(lmerTest)
library(psych)
require(MuMIn)
library(ggpubr)
###############################################################################################################################################
#1 set directory
setwd('/users/Eoin/Documents/FLIM/')
lmer_data <-read.csv("FLIM_Data.csv", header = T)
lmer_data$day = factor(lmer_data$Day)
lmer_data$group = factor(lmer_data$Group)
str(lmer_data)
means <-read.csv("FLIM_Data_Wide.csv", header = T)

#2 baseline control tests - groups accurately randomized?
#2A Flicker:
t.test(Flicker_Base ~ Group, data = means, var.equal = FALSE) # Not Significant
#2B Fusion
t.test(Fusion_Base ~ Group, data = means, var.equal = FALSE) # Significant!

#3 Linear modelling
#3A Flicker on just assessment week including error scores also as a covariate:
lmer_data_AW <- subset(lmer_data, Day != "4", rename=c())
flicker_interaction_AW <- lmer(Flicker ~ group*day + Flicker_Error + (1|SubID), data = lmer_data_AW, REML = F)
anova(flicker_interaction_AW) # No Significant Effect

#3B Flicker now including Follow-up:
flicker_interaction_Full <- lmer(Flicker ~ group*day + Flicker_Error + (1|SubID), data = lmer_data, REML = F)
anova(flicker_interaction_Full) #No Significant Effect

#3C Fusion (normalized for baseline given result from 2B) on just assessment week, including error scores as covariate
fusion_normed <- subset(lmer_data, Day != "1" & Day != '4', rename=c())
fusion_normed_AW <- lmer(Fusion_Normed ~ group*day + Fusion_Error + (1|SubID), data = fusion_normed, REML = F)
anova(fusion_normed_AW) #Significant Time and Interaction Effect

#3D Fusion (normalized for baseline given result from 2B) including FU:
fusion_normed_FULL <- subset(lmer_data, Day != "1", rename=c())
fusion_normed <- lmer(Fusion_Normed ~ group*day + Fusion_Error + (1|SubID), data = fusion_normed_FULL, REML = F)
anova(fusion_normed) #Significant Interaction Effect

#3E Fusion analyses but matched for EEG subjects in just the assessment week:
eeg_fus <- subset(lmer_data, SubID != "060" & SubID!= "004" & SubID!= "042" & SubID!= "080" & SubID!= "065", rename=c())
fusion_normed_AW <- subset(eeg_fus, Day != "1" & day != "4", rename=c())
fusion_eeg_sample_AW_Normed <- lmer(Fusion_Normed ~ group*day + Fusion_Error + (1|SubID), data = fusion_normed_AW, REML = F)
anova(fusion_eeg_sample_AW_Normed)#Significant Time and Interaction Effect

#3F And now including the FU
fusion_normed <- subset(eeg_fus, Day != "1", rename=c())
fusion_eeg_sample_Normed <- lmer(Fusion_Normed ~ group*day + Fusion_Error + (1|SubID), data = fusion_normed, REML = F)
anova(fusion_eeg_sample_Normed)# Not significant

#4A Post hoc ttests on each timepoint for Fusion analysis - 2 samples
t.test(Fusion_D1_Normed ~ Group, data = means, var.equal = FALSE) #Not Significant
t.test(Fusion_D7_Normed ~ Group, data = means, var.equal = FALSE)#Not Significant
t.test(Fusion_FU_Normed ~ Group, data = means, var.equal = FALSE)#Not Significant

#4B Post hocs within each group separately
escit <- subset(means, Group != "Placebo", rename=c()) # subset just to drug group
t.test(escit$Fusion_D1_Normed, escit$Fusion_D7_Normed, paired = TRUE, alternative = "two.sided") # not significant
t.test(escit$Fusion_D1_Normed, escit$Fusion_FU_Normed, paired = TRUE, alternative = "two.sided") # not significant
t.test(escit$Fusion_D7_Normed, escit$Fusion_FU_Normed, paired = TRUE, alternative = "two.sided") # not significant

plac <- subset(means, Group != "Escitalopram", rename=c()) # subset just to placebo group
t.test(plac$Fusion_D1_Normed, plac$Fusion_D7_Normed, paired = TRUE, alternative = "two.sided") # significant :(
t.test(plac$Fusion_D1_Normed, plac$Fusion_FU_Normed, paired = TRUE, alternative = "two.sided") # not significant
t.test(plac$Fusion_D7_Normed, plac$Fusion_FU_Normed, paired = TRUE, alternative = "two.sided") # not significant

#5 Does Normalised Fusion correlation with Slope in drug group?
FLIM_Slope <-read.csv("FLIM_Slope.csv", header = T)
escit <- subset(FLIM_Slope, Group != "Placebo", rename=c()) # subset just to drug group
cor.test(escit$Fusion_D1_Normed, escit$Slope_D1, method = "pearson") #Not significant
cor.test(escit$Fusion_D7_Normed, escit$Slope_D7, method = "pearson") #Significant

#6 Does slope at baseline predict normalised Fusion at D1, D7, or at FU?
Fusion_Slope <-read.csv("Fusion_Slope_Predict.csv", header = T)
linearMod_1 <- lm(Slope_Baseline ~ Fusion_D1N, data=Fusion_Slope) # Not significant
summary(linearMod_1)
linearMod_2 <- lm(Slope_Baseline ~ Fusion_D7N, data=Fusion_Slope) # Not significant
summary(linearMod_2)
linearMod_3 <- lm(Slope_Baseline ~ Fusion_FUN, data=Fusion_Slope) # Not significant
summary(linearMod_3)
#################################################################################################
# Summary - 
# Flicker: No significant effects - Post-hocs not performed, several outliers ID'd by boxplots,
# QC data re-analysed below - no change in outcomes

# Fusion: Baseline differences, data normalised for baseline differences by subtracting baseline values from every other timepoints values,
# Significant time and interaction effects when looking at just assessment week and a signifacnt interaction when looking at all timepoints together,
# No group differences at any timepoint,
# Boxplots ID 1 placebo subject as an outlier at baseline and 2 escitalopram subjects as outliers as Day1. Subjects NOT removed from analysis,
# as they are not outliers at more than 1 timepoint,
# When looking at fusion again in the 59 subjects from the EEG analysis, the assessment week is the same outcome, though there is no effect,
# when looking at FU
# No indication of correlation between Normed Fusion and Slope at Day1, but sig correlation at Day7,
# Slope does not predict Normed Fusion outcomes at either Day1, Day7, or FU
#################################################################################################

#6 Sensitivity analysis on Flicker with possible outliers excluded n = 3 (placebo = 1)
flicker_sense <-read.csv("FLIM_Data_Flicker_Exclude.csv", header = T)
flicker_sense$day = factor(flicker_sense$Day)
flicker_sense$group = factor(flicker_sense$Group)
str(flicker_sense)
flicker_sense_means <-read.csv("FLIM_Data_Wide_Flicker_Exclude.csv", header = T)
#6A Flicker baseline control tests - groups accurately randomized?
t.test(Flicker_Base ~ Group, data = flicker_sense_means, var.equal = FALSE) # Not Significant
#6B  Linear modelling
#Flicker with exclusions on just assessment week including error scores also as a covariate:
flicker_sense_AW <- subset(flicker_sense, Day != "4", rename=c())
flicker_interaction_AW <- lmer(Flicker ~ group*day + Flicker_Error + (1|SubID), data = flicker_sense_AW, REML = F)
anova(flicker_interaction_AW) # No Significant Effect
#3B Flicker now including Follow-up:
flicker_interaction_Full <- lmer(Flicker ~ group*day + Flicker_Error + (1|SubID), data = flicker_sense, REML = F)
anova(flicker_interaction_Full) #No Significant Effect
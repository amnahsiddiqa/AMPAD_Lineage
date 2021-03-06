source('MiscPreprocessing.R')



Dat <- read.delim('Data/MAYO_CBE_TCX_logCPM.tsv',stringsAsFactors = F)
Dat2 <- read.delim('Data/MAYO_CBE_TCX_Covariates.tsv',stringsAsFactors = F)

Cov <- read.csv('Data/mayo_igap_snps.csv',stringsAsFactors = F)
Cov[,2:22] <- round(Cov[,2:22])

#AMP_mods <-  read.csv('Data/TCX_AMPAD_Modules.csv')
AMP_mods <-  read.csv('Data/TCX_DE.csv')
#AMP_mods <-  read.csv('DLPFC_DE.csv')
In <- which(AMP_mods$logPV >= 1)
AMP_mods <- AMP_mods[In,]




#Normalize all columns 

GeneNames <- Dat$ensembl_gene_id
GeneNamesAD <- AMP_mods$GeneID

Names <- colnames(Dat)

for (i in 1:length(Names)){
  
  Names[i] <- substring(Names[i],2)
  
}


colnames(Dat) <- Names
cNames <- Dat2$SampleID
l <- length(Names)

#deleting columns not in the covariate list
temp <- rep(T,l)
for (i in 1:l){
  if (!(Names[i] %in% cNames)){
    temp[i] <- F
  }
}

In <- which(temp)
#print(temp)
Dat <- Dat[,In]

#deleting extra rows in covariate list
Names <- Names[In]
l <- length(cNames)
temp <- rep(T,l)
for (i in 1:l){
  if (!(cNames[i] %in% Names)){
    temp[i] <- F
  }
}
In <- which(temp)
Dat2 <- Dat2[In,]


DatNorm <- ColNorm(Dat)
In_genes <- which(GeneNames %in% GeneNamesAD)
#In_genes <- Get.High.Var.Genes(Dat)
DatNorm2 <- DatNorm[In_genes,]
GeneNamesAD <- GeneNames[In_genes]


In_BR <- grep('TCX',Dat2$Tissue.Diagnosis)
#In_BR <- grep('DLPFC',Dat2$Tissue.Diagnosis)
DatNorm3 <- DatNorm2[,In_BR]
Dat3 <- Dat2[In_BR,]

Sex <- 'FEMALE'
In_S <- which(Dat3$Sex == Sex)
DatNorm4 <- DatNorm3[,In_S]
Dat4 <- Dat3[In_S,]

In_cov <- which(Cov$ID %in% Dat4$Donor_ID)
Cov <- Cov[In_cov,]
In_cov <- c()
for(i in 1:length(Dat4$Donor_ID)){
  temp <- which(Cov$ID == Dat4$Donor_ID[i])
  In_cov <- c(In_cov,temp[1])
}
Cov <- Cov[In_cov,]

for (i in 23:26){
  Cov[,i] <- (Cov[,i] - min(Cov[,i]))/(max(Cov[,i])-min(Cov[,i]))
}

source('LineageFunctions.R')
temp <- DatNorm4
temp2 <- cbind(Dat4,Cov)

gene_short_name <- Make.Gene.Symb(GeneNamesAD)

rownames(temp) <- NULL
colnames(temp) <- NULL
MonRun <- RunMonocleTobit(temp, temp2, C_by = 'Pseudotime',gene_short_name = gene_short_name)


plot_cell_trajectory(MonRun, color_by = "Tissue.Diagnosis")

#Get p-values for cell type specific marker expression
load('./Data/mouseMarkerGenes.rda')
In_ct <- which(gene_short_name %in% toupper(mouseMarkerGenes$Cortex$Pyramidal))
Dat_ct <- Rescale.Rows(temp[In_ct,])
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$coefficients[,4][2]
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$r.squared

In_ct <- which(gene_short_name %in% toupper(mouseMarkerGenes$Cortex$Microglia))
Dat_ct <- Rescale.Rows(temp[In_ct,])
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$coefficients[,4][2]
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$r.squared

In_ct <- which(gene_short_name %in% toupper(mouseMarkerGenes$Cortex$Oligo))
Dat_ct <- Rescale.Rows(temp[In_ct,])
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$coefficients[,4][2]
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$r.squared

In_ct <- which(gene_short_name %in% toupper(mouseMarkerGenes$Cortex$Astrocyte))
Dat_ct <- Rescale.Rows(temp[In_ct,])
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$coefficients[,4][2]
summary(lm(colMeans(Dat_ct) ~ MonRun$Pseudotime))$r.squared



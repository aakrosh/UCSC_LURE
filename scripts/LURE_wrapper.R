# LURE_wrapper.R
# David Haan 2019
# This script is a wrapper script for running the LURE method.
# LURE's input arguments are passed as command line arguments to this script
# It is set up to load the PANCAN gene expression data as feature data, but this will change

run_timestamp<-strftime(Sys.time(),"%Y_%m_%d_%H_%M")

run_timestamp<-strftime(Sys.time(),"%Y_%m_%d_%H_%M")

print("Running LURE Wrapper Script")

INPUT<-"./input/"
TEMP<-"./temp/"
# SCRIPTS<-"/lure_scripts/" # for tackle_box
SCRIPTS<-"./scripts/"
OUTPUT<-"./output/"
source(paste(sep="",SCRIPTS,"LURE_functions.R"))
registerDoMC(detectCores()/2)

option_list = list(
  make_option(c("--folds"), type="numeric", default=10,
              help="Number of Cross Validation Folds.", metavar="character"),

  make_option(c("--num_permutations"), type="numeric", default=5,
              help="Number of Permutations/Iterations.", metavar="character"),

  make_option(c("--min_gene_set_size"), type="numeric", default=4,
              help="Catch event minimum size: parameter for SSEA; only events with <min_gene_set_size> or more mutated samples are considered.", metavar="character"),

  make_option(c("--percent_overlap"), type="numeric", default=.5,
              help=" If <percent_overlap> of the samples harboring the potential catch event are in the existing bait sample set  then we skip it. A smaller number is more restrictive.",
              metavar="character"),

  make_option(c("--max_tree_length"), type="numeric", default=5,
              help="Max Tree Length: Here we set the max length of the Event Discovery Tree (EDT). A longer EDT will result in longer run times.", metavar="character"),

  make_option(c("--bait_gene"), type="character", default="SF3B1-SET1_MISSENSE",
              help="Bait gene name. Must be present in the provided gmt file. Multiple baits are allowed separated by a semicolon.", metavar="character"),

  make_option(c("--gmt_file"), type="character", default="positive_control_SF3B1_missense.gmt",
              help="Gene Matrix Transposed (gmt) formatted file. Each line in the file lists a mutation and the samples harboring the mutation. See positive control files for examples.", metavar="character"),

  make_option(c("--gsea_fdr_threshold"), type="numeric", default=.25,
              help="FDR value threshold for GSEA step.", metavar="character"),

  make_option(c("--gsea_pvalue_threshold"), type="numeric", default=.05,
              help="P value threshold for GSEA step.", metavar="character"),

  make_option(c("--LURE_pvalue_threshold"), type="numeric", default=.05,
              help="P value threshold for LURE PR AUC score step.", metavar="character"),

  make_option(c("--max_num_events"), type="numeric", default=3,
              help="Used to limit the number of catch events found by GSEA and considered for LURE's classifier AUC score step.  The events are sorted by GSEA NES score so the top events will be chosen. The larger this parameter the longer the runtime.",
              metavar="character"),
  make_option(c("--feature_data_file"), type="character", default="pancan_RNAexp_UVM",
              help="Feature Data File. File must be located in input directory.", metavar="character"),

  make_option(c("--target_gmt_file"), type="character", default="LUAD_functional_coding_non_coding_amp_del_fusion.gmt",
              help="This argument only pertains when LURE is run with enrichment only.  It is the gmt file for the test/target dataset.  The 'gmt_file' argument is used to identify the bait event samples.", metavar="character"),

  make_option(c("--target_feature_file"), type="character", default="mutation_specific_cytoband_fusion_5_15_2019.gmt",
              help="This argument only pertains when LURE is run with enrichment only.  It is the feature file for the test/target dataset. File must be located in the input directory.", metavar="character"),

  make_option(c("--output_file_prefix"), type="character", default="V10",
              help="This is the file prefix assigned to all the output files.  For multiple runs it helps keep track of each run."),

  make_option(c("--tissue"), type="character", default="",
              help="Tissue or Tumor Type, used for additional filename prefix.")


)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
folds<<-opt$folds
print(opt)

# For running PANCAN analysis...
# feature_data<-data.frame(fread(paste(PANCAN_DATA,opt$feature_data_file,sep=""),stringsAsFactors = FALSE),row.names = 1)

feature_data<-data.frame(fread(paste(INPUT,opt$feature_data_file,sep=""),stringsAsFactors = FALSE),row.names = 1)




LURE(bait_gene=opt$bait_gene,
     gmt_file=opt$gmt_file,
     feature_data=feature_data,
     num_permutations=opt$num_permutations,
     max_num_events=opt$max_num_events,
     percent_overlap=opt$percent_overlap,
     LURE_pvalue_threshold=opt$LURE_pvalue_threshold,
     min_gene_set_size=opt$min_gene_set_size,
     gsea_pvalue_threshold=opt$gsea_pvalue_threshold,
     gsea_fdr_threshold=opt$gsea_fdr_threshold,
     max_tree_length =opt$max_tree_length,
     folds=opt$folds,
     enrichment_analysis_only=FALSE,
     output_file_prefix=opt$output_file_prefix,
     tissue=opt$tissue)

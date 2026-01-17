# Installing Beagle for Genotype Imputation (written by ChatGPT)

This package optionally uses **Beagle** for linkage-disequilibrium–aware
genotype imputation prior to computing a genomic relationship matrix (GRM).
Beagle is an external Java-based program distributed as a `.jar` file.

If you do not wish to install Beagle, the GRM function can fall back to simple
mean imputation.

---

## Overview

- Beagle is **not an R package**
- It must be installed **outside of R**
- R calls Beagle via a system command such as:
  `java -Xmx16g -jar beagle.jar`

This document covers installation and use on **Linux, macOS, and Windows**.
Users may skip sections not relevant to their operating system.

---

## Requirements (All Operating Systems)

### Java

Beagle 5.x requires **Java 8 or newer**.

Check whether Java is installed:
`java -version`

If Java is not installed or the version is too old, follow the operating-system–specific instructions below.

---

### Beagle JAR File

Beagle is distributed as a single `.jar` file, for example:
`beagle.27Feb25.75f.jar`

Official download page:  
https://faculty.washington.edu/browning/beagle/beagle.html

---

## Installing Java

### Linux

Install OpenJDK (recommended):
`sudo apt update && sudo apt install openjdk-11-jre`

Verify installation:
`java -version`

---

### macOS

Using Homebrew:
`brew install openjdk`

Homebrew will print instructions if you need to add Java to your PATH.

Verify:
`java -version`

---

### Windows

1. Download Java from https://adoptium.net/
2. Install using default options
3. Open **Command Prompt** and verify:
   `java -version`

If Java is not found, restart your computer and try again.

---

## Downloading Beagle (All Operating Systems)

1. Go to https://faculty.washington.edu/browning/beagle/beagle.html
2. Download the latest **Beagle 5.x** `.jar` file
3. Place it in a stable location, for example:

Linux / macOS: `~/software/beagle/`  
Windows: `C:\beagle\`

---

## Testing the Beagle Installation

Run the following command in a terminal (Linux/macOS) or Command Prompt (Windows):
`java -Xmx2g -jar beagle.27Feb25.75f.jar`

If Beagle prints usage information, the installation is successful.

---

## Using Beagle from R

When calling the GRM function, supply the path to the Beagle JAR file.

Example (Linux/macOS):
`vcf_to_grm_vanraden1(vcf_file = "input.vcf.gz", out_rds = "grm.rds", impute = "beagle", beagle_jar = "~/software/beagle/beagle.27Feb25.75f.jar", beagle_mem_gb = 16)`

Example (Windows):
`beagle_jar = "C:/beagle/beagle.27Feb25.75f.jar"`

Forward slashes are recommended on Windows.

---

## Optional: Installing Beagle via Conda (Linux/macOS, HPC Systems)

If you use **conda** or **mamba**, Beagle is available via Bioconda:
`mamba install -c conda-forge -c bioconda beagle`

Notes:
- Java is usually installed automatically
- Some systems still require running Beagle with `java -jar`
- Check the installed location with:
  `which beagle`

---

## Notes on Imputation Options

- Beagle can impute missing genotypes **without a reference panel**
- Accuracy can be improved by supplying:
  - a reference panel (`ref=`)
  - a genetic map (`map=`)
  - effective population size (`ne=`)

These are optional and not required for basic use.

---

## If You Do Not Want to Install Beagle

You may use mean imputation instead:
`impute = "mean"`

This imputes missing genotypes to `2p` (centered to zero). It is fast but ignores linkage disequilibrium and relatedness.

---

## Troubleshooting

### Java Version Errors

Error: `Unsupported major.minor version`  
Solution: Upgrade Java to version 8 or newer.

---

### Beagle Runs but Produces No Output

- Increase memory (`-Xmx`)
- Ensure the VCF is diploid, biallelic, and bgzip-compressed (`.vcf.gz`)
- Check Beagle log output for warnings

---

## Reference

Browning, B. L., Zhou, Y., & Browning, S. R. (2018).  
*A One-Penny Imputed Genome from Next-Generation Reference Panels*.  
American Journal of Human Genetics, 103(3), 338–348.

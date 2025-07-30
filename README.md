# 🧬 Codon Highlighter
**Codon Highlighter** is a simple Bash-based bioinformatics tool that scans coding DNA sequences from FASTA files and highlights **start codons** (ATG) and **stop codons** (TAA, TAG, TGA) in all 6 frames in an HTML output. It translates all the frame sequences to highlights the start and stop amino acids. It provides a clean visualization for codon  and amino acid positions in a given reading frame.

---

## 🚀 Features

- Supports **FASTA format** input
- Highlights:
  - Start codons (`ATG`) in **green** 
  - Stop codons (`TAA`, `TAG`, `TGA`) in **red**
  - Non-coding region (after stop codon before next start codon) in **lightblue**
- Displays codon **position**, **index**, and **reading frame**
- Translates the sequences, nagivated by the links at the bottom
- Outputs an **HTML file** with formatted, and highlighted codons
- Gives output for all 6 reading frames.
- **Multiple files** in a folder can be processed.
---



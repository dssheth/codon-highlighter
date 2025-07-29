#!/usr/bin/env python3

from Bio.Seq import Seq
from Bio import SeqIO
import sys
import os
import webbrowser

print('argv: ', sys.argv)
file = sys.argv[1]
species = os.path.basename(file).replace(".fna", "")
record = next(SeqIO.parse(file, "fasta"))
seq = str(record.seq).upper()

def format_translation_frame(frame_name, aas):
    html = f"<h3>{frame_name}</h3>\n<div style='font-family:monospace; padding-left: 5rem;'>"

    start = 0
    stop = 0
    aas_line = ""
    aas_per_line = 60
    for i, aa in enumerate(aas):
        if aa == '*' and start == 1:
            stop = 1 
            start = 0 
            aa_fmt = "<span style='color:red; font-weight:bold;'>stop</span> "
        elif aa == 'M' and start == 0:
            start = 1
            stop = 0
            aa_fmt = "<span style='color:green; font-weight:bold;'>M</span> "
        elif start == 1 and stop == 0:  
            aa_fmt = f"{aa} " 
        else: 
            aa_fmt = f"<span style='color:lightblue; font-weight:bold;'>{aa}</span> "

        aas_line += aa_fmt

        if (i + 1) % aas_per_line == 0:
            html += f"<pre>{aas_line.strip()}</pre>\n"
            aas_line = ""

    if aas_line:
        html += f"<pre>{aas_line.strip()}</pre>\n"

    html += "</div><hr>"
    return html


html_blocks = ""
for direction in ["forward", "reverse"]:
    seq_to_use = seq if direction == "forward" else str(Seq(seq).reverse_complement())

    for frame in range(3):
        frame_seq = seq_to_use[frame:]
        codons = [frame_seq[i:i+3] for i in range(0, len(frame_seq) - 2, 3)]
        aas = [str(Seq(c).translate(to_stop=False)) if len(c) == 3 else '' for c in codons]

        codons = [c if len(c) == 3 else '---' for c in codons]
        aas = [a if len(a) == 1 else '-' for a in aas]

        frame_name = f"Frame {frame} ({direction})"
        html_blocks += format_translation_frame(frame_name, aas)


# Write output HTML
output_html = f"{species}_translation.html"
with open(output_html, "w") as f:
    f.write(f"""<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Translated Frames for {species}</title>
</head>
<body>
<h1 style='padding-left:5rem;'>Translation of All 6 Reading Frames : {species}</h1>
{html_blocks}

<a href='{species}.html' style='margin-left:5rem; font-size:18px;'>
🔗 View the CDS sequence : {species} 
</a>

</body>
</html>
""")

print(f"✔ Translation written to {output_html}")


# webbrowser.open(output_html)
print ("Open {output_html} manually.")
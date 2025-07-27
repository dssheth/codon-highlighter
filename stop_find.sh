#!/bin/bash

file="$1"  # Input file
stop_codons="TAA TAG TGA"


# Clean and get the sequence
sequence=$(grep -v "^>" "$file" | tr -d '\n' | tr 'a-z' 'A-Z')
len=${#sequence}
frame=0
highlighted=""
codons_per_line=21  # You can change this to adjust line width
codon_count=0
stop_info=""
start_found=0

echo "📍 Checking stop codons in reading frame 0 (triplets):"

for ((i=frame; i<=$len-3; i+=3)); do
    codon="${sequence:$i:3}"
    pos=$((i+1))
    codon_num=$((i/3+1))

    if [[ "$codon" == "ATG" && $start_found == 0 ]]; then
        start_found=1
        start_summary="<p><b>Start Codon (ATG)</b> found at position <b>$pos</b> (codon # <b>$codon_num</b>)</p>"
        highlighted+="<span style=\"color:green;\"><b>$codon </b></span>"
    elif [[ ("$codon" == "TAA" || "$codon" == "TAG" || "$codon" == "TGA") && $start_found == 1 ]]; then
        echo "❗ Stop codon '$codon' found at position $pos (codon # $codon_num)"
        highlighted+="<span style=\"color:red;\"><b>$codon </b></span>"
        stop_info+="<li>Stop codon <b>$codon</b> at position <b>$pos</b> (codon # <b>$codon_num</b>)</li>"
    else
        highlighted+="$codon "
    fi

    ((codon_count++))

    # Add line break after codons_per_line codons
    if (( codon_count % codons_per_line == 0 )); then
        highlighted+="<br>"
    fi
done

# Write to HTML
output_file="$1_output.html"
echo "<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>Codon Highlighter</title>
</head>
<body>
<pre style='font-size:16px; font-family:monospace; padding-left: 5rem;'>
<h2>The stop codons are highlighted in <span style=\"color:red\">red</span></h2>
<h2>The start codon is highlighted in <span style=\"color:green\">green</span></h2>
</pre>

<div style='font-family:monospace; padding-left: 5rem;'>
<h3>Summary:</h3>
${start_summary:-<p><b>Start Codon (ATG)</b> not found in frame</p>}
<h4>Stop Codons Found:</h4>
<ul>
${stop_info:-<li>No stop codons found</li>}
</ul>
</div>

<pre style='font-size:16px; font-family:monospace; padding-left: 5rem;'>$highlighted</pre>
</body>
</html>" > "$output_file"

# Open in browser   
xdg-open "$output_file" 2>/dev/null || open "$output_file" || echo "Open $output_file manually."

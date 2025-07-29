#!/bin/bash

file="$1"  # Input file
stop_codons="TAA TAG TGA"


# Clean and get the sequence
species=$(basename "$file" .fna)  # extracts 'cow' from 'cow.fna'
html_blocks=""  # accumulate HTML for all frames

for direction in forward reverse; do
  for frame in 0 1 2; do

        if [[ $direction == "forward" ]]; then
            sequence=$(grep -v "^>" "$file" | tr -d '\n' | tr 'a-z' 'A-Z')
        else
        # reverse complement
            sequence=$(grep -v "^>" "$file" | tr -d '\n' | tr 'a-z' 'A-Z' | \
                tr 'ATCG' 'TAGC'| rev)
        fi

        len=${#sequence}
        highlighted=""
        codons_per_line=21  # You can change this to adjust line width
        codon_count=0
        start_summary=""
        stop_info=""
        start_found=0

        echo "📍 Checking stop codons in reading frame $frame (triplets):"

        for ((i=frame; i<=$len-3; i+=3)); do
            codon="${sequence:$i:3}"
            pos=$((i+1))
            codon_num=$((i/3+1))

            if [[ "$codon" == "ATG" && $start_found == 0 ]]; then
                start_found=1
                stop_found=0
                start_summary+="<li><b>Start Codon (ATG)</b> found at position <b>$pos</b> (codon # <b>$codon_num</b>)</li>"
                highlighted+="<span style=\"color:green;\"><b>$codon </b></span>"
            elif [[ $start_found == 1 && $stop_found == 0 && ("$codon" == "TAA" || "$codon" == "TAG" || "$codon" == "TGA") ]]; then
                stop_found=1
                start_found=0
                echo "❗ Stop codon '$codon' found at position $pos (codon # $codon_num)"
                highlighted+="<span style=\"color:red;\"><b>$codon </b></span>"
                stop_info+="<li>Stop codon <b>$codon</b> at position <b>$pos</b> (codon # <b>$codon_num</b>)</li>"
            elif [[ $start_found == 1 && $stop_found == 0 ]]; then
                highlighted+="$codon "
            else    
                highlighted+="<span style=\"color:lightblue;\"><b>$codon </b></span>"
            fi

            ((codon_count++))

            # Add line break after codons_per_line codons
            if (( codon_count % codons_per_line == 0 )); then
                highlighted+="<br>"
            fi
        done

        frame_name="Frame $frame ($direction strand)"
        html_blocks+="<hr><h2>$frame_name</h2>
        <div style='font-family:monospace; padding-left: 5rem;'>
        <ul>${start_summary:-<li>No Start Codon Found</li>}</ul>
        <ul>${stop_info:-<li>No Stop Codon Found</li>}</ul>
        <pre style='font-size:16px; font-family:monospace;'>$highlighted</pre>
        </div>"
    done
done

 
python3 translate.py $file

# Write to HTML
output_file="$species.html"
echo "<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<title>Codon Highlighter for $species</title>
</head>
<body>
<h1 style='padding-left:5rem;'>Species: $species</h1>
<h2>The stop codons are highlighted in <span style=\"color:red\">red</span></h2>
<h2>The start codon is highlighted in <span style=\"color:green\">green</span></h2>
$html_blocks

<a href='${species}_translation.html' target="_blank" style='margin-left:5rem; font-size:18px;'>
🔗 View Translated Amino Acid Sequences (All 6 Frames)
</a>

</body>
</html>" > "$output_file"

# Open in browser   
xdg-open "$output_file" 2>/dev/null || open "$output_file" || echo "Open $output_file manually."

vgvgaligner map -i graph.idx -f reads_header.fa --also-align

# Convert my result to gam
vg convert graph.gfa -F reads_header-alignments.gaf > reads_header-alignments.gam

# Convert the alignment from vg sim to gaf
vg convert graph.gfa -G aln.gam > aln.gaf

# Add the correct read header to the gaf
awk -v n=1 '$1 = "read" n' aln.gaf > aln_header.gaf

# Convert to gam
vg convert graph.gfa -F aln_header.gaf > aln_header.gam

# Compare alignment
vg gamcompare reads_header-alignments.gam aln_header.gam
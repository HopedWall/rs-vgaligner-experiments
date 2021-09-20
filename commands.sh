#!/bin/bash 

# Install vgaligner (just for safety)
cargo install --path ../..

for d in */; do
	
	echo "\n"
	echo "========Executing pipeline for $d======="

	# Move to d
	cd "$d"

	# Store original graph stats (nodes, edges, cyclic, self-loops)
	vg stats -zAL graph.gfa > og_stats.txt

	# Sort with odgi and re-covnert to gfa
	odgi sort -i graph.gfa -o sorted.odgi -p Ygs -P
	odgi view -i sorted.odgi -g > sorted_graph.gfa
	vg stats -zAL sorted_graph.gfa > sorted_stats.txt

    # Generate gam and reads in fasta format
	vg sim -x sorted_graph.gfa -n 10 -s 77 -a | tee sim.gam | vg view -aj - | jq -r '[.name, .sequence] | @tsv' | awk '{ print ">"$1"\n"$2; }' > reads.fa

	# Convert sim.gam to gaf
	vg convert --gam-to-gaf sim.gam sorted_graph.gfa > sim.gaf

	# Run vgaligner
	/usr/bin/time -o aliger_results.txt --verbose vgaligner index  -i sorted_graph.gfa -k 11
	/usr/bin/time -o mapper_results.txt --verbose vgaligner map -i sorted_graph.idx -f reads.fa --also-align
	#vgaligner index  -i graph.gfa -k 11
	#vgaligner map -i graph.idx -f reads.fa --also-align

	# Run gamcompare
	python3 ../gafcompare.py reads-alignments.gaf sim.gaf

	# Move back to main folder
	cd ..

	echo "========End pipeline for $d======="

	# Convert my result to gam
	#vg convert graph.gfa --gam-to-gaf reads-alignments.gaf > reads-alignments.gam

	# Compare reads
	#vg gamcompare reads-alignments.gam sim.gam -s -r 10
done
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
	vg sim -x sorted_graph.gfa -n 100 -s 77 -a | tee sim.gam | vg view -aj - | jq -r '[.name, .sequence] | @tsv' | awk '{ print ">"$1"\n"$2; }' > reads.fa

	# Convert sim.gam to gaf
	vg convert --gam-to-gaf sim.gam sorted_graph.gfa > sim.gaf

	# Run single-thread
	/usr/bin/time -o index_stats_single.txt --verbose vgaligner index  -i sorted_graph.gfa -k 11 -n 1 -r 10
	/usr/bin/time -o mapper_stats_single.txt --verbose vgaligner map -i sorted_graph.idx -f reads.fa --also-align -n 1

	# Run multi-thread
	/usr/bin/time -o index_stats_multi.txt --verbose vgaligner index  -i sorted_graph.gfa -k 11 -r 10 
	/usr/bin/time -o mapper_stats_multi.txt --verbose vgaligner map -i sorted_graph.idx -f reads.fa --also-align

	# Run gamcompare
	python3 ../gafcompare.py reads-alignments.gaf sim.gaf > comparison_results.txt

	# Remove vgaligner's index (it can get quite big)
	find . -name "*.idx" -type f -delete

	# Run graphaligner
	touch graphaligner.gaf
	/usr/bin/time -o graphaligner_stats_multi.txt --verbose GraphAligner -g sorted_graph.gfa -f reads.fa -a graphaligner.gaf -x vg
	python3 ../gafcompare.py graphaligner.gaf sim.gaf > graphaligner_comparison.txt

	# Run vg
	vg view -F sorted_graph.gfa -v > graph.vg
	/usr/bin/time -o vgind_stats_multi.txt --verbose vg index graph.vg -x graph.xg -g graph.gcsa -k 11
	/usr/bin/time -o vgmap_stats_multi.txt --verbose vg map -d graph -f reads.fa > vg_result.gam
	vg convert --gam-to-gaf vg_result.gam sorted_graph.gfa > vg_result.gaf
	python3 ../gafcompare.py vg_result.gaf sim.gaf > graphaligner_comparison.txt

	# Move back to main folder
	cd ..

	echo "========End pipeline for $d======="
done

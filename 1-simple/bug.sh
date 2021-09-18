# Simulate .GAM
vg sim -x graph.gfa -n 1 -s 77 -a > sim.gam

# Convert to GAF
vg convert --gam-to-gaf sim.gam graph.gfa >sim2.gaf

# Re-convert to GAM
vg convert --gaf-to-gam sim2.gaf graph.gfa >sim2.gam

# Compare
vg gamcompare sim2.gam sim.gam -s  -r 100



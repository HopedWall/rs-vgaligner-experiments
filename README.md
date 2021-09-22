# rs-vgaligner-experiments
Experiments/validation for [rs-vgaligner](https://github.com/HopedWall/rs-vgaligner). 
This repo is not intended to be used independently, but as a submodule for vgaligner. 
It is intended to be used on UNIX-systems.

## Requirements
- rust (cargo)
- [vg](https://github.com/vgteam/vg) for simulating the reads
- [odgi](https://github.com/pangenome/odgi) for sorting the graphs
- python3 with pandas installed

## How to run the experiments
First clone vgaligner with the ```--recursive``` option (this also clones this submodule). 
Then move to ```experiments/rs-vgaligner-experiments``` and run the ```commands.sh``` file.

Here is the complete list of commands that should be used:
```
git clone https://github.com/HopedWall/rs-vgaligner --recursive
cd rs-vgaligner/experiments/rs-vgaligner-experiments
sh commands.sh
```



import argparse
import pandas as pd
import re

# CLI arguments parsing
parser = argparse.ArgumentParser(description='Compare two GAFs given as input.')
parser.add_argument('GAF1', help='Path to the first GAF file')
parser.add_argument('GAF2', help='Path to the second GAF file')
args = vars(parser.parse_args())

# Read GAF files
my_gaf = pd.read_csv(args["GAF1"], 
                        sep='\t', 
                        names=["Name", "qlen", "qstart", "qend", 
                                "strand", "path", "plen", "pstart", "pend", 
                                "residue", "alblock", "quality", "extra"])
ref_gaf = pd.read_csv(args["GAF2"], 
                        sep='\t', 
                        names=["Name", "qlen", "qstart", "qend", 
                                "strand", "path", "plen", "pstart", "pend", 
                                "residue", "alblock", "quality", "extra",
                                "extra1", "extra2"])    # final fields are a bit different, 
                                                        # this should not matter too much


# Compare nodes
assert len(my_gaf.index) == len(ref_gaf.index), "GAFs have different column numbers"
for i in range(len(my_gaf.index)):
        # Get the string representing the path
        my_gaf_nodes_str = my_gaf["path"][i]
        ref_gaf_nodes_str = ref_gaf["path"][i]
        
        # Find tuples (orient, nodeid) and perform the comparison 
        my_gaf_tuples = re.findall("(>|<)([0-9]+)", my_gaf_nodes_str)
        ref_gaf_tuples = re.findall("(>|<)([0-9]+)", ref_gaf_nodes_str)

        # Convert ids to integers
        my_gaf_int = list(map(lambda x: +int(x[1]) if x[0]=='>' else -int(x[1]), my_gaf_tuples))
        ref_gaf_int = list(map(lambda x: +int(x[1]) if x[0]=='>' else -int(x[1]), ref_gaf_tuples))

        # Find intersection and union
        my_gaf_int.sort()
        ref_gaf_int.sort()
        
        intersec = range(max(my_gaf_int[0], ref_gaf_int[0]), min(my_gaf_int[-1], ref_gaf_int[-1]))
        union = range(min(my_gaf_int[0], ref_gaf_int[0]), max(my_gaf_int[-1], ref_gaf_int[-1]))

        # Compute jaccard
        jaccard = len(intersec)/len(union) if len(union) else 0
        print("jaccard is: {}".format(jaccard))

        '''
        # Figure out how many matches there are
        matches = 0
        for (my, ref) in zip(my_gaf_tuples, ref_gaf_tuples):
                if my == ref:
                        matches += 1
        print("Path matches: {}/{}".format(matches, len(ref_gaf_tuples)))
        '''
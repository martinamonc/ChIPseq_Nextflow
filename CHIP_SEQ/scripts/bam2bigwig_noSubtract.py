import subprocess
import pysam
import argparse

######################
## ARGUMENT PARSING ##
######################
parser = argparse.ArgumentParser(description='Bam to bigwig with deeptools')
parser.add_argument('-t', '--target', help='target sample bam file', required=True)
parser.add_argument('-b', '--bigwig', help='name for the output bigwig file', required=True)
parser.add_argument('-p', '--threads', help='Number of threads to use', required=True)
parser.add_argument('-o', '--otherParams', help='Extra parameters to deeptools', action='append', nargs=argparse.REMAINDER)

options = parser.parse_args()

params    = options.otherParams
params    = " ".join(str(e) for e in params[0])
target      = options.target
threads   = options.threads
bw        = options.bigwig


##############################
## Avoid warning from pysam ##
##############################
def touch_file(file):
	command = "touch " + file
	subprocess.call(command.split())

# Avoid the warning from pysam that tells that the bam file is more recent than the index file (due to snakemake behaviour)
touch_file(target + ".bai")

####################
## Read bam files ##
####################
c  = pysam.AlignmentFile(target, "rb")

################################################################
## Calculate normalization factors: (1/mapped reads)*1million ##
################################################################
target_norm      = str( (1.0/float(c.mapped))*1000000 )

############################################
## Output some values to eventually debug ##
############################################
print('Number of reads in ChIP is: ' + str(c.mapped))
print("The scaling factor is: "+ str(target_norm))

#############################
## Bash commands to launch ##
#############################
bamCoverage = "bamCoverage -b " + target + " -o " + bw + " -p " + threads + " " + params + " --scaleFactor " + target_norm

subprocess.call(bamCoverage.split())

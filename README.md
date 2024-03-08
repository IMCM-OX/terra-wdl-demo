# terra-wdl-demo

## About
This demo workflow executes the `bedtools intersect` command on the provided VCF and BED files, producing a filtered VCF file based on the intersection, along with a count of variants.

## Inputs
- `query_vcf`: Input VCF file containing variants.
- `query_bed`: Input BED file specifying the region of interest.
- `label`: A string label used as a prefix for output files.

## Outputs
- `output_vcf`: Output VCF file containing variants within the specified region.
- `count`: Number of variants in the output VCF file.

Workflow Execution
The BedtoolsDemo workflow calls the intersect task with the provided inputs. 
The intersect task, in turn, runs the bedtools intersect command within a Docker container (pegi3s/bedtools). 
The resulting VCF file and variant count are then captured and reported as outputs.

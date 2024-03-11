# terra-wdl-demo

[![Open](https://img.shields.io/badge/Open-Dockstore-blue)](https://dockstore.org/workflows/github.com/IMCM-OX/terra-wdl-demo:main?tab=info)

> [!TIP]
> To import the workflow into your Terra workspace, click on the above Dockstore badge, and select 'Terra' from the 'Launch with' widget on the Dockstore workflow page.

## About
This demo workflow executes the `bedtools intersect` command on the provided VCF and BED files, producing a filtered VCF file based on the intersection, along with a count of variants.

## Inputs
- `query_vcf`: Input VCF file containing variants.
- `query_bed`: Input BED file specifying the region of interest.
- `label`: A string label used as a prefix for output files.

## Outputs
- `output_vcf`: Output VCF file containing variants within the specified region.
- `count`: Number of variants in the output VCF file.

## Workflow steps
The `BedtoolsDemo` workflow calls the `intersect` task with the provided inputs. 
The `intersect` task, runs the `bedtools intersect` command.
The resulting VCF file and variant count are then captured and reported as outputs.

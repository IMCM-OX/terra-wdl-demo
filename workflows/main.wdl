version 1.0

import "./tasks/intersect.wdl" as t1

############################ Workflow definition begins here ############################
workflow Bedtools {

    meta {
        description: "A simple wdl workflow extract variants from a vcf using a region of interest (bed)"
    }

    # Declare all the inputs required for the workflow
    input {
        File query_vcf
        File query_bed
        String label
    }

    # Metadata specific to the workflow input parameters
    parameter_meta {

        query_vcf:{
            help:"Input VCF file.",
            example: "test_data/NA00001.vcf"
        }
        
        query_bed:{
            help:"Coordinates for the regions of interest in .bed format.",
            example: "test_data/region_of_interest.bed"
        }
        
        label:{
            help:"Output file prefix.",
            example: "demo"
        }
    }

    # Calling the 'intersect' task with specified inputs
    call t1.intersect {
        input:
            vcf = query_vcf,
            bed = query_bed,
            prefix = label
    }

    # Output declarations for the workflow.
    # Catching the outputs of the 'intersect' task and assigning them to `output_vcf` and `count`.
    output {
        File output_vcf = intersect.out
        Int count = intersect.count
    }

}
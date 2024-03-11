version 1.0

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
            example: "test_data/sample.vcf"
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
    call intersect {
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

############################ Task definition begins here ############################
task intersect {
    
    # Declare all the task-level inputs required to run the shell command
    input {
        File vcf
        File bed
        String prefix
    }

    # Shell commands to be executed by the task
    # Use 'bedtools intersect' to filter variants based on the provided BED file.
    # Use 'grep' to filter out header lines and count the remaining variants from the resultant file.
    command <<<
        bedtools intersect -a ~{vcf} -b ~{bed} -header > ~{prefix}.vcf
        grep -v "#" ~{prefix}.vcf |wc -l
    >>>

    # Output declarations for the task.
    # Catching the ".vcf" file created by "bedtools" and the "stdout" of the grep command and assigning them to "out" and "count" respectively.
    output {
        File out = prefix + ".vcf"
        Int count = read_int(stdout())
    }

    # Runtime specifications for the task
    runtime {
        docker: "pegi3s/bedtools"
        memory: "4G"
        disks: "local-disk 1 HDD"
    }

}
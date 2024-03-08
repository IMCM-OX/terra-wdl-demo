version 1.0

workflow BedtoolsDemo {
    meta {
        description: "A simple wdl workflow extract variants from a vcf using a region of interest (bed)"
    }
    
    input {
        File query_vcf
        File query_bed
        String label
    }

    call intersect {
        input:
            vcf = query_vcf,
            bed = query_bed,
            prefix = label
    }

    output {
        File output_vcf = intersect.out
        Int count = intersect.count
    }
}

task intersect {
    input {
        File vcf
        File bed
        String prefix
    }

    command <<<
        bedtools intersect -a ~{vcf} -b ~{bed} -header > ~{prefix}.vcf
        grep -v "#" ~{prefix}.vcf |wc -l
    >>>

    output {
        File out = prefix + ".vcf"
        Int count = read_int(stdout())
    }

    runtime {
        docker: "pegi3s/bedtools"
        memory: "4G"
        disks: "local-disk 1 HDD"
    }
}
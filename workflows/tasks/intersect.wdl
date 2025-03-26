version 1.0

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
        bedtools intersect -a ~{vcf} -b ~{bed} -header > ~{prefix}_subset.vcf
        grep -v "#" ~{prefix}_subset.vcf |wc -l
    >>>

    # Output declarations for the task.
    # Catching the ".vcf" file created by "bedtools" and the "stdout" of the grep command and assigning them to "out" and "count" respectively.
    output {
        File out = prefix + "_subset.vcf"
        Int count = read_int(stdout())
    }

    # Runtime specifications for the task
    runtime {
        docker: "pegi3s/bedtools"
        memory: "4G"
        disks: "local-disk 1 HDD"
    }

}
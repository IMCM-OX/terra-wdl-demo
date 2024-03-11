# terra-wdl-demo

[![Open](https://img.shields.io/badge/Open-Dockstore-blue)](https://dockstore.org/workflows/github.com/IMCM-OX/terra-wdl-demo:main?tab=info)

> [!TIP]
> To import the workflow into your Terra workspace, click on the above Dockstore badge, and select 'Terra' from the 'Launch with' widget on the Dockstore workflow page.

## About
This is a workflow that extracts variants from a VCF (Variant Call Format) file using a region of interest specified in a BED file.
This demo workflow executes the `bedtools intersect` command on the provided VCF and BED files, producing a filtered VCF file based on the intersection, along with a count of variants.

## Workflow steps
The `BedtoolsDemo` workflow calls the `intersect` task with the provided inputs. 
The `intersect` task, runs the `bedtools intersect` command.
The resulting VCF file and variant count are then captured and reported as outputs.

## Inputs
- `query_vcf`: Input VCF file containing variants.
- `query_bed`: Input BED file specifying the region of interest.
- `label`: A string label used as a prefix for output files.

## Outputs
- `output_vcf`: Output VCF file containing variants within the specified region.
- `count`: Number of variants in the output VCF file.

## Understanding the WDL Script
Every WDL file must begin with a version statement.
In our example, we are declaring `version 1.0` at the top of the `main.wdl` script.

### Task section (eg `intersect`)
A task is defined using the `task` keyword, followed by a task name that is unique within its WDL document.

```{bash}
task intersect {
    # declaration of a task
}
```
#### `input`: Specifies the input files and parameters required for the task (vcf, bed, prefix).
```{bash}
task intersect {
    input {
        File vcf
        File bed
        String prefix
    }
}
```
#### `command`: Contains the shell commands executed by the task. It uses `bedtools intersect` to extract variants and grep to count non-header lines.
```{bash}
task intersect {
    ...
    command <<<
        bedtools intersect -a ~{vcf} -b ~{bed} -header > ~{prefix}.vcf
        grep -v "#" ~{prefix}.vcf |wc -l
    >>>
}
```
#### `output`: Defines the output files and variables produced by the task (`out`, `count`).
```{bash}
task intersect {
    ...
    output {
        File out = prefix + ".vcf"
        Int count = read_int(stdout())
    }
}
```
#### `runtime`: Specifies the runtime environment, including `docker` image, `memory` allocation, and `disk` requirements.
```{bash}
task intersect {
    ...
    runtime {
        docker: "pegi3s/bedtools"
        memory: "4G"
        disks: "local-disk 1 HDD"
    }
}
```
Optionally, we can add `meta` and `parameter_section` with additional metadata.


### Workflow section (eg `Bedtools`)
  
  A workflow is defined using the workflow keyword, followed by a workflow name that is unique within its WDL document, followed by any number of workflow elements within braces.
  ```{bash}
  workflow Bedtools {
    # declaration of a workflow
  }
  ```

#### `input`: Defines the input files required for the workflow (query_vcf, query_bed, label).
```{bash}
workflow name {
    input {
        File query_vcf
        File query_bed
        String label
    }
}
```
#### `call` intersect: Invokes the intersect task with specified inputs.
  ```{bash}
  workflow Bedtools {
    ...
    call intersect {
        input:
            vcf = query_vcf,
            bed = query_bed,
            prefix = label
    }
  }
  ```
#### `output`: Specifies the output files of the workflow (output_vcf, count).
  ```{bash}
  workflow Bedtools {   
    ...     
    output {
        File output_vcf = intersect.out
        Int count = intersect.count
    }
  }
  ```




## Further reading
- [WDL 1.0 style guidelines:](https://biowdl.github.io/styleGuidelines.html)
- [Workflow Description Language (WDL) specification](https://github.com/openwdl/wdl/blob/release-1.1.0/SPEC.md)

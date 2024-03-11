# terra-wdl-demo

[![Open](https://img.shields.io/badge/Open-Dockstore-blue)](https://dockstore.org/workflows/github.com/IMCM-OX/terra-wdl-demo:main?tab=info)

> [!TIP]
> To import the workflow into your Terra workspace, click on the above Dockstore badge, and select 'Terra' from the 'Launch with' widget on the Dockstore workflow page.

# Table of Contents

1. [About](#about)
2. [Workflow Steps](#workflow-steps)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Understanding the WDL Script](#understanding-the-wdl-script)
   - [Task Section (e.g., intersect)](#task-section-eg-intersect)
     - [`input`](#input)
     - [`command`](#command)
     - [`output`](#output)
     - [`runtime`](#runtime)
   - [Workflow Section (e.g., Bedtools)](#workflow-section-eg-bedtools)
     - [`input`](#input-1)
     - [`call` intersect](#call-intersect)
     - [`output`](#output-1)
     - [Metadata Sections (optional)](#metadata-sections-optional)
     - [Complete Workflow Script (`workflow/main.wdl`)](#complete-workflow-script-workflowmainwdl)
6. [Further Reading](#further-reading)


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

A workflow can contain the following components:
- `input` section
- `output` section
- `command` section
- `runtime` section

Optional components
- `meta` section
- `parameter_meta` section

Here is the structure of a simple task:

```{bash}
# declaration of a task
task task_name {
    input {
        # input declaration
    }
    
    command <<<
    # bash/python/perl/R command
    >>>
    
    output {
        # declare the outputs of the task
    }
    
    runtime {
        # declare computing requirements required to run the task
    }
}
```

The detailed description of the components of our `intersect` task is provided below.

#### `input`

Specifies the input files and parameters required for the task (vcf, bed, prefix).

```{bash}
# declaration of the task
task intersect {
    input {
        File vcf
        File bed
        String prefix
    }
}
```

#### `command`

Contains the shell commands executed by the task. It uses `bedtools intersect` to extract variants and grep to count non-header lines.

```{bash}
task intersect {
    ...
    command <<<
        bedtools intersect -a ~{vcf} -b ~{bed} -header > ~{prefix}.vcf
        grep -v "#" ~{prefix}.vcf |wc -l
    >>>
}
```

#### `output`

Defines the output files and variables produced by the task (`out`, `count`).

```{bash}
task intersect {
    ...
    output {
        File out = prefix + ".vcf"
        Int count = read_int(stdout())
    }
}
```

#### `runtime`

Specifies the runtime environment, including `docker` image, `memory` allocation, and `disk` requirements.

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
  
A workflow is defined using the `workflow` keyword, followed by a workflow name that is unique within its WDL file, followed by the components of the workflow within braces.

A workflow can contain the following components:
- `input` section
- `output` section
- `call` section

Optional components
- `meta` section
- `parameter_meta` section


Here is the structure of a simple workflow that involves running two tasks.

```{bash}
# declaration of a workflow
workflow workflow_name {

    input {
        # input declaration
    }

    call task_name_1 {
        # execute the first task
    }

    call task_name_2 {
        # execute the second task
    }

    output {
        # declare the outputs of the workflow
    }
}
```

The detailed description of the components of our `Bedtools` workflow is provided below.

#### `input`

Defines the input files required for the workflow (query_vcf, query_bed, label).

```{bash}
workflow Bedtools {
    input {
        File query_vcf
        File query_bed
        String label
    }
}
```

#### `call` intersect

Invokes the intersect task with specified inputs.

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

#### `output`

Specifies the output files of the workflow (output_vcf, count).

  ```{bash}
  workflow Bedtools {   
    ...     
    output {
        File output_vcf = intersect.out
        Int count = intersect.count
    }
  }
  ```

#### Metadata Sections (optional)

User can also add meta and parameter_meta sections to both workflow and tasks.
- `meta` : task or workflow level metadata. For example: description, author and contact email, etc.
- `parameter_meta`: This section contains metadata specific to input and output parameters.
Any key in this section must correspond to a task input or output.


#### Complete workflow script (`workflow/main.wdl`)

```{bash}
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

```

## Further reading
- [WDL 1.0 style guidelines:](https://biowdl.github.io/styleGuidelines.html)
- [Workflow Description Language (WDL) specification](https://github.com/openwdl/wdl/blob/release-1.1.0/SPEC.md)

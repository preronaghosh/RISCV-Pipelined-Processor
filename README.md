## Environment Setup

### Getting the repository

Use `git` to clone the repository to your Linux environment. This can be done using:

```bash
git clone git@github.com:preronaghosh/RISCV-Pipelined-Processor.git && ./install-hooks.sh
```

The `./install-hooks.sh` command installs a pre-push hook in your local repository to remind you to add/clear files before pushing.

### Setup of simulators and environment variables

Go to the root of the project repository and execute the command `source env.sh`.
Note that you will need to perform this operation every time you use a different `bash` session.
Otherwise, the scripts will not be able to locate the files.

```bash
$ source env.sh
===== Environment Setup =====
Important: this script should be used as `source env.sh` and should only be used in bash
Project Root ($PROJECT_ROOT):		/home/your/path/to/repo
verilator Version ($VERILATOR_VERSION):	 Verilator 4.210 2021-07-07 rev v4.210
Vivado Version ($VIVADO_VERSION): 	 Vivado v2022.1 (64-bit)
===== Computer Architecture Course Environment Done  =====
```

If the script is unable to locate the verilator or vivado version, the corresponding line will be empty.

## Tests

To run tests, go to `verif/scripts` and use the following command:

```bash
make -s run [TEST=<test_name>] [MEM_PATH=<mem_path>]
```

## Troubleshooting

You can plot the waves using `gtkwave`. A Makefile target has been added to do this:

```bash
make waves [MEM_PATH=<mem_path>]
```

You can edit `verif/scripts/waves.tcl` to automatically add specific signals to your screen, group signals together, set colours and zoom level, etc.


# Examples

This folder contains root and workload-oriented examples that help validate or consume the modules in this repository.

## Recommended Starting Points

- [root-plan-harness/README.md](./root-plan-harness/README.md): how to use the root plan-validation harness
- [../docs/MODULES_INDEX.md](../docs/MODULES_INDEX.md): links to each module's `README`, `EXAMPLES`, and `tests/live.tftest.hcl`

## Existing Workload Examples

- `linuxvm/`: workload-specific sample inputs for the Linux VM module path
- `winvm/`: workload-specific sample inputs for the Windows VM module path
- `adf/`: reserved for Azure Data Factory example material

Prefer the root plan harness when validating module wiring across the repository. Prefer module-local `EXAMPLES.md` files when you want a focused example for a single module.

#!/usr/bin/env python3
"""Check module documentation and test conventions from the module documentation standard.

Warn mode (default) reports every finding and exits 0. Fail mode exits 1 when any finding exists.
When GITHUB_ACTIONS is set, findings are also emitted as workflow warnings or errors.
"""

import argparse
import glob
import os
import re
import sys

SECTIONS = {
    "features": r"^##+\s+.*feature",
    "resources": r"^##+\s+.*resources",
    "prerequisites": r"^##+\s+.*(prerequisite|dependenc)",
    "provider": r"^##+\s+.*provider",
    "usage": r"^##+\s+.*(usage|quick ?start)",
    "behavior": r"^##+\s+.*(behavior|behaviour|secure default|security)",
    "naming": r"^##+\s+.*(naming|tag)",
    "testing": r"^##+\s+.*test",
    "limitations": r"^##+\s+.*limitation",
    "reference": r"^##\s+terraform reference",
}

# Headings that the standard replaced with canonical names.
NON_CANONICAL_HEADINGS = [
    (r"^##\s+Identity and Access\s*$", "use 'Identity and RBAC'"),
    (r"^##\s+RBAC\s*$", "use 'Identity and RBAC'"),
    (r"^##\s+Important Behavior\s*$", "use 'Important Behavior and Secure Defaults'"),
]

EXTERNAL_PREFIXES = ("azurerm_", "azuread_", "random_", "azapi_", "time_", "null_", "tls_", "msgraph_")


def read(path):
    with open(path, encoding="utf-8", errors="replace") as handle:
        return handle.read()


def strip_hcl_comments(text):
    """Drop whole-line HCL comments so commented-out blocks are not treated as live code."""
    kept = []
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("#") or stripped.startswith("//"):
            continue
        kept.append(line)
    return "\n".join(kept)


def tf_text(module_dir):
    return "\n".join(strip_hcl_comments(read(path)) for path in glob.glob(os.path.join(module_dir, "*.tf")))


def block_bodies(text, kind):
    """Yield (name, body) for each top-level variable or output block using brace matching."""
    for match in re.finditer(kind + r'\s+"([^"]+)"\s*\{', text):
        index = match.end()
        depth = 1
        while depth and index < len(text):
            depth += {"{": 1, "}": -1}.get(text[index], 0)
            index += 1
        yield match.group(1), text[match.end():index]


def check_module(root, name):
    module_dir = os.path.join(root, "modules", name)
    issues = []
    readme_path = os.path.join(module_dir, "README.md")
    if not os.path.exists(readme_path):
        return ["README.md is missing"]

    readme = read(readme_path)
    human = readme.split("<!-- BEGIN_TF_DOCS -->")[0]
    tf = tf_text(module_dir)

    for key, pattern in SECTIONS.items():
        if not re.search(pattern, readme, re.IGNORECASE | re.MULTILINE):
            issues.append(f"README section missing: {key}")

    for pattern, advice in NON_CANONICAL_HEADINGS:
        if re.search(pattern, readme, re.MULTILINE):
            issues.append(f"README heading is non-canonical: {advice}")

    variables = []
    outputs = []
    for kind in ("variable", "output"):
        for block_name, body in block_bodies(tf, kind):
            if kind == "variable":
                variables.append(block_name)
            else:
                outputs.append(block_name)
            if not re.search(r"^\s*description\s*=", body, re.MULTILINE):
                issues.append(f"{kind} {block_name} has no description")
            if kind == "variable" and not re.search(r"^\s*type\s*=", body, re.MULTILINE):
                issues.append(f"variable {block_name} has no type")

    if re.search(r'^provider\s+"', tf, re.MULTILINE):
        issues.append("module contains a provider block")

    known = set(variables) | set(outputs)
    known |= set(re.findall(r'"([a-z0-9_]+)"', tf))
    known |= set(re.findall(r"\b([a-z][a-z0-9_]+)\s*=", tf))
    example_and_test_files = glob.glob(os.path.join(module_dir, "examples", "*", "*.tf"))
    example_and_test_files += glob.glob(os.path.join(module_dir, "tests", "**", "*.hcl"), recursive=True)
    for path in example_and_test_files:
        known |= set(re.findall(r"\b([a-z][a-z0-9_]+)\b", read(path)))
    ticks = set(re.findall(r"`([a-z][a-z0-9]*_[a-z0-9_]+)`", human))
    unknown = sorted(
        tick for tick in ticks
        if tick not in known and not tick.startswith(EXTERNAL_PREFIXES) and tick not in tf
    )
    if unknown:
        issues.append("README mentions identifiers not defined in the module: " + ", ".join(unknown))

    for md_path in glob.glob(os.path.join(module_dir, "**", "*.md"), recursive=True):
        for link in re.findall(r"\]\(([^)\s]+)\)", read(md_path)):
            if re.match(r"^(https?:|mailto:|#)", link):
                continue
            target = link.split("#")[0]
            if not target:
                continue
            resolved = os.path.normpath(os.path.join(os.path.dirname(md_path), target.replace("%20", " ")))
            if not os.path.exists(resolved):
                issues.append(f"broken link in {os.path.relpath(md_path, module_dir)}: {link}")

    for doc in glob.glob(os.path.join(module_dir, "docs", "*.md")):
        if os.path.basename(doc) not in readme:
            issues.append(f"docs/{os.path.basename(doc)} is not linked from README")

    examples_dir = os.path.join(module_dir, "examples")
    if not os.path.isdir(os.path.join(examples_dir, "basic")):
        issues.append("examples/basic is missing (required)")
    if os.path.isdir(examples_dir):
        for example in sorted(os.listdir(examples_dir)):
            if f"examples/{example}" not in readme:
                issues.append(f"example {example} is not referenced in README")
            example_readme = os.path.join(examples_dir, example, "README.md")
            if os.path.exists(example_readme):
                example_text = read(example_readme)
                if not re.search(r"terraform\b.*(init|plan|validate)", example_text):
                    issues.append(f"example {example} README has no terraform commands")
                if not re.search(r"cost|billable|charge|pric", example_text, re.IGNORECASE):
                    issues.append(f"example {example} README does not mention cost")

    if not os.path.exists(os.path.join(module_dir, "tests", "unit.tftest.hcl")):
        issues.append("tests/unit.tftest.hcl is missing (required)")
    for test_path in glob.glob(os.path.join(module_dir, "tests", "*.tftest.hcl")):
        test_name = os.path.basename(test_path)
        if test_name not in readme:
            issues.append(f"test {test_name} is not mentioned in README")
        test_text = read(test_path)
        if test_name.startswith("integration") and not re.match(r"\s*#.*\b(plan|apply)\b", test_text, re.IGNORECASE):
            issues.append(f"{test_name} lacks a leading plan/apply comment")
        if test_name.startswith("unit") and "mock_provider" not in test_text and "override_" not in test_text:
            issues.append(f"{test_name} has no mock_provider")

    terraform_tf = read(os.path.join(module_dir, "terraform.tf"))
    required = re.search(r'required_version\s*=\s*"([^"]+)"', terraform_tf)
    if not required:
        issues.append("terraform.tf has no required_version")
    for provider, version in re.findall(
        r'(\w+)\s*=\s*\{\s*source\s*=\s*"[^"]+"\s*(?:\n\s*)?version\s*=\s*"([^"]+)"', terraform_tf
    ):
        if "<" not in version and "~>" not in version:
            issues.append(f"provider {provider} version is unbounded: {version}")

    return issues


def emit(level, module, message):
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::{level} title=module-standards::{module}: {message}")
    else:
        print(f"  [{module}] {message}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    parser.add_argument("--mode", choices=["warn", "fail"], default="warn")
    args = parser.parse_args()

    modules_dir = os.path.join(args.root, "modules")
    modules = sorted(
        name for name in os.listdir(modules_dir) if os.path.isdir(os.path.join(modules_dir, name))
    )

    total = 0
    affected = 0
    for name in modules:
        issues = check_module(args.root, name)
        if issues:
            affected += 1
            total += len(issues)
        for issue in issues:
            emit("error" if args.mode == "fail" else "warning", name, issue)

    print(f"Module standards: {total} finding(s) across {affected} of {len(modules)} module(s); mode={args.mode}.")
    return 1 if (args.mode == "fail" and total) else 0


if __name__ == "__main__":
    sys.exit(main())

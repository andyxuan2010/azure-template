"""Regression coverage for documentation publication and test selection guards."""

import importlib.util
import json
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("stage_docs", ROOT / "scripts/stage-docs.py")
STAGE_DOCS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(STAGE_DOCS)


class DocumentationStagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / "repo"
        self.root.mkdir()
        for name in ("index.html", "docs-manifest.json", ".nojekyll"):
            (self.root / name).write_text("public", encoding="utf-8")

    def write(self, name):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("fixture", encoding="utf-8")

    def test_only_documentation_and_assets_are_published(self):
        public = ["readme.MD", "readme.pdf", "docs/guide.md", "modules/demo/README.md", "docs/image.png", "assets/icon.svg"]
        private = [".env", "credentials", "terraform.tfvars", "terraform.tfstate", "tfplan", ".git/config", "modules/demo/main.tf", "modules/demo/.terraform/provider.md", "scripts/private.md"]
        for name in public + private:
            self.write(name)
        target = self.base / "site"
        STAGE_DOCS.stage_docs(self.root, target)
        for name in public:
            self.assertTrue((target / name).is_file(), name)
        for name in private:
            self.assertFalse((target / name).exists(), name)

    def test_rejects_output_inside_source_or_an_ancestor(self):
        for target in (self.root, self.root / "output", self.base):
            with self.subTest(target=target), self.assertRaises(ValueError):
                STAGE_DOCS.stage_docs(self.root, target)

    def test_rejects_existing_destination(self):
        target = self.base / "site"
        target.mkdir()
        with self.assertRaises(FileExistsError):
            STAGE_DOCS.stage_docs(self.root, target)

    def test_skips_symlinked_documents(self):
        secret = self.base / "secret.md"
        secret.write_text("private", encoding="utf-8")
        (self.root / "docs").mkdir()
        try:
            (self.root / "docs/leak.md").symlink_to(secret)
        except OSError:
            self.skipTest("Creating symlinks requires OS permission")
        target = self.base / "site"
        STAGE_DOCS.stage_docs(self.root, target)
        self.assertFalse((target / "docs/leak.md").exists())


@unittest.skipUnless(shutil.which("pwsh") and shutil.which("git"), "Requires PowerShell and Git")
class DocumentationManifestTests(unittest.TestCase):
    def test_includes_pdfs_and_markdown_without_terraform(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "scripts").mkdir()
            script = root / "scripts/generate-docs-manifest.ps1"
            shutil.copyfile(ROOT / "scripts/generate-docs-manifest.ps1", script)
            for name in ("README.md", "guide.pdf", "main.tf"):
                (root / name).write_text("fixture", encoding="utf-8")
            subprocess.run(["git", "init", directory], check=True, capture_output=True)
            subprocess.run(["git", "-C", directory, "add", "."], check=True, capture_output=True)
            result = subprocess.run(["pwsh", "-NoProfile", "-File", str(script)], capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            documents = json.loads((root / "docs-manifest.json").read_text())["documents"]
            self.assertEqual(set(documents), {"README.md", "guide.pdf"})


@unittest.skipUnless(shutil.which("node"), "Requires Node.js")
class DocumentationLinkTests(unittest.TestCase):
    def test_directory_and_source_links(self):
        script = r'''
const fs = require("fs"), assert = require("assert");
const html = fs.readFileSync(process.argv[1], "utf8");
const start = html.indexOf("function configureMarkdown(");
const end = html.indexOf("async function loadDocument(", start);
let renderer;
const marked = {Renderer: function() {}, setOptions: options => renderer = options.renderer};
const state = {documents: ["modules/demo/examples/basic/README.md"]};
const directory = path => path.slice(0, path.lastIndexOf("/") + 1);
const normalize = path => require("path").posix.normalize(path).replace(/\/$/, "");
const encode = path => path.split("/").map(encodeURIComponent).join("/");
const configure = new Function("marked", "state", "pathDirectory", "normalizePath", "encodePath", "escapeHtml", "REPOSITORY", "BRANCH", html.slice(start, end) + "; return configureMarkdown;")(marked, state, directory, normalize, encode, x => x, "https://github.com/example/repo", "main");
configure("modules/demo/README.md");
renderer.parser = {parseInline: () => "label"};
const link = href => renderer.link({href, tokens: []});
assert(link("examples/basic/").includes("#doc=modules%2Fdemo%2Fexamples%2Fbasic%2FREADME.md"));
assert(link("scripts/init.sh").includes("https://github.com/example/repo/blob/main/modules/demo/scripts/init.sh"));
assert(link("guide.pdf").includes("#doc=modules%2Fdemo%2Fguide.pdf"));
assert(link("https://example.com/").includes('rel="noopener noreferrer"'));
'''
        result = subprocess.run(["node", "-e", script, str(ROOT / "index.html")], capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


@unittest.skipUnless(shutil.which("pwsh") and shutil.which("terraform"), "Requires PowerShell and Terraform")
class TerraformRunnerTests(unittest.TestCase):
    def test_matching_test_file_runs(self):
        with tempfile.TemporaryDirectory() as directory:
            module = Path(directory) / "smoke"
            (module / "tests").mkdir(parents=True)
            (module / "main.tf").write_text('output "marker" { value = 42 }\n', encoding="utf-8")
            (module / "tests/unit.tftest.hcl").write_text('run "smoke" {\n command = plan\n assert {\n condition = output.marker == 42\n error_message = "Missing marker"\n }\n}\n', encoding="utf-8")
            result = subprocess.run(
                ["pwsh", "-NoProfile", "-File", str(ROOT / "scripts/Test-TerraformModules.ps1"), "-ModulesRoot", directory, "-TestFile", "tests/unit.tftest.hcl", "-NoColor"],
                capture_output=True, text=True, timeout=60,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("Success! 1 passed", result.stdout)

    def test_empty_test_selection_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            module = Path(directory) / "empty"
            (module / "tests").mkdir(parents=True)
            (module / "main.tf").write_text("terraform {}\n", encoding="utf-8")
            (module / "tests/unit.tftest.hcl").write_text("# No run blocks\n", encoding="utf-8")
            result = subprocess.run(
                ["pwsh", "-NoProfile", "-File", str(ROOT / "scripts/Test-TerraformModules.ps1"), "-ModulesRoot", directory, "-NoColor"],
                capture_output=True, text=True, timeout=60,
            )
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("non-empty passing test selection", result.stdout)

    def test_no_matching_modules_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                ["pwsh", "-NoProfile", "-File", str(ROOT / "scripts/Test-TerraformModules.ps1"), "-ModulesRoot", directory],
                capture_output=True, text=True, timeout=30,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("No modules found", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()

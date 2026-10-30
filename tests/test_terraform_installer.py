"""Ensure unverified Terraform downloads are never extracted or installed."""

import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASH = shutil.which("bash")
if os.name == "nt":
    candidate = Path("C:/Program Files/Git/bin/bash.exe")
    BASH = str(candidate) if candidate.exists() else None

HARNESS = r'''
curl() {
  local output
  while (($#)); do
    if [[ "$1" == "-o" ]]; then output="$2"; shift 2; else shift; fi
  done
  if [[ "$output" == */SHA256SUMS ]]; then
    printf '%s  terraform_1.15.8_linux_amd64.zip\n' "$TEST_CHECKSUM" > "$output"
  else
    printf 'archive payload' > "$output"
  fi
}
uname() { printf 'x86_64\n'; }
unzip() {
  printf 'extracted' > "$TEST_EXTRACT_MARKER"
  printf '#!/usr/bin/env bash\necho Terraform-test-fixture\n' > "${@: -1}/terraform"
}
source "$1" "$2"
'''


@unittest.skipUnless(BASH, "Requires Bash")
class TerraformInstallerTests(unittest.TestCase):
    def run_installer(self, checksum, version="1.15.8"):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            marker = base / "extracted"
            env = os.environ.copy()
            env.update({
                "AGENT_TEMPDIRECTORY": base.as_posix(),
                "TEST_EXTRACT_MARKER": marker.as_posix(),
                "TEST_CHECKSUM": checksum,
            })
            result = subprocess.run(
                [BASH, "-c", HARNESS, "installer-test", (ROOT / "scripts/azure-pipelines/install-terraform.sh").as_posix(), version],
                env=env, capture_output=True, text=True, timeout=30,
            )
            return result, marker.exists(), (base / "terraform-bin/terraform").exists()

    def test_valid_checksum_allows_installation(self):
        result, extracted, installed = self.run_installer(hashlib.sha256(b"archive payload").hexdigest())
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(extracted)
        self.assertTrue(installed)

    def test_corrupt_archive_is_rejected_before_extraction(self):
        result, extracted, installed = self.run_installer("0" * 64)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(extracted)
        self.assertFalse(installed)

    def test_invalid_version_is_rejected_before_extraction(self):
        result, extracted, installed = self.run_installer("0" * 64, "../invalid")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("major.minor.patch", result.stderr)
        self.assertFalse(extracted)
        self.assertFalse(installed)


if __name__ == "__main__":
    unittest.main()

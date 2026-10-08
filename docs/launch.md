# Launch and discoverability

## Repository metadata

- Owner suggestion: CodeCornTech
- Repository: intel-vtx-rescue
- Description: Enable Intel VT-x from Windows with Intel ITK — verified on DH61CR BIOS 0038.
- Topics: intel, vt-x, virtualization, bios, firmware, powershell, windows, windows-11, virtualbox, intel-integrator-toolkit, dh61cr, legacy-hardware, troubleshooting, sysadmin, remote-administration
- Initial release: v0.1.0
- License: MIT for original scripts/documentation

## Before the first release

1. Read the dry-run output of `scripts/repo-init.sh`, then deliberately publish with `--publish`.
2. Verify Windows CI passes in both PowerShell versions before creating the release.
3. Enable private vulnerability reporting in GitHub Settings > Security.
4. Protect main with pull requests and the offline-check status jobs when collaborators join; require reviews only when another reviewer is actually available.
5. Add a social-preview image in repository settings if desired. Use the actual board name and verified scope, and do not present stars or compatibility results that have not been earned.
6. Pin the repository on the maintainer/organization profile.

## Release command

From the local repository, after the initial push and successful CI:

```bash
gh release create v0.1.0 --repo CodeCornTech/intel-vtx-rescue \
  --target main --title 'Intel VT-x Rescue 0.1.0' \
  --notes-file docs/release-notes-v0.1.0.md
```

The bootstrap accepts a different owner. Adjust the release owner to match if needed.

## Suggested community post

> VT-x disabled in BIOS, and no one available to enter Setup? We enabled it remotely from Windows 11 on an Intel DH61CR running BIOS 0038, using Intel ITK Legacy and one exported BIOS token. A normal restart returned `VirtualizationFirmwareEnabled = True`.
>
> We published the procedure, sanitized evidence, original-setting backups, restore files and PowerShell helpers: https://github.com/CodeCornTech/intel-vtx-rescue
>
> Verified on one exact configuration; other board/BIOS reports are welcome. If this saves you a BIOS visit, a star is appreciated.

Publish the post only after the repository URL exists; update the URL if using another owner. Share once in relevant virtualization, sysadmin or retro-computing communities, following their self-promotion rules. Answer reports and grow the compatibility table from evidence.

## Presentation decisions

The English README leads with the actual error, measurable before/after result and quick start. The Italian README preserves accessibility for the original audience. Topics describe the real technology and scope. The verified case separates CPU virtualization from guest recovery. A concise star request follows useful instructions rather than replacing them.

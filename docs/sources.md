# Sources and evidence boundaries

## Intel-authored documentation

- [Intel DH61CR product brief](https://www.intel.com/content/dam/doc/product-brief/desktop-board-dh61cr-classic-brief.pdf): identifies the H61 board and Intel toolkit integration.
- [Intel Community archive thread and ITK 5.0.4.575 attachment](https://community.intel.com/t5/Mobile-and-Desktop-Processors/Modificar-a-tela-inicial-do-DH61AG-usando-Intel-Integrator/m-p/1654735): distribution reference for the archived package. The thread itself concerns a DH61AG splash screen; it is not evidence that VT-x worked on DH61CR 0038.
- The attachment's Intel-authored Readme.rtf and Legacy iToolkit.CHM: distinguish ITOOLKIT/ITOOLKITW from newer VCUST/VCUSTW; document EXTRACT/INSTALL -tokens and selected setting installation. The guide's "Token Extract and Install Component" and "Help Legend" topics provide the syntax used here.
- [Intel Desktop Boards BIOS Settings Glossary V19, November 2012](https://downloads.bl4ckb0x.de/download.intel.com/support/motherboards/desktop/sb/biosglossary_v19.pdf), Intel-authored archival mirror: Virtualization Technology at page 17 of the PDF; Unattended BIOS Configuration at page 34. These are general definitions, not a read of the live host's unattended policy.
- [Intel Software Developer's Manual, volume 2](https://cdrdv2-public.intel.com/782156/325383-sdm-vol-2abcd.pdf): IA32_FEATURE_CONTROL layout, VMX enable bits, lock behavior and power-on reset semantics.

## Direct case evidence

[verified-case.md](verified-case.md) records the sanitized operator-supplied export, successful write output and post-restart Windows result. It establishes the token mapping and activation outcome for this exact machine. It does not establish broad H61 compatibility, Windows 11 vendor support, or guest-disk recovery.

No Intel binaries, entire help files, full CPU-Z report, hardware serial numbers or customer paths are redistributed by this repository.

## Repository bootstrap

- [GitHub CLI repo create](https://cli.github.com/manual/gh_repo_create)
- [GitHub CLI repo edit](https://cli.github.com/manual/gh_repo_edit)
- [GitHub topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics)

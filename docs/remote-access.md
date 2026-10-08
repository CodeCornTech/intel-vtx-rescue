# Restarting an unattended host

ITK accepted the setting write in the recorded case. A normal restart returned to Windows and enabled virtualization. That observation does not determine the policy or reset behavior of another machine, including a second DH61CR with different configuration.

Intel documents an **Unattended BIOS Configuration** setting with Always Prompt, Lock, Temporarily Skip Prompt and Never Prompt options. A keyboard response can be required for configuration changes. `Lock=FALSE` in a token export is not a reading of that policy.

Before restarting remotely, save open work and establish how you will regain access if Windows does not return. Ordinary remote-desktop software cannot supply keystrokes while its Windows service is unavailable. An already-tested out-of-band console or an onsite person can provide recovery; merely enabling a Windows remote-access application does not provide pre-boot access.

Intel documents that VT-x changes take effect after power cycling. The recorded normal restart was sufficient on the exact verified host. If an ordinary restart leaves virtualization disabled, arrange an appropriate power cycle rather than repeatedly changing settings.

**Do not shut down an unattended host unless you have a verified method to power it back on.** A scheduled Windows task cannot power on a machine after Windows is off. Wake-on-LAN should not be assumed to work without prior validation from the network and power state involved.

No project script performs an automatic restart, power-off, firmware reset, or physical-presence-policy change.

See the Intel BIOS glossary and processor manual in [sources.md](sources.md).

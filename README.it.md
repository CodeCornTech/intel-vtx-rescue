# Intel VT-x Rescue

**Attivare Intel VT-x da Windows, senza entrare nel BIOS Setup.**

[English](README.md) · [Caso verificato](docs/verified-case.md) · [Accesso remoto](docs/remote-access.md)

Il caso nasce da `VERR_VMX_MSR_ALL_VMX_DISABLED` in VirtualBox. Un Intel Core i5-2400 supportava VT-x, ma il BIOS della DH61CR lo teneva disabilitato. Il componente Legacy di Intel Integrator Toolkit ha esportato le impostazioni reali, accettato una modifica al solo token VT-x da Windows 11 e, dopo un normale riavvio, Windows ha restituito `VirtualizationFirmwareEnabled = True`.

**Procedura manuale verificata:** DH61CR, BIOS `BEH6110H.86A.0038.2012.0110.1653`, i5-2400, ITK 5.0.4.575 con ITOOLKITW 1.4.1.135. Gli script riutilizzabili sono verificati con test offline; non sono ancora stati eseguiti indipendentemente su quella macchina. Il comando di scrittura rifiuta altre combinazioni.

## Procedura

Installare il pacchetto ITK archiviato indicato nel [README inglese](README.md#requirements). Aprire PowerShell come amministratore nella cartella del repository ed esaminare gli script prima di eseguirli.

```powershell
# Stato attuale
.\scripts\Test-IntelVtx.ps1

# Esportazione di sola lettura
.\scripts\Export-IntelVtxSettings.ps1

# Preparazione dei file: non scrive impostazioni firmware
.\scripts\Set-IntelVtx.ps1

# Applicazione esplicita, con nuova esportazione e file di ripristino
.\scripts\Set-IntelVtx.ps1 -Apply
```

I file restano nella cartella locale `C:\ProgramData\IntelVtxRescue`, in una sottocartella diversa per ogni operazione. Il token verificato è `SETTING_012F`: `0 = Disable`, `1 = Enable`. La modifica contiene solamente `[System]`, la versione INI estratta e quella singola voce. Non include Lock/Hide, SMBIOS o l'intera configurazione CMOS.

Se ITK non viene trovato o vengono trovate più installazioni, aggiungere `-ToolPath 'C:\percorso\itoolkitw.exe'`. Non spostare il solo EXE: lasciare disponibili i suoi componenti installati.

## Riavvio e accesso remoto

Gli script non riavviano né spengono il computer. Prima di riavviare una macchina senza assistenza sul posto, leggere [le considerazioni sull'accesso remoto](docs/remote-access.md): il firmware potrebbe chiedere una conferma fisica. Nel caso documentato il normale riavvio è bastato e l'accesso remoto è tornato.

```powershell
shutdown /r /t 0
```

Quando Windows torna operativo, eseguire `Test-IntelVtx.ps1`: il risultato atteso è `VirtualizationFirmwareEnabled = True`. Un successo di INSTALL, da solo, conferma l'accettazione della scrittura, non l'attivazione nella CPU.

## Ripristino e limiti

Ogni operazione prepara `restore.ini` con il valore iniziale, insieme al backup completo dei token e ai metadati dell'operazione. Il [README inglese](README.md#restore-the-previous-setting) descrive come applicarlo. Il ripristino è comunque una scrittura firmware e richiede le stesse verifiche sull'accesso remoto.

Questo progetto abilita VT-x sulla piattaforma documentata. Non recupera dischi VDI o installazioni XP perse, non sblocca password BIOS e non aggiorna il firmware. La documentazione Legacy non elenca Windows 11 tra i sistemi supportati: riportiamo un caso funzionante, non una garanzia del produttore.

Se ti ha risparmiato un intervento nel BIOS, lascia una **star**. Per altre schede, contribuisci con un report verificabile e senza dati personali.

Licenza MIT per gli script e la documentazione originali. I componenti Intel mantengono i loro termini e non sono inclusi.

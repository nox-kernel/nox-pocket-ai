# NOX Pocket AI

**Private, portable, offline chat AI — built on a USB drive.** An experimental, free Windows starter project by NOX Kernel. Download this repository, run the installer **once while online**, and then use the model **offline** from the USB drive on a compatible Windows PC.

**What it is:** A portable folder containing the llama.cpp Windows CPU runtime, a local Qwen3 1.7B quantised GGUF model and starter scripts. The AI **runs on the computer's CPU and RAM**, not inside the USB hardware. It does **not** run Windows from the USB or install an AI cloud service.

**What it costs:** £0 in software or API fees. You provide the USB and Windows computer. No ChatGPT plan, login, API key, Python, CUDA or discrete GPU is required.

> **Project status: experimental preview.** The installation and offline workflow have not yet been confirmed through a complete physical Windows USB test. Compatibility may vary; see [TEST-LOG.md](TEST-LOG.md) for results and report reproducible issues.

## Quick start (Windows x64)

1. Click **Code → Download ZIP** on this page (or clone the repo). Extract it into a folder on an **8GB+ USB drive** (exFAT or NTFS recommended).
2. Connect to the internet **for the initial setup**. Double-click **INSTALL-NOX-AI.bat**.
3. Follow the on-screen status. It downloads an official llama.cpp Windows x64 **CPU** release and the **Qwen3-1.7B-Q4_K_M.gguf** model from Hugging Face to your USB. Downloads are not stored in this Git repo.
4. Double-click **VERIFY-NOX-AI.bat** to check the files.
5. Double-click **START-NOX-AI.bat**. A local server starts; the built-in chat UI opens at **http://127.0.0.1:8080** when ready. Alternatively open **OPEN-LOCAL-CHAT.url** yourself.
6. Test offline: stop the server (close its console), disconnect Wi-Fi/Ethernet, start it again and send a prompt.

The **first setup needs internet**. After the downloads are complete and the dependencies are available on the destination PC, **local inference does not**. Windows may require Microsoft Visual C++ runtime components already present on many systems; see TECH-SHEET.md.

### Supported starting point

| Item | Baseline |
| --- | --- |
| Host | Windows 10/11 x64 (not macOS, Linux, or Windows on ARM) |
| Computer RAM | 8GB or more recommended (6GB may work with tight memory limits) |
| USB | 8GB minimum; USB 3.x preferred |
| CPU | x64 CPU; newer CPUs are typically faster |
| GPU | Not required; CPU mode |
| Runtime | [llama.cpp](https://github.com/ggml-org/llama.cpp), Windows x64 CPU release |
| Model | [Qwen3-1.7B Q4_K_M](https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/tree/main) from Unsloth; approximately 1.1GB file |
| Chat UI | Included with llama.cpp, runs locally in your web browser |
| Address | http://127.0.0.1:8080 (loopback only; NOT exposed to the LAN) |

Small models can hallucinate, are slower on older CPUs, and are not substitutes for large cloud models. The first answer may take some time.

## Main launchers

- **INSTALL-NOX-AI.bat** — initial online download and setup.
- **START-NOX-AI.bat** — start offline chat after installation.

Also included: **VERIFY-NOX-AI.bat**, **OPEN-LOCAL-CHAT.url**, the PowerShell implementation under `tools/`, a technical guide, and a compatibility test log.

## Files and layout

~~~
nox-pocket-ai/
├── INSTALL-NOX-AI.bat
├── START-NOX-AI.bat
├── VERIFY-NOX-AI.bat
├── OPEN-LOCAL-CHAT.url
├── README.md
├── TECH-SHEET.md
├── VIDEO-SCRIPT.md        <- project production reference
├── TEST-LOG.md            <- compatibility checks
├── SOURCES-AND-LICENSES.md
├── bin/                  <- llama.cpp executable + required DLLs (downloaded)
├── models/               <- Qwen GGUF (downloaded)
├── tools/                <- installer, launcher, verifier, local manifest
└── recording/            <- project production resources
~~~

The USB drive letter may change between computers; scripts use their own folder location instead of a hardcoded drive letter. Do not move the BAT files out of the project folder.

## Safety, privacy and limitations

- Inference takes place locally. The launcher explicitly uses **--host 127.0.0.1**, so other devices cannot connect to it by default.
- This is **not an encrypted USB**. Prompts/history or other files saved by a browser can remain on the host. Follow your browser's privacy controls and never assume absolute anonymity.
- The installer downloads *executables* from GitHub and model data from Hugging Face. Review the PowerShell scripts under tools/ before executing. The installer checks available upstream checksums and saves local SHA-256 fingerprints; see TECH-SHEET.md.
- The installer does **not** automatically format your USB drive, require administrator privileges or change the system-wide PowerShell execution policy.
- Qwen3 can emit internal reasoning/thinking text; the built-in UI usually displays it separately.
- Running on a second computer requires a compatible Windows x64 CPU and any necessary system runtime libraries. Model speed depends on the host; the USB does not provide compute.

## Optional AI-guided setup

You can follow the guide without any AI subscription. For optional help from ChatGPT or another assistant, use this prompt:

> I downloaded the NOX Pocket AI repository and extracted it to a USB drive. I'm using a Windows x64 PC. Walk me through TECH-SHEET.md one action at a time. Don't ask me for API keys, don't recommend a paid service, and don't assume a cloud connection after installation. Help me confirm the llama.cpp executable, GGUF model, localhost chat interface, and then an offline test. If something fails, explain the error and give one safe diagnostic step before any destructive action.

The repository and its scripts work independently of the assistant used to read the instructions.

## Troubleshooting and contributing

See **TECH-SHEET.md** first. Please include your Windows version, CPU, RAM, exact error message, and whether the problem occurs during download or offline launch in an issue. Don't post private prompts or passwords.

License: original NOX launch scripts and documentation are MIT licensed (see LICENSE). Third-party software and models retain their own licences (see SOURCES-AND-LICENSES.md).

# NOX Pocket AI

**Private, portable, offline chat AI — built on a USB drive.** An experimental, free Windows starter project by NOX Kernel. Download this repository, run the installer **once while online**, and then use the model **offline** from the USB drive on a compatible Windows PC.

**What it is:** A portable folder containing the llama.cpp Windows CPU runtime, a local Qwen3 1.7B quantised GGUF model and starter scripts. The AI **runs on the computer's CPU and RAM**, not inside the USB hardware. It does **not** run Windows from the USB or install an AI cloud service.

**What it costs:** £0 in software or API fees. You provide the USB and Windows computer. No ChatGPT plan, login, API key, Python, CUDA or discrete GPU is required.

> **Project status: experimental preview.** The pinned runtime/model have been installed and used for local chat on one Windows 11 x64 PC. Disconnected-network operation and a second PC have not yet been verified. Check the requirements and test on your own PC.

## Quick start (Windows x64)

1. Plug in an **8GB+ USB drive** with at least **4GB free** (exFAT or NTFS recommended). You do not need to format an existing suitable drive.
2. On this GitHub page, click the green **Code** button, then **Download ZIP**. Open **File Explorer → Downloads** and find **nox-pocket-ai-main.zip**.
3. Right-click the ZIP and choose **Extract All...**. Click **Browse**, choose your USB under **This PC** and extract. Open the extracted **nox-pocket-ai-main** folder until you can see **INSTALL-NOX-AI.bat**, **START-NOX-AI.bat** and **VERIFY-NOX-AI.bat** together. Do not run files while viewing the ZIP itself.
4. Stay online and double-click **INSTALL-NOX-AI.bat**. A setup window downloads and verifies the pinned **llama.cpp b11809 CPU runtime** and **Qwen3 1.7B Q4_K_M** model. The model is **1.28 GB**, so leave the window open. When it reports installation finished, press a key to close it.
5. Double-click **VERIFY-NOX-AI.bat**. Wait for the runtime and model checks to pass, then press a key to close it.
6. Double-click **START-NOX-AI.bat**. Leave the server window open. When the model is ready, the browser opens at **http://127.0.0.1:8080**; send a question. Alternatively open **OPEN-LOCAL-CHAT.url**.
7. To finish, close the server window before safely ejecting the USB. For a separate offline test, first stop the server, disconnect Wi-Fi/Ethernet, then start it again and send a new question.

If Windows hides file extensions, the launchers may appear as **INSTALL-NOX-AI**, **VERIFY-NOX-AI** and **START-NOX-AI**, with type **Windows Batch File**. The USB letter may differ from the one shown in the video.

The **first setup needs internet**. After the downloads are complete and the dependencies are available on the destination PC, **local inference does not**. Windows may require Microsoft Visual C++ runtime components already present on many systems; see TECH-SHEET.md.

### Supported starting point

| Item | Baseline |
| --- | --- |
| Host | Windows 10/11 x64 (not macOS, Linux, or Windows on ARM) |
| Computer RAM | 8GB or more recommended (6GB may work with tight memory limits) |
| USB | 8GB minimum; USB 3.x preferred |
| CPU | x64 CPU; newer CPUs are typically faster |
| GPU | Not required; CPU mode |
| Runtime | [llama.cpp b11809](https://github.com/ggml-org/llama.cpp/releases/tag/b11809), Windows x64 CPU release |
| Model | [Qwen3-1.7B Q4_K_M](https://huggingface.co/ggml-org/Qwen3-1.7B-GGUF) from ggml-org; 1,282,439,264 bytes (1.28 GB) |
| Chat UI | Included with llama.cpp, runs locally in your web browser |
| Address | http://127.0.0.1:8080 (loopback only; NOT exposed to the LAN) |

Small models can hallucinate, are slower on older CPUs, and are not substitutes for large cloud models. The first answer may take some time.

## Main launchers

- **INSTALL-NOX-AI.bat** — initial online download and setup.
- **START-NOX-AI.bat** — start offline chat after installation.

Also included: **VERIFY-NOX-AI.bat**, **OPEN-LOCAL-CHAT.url**, the PowerShell scripts under `tools/`, and a detailed setup and troubleshooting guide in **TECH-SHEET.md**.

## Files and layout

~~~
nox-pocket-ai/
├── INSTALL-NOX-AI.bat
├── START-NOX-AI.bat
├── VERIFY-NOX-AI.bat
├── OPEN-LOCAL-CHAT.url
├── README.md
├── TECH-SHEET.md
├── SOURCES-AND-LICENSES.md
├── bin/                  <- llama.cpp executable + required DLLs (downloaded)
├── models/               <- Qwen GGUF (downloaded)
└── tools/                <- installer, launcher, verifier, local manifest
~~~

The USB drive letter may change between computers; scripts use their own folder location instead of a hardcoded drive letter. Do not move the BAT files out of the project folder.

## Safety, privacy and limitations

- Inference takes place locally. The launcher explicitly uses **--host 127.0.0.1**, so other devices cannot connect to it by default.
- This is **not an encrypted USB**. Prompts/history or other files saved by a browser can remain on the host. Follow your browser's privacy controls and never assume absolute anonymity.
- The installer downloads *executables* from GitHub and model data from Hugging Face. Review the PowerShell scripts under tools/ before executing. Release/model revision, sizes and mandatory SHA-256 values are pinned in **tools/asset-manifest.json**; the verifier checks those values without an internet connection.
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

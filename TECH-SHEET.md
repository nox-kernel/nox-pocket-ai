# TECH SHEET — NOX Pocket AI / Windows USB Setup

**Goal:** Download once, then move a portable CPU-only LLM between suitable Windows computers. No API or subscription is used. Expected runtime: llama.cpp serving a locally stored Qwen3-1.7B GGUF and its built-in web chat UI at http://127.0.0.1:8080.

## 0. Before anything else

- PC: Windows 10/11 **64-bit x64**, ideally 8GB+ RAM. This project does not currently support Linux, macOS or Windows ARM.
- USB: **8GB+**, USB 3.x recommended; exFAT or NTFS recommended. Copy off anything important before manually formatting a USB. **The scripts never format it.**
- Initial connection: Internet access (the 1.28 GB model and a 24 MB Windows CPU runtime archive must be downloaded).
- An unzip utility or Windows Explorer. No Python, Docker, GPU or API key required.
- Allow enough free space on the USB for the downloaded model, runtime and temporary unpacking (at least 4GB free is a sensible target).

## 1. Get the project

From https://github.com/nox-kernel/nox-pocket-ai select **Code → Download ZIP**. Extract the folder *on the USB*. Example after extraction:

~~~
E:\nox-pocket-ai-main\
  INSTALL-NOX-AI.bat
  START-NOX-AI.bat
  VERIFY-NOX-AI.bat
  bin\
  models\
  tools\
~~~

Do not run the BAT files while they are still inside the ZIP, and do not move them away from tools/.

Advanced option:

~~~powershell
git clone https://github.com/nox-kernel/nox-pocket-ai.git E:\nox-pocket-ai
~~~

E: is only an example; do not hardcode it in scripts.

## 2. Install (online, one time)

Double-click **INSTALL-NOX-AI.bat**. It opens Windows PowerShell with a per-process script policy override; it does not change the machine-wide policy.

The installer:
1. Creates bin/, models/ and temporary folders on the USB.
2. Checks that Windows is 64-bit x64.
3. Reads **tools/asset-manifest.json**, which pins **llama.cpp b11809 Windows CPU x64** and a specific ggml-org Qwen model revision. It does not search for a changing latest release.
4. Downloads the pinned runtime archive and requires its exact size and SHA-256 to match before extraction.
5. Unzips the archive and copies the executable and accompanying DLLs to bin/.
6. Downloads **Qwen3-1.7B-Q4_K_M.gguf** from ggml-org on Hugging Face, requires its exact size (1,282,439,264 bytes) and pinned SHA-256, and records the installed versions/checks in **tools/download-manifest.json**.
7. Removes temporary extracted files and prints the next steps.

The installer checks already present runtime/model files and reuses them only when they match the pinned values. If files differ or a runtime is incomplete, it stops without replacing them. Keep that folder as a backup and extract a fresh project folder for a clean installation. Do not edit a manifest to make a failed check appear to pass.

If your PowerShell security tools block downloads, do not turn off security or add blanket exclusions; inspect the destination, script and upstream publisher URLs first.

## 3. Verify (online or offline)

Double-click **VERIFY-NOX-AI.bat**. It reports:
- Windows x64 architecture and the current project folder;
- SHA-256 of every packaged runtime file, including the small server launcher and companion DLLs;
- the exact model size and SHA-256 compared with the pinned asset manifest;
- any missing components or verification errors.

A passed check does **not** prove the server can run on every computer. A real launch/chat/offline test is still required. This llama.cpp release uses a **9 KB launcher EXE** and a larger implementation DLL; the small EXE is expected, so file size alone is not a valid runtime check.

## 4. Start the local browser chat

Double-click **START-NOX-AI.bat**. Its PowerShell launcher:
- refuses to take over port 8080 if something is already listening there;
- starts the downloaded server using the local model and CPU only;
- binds only to **127.0.0.1**, port **8080**;
- uses a modest context size (2048 tokens) to fit lower-memory PCs;
- waits for the server's /health endpoint and opens your default browser when ready.

If the browser does not open, run **OPEN-LOCAL-CHAT.url** once the server prints that it is ready, or browse to http://127.0.0.1:8080.

Leave the server console open while chatting. To stop, close that server console, or press Ctrl+C in it. Eject the USB only *after* stopping the server and closing files on it.

### Command used under the hood

~~~powershell
.\bin\llama-server.exe -m ".\models\Qwen3-1.7B-Q4_K_M.gguf" --host 127.0.0.1 --port 8080 --ctx-size 2048 --n-gpu-layers 0
~~~

The scripted launcher supplies an absolute model path so it works when the USB drive letter changes.

## 5. Prove offline operation

1. While online, complete INSTALL and a successful local chat.
2. Close the server window.
3. Disconnect Wi-Fi, unplug Ethernet, and ensure any VPN or tethering is inactive.
4. Start **START-NOX-AI.bat** again, open the local URL, and ask a fresh question.
5. If possible, safely stop the server, move the USB to a *second* compatible Windows PC, and repeat the offline launch to confirm portability.

**How it works:** Internet access is needed for the initial downloads. The USB stores the AI files; the PC supplies CPU, RAM and power for local inference.

## Troubleshooting

| Symptom | Check / safe action |
| --- | --- |
| Windows says a .bat is untrusted | Confirm it came from our GitHub repository, review tools/*.ps1, and use the normal Windows file properties/security flow. Never disable antivirus globally. |
| The initial download fails | Check connectivity, available USB capacity, and whether github.com / huggingface.co are reachable. Re-run when online; partial .part files are removed on the next attempt. |
| Pinned download unavailable | Check connectivity and the official source URL, then open a repo issue. The installer stops rather than silently choosing a different build/model. |
| Model/runtime fails checksum or is incomplete | Keep the existing project folder as a backup, extract the project into a fresh folder and install again. Record the exact error and source URL if the issue repeats. |
| Missing DLL / executable won't start | Make sure the whole llama.cpp binary folder (including DLLs) was copied, not just the EXE. The host might need Microsoft's supported Visual C++ runtime. |
| Browser says site can't be reached | Look for an error in the server console; check whether port 8080 is already in use. Wait for model loading before opening the URL. |
| Port 8080 occupied | Close the application using that port. Do **not** reconfigure the launcher to 0.0.0.0 merely to work around a port conflict. |
| AI is very slow | The CPU and available RAM determine speed. Close heavy apps; prefer USB 3.x. Qwen3 1.7B is a compact model, not a fast cloud GPU. |
| It worked on first PC, fails on another | Check 64-bit Windows, CPU instruction compatibility, missing redistributables, RAM and local security policy. |
| Chat doesn't open offline | Ensure both the runtime EXE/DLLs and model GGUF exist on the USB. A model card URL isn't the model file. |
| GitHub ZIP download doesn't contain model | Correct by design. Run the installer once online; large third-party binary files are not redistributed in Git. |

## Final setup checks

- [ ] The downloaded `llama-server.exe` and GGUF model are both present on the USB.
- [ ] `VERIFY-NOX-AI.bat` reports no errors.
- [ ] `START-NOX-AI.bat` opens the local chat interface at http://127.0.0.1:8080.
- [ ] The model responds to a question while the computer is offline.
- [ ] The server is stopped before safely ejecting the USB.

## Upstream documentation

- llama.cpp releases: https://github.com/ggml-org/llama.cpp/releases
- llama.cpp server docs: https://github.com/ggml-org/llama.cpp/tree/master/tools/server
- Qwen base model: https://huggingface.co/Qwen/Qwen3-1.7B
- Qwen GGUF chosen: https://huggingface.co/ggml-org/Qwen3-1.7B-GGUF
- Licences/credits: SOURCES-AND-LICENSES.md

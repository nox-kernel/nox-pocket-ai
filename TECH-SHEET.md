# TECH SHEET — NOX Pocket AI / Windows USB Setup

**Goal:** Download once, then move a portable CPU-only LLM between suitable Windows computers. No API or subscription is used. Expected runtime: llama.cpp serving a locally stored Qwen3-1.7B GGUF and its built-in web chat UI at http://127.0.0.1:8080.

## 0. Before anything else

- PC: Windows 10/11 **64-bit x64**, ideally 8GB+ RAM. This project does not currently support Linux, macOS or Windows ARM.
- USB: **8GB+**, USB 3.x recommended; exFAT or NTFS recommended. Copy off anything important before manually formatting a USB. **The scripts never format it.**
- Initial connection: Internet access (the ~1.1GB model and a Windows CPU runtime archive must be downloaded).
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
3. Requests the **llama.cpp releases list** and picks the newest non-draft release that includes a Windows **CPU x64** ZIP (some tags publish no binaries).
4. Downloads the runtime from the published GitHub release asset. If GitHub provides a SHA-256 digest, the archive is checked before extraction.
5. Unzips the archive and copies the executable and accompanying DLLs to bin/.
6. Requests file metadata for Qwen3-1.7B-Q4_K_M.gguf from the Hugging Face Unsloth model repository, downloads it, verifies the expected size and SHA-256 where publisher metadata supplies them, checks the GGUF magic bytes, and stores a local SHA-256 in tools/download-manifest.json.
7. Removes temporary extracted files and prints the next steps.

The installer skips already present runtime/model files. To deliberately update a binary or model, back up first, remove the old contents of the applicable bin/ or models/ folder and re-run INSTALL-NOX-AI.bat while online. Do not edit tools/download-manifest.json as a substitute for a genuine verification.

If your PowerShell security tools block downloads, do not turn off security or add blanket exclusions; inspect the destination, script and upstream publisher URLs first.

## 3. Verify (online or offline)

Double-click **VERIFY-NOX-AI.bat**. It reports:
- architecture, current drive and rough available memory;
- existence and plausible size of bin/llama-server.exe and the .gguf;
- GGUF file signature;
- local SHA-256 compared with the install manifest if available;
- any missing components or verification errors.

A passed check does **not** prove the server can run on every computer. A real launch/chat/offline test is still required.

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
5. Capture the working chat and Windows network-disconnected indicator on video.
6. If possible, safely stop the server, move the USB to a *second* compatible Windows PC and repeat steps 4–5.

**Truth in advertising:** You only need the internet during setup. A USB flash drive does not perform inference; the PC supplies CPU, RAM and power.

## Troubleshooting

| Symptom | Check / safe action |
| --- | --- |
| Windows says a .bat is untrusted | Confirm it came from our GitHub repository, review tools/*.ps1, and use the normal Windows file properties/security flow. Never disable antivirus globally. |
| The initial download fails | Check connectivity, available USB capacity, and whether github.com / huggingface.co are reachable. Re-run when online; partial .part files are removed on the next attempt. |
| No matching Windows CPU release | GitHub release naming may have changed. Check official llama.cpp releases, then open a repo issue instead of downloading a random executable. |
| Model fails checksum / size | Delete the incomplete model and re-run the installer. If the issue repeats, record the exact error and source URL. |
| Missing DLL / executable won't start | Make sure the whole llama.cpp binary folder (including DLLs) was copied, not just the EXE. The host might need Microsoft's supported Visual C++ runtime. |
| Browser says site can't be reached | Look for an error in the server console; check whether port 8080 is already in use. Wait for model loading before opening the URL. |
| Port 8080 occupied | Close the application using that port. Do **not** reconfigure the launcher to 0.0.0.0 merely to work around a port conflict. |
| AI is very slow | The CPU and available RAM determine speed. Close heavy apps; prefer USB 3.x. Qwen3 1.7B is a compact model, not a fast cloud GPU. |
| It worked on first PC, fails on another | Check 64-bit Windows, CPU instruction compatibility, missing redistributables, RAM and local security policy. |
| Chat doesn't open offline | Ensure both the runtime EXE/DLLs and model GGUF exist on the USB. A model card URL isn't the model file. |
| GitHub ZIP download doesn't contain model | Correct by design. Run the installer once online; large third-party binary files are not redistributed in Git. |

## Compatibility validation checklist

- [ ] Clean Windows 10/11 x64 setup succeeds from a fresh ZIP.
- [ ] Installer finds an actual CPU x64 release and copies the necessary DLLs.
- [ ] Qwen3 model downloads completely and verifies.
- [ ] A normal double-click launch opens the built-in chat UI.
- [ ] A useful example prompt responds with the network disconnected.
- [ ] Test on a second PC with a different drive letter and no installed development tools.
- [ ] No Windows firewall rule, cloud API, admin access, or system-wide policy change is needed.
- [ ] Record version/build, CPU, RAM, USB type, date and any limitations in TEST-LOG.md.

## Upstream documentation

- llama.cpp releases: https://github.com/ggml-org/llama.cpp/releases
- llama.cpp server docs: https://github.com/ggml-org/llama.cpp/tree/master/tools/server
- Qwen base model: https://huggingface.co/Qwen/Qwen3-1.7B
- Qwen GGUF chosen: https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/tree/main
- Licences/credits: SOURCES-AND-LICENSES.md

# NOX Pocket AI — YouTube production plan

**Format:** clear, authentic technical demo. 3–6 minute main video; use actual terminal output and real performance, not a staged fake chat. Film a successful dry run first, then record a clean install.

## Working title options

1. Build a Private Offline AI on a USB Stick — Free
2. Can a USB Stick Run an AI? Here's What Really Happens
3. NOX Pocket AI — Local Chat Anywhere, No Cloud API

Suggested thumbnail: USB stick + Windows laptop + disconnected Wi-Fi symbol. Caption: **OFFLINE AI / £0 API**. Don't imply the USB itself performs computation.

## Storyboard / shots

| Time | Visual | Narration cue |
| --- | --- | --- |
| 0:00–0:20 | Plug in USB; Windows network off; response appearing in browser | "This is a local language model running with no internet connection. The files travel on USB; the computer does the thinking." |
| 0:20–0:45 | USB/Windows system info | Explain 8GB+ USB, Windows x64, 8GB RAM recommended, no GPU required. |
| 0:45–1:15 | Public NOX GitHub repo / Code → Download ZIP | "Everything needed to get started is in the repo. No AI subscription or API key." |
| 1:15–2:00 | Extract to USB; project tree; installer running | Point out INSTALL and START, first-time downloads from official publishers. |
| 2:00–2:40 | VERIFY output and model filename | Show real filenames; explain GGUF and approx 1.1GB model. |
| 2:40–3:20 | START; local browser UI | "The browser is only the interface; llama.cpp does inference on this PC." |
| 3:20–4:05 | Disconnect Wi-Fi; run a new prompt | Prove the offline test on camera. |
| 4:05–4:40 | Move USB to another compatible PC (if actually tested) | Demonstrate portability; mention different CPUs can perform differently. |
| 4:40–5:00 | Repo / source credits / next episode | Invite issue reports and honest benchmarking. |

## Voiceover outline

**Cold open:** "No cloud API. No login. No GPU required. This small local model runs offline from a USB folder — but let's be precise: the USB stores the files, and the PC handles the calculations."

**Build:** "Grab the repo, extract it to your USB drive, and run the installer while you're connected. It downloads llama.cpp and a compact quantised Qwen3 model. The repository doesn't hide a gigabyte binary inside the ZIP."

**Chat:** "Open START-NOX-AI. The runtime serves a browser UI on 127.0.0.1, which means the interface stays on this computer by default."

**Proof:** "Now I'll shut down the server, disconnect the internet, and launch it again. Here's a fresh prompt. Nothing here relies on an account or a remote API."

**Caveat:** "You won't get frontier-model intelligence or GPU speed from a 1.7B model, and some Windows PCs need extra runtime libraries. But this is a great starting point for understanding how local inference works."

**Call to action:** "The code and checklist are linked below. Reproduce the test, document your hardware, and report issues so we can improve NOX Pocket AI together."

## Video description (copy and adjust after the test)

~~~
NOX Pocket AI: a free Windows USB-based offline LLM starter project.
The USB stores the model + runtime; the Windows host does CPU inference.

PROJECT / FREE DOWNLOAD
https://github.com/nox-kernel/nox-pocket-ai
GET THE ZIP
https://github.com/nox-kernel/nox-pocket-ai/archive/refs/heads/main.zip

Stack: llama.cpp (CPU) + Qwen3 1.7B Q4_K_M (GGUF)
Recommended: Windows 10/11 x64, 8GB+ RAM, 8GB+ USB
First-time download requires internet; chatting can work offline after setup.
No ChatGPT plan, cloud API, or GPU is required.

Read TECH-SHEET.md for the full guide, troubleshooting, sources & licences.
#OfflineAI #LocalLLM #Homelab #NoxKernel
~~~

## Suggested pinned comment

"Please don't format a USB without backing up your own files. Setup downloads the runtime and model from their publishers and needs internet ONCE; the test runs with the network off. Send bugs via the GitHub Issues tab with your CPU/RAM/Windows version. Please don't post private prompts."

## Reusable viewer prompt (plan-independent)

> I'm using NOX Pocket AI from https://github.com/nox-kernel/nox-pocket-ai to build a Windows USB offline chat model. My Windows version is [version], CPU is [CPU], RAM is [RAM], USB has [space] free. Teach me INSTALL, VERIFY, START and the offline test, following the repo TECH-SHEET.md. Work one step at a time, explain errors clearly, never ask for API keys or a paid ChatGPT plan, and warn me before destructive commands. If you can generate artifacts, you may package an equivalent scaffold as a ZIP; otherwise give me text I can save as files. Prefer the maintained GitHub repo over generating untested alternate scripts.

## Recording checklist

- [ ] Show the actual GitHub URL and correct account.
- [ ] Use a blank/sanitised Windows account; hide tokens, e-mail, private filenames.
- [ ] Don't falsely claim that inference happens on the USB stick.
- [ ] Confirm **both** online setup and offline inference on camera.
- [ ] Label hardware and approximate response speed honestly.
- [ ] Cite llama.cpp/Qwen/Unsloth credits and licences.
- [ ] Upload a genuine test log; do not mark untested items as passed.

# Sources, credits and licences

NOX Pocket AI is a **small integration project**. The repository supplies scripts and guides; it **does not redistribute** a pre-trained model or compiled llama.cpp binaries. First-time installation downloads those from their publishers. Respect upstream licence and attribution requirements if you fork, modify or redistribute downloaded components.

| Component | Publisher / source | Licence / notes |
| --- | --- | --- |
| NOX launch scripts + docs | https://github.com/nox-kernel/nox-pocket-ai | MIT (see LICENSE) |
| llama.cpp inference server | https://github.com/ggml-org/llama.cpp | MIT; inspect current upstream LICENSE |
| Windows binary releases | https://github.com/ggml-org/llama.cpp/releases | Official builds; may bundle libraries with their own notices |
| Qwen3-1.7B base model | https://huggingface.co/Qwen/Qwen3-1.7B | Apache 2.0 |
| Qwen3-1.7B-GGUF quantisation | https://huggingface.co/unsloth/Qwen3-1.7B-GGUF | Listed Apache 2.0; check model card and files |
| Microsoft PowerShell / Windows | Microsoft | Provided by the user's Windows installation |

## Download destinations used by the installer

- Runtime release metadata: https://api.github.com/repos/ggml-org/llama.cpp/releases?per_page=100
- Runtime archive: the selected release's browser_download_url, with a win-cpu-x64 ZIP filename.
- Model metadata: https://huggingface.co/api/models/unsloth/Qwen3-1.7B-GGUF/tree/main
- Model binary: https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_K_M.gguf

## Integrity and security

The installer checks publisher metadata and available SHA-256 digests for downloads. If a publisher does not expose a digest, it records its *own* SHA-256 for later integrity checks, but such a locally computed hash **is not equivalent to publisher authenticity verification**. TLS/download origin and review of scripts still matter.

The project does not request API keys and the server binds to 127.0.0.1. Don't publish personal model chats, account tokens or a server reachable from the internet.

This attribution document isn't a substitute for the full upstream licence terms. If you distribute a prepared USB containing upstream binaries/models, include their respective licence and notices.

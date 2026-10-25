# Sources, credits and licences

NOX Pocket AI is a **small integration project**. The repository supplies scripts and guides; it **does not redistribute** a pre-trained model or compiled llama.cpp binaries. First-time installation downloads those from their publishers. Respect upstream licence and attribution requirements if you fork, modify or redistribute downloaded components.

| Component | Publisher / source | Licence / notes |
| --- | --- | --- |
| NOX launch scripts + docs | https://github.com/nox-kernel/nox-pocket-ai | MIT (see LICENSE) |
| llama.cpp inference server | https://github.com/ggml-org/llama.cpp | MIT; inspect current upstream LICENSE |
| Windows binary releases | https://github.com/ggml-org/llama.cpp/releases | Official builds; may bundle libraries with their own notices |
| Qwen3-1.7B base model | https://huggingface.co/Qwen/Qwen3-1.7B | Apache 2.0 |
| Qwen3-1.7B-GGUF quantisation | https://huggingface.co/ggml-org/Qwen3-1.7B-GGUF | Listed Apache 2.0; check model card and files |
| Microsoft PowerShell / Windows | Microsoft | Provided by the user's Windows installation |

## Download destinations used by the installer

- Runtime archive: https://github.com/ggml-org/llama.cpp/releases/download/b11809/llama-b11809-bin-win-cpu-x64.zip
- Model binary: https://huggingface.co/ggml-org/Qwen3-1.7B-GGUF/resolve/daeb8e2d528a760970442092f6bf1e55c3b659eb/Qwen3-1.7B-Q4_K_M.gguf?download=true
- Exact versions, file sizes, hashes and runtime file checksums: **tools/asset-manifest.json**. Runtime file hashes were derived from the archive whose SHA-256 matches the GitHub release digest; the model SHA-256 matches the publisher's Git LFS object.

## Integrity and security

The installer requires the checked-in SHA-256 values for both downloads; a mismatch stops installation. The offline verifier checks all packaged runtime files and the model against this pinned manifest. The install receipt records what was installed and is not the trust source. TLS/download origin and review of scripts still matter.

The project does not request API keys and the server binds to 127.0.0.1. Don't publish personal model chats, account tokens or a server reachable from the internet.

This attribution document isn't a substitute for the full upstream licence terms. If you distribute a prepared USB containing upstream binaries/models, include their respective licence and notices.

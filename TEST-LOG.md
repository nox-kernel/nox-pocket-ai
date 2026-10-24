# NOX Pocket AI — reproducibility & test log

> **Not yet end-to-end tested in this repository.** Do not substitute this template for a real test. Write results after running on a physical Windows computer.

| Date (UTC) | Windows build | CPU | RAM | USB / filesystem | llama.cpp tag | First install | Local UI | Offline | Second PC | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| _not tested_ | — | — | — | — | — | Pending | Pending | Pending | Pending | Run real test before publishing |

## Detailed test record template

- Date / tester:
- Windows edition / version:
- CPU:
- Host RAM:
- USB model, capacity, filesystem and free space:
- llama.cpp tag and asset filename (from tools/download-manifest.json):
- Model filename, downloaded size, verified SHA-256:
- Installer exit status / errors:
- Verify output:
- Server startup time:
- Actual prompt and response (sanitised):
- Network disabled: Wi-Fi OFF, Ethernet unplugged, tethering/VPN OFF:
- Offline response succeeded?:
- Second host / changed drive letter result:
- Security flags / antivirus issues:
- Follow-up GitHub issue or fix commit:

## Acceptance checklist

- [ ] Online installer succeeds with clean extract.
- [ ] No partial model files after successful install.
- [ ] Verify reads downloaded model and executable.
- [ ] Chat browser is accessible at http://127.0.0.1:8080.
- [ ] Server is bound only to loopback and does not accept LAN clients.
- [ ] An actual answer is generated with the internet disconnected.
- [ ] Works after move to a different USB drive letter.
- [ ] No API or paid ChatGPT subscription needed.
- [ ] Stop server before ejecting the USB.

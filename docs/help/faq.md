# FAQ

---

## Is this installer affiliated with Steven Atkin or the upstream project?

No. This is an independent, unaffiliated packaging effort by
[Jay German](https://github.com/jsgermanaai). Steven Atkin created
[MLX Training Studio](https://github.com/stevenatkin/mlx-lm-gui) and all credit
for the application belongs to him and contributors. This installer simply
automates the clone-build-install workflow that upstream does not provide.

---

## Why not publish a pre-built binary?

Two reasons:

1. **Upstream choice.** The upstream project publishes source only. Redistributing
   a binary of someone else's app raises licensing and maintenance questions even
   when the license (Apache-2.0) technically permits it.

2. **Apple Silicon code signing.** Distributing a non-sandboxed macOS app outside
   the App Store requires an Apple Developer notarization. Building locally means
   Gatekeeper sees the app as locally built, which requires only a one-time
   quarantine attribute removal rather than a notarization identity.

See [Architecture — why source-only build](../reference/architecture.md#why-source-only-build)
for the full explanation.

---

## Can I run this on an Intel Mac?

No. The upstream application is built on Apple's
[MLX](https://github.com/ml-explore/mlx) framework, which targets Apple Silicon
(arm64) exclusively. `mlx-training-studio doctor` will report a hard failure on
Intel hardware:

```
[ERR ] Architecture 'x86_64' detected. Apple Silicon (arm64) is required.
[ERR ] Intel Macs are not supported by the upstream application.
```

There is no workaround — this is an upstream constraint.

---

## How do I run training without the GUI?

Use `mlx-lm-lora` directly from the command line. Install it in a Python 3.12+
virtual environment:

```sh
python3.12 -m venv ~/mlx-venv
source ~/mlx-venv/bin/activate
pip install mlx-lm-lora

# Fine-tune a model
python -m mlx_lm.lora \
  --model Qwen/Qwen2.5-0.5B-Instruct \
  --data ~/datasets/my-data \
  --train \
  --batch-size 4 \
  --num-epochs 3
```

See the [mlx-lm documentation](https://github.com/ml-explore/mlx-examples/tree/main/llms/mlx_lm)
for the full CLI reference.

---

## Is this the same as "MLX Studio" or "LM Studio"?

No — these are three different applications:

| Name | What it is |
|---|---|
| **MLX Training Studio** (this installer) | Swift macOS app for LoRA/QLoRA **fine-tuning** on Apple Silicon via mlx-lm-lora |
| **MLX Swift** / **MLX** | Apple's machine learning framework for Apple Silicon |
| **LM Studio** | A separate, closed-source application for running LLM inference locally (chat UI, model manager) — not related |

---

## Will this installer track upstream forever?

By default, yes — `mlx-training-studio update` fetches and resets to
`origin/main`, so you always get the latest upstream commit.

To lock to a specific commit:

```sh
MLX_TS_REF=a3f9c21b84d7e05c1f2843b6d9a0e1f3c5d2e4b8 mlx-training-studio update
```

Run `mlx-training-studio status` to see the currently installed commit.

---

## How do I check which version I have installed?

```sh
mlx-training-studio status
```

This prints the manifest JSON, which includes:

- `installer_version` — the version of this installer that performed the install.
- `upstream_commit` — the full commit SHA of the upstream source that was built.
- `installed_at` — the UTC timestamp of the last install or update.

---

## Can I install to a location other than `/Applications`?

Yes. Set `MLX_TS_INSTALL_DIR`:

```sh
MLX_TS_INSTALL_DIR="${HOME}/Applications" mlx-training-studio install
```

Or choose option 2 (`~/Applications`) at the interactive prompt during
`mlx-training-studio install`.

---

## Does the installer need root / sudo?

The installer itself does not run as root. `cp` and `mv` to `/Applications` on
macOS does not require root for bundles (it is writable by the owner on a
standard macOS install).

The following steps do require `sudo` if you need them:

| Operation | Requires sudo |
|---|---|
| Switch Xcode developer directory | `sudo xcode-select -s ...` |
| Accept Xcode license | `sudo xcodebuild -license accept` |
| Normal install / update / uninstall | No |

---

## Where do my fine-tuned model adapters live?

Adapter weights are saved by mlx-lm-lora to the path specified in your training
configuration (typically the `output_dir` key in the training YAML). The
installer does not manage, read, or write adapter files.

By default, mlx-lm-lora saves adapters to an `adapters/` directory relative to
where it was invoked. Inside the MLX Training Studio app, the working directory
is typically `~/Library/Application Support/MLX Training Studio/` or a
subdirectory you configured in the training job. Check the training output log
for the exact path printed after a completed run.

---

## Is there a way to donate or support the upstream project?

This installer has no relationship with the upstream project. If you find
MLX Training Studio useful, consider opening issues or contributing pull requests
at [stevenatkin/mlx-lm-gui](https://github.com/stevenatkin/mlx-lm-gui).

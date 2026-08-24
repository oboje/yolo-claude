---
title: Claude VM
description: Isolated Alpine container machine running Claude Code on apple/container.
date: 2026-08-24
tags: [apple-container, alpine, claude-code, sandbox]
status: draft
---

A disposable Alpine container machine that runs Claude Code fully isolated from the macOS filesystem.

## Why

I try a lot of half-baked ideas with Claude on my main machine. Every time, I had to stop
and think about how much I trusted a prompt, a repo, or some MCP server I just installed,
because Claude could reach my keys and my home directory. So I moved it into a VM that
cannot see my Mac at all.

That changes what a mistake costs. We all run `--dangerously-skip-permissions` anyway;
moving it into the VM is what makes that fine. A prompt injection or a bad `rm -rf` now
breaks a VM disk I rebuild in eleven seconds, instead of my laptop.

**Never experiment unprotected.**

## Alias

One-liner to get `claude3` (bash):

```bash
echo "alias claude3='\$HOME/vm/claude/up.sh'" >> ~/.bashrc && source ~/.bashrc
```

For zsh, swap the file:

```bash
echo "alias claude3='\$HOME/vm/claude/up.sh'" >> ~/.zshrc && source ~/.zshrc
```

## Quickstart

1. Download the latest signed `.pkg` from https://github.com/apple/container/releases and install it.
2. `container system start`
3. `./up.sh`

## Usage

- `./up.sh` — build the image, create the machine, and attach to a tmux session inside it.
- `./down.sh` — stop the machine.
- `./down.sh rm` — delete the machine and its persistent home.
- `./down.sh purge` — delete the machine and also remove the `claude-vm` image.

## Prerequisites

- macOS 26 on Apple silicon.
- apple/container 1.2.2, installed from the signed `.pkg` at https://github.com/apple/container/releases

## Isolation

The machine is created with `--home-mount none`, so the VM cannot see the macOS filesystem at all. Get code in with `git clone` from inside the VM.

## Image

Built from [Dockerfile](./Dockerfile):

```
claude-vm  <-  alpine:3.22            ~50 MB base, busybox init
├── claude-code 2.1.231               from the signed apk repo
├── libgcc, libstdc++, ripgrep        musl runtime deps
├── bash, git                         shell + the only way code gets in
├── tmux                              survives closing the terminal
└── USE_BUILTIN_RIPGREP=0             musl needs the system ripgrep
```

## First login

Run `claude` inside the VM. It prints a browser link: open that link on the Mac,
approve the login, and paste the code it gives you back into the VM.

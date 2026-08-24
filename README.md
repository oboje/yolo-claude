---
title: Claude VM
description: Isolated Alpine container machine running Claude Code on apple/container.
date: 2026-08-24
tags: [apple-container, alpine, claude-code, sandbox]
status: draft
---

A disposable Alpine container machine that runs Claude Code fully isolated from the macOS filesystem.

On [apple/container](https://github.com/apple/container), Apple's containerization runtime,
every container is a full VM rather than a shared kernel namespace: its own filesystem, no
access to your Mac. Experiment freely.

## Why

I try a lot of half-baked ideas with Claude on my main machine. Every time, I had to stop
and think about how much I trusted a prompt, a repo, or some MCP server I just installed,
because Claude could reach my keys and my home directory. So I moved it into a VM that
cannot see my Mac at all.

That changes what a mistake costs. We all run `--dangerously-skip-permissions` anyway;
moving it into the VM is what makes that fine. A prompt injection or a bad `rm -rf` now
breaks a VM disk I rebuild in eleven seconds, instead of my laptop.

**Never experiment unprotected.**

## Quickstart

1. Install [apple/container](https://github.com/apple/container/releases) from the latest
   signed `.pkg`, then start it:

   ```bash
   container system start
   ```

2. Clone it to the path the alias expects:

   ```bash
   git clone https://github.com/oboje/yolo-claude.git ~/vm/claude
   ```

3. Add the alias:

   ```bash
   echo "alias claude3='\$HOME/vm/claude/up.sh'" >> ~/.zshrc && source ~/.zshrc
   ```

4. Run it:

   ```bash
   claude3
   ```

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

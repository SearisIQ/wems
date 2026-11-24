<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="logo/kit/wems-horizontal-reversed.svg">
    <img src="logo/kit/wems-horizontal.svg" alt="WEMS" width="360">
  </picture>
</p>

# WEMS: What's Eating My Storage?

This morning your Mac had 25 GB free, and now it has 4. A disk analyzer will tell you which folders are big, but it won't tell you which ones grew today. WEMS will.

You save a snapshot of your disk usage, and later you compare it with another snapshot or with the disk as it is now. WEMS lists the folders that grew the most. If some of the lost space isn't in any folder, it says so. That's usually APFS snapshots left behind by a macOS update or Time Machine.

It's one bash script for macOS and only uses tools that come with the system.

## You might not need this

If all you want is to see which folders are taking up a lot of space, you don't need WEMS, or any other app for that matter. Your Mac already does that, and you've had it the whole time:

1. Open Finder and press ⌘⇧H to go to your home folder.
2. Press ⌘2 to switch to list view.
3. Press ⌘J, tick "Calculate all sizes", and click "Use as Defaults" so every folder gets it.
4. Click the Size column header to put the biggest folders on top.
5. Open the biggest one and look again. Keep going until you find the culprit.

That's it. Come back when your disk shrinks overnight and you have no idea why.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/SearisIQ/wems/main/install.sh | bash
```

The installer copies the script to `~/.local/bin/wems`. If that folder isn't on your PATH yet, it adds it to your `.zshrc` (or `.bash_profile`).

## Usage

Run `wems` with no arguments to get a menu. Everything in it also works as a command:

```bash
wems snap            # save a snapshot (takes a minute or two)
wems diff            # newest snapshot vs now
wems diff 3 1        # snapshot 3 vs snapshot 1, numbers from `wems list`
wems hogs            # sizes of the usual suspects
wems ai              # AI report, only if AI mode is on (see below)
wems auto 3          # snapshot every 3 hours; `wems auto off` stops it
wems rm old          # delete every snapshot but the newest
wems help
```

A snapshot records the size of every folder on the data volume, six levels deep, and takes up about 300 KB.

`hogs` checks the places that tend to fill up: macOS updates waiting to install, caches, Xcode, Docker, iPhone backups, and folders in `/Volumes` that look like external drives but are actually on your internal disk.

The menu also has a live view of free space, which shows how fast it's going down.

The easiest way to catch whatever is eating your space is to turn on auto snapshots. The background job keeps the newest 24. The next time space disappears, compare the two snapshots on either side of the drop.

### Reading a comparison

"Files changed" is how much the folders WEMS could read grew in total. "Not in folders" is the space you lost that doesn't show up in any of them. That's usually APFS snapshots, purgeable space, or folders macOS won't let your terminal read. To include protected folders like Mail, Messages and Safari, give your terminal app Full Disk Access in System Settings → Privacy & Security.

## AI mode (Optional)

AI mode takes your biggest folders and asks an AI coding tool you already have to say what each one is. WEMS draws the report itself, grouped by app:

```
  WEMS  Claude Code · privacy on · snapshot of Nov 24 14:42

  Adobe                                                         23.5 GB
  ↳ Delete via Creative Cloud app or uninstaller, not by hand
  Adobe Photoshop (Be…  /Volumes/SSK SD301/…/Contents  21.10.2026   6.2 GB
  CameraRaw             /Library/…/Adobe/CameraRaw     21.10.2026   2.1 GB

  Claude                                                        12.4 GB
  vm_bundles            ~/Library/…/Claude/vm_bundles  24.11.2026  11.2 GB
```

**AI mode is optional.** The first time you open WEMS, it asks whether you want it. If you don't trust AI, don't like it, or just don't want your folder names going to someone's server, say no. AI mode then disappears from the menu and the help, `wems ai` refuses to run, and WEMS doesn't even look for AI tools on your Mac. Everything else works the same.

If you change your mind, turn it on (or back off) under Settings → AI mode.

It works with Claude Code, Codex, opencode and Open Interpreter, whichever ones you have installed and are signed in to. A run takes 1 to 5 minutes and uses your plan's quota.

The AI can't change anything on your disk:

- Claude Code only gets the Read, Glob and Grep tools, and none at all with privacy on.
- Codex runs with `--sandbox read-only`, which macOS enforces.
- opencode has every permission denied except reading, and reading too when privacy is on.
- Open Interpreter has no read-only mode, so WEMS keeps privacy on and code execution off for it.

With privacy on, the AI only sees folder paths, sizes and dates. With privacy off it can look inside files, so a folder full of `.docx` files becomes "Word documents". Either way, the paths go to the AI provider.

The AI mode menu also lets you pick:

- Sort order: size, last used, or name.
- Minimum folder size: 20 MB, 50 MB, 100 MB, 200 MB, 500 MB (default), 1 GB, 2 GB, 5 GB or 10 GB.
- Scope: the whole disk, your home folder, or a folder you add yourself, like `~/Documents/xyz`. Your own folders are scanned fresh each time. The other two scopes can use the latest snapshot, which is instant.
- Whether to show the last-used date and a short note on what each folder is.

Your choices are remembered. "Last report" reopens the previous result with the current sort order, without asking the AI again. Reports are also saved as text in `~/.local/share/wems/reports/`.

A folder marked "(rest)" means the loose files in that folder, not counting subfolders that are listed separately, so nothing gets counted twice.

## Scan depth

Every scan measures the whole disk, so folder totals are always complete. The depth (default 6) sets how many folder levels get their own line, and how far down WEMS looks for single big files. To change it, open Settings → Scan depth, press Enter and type a number. Higher numbers show more detail but make scans slower. The choice is saved in `~/.local/share/wems/wems.conf`.

## Environment variables

| Variable | Default | |
|---|---|---|
| `WEMS_MIN_MB` | 50 | smallest change listed in a comparison |
| `WEMS_TOP` | 20 | rows in a comparison |
| `WEMS_DEPTH` | 6 | scan depth; overrides the one set in Settings |
| `WEMS_AUTO_KEEP` | 24 | auto snapshots kept |
| `WEMS_HOME` | `~/.local/share/wems` | where snapshots and reports go |
| `WEMS_AI_MODEL` | | model passed to the AI tool, e.g. `haiku` |
| `WEMS_AI_MAX` | 80 | most folders sent to the AI |

## Update and uninstall

```bash
wems update
```

```bash
wems uninstall
```

---

WEMS was written with help from AI models.

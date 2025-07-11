# Runix: Smart File Runner for Termux

Runix is a powerful, interactive shell script for Android Termux that lets you compile, run, preview, and manage code files (C, C++, Python, Java, JS, Bash, etc.) with a single command. It supports shortcuts, output previews, auto-update notifications, and on-demand dependency installation.

---

## 🚀 Features

- **One-click install & auto setup**
- **Compile and run:** C, C++, Python, Java, NodeJS, Bash (and more)
- **Output preview:** Choose when/how to view output files
- **Shortcuts:** Map custom commands or filenames to short aliases
- **Auto-update notification:** Always know when a new version is available
- **Safe compiler checks:** If you don’t have the right compiler/interpreter, Runix offers to install it for you
- **Easy configuration & reconfiguration**
- **Clean uninstall**

---

## 📦 Installation

Open Termux and run:

```bash
curl -s https://raw.githubusercontent.com/Peace-forever69/Runix/main/runix-installer.sh | bash
```

- This sets up everything in `$HOME/Runix` and creates a shortcut command: `run`
- On first use, you’ll be guided through initial setup.

---

## 🛠 Supported Languages & Tools (On-Demand)

- C (`clang`)
- C++ (`clang++`)
- Python (`python`)
- Java (`javac`, `java`)
- JavaScript (`node`)
- Bash (`bash`)

If you try to compile/run a file and the required tool isn’t installed, Runix will ask if you want to install it automatically.

---

## 💡 Usage

Type `run help` to see all commands.

### **Basic commands:**

| Command              | Description                         |
|----------------------|-------------------------------------|
| `run file.ext`       | Compile & run file                  |
| `run file.ext c`     | Only compile                        |
| `run file.ext r`     | Only run (skip compile)             |
| `run runall`         | Run all code files in your folder   |
| `run clean`          | Clear compiled binaries             |
| `run search`         | Search for files by name            |
| `run settings`       | Reconfigure Runix                   |
| `run info`           | Show current settings               |
| `run shortcut`       | Add shortcut for file/command       |
| `run uninstall`      | Remove Runix                        |
| `run update`         | Manually update Runix               |
| `run help`           | Show help message                   |

---

## 🔔 Update Notification

Whenever you run any Runix command, it checks for updates.  
If a new version is available on GitHub, you’ll see:

`
[Runix] Update available! Run 'run update' to get the latest version.
`

---

## ⚙️ Configuration

On first use (or via `run settings`), you’ll be asked to set:

- Your main folder path (script wont work outside it)
- Output preview mode (always/never/ask)
- Whether to save compiled binaries after running

You can reconfigure any time with `run settings`.

---

## 🧹 Uninstall

To completely remove Runix:

```bash
run uninstall
```

---

## 🙏 Credits

Developed by [Peace-forever69](https://github.com/Peace-forever69)

---
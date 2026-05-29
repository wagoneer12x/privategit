<div align="center">

<img src="https://raw.githubusercontent.com/vdutts7/squircle/refs/heads/main/webp/material-icons/git.webp" alt="logo" width="80" height="80" />

<h1>secure-git-template</h1>
<p><i><b>opinionated private repo bootstrap with one command setup</b></i></p>


<a href="https://github.com/vdutts7/homebrew-tap"><img src="./assets/badges/shelllock.badge.svg" alt="shelllock" height="34" /></a> &nbsp;
<a href="https://github.com/AGWA/git-crypt"><img src="./assets/badges/git-crypt.badge.svg" alt="git-crypt" height="34" /></a> &nbsp; 


</div>

<br/>

## Table Of Contents

- [About](#about)
- [Install](#install)
- [Usage](#usage)
- [Requirements](#requirements)
- [Contact](#contact)

___

## About

- **problem** - private repos drift into inconsistent local setup and weak guardrails
- **solution** - force one install path and one setup command with hooks + identity + encryption
- **summary** - clone, run command, store key, commit, push

___

## Install

```bash
brew tap vdutts7/tap && brew install shelllock git-crypt git-lfs && git lfs install && \
git clone <your-repo-url> && cd <your-repo-dir> && \
./.hooks/scripts/setup.sh --remote "<your-remote-url>" --name "<git-name>" --email "<git-email>" --pseudo-encrypt-commits --git-crypt --key-output "$HOME/Downloads/git-crypt-key" && \
open "$HOME/Downloads" && rm "$HOME/Downloads/git-crypt-key" && \
git add . && git commit -m "initial setup" && git push -u origin main
```

___

## Usage

```bash
.hooks/scripts/setup.sh --remote "<your-remote-url>" --name "<git-name>" --email "<git-email>" --pseudo-encrypt-commits --git-crypt --key-output "$HOME/Downloads/git-crypt-key"
```

| Arg | Purpose |
|---|---|
| `--remote` | set or replace `origin` |
| `--name` | set repo-local `user.name` in `.git/config` |
| `--email` | set repo-local `user.email` in `.git/config` |
| `--pseudo-encrypt-commits` | obfuscate commit messages as `..` and log originals to `.commits.jsonl` |
| `--git-crypt` | initialize `git-crypt` and activate `.gitattributes` encryption rule |
| `--key-output` | export git-crypt key file |

Examples:

```bash
# full setup
./.hooks/scripts/setup.sh --remote "git@github.com:owner/repo.git" --name "your-name" --email "your-email@example.com" --pseudo-encrypt-commits --git-crypt --key-output "$HOME/Downloads/git-crypt-key"

# first push
git add . && git commit -m "initial setup" && git push -u origin main
```

___

## Requirements

- `shelllock`
- `git-crypt`
- `git-lfs`

___

## Contact

<a href="https://vd7.io"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/v1773910810/readme-badges/readme-badge-vd7.png" alt="vd7.io" height="40" /></a> &nbsp; <a href="https://x.com/vdutts7"><img src="https://res.cloudinary.com/ddyc1es5v/image/upload/v1773910817/readme-badges/readme-badge-x.png" alt="/vdutts7" height="40" /></a>

[git]: https://img.shields.io/badge/Git-181717?style=for-the-badge&logo=github&logoColor=white
[github-url]: https://github.com/vdutts7/secure-git-template
[homebrew]: https://img.shields.io/badge/Homebrew-FBB040?style=for-the-badge&logo=homebrew&logoColor=black
[homebrew-url]: https://github.com/vdutts7/homebrew-tap

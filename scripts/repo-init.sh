#!/bin/bash

# Run with bash. Default prints the plan. --local initializes locally.
# --publish creates a NEW public GitHub repository and pushes this source.

main() {
    local owner='CodeCornTech'
    local mode='dry-run'
    local root repo description topic existing_top remote origin_url protocol
    local -a topic_args
    root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || return 1
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --owner) owner="${2:-}"; shift 2 || return 1 ;;
            --local) mode='local'; shift ;;
            --publish) mode='publish'; shift ;;
            --dry-run) mode='dry-run'; shift ;;
            --help)
                printf '%s\n' 'Usage: bash scripts/repo-init.sh [--owner CodeCornTech] [--dry-run|--local|--publish]'
                return 0 ;;
            *) printf 'Unknown argument: %s\n' "$1" >&2; return 1 ;;
        esac
    done
    if ! [[ "$owner" =~ ^[A-Za-z0-9][A-Za-z0-9-]*$ ]]; then
        printf '%s\n' 'Invalid GitHub owner.' >&2; return 1
    fi
    repo="$owner/intel-vtx-rescue"
    description='Enable Intel VT-x from Windows with Intel ITK — verified on DH61CR BIOS 0038.'
    topic_args=()
    for topic in intel vt-x virtualization bios firmware powershell windows windows-11 virtualbox intel-integrator-toolkit dh61cr legacy-hardware troubleshooting sysadmin remote-administration; do
        topic_args+=(--add-topic "$topic")
    done
    printf 'Source: %s\nRepository: %s\nMode: %s\nDescription: %s\n' "$root" "$repo" "$mode" "$description"
    if [ "$mode" = 'dry-run' ]; then
        printf '%s\n' 'Plan: initialize main, commit project files, create a new PUBLIC repository, push, configure topics, issues, discussions and squash merges.'
        printf '%s\n' 'No commands that modify Git or GitHub were executed. Use --local or --publish deliberately.'
        return 0
    fi
    command -v git >/dev/null || { printf '%s\n' 'git is required.' >&2; return 1; }
    cd "$root" || return 1
    for required in README.md README.it.md LICENSE scripts/Set-IntelVtx.ps1 tests/Test-Offline.ps1; do
        [ -f "$required" ] || { printf 'Missing: %s\n' "$required" >&2; return 1; }
    done
    existing_top="$(git rev-parse --show-toplevel 2>/dev/null)" || existing_top=''
    if [ -n "$existing_top" ] && [ "$existing_top" != "$root" ]; then
        printf '%s\n' 'Source is inside another Git repository. Extract into a separate folder.' >&2; return 1
    fi
    if [ -d .git ]; then
        if [ "$(git branch --show-current)" != 'main' ] || [ -n "$(git status --porcelain)" ]; then
            printf '%s\n' 'Existing repository must be clean and on main. No changes made.' >&2; return 1
        fi
    fi
    git var GIT_AUTHOR_IDENT >/dev/null || { printf '%s\n' 'Configure Git user.name and user.email before initialization.' >&2; return 1; }
    if [ "$mode" = 'publish' ]; then
        command -v gh >/dev/null || { printf '%s\n' 'GitHub CLI is required; authenticate with gh auth login.' >&2; return 1; }
        gh auth status --hostname github.com || return 1
        if gh repo view "$repo" >/dev/null 2>&1; then
            printf 'Repository already exists: %s. Refusing to overwrite or reuse it.\n' "$repo" >&2; return 1
        fi
        origin_url="$(git remote get-url origin 2>/dev/null)" || origin_url=''
        [ -z "$origin_url" ] || { printf '%s\n' 'Existing origin found. No remote changes made.' >&2; return 1; }
    fi
    if [ ! -d .git ]; then
        git init -b main || return 1
        # Explicit paths avoid accidentally publishing nearby host files.
        git add README.md README.it.md LICENSE CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md .gitignore .gitattributes .editorconfig .github docs examples scripts tests || return 1
        git diff --cached --check || return 1
        git commit -m 'feat: document verified Intel VT-x rescue with guarded PowerShell workflow' || return 1
    fi
    if [ "$mode" = 'local' ]; then
        printf '%s\n' 'Local repository initialized. Review it, then rerun with --publish when ready.'
        return 0
    fi
    gh repo create "$repo" --public --source=. --remote=origin --description "$description" --disable-wiki || return 1
    # Respect the GitHub CLI account's configured Git transport.
    protocol="$(gh config get git_protocol --host github.com)" || return 1
    if [ "$protocol" = 'https' ]; then
        gh auth setup-git --hostname github.com || return 1
    fi
    git push -u origin main || return 1
    gh repo edit "$repo" --default-branch main --enable-issues --enable-discussions \
        --enable-wiki=false --enable-projects=false --delete-branch-on-merge \
        --enable-squash-merge --enable-merge-commit=false --enable-rebase-merge=false \
        --squash-merge-commit-message pr-title-description \
        "${topic_args[@]}" || return 1
    printf 'Published: https://github.com/%s\n' "$repo"
    printf '%s\n' 'Wait for CI, then follow docs/launch.md for the first release and community post.'
}

main "$@"

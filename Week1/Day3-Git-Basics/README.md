# **Day3: Git Basics & Version Control Workflow**

## 🎯 **Objectives**

* Understand Git architecture and workflow
* Learn to initialize, track, commit, and push changes
* Use `.gitignore` for excluding files
* Explore Git logs, diffs, and commit history
* Build confidence with practical Git operations
* Keep handy interview notes for version control concepts

---

## 🧠 **Concept Notes (Interview / Training Reference)**

### 🔹 **What is Git?**

Git is a **distributed version control system (DVCS)** that tracks file changes, allowing multiple developers to collaborate efficiently.

### 🔹 **Core Git Areas**

| Area                     | Description                                                |
| ------------------------ | ---------------------------------------------------------- |
| **Workspace**            | Your working directory where files live                    |
| **Staging Area (Index)** | Temporary storage where changes are prepared before commit |
| **Local Repository**     | Your `.git` folder containing commit history               |
| **Remote Repository**    | GitHub / GitLab — shared central repo                      |

➡️ Workflow:
**Workspace → git add → Staging → git commit → Local Repo → git push → Remote**

---

### 🔹 **Common Git Commands Overview**

| Category             | Command                                              | Description                      |
| -------------------- | ---------------------------------------------------- | -------------------------------- |
| **Configuration**    | `git config --list`                                  | View current settings            |
|                      | `git config --global user.name "Name"`               | Set username                     |
|                      | `git config --global user.email "email@example.com"` | Set email                        |
| **Tracking Changes** | `git status`                                         | Show modified/untracked files    |
|                      | `git add <file>`                                     | Stage file                       |
|                      | `git commit -m "message"`                            | Save staged changes locally      |
|                      | `git push origin <branch>`                           | Push commits to remote           |
|                      | `git pull`                                           | Fetch + merge from remote        |
|                      | `git fetch`                                          | Download commits without merging |
| **Viewing History**  | `git log --oneline --graph --decorate --all`         | Compact, visual commit history   |
|                      | `git show <commit-id>`                               | Show commit details              |
| **Undoing**          | `git restore <file>`                                 | Discard unstaged changes         |
|                      | `git reset HEAD <file>`                              | Unstage file                     |
|                      | `git revert <commit-id>`                             | Undo commit (preserves history)  |
| **Cleanup**          | `git rm <file>`                                      | Remove file from repo            |
|                      | `.gitignore`                                         | File defining untracked patterns |

---

### 🔹 **Key Interview Topics**

| Concept                     | Explanation                                                                                                |
| --------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **git fetch vs git pull**   | `fetch` downloads new commits, `pull` = fetch + merge                                                      |
| **git merge vs git rebase** | Merge creates new commit combining histories; rebase rewrites commits onto target branch (cleaner history) |
| **Detached HEAD**           | State when you checkout a commit instead of a branch; changes not linked to any branch                     |
| **.gitignore**              | File that lists patterns Git should ignore (e.g., `*.log`, `/temp/`)                                       |
| **HEAD**                    | Pointer to current commit (tip of your checked-out branch)                                                 |
| **Three States**            | Modified → Staged → Committed                                                                              |
| **Branch Strategy**         | Main (`main/master`) + feature branches (e.g., `feature/week1`) for isolated work                          |

---

## ⚙️ **Environment Setup**

**📍 Where to Run:** Inside Ubuntu VM (repo cloned under `/home/vagrant/devops-local-e2e-practice`)

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week1/Day3-Git-Basics
cd Week1/Day3-Git-Basics
touch README.md
```

---

## 🧩 **Task 1: Initialize and Configure Git**

Check your configuration:

```bash
cd ~/devops-local-e2e-practice
git config --list
```

If name/email missing:

```bash
git config --global user.name "Sreekanth CloudDevOps"
git config --global user.email "your_email@example.com"
```

---

## 🧩 **Task 2: Create Files and Track Changes**

```bash
cd ~/devops-local-e2e-practice/Week1/Day3-Git-Basics

echo "Git is a distributed version control system." > notes.txt
echo "It tracks code changes and collaboration history." >> notes.txt
echo "Initial Git commands practice." > commands.txt
```

Check status:

```bash
cd ~/devops-local-e2e-practice
git status
```

Add and commit:

```bash
git add Week1/Day3-Git-Basics
git commit -m "Week1-Day3: Initial Git files created"
```

---

## 🧩 **Task 3: Modify and View Diffs**

Edit your file:

```bash
echo "Git has three main states: modified, staged, and committed." >> Week1/Day3-Git-Basics/notes.txt
```

Check changes:

```bash
git status
git diff Week1/Day3-Git-Basics/notes.txt
```

Stage and commit:

```bash
git add Week1/Day3-Git-Basics/notes.txt
git commit -m "Added explanation of Git states"
```

---

## 🧩 **Task 4: Create and Use `.gitignore`**

Inside `Week1/Day3-Git-Basics`:

```bash
echo "*.log" > .gitignore
echo "temp/" >> .gitignore
mkdir temp
touch temp/debug.log
```

Git will now ignore `.log` files and `/temp/` directories:

```bash
cd ~/devops-local-e2e-practice
git status
```

---

## 🧩 **Task 5: View Commit History**

```bash
git log --oneline --graph --decorate --all
```

✅ Example Output:

```
* b1f7ac1 (HEAD -> feature/Week1) Added explanation of Git states
* 3f92a11 Week1-Day3: Initial Git files created
* 75de004 Week1-Day2: Permissions and Processes
* 1a5cb43 Week1-Day1: Linux Essentials
```

---

## 🧩 **Task 6: Practice Undo & Restore Commands**

```bash
# Remove file from repo (and disk)
git rm <file>

# Unstage changes
git reset HEAD <file>

# Restore file to last committed state
git restore <file>

# Compare previous commit to latest
git diff HEAD~1 HEAD
```

---

## 🧩 **Task 7: Push to GitHub**

```bash
cd ~/devops-local-e2e-practice
git push origin feature/Week1
```

✅ Verify in GitHub:
👉 [https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day3-Git-Basics](https://github.com/sreekanth-clouddevops/devops-local-e2e-practice/tree/feature/Week1/Week1/Day3-Git-Basics)

---

## 🧩 **Summary Table**

| Command       | Description              |
| ------------- | ------------------------ |
| `git init`    | Initialize Git repo      |
| `git status`  | Check file states        |
| `git add`     | Stage files              |
| `git commit`  | Save local snapshot      |
| `git log`     | View commit history      |
| `git diff`    | See unstaged changes     |
| `git push`    | Send commits to remote   |
| `git fetch`   | Download without merge   |
| `git pull`    | Fetch + merge            |
| `git restore` | Undo working dir changes |

---

## 🧾 **Quick Git Interview Q&A**

| Question                                               | Quick Answer                                                                                  |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------- |
| **Q: What is difference between Git and GitHub?**      | Git is version control; GitHub is a cloud hosting service for Git repos.                      |
| **Q: What does “HEAD” mean?**                          | HEAD points to the current commit you’re on.                                                  |
| **Q: What is detached HEAD?**                          | When you checkout a commit directly instead of a branch; commits won’t be linked to a branch. |
| **Q: How do you resolve a merge conflict?**            | Edit conflicting file → remove conflict markers → `git add` → `git commit`.                   |
| **Q: How to undo last commit but keep changes?**       | `git reset --soft HEAD~1`                                                                     |
| **Q: How to delete a branch locally and remotely?**    | Local: `git branch -d <branch>`; Remote: `git push origin --delete <branch>`                  |
| **Q: What’s the difference between merge and rebase?** | Merge combines histories; rebase moves commits onto new base creating a linear history.       |

---

## 🪜 **Git Workflow Recap**

```
1️⃣  Edit files (Workspace)
2️⃣  git add (Staging area)
3️⃣  git commit (Local repo)
4️⃣  git push (Remote repo)
5️⃣  git pull (Sync from remote)
```

---

## 🧩 **Outcome**

* Practiced Git end-to-end flow
* Understood local and remote commit cycles
* Used `.gitignore` effectively
* Learned difference between fetch/pull and merge/rebase
* Pushed all work to `feature/Week1` branch successfully

---

## 🪜 **Git Commands Cheat Sheet (Handy Summary)**

```
git status
git add <file>
git commit -m "message"
git log --oneline --graph --decorate
git diff
git push origin <branch>
git fetch
git pull
git branch
git checkout -b <branch>
git merge <branch>
git rebase <branch>
git revert <commit>
git reset --soft HEAD~1
```

---

**Next:**
➡️ **Day4: Git Branching, Merging & Conflict Resolution (Real-world Dev Workflow)**
We’ll create branches, simulate collaboration, and handle merges & conflicts step-by-step.

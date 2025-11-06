# **Day4: Git Branching, Merging & Conflict Resolution**

## 🎯 Objectives

* Learn branching and merging concepts
* Understand real-world feature branch workflow
* Practice resolving merge conflicts
* Capture key interview notes on Git branching strategies

---

## 🧠 Concept Notes (Interview / Training Reference)

### 🔹 Branching in Git

* **Branch** = independent line of development
* Each branch is a pointer to a commit in history
* Default branch = `main` (or `master`)
* Developers work in **feature branches** to isolate changes

### 🔹 Merging

* Combines two branches’ histories into one
* **Fast-forward merge:** target branch is ahead only linearly
* **Three-way merge:** both branches have diverged; Git creates a merge commit

### 🔹 Conflicts

* Occur when same lines are modified in both branches
* Git marks conflicts using:

  ```
  <<<<<<< HEAD
  your changes
  =======
  incoming changes
  >>>>>>> branch-name
  ```
* Resolve by editing, saving, `git add`, and `git commit`

### 🔹 Common Commands

| Command                             | Description                     |
| ----------------------------------- | ------------------------------- |
| `git branch`                        | List branches                   |
| `git checkout -b <branch>`          | Create & switch branch          |
| `git merge <branch>`                | Merge branch into current       |
| `git branch -d <branch>`            | Delete local branch             |
| `git push origin --delete <branch>` | Delete remote branch            |
| `git stash / git stash pop`         | Temporarily save & restore work |

---

## ⚙️ Environment Setup

**📍 Where to Run:** Inside Ubuntu VM in repo path `/home/vagrant/devops-local-e2e-practice`

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week1/Day4-Git-Branching-Merging
cd Week1/Day4-Git-Branching-Merging
touch README.md
```

---

## 🧩 Task 1: Create and Switch Branches

```bash
cd ~/devops-local-e2e-practice
git checkout -b feature/day4-demo
git branch
```

---

## 🧩 Task 2: Add File on New Branch

```bash
echo "This line is from feature/day4-demo branch" > Week1/Day4-Git-Branching-Merging/demo.txt
git add Week1/Day4-Git-Branching-Merging
git commit -m "Day4: Added demo.txt from feature/day4-demo branch"
git push origin feature/day4-demo
```

---

## 🧩 Task 3: Create Conflict on Another Branch

```bash
git checkout feature/Week1
echo "This line is from feature/Week1 branch" > Week1/Day4-Git-Branching-Merging/demo.txt
git add Week1/Day4-Git-Branching-Merging/demo.txt
git commit -m "Day4: Added demo.txt from Week1 branch"
git merge feature/day4-demo
```

Conflict appears:

```
CONFLICT (content): Merge conflict in demo.txt
Automatic merge failed; fix conflicts and commit the result.
```

---

## 🧩 Task 4: Resolve Conflict

Open file:

```
<<<<<<< HEAD
This line is from feature/Week1 branch
=======
This line is from feature/day4-demo branch
>>>>>>> feature/day4-demo
```

Keep your final version:

```
This file shows merge conflict resolved between two branches.
```

Then:

```bash
git add Week1/Day4-Git-Branching-Merging/demo.txt
git commit -m "Resolved merge conflict between Week1 and day4-demo"
```

---

## 🧩 Task 5: Push Changes and Clean Up

```bash
git push origin feature/Week1
git branch -d feature/day4-demo
git push origin --delete feature/day4-demo
```

---

## 🧩 Task 6: View Graph History

```bash
git log --oneline --graph --decorate --all
```

✅ Example:

```
* 3b9d5d2 (HEAD -> feature/Week1) Resolved merge conflict
|\  
| * 20ad99a (feature/day4-demo) Added demo.txt from feature/day4-demo branch
* | 4b7a118 Added demo.txt from Week1 branch
|/  
```

---

## 🧾 Quick Notes for Interview / Training

| Concept                       | Description                                            |
| ----------------------------- | ------------------------------------------------------ |
| **Feature Branching**         | Each feature/task developed in its own branch          |
| **Pull Request (PR)**         | Review mechanism before merging to main                |
| **Fast-Forward Merge**        | No divergence → moves branch pointer ahead             |
| **Three-Way Merge**           | Diverged branches merged via new merge commit          |
| **Conflict Resolution Steps** | Edit → `git add` → `git commit`                        |
| **Rebase**                    | Re-apply commits onto a new base; keeps linear history |
| **Cherry-Pick**               | Apply a specific commit from another branch            |
| **Stash**                     | Save temporary work not ready to commit                |
| **Merge Strategy**            | Prefer PR merges over direct pushes in team workflows  |

---

## 🧩 Outcome

* Understood branching, merging, and conflicts
* Practiced real-world Git workflow
* Learned conflict resolution using CLI
* Cleaned up feature branches post-merge
* Documented key interview notes for quick recall

---

**Next:**
➡️ **Day5: Shell Scripting & Mini-Project – System Health Report**
You’ll write automation scripts integrating Day 1–4 knowledge (variables, loops, Git tracking).

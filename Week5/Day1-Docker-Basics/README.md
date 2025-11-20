# Week5 – Day1  
## Docker Basics + Multi-Stage Builds

---

## 🎯 Objective

In Day1 you will:

- Learn Docker fundamentals  
- Build a simple Python Flask application  
- Create a **multi-stage Dockerfile** (production ready)  
- Run the container inside your Vagrant VM  
- Access app from Windows browser  
- Prepare for Kubernetes deployment (later days)

---

## 📂 Project Structure

```
Week5/
 └── Day1-Docker-Basics/
       ├── app/
       │    ├── app.py
       │    └── requirements.txt
       ├── Dockerfile
       ├── .dockerignore
       └── README.md
```

---

## 🚀 Step 1 — Create Folder Structure

Run inside Vagrant VM:

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week5/Day1-Docker-Basics/app
cd Week5/Day1-Docker-Basics
```

---

## 🚀 Step 2 — Create Flask App

Create the file:

```bash
cd app
cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Docker + Week5-Day1!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF
```

Requirements:

```bash
echo "flask==2.3.2" > requirements.txt
```

---

## 🚀 Step 3 — Multi-Stage Dockerfile

Create Dockerfile in **Week5/Day1-Docker-Basics**:

```bash
cat <<EOF > Dockerfile
# --------------------------
# Stage 1: Builder
# --------------------------
FROM python:3.10-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --user -r requirements.txt

# --------------------------
# Stage 2: Production Image
# --------------------------
FROM python:3.10-slim
WORKDIR /app
COPY app /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
EXPOSE 5000
CMD ["python3", "app.py"]
EOF
```

---

## 🚀 Step 4 — Build & Run Docker Container

Build image:

```bash
docker build -t week5-app:latest .
```

Run container:

```bash
docker run -d -p 5000:5000 week5-app:latest
```

Test in Windows browser:

```
http://192.168.56.60:5000
```

Expected output:

```
Hello from Docker + Week5-Day1!
```

---

## 🚀 Step 5 — Create .dockerignore

```bash
cat <<EOF > .dockerignore
__pycache__/
*.pyc
*.pyo
*.pyd
env/
venv/
.git/
EOF
```

---

## 🚀 Step 6 — Git Commit (Feature Branch Week5)

```bash
git add Week5/Day1-Docker-Basics
git commit -m "Week5-Day1 Docker basics + multi-stage build"
git push origin feature/Week5
```

---

## ✅ Summary

By completing Week5-Day1, you learned:

✔ Dockerfile basics  
✔ Multi-stage builds  
✔ Running containers  
✔ Exposing Flask app  
✔ Testing via browser  
✔ Preparing for Kubernetes  

**Next:**  
👉 Week5-Day2 — Docker Compose (Flask + Redis)



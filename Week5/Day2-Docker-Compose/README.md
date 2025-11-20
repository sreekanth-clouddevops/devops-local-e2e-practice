# Week5 – Day2  
## Docker Compose: Multi-Container Application (Flask + Redis)

---

## 🎯 Objective

In Day2 you will:

- Learn Docker Compose  
- Run multi-container applications  
- Create Flask + Redis stack  
- Use networks, volumes, environment variables  
- Run, stop, debug containers  
- Prepare for Kubernetes migration later this week

---

## 📂 Project Structure

```
Week5/
 └── Day2-Docker-Compose/
       ├── app/
       │    ├── app.py
       │    └── requirements.txt
       ├── Dockerfile
       ├── docker-compose.yml
       └── README.md
```

---

## 🚀 Step 1 — Create Folders

```bash
cd ~/devops-local-e2e-practice
mkdir -p Week5/Day2-Docker-Compose/app
cd Week5/Day2-Docker-Compose
```

---

## 🚀 Step 2 — Flask App Using Redis

`app/app.py`:

```python
from flask import Flask
import redis
import os

app = Flask(__name__)

redis_host = os.getenv("REDIS_HOST", "redis")
redis_port = 6379
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route("/")
def home():
    count = r.incr("hits")
    return f"Hello from Docker Compose! Site visited {count} times."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

`app/requirements.txt`:

```
flask==2.3.2
redis==4.5.5
```

---

## 🚀 Step 3 — Dockerfile

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app /app
EXPOSE 5000
CMD ["python3", "app.py"]
```

---

## 🚀 Step 4 — docker-compose.yml

```yaml
version: "3.9"

services:
  web:
    build: .
    container_name: flask-app
    ports:
      - "5001:5000"
    environment:
      REDIS_HOST: redis
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    container_name: redis-db
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  redis-data:
```

---

## 🚀 Step 5 — Start App

```bash
docker compose up -d
```

---

## 🚀 Step 6 — Test in Browser

```
http://192.168.56.60:5001
```

Expected output:

```
Hello from Docker Compose! Site visited X times.
```

---

## 🚀 Step 7 — View Logs

```bash
docker compose logs -f
```

---

## 🚀 Step 8 — Stop and Cleanup

```bash
docker compose down
```

Delete volume if needed:

```bash
docker volume rm day2-docker-compose_redis-data
```

---

## 🚀 Step 9 — Git Commit

```bash
git add Week5/Day2-Docker-Compose
git commit -m "Week5-Day2 Docker Compose multi-container app"
git push origin feature/Week5
```

---

## ✅ Summary

By finishing Day2, you learned:

✔ Multi-container Docker setup  
✔ Web + Redis communication  
✔ Compose networks and volumes  
✔ App debugging & logs  
✔ Preparing for Kubernetes migration on Day3–Day5  

---


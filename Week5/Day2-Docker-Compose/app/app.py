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

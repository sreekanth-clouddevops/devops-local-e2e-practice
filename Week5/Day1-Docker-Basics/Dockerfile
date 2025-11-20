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
ENV PATH=/root/.local/bin:/home/vagrant/.local/bin:/home/vagrant/.local/bin:/home/vagrant/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
EXPOSE 5000
CMD ["python3", "app.py"]

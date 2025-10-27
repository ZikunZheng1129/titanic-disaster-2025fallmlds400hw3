FROM python:3.11-slim
WORKDIR /app

# install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy code
COPY src ./src

# default run
CMD ["python", "src/app/main.py"]

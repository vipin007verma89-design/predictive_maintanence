FROM python:3.12-slim

WORKDIR /app

# Install system dependencies required for XGBoost
RUN apt-get update && apt-get install -y \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

EXPOSE 7860

CMD ["streamlit", "run", "deploy.py", "--server.port=7860", "--server.address=0.0.0.0"]

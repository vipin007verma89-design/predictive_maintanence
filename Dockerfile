# Stage 1: Build and dependency caching stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies and libgomp system requirement
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and copy the verified configuration requirements
RUN python -m pip install --no-cache-dir --upgrade pip
COPY requirements.txt .

# Install packages into a local space to isolate the runner stage cleanly
RUN pip install --no-cache-dir --user -r requirements.txt


# Stage 2: Clean, optimized production runtime
FROM python:3.12-slim AS runner

WORKDIR /app

# CRITICAL COMPATIBILITY FIX: Install the precise multi-threading OpenMP library 
# required to clear the XGBoost OSError seen in your previous execution block.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed python dependencies over from the builder sequence
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app/requirements.txt ./requirements.txt

# Ensure system architecture registers the path locations flawlessly
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

# Expect structural mounting for app definitions and models matching your directory map
COPY ./saved_models /app/saved_models
COPY ./app /app/app

# Expose port 8000 for standard web serving architectures
EXPOSE 8000

# Fire up the lightweight API application engine
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

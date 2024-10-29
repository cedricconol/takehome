# Use Python 3.10.9-slim image
FROM python:3.10.9-slim

# Set environment variables for pip to not cache and to use UTF-8 encoding
ENV PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PIP_NO_CACHE_DIR=1

# Set working directory
WORKDIR /usr/src/app

# Install system dependencies for dbt
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install dbt CLI and any other Python dependencies
RUN pip install --upgrade pip \
    && pip install dbt-core dbt-snowflake

# Default command to run dbt CLI
CMD ["dbt", "--version"]

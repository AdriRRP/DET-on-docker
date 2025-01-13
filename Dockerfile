# Base image with Python 2.7
FROM python:2.7-slim

# Set working directory
WORKDIR /opt/DET

# Install system dependencies for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpcap-dev \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone DET repository
RUN git clone https://github.com/sensepost/DET.git /opt/DET

# Install Python dependencies for DET
RUN pip install --no-cache-dir -r /opt/DET/requirements.txt \
    && pip install --no-cache-dir scapy==2.4.5

# Set entrypoint to allow passing arguments to DET
ENTRYPOINT ["python", "det.py"]

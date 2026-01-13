FROM python:3.13-slim

# Create a system user
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup decoderuser

    
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Poetry and configure no virtualenv
RUN pip install poetry && \
    poetry config virtualenvs.create false

# Copy only dependency files for caching
COPY pyproject.toml poetry.lock* /app/

# Install dependencies
RUN poetry install --no-root

# Copy rest of the app
COPY . /app/

# Fix permissions so decoderuser can read/write
RUN chown -R decoderuser:appgroup /app

# Switch to non-root user
USER decoderuser

# Run the application
CMD ["python", "-u", "decoder_bindings/main.py"]

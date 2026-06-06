# Use Python 3.9 slim image as base
# WHAT: Starts with a lightweight Python image
# WHY: We need Python to run our Flask app
# SLIM: Smaller size than full Python image
FROM python:3.9-slim

# Set working directory inside container
# WHAT: Creates and sets /app as current directory
# WHY: All subsequent commands run from here
# CREATES: Directory if it doesn't exist
WORKDIR /app

# Copy requirements file first (for better caching)
# WHAT: Copies requirements.txt from host to container
# WHY: Need to know what packages to install
# CACHING: If requirements don't change, Docker reuses this layer
COPY requirements.txt .

# Install Python dependencies
# WHAT: Installs Flask and other packages
# WHY: Our app needs Flask to run
# --no-cache-dir: Don't store pip cache (smaller image)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
# WHAT: Copies all app files to container
# WHY: Need our Python code to run
# AFTER dependencies: So code changes don't trigger dependency reinstall
COPY app.py .
COPY templates/ templates/
COPY static/ static/

# Expose port 5000
# WHAT: Documents that app uses port 5000
# WHY: Tells users which port to map
# NOTE: This is just documentation, doesn't actually open the port
EXPOSE 5000

# Set environment variables
# WHAT: Configures Flask settings
# WHY: Flask uses these for configuration
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Health check (optional but recommended)
# WHAT: Checks if app is responding
# WHY: Docker can restart if unhealthy
# INTERVAL: Check every 30 seconds
# TIMEOUT: Wait 3 seconds for response
HEALTHCHECK --interval=30s --timeout=3s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Command to run when container starts
# WHAT: Starts the Flask application
# WHY: This is what the container does
# FORMAT: JSON array format (recommended)
CMD ["python", "app.py"]

# Made with Bob

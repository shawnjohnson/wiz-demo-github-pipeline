# 1. Base Image
# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM docker.io/library/python:3.9

# 2. Working Directory
# Set the working directory inside the container.
WORKDIR /app

# 3. Dependencies
# Copy requirements.txt first to leverage Docker cache.
COPY requirements.txt .

# Install dependencies.
# --no-cache-dir keeps the image small by not storing the cache.
RUN pip install --no-cache-dir -r requirements.txt

# 4. Source Code
# Copy the rest of your application code to the container.
COPY . .

# 5. Run
# Specify the command to run your application.
CMD ["python", "app.py"]

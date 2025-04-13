FROM python:3.13-alpine
COPY . /app
WORKDIR /app
RUN pip install flask flask_cors requests
CMD ["python", "app.py"]
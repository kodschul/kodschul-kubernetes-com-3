# Basisimage: Python 3.14 auf Alpine Linux (klein, aktuell unterstützt)
FROM python:3.14-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Version und Farbe dieses Images; für v2: APP_VERSION=v2, APP_COLOR=lightgreen
ENV APP_VERSION=v1 \
    APP_COLOR=lightblue \
    PORT=80

EXPOSE 80

CMD ["python", "app.py"]

FROM python:3.9-alpine

RUN pip install flask requests

WORKDIR /app

COPY backend.py .


CMD [ "python", "backend.py" ]

EXPOSE 80

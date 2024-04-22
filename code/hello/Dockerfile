FROM python:3.9-alpine

# -- install packages
RUN pip install flask requests

WORKDIR /app
COPY frontend.py .

CMD [ "python", "frontend.py" ]

EXPOSE 80
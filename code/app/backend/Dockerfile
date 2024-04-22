FROM python:3.10-alpine

RUN pip install flask requests

WORKDIR /backend

COPY . . 


CMD [ "python", "backend.py" ]

EXPOSE 80

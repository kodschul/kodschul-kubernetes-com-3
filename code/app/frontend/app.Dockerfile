FROM python:3.9-alpine

RUN pip install flask requests

WORKDIR /app

ARG version=1.0
RUN echo "Version: $version" > version.info


COPY . .


CMD [ "python", "frontend.py" ]

EXPOSE 80

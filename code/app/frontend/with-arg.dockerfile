FROM python:3.10-alpine

ARG version=1.0.0
ARG module=frontend

RUN pip install flask requests

WORKDIR /$module

RUN echo "Version: $version" > version.info


COPY . . 

CMD  python $module.py

EXPOSE 80

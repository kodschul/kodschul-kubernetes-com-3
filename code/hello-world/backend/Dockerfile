FROM python:3.10-alpine

# Install flask library
RUN pip install flask requests

WORKDIR /backend
COPY . .


ENTRYPOINT [ "python", "backend.py" ]

EXPOSE 80
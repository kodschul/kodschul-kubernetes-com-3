FROM python:3.10-alpine

# Install flask library
RUN pip install flask requests

WORKDIR /frontend
COPY . .

ENTRYPOINT [ "python", "frontend.py" ]

EXPOSE 80
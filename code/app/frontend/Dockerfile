FROM python:3.10-alpine


RUN pip install flask requests

WORKDIR /frontend

COPY . . 

CMD ["python", "frontend.py"]

EXPOSE 80

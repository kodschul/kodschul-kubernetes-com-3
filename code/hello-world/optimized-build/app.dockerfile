FROM busybox as base 
WORKDIR /app

# ------
FROM python:3.10-alpine as build
WORKDIR /src 
COPY . . 

# build
RUN python build.py

# ------
FROM base 
WORKDIR /app
COPY --from=build /src/output.txt /app/
CMD [ "cat", "output.txt" ]

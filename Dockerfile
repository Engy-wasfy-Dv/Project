FROM alpine

WORKDIR /app

COPY file.txt .

CMD cat file.txt 

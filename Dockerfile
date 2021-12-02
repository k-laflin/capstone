FROM python:3.7.3-stretch

SHELL ["/bin/bash", "-c"]

WORKDIR /app

COPY . /app/

RUN make setup 
 
RUN source /app/.capstone/bin/activate

RUN make install

EXPOSE 80

CMD ["python", "app.py"]

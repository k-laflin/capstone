FROM openjdk:11-jdk

SHELL ["/bin/bash", "-c"]

WORKDIR /app

COPY app/ /app/

#RUN make install

EXPOSE 8080

CMD ["mvn", "jetty:run"]
# CMD ["python", "app.py"]

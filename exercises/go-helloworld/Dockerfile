# set the base image. Since we're running 
# a Python application a Python base image is used
FROM golang:alpine
# set a key-value label for the Docker image
LABEL maintainer="Hasan"

#  defines the working directory within the container
WORKDIR /go/src/app

# copy files from the host to the container filesystem. 
# For example, all the files in the current directory
# to the  `/app` directory in the container
ADD . .


# run commands within the container. 
#to build the application, use go build -o helloworld command, 
#where -o helloworld will create the binary of the application with the name helloworld
RUN go mod init helloworld
RUN go build -o helloworld


EXPOSE 6111
# provide a command to run on container start. 
# For example, start the `app.py` application.
CMD [ "./helloworld" ]

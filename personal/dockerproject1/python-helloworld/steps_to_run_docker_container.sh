#!/bin/bash

#Step1
#Create docker file in the root directory of project as done

#Step2
# build an image using the Dockerfile from the current directory
docker build -t python-helloworld .

# build an image using the Dockerfile from the `lesson1/python-app` directory
docker build -t python-helloworld lesson1/python-app

#Step3
#Run our new docker image within docker container by :
# running the `python-helloworld` image, in detached mode and expose it on port `5111` 
docker run -d -p 5111:5000 python-helloworld   #  portinOS:portindockerAsInterfacedWithApp

#Step 4
#open web browser to check app http://127.0.0.1:5111

#Step5
# to list running containers
docker container ls   
#Result
#CONTAINER ID   IMAGE               COMMAND            CREATED         STATUS         PORTS                                       NAMES
#669670bf3e27   python-helloworld   "python3 app.py"   3 minutes ago   Up 3 minutes   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   stoic_mayer

#Step 6
#To retrieve the Docker container logs use :
#docker logs {{ CONTAINER_ID }} command. 
docker logs 669670bf3e27

#Step7
#Stop docker container
#docker stop {{ CONTAINER_ID }}
docker stop 669670bf3e27


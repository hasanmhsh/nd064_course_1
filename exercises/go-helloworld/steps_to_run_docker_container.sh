#!/bin/bash

#Step1
#Create docker file in the root directory of project as done

#Step2
# build an image using the Dockerfile from the current directory
docker build -t go-helloworld .

# build an image using the Dockerfile from the `lesson1/go-app` directory
# docker build -t go-helloworld lesson1/go-app

#Step3
#Run our new docker image within docker container by :
# running the `go-helloworld` image, in detached mode and expose it on port `5111` 
docker run -d -p 6111:6111 go-helloworld   #  portinOS:portindockerAsInterfacedWithApp

#Step 4
#open web browser to check app http://127.0.0.1:6111

#Step5
#List local docker images
docker images
# to list running containers
docker container ls   
#Result
#CONTAINER ID   IMAGE               COMMAND            CREATED         STATUS         PORTS                                       NAMES
#669670bf3e27   go-helloworld   "go3 app.py"   3 minutes ago   Up 3 minutes   0.0.0.0:5000->5000/tcp, :::5000->5000/tcp   stoic_mayer

#To delete docker image and all of its tags
# docker rmi -f go-helloworld
docker image rm -f [image-ID]

#Step 6
#To retrieve the Docker container logs use :
#docker logs {{ CONTAINER_ID }} command. 
docker logs 669670bf3e27

#Step7
#Stop docker container
#docker stop {{ CONTAINER_ID }}
docker stop 669670bf3e27


#Step8
#Destribute docker image to public image registry such as: (like public github repositories)
#docker hub , docker container registry and harbor
#or private image registry such as: (like private github repositories you have control to set who do what on which)

#Step8 - A
#container ID is not human readable so you have to tag the image with version and name of image to have it as container ID
# tag an image
# SOURCE_IMAGE[:TAG]  - required and the tag is optional; define the name of an image on the current machine 
# TARGET_IMAGE[:TAG] -  required and the tag is optional; define the repository, name, and version of an image
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
# tag the `go-helloworld` image, to be pushed 
# in the `pixelpotato` repository, with the `go-helloworld` image name
# and version `v1.0.0`
docker tag go-helloworld hasanmhsh/go-helloworld:v5.12.3
#first go-helloworld is the name of the source image on the local machine
#pixelpotato is the name of the repository in the docker hub
#second go-helloworld is the name of the image in the docker hub
#v1.0.0 is the version of the image

#Step8 - B
#before pushing image you must login to your account using web brouser on docker hub and create empty repository with name go-helloworld
#then login within terminal by using this command
docker login
# push an image to a registry 
# NAME[:TAG] - required and the tag is optional; name, set the image name to be pushed to the registry
docker push NAME[:TAG]

# push the `go-helloworld` application in version v1.0.0 
# to the `pixelpotato` repository in DockerHub
docker push hasanmhsh/go-helloworld:v5.12.3

#by default docker will OCI or open container initiative compliant image
#OCI aims to standardize image formats making sure that this image can be executed on 
#any OCI-Compliant run time such as Docker or CRIO.
#While Docker is the most widely used mechanism to generate images , it has security issue which is the 
#opened socket of docker daemon inside docker container to execute the image so there is another tools to build images which is more
#secure and easier and have no exposed docker sockets
# *Buildpacks : without dockerfile , and automaticaly identify dependencies following with the best practices
# *Podman
# *Buildah
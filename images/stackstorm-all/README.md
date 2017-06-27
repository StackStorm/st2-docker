# StackStorm Docker image all-in-one (stackstorm-all)

## Intro:

- This repo contains what's needed to build a Docker image for [stackstorm](https://stackstorm.com/). Has been tested with version  2.1.2.
- This is an All-in-One type of image because all components and services required for StackStorm are included in the same image. This differs from a the classical microservices model of having one container per service. 
- This is less intended for a producation usage (or for smalle environements only)  but rather more intended for testing / prototyping / CI jobs etc ...
- All various modules are installed and available, with the exception of the ChatOps part (Roadmap).
- Thanks to Baptiste Assmann who helped.

## How to use this pack ?:

- You first need to git clone this repo.
```
git clone https://github.com/StackStorm/st2-docker.git
```

### Build:
 - First change the ```ST2_PASSWORD``` variable in the Dockerfile. (You may skip this and stay with default password if you using this image for testing purposes only, for production usage though, you may need to change it).
 - Use the docker ```build``` command to create the docker image and give it a name (in this example we are naming the image stackstorm/stackstorm-all).
 	- The simplest is to go to the directory that contains the Dockerfile and type in the following command (replace ```.``` by the path to Dockerfile if you are not in that directory): 
```
docker build -t stackstorm/stackstorm-all .
```
 - This will start building the image, it may take a while the first time as it will pull the ubuntu image (approximatly 10 mn). Once it is done, you can check by typing:
```
docker images
```

### Run:

- The Run is about instanciating the docker image we just built, in order to get a container.
- Use the docker ```run``` command to create the docker image. 
	- Use ```-d``` to indicate detach mode. This will allow to process the build of the image in background, as soon as you type in this command, you'll get the container ID (even if the build will take roughly 10 mn to get done).
	- You can add ```--rm=true``` which is helpful for de-provisionning, it will automatically remove the container when you kill it.

```
docker run -d --rm=true --name=my_st2 stackstorm/stackstorm-all
```

- If you want to check the logs, during the build and after (meaning the output of the logs file when you'll be using the container), type in:
```
docker logs my_st2 -f
```

- You can check that the container is created by typing and look for ```my_st2``` or the name you would have used during the instanciation:
```
docker ps
```

### Test:

- Use the docker ```exec``` command to enter the docker container and type any command.
	- Use ```-it``` to be in interactive mode

```
docker exec -it my_st2 st2 --version
docker exec -it my_st2 st2 pack list
docker exec -it my_st2 st2 action list
```

- You can also use the following command to enter in the container and type directly all the st2 commands you wish:
```
docker exec -it my_st2 bash
```

- For testing purposes you may want to upload data to the container at the moment of its creation. This is very useful if you are working on writing a pack, or components of a pack, and you want to test it.

	- Use ```-v``` to add a data volume to the container. In the below example your local ```/opt/stackstorm/packs/my_pack/``` directory will be mounted to the directory ```/opt/stackstorm/packs/my_pack``` in the container

```
docker run -d -v /opt/stackstorm/packs/my_pack/:/opt/stackstorm/packs/my_pack --rm=true --name=my_st2 stackstorm/stackstorm-all
```

You can check that data have been properly mounted by typing the following command:

```
docker exec -it my_st2 ls -l my_pack
```

Please note, that for st2, mounting data to the container at the right even at the right location, is the first step, but that is not enough to use that code. You'll need to go through few steps before being able to use it.
- Setting up the virtual environements: ```st2 run packs.setup_virtualenv packs=my_pack```
- Register the pack ```st2ctl restart```
- Then check if the pack and its actions have been registered: ```st2 pack list``` & ```st2 action list -p my_pack```

- The UI is available at https://<container_IP>, user 'st2admin' and password the one set in Dockerfile.


## Road-map:
- Add the support of ChatOps settings during the container instanciation.

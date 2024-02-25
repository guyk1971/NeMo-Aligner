# Environment scripts for NeMo-Aligner

## Docker 

### Building the docker image
there are 2 stages in the build up process:
1. run the Dockerfile that is releaseed with the project.  
from the project root dir:
```bash
docker buildx build -f Dockerfile -t nemo_aligner .
``` 
this will generate an image `nemo_aligner:latest`

you can skip this step if you use a pre-built docker image, in which case you'll have to set the `BASE_IMAGE` variable in the following script accordingly.


2. Add your specific additions on top of the generated image.  
from the project root dir:  
```bash
./env_scripts/docker_build_run_cl.sh
# or on local machine
./env_scripts/docker_build_run_lws.sh
```
it expects to find the `BASE_IMAGE` on the local docker registry. so make sure to set `BASE_IMAGE` before running the script. 

this will add you as a username and will generate an image `nemo_aligner_gkoren:latest`
from here you can install some stuff from within the container and then commit to the image (if it makes sense - e.g. on local machine)  
remember to save it as `nemo_aligner_gkoren:dev`   




### Running the docker image
this scenario is relevant only when running on local machine (where its reasonable to assume that `nemo_aligner_gkoren` already exists)  
from the root folder:
```bash
./env_scripts/docker_run_lws.sh
```


# python3 -m venv .venv
# source ./venv/bin/activate
# pip install -r requirements.txt
# python dns-perf.py


## run in a docker container:
# docker build -t <tag-name> .
# docker images
# docker container run --name <container-name> <image-id>
# docker ps -a

## using the latest image from gitlab registry:

# Any change to the repo will trigger a pipeline to create and store the docker image in container registry
# see .gitlab-ci.yml

# to pull the latest image from container registry and run:
# docker login registry.gitlab.com
# username: <your-gitlab-username>
# password: <your-gitlab-access-token>
# docker run registry.gitlab.com/<path-to-image>



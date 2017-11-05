# swarm-agents

Weave Cloud agents for Docker Swarm instrumentation

Prerequisites:

* Minimum Docker version 17.09.0-ce or 17.06.2-ee-3
* Docker Swarm cluster with one manager and a worker node

Install the agents by running the following command on a Swarm manager:

```bash
docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    weaveworks/swarm-agents install <WEAVE-TOKEN>
```


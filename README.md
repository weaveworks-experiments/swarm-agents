# Weave Cloud agents for Docker EE & CE

Prerequisites:

* Docker 17.09.0-ce or 17.06.2-ee-3
* Docker Swarm cluster with one manager and a worker node

Install:

```bash
docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    weaveworks/swarm-agents install <WEAVE-TOKEN>
```

The Weave stack is composed of the following services:

* Weave Scope
* Prometheus (remote write to Weave Cloud)
* Node Exporter
* cAdvisor

Running the installer on a Docker engine without swarm mode will deploy only Weave Scope.

For an in depth look at Docker Swarm instrumentation with Prometheus and Weave Cloud see this [blog post](https://www.weave.works/blog/swarmprom-prometheus-monitoring-for-docker-swarm).

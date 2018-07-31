## Stack Storm Helm Chart

This chart is just a prototype!!!  Not for production use, yet!

### Overview
Install Stack Storm into Kubernetes cluster via Helm.  The chart leverages subcharts for mongodb, postgresql, rabbitmq, and redis.

### Usage

- Make sure your kubectl context is setup before proceeding, you should be able to run commands like `helm list`.  If not see https://docs.helm.sh/using_helm/ or #docker in stackstorm-community.slack.com

0. `git clone git@github.com/stackstorm/st2-docker`
0. `cd st2-docker`
0. `git checkout helm_example_jbrownsm`
0. `cd runtime/kubernetes-1ppc/helm`
0. `helm install --name stackstorm-test1 --namespace stackstorm-test1 .`
0. `kubectl --namespace stackstorm-test1 get pods`
0. `sudo kubectl --namespace stackstorm-test1 port-forward $(kubectl --namespace stackstorm-test1 get pods -l app=st2web -o name | head -n1) 443:443` (Note nothing else can be on 443, at some point we'll put Nginx in front of this and not make it be port 443...)
0. Goto https://localhost

### Advanced Configuration

- Adding an external-dns hostname
- Exposing Stack Storm via an internal, cloud specific, Load Balancer
- Exposing Stack Storm to the scary public internet
- Adding secrets to your Stack Storm installation

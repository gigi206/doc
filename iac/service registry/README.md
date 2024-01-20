# Service Discovery
## Consul
* [Consul](https://www.consul.io) ([doc](https://developer.hashicorp.com/consul))
  * [Consul-template](https://github.com/hashicorp/consul-template)

## Consul alternatives
* [Articles1](https://technologyconversations.com/2015/09/08/service-discovery-zookeeper-vs-etcd-vs-consul/)

One of possible alternatives is to use these tools:
* *confd*: can be used to automate the process of updating configuration files. For example, you could use confd to update the configuration file for a web application based on the latest version of the application code. This would ensure that the application is always running with the latest version of the configuration. (equivalent to [consul-template](https://github.com/hashicorp/consul-template))
  * [Github](https://github.com/kelseyhightower/confd)

* *Registrator*: can be used to automate the process of registering services with a configuration database. For example, you could use Registrator to automatically register all of the Docker containers running on your infrastructure with etcd. This would allow you to easily manage all of your services from a single place.
  * [Github](https://github.com/gliderlabs/registrator)

* *etcd*: can be used to store configuration data in a central location. This can make it easier to manage and update configuration data, and it can also improve consistency across your infrastructure.
  * [Github](https://github.com/etcd-io/etcd)

* *SkyDNS*: can be used to provide automatic DNS resolution for services registered in etcd. This can make it easier to access services by name, and it can also improve the scalability of your infrastructure.
  * [Github](https://github.com/skynetservices/skydns)

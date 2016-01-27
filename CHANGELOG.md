* Add docker-registry PR 961 as a patch file. [Internal] [Aleksis]

# 2015-01-18

* Updated to the new resin-base. [Internal] [Page]

# 2015-12-01

* Disabled registry redirects so docker clients >= 1.7 can pull. [External] [Page]
* Switched to a purely etcd backed confd. [Internal] [Page]

# 2015-10-19

* Set up caching for the docker registry to improve performance. [External] [Page]
* Fixed an rsyslogd infinite restart loop when there is no logentries token. [Internal] [Page]

# 2015-08-18

* Always restart the service if it exits. [Aleksis]
* Try to populate the docker cache before building. [Page]
* Switched to using a tagged version of resin-base. [Page]

# 2015-07-29

* Switched logentries to TLS. [Petros]

# 2015-06-29

* Changed to support newer resin-base with confd 0.10.0 [Page]

# 2015-06-10

* Use authentication for pushes [petrosagg]

# 2015-09-21

* Fix production config [Petros]

# 2015-09-19

* Switched to a systemd base image [Petros]
* Updated to registry v0.9.1 [Petros]

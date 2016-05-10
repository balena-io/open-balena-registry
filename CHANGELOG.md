# 2016-05-10

* Updated to nginx 1.10.0 [Internal] [Page]
* Updated resin-base to v2 [Internal] [Page]

# 2016-04-21

* Updated registry to v2.4.0 [Internal] [Page]

# 2016-03-29

* Disabled S3 v4 auth as it sometimes returned a 500 error. [Internal] [Petros]

# 2016-03-18

* Updated registry to v2.3.1 [Internal] [Page]

# 2016-03-08

* Updated to registry 2.3.0 [Internal] [Page]

# 2016-02-19

* Switched to docker registry v2 [External] [Page]

# 2015-01-27

* Add docker-registry PR 961 as a patch file. [Internal] [Aleksis]
* Added `proxy_set_header Authorization ""` and `proxy_read_timeout 900` [Internal] [Petros]

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

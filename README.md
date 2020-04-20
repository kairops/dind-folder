# DEPRECATED

Please visit https://github.com/ayudadigital/dind-folder

# DinD folder

Copy any folder of a docker.sock powered container to the host in a temporary directory under /tmp

The objective is avoid the error that occurs when you are trying to mount a directory as a volume in a container running within docker-in-docker strategy (mounting /var/run/docker.sock in the container).

As a result:
- A new directory TMPDIR was created on the docker host in a new random temporary directory under /tmp
- The local DIR was copied within TMPDIR
- You will get the target path of the host in STDOUT as "TMPDIR/DIR"

...so you can mount the "TMPDIR/DIR" in a new DinD container within your container and find the right contents, because the script copied the directory on the host.

By the moment is only a PoC, but what can you do with this? Maybe you can execute tests using docker-compose into GitLab CI runner.

How to do that?

Using an example, you are executing the script in a DinD container (i.e. redpandaci/ubuntu-dind) to execute the test of this project https://github.com/segodev/basic-mongo:

```console
root@288ac1f3f429:~/dind-folder# git clone https://github.com/segodev/basic-mongo /opt/basic-mongo
Cloning into '/opt/basic-mongo'...
remote: Enumerating objects: 237, done.
remote: Counting objects: 100% (237/237), done.
remote: Compressing objects: 100% (127/127), done.
remote: Total 237 (delta 119), reused 199 (delta 86), pack-reused 0
Receiving objects: 100% (237/237), 70.03 KiB | 0 bytes/s, done.
Resolving deltas: 100% (119/119), done.
Checking connectivity... done.
root@288ac1f3f429:~/dind-folder# ./dind-folder.sh /opt/basic-mongo 
/tmp/tmp.FjEbi39w9E
```

The next step is run a new container with this directory mounted as volume in the same target directory of the container. In this example we would execute the tests of the project:

```console
root@288ac1f3f429:~/dind-folder# docker run -ti -v /tmp/tmp.FjEbi39w9E:/tmp/tmp.FjEbi39w9E -v /var/run/docker.sock:/var/run/docker.sock redpandaci/ubuntu-dind bash
/usr/local/bin/wrapdocker: line 4: dmsetup: command not found
mount: permission denied
Could not mount /sys/kernel/security.
AppArmor detection and --privileged mode might break.
mkdir: cannot create directory '/sys/fs/cgroup/name=systemd': Read-only file system
mount: mount point /sys/fs/cgroup/name=systemd is not a directory
ln: failed to create symbolic link '/sys/fs/cgroup/systemd/name=systemd': Read-only file system
can't create unix socket /var/run/docker.sock: device or resource busy
root@b079b6ef4646:/# cd /tmp/tmp.FjEbi39w9E/basic-mongo/
root@b079b6ef4646:/tmp/tmp.FjEbi39w9E/basic-mongo# ls -l
total 24
-rw-r--r--  1 root root 11357 Nov 16 08:02 LICENSE
-rw-r--r--  1 root root  1315 Nov 16 08:02 README.md
drwxr-xr-x  4 root root   128 Nov 16 08:02 bin
-rw-r--r--  1 root root   382 Nov 16 08:02 docker-compose.yml
-rw-r--r--  1 root root   562 Nov 16 08:02 sonar-project.properties
drwxr-xr-x 13 root root   416 Nov 16 08:02 src
root@b079b6ef4646:/tmp/tmp.FjEbi39w9E/basic-mongo# bin/test.sh 
Basic Mongo Test
Creating network "basic-mongo_default" with the default driver
Creating basic-mongo_redis_1  ... done
Creating basic-mongo_mongo_1  ... done
Creating basic-mongo_rabbit_1 ... done
Creating basic-mongo_basic-mongo_1 ... done
Waiting for up!...
MongoDB shell version v4.0.4
connecting to: mongodb://127.0.0.1:27017/app
Implicit session: session { "id" : UUID("06964dc4-5ec3-4879-84b9-d5f9ac73b60b") }
MongoDB server version: 4.0.4
{ "ok" : 1 }
MongoDB shell version v4.0.4
connecting to: mongodb://127.0.0.1:27017/app
Implicit session: session { "id" : UUID("bc13526a-4ccb-415c-b6bc-420af4a9f85f") }
MongoDB server version: 4.0.4
WriteResult({ "nInserted" : 1 })
[ .................] / fetchMetadata: sil

[...]

```

Note you have the directory "basic-mongo" within /tmp/tmp.FjEbi39w9E

I will add some other scripts to make this work easyest and less tricky. And I will make a test using GiaLab CI runner :)

# Docker Execution Speed

We are going to use Docker, but there is a "discussion" as too how efficient this will be... and as I have no clue when the correct answer will be - it is time to develop a test.

## Python Prime Numbers

This is the test - check the number of prime numbers.

And this is the code

```bash
#!/bin/bash
python -m timeit -n 10 -s "from pyprimes import prime_count" "prime_count(1500000)"
```

In order to run this we need

  - python3
  - a package called pyprimes

## Docker Image

Using the official Python:3 Docker image (called Python:3). We can auto add modules by copying a requirements file into a specific direcory (info on the Docker python:3 web page at [https://hub.docker.com/_/python/](https://hub.docker.com/_/python/) in case you think I am making this up.

**Dockerfile** 

```text
FROM python:3

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
add run.sh /usr/local/bin/run.sh
run chmod +x /usr/local/bin/run.sh

cmd ["/bin/bash","/usr/local/bin/run.sh"]
```

**run.sh**

```bash
#!/bin/bash
python -m timeit -n 10 -s "from pyprimes import prime_count" "prime_count(1500000)"
```
**requirments.txt**

```text
pyprimes
```

#Building Container

Straight forward Container build command

```bash
docker build -t py3_prime:1.0 ./py_prime
```

The output looks like

```text
Sending build context to Docker daemon  4.096kB
Step 1/7 : FROM python:3
 ---> a5b7afcfdcc8
Step 2/7 : WORKDIR /usr/src/app
Removing intermediate container ef3af0706d52
 ---> f0640f92db31
Step 3/7 : COPY requirements.txt ./
 ---> 60fa2c98eb9c
Step 4/7 : RUN pip install --no-cache-dir -r requirements.txt
 ---> Running in edb0f6715b98
Collecting pyprimes (from -r requirements.txt (line 1))
  Downloading https://files.pythonhosted.org/packages/2c/56/7fdfee6a5912e6aa62e94ce3b17a20826e336f7fe9c62d30683221a1e68a/pyprimes-0.1.tar.gz
Installing collected packages: pyprimes
  Running setup.py install for pyprimes: started
    Running setup.py install for pyprimes: finished with status 'done'
Successfully installed pyprimes-0.1
Removing intermediate container edb0f6715b98
 ---> 74e9611089bc
Step 5/7 : add run.sh /usr/local/bin/run.sh
 ---> 6c08eeb1832e
Step 6/7 : run chmod +x /usr/local/bin/run.sh
 ---> Running in 7f380b0d2312
Removing intermediate container 7f380b0d2312
 ---> e444105f221f
Step 7/7 : cmd ["/bin/bash","/usr/local/bin/run.sh"]
 ---> Running in 27bc3f67fc1a
Removing intermediate container 27bc3f67fc1a
 ---> 85e34c23c430
Successfully built 85e34c23c430
Successfully tagged py_prime:1.0
```

And that's it

# Test it on Baremetal

Again a normal run command, we have the script to auto-execute so no need to shell into the container

```bash
docker run -t py_prime:1.0
```
And I get the result

```text
10 loops, best of 3: 293 msec per loop
```

### Bare Metal Parallel 5

To be a little more difficult I than run 5 parallel tasks

```bash
for a in 1 2 3 4 5 
do
   nohup ./run.sh&
done
```

The average time with 5 parallel proceses running was **10 loops, best of 3: 838 msec per loop**. 

### Container Parallel 5

To be a little more difficult I than run 5 parallel tasks

```bash
for a in 1 2 3 4 5 
do
   nohup docker run -t py_prime:1.0&
done
```

The average time with 5 parallel proceses running was **110 loops, best of 3: 713 msec per loop**. 

I did not expect that to be quicker.


# Export the Container

I could repeat these steps on the virtual Machine, instead I will export and Import the container.

#Virtual Machine

I build a new VirtualMachine

  - Ubuntu Serer 16.04.03
  - BARE Install
  
I then used this script to add directly from Docker, and not from the Ubuntu Repos

```bash
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get install apt-transport-https -y
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
```

I then added the Group Docker to my username

    moduser -aG docker tim
    
Logged out - and then carried on.
  

## Export

Using the Save option

```
docker save py_prime > py_prime.tar
```

## Import

Using the Load option

Note: This I had to sudo to make to work.

```bash
docker load -i <path to image tar file>
```

# VM Container Tests

I did the same as on the baremetal machine

1 Thread - same time as the Baremetal
5 Threads - Half the speed of the bare-metal solution.
 

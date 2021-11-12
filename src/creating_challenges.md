# Creating challenges
**NOTE: This documentation is still a work-in-progress!**

This article covers the relevant knowledge on how to create a terminal-based challenge. It is
expected that the reader has some familiarity with Linux, Docker and Kubernetes. These skills will
be needed to effectively build, run, and troubleshoot any issues you may have during this process.

## Building a container
All challenge environments utilize at least one container running in Kubernetes. Because this
article assumes that the reader wants to create a terminal-based challenge (rather than a web-based
one), you will need to familiarize yourself with the penimage. The penimage is effectively a
preconfigured Docker image of which all of our terminal-based challenges derive from. It utilizes
an Ubuntu 20.04 LTS base. The reason it is recommended to use this is that it preinstalls an OpenSSH 
server with a start script that will inject the public key of the Termproxy microservice.

### Example
The following is an example of a simple container which adds some Python scripts.
```dockerfile
FROM ghcr.io/acasi-ctf/ctf/penimage:latest

COPY challenges/ciphers/challenges/caesar-cipher/code/Caesar-cipher.py /home/player
COPY challenges/ciphers/challenges/comprehensive-challenge/code/Mixed-Challenge-1.py /home/player
COPY challenges/ciphers/challenges/letter-to-number/code/Letter-to-Number.py /home/player
COPY challenges/ciphers/challenges/morse-code/code/Morse_code.py /home/player
COPY challenges/ciphers/challenges/reverse-cipher/code/Reverse.py /home/player
```

As you may notice, the user that is used in the container is **player**, and their home directory is
located at `/home/player`.

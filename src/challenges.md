# Introduction to Challenges
Challenge sets and challenges are the basis of the CTF platform. Challenge sets are groups of
similar challenges, and challenges represent an individual problem or task to be performed by the
user.

## Challenge environments
A challenge environment is defined as the backend representation of a single instance of a challenge
that a user has created. Environments use containers running on Kubernetes to provide various
services for the user. One such instance might be that a user wants to learn more about a Linux
environment and commands. In this case, the challenge would provide an SSH server that the Termproxy
component connects to and would show this in the user interface as a terminal. Alternatively, it is
also possible for a challenge environment to expose a web server in a similar way, and this may be
used for SQL injection, XSS attacks, etc.

## How do I create a challenge?
See the [creating challenges](creating_challenges.md) page for more information on this topic.

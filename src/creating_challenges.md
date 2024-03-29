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

## Challenge directory structure
To create a challenge set and children challenges, you must have a directory for that dedicated
challenge set. The directory structure might look something like below. Each file is annotated with
a brief comment describing briefly what it is.

```
challenges/kali/challenge-set.json                           # Challenge set definition (JSON)
challenges/kali/challenges/strings/template.yaml             # Kubernetes CRD (YAML)
challenges/kali/challenges/strings/kubernetes.json           # Kubernetes provisioner (JSON)
challenges/kali/challenges/strings/challenge.json            # Challenge definition (JSON)
challenges/kali/challenges/strings/docs/StringsDocument.md   # Documentation (Markdown)
challenges/kali/challenges/strings/src/lock.cpp              # Source code for challenge (C++)
challenges/kali/challenges/binwalk/template.yaml             # Kubernetes CRD (YAML)
challenges/kali/challenges/binwalk/kubernetes.json           # Kubernetes provisioner (JSON)
challenges/kali/challenges/binwalk/challenge.json            # Challenge definition (JSON)
challenges/kali/challenges/binwalk/docs/BinwalkDocument.md   # Documentation (Markdown)
```

## Challenge set definition
A challenge set definition contains unique identifiers and human-readable descriptor fields. It also
links to each challenge by the name of the directory.

### Fields
| Name        | Type            | Description                                                                                                                               |
|-------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| id          | UUIDv4          | Unique identifier for this challenge set. This MUST be unique amongst all other challenge sets and challenges.                            |
| slug        | string          | Unique slug name for this challenge set. This MUST be unique amongst all other challenge sets.                                            |
| name        | string          | Descriptive name that is displayed in the user interface.                                                                                 |
| description | string          | Description of this challenge set displayed in the user interface.                                                                        |
| version     | string          | Version of this challenge.                                                                                                                |
| challenges  | array of string | Array of strings that reference each challenge directory to be included in this challenge set. Use lowercases and dashes for these names. |

### Example
```json
{
  "id": "4040a75a-037c-44c0-b1e2-bdcc6ceaddb0",
  "slug": "kali",
  "name": "Kali",
  "description": "Challenge set that focuses on Kali Linux",
  "version": "0.1.0",
  "challenges": [
    "strings",
    "binwalk"
  ]
}
```

## Challenge definition
A challenge definition contains unique identifiers, human-readable descriptor fields, and relevant
information required by the platform to build and start the environment.

### Fields
| Name          | Type            | Description                                                                                                                                                |
|---------------|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| id            | UUIDv4          | Unique identifier for this challenge. This MUST be unique amongst all other challenge sets and challenges.                                                 |
| slug          | string          | Unique slug name for this challenge. This MUST be unique amongst all other challenge.                                                                      |
| name          | string          | Descriptive name that is displayed in the user interface.                                                                                                  |
| description   | string          | Description of this challenge set displayed in the user interface.                                                                                         |
| provisioner   | object          | Object which contains field type, which can be either none or kubernetes. If kubernetes, kubernetes.json will be read as part of the provisioning process. |
| documentation | array of object | Array of objects which contain name and path fields, name is descriptive name for user interface and path is the path relative to the challenge.json file. |

### Example
```json
{
  "id": "0c73d010-b360-4116-ba6f-92dad43c3e57",
  "slug": "strings",
  "name": "strings",
  "description": "This is a challenge that demonstrates strings tool",
  "provisioner": {
    "type": "kubernetes"
  },
  "documentation": [
    {
      "name": "StringsDocument",
      "path": "docs/StringsDocument.md"
    }
  ]
}
```

## Kubernetes provisioner
A challenge which utilizes Kubernetes as a provisioning backend (currently the only one supported),
will require a kubernetes.json file in the same directory as challenge.json.

### Fields
| Name               | Type        | Description                                                                                                                                                |
|--------------------|-------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| templatePath       | UUIDv4      | Relative path to a YAML file containing the EnvironmentTemplate CRD for this challenge.                                                                    |
| templateCRDVersion | string enum | Version of the template CRD. This currently only has one value, which is v1alpha1. This maps directly to the versions of the CRD in Kubernetes.            |

### Example
```json
{
  "templatePath": "template.yaml",
  "templateCRDVersion": "v1alpha1"
}
```

## Kubernetes CRD
A challenge which utilizes Kubernetes as a provisioning backend will require this environment
template kind of resource. It combines the specs for one or more pods, and zero or more services and
ingresses.

### Example
```yaml
apiVersion: ctf.acasi.info/v1alpha1
kind: EnvTemplate
metadata:
  name: kali-strings
spec:
  pods:
    - metadata:
        name: penimage
        labels:
          app: penimage
      spec:
        containers:
          - name: penimage
            image: ghcr.io/acasi-ctf/challenges/kali/strings:latest
  services:
    - metadata:
        name: penimage-termproxy
      spec:
        selector:
          app: penimage
        ports:
          - port: 22
            ctfExpose: Termproxy
```

## Building the challenge set
To distribute our challenges, we build a ZIP file that contains all the JSON files that are listed
above to simplify the process. There is a tool that is written in Go to build these ZIP files, as
well as do some basic validation on the JSON to catch some of the most common schema validation
errors.

To utilize this tool, you must have Go installed (tested with Go v1.16 and above). This section
assumes that you are using macOS or Linux, it has not been tested on Windows.

All of these commands are run from the root of our repository, if your challenges are stored
elsewhere.

```
# List the challenges directory to show it exists.
☁  ctf [main] ls -la challenges
drwxr-xr-x - dschrute 25 May 19:09 ciphers
drwxr-xr-x - dschrute  9 Nov 19:40 games
drwxr-xr-x - dschrute  9 Nov 19:40 internal
drwxr-xr-x - dschrute 19 Nov 15:55 pentesting
drwxr-xr-x - dschrute 16 Nov 17:56 schemas
drwxr-xr-x - dschrute 25 May 19:09 web-based

# Alias `chl` to run the chl main file with `go run`.
☁  ctf [main] alias chl=go\ run\ cmd/chl/main.go

# Build the challenge, first positional argument for the build subcommand is the directory path,
#  the second is the output ZIP path.
☁  ctf [main] chl build challenges/pentesting pentesting.zip
Validated challenge set file
Validated 'strings' challenge file
Validated 'binwalk' challenge file
Validated 'hash-identifier' challenge file
Validated 'hashcat' challenge file

# Demonstrate the new ZIP file output.
☁  ctf [main] ls -la pentesting.zip
.rwxr-xr-x 18k dschrute 19 Nov 16:50 pentesting.zip
```

## Uploading the challenge set
This section requires that you are an administrator for the platform instance you are uploading to.
When visiting the web UI, you will see the following option in the sidebar if you have the correct
role as mentioned.

![Sidebar showing the "Upload Challenge Set" option](images/admin_upload_cs_sidebar.png)

Click this option, and you will find yourself on a very basic page which has two buttons. One is to
choose a file, and the other is to upload. Click "choose file", then browse and select the challenge
set ZIP you would like to upload to create or update. Afterwards, click the "upload" button.

![Screenshot of the "Upload Challenge Set" page](images/admin_upload_cs_page.png)

After clicking the upload button, if the operation was successful, you will see an alert like the
following.

![Screenshot showing successful upload](images/admin_upload_cs_success.png)

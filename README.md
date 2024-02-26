<!-- ABOUT  -->
## About 

This is a collection of scripts that I have written for various purposes, some just for learning scripting, some are used by me when I code. I always try to include scripts both for bash and powershell. Check out [this repository](https://github.com/kapiaszczyk/python-scripts) for scripts written in Python.

<!-- USAGE -->
## Usage

### [build_run_image.sh](https://github.com/kapiaszczyk/scripts/blob/main/docker/build_run_image.sh)

```bash
$0 [-h] <-s source directory> <-n image name> [-p port]
```

Builds a Java project with Maven, builds a Docker image and then runs it.

### [iterate_and_delete.sh](https://github.com/kapiaszczyk/scripts/blob/main/util/iterate_and_delete.sh)

```bash
$0 [-h] <-d directory> [-m secondary directory]
```

While iterating through a directory, mark files for deletion or moving to a secondary directory (if specified).

<!-- LICENSE -->
## License
Distributed under the MIT License. See `LICENSE.txt` for more information.

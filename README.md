# Running Ceylon applications

The following images/tags are available:

 - `1.2.1-jre7`, `1.2.1`, `latest` ([ceylon/Dockerfile](https://github.com/ceylon-docker/ceylon/blob/1.2.1-jre7/Dockerfile))
 - `1.2.0-jre7`, `1.2.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/ceylon/blob/1.2.0-jre7/Dockerfile))
 - `1.1.0-jre7`, `1.1.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/ceylon/blob/1.1.0-jre7/Dockerfile))
 - `1.0.0-jre7`, `1.0.0` ([ceylon/Dockerfile](https://github.com/ceylon-docker/ceylon/blob/1.0.0-jre7/Dockerfile))

### Demo

A one-liner that shows how you could execute single `ceylon` commands:

    docker run -ti --rm ceylon/ceylon:1.2.0 ceylon src,compile,run com.example.helloworld

You can combine this with the `-v` option to execute the command on some local files, for example:

    docker run -ti --rm -v `pwd`:/app ceylon/ceylon ceylon compile

would compile all the modules found in the local `./source` folder.

### Trying things out

When you just want to quickly try out a couple of `ceylon` commands you simply do:

    docker run -ti --rm ceylon/ceylon

which will give you a shell prompt to experiment with. But remember that when you exit the image anything you did will be gone! If you want things a little more permanent you can use the following option.

### Developing

If you want to be able to work on some code without having to install Ceylon (yet) but you need things to be a bit more permanent you can add a volume to hold all the source files and compiled modules. In the following example the local folder will be added to the image:

    docker run -ti --rm -v `pwd`:/app ceylon/ceylon

Any sources you write, any code you compile will be stored in your local folder even when you exit the image so it can be made available again when you next run the command.

### Creating applications

The image can also be used to easily create application images. When you create a `Dockerfile` with just the following line:

    FROM ceylon/ceylon

all the local files in the same folder will automatically be added to the image. Then you just need to add a single `CMD` to your `Dockerfile` to run the code and you're done. This all together makes it easy to wrap everything into a simple application bundle, imagine the following folder structure for example:

    ./Dockerfile
    ./source/my/app/module.ceylon
    ./source/my/app/run.ceylon

And the following contents of the `Dockerfile`:

    FROM ceylon/ceylon
    CMD ceylon run --compile my.app

NB: You can of course pre-compile the sources and add the resulting `modules` folder to the image instead of the sources and just immediately run the code without compiling.

NB2: The image gives you an unprivileged user by default to better protect the host. If you want to give that user `sudo` rights you could add the following lines to your `Dockerfile`:

    USER root
    RUN echo 'ceylon ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/ceylon
    USER ceylon


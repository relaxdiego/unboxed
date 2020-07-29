# Unboxed Charm

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam efficitur eros sed arcu
commodo posuere. Sed nec ornare enim, ut pellentesque tellus. Nunc lacinia, dolor vel
aliquet tincidunt, mi risus finibus mauris, vel pellentesque ante diam in leo. Sed et
faucibus eros, vel sagittis purus. Praesent vel malesuada nulla. Quisque tincidunt mauris
vitae finibus fermentum. Phasellus sodales magna quis feugiat lacinia. Nullam placerat
nunc quis eros vehicula feugiat. In nunc odio, euismod nec felis nec, egestas aliquam leo.
Cras convallis lorem quis augue vestibulum, eu blandit metus vulputate.

## Quick Start

Build, and deploy the charm:

```
make build && juju deploy ./unboxed.charm
```

Optionally set the Juju log level to DEBUG:

```
juju model-config logging-config="<root>=WARNING;unit=DEBUG"
```


# Developer's Guide

## Prepare Your Python Environment

> This section is OPTIONAL but RECOMMENDED since it guarantees safety of your main
> Python environment or any other virtual environments you have lying around. That
> said, you're free to skip this part and just go with `python3 -m venv ./.venv`.
> Just make sure to activate that virtualenv before you go to the next section!

1. Install pyenv so that you can test with different versions of Python

```
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
```

2. Append the following to your ~/.bashrc then log out and log back in

```
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
```

3. Install development packages

```
sudo apt install build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git
```

4. Install Python 3.5, 3.6 and 3.7

```
pyenv install 3.5.9
pyenv install 3.6.10
pyenv install 3.7.7
```

NOTE: For more available versions, run `pyenv install --list`

5. Create a virtualenv for this project

```
export charm_name=unboxed
pyenv virtualenv 3.7.7 ${charm_name}-3.7.7
pyenv local ${charm_name}-3.7.7 3.7.7 3.6.10 3.5.9
```

Your newly created virtualenv should now be activated if your prompt changed
to the following:

```
(unboxed-3.7.7) ubuntu@dev...
```

or, should you happen to be using [my dotfiles](https://dotfiles.relaxdiego.com),
if it changed tothe following

```
... via 🐍 v3.7.7 (unboxed-3.7.7)
```

Notice the things in parentheses that corresponds to the virtualenv you created
in the previous step. This is thanks to the coordination of pyenv-virtualenv and
a newly createdd `.python-version` file in the rootdir of this project.

If you `cd ..` or `cd` anywhere else outside your project directory, the virtualenv
will automatically be deactivated. When you `cd` back into the project dir, the
virtualenv will automatically be activated.


## Install The Dependencies

Install all development and runtime dependencies.

WARNING: Make sure you are using a virtualenv before running this command. Since it
         uses pip-sync to install dependencies, it will remove any package that is not
         listed in either `requirements-dev.in` or `setup.py`. If you followed the steps
         in Prepare Your Development Environment above, then you're good.

```
make dependencies
```


## Adding A Development Dependency

1. Add it to `requirements-dev.in` and then run make:

```
echo "foo" >> requirements-dev.in
make dependencies
```

This will create `requirements-dev.txt` and then install all dependencies


2. Commit `requirements-dev.in` and `requirements-dev.txt`. Both
   files should now be updated and the `foo` package installed in your
   local machine. Make sure to commit both files to the repo to let your
   teammates know of the new dependency.

```
git add requirements-dev.*
git commit -m "Add foo to requirements-dev.txt"
git push origin
```


## Adding A Runtime Dependency

1. Add it to `runtime_requirements` list in setup.py and then run:

```
make dependencies
```

This will create `requirements.txt` and then install all dependencies


2. Commit `setup.py` and `requirements.txt`. Both
   files should now be updated and the `foo` package installed in your
   local machine. Make sure to commit both files to the repo to let your
   teammates know of the new dependency.

```
git add requirements.txt
git add setup.py
git commit -m "Add bar to requirements.txt"
git push origin
```


## Testing and Building the Charm

After any change in the charm code, you want to ensure that all unit tests
pass before building it. This can be easily done by running:

```
make test build
```


## Viewing the Coverage Report

To view the coverage report, run the tests first and then run:

```
make coverage-server
```

This will run a simple web server on port 5000 that will serve the files
in the auto-generated `htmlcov/` directory. You may leave this server running
in a separate session as you run the tests so that you can just switch back
to the browser and hit refresh to see the changes to your coverage down to
the line of code.


## Running the Tests in Multiple Python Versions

More often than not your charm needs to support more than one version of
Python. This is where tox comes in. Just run the following to get test
results for all Python versions listed in tox.ini's envlist config option

```
tox
```

## Need A Fresh Start?

Sigh, oh what we'd give to get a fresh start in life, huh? Oh, wait, you
mean just the project directory's state? Oh, well we got you covered there
too! Just run:

```
make clean
```
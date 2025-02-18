# NS-3 Docker image

## Useful commands

How to add ns3 submodule to the repository:

`git submodule add git@gitlab.com:nsnam/ns-3-dev.git extern/ns3`

How to update the submodules configuration (apply changes from the file):

`git submodule sync`

Update the submodules:

`git submodule update --remote --merge`

How to check the `site-modules` include path in Python:

`python -m site`

https://stackoverflow.com/questions/122327/how-do-i-find-the-location-of-my-python-site-packages-directory
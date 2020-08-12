# Main repository README

## Description

This is the main repository for the contact tracing project. It ties all 
sub-projects together into a single code base in order to keep the project as
clean and structured as possible. This README is only a simple set up guide for
the project and contains no technical documentation.

More information
about the project can be found on the 
[Confluence page](https://contracing.atlassian.net/wiki/spaces/CONTRACING/overview?homepageId=32960)
and the workflow and issues can be found on the 
[Jira board](https://contracing.atlassian.net/secure/RapidBoard.jspa?rapidView=4&projectKey=CT).

Information about Git related issues can be found on the 
[wiki pages](https://bitbucket.org/contracing/contracing/wiki/Home).

## Requirements

The git hooks used in this project requires python 2.7 which can be installed 
like this

```
sudo apt install python
```

## Installing

In order to clone the contracing repository and all submodules within it, run
the following git clone command (assuming you have 
[set up SSH](https://bitbucket.org/contracing/contracing/wiki/pages/ssh-setup) 
on your Bitbucket user). It is then important to install the git hooks properly
using the script `install_hooks`.

```
git clone --recurse-submodules git@bitbucket.org:contracing/contracing.git/
cd contracing
scripts/install_hooks
```

## Git workflow

This project uses some hooks in order to enforce certain guidelines on code 
style as well as git related operations. Please read the 
[git hooks wiki page](https://bitbucket.org/contracing/contracing/wiki/pages/hooks)
in order to get an overview of the hooks and how they work. Should there be any
updates to the hooks, users will be notified to update their hooks using the 
same installation script as above.

# Main Repository README

## Description

This is the main repository for the contact tracing project. It ties all  
sub-projects together into a single code base in order to keep the project as  
clean and structured as possible. This README is only a simple set up guide for  
the project and contains no technical documentation. 

## Requirements

```
sudo apt install -y python clang-format
```

## Installing

In order to clone the Main-Contracing-Repository repository and all submodules  
within it, run the following git clone command (assuming you have set up SSH  
on your Github user). It is then important to install the git hooks properly  
using the script `install_hooks`.

```
git clone --recurse-submodules git@github.com:martinaalien/Main-Contracing-Repository.git
cd Main-Contracing-Repository
scripts/install_hooks
```
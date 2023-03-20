# create-apachevh


Restore `tmux` environment after system restart.

Creating virtual host requires knowing which configurations to change and 
update. Which are easy to forget!


`create-apachvh` creates virtual host(s) and updates all relevant files.
All then you have to do is test for the provide link and start working
right away.
Creating virtual host will feel like a breaze.

### Preview

![Preview working with create-apachevh](./screencast_img.png)

### Commands

- `create-apachevh host.link`

You can specify multiple host as a list of arguments.

### About

Creates virtual host on arch based systems only, atleast for now.

Requirements : `apache server`

Tested and working on Manjaro Linux.

### Installation

Clone and add to your local bin folder of your working directory.
Add execution rights. Then you are goo to go.

- `chmod u+x create-apachevh`


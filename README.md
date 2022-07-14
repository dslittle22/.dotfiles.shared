It's my dotfiles!

## Instructions:

1. On old machine, run `make_brewfiles.sh -b`, to make a new brewfile. Git commit and push.
2. Set up git / github on new machine:
   [url](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
3. clone the .dotfiles repo into home dir:
   `git clone git@github.com:dslittle22/.dotfiles.git ~/.dotfiles`
4. On new machine, run `make_brewfiles.sh` to make Brewfile-work and Brewfile-personal
5. Run `new_machine_install.sh -m work` or `-m personal` from .dotfiles directory
6. Follow the instructions

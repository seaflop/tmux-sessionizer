# tmux-sessionizer

## About

An automated tmux session creator that uses a fuzzy finder to search for 
directories from your root directory and launch a tmux session in the chosen 
directory. 

## Installation

**Dependencies:**

- tmux
- fzf

Clone the repository:

```
git clone https://github.com/seaflop/tmux-sessionizer
cd tmux-sessionizer
```

Add the script to your PATH. Typically `/bin` is already in your PATH. Verify 
by running `echo $PATH`.

```
sudo mv script.sh /bin/
sudo mv /bin/script.sh /bin/tsm
chmod +x /bin/tsm
cd ..
rm -rf tmux-sessionizer
```

## Usage

1. Run the `tsm` command to launch the fuzzy finder.
2. Search for the directory and hit ENTER.
3. et voila.

**_Note that searching for a directory that already has a session active in it 
will instead attach to the pre-existing session._**

## To-do

- Add more robust session renaming when encountering sessions that have the 
same name. Currently only renaming the new session without renaming the old 
matched session.
- Speed up fzf by removing search for unnecessary directories.
- Create a fzf menu specifically for session attach and deletion.
- Add support for compatibility with tmux sessions not created with `tsm`.

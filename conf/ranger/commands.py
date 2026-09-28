from ranger.api.commands import Command
import os
import subprocess

# Show full date + time in the log viewer (bound to `W`).
# ranger hardcodes datefmt='%H:%M:%S' in ranger/ext/logutils.py, so the log only
# shows the time. Re-set the formatter on the already-installed log handlers to
# prepend the date, keeping ranger's own format string (normal vs --debug).
import logging as _logging

_LOG_DATEFMT = '%Y-%m-%d %H:%M:%S'
for _handler in _logging.getLogger().handlers:
    _fmt = _handler.formatter
    if _fmt is not None:
        _handler.setFormatter(_logging.Formatter(fmt=_fmt._fmt, datefmt=_LOG_DATEFMT))


class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """
    def execute(self):
        if self.quantifier:
            # match only directories
            command = "find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        else:
            # match files and directories
            command = "find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m"
        fzf = self.fm.execute_command(command, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.decode('utf-8').rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class open_drop(Command):

    def execute(self):
        uname_output = subprocess.check_output(['uname']).decode('utf-8').strip()
        if 'Darwin' in uname_output:
            subprocess.call(['open', self.fm.thisdir.path])
        else:
            subprocess.call(['dragon-drop', '-a', '-x', self.fm.thisfile.path])

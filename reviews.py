#!/usr/bin/python

import bugzilla
import re
import sys

bz = bugzilla.Bugzilla(url='https://bugzilla.redhat.com/xmlrpc.cgi')

bugs = bz.getbugs(bz.getbug(956806).depends_on)
summaries = [bug.summary for bug in bugs]

pkgs = []
for summary in summaries:
    m = re.search(r'(\S*) -', summary)
    if m:
        pkg = m.group(1)
        npm = pkg.replace('nodejs-','')
        pkgs.append((npm, pkg))
    else:
        sys.stderr.write('Malformed review summary: ' + summary + '\n')

with open('out/reviews.txt', 'w') as fh:
    for pkg in pkgs:
        fh.write(pkg[0])
        fh.write('\n')

with open('out/reviews-rpm.txt', 'w') as fh:
    for pkg in pkgs:
        fh.write(pkg[0])
        fh.write(' ')
        fh.write(pkg[1])
        fh.write('\n')

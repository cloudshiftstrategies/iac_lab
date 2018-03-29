#!/usr/bin/env python

searchstr="iaclab"

import hcl, json, sys, os
from copy import deepcopy

cleantf = "clean.tf"
outtf = "out.tf"

with open(cleantf) as cleanfile:
    resources = hcl.load(cleanfile)
output = deepcopy(resources)

#print json.dumps(resources, indent=2)
#sys.exit(1)
for rtype in resources['resource']:
    for rname in resources['resource'][rtype]:
        if 'default' in rname:
            pass
        elif searchstr in rname:
            print rname
            del output['resource'][rtype][rname]
        elif 'tags' in resources['resource'][rtype][rname]:
            if 'Project' in resources['resource'][rtype][rname]['tags']:
                if searchstr in resources['resource'][rtype][rname]['tags']['Project']:
                    print rname
                    del output['resource'][rtype][rname]
            elif 'Name' in resources['resource'][rtype][rname]['tags']:
                if searchstr in resources['resource'][rtype][rname]['tags']['Name']:
                    print rname
                    del output['resource'][rtype][rname]

# Delete empty resource types
outdata = deepcopy(output)
for rtype in output['resource']:
    if not output['resource'][rtype]:
        del outdata['resource'][rtype]

#print json.dumps(outdata, indent=2)
outfile = open(outtf, 'w')
outfile.write(hcl.dumps(outdata, indent=2, sort_keys=True))
outfile.close()
os.rename(cleantf, cleantf + ".sav")

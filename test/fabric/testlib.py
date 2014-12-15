#!/usr/bin/env python

import re
import os
from fabric.api import run, hide, get


def apache2_is_responding(search):
    with hide('running', 'stdout'):
        wget_cmd = (
            "wget --quiet --output-document - --header='Host: example.com' "
            "http://localhost/"
        )
        homepage = run(wget_cmd)
        if re.search(search, homepage):
            return True
        else:
            return False


def get_artifacts():
    artifacts = ['/tmp/heat_chef', '/tmp/run_recipe.log']
    for artifact in artifacts:
        if os.getenv('CIRCLE_ARTIFACTS') is not None:
            tarfile = "{0}.tar.gz".format(artifact)
            destination = "{0}/%(host)s/{1}".format(os.getenv('CIRCLE_ARTIFACTS'), tarfile)
            command = "tar czvf {0} --exclude='nodes' {1}".format(tarfile, artifact)
            run(command)
            get(tarfile, destination)

if __name__ == "__main__":
    pass

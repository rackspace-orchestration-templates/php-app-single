import re, os
from fabric.api import env, run, hide, task, get
from envassert import detect, file, group, package, port, process, service, \
    user


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


@task
def check():
    env.platform_family = detect.detect()

    artifacts = ['/tmp/heat_chef', '/tmp/run_recipe.log']
    for artifact in artifacts:
        if os.getenv['CIRCLE_ARTIFACTS']:
            get(artifact, os.environ['CIRCLE_ARTIFACTS'])

    assert file.exists('/var/www/vhosts/application/index.php'), \
        '/var/www/vhosts/application/index.php did not exist'

    assert port.is_listening(80), 'port 80/apache2 is not listening'
    assert port.is_listening(3306), 'port 3306/mysqld is not listening'
    assert port.is_listening(11211), 'port 11211/memcached is not listening'

    assert user.exists('mysql'), 'mysql user does not exist'
    assert user.exists('memcache'), 'user memcache does not exist'

    assert process.is_up('apache2'), 'apache2 process is not up'
    assert process.is_up('mysqld'), 'mysqld is not running'
    assert process.is_up('memcached'), 'memcached process is not up'

    assert service.is_enabled('apache2'), 'apache2 is not enabled'
    assert service.is_enabled('mysql'), 'mysql service not enabled'
    assert service.is_enabled('memcached'), 'memcached is not enabled'

    assert apache2_is_responding('PHP Version'), 'php app did not respond as expected'

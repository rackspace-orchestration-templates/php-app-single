import re
from fabric.api import env, run, hide, task
from envassert import detect, file, port, process, service, user


def apache2_is_responding():
    with hide('running', 'stdout'):
        wget_cmd = (
            "wget --quiet --output-document - --header='Host: example.com' "
            "http://localhost/"
        )
        homepage = run(wget_cmd)
        if re.search('Welcome to example.com', homepage):
            return True
        else:
            return False


@task
def check():
    env.platform_family = detect.detect()

    assert file.exists('/var/www/vhosts/application/index.php'), \
        '/var/www/vhosts/application/index.php did not exist'

    assert port.is_listening(80), 'port 80/apache2 is not listening'
    assert port.is_listening(3306), 'port 3306/mysqld is not listening'
    assert port.is_listening(11211), 'port 11211/memcached is not listening'

    assert user.exists('mysql'), 'mysql user does not exist'
    assert user.exists('memcache'), 'memcache user does not exist'

    assert process.is_up('apache2'), 'apache2 is not running'
    assert process.is_up('mysqld'), 'mysqld is not running'
    assert process.is_up('memcached'), 'memcached is not running'

    assert service.is_enabled('apache2'), 'apache2 service not enabled'
    assert service.is_enabled('mysql'), 'mysql service not enabled'
    assert service.is_enabled('memcached'), 'memcached service not enabled'

    assert apache2_is_responding(), 'apache2 did not respond as expected.'

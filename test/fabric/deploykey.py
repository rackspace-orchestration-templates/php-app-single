import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fabric.api import env, task
from testlib import get_artifacts, apache2_is_responding
from envassert import detect, file, port, process, service, user


@task
def check():
    env.platform_family = detect.detect()
    get_artifacts()

    assert file.exists('/var/www/vhosts/application/current/index.php'), \
        '/var/www/vhosts/application/current/index.php did not exist'

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

    assert apache2_is_responding('PHP Version'), 'php app did not respond'

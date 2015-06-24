from fabric.api import env, task
from envassert import detect, file, port, process, service, user
from hot.utils.test import get_artifacts, http_check


@task
def check():
    env.platform_family = detect.detect()

    site = "http://localhost/"
    string = env.string

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

    assert http_check(site, string), 'Apache is not responding as expected.'


@task
def artifacts():
    env.platform_family = detect.detect()
    get_artifacts()

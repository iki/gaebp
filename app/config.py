# -*- coding: utf-8 -*-

import os as _os


##| Configure properties.

live_app_id = 's~gaebp-demo'
live_domain = 'gaebp-demo.appspot.com'

analytics_live_id = ''
analytics_test_id = ''


##| Configure environment.

app_path = _os.path.abspath(_os.path.dirname(_os.path.realpath(__file__)))
lib_path = ('lib', 'lib/dist.zip')
lib_path = [ _os.path.join(app_path, p) for p in lib_path ]
lib_path = [ p for p in lib_path if _os.path.exists(p) ]

app_id = _os.environ.get('APPLICATION_ID', None)
version, deployment_version = _os.environ.get('CURRENT_VERSION_ID', '0.0').rsplit('.', 1)

is_local = _os.environ.get('SERVER_SOFTWARE', 'Dev').startswith('Dev')
    ##| SERVER_SOFTWARE is 'Development/X.Y' on SDK, or 'Google App Engine/X.Y.Z' on Google Cloud.
is_live = (app_id == live_app_id) and not is_local

debug = not is_live

enable_appstats = True


##| Configure data.

analytics_id = analytics_live_id if is_live else ('' if is_local else analytics_test_id)

template_path = 'site'
template_path = _os.path.join(app_path, template_path)

content_path = template_path
content_file = '{name}.{lang}.yaml'

default_lang = 'en'


##| Configure webapp2.

webapp2_config = dict((kv for kv in locals().iteritems() if not kv[0][0] == '_'))

webapp2_config['webapp2_extras.jinja2'] = dict(
    template_path = template_path,
    compiled_path = None,
    globals = dict(
        config = webapp2_config,
        ),
    )

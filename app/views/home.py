"""Home page view.
"""
__all__ = 'Home'.split()

import os
import yaml
import urllib
import logging

import webapp2

from webapp2_extras import jinja2


def urlquote(s):
    return urllib.quote_plus(s.encode('utf8'))

class Home(webapp2.RequestHandler):

    log = logging

    config = webapp2.get_app().config
    config_key = jinja2.Jinja2.config_key # 'webapp2_extras.jinja2'

    content_path = config['content_path']
    content_file = config['content_file']

    default_lang = config['default_lang']
    default_template = 'index.html'

    headers = {
        'Access-Control-Allow-Origin': '*',
        'X-UA-Compatible': 'IE=edge,chrome=1',
        }

    globals = dict(
        urlquote = urlquote,
        )

    filters = dict(
        )

    tests = dict(
        )


    def get(self, **options):
        self.response.headers.update(self.get_headers(**options))
        self.write_response(self.get_response(**options))

    def get_headers(self, **options):
        return self.headers

    def get_options(self, **options):
        if 'name' not in options:
            options['name'] = os.path.splitext(self.get_template(**options))[0]

        if 'lang' not in options:
            options['lang'] = self.default_lang

        options['content_path'] = content_path = options.get(
            'content_path', self.content_path)
        options['content_file'] = content_file = options.get(
            'content_file', self.content_file).format(**options)

        options.update(yaml.load(open(os.path.join(content_path, content_file))))

        return options

    def get_template(self, template=None, **options):
        return (template or self.default_template).format(**options)

    def get_response(self, **options):
        options = self.get_options(**options)
        return self.render_template(**options)

    def write_response(self, response):
        if self.log: self.log.info(u'writing response: {0} [{1}]'.format(
            self.response.headers.get('Content-Type', None) or response.__class__.__name__,
            len(response)))
        self.response.write(response)

    def render_template(self, template=None, **options):
        template = self.get_template(template, **options)
        if self.log: self.log.info(u'rendering jinja template {template}'.format(template=template))
        return self.jinja2.render_template(template, **options)

    @property
    def jinja2(self):
        try:
            return self.__class__.jinja2_instance
        except AttributeError:
            if self.log: self.log.info(u'get jinja2 instance {app}: {key}'.format(
                app = self.app.__class__.__name__,
                key = '.'.join((jinja2._registry_key, self.__class__.__name__)),
                ))
            self.__class__.jinja2_instance = jinja2.get_jinja2(
                app = self.app,
                factory = self.jinja2_factory,
                key = '.'.join((jinja2._registry_key, self.__class__.__name__)),
                )
            return self.__class__.jinja2_instance

    def jinja2_factory(self, app):
        if self.log: self.log.info(u'new jinja2 for {cls} [{id}] in {app} [{app_id}] with app config {key}:\n{app_config}\n(loaded: {loaded}) and custom config:\n{config}'.format(
            cls = self.__class__.__name__, id = id(self.__class__),
            app = app.__class__.__name__, app_id = id(app),
            key = self.config_key, loaded = self.config_key in app.config.loaded,
            app_config = app.config.get(self.config_key, None),
            config = self.config.get(self.config_key, None),
            ))
        j = jinja2.Jinja2(app, self.config)
        j.environment.filters.update(self.filters)
        j.environment.globals.update(self.globals)
        j.environment.tests.update(self.tests)
        return j

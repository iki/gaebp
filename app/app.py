import config
import routes

import webapp2

if config.lib_path:
    import sys
    sys.path[:0] = [ p for p in config.lib_path if not p in sys.path ]

app = webapp2.WSGIApplication(debug=config.debug, config=config.webapp2_config)

for route in routes.routes:
    app.router.add(route)

if config.enable_appstats:
    from google.appengine.ext.appstats import recording
    app = recording.appstats_wsgi_middleware(app)

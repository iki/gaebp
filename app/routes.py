"""Application routes.
"""
__all__ = 'routes'.split()

# from webapp2 import Route
from webapp2_extras.routes import RedirectRoute # , PathPrefixRoute

##| Configure application routes.

routes = [

    ##| Home page
    RedirectRoute('/', 'views.home.Home',  name='home'),

    ##| Redirect any other /path to /#path.
    RedirectRoute('/<path:.*>', redirect_to = lambda handler, path: '/#{0}'.format(path)),

    ]

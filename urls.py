from django.conf import settings
from django.conf.urls.defaults import *
from django.contrib import admin
from tomo.course.models import Course

admin.autodiscover()

urlpatterns = patterns('',
    (r'^$', 'tomo.views.homepage', {}, 'homepage'),
    (r'^admin/', include(admin.site.urls)),
    (r'^course/', include(patterns('tomo.course.views',
        url(r'^(?P<course_id>\d+)/$', 'view_course', name='course'),
    ))),
    (r'^problem_set/', include(patterns('tomo.course.views',
        (r'^(?P<problem_set_id>\d+)/', include(patterns('tomo.course.views',
            url(r'^$', 'view_problem_set', name='problem_set'),
            url(r'^zip/$', 'download_problem_set', name='download_problem_set'),
            url(r'^stats/$', 'view_statistics', name='view_statistics'),
        ))),
    ))),
    (r'^problem/', include(patterns('tomo.problem.views',
        (r'^(?P<problem_id>\d+)/', include(patterns('tomo.problem.views',
            # Download the file used to solve a problem
            (r'^$', 'download', {}, 'download'),
            # Download the file used to solve a problem
            (r'^(?P<user_id>\d+)/$', 'download_user', {}, 'download_user'),
            # Download the file used to solve a problem
            (r'^edit/$', 'edit', {}, 'edit'),
        ))),
        # Respond to a challenge
        (r'^upload/$', 'upload', {}, 'upload'),
        # Download the file used to edit a problem
        (r'^edit/$', 'edit', {}, 'edit'),
        # Create a problem
        (r'^create/$', 'create', {}, 'create'),
        # Update the problem
        (r'^update/$', 'update', {}, 'update'),
    ))),
    (r'^accounts/', include(patterns('django.contrib.auth.views',
        (r'^login/$', 'login', {
            'template_name': 'home.html',
            'extra_context': { 'courses': Course.objects }
        }),
        (r'^logout/$', 'logout', {'next_page': '/'}),
    )))
)

if settings.DEBUG:
    urlpatterns += patterns('',
        (r'^static/(?P<path>.*)$', 'django.views.static.serve', {
            'document_root': settings.MEDIA_ROOT
        }),
    )

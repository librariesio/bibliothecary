from setuptools import setup

setup(name='political-memory',
    version='0.0.1',
    description='OpenShift App',
    packages=['political_memory'],
    package_dir={'political_memory': '.'},
    author='James Pic, Laurent Peuch, Arnaud Fabre',
    author_email='cortex@worlddomination.be',
    url='http://github.com/political-memory/political_memory/',
    install_requires=[
        # -*- Install requires: -*-
        'django-bootstrap3>=6.2,<6.3',
        'lesscpy',
        'unicodecsv==0.14.1',
        'django-coffeescript>=0.7,<0.8',
        'django-compressor>=1.6,<1.7',
        'django-datetime-widget>=0.9,<1.0',
        'django-filter>=0.11,<0.12',
        'django-representatives-votes>=0.0.13',
        'django-representatives>=0.0.14',
        'django-taggit>=0.17,<0.18',
        'django>=1.8,<1.9',
        'djangorestframework>=3.2.0,<3.3.0',
        'hamlpy>=0.82,<0.83',
        'ijson>=2.2,<2.3',
        'python-dateutil>=2.4,<2.5',
        'pytz==2015.7',
        'django-suit',
    ],
    extras_require={
        'testing': [
            'django-responsediff',
            'flake8',
            'pep8',
            'pytest',
            'pytest-django',
            'pytest-cov',
            'codecov',
        ]
    }
)

#!/usr/bin/env python

from setuptools import setup

setup(
    name="vapprun",
    version="1.0.1",
    author="Yann Hodique",
    author_email="hodiquey@vmware.com",
    namespace_packages=['vmw'],
    packages=['vmw', 'vmw.vapprun'],
    package_data={'vmw.vapprun': ['templates/*']},
    scripts=['bin/vapprun'],
    setup_requires=['setuptools'],
    install_requires=['setuptools', 'six'],
)

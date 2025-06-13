#!/usr/bin/env python3
"""
Setup script for EnviREAment - Virtual REAPER Environment

This setup.py provides additional compatibility for older pip versions
and development installations.
"""

from setuptools import setup, find_packages
import os

# Read the README file
readme_path = os.path.join(os.path.dirname(__file__), "README.md")
if os.path.exists(readme_path):
    with open(readme_path, "r", encoding="utf-8") as fh:
        long_description = fh.read()
else:
    long_description = "EnviREAment - Virtual REAPER Environment for Development and Testing"

setup(
    name="envireament",
    version="1.0.0",
    author="Matthew @ Songbase",
    author_email="contact@songbase.dev",
    description="EnviREAment - Virtual REAPER Environment for Development and Testing",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/your-username/EnviREAment",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Lua",
        "Topic :: Multimedia :: Sound/Audio",
        "Topic :: Software Development :: Testing",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
    install_requires=[],
    extras_require={
        "dev": ["black", "pytest", "flake8"],
    },
    entry_points={
        "console_scripts": [
            "envireament=envireament.cli:main",
            "envireament-test=envireament.cli:run_tests_cli",
            "envireament-demo=envireament.cli:run_demo_cli",
        ],
    },
    include_package_data=True,
    package_data={
        "": ["*.lua", "README.md", "LICENSE"],
        "envireament": ["*"],
    },
    keywords=["reaper", "virtual-environment", "testing", "lua", "imgui", "music-production"],
    project_urls={
        "Bug Reports": "https://github.com/your-username/EnviREAment/issues",
        "Source": "https://github.com/your-username/EnviREAment",
        "Documentation": "https://github.com/your-username/EnviREAment/docs",
    },
)

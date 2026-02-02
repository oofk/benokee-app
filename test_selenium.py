#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Test script om te controleren of Selenium correct is geïnstalleerd."""

import sys
import io

# Fix encoding voor Windows console
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

try:
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from selenium.webdriver.chrome.options import Options
    from webdriver_manager.chrome import ChromeDriverManager
    print("OK: Selenium is succesvol geinstalleerd!")
    print("OK: Alle benodigde modules zijn beschikbaar")
    print("\nJe kunt nu de BOSA formulier scripts gebruiken:")
    print("  - python bosa_form_analyzer.py")
    print("  - python bosa_app.py")
except ImportError as e:
    print(f"FOUT: {e}")
    print("\nInstalleer Selenium met:")
    print("  python -m pip install selenium webdriver-manager")


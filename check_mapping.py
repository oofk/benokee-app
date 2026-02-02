#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Check field mapping bestand."""

import json

with open('bosa_field_mapping.json', 'r', encoding='utf-8') as f:
    m = json.load(f)

print(f'Field mapping bevat {len(m)} velden')
print('\nEerste 10 velden:')
for k, v in list(m.items())[:10]:
    print(f'  {k}: {v["selector"]["value"]} ({v.get("type", "unknown")})')



import os
import re

# 1. pubspec.yaml
with open('pubspec.yaml', 'r') as f:
    c = f.read()
c = c.replace('name: easypos', 'name: yellowpos')
with open('pubspec.yaml', 'w') as f:
    f.write(c)

# 2. main.dart (MaterialApp Title and WindowManager Title)
with open('lib/main.dart', 'r') as f:
    c = f.read()
c = c.replace("title: 'EasyPOS'", "title: 'Yellow Pos'")
with open('lib/main.dart', 'w') as f:
    f.write(c)

# 3. installer.iss
with open('windows/runner/installer.iss', 'r') as f:
    c = f.read()
c = c.replace('MyAppName "EasyPOS"', 'MyAppName "Yellow Pos"')
c = c.replace('MyAppName, "EasyPOS"', 'MyAppName, "Yellow Pos"')
c = c.replace('MyAppName, "easypos"', 'MyAppName, "yellowpos"')
c = c.replace('OutputBaseFilename=EasyPOS_Setup', 'OutputBaseFilename=YellowPos_Setup')
with open('windows/runner/installer.iss', 'w') as f:
    f.write(c)

# 4. Printer Service
with open('lib/core/utils/printer_service.dart', 'r') as f:
    c = f.read()
c = c.replace("Logiciel EasyPOS", "Logiciel Yellow Pos")
with open('lib/core/utils/printer_service.dart', 'w') as f:
    f.write(c)

# 5. React Web Admin
with open('web-admin/index.html', 'r') as f:
    c = f.read()
c = c.replace("Vite + React + TS", "Yellow Pos Admin")
with open('web-admin/index.html', 'w') as f:
    f.write(c)

with open('web-admin/package.json', 'r') as f:
    c = f.read()
c = c.replace('"name": "web-admin"', '"name": "yellowpos-admin"')
with open('web-admin/package.json', 'w') as f:
    f.write(c)

# 6. Windows Runner properties
try:
    with open('windows/runner/Runner.rc', 'r') as f:
        c = f.read()
    c = c.replace("EasyPOS", "Yellow Pos")
    c = c.replace("easypos", "yellowpos")
    with open('windows/runner/Runner.rc', 'w') as f:
        f.write(c)
except:
    pass

try:
    with open('windows/runner/main.cpp', 'r') as f:
        c = f.read()
    c = c.replace("easypos", "Yellow Pos")
    with open('windows/runner/main.cpp', 'w') as f:
        f.write(c)
except:
    pass

print("App successfully renamed to Yellow Pos!")

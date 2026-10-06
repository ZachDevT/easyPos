import os
import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

if "SupabaseConfig.initialize();" not in content:
    content = content.replace(
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'core/supabase/supabase_config.dart';"
    )
    content = content.replace(
        "await windowManager.waitUntilReadyToShow(windowOptions, () async {",
        "await SupabaseConfig.initialize();\n  await windowManager.waitUntilReadyToShow(windowOptions, () async {"
    )

with open('lib/main.dart', 'w') as f:
    f.write(content)

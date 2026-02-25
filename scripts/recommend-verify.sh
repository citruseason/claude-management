#!/bin/bash
# Recommend running /verify-implementation before git push
# Non-blocking: always exits 0

if echo "$TOOL_INPUT" | grep -q "git push"; then
  echo "💡 Tip: Consider running /verify-implementation before pushing to validate against project standards." >&2
fi

exit 0

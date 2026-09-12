#!/bin/bash
# Decode staged phase1-payloads/*.gz.b64 into live site files on feat/phase1-site-improvements.
# Requires: gh auth (GITHUB_TOKEN) with contents:write
set -euo pipefail
BRANCH=feat/phase1-site-improvements
REPO=hellsecdev/hellsec.dev

put_decoded() {
  local dest="$1" payload="$2" msg="$3"
  local tmp sha b64
  tmp=$(mktemp)
  gh api "repos/$REPO/contents/$payload?ref=$BRANCH" --jq .content | tr -d '\n' | base64 -d | gzip -dc > "$tmp"
  echo "decoded $dest bytes=$(wc -c < "$tmp")"
  sha=$(gh api "repos/$REPO/contents/$dest?ref=$BRANCH" --jq .sha)
  b64=$(base64 -w0 "$tmp")
  gh api --method PUT "repos/$REPO/contents/$dest" \
    -f message="$msg" -f content="$b64" -f branch="$BRANCH" -f sha="$sha" \
    --jq '{commit:.commit.sha, blob:.content.sha, size:.content.size}'
  rm -f "$tmp"
}

put_decoded he/index.html phase1-payloads/he.index.html.gz.b64 "feat: Phase 1 — he/index.html full overwrite (from payload)"
put_decoded ru/index.html phase1-payloads/ru.index.html.gz.b64 "feat: Phase 1 — ru/index.html (from payload)"
put_decoded index.html phase1-payloads/en.index.html.gz.b64 "feat: Phase 1 — link assets/phase1.css on EN home (from payload)"
echo DONE

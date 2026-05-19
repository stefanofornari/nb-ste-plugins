#!/usr/bin/env bash
set -euo pipefail

OUTDIR=target/netbeans_site
NBMDIR=target/repo/nbm
mkdir -p "$OUTDIR/nbm"

TS=$(date +%s)
cat > "$OUTDIR/updates.xml" <<XML
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE module_updates PUBLIC "-//NetBeans//DTD Autoupdate Catalog 2.8//EN" "https://netbeans.apache.org/dtds/autoupdate-catalog-2_8.dtd">
<module_updates timestamp="$TS">
XML

shopt -s nullglob
for f in "$NBMDIR"/*.nbm; do
  echo "Processing $f"
  cp "$f" "$OUTDIR/nbm/"
  # extract the <module ...> element from Info/info.xml and append
  unzip -p "$f" Info/info.xml | sed -n '/<module/,/<\/module>/p' >> "$OUTDIR/updates.xml" || true
done

cat >> "$OUTDIR/updates.xml" <<XML

</module_updates>
XML

gzip -c "$OUTDIR/updates.xml" > "$OUTDIR/updates.xml.gz"

echo "Generated $OUTDIR/updates.xml and copied nbms to $OUTDIR/nbm"

#!/bin/sh
cd $(dirname $0)/..
set -eux

# settings
REPORT_DIR="__reg_report__"
STORYCAP_DIR_PREFIX="storycap_"

# args
actual_ref=$1
expect_ref=$2

# functions
storycap() {
  npx storycap \
    -C puppeteer \
    --serverCmd "start-storybook -p 6006" \
    --serverTimeout 60000 \
    --delay 1000 \
    http://localhost:6006
}

# main
[ ! -e $REPORT_DIR ] && mkdir $REPORT_DIR

if [ ! -e "$REPORT_DIR/$STORYCAP_DIR_PREFIX$expect_ref" ]; then
  git checkout $expect_ref || :
  storycap
  mv __screenshots__ "$REPORT_DIR/$STORYCAP_DIR_PREFIX$expect_ref"
fi
if [ ! -e "$REPORT_DIR/$STORYCAP_DIR_PREFIX$actual_ref" ]; then
  git checkout $actual_ref || :
  storycap
  mv __screenshots__ "$REPORT_DIR/$STORYCAP_DIR_PREFIX$actual_ref"
fi

cd $REPORT_DIR
npx reg-cli \
  "$STORYCAP_DIR_PREFIX$actual_ref" \
  "$STORYCAP_DIR_PREFIX$expect_ref" \
  diff \
  --concurrency $(nproc) \
  --report report.html

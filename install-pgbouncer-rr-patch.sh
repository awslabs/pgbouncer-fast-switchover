#!/bin/bash

#
# Copyright 2015-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License. A copy of the License is located at
#
#  http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied. 
# See the License for the specific language governing permissions and limitations under the License.
#
# pgbouncer-rr-patch: 
# Script to patch pgbouncer distribution with pgbouncer-rr enhancements
#

USAGE="Usage: $0 <pgbouncer dir>"
usage() {
   echo $USAGE
   exit 1
}

PGDIR=$1
[ -z "$PGDIR" ] && usage

PATCHDIR=$(pwd)
patchstatus=0

# Patch each modified file
MERGEFILES="\
   Makefile\
   src/client.c\
   src/main.c\
   include/bouncer.h\
   "
for file in $MERGEFILES
do
   echo Merging pgbouncer-rr changes to: $PGDIR/$file
   patch -d $PGDIR -f -b -p1 < $PATCHDIR/$file.diff || patchstatus=1
done


# copy pgbouncer-rr source files
mkdir -p $PGDIR/images
NEWFILES="\
   README.md\
   LICENSE.txt\
   NOTICE.txt\
   pgbouncer-example.ini\
   users.txt\
   rewrite_query.py\
   routing_rules.py\
   images/diagram1.jpg\
   images/diagram2-routing.jpg\
   images/diagram3-rewrite.jpg\
   src/pycall.c\
   src/rewrite_query.c\
   src/route_connection.c\
   include/pycall.h\
   include/rewrite_query.h\
   include/route_connection.h\
   "
echo -n "copying pgbouncer-rr files: "
for file in $NEWFILES
do
   echo -n "$file "
   cp $PATCHDIR/$file $PGDIR/$file || patchstatus=1
done
echo

if [ $patchstatus -eq 1 ]; then
   echo "Failures encountered during merge of pgbouncer-rr with pgbouncer."
   echo "See error messages above."
   echo "Possible causes: "
   echo "   pgbouncer-rr-patch already installed in target directory?"
   echo "   new version of pgbouncer with changed source files that can't be patched?"
   echo "      - last tested with pgbouncer v1.12 (April 2020)"
   echo "      - Try getting pgbouncer with: git clone https://github.com/pgbouncer/pgbouncer.git --branch \"stable-1.19\""
   echo "Status: pgbouncer-rr-patch merge FAILED"
else
   echo "Status: pgbouncer-rr-patch merge SUCEEDED"
fi
exit $patchstatus

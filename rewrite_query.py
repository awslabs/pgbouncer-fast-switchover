# Copyright 2015-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Amazon Software License (the "License").
# You may not use this file except in compliance with the License. A copy of the License is located at
#
#     http://aws.amazon.com/asl/
#
# or in the "license" file accompanying this file.
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#
# Python module containing example query rewrite function.
# Configure path/name to this file in [pgbouncer] section of ini file.
# Ex:
#    rewrite_query_py_module_file = /etc/pgbouncer/rewrite_query.py


# REWRITE FN - CALLED FROM PGBOUNCER - DO NOT CHANGE NAME
# RETURNS MODIFIED QUERY STRING
import re
def rewrite_query(username, query):
    if re.match(username, "user_with_limited_access"):
	new_query = re.sub(r'clockwork_unsanitized.members', 'clockwork_unsanitized.members_obfuscated', query)
        # new line
    else:
	new_query = query

    return new_query


if __name__ == "__main__":
    print("rewriting queries!")

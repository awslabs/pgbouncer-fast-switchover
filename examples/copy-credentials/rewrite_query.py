import re
from boto import utils

def rewrite_query(username, query):
    cred_pattern="'aws_access_key_id=\S*;aws_secret_access_key=\S*'"
    if re.search(cred_pattern, query) is not None:
        role=list(utils.get_instance_metadata()['iam']['security-credentials'])[0]
        creds=utils.get_instance_metadata()['iam']['security-credentials'][role]
        repl_pattern="'aws_access_key_id=%s;aws_secret_access_key=%s;token=%s'" % (creds['AccessKeyId'], creds['SecretAccessKey'], creds['Token'])
        new_query = re.sub(cred_pattern, repl_pattern, query).replace("\n"," ")
    else:
        new_query = query
    return str(new_query)

if __name__ == "__main__":
    # some tests
    print rewrite_query("root", "copy lineitem from 's3://redshift-demo/tpc-h/100/lineitem/lineitem.tbl.' CREDENTIALS 'aws_access_key_id=XXXXX;aws_secret_access_key=YYYYYY' gzip delimiter '|';")

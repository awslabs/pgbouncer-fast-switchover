# copy-credentials 
This rewrite example showcases how you can match a pattern to identify a Redshift SQL command which requires AWS credentials, then generate temporary credentials and insert them into the command. This prevents the need to pass AWS credentials in the SQL directly from the SQL client and simplifies credential management. To use the credentials from the IAM role you must launch the EC2 instance with the pgbouncer server using a role which has the necessary privileges.

It's important to note that if credentials expire while a COPY is in progress then the command will fail, so it's best to generate credentials in a way so that they will exist for the entire duration of the COPY command.

| Example | Type | Purpose |
| ------------- | -------------  | ------------- |
| copy-credentials | rewrite | Intercept a COPY command with missing credentials, passes in temporary credentials from EC2 IAM role. |

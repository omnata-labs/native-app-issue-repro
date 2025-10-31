## Repro for Snowflake case 01167074

The issue occurs when a native application provides access to one of its functions via an application role, but the function references a secret which the caller does not have access to.

### Steps

1. Deploy the native application, henceforth referred to as `MY_NATIVE_APP_PROJECT_VSCODE`.

There is a dev container instance configured to mount the traditional snowcli config path (.config/snowflake) into the container, so if you have configuration there you can run the following terminal command:
```
snow app run -c dev -p /workspaces/native-app-issue-repro/my_app
```

2. Remove debug mode: `alter application MY_NATIVE_APP_PROJECT_VSCODE set debug_mode=false`

3. Create an external access integration which uses the secrets and rules owned by the application:

```
create EXTERNAL ACCESS INTEGRATION EAI_TEST
ALLOWED_NETWORK_RULES=(MY_NATIVE_APP_PROJECT_VSCODE.DATA.MY_NETWORK_RULE)
ALLOWED_AUTHENTICATION_SECRETS=(MY_NATIVE_APP_PROJECT_VSCODE.DATA.MY_SECRET)
enabled=true;
```

4. Grant usage on the external access integration to the application:

```
grant usage on integration EAI_TEST to application MY_NATIVE_APP_PROJECT_VSCODE;
```

5. Request that the application bind the integration and its secret to the UDFS.HELLO_WORLD function:

```
call MY_NATIVE_APP_PROJECT_VSCODE.UDFS.BIND_INTEGRATION('EAI_TEST');
```

6. Invoke the function, this should work:

```
select MY_NATIVE_APP_PROJECT_VSCODE.UDFS.HELLO_WORLD();
```

7. Request that the application revoke access to the DATA schema that the secret and network rule reside in:

```
call MY_NATIVE_APP_PROJECT_VSCODE.UDFS.REVOKE_SCHEMA_ACCESS();
```

6. Invoke the function again, this will fail:

```
select MY_NATIVE_APP_PROJECT_VSCODE.UDFS.HELLO_WORLD();
```

The error will be:
> Schema 'MY_NATIVE_APP_PROJECT_VSCODE.DATA' does not exist or not authorized.

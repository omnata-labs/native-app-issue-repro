## Repro for streamlit compute pool not working in a native app

Steps:

1. Ensure snowcli is installed
2. `cd` into `home/vscode`
3. deploy the native app, e.g.:
```
snow app run --connection dev -p /workspaces/native-app-issue-repro/my_app/
```
4. Create a compute pool and assign it to the streamlit:
```
CREATE COMPUTE POOL TEST_COMPUTE_POOL
  FOR APPLICATION MY_NATIVE_APP_PROJECT_VSCODE
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = CPU_X64_XS
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  AUTO_SUSPEND_SECS = 600
;

alter streamlit MY_NATIVE_APP_PROJECT_VSCODE.UI.TEST
set compute_pool=TEST_COMPUTE_POOL
QUERY_WAREHOUSE = COMPUTE_WH
RUNTIME_NAME = SYSTEM$ST_CONTAINER_RUNTIME_PY3_11;

show compute pools like 'TEST_COMPUTE_POOL';
```
5. Try to launch the streamlit

### Dev container

There is a dev container definition available for vscode users, but it mounts your local snowcli config and .ssh folder, so a little bit more effort and probably not worth it given how simple the app build/deploy is.
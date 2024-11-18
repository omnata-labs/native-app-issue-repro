## Reproduction of Snowflake support ticket 00883733

This repo contains a basic native app which can be used to reproduce the issue where `to_pandas_batches` calls fail when invoked by a task. The error looks like:
```
000709 (02000): 01b82abe-3203-ce4f-0000-81c105b674e6: Statement 01b82abe-3203-ce4f-0000-81c105b674e2 not found
```

### Steps

1. Deploy the native application under the 'my_app' folder, using Snowcli (`snow app run --connection="dev"`)
2. In Snowsight, as the application owner, run the following:
```
call MY_NATIVE_APP_PROJECT_VSCODE.CORE.TO_PANDAS_BATCHES_TEST();
```
It will return:
| TO_PANDAS_BATCHES_TEST |
|------------------------|
| 100000                 |

Then, under a database/schema context where you have permission to create a task, run:
```
CREATE TASK TEST_TASK
WAREHOUSE=COMPUTE_WH
AS
call MY_NATIVE_APP_PROJECT_VSCODE.CORE.TO_PANDAS_BATCHES_TEST();

```
Then:
```
execute task TEST_TASK;
```
If you open the task history, you will see an error like the one shown above.


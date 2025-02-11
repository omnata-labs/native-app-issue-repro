## How to use this example


Deploy app:
```
snow app run --connection dev --project my_app
```

Upload file:
```
snow stage copy -c dev /workspaces/native-app-issue-repro/my_app/app/infor-compass-jdbc-2023.10.jar --database MY_NATIVE_APP_PROJECT_VSCODE --schema CUSTOM_PACKAGES "@PACKAGES"
```

(Optional) Show files on stage:
```
snow stage list-files -c dev --database MY_NATIVE_APP_PROJECT_VSCODE --schema CUSTOM_PACKAGES "@PACKAGES"
```

Call the proc:
```
call MY_NATIVE_APP_PROJECT_VSCODE.CORE.JAR_LOAD_TEST();
```
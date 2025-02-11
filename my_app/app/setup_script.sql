-- This is the setup script that runs while installing a Snowflake Native App in a consumer account.
-- To write this script, you can familiarize yourself with some of the following concepts:
-- Application Roles
-- Versioned Schemas
-- UDFs/Procs
-- Extension Code
-- Refer to https://docs.snowflake.com/en/developer-guide/native-apps/creating-setup-script for a detailed understanding of this file.
create application role if not exists OMNATA_MANAGEMENT;

CREATE OR ALTER VERSIONED SCHEMA core;

-- The rest of this script is left blank for purposes of your learning and exploration.
create schema if not exists CUSTOM_PACKAGES;
create or alter stage CUSTOM_PACKAGES.PACKAGES DIRECTORY = (ENABLE=TRUE);
grant read on stage CUSTOM_PACKAGES.PACKAGES to application role OMNATA_MANAGEMENT;
grant write on stage CUSTOM_PACKAGES.PACKAGES to application role OMNATA_MANAGEMENT;

CREATE OR REPLACE PROCEDURE core.JAR_LOAD_TEST()
RETURNS VARCHAR
LANGUAGE JAVA
RUNTIME_VERSION = 11
PACKAGES = ('com.snowflake:snowpark:1.15.0')
HANDLER = 'JarLoader.test'
AS
$$
import java.sql.*;
import net.snowflake.client.jdbc.*;
import java.net.URLClassLoader;
import java.net.URL;
import java.net.URI;
import java.util.jar.JarInputStream;
import scala.collection.immutable.HashMap;

class JarLoader {
  public String test(com.snowflake.snowpark.Session session) throws Exception {
    HashMap<String, String> options = new HashMap<String, String>();
    session.file().get("@CUSTOM_PACKAGES.PACKAGES/infor-compass-jdbc-2023.10.jar","file:///tmp/",options);
    URI uri = new URI("file:///tmp/infor-compass-jdbc-2023.10.jar");
    URL url = uri.toURL();
    URL[] urls = { url };
    URLClassLoader classLoader = new URLClassLoader(urls, Thread.currentThread().getContextClassLoader());
    // Load the driver class from the JAR
    Class<?> driverClass = Class.forName("com.infor.idl.jdbc.Driver", true, classLoader);
    DriverManager.registerDriver((java.sql.Driver) driverClass.getDeclaredConstructor().newInstance());

    return "success";
  }
}
$$;
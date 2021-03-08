## Steps to install Spark+Hadoop+Hive

Dowload and place the `scripts` driectory at the `${USER}` home directory and execute `chmod 755 scripts/*`.

Keep the other required configuration directories (`hadoop_conf`, `hive_conf`, `spark_conf`) downloaded to the same directory as the `scripts`.

_NOTE: You can modify the installation locations and soft links to your needs, following steps places all the extracts in the users' home directory_

**Step 1: Set up all the required files and directories on Driver/Master node**

1. Download the Hadoop, Spark and Hive `tar.gz` files from the archives. Make sure the versions are compatible. After extracting the tar ball, _DO NOT DELETE_ the tar files.

2. These steps and scripts assume all the machines have same ssh access key and user. [Optional] For the ease of the use you can add to more varaibles to the `~/.bashrc` file.

```
    export USER="${YOUR_USER_NAME}"
    export PEM_FILE="${PATH_TO_PEM_FILE_ON_YOUR_MACHINE}"
```

3. Create soft links to the folders and add the paths in `~/.bashrc` file (depending on the shell you are using it may differ).

```
    ln -s ${HADOOP_decompressed_directory} hadoop
    ln -s ${HIVE_decompressed_directory} hive
    ln -s ${SPARK_decompressed_directory} spark
```

* Java location on most of the ubuntu machines is `/usr/lib/jvm/java-8-openjdk-amd64`.

```
    # JAVA configuration
    export JAVA_HOME="${JVM_INSTALLATION_DIRECTORY}"
    
    # Hadoop configuration
    export HADOOP_HOME="/home/${USER}/hadoop"
    PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

    # Apache Hive configurations
    export HIVE_HOME="/home/${USER}/hive"
    export HIVE_CONF_DIR="${HIVE_HOME}/conf"
    PATH=${PATH}:${HIVE_HOME}/bin
    
    # Apache Spark configuration
    export SPARK_HOME="/home/${USER}/spark"
    PATH=${PATH}:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

    # AWS Configurations
    export AWS_ACCESS_KEY_ID="${YOUR_KEY}"
    export AWS_SECRET_ACCESS_KEY="${YOUR_SECRET}"
```

4. Execute command `mkdir machines`, within this directory create two lists `serverlist` and `workers`. List all the _private_ IP address in the `serverlist` file including the `driver/main/master` node. Again list the same addresses in the `workers` file, except for the `driver` IP address.

5. Add the IP and hostname mapping to the `/etc/hosts` file on the `driver` machine. (Assuming `driver` machine is used for the installation process)

```
    172.0.0.1 Driver
    172.0.0.2 Worker-1
    172.0.0.3 Worker-2
```

6. To start using the updated `~/.bashrc` on `driver` node use - `source ~/.bashrc`

7. Copy the `~/.bashrc` to all workers - `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers /home/${USER}/.bashrc /home/${USER}/`

7. Start using the bash environments on all machines - `bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "source ~/.bashrc"`

8. Sometimes the environment variables are not reflected using `source` command, you may need to `reboot` the machines.

**Step 2: Set up password-less SSH**

1. Sync the hosts all nodes using command - `bash scripts/syncDNS.sh ${USER} ${PEM_FILE} machines/workers`

2. Copy the `PEM` file to all the nodes using command -  `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers ${PEM_FILE} ${PEM_FILE}`

3. Setup password-less SSH using command - `bash scripts/passwordfree.sh ${USER} ${PEM_FILE} machines/serverlist`


**Step 3: Set up framework directories on worker nodes and set up the soft links**

1. Copy the tarball to all workers for all the 3 frameworks :-

```
    bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers /home/${USER}/${hadoop-tar-file} /home/${USER}/

    bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers /home/${USER}/${hive-tar-file} /home/${USER}/

    bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers /home/${USER}/${spark-tar-file} /home/${USER}/
```

2. Decompress the tarball on all the workers :-

```
    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "tar -xvf /home/${USER}/${hadoop-tar-file}"

    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "tar -xvf /home/${USER}/${hive-tar-file}"

    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "tar -xvf /home/${USER}/${spark-tar-file}"
```

3. Create soft links on all the workers :- 

```
    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "ln -s /home/${USER}/${HADOOP_decompressed_directory} /home/${USER}/hadoop"

    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "ln -s /home/${USER}/${HIVE_decompressed_directory} /home/${USER}/hive"

    bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "ln -s /home/${USER}/${SPARK_decompressed_directory} /home/${USER}/spark"
```

4. Sync the `~/.bashrc` file on all the workers using command - `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/workers ~/.bashrc ~/.bashrc`

5. To start using the updated `~/.bashrc` file use command - `bash scripts/sshWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "source ~/.bashrc"`


**Updating the worker node addresses**

1. Update for Hadoop nodes - `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist machines/workers "${HADOOP_HOME}"/etc/hadoop/slaves` 

2. Update for Hive nodes - `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist machines/workers "${HIVE_HOME}"/conf/slaves` 

3. Update for Spark nodes - `bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist machines/workers "${SPARK_HOME}"/conf/slaves`


**Step 4: Configure Hadoop**

1. There are four configuration files within the `hadoop_conf` directory, `core-site.xml`, `hdfs-site.xml`, `mapred-site.xml`
and `yarn-site.xml`

2. In each of the files replace `${MASTER_NODE_PRIVATE_IP}` with the IP of your master node. Modify the `<value/>` parameter 
of each configuration as desired.

3. Copy the configuration files to the `conf` directory of the hadoop installation location.
`bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "hadoop_conf/*" "${HADOOP_HOME}"/etc/hadoop/` 


**Step 5: Configure Hive**

1. Copy the file using command - `cp "${HIVE_HOME}"/conf/hive-default.xml.template hive_conf/hive-site.xml`

2. Add the following configuration at the begining within `hive_conf/hive-site.xml` file :-

```
  <property>
    <name>hive.metastore.schema.verification</name>
    <value>false</value>
  </property> 
  <property>
    <name>fs.s3a.awsAccessKeyId</name>
    <value>${YOUR_ACESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.awsSecretAccessKey</name>
    <value>${YOUR_SECRET}</value>
  </property>
  <property>
    <name>system:java.io.tmpdir</name>
    <value>/tmp/hive/java</value>
  </property>
  <property>
    <name>system:user.name</name>
    <value>${user.name}</value>
  </property>
```

2. Copy `hadoop_conf/core-site.xml` to `hive_conf/` directory.

3. Copy the configuration files to the `conf` directory of the hive installation location.
`bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "hive_conf/*" "${HIVE_HOME}"/conf/`

4. Start the Hadoop DFS and create the hive required directories :-

    * `hdfs dfs -mkdir -p /user/hive/warehouse`
    * `hdfs dfs -mkdir /tmp`
    * `hdfs dfs -chmod g+w /user/hive/warehouse`
    * `hdfs dfs -chmod g+w /tmp`

5. Create the metastore using default derby server - `schematool -initSchema -dbType derby`

 
 **Step 6: Configure Spark**

 1. There are two configuration file `spark-env.sh` and `spark-defaults.conf`.

 2. In each of the files replace `${MASTER_NODE_PRIVATE_IP}` with the IP of your master node.

 3. Copy `hadoop_conf/core-site.xml`, `hadoop_conf/hdfs-site.xml` and `hive_conf/hive-site.xml` to `spark_conf` directory.

 4. Copy the configuration files to the `conf` directory of the spark installation location.
`bash scripts/scpWorkers.sh ${USER} ${PEM_FILE} machines/serverlist "spark_conf/*" "${SPARK_HOME}"/conf/` 

5. Create history diretory on HDFS - `hdfs dfs -mkdir -p /applicationHistory`


**Commands to start Services**

* start-dfs.sh
* start-history-server.sh
* $SPARK_HOME/sbin/start-all.sh

**Commands to stop Services**

* $SPARK_HOME/sbin/stop-all.sh
* stop-history-server.sh
* stop-dfs.sh


org.quartz.scheduler.rmi.export=true
org.quartz.scheduler.rmi.createRegistry=true
org.quartz.scheduler.rmi.registryHost=localhost
org.quartz.scheduler.rmi.registryPort=1099
org.quartz.threadPool.class=org.quartz.simpl.SimpleThreadPool
org.quartz.threadPool.threadCount=20
#Quartz Server Properties
quartz.scheduler.instanceName=ServerScheduler
org.quartz.scheduler.instanceId=AUTO
org.quartz.scheduler.skipUpdateCheck=true
org.quartz.scheduler.jobFactory.class=org.quartz.simpl.SimpleJobFactory
org.quartz.jobStore.class=org.quartz.impl.jdbcjobstore.JobStoreTX
org.quartz.jobStore.driverDelegateClass=org.quartz.impl.jdbcjobstore.PostgreSQLDelegate
org.quartz.jobStore.dataSource=quartzDataSource
org.quartz.jobStore.tablePrefix=QRTZ_
org.quartz.jobStore.isClustered=false
org.quartz.scheduler.misfirePolicy=doNothing
org.quartz.job-store-type=jdbc

#Database
org.quartz.dataSource.quartzDataSource.driver=org.postgresql.Driver
org.quartz.dataSource.quartzDataSource.URL=[=connectionStringInfo.url]
org.quartz.dataSource.quartzDataSource.user=[=connectionStringInfo.username]
org.quartz.dataSource.quartzDataSource.password=[=connectionStringInfo.password]
org.quartz.dataSource.quartzDataSource.maxConnections=15
        
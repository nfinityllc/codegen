package com.nfinity.fastcode.SchedulerService;


import org.quartz.Trigger.TriggerState;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;
import org.springframework.stereotype.Component;

import com.google.gson.Gson;
import com.nfinity.fastcode.Constants.QuartzConstants;
import com.nfinity.fastcode.application.Scheduler.Dto.GetJobOutput;
import com.nfinity.fastcode.application.Scheduler.Dto.JobDetails;
import com.nfinity.fastcode.application.Scheduler.Dto.TriggerCreationDetails;
import com.nfinity.fastcode.application.Scheduler.Dto.TriggerDetails;
import com.nfinity.fastcode.domain.Scheduler.JobHistoryEntity;
import com.nfinity.fastcode.logging.LoggingHelper;
import org.quartz.*;

import java.util.*;


@Component
public class SchedulerServiceUtil {

	@Autowired
	private LoggingHelper logHelper;

	@Autowired
	Scheduler scheduler;

	@Autowired
	SchedulerFactoryBean schedulerFactoryBean;

	private QuartzConstants quartzConstant;

	public Scheduler getScheduler() throws SchedulerException
	{
		scheduler=schedulerFactoryBean.getScheduler();
		//scheduler.start();
		return scheduler;
	}
	public TriggerDetails ReturnTriggerDetails (Trigger trigger) throws SchedulerException
	{
		TriggerKey triggKey = trigger.getKey();
		String trigName = triggKey.getName();
		String trigGroup = triggKey.getGroup();
		String trigType = quartzConstant.SIMPLE_TRIGGER;
		if (trigger.getClass().toString().equals(quartzConstant.CRON_TRIGGER_CLASS))
			trigType = quartzConstant.CRON_TRIGGER;

		Date nextFireTime = trigger.getNextFireTime();
		Date endTime = trigger.getEndTime();
		Date fireTime = trigger.getStartTime();
		Date lastFireTime =trigger.getPreviousFireTime();

		String triggerState = getScheduler().getTriggerState(triggKey).toString();

		String triggerDescription = getScheduler().getTrigger(triggKey).getDescription();

		String[] triggerKeyValues =getScheduler().getTrigger(triggKey).getJobDataMap().getKeys();
		Map<String, String> triggerMap = new HashMap<String, String>();
		for (int j = 0; j < triggerKeyValues.length; j++) {
			String str =getScheduler().getTrigger(triggKey).getJobDataMap().getString(triggerKeyValues[j]);
			triggerMap.put(triggerKeyValues[j], str);
		}

		TriggerDetails triggDetails = new TriggerDetails(trigName, trigGroup, triggerState, trigType, triggerDescription, triggerMap, fireTime, endTime,
				lastFireTime, nextFireTime);

		return triggDetails;

	}

	public JobDetails ReturnJobDetails (JobKey jobKey) throws SchedulerException
	{	
		Class<? extends Job> jobClassObject = getScheduler().getJobDetail(jobKey).getJobClass();
		String jobClass = jobClassObject.toString();
		jobClass = jobClass.substring(jobClass.indexOf(' ') + 1);
		String jobStatus = null;
		String jobDescription = getScheduler().getJobDetail(jobKey).getDescription();
		boolean isDurable = getScheduler().getJobDetail(jobKey).isDurable();

		if (isJobRunning(jobKey.getName(), jobKey.getGroup()))
			jobStatus =quartzConstant.JOB_STATUS_RUNNING;
		else
			jobStatus = getJobState(jobKey.getName(), jobKey.getGroup());



		String[] jobKeyValues = getScheduler().getJobDetail(jobKey).getJobDataMap().getKeys();
		Map<String, String> map = new HashMap<String, String>();
		for (int i = 0; i < jobKeyValues.length; i++) {
			String st = getScheduler().getJobDetail(jobKey).getJobDataMap().getString(jobKeyValues[i]);
			map.put(jobKeyValues[i], st);
		}

		JobDetails jobDetails = new JobDetails(jobKey.getName(), jobKey.getGroup(), jobClass, jobDescription, map, null, isDurable, jobStatus);
		return jobDetails;

	}

	public boolean isJobRunning(String jobName, String jobGroup) throws SchedulerException {


		JobKey jobkey = new JobKey(jobName, jobGroup);

		List<JobExecutionContext> executingJobs = getScheduler().getCurrentlyExecutingJobs();
		for (int i = 0; i < executingJobs.size(); i++) {
			JobKey executingJobKey = executingJobs.get(i).getJobDetail().getKey();
			if (executingJobKey.getName().equals(jobName) && executingJobKey.getGroup().equals(jobGroup)) {
				return true;
			}
		}

		return false;
	}

	public String getJobState(String jobName, String jobGroup) throws SchedulerException {

		try {

			JobKey jobKey = new JobKey(jobName, jobGroup);
			JobDetail jobDetail = getScheduler().getJobDetail(jobKey);

			List<? extends Trigger> triggers = getScheduler().getTriggersOfJob(jobDetail.getKey());
			if (triggers != null && triggers.size() > 0) {
				for (Trigger trigger : triggers) {
					TriggerState triggerState = getScheduler().getTriggerState(trigger.getKey());
                 
					if (TriggerState.PAUSED.equals(triggerState)) {
						return "PAUSED";
					} else if (TriggerState.BLOCKED.equals(triggerState)) {
						return "BLOCKED";
					} else if (TriggerState.COMPLETE.equals(triggerState)) {
						return "COMPLETE";
					} else if (TriggerState.ERROR.equals(triggerState)) {
						return "ERROR";
					} else if (TriggerState.NONE.equals(triggerState)) {
						return "NONE";
					} else if (TriggerState.NORMAL.equals(triggerState)) {
						return "SCHEDULED";
					}
				}
			}
		} catch (SchedulerException e) {
			logHelper.getLogger().error("SchedulerException while fetching all jobs. error message :" + e.getMessage());
			e.printStackTrace();
		}
		return null;
	}

	public List<GetJobOutput> ReturnJobOutput(List<JobHistoryEntity> jobList)
	{
		List<GetJobOutput> list = new ArrayList<GetJobOutput>();

		for (int i = 0; i < jobList.size(); i++) {
			GetJobOutput obj = new GetJobOutput();
			obj.setId(jobList.get(i).getId());
			obj.setJobName(jobList.get(i).getJobName());
			obj.setJobGroup(jobList.get(i).getJobGroup());
			obj.setJobClass(jobList.get(i).getJobClass());
			obj.setTriggerName(jobList.get(i).getTriggerName());
			obj.setTriggerGroup(jobList.get(i).getTriggerGroup());
			obj.setJobStatus(jobList.get(i).getJobStatus());
			obj.setJobDescription(jobList.get(i).getJobDescription());
			obj.setFiredTime(jobList.get(i).getFiredTime());
			obj.setFinishedTime(jobList.get(i).getFinishedTime());
			obj.setDuration(jobList.get(i).getDuration());

			String mapData = jobList.get(i).getJobMapData();
			Map<String, String> result = new Gson().fromJson(mapData, HashMap.class);
			obj.setJobMapData(result);

			list.add(obj);
		}

		return list;
	}
	
	public boolean UpdateCronTrigger(TriggerCreationDetails obj,TriggerKey triggerKey) throws SchedulerException
	{
		Trigger trigger;
		TriggerBuilder triggerBuilder;
		if (obj.getCronExpression() != null) {                   	
			trigger = getScheduler().getTrigger(triggerKey);
			triggerBuilder = trigger.getTriggerBuilder();
			trigger = triggerBuilder.withSchedule(CronScheduleBuilder
					.cronSchedule(obj.getCronExpression()))
					.build();

			getScheduler().rescheduleJob(triggerKey, trigger);
			return true;
		}
		else {                    
			logHelper.getLogger().error("Cron Expression must not be null");
			return false;
		}
	}

	public boolean UpdateSimpleTrigger(TriggerCreationDetails obj,TriggerKey triggerKey) throws SchedulerException
	{
		Trigger trigger;
		TriggerBuilder triggerBuilder;
		if (obj.getRepeatIndefinite() && obj.getRepeatInterval() > 0)
		{
			trigger = getScheduler().getTrigger(triggerKey);
			triggerBuilder = trigger.getTriggerBuilder();
			trigger = triggerBuilder
					.withSchedule(SimpleScheduleBuilder
							.simpleSchedule()
							.repeatForever()
							.withIntervalInSeconds(obj.getRepeatInterval()))
					.build();

			getScheduler().rescheduleJob(triggerKey, trigger);
			return true;
		}
		else if (!obj.getRepeatIndefinite() && obj.getRepeatCount() > 0 && obj.getRepeatInterval() > 0) {
			trigger = getScheduler().getTrigger(triggerKey);
			triggerBuilder = trigger.getTriggerBuilder();
			trigger = triggerBuilder
					.withSchedule(SimpleScheduleBuilder
							.simpleSchedule()
							.withIntervalInSeconds(obj.getRepeatInterval())
							.withRepeatCount(obj.getRepeatCount()))
					.build();
			getScheduler().rescheduleJob(triggerKey, trigger);
			return true;
		} 
		else {
			trigger = getScheduler().getTrigger(triggerKey);
			triggerBuilder= trigger.getTriggerBuilder();
			trigger = triggerBuilder
					.withSchedule(SimpleScheduleBuilder
							.simpleSchedule())
					.build();

			getScheduler().rescheduleJob(triggerKey, trigger);
			return true;
		} 
		
	}

	//CronnTrigger
	public Trigger CreateCronTrigger(TriggerCreationDetails obj, JobDetail jobDetail)
	{

		if(obj.getCronExpression() == null)
		{
			logHelper.getLogger().error("Cron Expression must not be null");
            return null;
		}
		else
		{
			if(obj.getStartTime() == null)
			{
				obj.setStartTime(new Date());
			}

			if(obj.getEndTime() !=null)
			{
				Trigger trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime()).endAt(obj.getEndTime())
						.withSchedule(CronScheduleBuilder.cronSchedule(obj.getCronExpression()))
						.build();
				return trigger;
			}
			else
			{
				Trigger trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime())
						.withSchedule(CronScheduleBuilder.cronSchedule(obj.getCronExpression()))
						.build();
				return trigger;
			}
		}
	}

	public Trigger CreateSimpleTrigger (TriggerCreationDetails obj, JobDetail jobDetail)
	{
		Trigger trigger ;
		if(obj.getStartTime() ==null)
		{
			obj.setStartTime(new Date());
		}
		if(obj.getEndTime() !=null)
		{
			if (obj.getRepeatIndefinite() && obj.getRepeatInterval() > 0) {
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime())
						.endAt(obj.getEndTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule().repeatForever()
								.withIntervalInSeconds(obj.getRepeatInterval())
								).build();
			} else if (!obj.getRepeatIndefinite() && obj.getRepeatCount() > 0 && obj.getRepeatInterval() > 0) {
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime())
						.endAt(obj.getEndTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule().withRepeatCount(obj.getRepeatCount())
								.withIntervalInSeconds(obj.getRepeatInterval())
								).build();	
			} 
			else
			{
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime())
						.endAt(obj.getEndTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule()).build();
			}

		}
		else
		{
			if (obj.getRepeatIndefinite() && obj.getRepeatInterval() > 0) {
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule().repeatForever()
								.withIntervalInSeconds(obj.getRepeatInterval())
								).build();
			} else if (!obj.getRepeatIndefinite() && obj.getRepeatCount() > 0 && obj.getRepeatInterval() > 0) {
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule().withRepeatCount(obj.getRepeatCount())
								.withIntervalInSeconds(obj.getRepeatInterval())
								).build();	
			} else
			{
				trigger = TriggerBuilder.newTrigger().forJob(jobDetail)
						.withIdentity(obj.getTriggerName(), obj.getTriggerGroup())
						.withDescription(obj.getTriggerDescription())
						.startAt(obj.getStartTime()).withSchedule(
								SimpleScheduleBuilder
								.simpleSchedule()).build();
			}
		}

		return trigger;
	}

}
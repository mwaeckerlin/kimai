# Downgrading schema 0.9.3 to 0.9.2

+-------------------+
| Tables_in_kimai   |
+-------------------+
| kimai_evt         | kimai_activities (Tatigkeiten)
| kimai_exp         |
| kimai_grp         | 
| kimai_grp_evt     | kimai_groups_activities
| kimai_grp_knd     | kimai_groups_customers
| kimai_grp_pct     | kimai_groups_projects
| kimai_knd         | kimai_customers
| kimai_ldr         |
| kimai_pct         | kimai_projects
| kimai_pct_evt     | kimai_projects_activities
| kimai_preferences |
| kimai_rates       |
| kimai_usr         |
| kimai_var         |
| kimai_zef         | kimai_timeSheet
+-------------------+


insert into kimai_grp (grp_ID, grp_name, grp_trash) select groupID, name, trash from kimai_groups where name <> 'admin';

insert into kimai_usr (usr_ID, usr_name, usr_alias, usr_grp, usr_sts, usr_trash, usr_active, usr_mail, pw, ban, banTime, secure, lastProject, lastEvent, lastRecord, timespace_in, timespace_out) select distinct u.userId, u.name, u.alias, 2, status, trash, active, mail, password, ban, banTime, secure, lastProject, lastActivity, lastRecord, timeframeBegin, timeframeEnd from kimai_users u where u.name <> 'admin';

delete from kimai_knd;
insert into kimai_knd (knd_ID, knd_name) select customerID, name from kimai_customers;

delete from kimai_pct;
insert into kimai_pct (pct_ID, pct_kndID, pct_name, pct_visible, pct_trash, pct_internal) select projectID, customerID, name, visible, trash, internal from kimai_projects;

delete from kimai_evt;
insert into kimai_evt (evt_ID, evt_name, evt_visible, evt_trash) select activityID, name, visible, trash from kimai_activities;

delete from kimai_grp_knd;
insert into kimai_grp_knd (grp_ID, knd_ID) select groupID, customerID from kimai_groups_customers;

delete from kimai_grp_pct;
insert into kimai_grp_pct (grp_ID, pct_ID) select groupID, projectID from kimai_groups_projects;

delete from kimai_grp_evt;
insert into kimai_grp_evt (grp_ID, evt_ID) select groupID, activityID from kimai_groups_activities;

insert into kimai_zef (zef_ID, zef_in, zef_out, zef_time, zef_usrID, zef_pctID, zef_evtID, zef_comment, zef_comment_type, zef_cleared, zef_location, zef_trackingnr, zef_rate) select timeEntryID, start, end, duration, userID, projectID, activityID, comment, commentType, cleared, location, trackingNumber, rate from kimai_timeSheet;

delete from kimai_pct_evt;
insert into kimai_pct_evt (pct_ID, evt_ID) select projectID, activityID from kimai_projects_activities;

drop table kimai_timeSheet;
drop table kimai_groups_activities;
drop table kimai_groups_customers;
drop table kimai_groups_projects;
drop table kimai_projects_activities;
drop table kimai_projects;
drop table kimai_customers;
drop table kimai_activities;

drop table kimai_configuration;
drop table kimai_expenses;
drop table kimai_fixedRates;
drop table kimai_groupleaders;
drop table kimai_groups_users;
drop table kimai_groups;
drop table kimai_users;
drop table kimai_statuses;

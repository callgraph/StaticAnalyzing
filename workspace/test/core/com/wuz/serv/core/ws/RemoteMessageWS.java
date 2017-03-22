package com.wuz.serv.core.ws;

public interface RemoteMessageWS {

	String getMessage(String taskName, String uids, String orgId, String url,
			String finishConditionNum);
}

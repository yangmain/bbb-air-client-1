package org.bigbluebutton.core
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	import mx.utils.ObjectUtil;
	
	import org.bigbluebutton.core.util.URLFetcher;
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	public class EnterService
	{
		protected var _successSignal:Signal = new Signal();
		protected var _unsuccessSignal:Signal = new Signal();
		
		public function get successSignal():ISignal {
			return _successSignal;
		}
		
		public function get unsuccessSignal():ISignal {
			return _unsuccessSignal;
		}
		
		public function enter(enterUrl:String, urlRequest:URLRequest):void {
			var fetcher:URLFetcher = new URLFetcher;
			fetcher.successSignal.add(onEnterResponse);
			fetcher.unsuccessSignal.add(onUnsuccess);
			fetcher.fetch(enterUrl, urlRequest);
		}
		
		protected function onEnterResponse(data:Object, responseUrl:String, urlRequest:URLRequest):void {
			try {
				onEnterResponseHelper(new XML(data));
			} catch (e:Error) {
				onUnsuccess("invalidEnterXml");
			}
		}
		
		protected function onEnterResponseHelper(xml:XML):void {
			if (xml.returncode == 'SUCCESS') {
				trace("Enter SUCCESS");
				var user:Object = {
					username:xml.fullname, 
					conference:xml.conference, 
					conferenceName:xml.confname,
					externMeetingID:xml.externMeetingID,
					meetingID:xml.meetingID, 
					externUserID:xml.externUserID, 
					internalUserId:xml.internalUserID,
					role:xml.role, 
					room:xml.room, 
					authToken:xml.room, 
					record:xml.record, 
					webvoiceconf:xml.webvoiceconf, 
					dialnumber:xml.dialnumber,
					voicebridge:xml.voicebridge, 
					mode:xml.mode, 
					welcome:xml.welcome, 
					logoutUrl:xml.logoutUrl, 
					defaultLayout:xml.defaultLayout, 
					avatarURL:xml.avatarURL,
					guest:xml.guest };
				user.customdata = new Object();
				if (xml.customdata) {
					for each(var cdnode:XML in xml.customdata.elements()){
						trace("checking user customdata: " + cdnode.name() + " = " + cdnode);
						user.customdata[cdnode.name()] = cdnode.toString();
					}
				}
				successSignal.dispatch(user);
			} else {
				trace("Enter FAILED");
				
				unsuccessSignal.dispatch(xml.messageKey);
			}
		}
		
		protected function onUnsuccess(reason:String):void {
			unsuccessSignal.dispatch(reason);
		}
	}
}
package
{
	import Array;
	
	import core_obj_tests.SyncEventRecorderTest;
	
	import flash.display.Sprite;
	
	import flexunit.flexui.FlexUnitTestRunnerUIAS;
	
	import org.flexunit.runner.Request;
	
	public class FlexUnitApplication extends Sprite
	{
		public function FlexUnitApplication()
		{
			onCreationComplete();
		}
		
		private function onCreationComplete():void
		{
			var testRunner:FlexUnitTestRunnerUIAS=new FlexUnitTestRunnerUIAS();
			testRunner.portNumber=8765; 
			this.addChild(testRunner); 
			testRunner.runWithFlexUnit4Runner(currentRunTestSuite(), "core_obj");
		}
		
		public function currentRunTestSuite():Array
		{
			var testsToRun:Array = new Array();
			testsToRun.push(Request.methods(core_obj_tests.SyncEventRecorderTest,["testReadFrom"]));
			
			return testsToRun;
		}
	}
}
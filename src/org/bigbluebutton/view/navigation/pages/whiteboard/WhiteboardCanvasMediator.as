package org.bigbluebutton.view.navigation.pages.whiteboard {
	
	import org.bigbluebutton.model.IUserSession;
	import org.bigbluebutton.model.whiteboard.IAnnotation;
	import org.osmf.logging.Log;
	import robotlegs.bender.bundles.mvcs.Mediator;
	
	public class WhiteboardCanvasMediator extends Mediator {
		
		[Inject]
		public var view:IWhiteboardCanvas;
		
		[Inject]
		public var userSession:IUserSession;
		
		private var _zoom:Number = 1.0;
		
		override public function initialize():void {
			Log.getLogger("org.bigbluebutton").info(String(this));
			userSession.presentationList.annotationHistorySignal.add(annotationHistoryHandler);
			userSession.presentationList.annotationUpdatedSignal.add(annotationUpdatedHandler);
			userSession.presentationList.annotationUndoSignal.add(annotationUndoHandler);
			userSession.presentationList.annotationClearSignal.add(annotationClearHandler);
			userSession.presentationList.slideChangeSignal.add(slideChangeHandler);
			view.resizeCallback = onWhiteboardResize;
		}
		
		private function annotationHistoryHandler():void {
			drawAllAnnotations();
		}
		
		private function annotationUpdatedHandler(annotation:IAnnotation):void {
			annotation.draw(view, _zoom);
		}
		
		private function annotationUndoHandler(annotation:IAnnotation):void {
			annotation.remove(view);
		}
		
		private function annotationClearHandler():void {
			removeAllAnnotations();
		}
		
		private function slideChangeHandler():void {
			removeAllAnnotations();
		}
		
		private function onWhiteboardResize(zoom:Number):void {
			trace("whiteboard zoom = " + zoom);
			_zoom = zoom;
			drawAllAnnotations();
		}
		
		private function drawAllAnnotations():void {
			var annotations:Array = userSession.presentationList.currentPresentation.getSlideAt(userSession.presentationList.currentPresentation.currentSlideNum).annotations;
			for (var i:int = 0; i < annotations.length; i++) {
				var an:IAnnotation = annotations[i] as IAnnotation;
				an.draw(view, _zoom);
			}
		}
		
		private function removeAllAnnotations():void {
			view.removeAllElements();
		}
		
		override public function destroy():void {
			userSession.presentationList.annotationHistorySignal.remove(annotationHistoryHandler);
			userSession.presentationList.annotationUpdatedSignal.remove(annotationUpdatedHandler);
			userSession.presentationList.annotationUndoSignal.remove(annotationUndoHandler);
			userSession.presentationList.annotationClearSignal.remove(annotationClearHandler);
			userSession.presentationList.slideChangeSignal.remove(slideChangeHandler);
			super.destroy();
			view.dispose();
			view = null;
		}
	}
}

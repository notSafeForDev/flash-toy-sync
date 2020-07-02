package PP_KT_34_fla
{
    import flash.display.*;
    import flash.events.*;

    dynamic public class MainTimeline extends MovieClip
    {
        public var Main1:MovieClip;
        public var b1:SimpleButton;
        public var b2:SimpleButton;
        public var b3:SimpleButton;
        public var b4:SimpleButton;
        public var b5:SimpleButton;
        public var pp34butt:MovieClip;

        public function MainTimeline()
        {
            addFrameScript(0, this.frame1);
            return;
        }// end function

        public function mouseDownHandlerPP34(event:MouseEvent) : void
        {
            this.pp34butt.play();
            return;
        }// end function

        public function b1f(event:MouseEvent)
        {
            this.Main1.gotoAndPlay("SS1");
            return;
        }// end function

        public function b2f(event:MouseEvent)
        {
            this.Main1.gotoAndPlay("SS2");
            return;
        }// end function

        public function b3f(event:MouseEvent)
        {
            this.Main1.gotoAndPlay("SS3");
            return;
        }// end function

        public function b4f(event:MouseEvent)
        {
            this.Main1.gotoAndPlay("SS4");
            return;
        }// end function

        public function b5f(event:MouseEvent)
        {
            this.Main1.gotoAndPlay("SSCUM");
            return;
        }// end function

        function frame1()
        {
            stop();
            this.pp34butt.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownHandlerPP34);
            this.b1.addEventListener(MouseEvent.CLICK, this.b1f);
            this.b2.addEventListener(MouseEvent.CLICK, this.b2f);
            this.b3.addEventListener(MouseEvent.CLICK, this.b3f);
            this.b4.addEventListener(MouseEvent.CLICK, this.b4f);
            this.b5.addEventListener(MouseEvent.CLICK, this.b5f);
            return;
        }// end function

    }
}

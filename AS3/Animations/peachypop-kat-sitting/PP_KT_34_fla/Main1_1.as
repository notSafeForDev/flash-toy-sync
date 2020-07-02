package PP_KT_34_fla
{
    import flash.display.*;
    import flash.events.*;

    dynamic public class Main1_1 extends MovieClip
    {
        public var arm2:MovieClip;
        public var arm3:MovieClip;
        public var bod:MovieClip;
        public var boob1:MovieClip;
        public var boob2:MovieClip;
        public var bum:MovieClip;
        public var butclo:SimpleButton;
        public var forearm:MovieClip;
        public var leg1:MovieClip;
        public var leg2:MovieClip;
        public var leg3:MovieClip;
        public var legbot:MovieClip;
        public var musicb:MovieClip;

        public function Main1_1()
        {
            addFrameScript(0, this.frame1, 37, this.frame38, 92, this.frame93, 114, this.frame115, 132, this.frame133, 389, this.frame390);
            return;
        }// end function

        public function clotha(event:MouseEvent) : void
        {
            this.boob1.play();
            this.boob2.play();
            this.bod.play();
            this.bum.play();
            this.arm2.play();
            this.arm3.play();
            this.forearm.play();
            this.leg1.play();
            this.leg2.play();
            this.leg3.play();
            this.legbot.play();
            return;
        }// end function

        function frame1()
        {
            this.butclo.addEventListener(MouseEvent.MOUSE_DOWN, this.clotha);
            return;
        }// end function

        function frame38()
        {
            gotoAndPlay("SS1");
            return;
        }// end function

        function frame93()
        {
            gotoAndPlay("SS2");
            return;
        }// end function

        function frame115()
        {
            gotoAndPlay("SS3");
            return;
        }// end function

        function frame133()
        {
            gotoAndPlay("SS4");
            return;
        }// end function

        function frame390()
        {
            gotoAndPlay("Finish");
            return;
        }// end function

    }
}
